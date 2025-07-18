//
//  OptimizedTrackMapPiPContent.swift
//  F1DashAppXCode
//
//  Optimized PiP content view for track map
//

import SwiftUI
import F1DashModels

struct OptimizedTrackMapPiPContent: View {
    let appEnvironment: OptimizedAppEnvironment
    @State private var trackViewModel: OptimizedTrackMapViewModel?
    @State private var animatedPositions: [String: CGPoint] = [:]
    @State private var lastUpdateTime: Date = Date()
    
    var body: some View {
        ZStack {
            // Background with glass effect
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
            
            // Track map content
            if let sessionInfo = appEnvironment.liveSessionState.sessionInfo,
               let _ = sessionInfo.meeting?.circuit.key,
               let viewModel = trackViewModel,
               viewModel.hasMapData {
                GeometryReader { geometry in
                    ZStack {
                        // Static track layer
                        Canvas { context, size in
                            drawRealTrack(in: context, size: size, viewModel: viewModel)
                        }
                        .padding(8)
                        
                        // Dynamic driver layer with smooth animations
                        // Access positionData to trigger updates
                        let _ = appEnvironment.liveSessionState.positionData
                        PiPDynamicDriverLayer(
                            viewModel: viewModel,
                            size: CGSize(
                                width: geometry.size.width - 16,
                                height: geometry.size.height - 16
                            )
                        )
                        .padding(8)
                    }
                }
                
                // Minimal overlay info
                VStack {
                    HStack {
                        // Session status indicator
                        if let trackStatus = appEnvironment.liveSessionState.trackStatus {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color(hex: trackStatus.status.color) ?? .gray)
                                    .frame(width: 8, height: 8)
                                Text(trackStatus.status.displayName)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                            .padding(6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        }
                        
                        Spacer()
                        
                        // Close button for iOS (macOS has window controls)
                        #if !os(macOS)
                        Button {
                            appEnvironment.pictureInPictureManager.deactivatePiP()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                        #endif
                    }
                    .padding(8)
                    
                    Spacer()
                }
            } else {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .onAppear {
            if trackViewModel == nil {
                trackViewModel = OptimizedTrackMapViewModel(
                    liveSessionState: appEnvironment.liveSessionState,
                    settingsStore: appEnvironment.settingsStore
                )
            }
        }
    }
    
    private func drawRealTrack(in context: GraphicsContext, size: CGSize, viewModel: OptimizedTrackMapViewModel) {
        // Draw track outline
        var path = Path()
        let rotatedPoints = viewModel.rotatedPoints.map { point in
            viewModel.normalizedPosition(for: point, in: size)
        }
        
        if let firstPoint = rotatedPoints.first {
            path.move(to: firstPoint)
            for point in rotatedPoints.dropFirst() {
                path.addLine(to: point)
            }
            path.closeSubpath()
        }
        
        // Simplified track rendering for PiP
        context.stroke(
            path,
            with: .color(Color(white: 0.4)),
            style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
        )
        
        // Draw sectors with status colors
        let trackStatus = appEnvironment.liveSessionState.trackStatus
        if let status = trackStatus?.status {
            let statusColor: Color = {
                switch status {
                case .green: return Color(red: 0.0, green: 0.9, blue: 0.2)
                case .yellow, .scYellow: return Color(red: 1.0, green: 0.8, blue: 0.0)
                case .red, .scRed: return Color(red: 1.0, green: 0.2, blue: 0.2)
                default: return .gray
                }
            }()
            
            context.stroke(
                path,
                with: .color(statusColor.opacity(0.6)),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
            )
        }
    }
}

// MARK: - PiP Dynamic Driver Layer

struct PiPDynamicDriverLayer: View {
    let viewModel: OptimizedTrackMapViewModel
    let size: CGSize
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    // Track animated positions separately from actual data
    @State private var animatedPositions: [String: CGPoint] = [:]
    
    private var positionUpdateKey: String {
        driverData.map { "\($0.driver.racingNumber):\($0.position.x),\($0.position.y)" }.joined()
    }
    
    private var driverData: [(driver: Driver, position: PositionCar)] {
        viewModel.driverPositions
    }
    
    var body: some View {
        ZStack {
            ForEach(driverData, id: \.driver.racingNumber) { driver, position in
                let normalizedPos = getNormalizedPosition(for: position)
                let isOnTrack = position.status == nil || position.status == "OnTrack"
                
                PiPDriverMarker(
                    driver: driver,
                    teamColor: Color(hex: driver.teamColour) ?? .gray,
                    position: animatedPositions[driver.racingNumber] ?? normalizedPos,
                    isOnTrack: isOnTrack,
                    isFavorite: appEnvironment.settingsStore.isFavoriteDriver(driver.racingNumber)
                )
                .animation(.linear(duration: 0.5), value: animatedPositions[driver.racingNumber])
            }
        }
        .onChange(of: positionUpdateKey) { _, _ in
            // Update positions when data changes
            updateAnimatedPositions()
        }
        .onAppear {
            // Set initial positions
            updateAnimatedPositions()
        }
        .onDisappear {
            // Clean up when view disappears
            animatedPositions.removeAll()
        }
    }
    
    private func updateAnimatedPositions() {
        for (driver, position) in driverData {
            animatedPositions[driver.racingNumber] = getNormalizedPosition(for: position)
        }
    }
    
    private func getNormalizedPosition(for position: PositionCar) -> CGPoint {
        guard let trackMap = viewModel.trackMap else {
            return .zero
        }
        
        // Rotate position according to track rotation
        let rotatedPos = TrackMap.rotate(
            x: position.x, y: position.y,
            angle: trackMap.rotation + 90, // rotationFix
            centerX: viewModel.centerX, centerY: viewModel.centerY
        )
        
        return viewModel.normalizedPosition(for: rotatedPos, in: size)
    }
}

// MARK: - PiP Driver Marker

struct PiPDriverMarker: View {
    let driver: Driver
    let teamColor: Color
    let position: CGPoint
    let isOnTrack: Bool
    let isFavorite: Bool
    
    var body: some View {
        ZStack {
            // Outer glow for PiP visibility
            Circle()
                .fill(teamColor.opacity(0.4))
                .frame(width: 14, height: 14)
                .blur(radius: 1)
            
            // Team color circle
            Circle()
                .fill(teamColor)
                .frame(width: 10, height: 10)
            
            // White border for visibility
            Circle()
                .stroke(.white, lineWidth: 1)
                .frame(width: 10, height: 10)
            
            // Driver number
            Text(driver.racingNumber)
                .font(.system(size: 6, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.8), radius: 1, x: 0, y: 0)
            
            // Favorite indicator
            if isFavorite {
                Circle()
                    .stroke(Color.blue, lineWidth: 1)
                    .frame(width: 14, height: 14)
            }
        }
        .position(position)
        .opacity(isOnTrack ? 1.0 : 0.4)
    }
}
