//
//  MapKitTrackMapRealDataView.swift
//  F1-Dash
//
//  Enhanced MapKit view with real track data integration
//

import SwiftUI
import MapKit
import F1DashModels
import CoreLocation

// MARK: - Enhanced Coordinate Transformer

struct EnhancedCoordinateTransformer {
    // Transform telemetry to GPS using track bounds
    static func telemetryToGPS(
        telemetryX: Double,
        telemetryY: Double,
        trackMap: TrackMap?,
        circuitCenter: CLLocationCoordinate2D
    ) -> CLLocationCoordinate2D {
        guard let map = trackMap else {
            // Fallback to simple transformation
            return simpleTransform(x: telemetryX, y: telemetryY, center: circuitCenter)
        }
        
        // Get track bounds from the map data
        let xMin = map.x.min() ?? -10000
        let xMax = map.x.max() ?? 10000
        let yMin = map.y.min() ?? -10000
        let yMax = map.y.max() ?? 10000
        
        // Track dimensions in telemetry units
        let trackWidth = xMax - xMin
        let trackHeight = yMax - yMin
        
        // Estimate real-world track size (Albert Park is approximately 5.3km long)
        // This gives us a rough scale factor
        let estimatedTrackLengthMeters = 5300.0
        let telemetryDiagonal = sqrt(trackWidth * trackWidth + trackHeight * trackHeight)
        let scaleFactor = estimatedTrackLengthMeters / telemetryDiagonal
        
        // Apply rotation from track map
        let rotation = map.rotation + 90 // 90 degree fix as seen in other views
        let rotationRad = rotation * .pi / 180.0
        
        // Center the coordinates
        let centeredX = telemetryX - (xMin + xMax) / 2
        let centeredY = telemetryY - (yMin + yMax) / 2
        
        // Apply rotation
        let rotatedX = centeredX * cos(rotationRad) - centeredY * sin(rotationRad)
        let rotatedY = centeredX * sin(rotationRad) + centeredY * cos(rotationRad)
        
        // Scale to meters
        let metersX = rotatedX * scaleFactor
        let metersY = rotatedY * scaleFactor
        
        // Convert to GPS offset
        let metersPerDegreeLat = 111_000.0
        let metersPerDegreeLon = 93_000.0 // At Melbourne latitude
        
        let deltaLat = metersY / metersPerDegreeLat
        let deltaLon = metersX / metersPerDegreeLon
        
        return CLLocationCoordinate2D(
            latitude: circuitCenter.latitude + deltaLat,
            longitude: circuitCenter.longitude + deltaLon
        )
    }
    
    private static func simpleTransform(x: Double, y: Double, center: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let scale = 0.3
        let metersPerDegreeLat = 111_000.0
        let metersPerDegreeLon = 93_000.0
        
        let deltaLat = (y * scale) / metersPerDegreeLat
        let deltaLon = (x * scale) / metersPerDegreeLon
        
        return CLLocationCoordinate2D(
            latitude: center.latitude + deltaLat,
            longitude: center.longitude + deltaLon
        )
    }
}

// MARK: - Real Data View Model

@MainActor
@Observable
final class MapKitRealDataViewModel {
    // Circuit locations with their keys
    let circuitData: [(name: String, key: Int, center: CLLocationCoordinate2D)] = [
        ("Albert Park", 145, CLLocationCoordinate2D(latitude: -37.8497, longitude: 144.9680)),
        ("Silverstone", 144, CLLocationCoordinate2D(latitude: 52.0786, longitude: -1.0169)),
        ("Monaco", 142, CLLocationCoordinate2D(latitude: 43.7347, longitude: 7.4206)),
        ("Spa", 139, CLLocationCoordinate2D(latitude: 50.4372, longitude: 5.9714)),
        ("Austin", 154, CLLocationCoordinate2D(latitude: 30.1328, longitude: -97.6411))
    ]
    
    // Selected circuit
    private(set) var selectedCircuitIndex = 0
    var selectedCircuit: (name: String, key: Int, center: CLLocationCoordinate2D) {
        circuitData[selectedCircuitIndex]
    }
    
    // Track data
    private(set) var trackMap: TrackMap?
    private(set) var trackPolyline: MKPolyline?
    private(set) var carAnnotations: [CarAnnotation] = []
    private(set) var isLoading = false
    private(set) var error: String?
    
    // Map service
    private let mapService = MapService()
    
    // Test position data (same as before)
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
    
    private let driverInfo: [String: (tla: String, teamColor: String)] = [
        "1": ("VER", "#1B2A48"), "11": ("PER", "#1B2A48"),
        "44": ("HAM", "#00A19B"), "63": ("RUS", "#00A19B"),
        "16": ("LEC", "#DC0000"), "55": ("SAI", "#DC0000"),
        "4": ("NOR", "#FF8700"), "81": ("PIA", "#FF8700"),
        "14": ("ALO", "#229971"), "18": ("STR", "#229971"),
        "31": ("OCO", "#FF87BC"), "10": ("GAS", "#FF87BC"),
        "77": ("BOT", "#52E252"), "24": ("ZHO", "#52E252"),
        "22": ("TSU", "#5E8FAA"), "21": ("DEV", "#5E8FAA"),
        "23": ("ALB", "#6692FF"), "2": ("SAR", "#6692FF"),
        "20": ("MAG", "#B6BABD"), "27": ("HUL", "#B6BABD")
    ]
    
    init() {
        Task {
            await loadTrackData()
        }
    }
    
    func selectCircuit(index: Int) {
        selectedCircuitIndex = index
        Task {
            await loadTrackData()
        }
    }
    
    @MainActor
    private func loadTrackData() async {
        isLoading = true
        error = nil
        
        do {
            // Try to fetch real track data
            let map = try await mapService.fetchMap(for: selectedCircuit.key)
            self.trackMap = map
            
            // Create track polyline from map data
            createTrackPolyline(from: map)
            
            // Update car positions
            updateCarPositions()
            
        } catch {
            print("Failed to load track data: \(error)")
            self.error = "Failed to load track data"
            
            // Create fallback track outline
            createFallbackTrackOutline()
            updateCarPositions()
        }
        
        isLoading = false
    }
    
    private func createTrackPolyline(from map: TrackMap) {
        // Apply rotation to track points
        let rotation = map.rotation + 90
        let rotationRad = rotation * .pi / 180.0
        
        let centerX = (map.x.max()! + map.x.min()!) / 2
        let centerY = (map.y.max()! + map.y.min()!) / 2
        
        var coordinates: [CLLocationCoordinate2D] = []
        
        for i in 0..<map.x.count {
            // Apply rotation
            let x = map.x[i] - centerX
            let y = map.y[i] - centerY
            
            let rotatedX = x * cos(rotationRad) - y * sin(rotationRad)
            let rotatedY = x * sin(rotationRad) + y * cos(rotationRad)
            
            // Convert to GPS
            let gpsCoord = EnhancedCoordinateTransformer.telemetryToGPS(
                telemetryX: rotatedX + centerX,
                telemetryY: rotatedY + centerY,
                trackMap: map,
                circuitCenter: selectedCircuit.center
            )
            
            coordinates.append(gpsCoord)
        }
        
        trackPolyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
    
    private func createFallbackTrackOutline() {
        // Same as before but adjusted for selected circuit
        let trackPoints: [(x: Double, y: Double)] = [
            (x: 2000, y: 0), (x: 1500, y: -1000),
            (x: 1000, y: -1500), (x: 0, y: -2000),
            (x: -1000, y: -2200), (x: -2000, y: -2000),
            (x: -3000, y: -1800), (x: -4000, y: -1500),
            (x: -5000, y: -1000), (x: -5500, y: 0),
            (x: -6000, y: 1000), (x: -6500, y: 2000),
            (x: -7000, y: 3000), (x: -7500, y: 4000),
            (x: -8000, y: 5000), (x: -7500, y: 5500),
            (x: -6500, y: 5700), (x: -5500, y: 5500),
            (x: -4000, y: 5000), (x: -2000, y: 4000),
            (x: 0, y: 3000), (x: 1000, y: 2000),
            (x: 2000, y: 1000), (x: 2000, y: 0)
        ]
        
        var coordinates: [CLLocationCoordinate2D] = []
        for point in trackPoints {
            let gpsCoord = EnhancedCoordinateTransformer.telemetryToGPS(
                telemetryX: point.x,
                telemetryY: point.y,
                trackMap: nil,
                circuitCenter: selectedCircuit.center
            )
            coordinates.append(gpsCoord)
        }
        
        trackPolyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
    
    private func updateCarPositions() {
        var annotations: [CarAnnotation] = []
        
        for (driverNumber, position) in testPositions {
            guard let info = driverInfo[driverNumber] else { continue }
            
            let gpsCoordinate = EnhancedCoordinateTransformer.telemetryToGPS(
                telemetryX: position.x,
                telemetryY: position.y,
                trackMap: trackMap,
                circuitCenter: selectedCircuit.center
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
}

// MARK: - MapKit Track Map Real Data View

struct MapKitTrackMapRealDataView: View {
    @State private var viewModel = MapKitRealDataViewModel()
    @State private var mapSelection: String?
    @State private var showSatellite = true
    @State private var cameraPosition: MapCameraPosition
    
    init() {
        let initialCenter = CLLocationCoordinate2D(latitude: -37.8497, longitude: 144.9680)
        _cameraPosition = State(initialValue: MapCameraPosition.region(
            MKCoordinateRegion(
                center: initialCenter,
                latitudinalMeters: 8000,
                longitudinalMeters: 8000
            )
        ))
    }
    
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
            
            // Controls overlay
            VStack {
                HStack {
                    // Circuit selector
                    Menu {
                        ForEach(0..<viewModel.circuitData.count, id: \.self) { index in
                            Button(viewModel.circuitData[index].name) {
                                viewModel.selectCircuit(index: index)
                                // Update camera position
                                cameraPosition = MapCameraPosition.region(
                                    MKCoordinateRegion(
                                        center: viewModel.circuitData[index].center,
                                        latitudinalMeters: 8000,
                                        longitudinalMeters: 8000
                                    )
                                )
                            }
                        }
                    } label: {
                        Label(viewModel.selectedCircuit.name, systemImage: "location.circle")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
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
                }
                .padding()
                
                Spacer()
                
                // Info panel
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.selectedCircuit.name)
                        .font(.headline)
                    
                    if viewModel.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading track data...")
                                .font(.caption)
                        }
                    } else if let error = viewModel.error {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    } else if viewModel.trackMap != nil {
                        Text("Real track data loaded")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                    
                    Divider()
                    
                    if let trackMap = viewModel.trackMap {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Track: \(trackMap.circuitName)")
                                .font(.caption2)
                            Text("Location: \(trackMap.location)")
                                .font(.caption2)
                            Text("Rotation: \(Int(trackMap.rotation))°")
                                .font(.caption2)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
            }
        }
        .navigationTitle("MapKit with Real Track Data")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MapKitTrackMapRealDataView()
    }
}
