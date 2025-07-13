//
//  MapKitTrackMapFixedView.swift
//  F1-Dash
//
//  Fixed MapKit view with corrected coordinate transformation
//

import SwiftUI
import MapKit
import F1DashModels
import CoreLocation

// MARK: - Fixed Coordinate Transformer

struct FixedCoordinateTransformer {
    // Albert Park circuit center (Melbourne, Australia)
    static let albertParkCenter = CLLocationCoordinate2D(latitude: -37.8497, longitude: 144.9680)
    
    // Earth radius in meters for lat/lon calculations
    static let earthRadiusMeters = 6_371_000.0
    
    // Transform telemetry coordinates to GPS coordinates
    static func telemetryToGPS(
        telemetryX: Double,
        telemetryY: Double,
        circuitCenter: CLLocationCoordinate2D,
        scale: Double = 0.3,  // Adjusted scale
        rotation: Double = 0
    ) -> CLLocationCoordinate2D {
        // Important: F1 telemetry often has Y-axis inverted (positive Y goes south)
        // and X-axis where positive goes east
        
        // Apply scale first
        let scaledX = telemetryX * scale
        let scaledY = -telemetryY * scale  // Invert Y axis
        
        // Apply rotation if needed
        let rotationRad = rotation * .pi / 180.0
        let rotatedX = scaledX * cos(rotationRad) - scaledY * sin(rotationRad)
        let rotatedY = scaledX * sin(rotationRad) + scaledY * cos(rotationRad)
        
        // Convert meters to degrees more accurately
        let latRadians = circuitCenter.latitude * .pi / 180.0
        
        // At the given latitude, calculate meters per degree
        let metersPerDegreeLat = 111_132.92 - 559.82 * cos(2 * latRadians) + 1.175 * cos(4 * latRadians)
        let metersPerDegreeLon = 111_412.84 * cos(latRadians) - 93.5 * cos(3 * latRadians)
        
        let deltaLat = rotatedY / metersPerDegreeLat
        let deltaLon = rotatedX / metersPerDegreeLon
        
        return CLLocationCoordinate2D(
            latitude: circuitCenter.latitude + deltaLat,
            longitude: circuitCenter.longitude + deltaLon
        )
    }
}

// MARK: - Fixed View Model

@MainActor
@Observable
final class MapKitFixedViewModel {
    // Albert Park actual track coordinates (approximate key points)
    private let albertParkKeyPoints: [(name: String, lat: Double, lon: Double)] = [
        ("Start/Finish", -37.849811, 144.968335),
        ("Turn 1", -37.850455, 144.969710),
        ("Turn 3", -37.851752, 144.970273),
        ("Turn 6", -37.853996, 144.969968),
        ("Turn 9", -37.854994, 144.968246),
        ("Turn 11", -37.854458, 144.966183),
        ("Turn 13", -37.852234, 144.965241),
        ("Turn 14", -37.850419, 144.966270),
        ("Turn 15", -37.849259, 144.967356)
    ]
    
    // Test position data with more realistic coordinates
    private let testPositions: [String: (x: Double, y: Double, status: String)] = [
        "44": (x: -437, y: -26, status: "OnTrack"),
        "18": (x: -820, y: 546, status: "OnTrack"),
        "27": (x: -642, y: 565, status: "OnTrack"),
        "22": (x: -326, y: -207, status: "OnTrack"),
        "81": (x: -152, y: -192, status: "OnTrack"),
        "4": (x: -583, y: 229, status: "OnTrack"),
        "23": (x: -643, y: 339, status: "OnTrack"),
        "24": (x: 67, y: -132, status: "OnTrack"),
        "20": (x: -447, y: -21, status: "OnTrack"),
        "11": (x: -668, y: 567, status: "OnTrack"),
        "10": (x: -273, y: -223, status: "OnTrack"),
        "31": (x: -616, y: 297, status: "OnTrack"),
        "55": (x: -731, y: 566, status: "OnTrack"),
        "14": (x: -807, y: 508, status: "OnTrack"),
        "1": (x: -136, y: 496, status: "OnTrack"),
        "63": (x: -508, y: 77, status: "OnTrack"),
        "2": (x: -99, y: -177, status: "OnTrack"),
        "21": (x: -225, y: -212, status: "OnTrack"),
        "77": (x: 234, y: -87, status: "OnTrack"),
        "16": (x: -602, y: 271, status: "OnTrack")
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
    
    private(set) var carAnnotations: [CarAnnotation] = []
    private(set) var trackPolyline: MKPolyline?
    private(set) var keyPointAnnotations: [MKPointAnnotation] = []
    private(set) var currentScale: Double = 0.3
    private(set) var currentRotation: Double = 0
    
    private var updateTimer: Timer?
    private var trackProgress: [String: Double] = [:]  // Track progress for each car (0-1)
    
    init() {
        createKeyPointAnnotations()
        createRealisticTrackOutline()
        updateCarPositions()
        startRealisticSimulation()
    }
    
    func updateScale(_ scale: Double) {
        currentScale = scale
        updateCarPositions()
        createRealisticTrackOutline()
    }
    
    func updateRotation(_ rotation: Double) {
        currentRotation = rotation
        updateCarPositions()
        createRealisticTrackOutline()
    }
    
    private func createKeyPointAnnotations() {
        // Define Albert Park key points
        let albertParkKeyPoints: [(name: String, lat: Double, lon: Double)] = [
            ("Start/Finish", -37.849811, 144.968335),
            ("Turn 1", -37.850455, 144.969710),
            ("Turn 3", -37.851752, 144.970273),
            ("Turn 6", -37.853996, 144.969968),
            ("Turn 9", -37.854994, 144.968246),
            ("Turn 11", -37.854458, 144.966183),
            ("Turn 13", -37.852234, 144.965241),
            ("Turn 14", -37.850419, 144.966270),
            ("Turn 15", -37.849259, 144.967356)
        ]
        
        keyPointAnnotations = albertParkKeyPoints.map { point in
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: point.lat, longitude: point.lon)
            annotation.title = point.name
            return annotation
        }
    }
    
    private func createRealisticTrackOutline() {
        // Create a more realistic Albert Park outline
        let trackPath: [(x: Double, y: Double)] = [
            // Start/Finish straight
            (0, 0), (100, 0), (200, 0),
            // Turn 1-2 complex
            (250, -50), (280, -100), (300, -150),
            // Turn 3
            (320, -200), (340, -250), (360, -300),
            // Straight to Turn 6
            (380, -400), (400, -500), (420, -600),
            // Turn 6-7-8
            (440, -650), (460, -680), (480, -700),
            // Turn 9-10
            (500, -720), (520, -740), (540, -750),
            // Back straight
            (560, -740), (580, -720), (600, -700),
            // Turn 11-12
            (620, -680), (640, -650), (660, -600),
            // Turn 13
            (680, -550), (700, -500), (720, -450),
            // Turn 14
            (740, -400), (760, -350), (780, -300),
            // Turn 15-16
            (800, -250), (820, -200), (840, -150),
            // Back to start
            (860, -100), (880, -50), (900, 0),
            // Complete the loop
            (800, 0), (600, 0), (400, 0), (200, 0), (0, 0)
        ]
        
        var coordinates: [CLLocationCoordinate2D] = []
        for point in trackPath {
            let gpsCoord = FixedCoordinateTransformer.telemetryToGPS(
                telemetryX: point.x - 450,  // Center the track
                telemetryY: point.y + 375,
                circuitCenter: FixedCoordinateTransformer.albertParkCenter,
                scale: currentScale,
                rotation: currentRotation
            )
            coordinates.append(gpsCoord)
        }
        
        trackPolyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
    
    private func updateCarPositions() {
        var annotations: [CarAnnotation] = []
        
        for (driverNumber, position) in testPositions {
            guard let info = driverInfo[driverNumber] else { continue }
            
            let gpsCoordinate = FixedCoordinateTransformer.telemetryToGPS(
                telemetryX: position.x,
                telemetryY: position.y,
                circuitCenter: FixedCoordinateTransformer.albertParkCenter,
                scale: currentScale,
                rotation: currentRotation
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
    
    private func startRealisticSimulation() {
        // Initialize track progress for each car
        for (driverNumber, _) in testPositions {
            trackProgress[driverNumber] = Double.random(in: 0...1)
        }
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            Task { @MainActor in
                self.simulateRealisticMovement()
            }
        }
    }
    
    private func simulateRealisticMovement() {
        var newAnnotations: [CarAnnotation] = []
        
        for annotation in carAnnotations {
            guard let info = driverInfo[annotation.driverNumber],
                  var progress = trackProgress[annotation.driverNumber] else { continue }
            
            // Move cars along the track
            progress += Double.random(in: 0.005...0.015)  // Different speeds
            if progress > 1.0 { progress -= 1.0 }  // Loop around
            
            trackProgress[annotation.driverNumber] = progress
            
            // Calculate position based on progress around track
            let angle = progress * 2 * .pi
            let radiusX = 400 + sin(angle * 3) * 100  // Varying radius for realistic track shape
            let radiusY = 300 + cos(angle * 2) * 80
            
            let x = cos(angle) * radiusX
            let y = sin(angle) * radiusY
            
            let gpsCoordinate = FixedCoordinateTransformer.telemetryToGPS(
                telemetryX: x,
                telemetryY: y,
                circuitCenter: FixedCoordinateTransformer.albertParkCenter,
                scale: currentScale,
                rotation: currentRotation
            )
            
            let newAnnotation = CarAnnotation(
                id: annotation.id,
                coordinate: gpsCoordinate,
                driverNumber: annotation.driverNumber,
                driverTLA: annotation.driverTLA,
                teamColor: annotation.teamColor,
                isOnTrack: annotation.isOnTrack
            )
            
            newAnnotations.append(newAnnotation)
        }
        
        carAnnotations = newAnnotations
    }
}

// MARK: - Fixed MapKit View

struct MapKitTrackMapFixedView: View {
    @State private var viewModel = MapKitFixedViewModel()
    @State private var mapSelection: String?
    @State private var showSatellite = true
    @State private var showKeyPoints = false
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: FixedCoordinateTransformer.albertParkCenter,
            latitudinalMeters: 4000,
            longitudinalMeters: 4000
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
                
                // Key points (for debugging)
                if showKeyPoints {
                    ForEach(viewModel.keyPointAnnotations, id: \.self) { annotation in
                        Marker(annotation.title ?? "", coordinate: annotation.coordinate)
                            .tint(.yellow)
                    }
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
                // Top controls
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
                    
                    // Show key points toggle
                    Button {
                        showKeyPoints.toggle()
                    } label: {
                        Label(
                            "Key Points",
                            systemImage: showKeyPoints ? "mappin.circle.fill" : "mappin.circle"
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
                
                // Debug controls
                VStack(alignment: .leading, spacing: 12) {
                    Text("Debug Controls")
                        .font(.headline)
                    
                    // Scale slider
                    VStack(alignment: .leading) {
                        Text("Scale: \(viewModel.currentScale, specifier: "%.2f")")
                            .font(.caption)
                        Slider(value: Binding(
                            get: { viewModel.currentScale },
                            set: { newValue in viewModel.updateScale(newValue) }
                        ), in: 0.1...1.0)
                    }
                    
                    // Rotation slider
                    VStack(alignment: .leading) {
                        Text("Rotation: \(Int(viewModel.currentRotation))°")
                            .font(.caption)
                        Slider(value: Binding(
                            get: { viewModel.currentRotation },
                            set: { newValue in viewModel.updateRotation(newValue) }
                        ), in: -180...180)
                    }
                    
                    Divider()
                    
                    // Info
                    Text("Albert Park Circuit")
                        .font(.caption.bold())
                    Text("Cars should move clockwise around track")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
            }
        }
        .navigationTitle("Fixed MapKit Track")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MapKitTrackMapFixedView()
    }
}