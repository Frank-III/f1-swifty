//
//  TestTrackMapView.swift
//  F1-Dash
//
//  Test view to debug track map and driver positions
//

import SwiftUI
import F1DashModels

struct TestTrackMapView: View {
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @State private var isConnecting = false
    @State private var trackViewModel: OptimizedTrackMapViewModel?
    @State private var refreshTimer: Timer?
    @State private var updateCount = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Track Map Test")
                .font(.largeTitle)
            
            // Connection status
            HStack {
                Circle()
                    .fill(connectionColor)
                    .frame(width: 10, height: 10)
                Text("Status: \(String(describing: appEnvironment.connectionStatus))")
            }
            
            // Connect button
            Button(action: {
                Task {
                    isConnecting = true
                    await appEnvironment.connect()
                    isConnecting = false
                }
            }) {
                if isConnecting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                } else {
                    Text("Connect to SSE")
                }
            }
            .disabled(appEnvironment.connectionStatus == .connected || isConnecting)
            .buttonStyle(.borderedProminent)
            
            // Session info
            VStack(alignment: .leading) {
                Text("Session Info:")
                    .font(.headline)
                if let sessionInfo = appEnvironment.liveSessionState.sessionInfo {
                    Text("Meeting: \(sessionInfo.meeting?.name ?? "Unknown")")
                    Text("Circuit Key: \(sessionInfo.meeting?.circuit.key ?? 0)")
                    Text("Session: \(sessionInfo.name ?? "Unknown")")
                } else {
                    Text("No session info available")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Driver list
            VStack(alignment: .leading) {
                Text("Drivers: \(appEnvironment.liveSessionState.driverList.count)")
                    .font(.headline)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(Array(appEnvironment.liveSessionState.driverList.values.sorted(by: { $0.line < $1.line })), id: \.racingNumber) { driver in
                            VStack {
                                Text(driver.tla)
                                    .font(.caption.bold())
                                Text("#\(driver.racingNumber)")
                                    .font(.caption2)
                            }
                            .padding(4)
                            .background(Color(hex: driver.teamColour) ?? .gray)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                        }
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Position data debug
            VStack(alignment: .leading) {
                Text("Position Data Debug:")
                    .font(.headline)
                
                if let positionData = appEnvironment.liveSessionState.positionData {
                    Text("Position entries: \(positionData.position?.count ?? 0)")
                    
                    if let latestPosition = positionData.position?.last {
                        Text("Latest timestamp: \(latestPosition.timestamp)")
                        Text("Cars with positions: \(latestPosition.entries.count)")
                        
                        // Show first few driver positions
                        ForEach(Array(latestPosition.entries.prefix(5)), id: \.key) { entry in
                            let (racingNumber, position) = entry
                            if let driver = appEnvironment.liveSessionState.driver(for: racingNumber) {
                                Text("\(driver.tla): X=\(String(format: "%.2f", position.x)), Y=\(String(format: "%.2f", position.y)), Status=\(position.status ?? "unknown")")
                                    .font(.system(.caption, design: .monospaced))
                            }
                        }
                    }
                } else {
                    Text("No position data available")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Track map
            VStack(alignment: .leading) {
                HStack {
                    Text("Track Map:")
                        .font(.headline)
                    
                    if let viewModel = trackViewModel {
                        Text(viewModel.hasMapData ? "✓ Loaded" : "✗ Not loaded")
                            .foregroundStyle(viewModel.hasMapData ? .green : .red)
                    }
                    
                    Button("Print Raw Positions") {
                        printRawPositionData()
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                    
                    Button("Force Reload Map") {
                        trackViewModel?.loadTrackMap()
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                    
                    Button("Print JSON") {
                        printPositionJSON()
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                    
                    Button("Test Lookup") {
                        testPositionLookup()
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                }
                
                ZStack {
                    if let circuitKey = appEnvironment.liveSessionState.sessionInfo?.meeting?.circuit.key {
                        // Use debug version with more logging
                        DebugTrackMapView(circuitKey: String(circuitKey), viewModel: $trackViewModel)
                            .frame(height: 300)
                            .background(Color.black)
                            .cornerRadius(8)
                    } else {
                        Text("No circuit key available")
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                
                // Driver positions from view model
                if let viewModel = trackViewModel {
                    Text("Driver positions in view model: \(viewModel.driverPositions.count)")
                        .font(.caption)
                    
                    ForEach(viewModel.driverPositions.prefix(5), id: \.driver.racingNumber) { item in
                        Text("\(item.driver.tla): \(item.position.status ?? "unknown")")
                            .font(.caption2)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Spacer()
        }
        .padding()
        .frame(width: 600, height: 900)
        .onAppear {
            if trackViewModel == nil {
                trackViewModel = OptimizedTrackMapViewModel(
                    liveSessionState: appEnvironment.liveSessionState,
                    settingsStore: appEnvironment.settingsStore
                )
            }
            
            // Set up refresh timer
            refreshTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                updateCount += 1
                print("\n--- Update \(updateCount) ---")
                print("TrackViewModel exists: \(trackViewModel != nil)")
                print("TrackViewModel hasMapData: \(trackViewModel?.hasMapData ?? false)")
                print("Driver positions count: \(trackViewModel?.driverPositions.count ?? 0)")
                
                // Force a refresh by accessing the computed property
                _ = trackViewModel?.driverPositions
            }
        }
        .onDisappear {
            refreshTimer?.invalidate()
            refreshTimer = nil
        }
    }
    
    private func printRawPositionData() {
        print("\n=== RAW POSITION DATA DEBUG ===")
        
        // Check if position data exists
        if let positionData = appEnvironment.liveSessionState.positionData {
            print("PositionData exists: YES")
            print("Position array count: \(positionData.position?.count ?? 0)")
            
            if let latestPosition = positionData.position?.last {
                print("Latest timestamp: \(latestPosition.timestamp)")
                print("Total entries: \(latestPosition.entries.count)")
                
                // Print all position entries
                for (racingNumber, position) in latestPosition.entries {
                    if let driver = appEnvironment.liveSessionState.driver(for: racingNumber) {
                        print("\nDriver \(driver.tla) (#\(racingNumber)):")
                        print("  X: \(position.x)")
                        print("  Y: \(position.y)")
                        print("  Z: \(position.z)")
                        print("  Status: \(position.status ?? "unknown")")
                    } else if racingNumber == "241" || racingNumber == "242" || racingNumber == "243" {
                        print("\nSafety Car #\(racingNumber):")
                        print("  X: \(position.x)")
                        print("  Y: \(position.y)")
                        print("  Z: \(position.z)")
                        print("  Status: \(position.status ?? "unknown")")
                    }
                }
            } else {
                print("No position entries found")
            }
        } else {
            print("PositionData exists: NO")
        }
        
        // Also check raw state
        print("\n--- Raw State Check ---")
        if let rawData = appEnvironment.liveSessionState.debugRawData(for: "positionData") {
            print("Raw positionData exists in state")
            if let dict = rawData as? [String: Any] {
                print("Top level keys: \(dict.keys.sorted())")
                
                // Check the nested positionData
                if let nestedPositionData = dict["positionData"] {
                    print("\nNested positionData type: \(type(of: nestedPositionData))")
                    
                    if let posArray = nestedPositionData as? [[String: Any]] {
                        print("It's an array with \(posArray.count) entries")
                        if let first = posArray.first {
                            print("\nFirst entry keys: \(first.keys.sorted())")
                            
                            // Check timestamp
                            if let timestamp = first["timestamp"] {
                                print("Timestamp: \(timestamp)")
                            }
                            
                            // Check entries
                            if let entries = first["entries"] as? [String: Any] {
                                print("Entries count: \(entries.count)")
                                
                                // Show first driver entry
                                if let firstDriverKey = entries.keys.sorted().first,
                                   let firstDriver = entries[firstDriverKey] as? [String: Any] {
                                    print("\nFirst driver (#\(firstDriverKey)):")
                                    print("  Keys: \(firstDriver.keys.sorted())")
                                    print("  X: \(firstDriver["x"] ?? "nil")")
                                    print("  Y: \(firstDriver["y"] ?? "nil")")
                                    print("  Z: \(firstDriver["z"] ?? "nil")")
                                    print("  Status: \(firstDriver["status"] ?? "nil")")
                                }
                            }
                        }
                    } else if let posDict = nestedPositionData as? [String: Any] {
                        print("It's a dict with keys: \(posDict.keys.sorted())")
                    } else {
                        print("Unknown type for nested positionData")
                    }
                }
            }
        } else {
            print("No raw positionData in state")
        }
        
        // Test the computed property
        print("\n--- Computed Property Test ---")
        if let posData = appEnvironment.liveSessionState.positionData {
            print("✓ positionData computed property returned data")
            print("  position array count: \(posData.position?.count ?? 0)")
        } else {
            print("✗ positionData computed property returned nil")
        }
        
        print("=== END POSITION DATA DEBUG ===\n")
    }
    
    private func printPositionJSON() {
        print("\n=== POSITION JSON ===")
        if let rawData = appEnvironment.liveSessionState.debugRawData(for: "positionData") {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: rawData, options: .prettyPrinted)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    // Just print first 1000 chars to avoid overwhelming output
                    let preview = String(jsonString.prefix(1000))
                    print(preview)
                    if jsonString.count > 1000 {
                        print("... (\(jsonString.count - 1000) more characters)")
                    }
                }
            } catch {
                print("Failed to convert to JSON: \(error)")
            }
        } else {
            print("No positionData in state")
        }
        print("=== END JSON ===\n")
    }
    
    private func testPositionLookup() {
        print("\n=== POSITION LOOKUP TEST ===")
        
        // Test the position accessor method
        let drivers = appEnvironment.liveSessionState.driverList
        print("Testing position lookup for \(drivers.count) drivers")
        
        for (racingNumber, driver) in drivers.prefix(5) {
            print("\nDriver \(driver.tla) (#\(racingNumber)):")
            
            if let position = appEnvironment.liveSessionState.position(for: racingNumber) {
                print("  ✓ Position found: X=\(position.x), Y=\(position.y), Status=\(position.status ?? "unknown")")
            } else {
                print("  ✗ No position found")
                
                // Check if position exists in raw data
                if let posData = appEnvironment.liveSessionState.positionData,
                   let latestPos = posData.position?.last {
                    if let rawPos = latestPos.entries[racingNumber] {
                        print("  BUT position exists in decoded data: X=\(rawPos.x), Y=\(rawPos.y)")
                    } else {
                        print("  Position not in latest entries")
                        print("  Available racing numbers: \(Array(latestPos.entries.keys).sorted())")
                    }
                }
            }
        }
        
        print("\n=== END LOOKUP TEST ===\n")
    }
    
    private var connectionColor: Color {
        switch appEnvironment.connectionStatus {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .red
        }
    }
}

// Debug version of track map with extra logging
struct DebugTrackMapView: View {
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    let circuitKey: String
    @Binding var viewModel: OptimizedTrackMapViewModel?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                
                if let viewModel = viewModel, viewModel.hasMapData {
                    // Static track layer with logging
                    Canvas { context, _ in
                        drawDebugTrack(in: context, size: geometry.size)
                    }
                    
                    // Dynamic driver positions with logging
                    Canvas { context, _ in
                        drawDebugDrivers(in: context, size: geometry.size)
                    }
                    .onAppear {
                        print("DebugTrackMap: Drawing \(viewModel.driverPositions.count) drivers")
                    }
                } else {
                    VStack {
                        ProgressView()
                        Text("Loading track...")
                            .foregroundStyle(.white)
                        if let vm = viewModel {
                            Text("hasMapData: \(vm.hasMapData)")
                                .foregroundStyle(.white)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .onAppear {
            print("DebugTrackMap: View appeared, viewModel exists: \(viewModel != nil)")
            if let vm = viewModel {
                print("DebugTrackMap: hasMapData: \(vm.hasMapData)")
            }
        }
    }
    
    private func drawDebugTrack(in context: GraphicsContext, size: CGSize) {
        guard let viewModel = viewModel else { return }
        
        // Draw track outline
        var path = Path()
        let points = viewModel.rotatedPoints.map { point in
            viewModel.normalizedPosition(for: point, in: size)
        }
        
        if let firstPoint = points.first {
            path.move(to: firstPoint)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            path.closeSubpath()
        }
        
        context.stroke(
            path,
            with: .color(.gray),
            style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round)
        )
        
        // Draw origin marker for debugging
        context.fill(
            Circle().path(in: CGRect(x: -5, y: -5, width: 10, height: 10)),
            with: .color(.red)
        )
        
        // Draw size marker
        context.draw(
            Text("Size: \(Int(size.width))x\(Int(size.height))")
                .font(.caption)
                .foregroundStyle(.white),
            at: CGPoint(x: size.width / 2, y: 20)
        )
    }
    
    private func drawDebugDrivers(in context: GraphicsContext, size: CGSize) {
        guard let viewModel = viewModel else { return }
        
        let positions = viewModel.driverPositions
        print("DebugTrackMap: Drawing \(positions.count) driver positions")
        
        for (index, item) in positions.enumerated() {
            let (driver, position) = item
            
            // Raw position
            print("Driver \(driver.tla): Raw position (\(position.x), \(position.y))")
            
            // Rotated position
            if let trackMap = viewModel.trackMap {
                let rotatedPos = TrackMap.rotate(
                    x: position.x, y: position.y,
                    angle: trackMap.rotation + 90,
                    centerX: viewModel.centerX, centerY: viewModel.centerY
                )
                print("Driver \(driver.tla): Rotated position (\(rotatedPos.x), \(rotatedPos.y))")
                
                // Normalized position
                let normalizedPos = viewModel.normalizedPosition(for: rotatedPos, in: size)
                print("Driver \(driver.tla): Normalized position (\(normalizedPos.x), \(normalizedPos.y))")
                
                // Draw the driver
                let teamColor = Color(hex: driver.teamColour) ?? .gray
                
                context.fill(
                    Circle().path(in: CGRect(
                        x: normalizedPos.x - 8,
                        y: normalizedPos.y - 8,
                        width: 16,
                        height: 16
                    )),
                    with: .color(teamColor)
                )
                
                context.draw(
                    Text(driver.tla)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white),
                    at: CGPoint(x: normalizedPos.x + 20, y: normalizedPos.y)
                )
                
                // Draw debug info for first driver
                if index == 0 {
                    context.draw(
                        Text("Raw: \(String(format: "%.1f,%.1f", position.x, position.y))")
                            .font(.caption2)
                            .foregroundStyle(.yellow),
                        at: CGPoint(x: normalizedPos.x, y: normalizedPos.y + 20)
                    )
                }
            }
        }
    }
}

#Preview {
    TestTrackMapView()
        .environment(OptimizedAppEnvironment())
}