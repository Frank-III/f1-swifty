//
//  AustriaLiveMapView.swift
//  F1-Dash
//
//  Live view showing Austria track data from server
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - Live Data Fetcher

@MainActor
class AustriaLiveDataFetcher: ObservableObject {
    @Published var positionData: [String: (x: Double, y: Double, status: String)] = [:]
    @Published var trackMapData: TrackMapResponse?
    @Published var isLoading = false
    @Published var error: String?
    
    private var timer: Timer?
    
    struct TrackMapResponse: Codable {
        let x: [Double]
        let y: [Double]
        let rotation: Double
        let circuitName: String
    }
    
    init() {
        fetchTrackMap()
        startPolling()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func fetchTrackMap() {
        Task {
            do {
                let url = URL(string: "https://api.multiviewer.app/api/v1/circuits/19/2023")!
                let (data, _) = try await URLSession.shared.data(from: url)
                self.trackMapData = try JSONDecoder().decode(TrackMapResponse.self, from: data)
                print("Loaded track map for \(trackMapData?.circuitName ?? "Unknown")")
            } catch {
                print("Failed to load track map: \(error)")
            }
        }
    }
    
    func startPolling() {
        fetchPositions()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                self.fetchPositions()
            }
        }
    }
    
    func fetchPositions() {
        Task {
            do {
                let url = URL(string: "http://localhost:3000/api/state")!
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let posData = json["positionData"] as? [String: Any],
                   let positions = posData["positionData"] as? [[String: Any]],
                   let latestFrame = positions.last,
                   let entries = latestFrame["entries"] as? [String: [String: Any]] {
                    
                    var newPositions: [String: (x: Double, y: Double, status: String)] = [:]
                    
                    for (driver, pos) in entries {
                        if let x = pos["x"] as? Double,
                           let y = pos["y"] as? Double,
                           let status = pos["status"] as? String {
                            newPositions[driver] = (x: x, y: y, status: status)
                        }
                    }
                    
                    self.positionData = newPositions
                    self.error = nil
                }
            } catch {
                self.error = "Failed to fetch positions: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Austria Live Map View

struct AustriaLiveMapView: View {
    @StateObject private var dataFetcher = AustriaLiveDataFetcher()
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 47.2197, longitude: 14.7647),
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )
    )
    @State private var showSatellite = true
    @State private var scale: Double = 0.3
    @State private var showDebugInfo = true
    
    let austriaCenter = CLLocationCoordinate2D(latitude: 47.2197, longitude: 14.7647)
    
    // Driver colors
    let teamColors: [String: Color] = [
        "1": Color(hex: "#1B2A48") ?? .blue,   // Red Bull
        "11": Color(hex: "#1B2A48") ?? .blue,
        "44": Color(hex: "#00A19B") ?? .cyan,  // Mercedes
        "63": Color(hex: "#00A19B") ?? .cyan,
        "16": Color(hex: "#DC0000") ?? .red,   // Ferrari
        "55": Color(hex: "#DC0000") ?? .red,
        "4": Color(hex: "#FF8700") ?? .orange, // McLaren
        "81": Color(hex: "#FF8700") ?? .orange,
        "14": Color(hex: "#229971") ?? .green,  // Aston Martin
        "18": Color(hex: "#229971") ?? .green
    ]
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                // Track outline
                if let trackData = dataFetcher.trackMapData {
                    MapPolyline(coordinates: createTrackOutline(from: trackData))
                        .stroke(.red, lineWidth: 3)
                }
                
                // Driver positions
                ForEach(Array(dataFetcher.positionData.keys), id: \.self) { driver in
                    if let pos = dataFetcher.positionData[driver] {
                        let coordinate = transformToGPS(x: pos.x, y: pos.y)
                        
                        Annotation(driver, coordinate: coordinate) {
                            ZStack {
                                Circle()
                                    .fill(teamColors[driver] ?? .gray)
                                    .frame(width: 24, height: 24)
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                Text(driver)
                                    .font(.caption2.bold())
                                    .foregroundColor(.white)
                            }
                            .opacity(pos.status == "OnTrack" ? 1.0 : 0.5)
                        }
                    }
                }
            }
            .mapStyle(showSatellite ? .hybrid(elevation: .realistic) : .standard)
            
            // Overlay controls
            VStack {
                HStack {
                    // Map style
                    Button(showSatellite ? "Satellite" : "Standard") {
                        showSatellite.toggle()
                    }
                    .buttonStyle(.bordered)
                    
                    // Debug toggle
                    Button(showDebugInfo ? "Hide Debug" : "Show Debug") {
                        showDebugInfo.toggle()
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    // Connection status
                    HStack {
                        Circle()
                            .fill(dataFetcher.error == nil ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        Text(dataFetcher.error == nil ? "Connected" : "Error")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.regularMaterial)
                    .cornerRadius(8)
                }
                .padding()
                
                Spacer()
                
                // Debug info
                if showDebugInfo {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Austria - Red Bull Ring")
                            .font(.headline)
                        
                        if let trackData = dataFetcher.trackMapData {
                            Text("Track: \(trackData.circuitName)")
                                .font(.caption)
                            Text("Rotation: \(Int(trackData.rotation))°")
                                .font(.caption)
                            Text("Points: \(trackData.x.count)")
                                .font(.caption)
                        }
                        
                        Divider()
                        
                        Text("Live Positions: \(dataFetcher.positionData.count) cars")
                            .font(.caption)
                        
                        // Scale control
                        VStack(alignment: .leading) {
                            Text("Scale: \(scale, specifier: "%.2f")")
                                .font(.caption)
                            Slider(value: $scale, in: 0.1...0.5)
                        }
                        
                        if let error = dataFetcher.error {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(12)
                    .padding()
                }
            }
        }
        .navigationTitle("Austria Live Track Map")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    // MARK: - Helper Functions
    
    private func createTrackOutline(from trackData: AustriaLiveDataFetcher.TrackMapResponse) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        
        // Sample every nth point to reduce complexity
        let step = max(1, trackData.x.count / 100)
        
        for i in stride(from: 0, to: trackData.x.count, by: step) {
            let gps = transformToGPS(
                x: trackData.x[i],
                y: trackData.y[i],
                rotation: trackData.rotation
            )
            coordinates.append(gps)
        }
        
        // Close the loop
        if let first = coordinates.first {
            coordinates.append(first)
        }
        
        return coordinates
    }
    
    private func transformToGPS(
        x: Double,
        y: Double,
        rotation: Double = 1
    ) -> CLLocationCoordinate2D {
        // Apply scale
        let scaledX = x * scale
        let scaledY = -y * scale  // Invert Y
        
        // Apply rotation
        let rotRad = rotation * .pi / 180
        let rotatedX = scaledX * cos(rotRad) - scaledY * sin(rotRad)
        let rotatedY = scaledX * sin(rotRad) + scaledY * cos(rotRad)
        
        // Convert to GPS
        let latRad = austriaCenter.latitude * .pi / 180
        let metersPerDegreeLat = 111132.92 - 559.82 * cos(2 * latRad)
        let metersPerDegreeLon = 111412.84 * cos(latRad)
        
        let deltaLat = rotatedY / metersPerDegreeLat
        let deltaLon = rotatedX / metersPerDegreeLon
        
        return CLLocationCoordinate2D(
            latitude: austriaCenter.latitude + deltaLat,
            longitude: austriaCenter.longitude + deltaLon
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AustriaLiveMapView()
    }
}