//
//  TrackMapView.swift
//  F1-Dash
//
//  Track map visualization with live car positions
//

import SwiftUI
import F1DashModels

struct TrackMapView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    @State private var viewModel: TrackMapViewModel?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(nsColor: .controlBackgroundColor)
                
                if viewModel?.driverPositions.isEmpty == false {
                    // Track map canvas
                    Canvas { context, size in
                        drawTrack(in: context, size: size)
                        drawDrivers(in: context, size: size)
                    }
                    .padding()
                } else {
                    // Empty state
                    ContentUnavailableView(
                        "No Position Data",
                        systemImage: "map",
                        description: Text("Driver positions will appear here during a session")
                    )
                }
                
                // Controls overlay
                VStack {
                    HStack {
                        // Zoom controls
                        HStack(spacing: 4) {
                            Button {
                                appEnvironment.settingsStore.$trackMapZoom.withLock { 
                                    $0 = min($0 + 0.1, 2.0) 
                                }
                            } label: {
                                Image(systemName: "plus.magnifyingglass")
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                appEnvironment.settingsStore.$trackMapZoom.withLock { 
                                    $0 = max($0 - 0.1, 0.5) 
                                }
                            } label: {
                                Image(systemName: "minus.magnifyingglass")
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                appEnvironment.settingsStore.$trackMapZoom.withLock { $0 = 1.0 }
                            } label: {
                                Image(systemName: "1.magnifyingglass")
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(6)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            viewModel = TrackMapViewModel(appEnvironment: appEnvironment)
        }
    }
    
    // MARK: - Drawing
    
    private func drawTrack(in context: GraphicsContext, size: CGSize) {
        guard let viewModel = viewModel else { return }
        
        // Draw track path by connecting driver positions
        var path = Path()
        var isFirstPoint = true
        
        // Sort positions to create a rough track outline
        let sortedPositions = viewModel.driverPositions.sorted { pos1, pos2 in
            // Simple angular sort from center
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let angle1 = atan2(pos1.y - center.y, pos1.x - center.x)
            let angle2 = atan2(pos2.y - center.y, pos2.x - center.x)
            return angle1 < angle2
        }
        
        for position in sortedPositions {
            let point = viewModel.normalizedPosition(for: position, in: size)
            
            if isFirstPoint {
                path.move(to: point)
                isFirstPoint = false
            } else {
                path.addLine(to: point)
            }
        }
        
        // Close the path
        if !sortedPositions.isEmpty {
            let firstPoint = viewModel.normalizedPosition(for: sortedPositions[0], in: size)
            path.addLine(to: firstPoint)
        }
        
        // Draw track outline
        context.stroke(
            path,
            with: .color(.secondary.opacity(0.3)),
            lineWidth: 20 * appEnvironment.settingsStore.trackMapZoom
        )
    }
    
    private func drawDrivers(in context: GraphicsContext, size: CGSize) {
        guard let viewModel = viewModel else { return }
        
        let zoom = appEnvironment.settingsStore.trackMapZoom
        
        for position in viewModel.driverPositions {
            let point = viewModel.normalizedPosition(for: position, in: size)
            
            // Skip off-track cars
            guard position.isOnTrack else { continue }
            
            // Driver dot
            let dotSize: CGFloat = 12 * zoom
            context.fill(
                Circle().path(in: CGRect(
                    x: point.x - dotSize/2,
                    y: point.y - dotSize/2,
                    width: dotSize,
                    height: dotSize
                )),
                with: .color(position.color)
            )
            
            // Driver number
            let isFavorite = appEnvironment.settingsStore.isFavoriteDriver(position.racingNumber)
            
            if zoom > 0.8 || isFavorite {
                context.draw(
                    Text(position.driver.tla)
                        .font(.system(size: 10 * zoom, weight: .bold))
                        .foregroundStyle(.white),
                    at: point
                )
            }
            
            // Highlight favorites
            if isFavorite {
                context.stroke(
                    Circle().path(in: CGRect(
                        x: point.x - dotSize/2 - 2,
                        y: point.y - dotSize/2 - 2,
                        width: dotSize + 4,
                        height: dotSize + 4
                    )),
                    with: .color(.yellow),
                    lineWidth: 2
                )
            }
        }
    }
}

// MARK: - Minimap View

struct TrackMapMiniView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    @State private var viewModel: TrackMapViewModel?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(nsColor: .controlBackgroundColor)
                
                if viewModel?.driverPositions.isEmpty == false {
                    Canvas { context, size in
                        drawMinimap(in: context, size: size)
                    }
                } else {
                    Image(systemName: "map")
                        .font(.title2)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onAppear {
            viewModel = TrackMapViewModel(appEnvironment: appEnvironment)
        }
    }
    
    private func drawMinimap(in context: GraphicsContext, size: CGSize) {
        guard let viewModel = viewModel else { return }
        
        for position in viewModel.driverPositions where position.isOnTrack {
            let point = viewModel.normalizedPosition(for: position, in: size)
            
            // Smaller dots for minimap
            let dotSize: CGFloat = 6
            context.fill(
                Circle().path(in: CGRect(
                    x: point.x - dotSize/2,
                    y: point.y - dotSize/2,
                    width: dotSize,
                    height: dotSize
                )),
                with: .color(position.color)
            )
        }
    }
}

#Preview("Full Track Map") {
    TrackMapView()
        .environment(AppEnvironment())
        .frame(height: 400)
}

#Preview("Mini Track Map") {
    TrackMapMiniView()
        .environment(AppEnvironment())
        .frame(width: 200, height: 150)
        .padding()
}
