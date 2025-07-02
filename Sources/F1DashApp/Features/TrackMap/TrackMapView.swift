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
        HStack(spacing: 0) {
            // Driver list sidebar (like TypeScript version)
            DriverListSidebar()
                .frame(width: 300)
                .background(.regularMaterial)
            
            // Main map view
            GeometryReader { geometry in
                ZStack {
                    // Background
                    Color.platformBackground
                    
                    if let viewModel = viewModel, viewModel.hasMapData {
                        // Track map canvas
                        Canvas { context, size in
                            drawTrack(in: context, size: size)
                            drawSectors(in: context, size: size)
                            drawFinishLine(in: context, size: size)
                            drawCorners(in: context, size: size)
                            drawDrivers(in: context, size: size)
                        }
                        .padding()
                    } else {
                        // Loading state
                        ProgressView("Loading track map...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
        .onAppear {
            viewModel = TrackMapViewModel(appEnvironment: appEnvironment)
        }
    }
    
    // MARK: - Drawing
    
    private func drawTrack(in context: GraphicsContext, size: CGSize) {
        guard let viewModel = viewModel,
              viewModel.trackMap != nil else { return }
        
        // Draw main track outline
        var path = Path()
        let rotatedPoints = viewModel.getRotatedTrackPoints(for: size)
        
        if let firstPoint = rotatedPoints.first {
            path.move(to: firstPoint)
            for point in rotatedPoints.dropFirst() {
                path.addLine(to: point)
            }
            path.closeSubpath()
        }
        
        // Draw track base
        context.stroke(
            path,
            with: .color(.secondary.opacity(0.6)),
            style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round)
        )
    }
    
    private func drawSectors(in context: GraphicsContext, size: CGSize) {
        guard let viewModel = viewModel else { return }
        
        let sectors = viewModel.getRenderedSectors(for: size)
        
        for sector in sectors {
            var path = Path()
            if let firstPoint = sector.points.first {
                path.move(to: firstPoint)
                for point in sector.points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            
            context.stroke(
                path,
                with: .color(sector.color),
                style: StrokeStyle(
                    lineWidth: sector.strokeWidth,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }
    }
    
    private func drawFinishLine(in context: GraphicsContext, size: CGSize) {
        guard let viewModel = viewModel,
              let finishLine = viewModel.getFinishLine(for: size) else { return }
        
        let lineRect = CGRect(
            x: finishLine.x - 5,
            y: finishLine.y - 10,
            width: 10,
            height: 20
        )
        
        context.fill(
            Path(lineRect),
            with: .color(.red)
        )
    }
    
    private func drawCorners(in context: GraphicsContext, size: CGSize) {
        guard let viewModel = viewModel,
              appEnvironment.settingsStore.showCornerNumbers else { return }
        
        let corners = viewModel.getCornerPositions(for: size)
        
        for corner in corners {
            context.draw(
                Text("\(corner.number)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary),
                at: corner.position
            )
        }
    }
    
    private func drawDrivers(in context: GraphicsContext, size: CGSize) {
        guard let viewModel = viewModel else { return }
        
        let driverPositions = viewModel.getDriverPositions(for: size)
        
        // Draw safety cars first (behind drivers)
        for position in driverPositions where position.isSafetyCar {
            drawDriverDot(context: context, position: position, size: size)
        }
        
        // Draw regular drivers
        for position in driverPositions where !position.isSafetyCar && position.isOnTrack {
            drawDriverDot(context: context, position: position, size: size)
        }
    }
    
    private func drawDriverDot(context: GraphicsContext, position: DriverMapPosition, size: CGSize) {
        let dotSize: CGFloat = 8
        let dotRect = CGRect(
            x: position.point.x - dotSize/2,
            y: position.point.y - dotSize/2,
            width: dotSize,
            height: dotSize
        )
        
        // Driver dot
        context.fill(
            Circle().path(in: dotRect),
            with: .color(position.color)
        )
        
        // Driver TLA
        context.draw(
            Text(position.tla)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white),
            at: CGPoint(x: position.point.x + 15, y: position.point.y - 8)
        )
        
        // Favorite driver highlight
        if position.isFavorite {
            context.stroke(
                Circle().path(in: CGRect(
                    x: dotRect.minX - 3,
                    y: dotRect.minY - 3,
                    width: dotRect.width + 6,
                    height: dotRect.height + 6
                )),
                with: .color(.blue),
                lineWidth: 2
            )
        }
        
        // Pit/hidden state
        if position.isInPit {
            context.fill(
                Circle().path(in: dotRect),
                with: .color(.gray.opacity(0.5))
            )
        }
        
        // Hidden drivers handled in color above
    }
}

// MARK: - Driver List Sidebar

struct DriverListSidebar: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Drivers")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding()
            .background(.regularMaterial)
            
            // Driver list
            ScrollView {
                LazyVStack(spacing: 1) {
                    if !appEnvironment.liveSessionState.driverList.isEmpty,
                       let timingData = appEnvironment.liveSessionState.timingData {
                        let drivers = appEnvironment.liveSessionState.driverList
                        ForEach(sortedDrivers(drivers: drivers, timingData: timingData), id: \.racingNumber) { driver in
                            TrackMapDriverRowView(driver: driver)
                        }
                    } else {
                        ForEach(0..<20, id: \.self) { _ in
                            TrackMapSkeletonDriverRow()
                        }
                    }
                }
            }
        }
    }
    
    private func sortedDrivers(drivers: [String: Driver], timingData: TimingData) -> [Driver] {
        return drivers.values.sorted { driver1, driver2 in
            let pos1 = driver1.line
            let pos2 = driver2.line
            return pos1 < pos2
        }
    }
}

struct TrackMapDriverRowView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    let driver: Driver
    
    var body: some View {
        HStack(spacing: 8) {
            // Position
            if let timingData = appEnvironment.liveSessionState.timingData,
               let driverTiming = timingData.lines[driver.racingNumber] {
                Text("\(driverTiming.line)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .frame(width: 30, alignment: .trailing)
            }
            
            // Driver tag
            HStack(spacing: 4) {
                Rectangle()
                    .fill(Color(hex: driver.teamColour) ?? .gray)
                    .frame(width: 4, height: 24)
                
                Text(driver.tla)
                    .font(.system(size: 12, weight: .bold))
                    .frame(width: 30)
            }
            
            // DRS status
            TrackMapDRSIndicator(driver: driver)
                .frame(width: 30)
            
            // Gap/Interval
            if let timingData = appEnvironment.liveSessionState.timingData,
               let driverTiming = timingData.lines[driver.racingNumber] {
                VStack(alignment: .leading, spacing: 2) {
                    let gapToLeader = driverTiming.gapToLeader
                    if !gapToLeader.isEmpty {
                        Text(gapToLeader)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    if let interval = driverTiming.intervalToPositionAhead?.value, !interval.isEmpty {
                        Text(interval)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                    }
                }
                .frame(width: 60, alignment: .leading)
            }
            
            // Lap times
            VStack(alignment: .trailing, spacing: 2) {
                if let timingData = appEnvironment.liveSessionState.timingData,
                   let driverTiming = timingData.lines[driver.racingNumber] {
                    let lastLap = driverTiming.lastLapTime.value
                    if !lastLap.isEmpty {
                        Text(lastLap)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    let bestLap = driverTiming.bestLapTime.value
                    if !bestLap.isEmpty {
                        Text(bestLap)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                    }
                }
            }
            .frame(width: 80, alignment: .trailing)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            appEnvironment.settingsStore.isFavoriteDriver(driver.racingNumber) ?
            Color.blue.opacity(0.1) : Color.clear
        )
    }
}

struct TrackMapDRSIndicator: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    let driver: Driver
    
    var body: some View {
        if let carData = appEnvironment.liveSessionState.carData,
           let driverCarData = carData.entries.last?.cars[driver.racingNumber] {
            let drsValue = driverCarData.drs
            
            if drsValue > 9 {
                Text("DRS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.green)
            } else if drsValue == 8 {
                Text("DRS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.yellow)
            } else {
                Text("---")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        } else {
            Text("---")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }
}

struct TrackMapSkeletonDriverRow: View {
    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .fill(.tertiary)
                .frame(width: 30, height: 20)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(.tertiary)
                .frame(width: 50, height: 20)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(.tertiary)
                .frame(width: 30, height: 20)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(.tertiary)
                .frame(width: 60, height: 20)
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 4)
                .fill(.tertiary)
                .frame(width: 80, height: 20)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .opacity(0.6)
    }
}

// MARK: - Minimap View

struct TrackMapMiniView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    @State private var viewModel: TrackMapViewModel?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.platformBackground
                
                if let viewModel = viewModel, viewModel.hasMapData {
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
        
        let driverPositions = viewModel.getDriverPositions(for: size)
        
        for position in driverPositions where position.isOnTrack {
            let dotSize: CGFloat = 4
            context.fill(
                Circle().path(in: CGRect(
                    x: position.point.x - dotSize/2,
                    y: position.point.y - dotSize/2,
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
