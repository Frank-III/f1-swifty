//
//  HybridTrackMapRealDataView.swift
//  F1-Dash
//
//  Hybrid track map using real data from OptimizedLiveSessionState
//  Canvas for static track elements + SwiftUI views for animated drivers
//

import SwiftUI
import F1DashModels

// MARK: - Animated Driver Marker

//struct AnimatedDriverMarker: View {
//    let driver: Driver
//    let teamColor: Color
//    let position: CGPoint
//    let isOnTrack: Bool
//    let isFavorite: Bool
//    
//    var body: some View {
//        ZStack {
//            // Shadow for depth
//            Circle()
//                .fill(.black.opacity(0.3))
//                .frame(width: 18, height: 18)
//                .offset(x: 1, y: 1)
//            
//            // Team color circle
//            Circle()
//                .fill(teamColor)
//                .frame(width: 16, height: 16)
//            
//            // White border
//            Circle()
//                .stroke(.white, lineWidth: 1)
//                .frame(width: 16, height: 16)
//            
//            // Driver number
//            Text(driver.racingNumber)
//                .font(.system(size: 9, weight: .bold))
//                .foregroundStyle(.white)
//            
//            // Favorite indicator
//            if isFavorite {
//                Circle()
//                    .stroke(Color.blue, lineWidth: 2)
//                    .frame(width: 20, height: 20)
//            }
//        }
//        .position(position)
//        .opacity(isOnTrack ? 1.0 : 0.3)
//    }
//}
//
//// MARK: - Animated Driver Layer
//
//struct HybridRealDriverLayer: View {
//    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
//    let viewModel: OptimizedTrackMapViewModel
//    let size: CGSize
//    
//    // Track animated positions separately from actual data
//    @State private var animatedPositions: [String: CGPoint] = [:]
//    
//    private var positionUpdateKey: String {
//        driverData.map { "\($0.driver.racingNumber):\($0.position.x),\($0.position.y)" }.joined()
//    }
//    
//    private func isRetired(_ timing: TimingDataDriver?) -> Bool {
//        // Since TimingDataDriver doesn't have these properties directly,
//        // we'll just check if they're off track based on position status
//        return false
//    }
//    
//    private var driverData: [(driver: Driver, position: PositionCar, timing: TimingDataDriver?)] {
//        let drivers = appEnvironment.liveSessionState.driverList
//        let positionData = appEnvironment.liveSessionState.positionData
//        let timingData = appEnvironment.liveSessionState.timingData
//        
//        guard let latestPositions = positionData?.position?.last else {
//            return []
//        }
//        
//        return drivers.compactMap { (_, driver) in
//            guard let position = latestPositions.entries[driver.racingNumber] else {
//                return nil
//            }
//            // Skip positions at (0,0) which indicate off-track
//            guard position.x != 0 || position.y != 0 else {
//                return nil
//            }
//            let timing = timingData?.lines[driver.racingNumber]
//            return (driver, position, timing)
//        }
//    }
//    
//    var body: some View {
//        ZStack {
//            ForEach(driverData, id: \.driver.racingNumber) { driver, position, timing in
//                let normalizedPos = getNormalizedPosition(for: position)
//                let isOnTrack = position.status == "OnTrack" && !isRetired(timing)
//                
//                AnimatedDriverMarker(
//                    driver: driver,
//                    teamColor: Color(hex: driver.teamColour) ?? .gray,
//                    position: animatedPositions[driver.racingNumber] ?? normalizedPos,
//                    isOnTrack: isOnTrack,
//                    isFavorite: appEnvironment.settingsStore.isFavoriteDriver(driver.racingNumber)
//                )
//                .animation(.linear(duration: 1.0), value: animatedPositions[driver.racingNumber])
//            }
//        }
//        .onChange(of: positionUpdateKey) { _, _ in
//            // Update positions when data changes
//            updateAnimatedPositions()
//        }
//        .onAppear {
//            // Set initial positions
//            updateAnimatedPositions()
//        }
//    }
//    
//    private func updateAnimatedPositions() {
//        for (driver, position, _) in driverData {
//            animatedPositions[driver.racingNumber] = getNormalizedPosition(for: position)
//        }
//    }
//    
//    private func getNormalizedPosition(for position: PositionCar) -> CGPoint {
//        guard let trackMap = viewModel.trackMap else {
//            return .zero
//        }
//        
//        // Rotate position according to track rotation
//        let rotatedPos = TrackMap.rotate(
//            x: position.x, y: position.y,
//            angle: trackMap.rotation + 90, // rotationFix
//            centerX: viewModel.centerX, centerY: viewModel.centerY
//        )
//        
//        return viewModel.normalizedPosition(for: rotatedPos, in: size)
//    }
//}
//
//// MARK: - Static Track Canvas
//
//struct HybridRealTrackCanvas: View {
//    let viewModel: OptimizedTrackMapViewModel
//    let size: CGSize
//    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
//    
//    var body: some View {
//        Canvas { context, _ in
//            // Draw track outline
//            drawTrack(in: context)
//            
//            // Draw sectors
//            drawSectors(in: context)
//            
//            // Draw finish line
//            drawFinishLine(in: context)
//            
//            // Draw corners if enabled
//            if appEnvironment.settingsStore.showCornerNumbers {
//                drawCorners(in: context)
//            }
//        }
//    }
//    
//    private func drawTrack(in context: GraphicsContext) {
//        var path = Path()
//        let rotatedPoints = viewModel.rotatedPoints.map { point in
//            viewModel.normalizedPosition(for: point, in: size)
//        }
//        
//        if let firstPoint = rotatedPoints.first {
//            path.move(to: firstPoint)
//            for point in rotatedPoints.dropFirst() {
//                path.addLine(to: point)
//            }
//            path.closeSubpath()
//        }
//        
//        #if os(macOS)
//        let trackWidth: CGFloat = 20
//        #else
//        let trackWidth: CGFloat = 24
//        #endif
//        
//        // Draw track shadow for depth (iOS)
//        #if !os(macOS)
//        context.stroke(
//            path,
//            with: .color(.black.opacity(0.1)),
//            style: StrokeStyle(lineWidth: trackWidth + 4, lineCap: .round, lineJoin: .round)
//        )
//        #endif
//        
//        // Draw track base
//        context.stroke(
//            path,
//            with: .color(Color(white: 0.3)),
//            style: StrokeStyle(lineWidth: trackWidth, lineCap: .round, lineJoin: .round)
//        )
//    }
//    
//    private func drawSectors(in context: GraphicsContext) {
//        let trackStatus = appEnvironment.liveSessionState.trackStatus
//        let raceControlMessages = appEnvironment.liveSessionState.raceControlMessages
//        
//        // Find yellow sectors from race control messages
//        let yellowSectors = findYellowSectors(from: raceControlMessages)
//        
//        for sector in viewModel.sectors {
//            var path = Path()
//            let points = sector.points.map { point in
//                viewModel.normalizedPosition(for: point, in: size)
//            }
//            
//            if let firstPoint = points.first {
//                path.move(to: firstPoint)
//                for point in points.dropFirst() {
//                    path.addLine(to: point)
//                }
//            }
//            
//            let color = getSectorColor(
//                sector: sector,
//                yellowSectors: yellowSectors,
//                trackStatus: trackStatus
//            )
//            
//            context.stroke(
//                path,
//                with: .color(color),
//                style: StrokeStyle(
//                    lineWidth: color == .secondary ? 4 : 8,
//                    lineCap: .round,
//                    lineJoin: .round
//                )
//            )
//        }
//    }
//    
//    private func drawFinishLine(in context: GraphicsContext) {
//        guard let finishLine = viewModel.finishLinePosition else { return }
//        
//        let point = viewModel.normalizedPosition(for: finishLine, in: size)
//        let lineRect = CGRect(
//            x: point.x - 5,
//            y: point.y - 10,
//            width: 10,
//            height: 20
//        )
//        
//        context.fill(
//            Path(lineRect),
//            with: .color(.red)
//        )
//    }
//    
//    private func drawCorners(in context: GraphicsContext) {
//        for corner in viewModel.rotatedCorners {
//            let position = viewModel.normalizedPosition(for: corner.labelPosition, in: size)
//            
//            context.draw(
//                Text("\(corner.number)")
//                    .font(.system(size: 12, weight: .semibold))
//                    .foregroundStyle(.secondary),
//                at: position
//            )
//        }
//    }
//    
//    private func findYellowSectors(from messages: RaceControlMessages?) -> Set<Int> {
//        guard let messages = messages?.messages else { return Set() }
//        
//        var yellowSectors = Set<Int>()
//        let yellowMessages = messages.filter { $0.flag == .yellow }
//        
//        for message in yellowMessages {
//            if message.scope == .track {
//                // Track-wide yellow
//                return Set(1...20)
//            } else if message.scope == .sector, let sector = message.sector {
//                yellowSectors.insert(sector)
//            }
//        }
//        
//        return yellowSectors
//    }
//    
//    private func getSectorColor(sector: MapSector, yellowSectors: Set<Int>, trackStatus: TrackStatus?) -> Color {
//        if yellowSectors.contains(sector.number) {
//            return .yellow
//        }
//        
//        if let status = trackStatus?.status {
//            switch status {
//            case .green: return .green
//            case .yellow, .scYellow: return .yellow
//            case .red, .scRed: return .red
//            default: break
//            }
//        }
//        
//        return .secondary
//    }
//}
//
//// MARK: - Main Hybrid Track Map View
//
//struct HybridTrackMapRealDataView: View {
//    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
//    @State private var trackViewModel: OptimizedTrackMapViewModel?
//    
//    private var circuitKey: String? {
//        if let key = appEnvironment.liveSessionState.sessionInfo?.meeting?.circuit.key {
//            return String(key)
//        }
//        return nil
//    }
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                // Background
//                Color.black
//                
//                if let viewModel = trackViewModel, viewModel.hasMapData {
//                    // Static track layer (Canvas)
//                    HybridRealTrackCanvas(
//                        viewModel: viewModel,
//                        size: geometry.size
//                    )
//                    
//                    // Animated driver layer (SwiftUI views)
//                    // Force update when position data changes
//                    let _ = appEnvironment.liveSessionState.positionData
//                    HybridRealDriverLayer(
//                        viewModel: viewModel,
//                        size: geometry.size
//                    )
//                    
//                    // Reload button overlay
//                    VStack {
//                        HStack {
//                            Spacer()
//                            Button {
//                                reloadMap()
//                            } label: {
//                                Label("Reload Map", systemImage: "arrow.clockwise")
//                                    .labelStyle(.iconOnly)
//                                    .font(.system(size: 16))
//                            }
//                            .buttonStyle(.bordered)
//                            .buttonBorderShape(.circle)
//                            .padding()
//                        }
//                        Spacer()
//                    }
//                } else {
//                    // Loading state
//                    VStack(spacing: 20) {
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle())
//                            .scaleEffect(1.5)
//                        
//                        Text(trackViewModel?.loadingError ?? "Loading track map...")
//                            .font(.headline)
//                            .foregroundStyle(.secondary)
//                        
//                        if trackViewModel?.loadingError != nil {
//                            Button("Retry") {
//                                reloadMap()
//                            }
//                            .buttonStyle(.borderedProminent)
//                        }
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                }
//            }
//        }
//        .onAppear {
//            if trackViewModel == nil {
//                trackViewModel = OptimizedTrackMapViewModel(
//                    liveSessionState: appEnvironment.liveSessionState,
//                    settingsStore: appEnvironment.settingsStore
//                )
//            }
//        }
//        .onChange(of: circuitKey) { _, _ in
//            // Reload map if circuit changes
//            trackViewModel?.loadTrackMap()
//        }
//    }
//    
//    private func reloadMap() {
//        trackViewModel?.loadTrackMap()
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    HybridTrackMapRealDataView()
//        .environment(OptimizedAppEnvironment())
//}
