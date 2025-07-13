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
    @State private var trackData: [CGPoint] = []
    @State private var hasInitialized = false
    
    var body: some View {
        ZStack {
            // Background with glass effect
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
            
            // Track map content
            if let sessionInfo = appEnvironment.liveSessionState.sessionInfo,
               let _ = sessionInfo.meeting?.circuit.key {
                GeometryReader { geometry in
                    Canvas { context, size in
                        // Draw simplified track
                        drawSimplifiedTrack(in: context, size: size)
                        
                        // Draw driver positions with larger dots for visibility
                        drawDriverPositions(in: context, size: size)
                    }
                    .padding(8)
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
            loadTrackData()
        }
    }
    
    private func loadTrackData() {
        // Simple track data for PiP mode
        // In a real implementation, this would load actual circuit data
        // For now, create a simple oval track
        let steps = 100
        trackData = (0..<steps).map { i in
            let angle = Double(i) / Double(steps) * 2 * .pi
            let x = 0.5 + 0.3 * cos(angle)
            let y = 0.5 + 0.4 * sin(angle)
            return CGPoint(x: x, y: y)
        }
        hasInitialized = true
    }
    
    private func drawSimplifiedTrack(in context: GraphicsContext, size: CGSize) {
        guard !trackData.isEmpty else { return }
        
        // Draw track with thicker line for better visibility
        var path = Path()
        
        let scaledPoints = trackData.map { point in
            CGPoint(x: point.x * size.width, y: point.y * size.height)
        }
        
        if let first = scaledPoints.first {
            path.move(to: first)
            for point in scaledPoints.dropFirst() {
                path.addLine(to: point)
            }
            path.closeSubpath()
        }
        
        // Simple track rendering
        context.stroke(
            path,
            with: .color(.secondary),
            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
        )
    }
    
    private func drawDriverPositions(in context: GraphicsContext, size: CGSize) {
        let drivers = appEnvironment.liveSessionState.driverList
        
        for (_, driver) in drivers {
            guard let position = appEnvironment.liveSessionState.position(for: driver.racingNumber),
                  position.status == nil || position.status == "OnTrack" else { continue }
            
            let point = CGPoint(x: position.x * size.width, y: position.y * size.height)
            let isFavorite = appEnvironment.settingsStore.favoriteDriverIDsString.contains(driver.racingNumber)
            let dotSize: CGFloat = isFavorite ? 10 : 8
            
            let rect = CGRect(
                x: point.x - dotSize/2,
                y: point.y - dotSize/2,
                width: dotSize,
                height: dotSize
            )
            
            // Draw driver dot
            let teamColor = Color(hex: driver.teamColour) ?? .gray
            context.fill(
                Circle().path(in: rect),
                with: .color(teamColor)
            )
            
            // White border for visibility
            context.stroke(
                Circle().path(in: rect),
                with: .color(.white),
                lineWidth: 1
            )
            
            // Show TLA only for favorite drivers in PiP mode
            if isFavorite {
                context.draw(
                    Text(driver.tla)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white),
                    at: CGPoint(
                        x: point.x,
                        y: point.y + dotSize + 4
                    )
                )
            }
        }
    }
}
