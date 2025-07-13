//
//  MapKitTrackMapTestView.swift
//  F1-Dash
//
//  Test view for displaying F1 car positions on real MapKit maps
//

import SwiftUI
import MapKit
import F1DashModels
import CoreLocation

// MARK: - Coordinate Transformer

struct CoordinateTransformer {
    // Albert Park circuit center (Melbourne, Australia)
    static let albertParkCenter = CLLocationCoordinate2D(latitude: -37.8497, longitude: 144.9680)
    
    // Approximate scale factors for Melbourne latitude
    // At this latitude: 1 degree latitude ≈ 111 km, 1 degree longitude ≈ 93 km
    static let metersPerDegreeLat = 111_000.0
    static let metersPerDegreeLon = 93_000.0
    
    // Scale factor to adjust telemetry coordinates to real world
    // This needs to be tuned based on the actual track size
    static let telemetryScale = 0.1 // Reduced scale - telemetry units seem larger than meters
    
    // Transform telemetry coordinates to GPS coordinates
    static func telemetryToGPS(
        telemetryX: Double,
        telemetryY: Double,
        circuitCenter: CLLocationCoordinate2D,
        rotation: Double = 0
    ) -> CLLocationCoordinate2D {
        // Scale down telemetry coordinates first
        let scaledX = telemetryX * telemetryScale
        let scaledY = telemetryY * telemetryScale
        
        // Apply rotation if needed (convert to radians)
        let rotationRad = rotation * .pi / 180.0
        let rotatedX = scaledX * cos(rotationRad) - scaledY * sin(rotationRad)
        let rotatedY = scaledX * sin(rotationRad) + scaledY * cos(rotationRad)
        
        // Convert meters to degrees
        let deltaLat = rotatedY / metersPerDegreeLat
        let deltaLon = rotatedX / metersPerDegreeLon
        
        // Add to circuit center
        return CLLocationCoordinate2D(
            latitude: circuitCenter.latitude + deltaLat,
            longitude: circuitCenter.longitude + deltaLon
        )
    }
}

// MARK: - Car Annotation

struct CarAnnotation: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let driverNumber: String
    let driverTLA: String
    let teamColor: Color
    let isOnTrack: Bool
}

// MARK: - MapKit Test View Model

@MainActor
@Observable
final class MapKitTestViewModel {
    // Test position data based on the provided sample
    private let testPositions: [String: (x: Double, y: Double, status: String)] = [
        "44": (x: -4437, y: -261, status: "OnTrack"),
        "18": (x: -8209, y: 5460, status: "OnTrack"),
        "27": (x: -6421, y: 5658, status: "OnTrack"),
        "22": (x: -3262, y: -2076, status: "OnTrack"),
        "81": (x: -1525, y: -1921, status: "OnTrack"),
        "4": (x: -5830, y: 2294, status: "OnTrack"),
        "23": (x: -6430, y: 3390, status: "OnTrack"),
        "24": (x: 673, y: -1324, status: "OnTrack"),
        "20": (x: -4470, y: -212, status: "OnTrack"),
        "11": (x: -6686, y: 5674, status: "OnTrack"),
        "10": (x: -2738, y: -2236, status: "OnTrack"),
        "31": (x: -6167, y: 2979, status: "OnTrack"),
        "55": (x: -7311, y: 5669, status: "OnTrack"),
        "14": (x: -8070, y: 5088, status: "OnTrack"),
        "1": (x: -1362, y: 4963, status: "OnTrack"),
        "63": (x: -5082, y: 775, status: "OnTrack"),
        "2": (x: -993, y: -1774, status: "OnTrack"),
        "21": (x: -2256, y: -2122, status: "OnTrack"),
        "77": (x: 2347, y: -872, status: "OnTrack"),
        "16": (x: -6028, y: 2710, status: "OnTrack")
    ]
    
    // Driver info mapping
    private let driverInfo: [String: (tla: String, teamColor: String)] = [
        "1": ("VER", "#1B2A48"), "11": ("PER", "#1B2A48"), // Red Bull
        "44": ("HAM", "#00A19B"), "63": ("RUS", "#00A19B"), // Mercedes
        "16": ("LEC", "#DC0000"), "55": ("SAI", "#DC0000"), // Ferrari
        "4": ("NOR", "#FF8700"), "81": ("PIA", "#FF8700"), // McLaren
        "14": ("ALO", "#229971"), "18": ("STR", "#229971"), // Aston Martin
        "31": ("OCO", "#FF87BC"), "10": ("GAS", "#FF87BC"), // Alpine
        "77": ("BOT", "#52E252"), "24": ("ZHO", "#52E252"), // Stake
        "22": ("TSU", "#5E8FAA"), "21": ("DEV", "#5E8FAA"), // AlphaTauri
        "23": ("ALB", "#6692FF"), "2": ("SAR", "#6692FF"), // Williams
        "20": ("MAG", "#B6BABD"), "27": ("HUL", "#B6BABD") // Haas
    ]
    
    private(set) var carAnnotations: [CarAnnotation] = []
    private(set) var trackPolyline: MKPolyline?
    private(set) var region = MKCoordinateRegion(
        center: CoordinateTransformer.albertParkCenter,
        latitudinalMeters: 5000,
        longitudinalMeters: 5000
    )
    
    private var updateTimer: Timer?
    private var positionIndex = 0
    
    init() {
        updateCarPositions()
        createTrackOutline()
        startSimulation()
    }
    
//    deinit {
//        updateTimer?.invalidate()
//    }
    
    private func updateCarPositions() {
        var annotations: [CarAnnotation] = []
        
        for (driverNumber, position) in testPositions {
            guard let info = driverInfo[driverNumber] else { continue }
            
            let gpsCoordinate = CoordinateTransformer.telemetryToGPS(
                telemetryX: position.x,
                telemetryY: position.y,
                circuitCenter: CoordinateTransformer.albertParkCenter,
                rotation: 0 // We'll adjust this based on track data
            )
            
            let annotation = CarAnnotation(
                id: driverNumber,
                coordinate: gpsCoordinate,
                driverNumber: driverNumber,
                driverTLA: info.tla,
                teamColor: Color(hex: info.teamColor) ?? .gray,
                isOnTrack: position.status == "OnTrack"
            )
            
            annotations.append(annotation)
        }
        
        carAnnotations = annotations
    }
    
    private func startSimulation() {
        // Simulate position updates
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                self.simulateMovement()
            }
        }
    }
    
    private func simulateMovement() {
        // Simple simulation: move cars along their trajectory
        var newAnnotations: [CarAnnotation] = []
        
        for annotation in carAnnotations {
            guard let position = testPositions[annotation.driverNumber] else { continue }
            
            // Add some random movement to simulate cars moving
            let deltaX = Double.random(in: -50...50)
            let deltaY = Double.random(in: -50...50)
            
            let newGPSCoordinate = CoordinateTransformer.telemetryToGPS(
                telemetryX: position.x + deltaX * Double(positionIndex),
                telemetryY: position.y + deltaY * Double(positionIndex),
                circuitCenter: CoordinateTransformer.albertParkCenter,
                rotation: 0
            )
            
            let newAnnotation = CarAnnotation(
                id: annotation.id,
                coordinate: newGPSCoordinate,
                driverNumber: annotation.driverNumber,
                driverTLA: annotation.driverTLA,
                teamColor: annotation.teamColor,
                isOnTrack: annotation.isOnTrack
            )
            
            newAnnotations.append(newAnnotation)
        }
        
        carAnnotations = newAnnotations
        positionIndex = (positionIndex + 1) % 10
    }
    
    private func createTrackOutline() {
        // Create a simplified track outline based on telemetry data bounds
        // This represents the approximate track layout
        let trackPoints: [(x: Double, y: Double)] = [
            // Start/finish straight
            (x: 2000, y: 0),
            (x: 1500, y: -1000),
            // Turn 1-2 complex
            (x: 1000, y: -1500),
            (x: 0, y: -2000),
            (x: -1000, y: -2200),
            // Back straight
            (x: -2000, y: -2000),
            (x: -3000, y: -1800),
            (x: -4000, y: -1500),
            // Turn 9-10
            (x: -5000, y: -1000),
            (x: -5500, y: 0),
            (x: -6000, y: 1000),
            // Lake section
            (x: -6500, y: 2000),
            (x: -7000, y: 3000),
            (x: -7500, y: 4000),
            (x: -8000, y: 5000),
            // Turn 11-12
            (x: -7500, y: 5500),
            (x: -6500, y: 5700),
            (x: -5500, y: 5500),
            // Back to start
            (x: -4000, y: 5000),
            (x: -2000, y: 4000),
            (x: 0, y: 3000),
            (x: 1000, y: 2000),
            (x: 2000, y: 1000),
            (x: 2000, y: 0) // Close the loop
        ]
        
        // Convert track points to GPS coordinates
        var coordinates: [CLLocationCoordinate2D] = []
        for point in trackPoints {
            let gpsCoord = CoordinateTransformer.telemetryToGPS(
                telemetryX: point.x,
                telemetryY: point.y,
                circuitCenter: CoordinateTransformer.albertParkCenter,
                rotation: 0
            )
            coordinates.append(gpsCoord)
        }
        
        // Create polyline from coordinates
        trackPolyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
}

// MARK: - Car Marker View

struct CarMarkerView: View {
    let annotation: CarAnnotation
    
    var body: some View {
        ZStack {
            // Shadow
            Circle()
                .fill(.black.opacity(0.3))
                .frame(width: 28, height: 28)
                .offset(x: 1, y: 1)
            
            // Team color background
            Circle()
                .fill(annotation.teamColor)
                .frame(width: 26, height: 26)
            
            // White border
            Circle()
                .stroke(.white, lineWidth: 2)
                .frame(width: 26, height: 26)
            
            // Driver number
            Text(annotation.driverNumber)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
        }
        .opacity(annotation.isOnTrack ? 1.0 : 0.5)
    }
}

// MARK: - MapKit Track Map Test View

struct MapKitTrackMapTestView: View {
    @State private var viewModel = MapKitTestViewModel()
    @State private var mapSelection: String?
    @State private var showSatellite = true
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CoordinateTransformer.albertParkCenter,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )
    )
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition, selection: $mapSelection) {
                // Track outline
                if let trackPolyline = viewModel.trackPolyline {
                    MapPolyline(trackPolyline)
                        .stroke(.red, lineWidth: 3)
                }
                
                // Car annotations
                ForEach(viewModel.carAnnotations) { annotation in
                    Annotation(
                        annotation.driverTLA,
                        coordinate: annotation.coordinate
                    ) {
                        CarMarkerView(annotation: annotation)
                            .onTapGesture {
                                mapSelection = annotation.id
                            }
                    }
                }
            }
            .mapStyle(showSatellite ? .hybrid(elevation: .realistic) : .standard)
            .mapControlVisibility(.automatic)
            .onAppear {
                // Set initial region
                mapSelection = nil
            }
            
            // Controls overlay
            VStack {
                HStack {
                    // Map style toggle
                    Button {
                        showSatellite.toggle()
                    } label: {
                        Label(
                            showSatellite ? "Satellite" : "Standard",
                            systemImage: showSatellite ? "map.fill" : "map"
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Spacer()
                    
                    // Info panel
                    if let selectedId = mapSelection,
                       let annotation = viewModel.carAnnotations.first(where: { $0.id == selectedId }) {
                        HStack {
                            Circle()
                                .fill(annotation.teamColor)
                                .frame(width: 20, height: 20)
                            Text("\(annotation.driverTLA) - #\(annotation.driverNumber)")
                                .font(.headline)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
                
                Spacer()
                
                // Legend and Debug Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Albert Park Circuit")
                        .font(.headline)
                    Text("Melbourne, Australia")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Divider()
                    
                    Text("F1 Car Positions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Tap a car for details")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    
                    Divider()
                    
                    // Debug info
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Debug Info")
                            .font(.caption.bold())
                        Text("Scale: \(CoordinateTransformer.telemetryScale, specifier: "%.2f")")
                            .font(.caption2.monospaced())
                        if let first = viewModel.carAnnotations.first {
                            Text("Car 1 GPS: \(first.coordinate.latitude, specifier: "%.6f"), \(first.coordinate.longitude, specifier: "%.6f")")
                                .font(.caption2.monospaced())
                        }
                    }
                    .foregroundStyle(.secondary)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
            }
        }
        .navigationTitle("MapKit Track Test")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MapKitTrackMapTestView()
    }
}

