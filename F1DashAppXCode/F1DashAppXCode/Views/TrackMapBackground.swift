//
//  TrackMapBackground.swift
//  F1-Dash
//
//  Background view that shows the actual track map
//

import SwiftUI
import F1DashModels

struct TrackMapBackground: View {
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @State private var trackViewModel: OptimizedTrackMapViewModel?
    @State private var renderedMapImage: Image?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark background base
                Color.black.opacity(0.9)
                
                if let mapImage = renderedMapImage {
                    mapImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .opacity(0.15) // Subtle background
                        .blur(radius: 3) // Slight blur to not interfere with content
                        .clipped()
                } else if let viewModel = trackViewModel, viewModel.hasMapData {
                    // Render the track map
                    Canvas { context, size in
                        drawTrack(context: context, size: size, viewModel: viewModel)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.15)
                    .blur(radius: 3)
                    .onAppear {
                        renderTrackToImage(size: geometry.size, viewModel: viewModel)
                    }
                }
                
                // Gradient overlay for better readability
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.4),
                        Color.black.opacity(0.2),
                        Color.black.opacity(0.4)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            if trackViewModel == nil,
               let circuitKey = appEnvironment.liveSessionState.sessionInfo?.meeting?.circuit.key {
                trackViewModel = OptimizedTrackMapViewModel(
                    liveSessionState: appEnvironment.liveSessionState,
                    settingsStore: appEnvironment.settingsStore
                )
            }
        }
        .onChange(of: appEnvironment.liveSessionState.sessionInfo?.meeting?.circuit.key) { _, newValue in
            if let newKey = newValue {
                // Reload map for new circuit
                trackViewModel = OptimizedTrackMapViewModel(
                    liveSessionState: appEnvironment.liveSessionState,
                    settingsStore: appEnvironment.settingsStore
                )
                renderedMapImage = nil
            }
        }
    }
    
    private func drawTrack(context: GraphicsContext, size: CGSize, viewModel: OptimizedTrackMapViewModel) {
        // Draw main track outline
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
        
        // Draw track with a softer color for background
        context.stroke(
            path,
            with: .color(Color.white.opacity(0.8)),
            style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round)
        )
        
        // Draw sectors with subtle colors
        for sector in viewModel.sectors {
            var sectorPath = Path()
            let points = sector.points.map { point in
                viewModel.normalizedPosition(for: point, in: size)
            }
            
            if let firstPoint = points.first {
                sectorPath.move(to: firstPoint)
                for point in points.dropFirst() {
                    sectorPath.addLine(to: point)
                }
            }
            
            context.stroke(
                sectorPath,
                with: .color(Color.white.opacity(0.3)),
                style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
            )
        }
    }
    
    private func renderTrackToImage(size: CGSize, viewModel: OptimizedTrackMapViewModel) {
        let renderer = ImageRenderer(content:
            Canvas { context, _ in
                drawTrack(context: context, size: size, viewModel: viewModel)
            }
            .frame(width: size.width, height: size.height)
            .background(Color.clear)
        )
        
        #if os(iOS)
        renderer.scale = UIScreen.main.scale
        if let uiImage = renderer.uiImage {
            renderedMapImage = Image(uiImage: uiImage)
        }
        #elseif os(macOS)
        if let nsImage = renderer.nsImage {
            renderedMapImage = Image(nsImage: nsImage)
        }
        #endif
    }
}