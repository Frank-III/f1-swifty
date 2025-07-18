import SwiftUI
import EventSource
import F1DashModels
import Observation

// MARK: - Test Track Map View Model (mimics OptimizedTrackMapViewModel)

@MainActor
@Observable
final class TestTrackMapViewModel {
    // SSE connection
    private var eventSource: EventSource?
    private let mapService = MapService()
    
    // Raw data storage
    private var dataState: [String: Any] = [:]
    var drivers: [String: (tla: String, color: String)] = [:]
    var rawPositions: [String: (x: Double, y: Double)] = [:]
    
    // Track data
    private(set) var trackMap: TrackMap?
    private(set) var sectors: [MapSector] = []
    private(set) var rotatedPoints: [TrackPosition] = []
    private(set) var rotatedCorners: [RotatedCorner] = []
    private(set) var finishLinePosition: TrackPosition?
    private(set) var loadingError: String?
    private(set) var hasMapData: Bool = false
    
    // Track bounds (after rotation)
    private(set) var minX: Double = 0
    private(set) var maxX: Double = 1000
    private(set) var minY: Double = 0
    private(set) var maxY: Double = 1000
    private(set) var centerX: Double = 500
    private(set) var centerY: Double = 500
    
    // Connection status
    private(set) var isConnected = false
    private(set) var lastUpdateTimestamp = ""
    private(set) var updateCount = 0
    
    // Constants
    private let space: Double = 1000
    private let rotationFix: Double = 90
    private var circuitKey: Int?
    
    init() {
        // Don't load track map immediately - wait for circuit key from session
    }
    
    func connect() {
        print("🔵 TEST: Connecting to SSE...")
        eventSource = EventSource(url: URL(string: "http://127.0.0.1:3000/v1/live/sse")!)
        
        eventSource?.onOpen = {
            Task { @MainActor in
                self.isConnected = true
                print("✅ TEST: SSE Connected")
            }
        }
        
        eventSource?.onMessage = { event in
            Task { @MainActor in
                // Don't process messages if we're disconnected
                guard self.isConnected else { 
                    print("⚠️ TEST: Ignoring message - not connected")
                    return 
                }
                
                guard let data = event.data.data(using: .utf8),
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
                
                self.processSSEData(json)
            }
        }
        
        eventSource?.onError = { error in
            Task { @MainActor in
                self.isConnected = false
                print("❌ TEST: SSE Error: \(String(describing: error))")
            }
        }
    }
    
    func disconnect() {
        print("🔴 TEST: Disconnecting SSE...")
        isConnected = false  // Set this first to stop message processing
        
        Task {
            await eventSource?.close()
            await MainActor.run {
                eventSource = nil
                
                // Clear positions but keep drivers and track data
                rawPositions.removeAll()
                lastUpdateTimestamp = ""
                print("🧹 TEST: Cleared positions after disconnect (kept drivers and track)")
            }
        }
    }
    
    func loadTrackMap() {
        Task {
            guard let circuitKey = circuitKey else {
                print("🔴 TEST: No circuit key available yet")
                return
            }
            
            print("🟢 TEST: Loading track map for circuit: \(circuitKey)")
            do {
                let map = try await mapService.fetchMap(for: circuitKey)
                await MainActor.run {
                    self.trackMap = map
                    self.processMapData()
                    self.hasMapData = true
                    print("🟢 TEST: Track map loaded successfully, hasMapData: \(self.hasMapData)")
                }
            } catch {
                print("🔴 TEST: Failed to load track map: \(error)")
                self.loadingError = "Failed to load track map"
            }
        }
    }
    
    private func processMapData() {
        guard let map = trackMap else { return }
        
        // Calculate center using the actual min/max values (not range)
        let xValues = map.x
        let yValues = map.y
        
        let originalCenterX = (xValues.max()! + xValues.min()!) / 2
        let originalCenterY = (yValues.max()! + yValues.min()!) / 2
        
        self.centerX = originalCenterX
        self.centerY = originalCenterY
        
        // Apply rotation
        let fixedRotation = map.rotation + rotationFix
        
        // Rotate track points
        rotatedPoints = zip(xValues, yValues).map { x, y in
            TrackMap.rotate(
                x: x, y: y,
                angle: fixedRotation,
                centerX: originalCenterX,
                centerY: originalCenterY
            )
        }
        
        // Rotate corners
        rotatedCorners = map.corners.map { corner in
            let rotatedPos = TrackMap.rotate(
                x: corner.trackPosition.x,
                y: corner.trackPosition.y,
                angle: fixedRotation,
                centerX: originalCenterX,
                centerY: originalCenterY
            )
            
            let labelOffset = 540.0
            let labelX = corner.trackPosition.x + labelOffset * cos(TrackMap.radians(from: corner.angle))
            let labelY = corner.trackPosition.y + labelOffset * sin(TrackMap.radians(from: corner.angle))
            
            let rotatedLabelPos = TrackMap.rotate(
                x: labelX, y: labelY,
                angle: fixedRotation,
                centerX: originalCenterX,
                centerY: originalCenterY
            )
            
            return RotatedCorner(
                number: corner.number,
                position: rotatedPos,
                labelPosition: rotatedLabelPos
            )
        }
        
        // Create sectors
        sectors = createRotatedSectors(from: map, rotation: fixedRotation)
        
        // Set finish line
        finishLinePosition = rotatedPoints.first
        
        // Update bounds
        updateTrackBounds()
        
        print("🔍 TEST: Track processing complete:")
        print("  Original X range: \(xValues.min()!)...\(xValues.max()!)")
        print("  Original Y range: \(yValues.min()!)...\(yValues.max()!)")
        print("  Track rotation from API: \(map.rotation)°")
        print("  Fixed rotation: \(fixedRotation)°")
        print("  Center (range-based): (\(centerX), \(centerY))")
        print("  Final bounds: X(\(minX)...\(maxX)) Y(\(minY)...\(maxY))")
    }
    
    private func createRotatedSectors(from map: TrackMap, rotation: Double) -> [MapSector] {
        var sectors: [MapSector] = []
        
        for i in 0..<map.marshalSectors.count {
            let sectorStart = TrackMap.rotate(
                x: map.marshalSectors[i].trackPosition.x,
                y: map.marshalSectors[i].trackPosition.y,
                angle: rotation,
                centerX: centerX,
                centerY: centerY
            )
            
            let nextIndex = (i + 1) % map.marshalSectors.count
            let sectorEnd = TrackMap.rotate(
                x: map.marshalSectors[nextIndex].trackPosition.x,
                y: map.marshalSectors[nextIndex].trackPosition.y,
                angle: rotation,
                centerX: centerX,
                centerY: centerY
            )
            
            // Find points for this sector
            let startIndex = TrackMap.findClosestPointIndex(to: sectorStart, in: rotatedPoints)
            let endIndex = TrackMap.findClosestPointIndex(to: sectorEnd, in: rotatedPoints)
            
            var sectorPoints: [TrackPosition] = []
            if startIndex <= endIndex {
                sectorPoints = Array(rotatedPoints[startIndex...endIndex])
            } else {
                sectorPoints = Array(rotatedPoints[startIndex...]) + Array(rotatedPoints[...endIndex])
            }
            
            sectors.append(
                MapSector(
                    number: i + 1,
                    start: sectorStart,
                    end: sectorEnd,
                    points: sectorPoints
                ))
        }
        
        return sectors
    }
    
    private func updateTrackBounds() {
        guard !rotatedPoints.isEmpty else { return }
        
        // Get all coordinates that should be visible
        var allXValues = rotatedPoints.map { $0.x }
        var allYValues = rotatedPoints.map { $0.y }
        
        // Include driver positions if available
        if !rawPositions.isEmpty, let trackMap = trackMap {
            for (_, pos) in rawPositions {
                // Rotate driver positions with same parameters as track
                let rotatedPos = TrackMap.rotate(
                    x: pos.x, y: pos.y,
                    angle: trackMap.rotation + rotationFix,
                    centerX: centerX,
                    centerY: centerY
                )
                allXValues.append(rotatedPos.x)
                allYValues.append(rotatedPos.y)
            }
        }
        
        // Calculate bounds to include both track and drivers
        let minX = allXValues.min()! - space
        let maxX = allXValues.max()! + space
        let minY = allYValues.min()! - space
        let maxY = allYValues.max()! + space
        
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
        
        print("🔍 TEST: Updated bounds - X: [\(Int(minX))...\(Int(maxX))], Y: [\(Int(minY))...\(Int(maxY))]")
    }
    
    func normalizedPosition(for position: TrackPosition, in size: CGSize) -> CGPoint {
        let normalizedX = (position.x - minX) / (maxX - minX)
        let normalizedY = 1.0 - (position.y - minY) / (maxY - minY)  // Flip Y axis
        
        return CGPoint(
            x: normalizedX * size.width,
            y: normalizedY * size.height
        )
    }
    
    private func processSSEData(_ data: [String: Any]) {
        // Extract session info to get circuit key
        if let sessionInfo = data["sessionInfo"] as? [String: Any],
           let meeting = sessionInfo["meeting"] as? [String: Any],
           let circuit = meeting["circuit"] as? [String: Any],
           let key = circuit["key"] as? Int {
            if self.circuitKey != key {
                print("📍 TEST: Found circuit key: \(key)")
                self.circuitKey = key
                loadTrackMap()
            }
        }
        
        // Extract driver list
        if let driverDict = data["driverList"] as? [String: [String: Any]] {
            for (racingNumber, driverData) in driverDict {
                if let tla = driverData["tla"] as? String,
                   let teamColour = driverData["teamColour"] as? String {
                    drivers[racingNumber] = (tla, teamColour)
                }
            }
            print("📋 TEST: Total drivers: \(drivers.count)")
        }
        
        // Extract positions
        if let posData = data["positionData"] as? [String: Any] {
            let posArray: [[String: Any]]?
            if let nested = posData["positionData"] as? [[String: Any]] {
                posArray = nested
            } else {
                posArray = nil
            }
            
            if let posArray = posArray,
               let lastPos = posArray.last,
               let timestamp = lastPos["timestamp"] as? String,
               let entries = lastPos["entries"] as? [String: [String: Any]] {
                
                // Only update if timestamp changed
                if timestamp != lastUpdateTimestamp {
                    print("🔵 TEST: New position data with timestamp: \(timestamp)")
                    lastUpdateTimestamp = timestamp
                    updateCount += 1
                    
                    // Process positions
                    rawPositions.removeAll()
                    for (racingNumber, posData) in entries {
                        if let x = extractCoordinate(from: posData["x"]),
                           let y = extractCoordinate(from: posData["y"]),
                           x != 0 || y != 0 {
                            rawPositions[racingNumber] = (x, y)
                        }
                    }
                    
                    print("🟣 TEST: Found \(rawPositions.count) valid positions")
                    
                    // Update bounds to include driver positions
                    if hasMapData {
                        updateTrackBounds()
                    }
                }
            }
        }
    }
    
    private func extractCoordinate(from value: Any?) -> Double? {
        if let double = value as? Double { return double }
        if let int = value as? Int { return Double(int) }
        if let bool = value as? Bool { return 0.0 }
        if let string = value as? String, let double = Double(string) { return double }
        return nil
    }
    
    // Computed property for driver positions (mimics OptimizedTrackMapViewModel)
    var driverPositions: [(racingNumber: String, position: (x: Double, y: Double))] {
        rawPositions.map { (key, value) in (key, value) }
            .sorted { $0.racingNumber < $1.racingNumber }
    }
}

// MARK: - Test view that mimics OptimizedTrackMapView structure

struct TestIsolatedTrackMap: View {
    @State private var trackViewModel: TestTrackMapViewModel?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Circle()
                    .fill(trackViewModel?.isConnected ?? false ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                
                Text(trackViewModel?.isConnected ?? false ? "Connected" : "Disconnected")
                    .font(.headline)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(trackViewModel?.drivers.count ?? 0) drivers")
                    Text("\(trackViewModel?.rawPositions.count ?? 0) positions")
                    Text("Updates: \(trackViewModel?.updateCount ?? 0)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Button("Test Disconnect/Reconnect") {
                    testDisconnectReconnect()
                }
                .buttonStyle(.bordered)
                
                Button(trackViewModel?.isConnected ?? false ? "Disconnect" : "Connect") {
                    if trackViewModel?.isConnected ?? false {
                        trackViewModel?.disconnect()
                    } else {
                        trackViewModel?.connect()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            // Track Map (mimics OptimizedTrackMapView structure)
            GeometryReader { geometry in
                ZStack {
                    // Background gradient (like real app)
                    LinearGradient(
                        colors: [
                            Color(red: 0.05, green: 0.05, blue: 0.1),
                            Color(red: 0.02, green: 0.02, blue: 0.05),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Grid pattern overlay (like real app)
                    Canvas { context, size in
                        let gridSize: CGFloat = 50
                        let gridColor = Color.white.opacity(0.03)
                        
                        for x in stride(from: 0, through: size.width, by: gridSize) {
                            var path = Path()
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: size.height))
                            context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
                        }
                        
                        for y in stride(from: 0, through: size.height, by: gridSize) {
                            var path = Path()
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: size.width, y: y))
                            context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
                        }
                    }
                    
                    if let viewModel = trackViewModel, viewModel.hasMapData {
                        // Static track layer with real track data
                        TestStaticTrackLayer(
                            viewModel: viewModel,
                            size: geometry.size
                        )
                        
                        // Dynamic driver layer
                        TestDynamicDriverLayer(
                            viewModel: viewModel,
                            size: geometry.size
                        )
                        
                        // Debug overlay to show raw driver positions
                        if viewModel.rawPositions.count > 0 {
                            Canvas { context, size in
                                // Show debug dots for raw driver positions
                                for (racingNumber, rawPos) in viewModel.rawPositions {
                                    if let trackMap = viewModel.trackMap {
                                        // Show where driver actually is in coordinate space
                                        let rotatedPos = TrackMap.rotate(
                                            x: rawPos.x, y: rawPos.y,
                                            angle: trackMap.rotation + 90,
                                            centerX: viewModel.centerX,
                                            centerY: viewModel.centerY
                                        )
                                        let normalizedPos = viewModel.normalizedPosition(for: rotatedPos, in: size)
                                        
                                        // Draw a small debug circle
                                        let debugRect = CGRect(
                                            x: normalizedPos.x - 2,
                                            y: normalizedPos.y - 2,
                                            width: 4,
                                            height: 4
                                        )
                                        context.fill(Path(ellipseIn: debugRect), with: .color(.cyan))
                                    }
                                }
                                
                                // Show info
                                context.draw(
                                    Text("Debug: \(viewModel.rawPositions.count) drivers")
                                        .font(.caption)
                                        .foregroundColor(.cyan),
                                    at: CGPoint(x: 60, y: 20)
                                )
                            }
                        }
                    } else {
                        // Loading state
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                            
                            Text(trackViewModel?.loadingError ?? "Loading track map...")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            if trackViewModel?.loadingError != nil {
                                Button("Retry") {
                                    trackViewModel?.loadTrackMap()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            
            // Debug info
            VStack(alignment: .leading, spacing: 4) {
                Text("Debug Info:")
                    .font(.caption.bold())
                
                if let viewModel = trackViewModel {
                    Text("Connection: \(viewModel.isConnected ? "✅ Connected" : "❌ Disconnected")")
                        .font(.caption.monospaced())
                        .foregroundColor(viewModel.isConnected ? .green : .red)
                    Text("Last timestamp: \(String(viewModel.lastUpdateTimestamp.suffix(10)))")
                        .font(.caption.monospaced())
                    Text("Drivers: \(viewModel.drivers.count) | Positions: \(viewModel.rawPositions.count)")
                        .font(.caption.monospaced())
                    
                    if viewModel.hasMapData {
                        Text("Track Info:")
                            .font(.caption.bold())
                            .padding(.top, 4)
                        Text("Circuit: Australia GP (key: 23)")
                            .font(.caption.monospaced())
                        Text("Rotation: \(viewModel.trackMap?.rotation ?? 0)° + 90° = \(Int((viewModel.trackMap?.rotation ?? 0) + 90))°")
                            .font(.caption.monospaced())
                        Text("Track bounds: X[\(Int(viewModel.minX))...\(Int(viewModel.maxX))]")
                            .font(.caption.monospaced())
                        Text("Track bounds: Y[\(Int(viewModel.minY))...\(Int(viewModel.maxY))]")
                            .font(.caption.monospaced())
                        Text("Center: (\(Int(viewModel.centerX)), \(Int(viewModel.centerY)))")
                            .font(.caption.monospaced())
                    }
                    
                    if !viewModel.rawPositions.isEmpty {
                        Text("Driver Position Ranges:")
                            .font(.caption.bold())
                            .padding(.top, 4)
                        let xRange = viewModel.rawPositions.values.map { $0.x }
                        let yRange = viewModel.rawPositions.values.map { $0.y }
                        Text("Raw X: [\(Int(xRange.min() ?? 0))...\(Int(xRange.max() ?? 0))]")
                            .font(.caption.monospaced())
                        Text("Raw Y: [\(Int(yRange.min() ?? 0))...\(Int(yRange.max() ?? 0))]")
                            .font(.caption.monospaced())
                        
                        if let trackMap = viewModel.trackMap {
                            // Show coordinate scales
                            let trackXMin = trackMap.x.min() ?? 0
                            let trackXMax = trackMap.x.max() ?? 0
                            let trackYMin = trackMap.y.min() ?? 0
                            let trackYMax = trackMap.y.max() ?? 0
                            
                            Text("Track vs Driver Coordinates:")
                                .font(.caption.bold())
                                .padding(.top, 2)
                            Text("Track X: [\(Int(trackXMin))...\(Int(trackXMax))] (range: \(Int(trackXMax - trackXMin)))")
                                .font(.caption.monospaced())
                            Text("Track Y: [\(Int(trackYMin))...\(Int(trackYMax))] (range: \(Int(trackYMax - trackYMin)))")
                                .font(.caption.monospaced())
                            
                            // Check if we need coordinate transformation
                            let driverXRange = (xRange.max() ?? 0) - (xRange.min() ?? 0)
                            let trackXRange = trackXMax - trackXMin
                            let scaleFactorX = driverXRange / trackXRange
                            
                            Text("Scale difference X: \(String(format: "%.2f", scaleFactorX))x")
                                .font(.caption.monospaced())
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
        .onAppear {
            if trackViewModel == nil {
                trackViewModel = TestTrackMapViewModel()
                trackViewModel?.connect()
            }
        }
        .onDisappear {
            trackViewModel?.disconnect()
        }
        .onChange(of: trackViewModel?.isConnected) { old, new in
          if new == false {
            trackViewModel?.disconnect()
          }
        }
    }
    
    private func testDisconnectReconnect() {
        print("🧪 TEST: Starting disconnect/reconnect test")
        trackViewModel?.disconnect()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("🧪 TEST: Reconnecting after delay...")
            trackViewModel?.connect()
        }
    }
}

// MARK: - Static Track Layer (mimics StaticTrackLayer)

struct TestStaticTrackLayer: View {
    let viewModel: TestTrackMapViewModel
    let size: CGSize
    
    var body: some View {
        Canvas { context, _ in
            drawTrack(in: context, size: size)
            drawSectors(in: context, size: size)
            drawFinishLine(in: context, size: size)
        }
    }
    
    private func drawTrack(in context: GraphicsContext, size: CGSize) {
        // Draw main track outline using real track data
        var path = Path()
        let normalizedPoints = viewModel.rotatedPoints.map { point in
            viewModel.normalizedPosition(for: point, in: size)
        }
        
        if let firstPoint = normalizedPoints.first {
            path.move(to: firstPoint)
            for point in normalizedPoints.dropFirst() {
                path.addLine(to: point)
            }
            path.closeSubpath()
        }
        
        #if os(macOS)
            let trackWidth: CGFloat = 20
        #else
            let trackWidth: CGFloat = 24
        #endif
        
        // Track layers (like real app)
        context.stroke(
            path,
            with: .color(Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.2)),
            style: StrokeStyle(lineWidth: trackWidth + 12, lineCap: .round, lineJoin: .round)
        )
        
        context.stroke(
            path,
            with: .color(.black.opacity(0.4)),
            style: StrokeStyle(lineWidth: trackWidth + 6, lineCap: .round, lineJoin: .round)
        )
        
        context.stroke(
            path,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.25, green: 0.25, blue: 0.3),
                    Color(red: 0.35, green: 0.35, blue: 0.4),
                ]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 1, y: 1)
            ),
            style: StrokeStyle(lineWidth: trackWidth, lineCap: .round, lineJoin: .round)
        )
        
        // Track surface texture
        context.stroke(
            path,
            with: .color(Color(white: 0.45).opacity(0.3)),
            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [10, 5])
        )
    }
    
    private func drawSectors(in context: GraphicsContext, size: CGSize) {
        // Simplified sector drawing - just use default gray color
        for sector in viewModel.sectors {
            var path = Path()
            let points = sector.points.map { point in
                viewModel.normalizedPosition(for: point, in: size)
            }
            
            if let firstPoint = points.first {
                path.move(to: firstPoint)
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            
            context.stroke(
                path,
                with: .color(Color(white: 0.6).opacity(0.5)),
                style: StrokeStyle(
                    lineWidth: 4,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }
    }
    
    private func drawFinishLine(in context: GraphicsContext, size: CGSize) {
        guard let finishLine = viewModel.finishLinePosition else { return }
        
        let point = viewModel.normalizedPosition(for: finishLine, in: size)
        
        // Draw checkered pattern for finish line
        let checkerSize: CGFloat = 4
        for row in 0..<5 {
            for col in 0..<3 {
                let isBlack = (row + col) % 2 == 0
                let checkerRect = CGRect(
                    x: point.x - 6 + CGFloat(col) * checkerSize,
                    y: point.y - 10 + CGFloat(row) * checkerSize,
                    width: checkerSize,
                    height: checkerSize
                )
                context.fill(
                    Path(checkerRect),
                    with: .color(isBlack ? .black : .white)
                )
            }
        }
        
        // Add border
        context.stroke(
            Path(CGRect(x: point.x - 6, y: point.y - 10, width: 12, height: 20)),
            with: .color(.white.opacity(0.8)),
            lineWidth: 1
        )
    }
}

// MARK: - Dynamic Driver Layer (mimics DynamicDriverLayer)

struct TestDynamicDriverLayer: View {
    let viewModel: TestTrackMapViewModel
    let size: CGSize
    
    // Track animated positions separately from actual data
    @State private var animatedPositions: [String: CGPoint] = [:]
    @State private var lastUpdateTimestamp: String = ""
    
    var body: some View {
        ZStack {
            ForEach(Array(viewModel.driverPositions), id: \.racingNumber) { item in
                if let driver = viewModel.drivers[item.racingNumber] {
                    let normalizedPos = getNormalizedPosition(for: item.position)
                    let animatedPos = animatedPositions[item.racingNumber] ?? normalizedPos
                    
                    TestAnimatedDriverMarker(
                        racingNumber: item.racingNumber,
                        tla: driver.tla,
                        teamColor: Color(hex: driver.color) ?? .gray,
                        position: animatedPos
                    )
                    .animation(.linear(duration: 0.8), value: animatedPositions[item.racingNumber])
                }
            }
        }
        .onChange(of: viewModel.lastUpdateTimestamp) { _, newTimestamp in
            if !newTimestamp.isEmpty && newTimestamp != lastUpdateTimestamp {
                print("🔵 TEST: DynamicDriverLayer detected new timestamp: \(newTimestamp)")
                lastUpdateTimestamp = newTimestamp
                updateAnimatedPositions()
            }
        }
        .onAppear {
            print("🔵 TEST: DynamicDriverLayer onAppear")
            updateAnimatedPositions()
        }
        // Clear cached positions on disconnect
        .onChange(of: viewModel.isConnected) { _, isConnected in
            if !isConnected {
                print("🟤 TEST: DynamicDriverLayer clearing positions on disconnect")
                animatedPositions.removeAll()
                lastUpdateTimestamp = ""
            }
        }
    }
    
    private func updateAnimatedPositions() {
        print("🟣 TEST: DynamicDriverLayer updating animated positions")
        
        for item in viewModel.driverPositions {
            let normalizedPos = getNormalizedPosition(for: item.position)
            animatedPositions[item.racingNumber] = normalizedPos
            
            // Debug first driver
            if item.racingNumber == viewModel.driverPositions.first?.racingNumber {
                print("  Driver \(item.racingNumber): raw(\(item.position.x), \(item.position.y)) -> normalized(\(normalizedPos))")
                print("  View size: \(size.width) x \(size.height)")
            }
        }
        
        print("🟣 TEST: DynamicDriverLayer has \(animatedPositions.count) animated positions")
    }
    
    private func getNormalizedPosition(for position: (x: Double, y: Double)) -> CGPoint {
        guard let trackMap = viewModel.trackMap else {
            return .zero
        }
        
        // Rotate position according to track rotation
        let rotatedPos = TrackMap.rotate(
            x: position.x, y: position.y,
            angle: trackMap.rotation + 90,  // rotationFix
            centerX: viewModel.centerX, centerY: viewModel.centerY
        )
        
        return viewModel.normalizedPosition(for: rotatedPos, in: size)
    }
}

// MARK: - Animated Driver Marker (mimics AnimatedDriverMarker)

struct TestAnimatedDriverMarker: View {
    let racingNumber: String
    let tla: String
    let teamColor: Color
    let position: CGPoint
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(teamColor.opacity(0.3))
                .frame(width: 24, height: 24)
                .blur(radius: 2)
            
            // Shadow
            Circle()
                .fill(.black.opacity(0.5))
                .frame(width: 18, height: 18)
                .offset(x: 1, y: 1)
                .blur(radius: 1)
            
            // Team color circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [teamColor, teamColor.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 16, height: 16)
            
            // White border
            Circle()
                .stroke(.white, lineWidth: 1.5)
                .frame(width: 16, height: 16)
            
            // Racing number (like real app)
            Text(racingNumber)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
        }
        .position(position)
    }
}


