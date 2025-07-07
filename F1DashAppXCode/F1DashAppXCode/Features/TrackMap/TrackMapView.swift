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
    @State private var showDriversList = false
    @State private var selectedDriver: String?
    
    var body: some View {
        Group {
            #if os(macOS)
            // macOS version with sidebar
            HStack(spacing: 0) {
                DriverListSidebar()
                    .frame(width: 300)
                    .background(.regularMaterial)
                
                GeometryReader { geometry in
                    ZStack {
                        Color.platformBackground
                        
                        if let viewModel = viewModel, viewModel.hasMapData {
                            Canvas { context, size in
                                drawTrack(in: context, size: size)
                                drawSectors(in: context, size: size)
                                drawFinishLine(in: context, size: size)
                                drawCorners(in: context, size: size)
                                drawDrivers(in: context, size: size)
                            }
                            .padding()
                            
                            // PiP/Live Activity button overlay
                            VStack {
                                HStack {
                                    Spacer()
                                    #if os(macOS)
                                    Button {
                                        appEnvironment.pictureInPictureManager.togglePiP()
                                    } label: {
                                        Label(
                                            appEnvironment.pictureInPictureManager.isPiPActive ? "Exit Picture in Picture" : "Picture in Picture",
                                            systemImage: appEnvironment.pictureInPictureManager.isPiPActive ? "pip.exit" : "pip.enter"
                                        )
                                    }
                                    .buttonStyle(.bordered)
                                    .padding()
                                    #else
                                    VStack(spacing: 8) {
                                        // System PiP button
                                        Button {
                                            if appEnvironment.systemPictureInPictureManager?.isSystemPiPActive == true {
                                                appEnvironment.systemPictureInPictureManager?.stopSystemPiP()
                                            } else {
                                                appEnvironment.systemPictureInPictureManager?.startSystemPiP()
                                            }
                                        } label: {
                                            Label(
                                                appEnvironment.systemPictureInPictureManager?.isSystemPiPActive == true ? "Exit Picture in Picture" : "Picture in Picture",
                                                systemImage: appEnvironment.systemPictureInPictureManager?.isSystemPiPActive == true ? "pip.exit" : "pip.enter"
                                            )
                                        }
                                        .buttonStyle(.borderedProminent)
                                        
                                        // Live Activity button
                                        Button {
                                            Task {
                                                if appEnvironment.liveActivityManager?.isLiveActivityActive == true {
                                                    await appEnvironment.liveActivityManager?.endLiveActivity()
                                                } else {
                                                    await appEnvironment.liveActivityManager?.startLiveActivity()
                                                }
                                            }
                                        } label: {
                                            Label(
                                                appEnvironment.liveActivityManager?.isLiveActivityActive == true ? "End Live Activity" : "Start Live Activity",
                                                systemImage: appEnvironment.liveActivityManager?.isLiveActivityActive == true ? "livephoto.slash" : "livephoto"
                                            )
                                        }
                                        .buttonStyle(.bordered)
                                    }
                                    .padding()
                                    #endif
                                }
                                Spacer()
                            }
                        } else {
                            ProgressView("Loading track map...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
            }
            #else
            // iOS version - mobile optimized
            NavigationStack {
                VStack(spacing: 0) {
                    // iOS Track Map Container
                    ZStack {
                        Color.platformBackground
                        
                        if let viewModel = viewModel, viewModel.hasMapData {
                            GeometryReader { geometry in
                                Canvas { context, size in
                                    drawTrack(in: context, size: size)
                                    drawSectors(in: context, size: size)
                                    drawFinishLine(in: context, size: size)
                                    drawCorners(in: context, size: size)
                                    drawDrivers(in: context, size: size)
                                }
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                .padding()
                            }
                            
                            // iOS-specific overlay controls
                            VStack {
                                HStack {
                                    // Map controls top-left
                                    VStack(spacing: 8) {
                                        Button {
                                            withAnimation(.spring()) {
                                                showDriversList.toggle()
                                            }
                                        } label: {
                                            Image(systemName: "list.bullet")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundStyle(.primary)
                                                .frame(width: 44, height: 44)
                                                .background(.ultraThinMaterial)
                                                .clipShape(Circle())
                                        }
                                        
                                        Button {
                                            // Zoom to fit functionality
                                        } label: {
                                            Image(systemName: "scope")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundStyle(.primary)
                                                .frame(width: 44, height: 44)
                                                .background(.ultraThinMaterial)
                                                .clipShape(Circle())
                                        }
                                    }
                                    .padding(.leading)
                                    
                                    Spacer()
                                    
                                    // Session info top-right
                                    VStack(alignment: .trailing, spacing: 4) {
                                        if let sessionInfo = appEnvironment.liveSessionState.sessionInfo,
                                           let sessionType = sessionInfo.type {
                                            Text(sessionType)
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(.primary)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .padding(.trailing)
                                }
                                
                                Spacer()
                                
                                // Bottom info panel
                                if let selectedDriver = selectedDriver,
                                   let driver = appEnvironment.liveSessionState.driverList[selectedDriver] {
                                    iOSDriverInfoPanel(driver: driver)
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                            }
                            
                        } else {
                            // iOS Loading state
                            VStack(spacing: 16) {
                                ProgressView()
                                    .controlSize(.large)
                                
                                Text("Loading track map...")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .sheet(isPresented: $showDriversList) {
                        iOSDriversSheet(selectedDriver: $selectedDriver)
                    }
                }
                .navigationTitle("Track Map")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        // Picture in Picture button
                        Button {
                            appEnvironment.pictureInPictureManager.togglePiP()
                        } label: {
                            Image(systemName: appEnvironment.pictureInPictureManager.isPiPActive ? "pip.exit" : "pip.enter")
                        }
                        
                        Button {
                            showDriversList = true
                        } label: {
                            Image(systemName: "person.3")
                        }
                    }
                }
            }
            #endif
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
        
        #if os(macOS)
        let trackWidth: CGFloat = 20
        #else
        // Thicker track for better mobile visibility
        let trackWidth: CGFloat = 24
        #endif
        
        // Draw track shadow for depth (iOS)
        #if !os(macOS)
        context.stroke(
            path,
            with: .color(.black.opacity(0.1)),
            style: StrokeStyle(lineWidth: trackWidth + 4, lineCap: .round, lineJoin: .round)
        )
        #endif
        
        // Draw track base
        context.stroke(
            path,
            with: .color(.secondary.opacity(0.7)),
            style: StrokeStyle(lineWidth: trackWidth, lineCap: .round, lineJoin: .round)
        )
        
        // Draw track center line for mobile clarity
        #if !os(macOS)
        context.stroke(
            path,
            with: .color(.white.opacity(0.3)),
            style: StrokeStyle(
                lineWidth: 2,
                lineCap: .round,
                lineJoin: .round,
                dash: [5, 5]
            )
        )
        #endif
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
        #if os(macOS)
        let dotSize: CGFloat = 8
        let fontSize: CGFloat = 10
        #else
        // Larger touch targets for iOS
        let dotSize: CGFloat = 12
        let fontSize: CGFloat = 12
        #endif
        
        let dotRect = CGRect(
            x: position.point.x - dotSize/2,
            y: position.point.y - dotSize/2,
            width: dotSize,
            height: dotSize
        )
        
        // Shadow for depth (iOS enhancement)
        #if !os(macOS)
        context.fill(
            Circle().path(in: CGRect(
                x: dotRect.minX + 1,
                y: dotRect.minY + 1,
                width: dotRect.width,
                height: dotRect.height
            )),
            with: .color(.black.opacity(0.2))
        )
        #endif
        
        // Driver dot with enhanced styling
        context.fill(
            Circle().path(in: dotRect),
            with: .color(position.color)
        )
        
        // White border for better visibility
        context.stroke(
            Circle().path(in: dotRect),
            with: .color(.white),
            lineWidth: 1.5
        )
        
        // Driver TLA with background for readability
        let textPosition = CGPoint(
            x: position.point.x + (dotSize/2) + 8,
            y: position.point.y
        )
        
        #if !os(macOS)
        // Text background for iOS
        let textSize = CGSize(width: 30, height: 16)
        let textRect = CGRect(
            x: textPosition.x - 2,
            y: textPosition.y - textSize.height/2,
            width: textSize.width,
            height: textSize.height
        )
        
        context.fill(
            RoundedRectangle(cornerRadius: 4).path(in: textRect),
            with: .color(.black.opacity(0.7))
        )
        #endif
        
        context.draw(
            Text(position.tla)
                .font(.system(size: fontSize, weight: .bold))
                .foregroundStyle(.white),
            at: textPosition
        )
        
        // Enhanced favorite driver highlight
        if position.isFavorite {
            let highlightRect = CGRect(
                x: dotRect.minX - 4,
                y: dotRect.minY - 4,
                width: dotRect.width + 8,
                height: dotRect.height + 8
            )
            
            context.stroke(
                Circle().path(in: highlightRect),
                with: .color(.yellow),
                lineWidth: 2.5
            )
            
            // Animated pulse effect for iOS
            #if !os(macOS)
            context.stroke(
                Circle().path(in: CGRect(
                    x: highlightRect.minX - 2,
                    y: highlightRect.minY - 2,
                    width: highlightRect.width + 4,
                    height: highlightRect.height + 4
                )),
                with: .color(.yellow.opacity(0.3)),
                lineWidth: 1
            )
            #endif
        }
        
        // Enhanced pit state visualization
        if position.isInPit {
            // Gray overlay
            context.fill(
                Circle().path(in: dotRect),
                with: .color(.gray.opacity(0.6))
            )
            
            // Pit icon
            context.draw(
                Text("P")
                    .font(.system(size: fontSize - 2, weight: .bold))
                    .foregroundStyle(.white),
                at: position.point
            )
        }
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

// MARK: - iOS Specific Components

#if !os(macOS)

struct iOSDriverInfoPanel: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    let driver: Driver
    
    var body: some View {
        VStack(spacing: 12) {
            // Driver header
            HStack {
                // Team color strip
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: driver.teamColour) ?? .gray)
                    .frame(width: 4, height: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(driver.tla)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text(driver.broadcastName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    // Close panel
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                }
            }
            
            // Driver stats
            if let timingData = appEnvironment.liveSessionState.timingData,
               let driverTiming = timingData.lines[driver.racingNumber] {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Position")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(driverTiming.line)")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Last Lap")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(driverTiming.lastLapTime.value.isEmpty ? "--:--" : driverTiming.lastLapTime.value)
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Best Lap")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(driverTiming.bestLapTime.value.isEmpty ? "--:--" : driverTiming.bestLapTime.value)
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
    }
}

struct iOSDriversSheet: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    @Binding var selectedDriver: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 1) {
                    if !appEnvironment.liveSessionState.driverList.isEmpty,
                       let timingData = appEnvironment.liveSessionState.timingData {
                        let drivers = appEnvironment.liveSessionState.driverList
                        ForEach(sortedDrivers(drivers: drivers, timingData: timingData), id: \.racingNumber) { driver in
                            iOSDriverRowView(driver: driver, selectedDriver: $selectedDriver)
                                .onTapGesture {
                                    selectedDriver = driver.racingNumber
                                    dismiss()
                                }
                        }
                    } else {
                        ForEach(0..<20, id: \.self) { _ in
                            TrackMapSkeletonDriverRow()
                        }
                    }
                }
            }
            .navigationTitle("Drivers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func sortedDrivers(drivers: [String: Driver], timingData: TimingData) -> [Driver] {
        return drivers.values.sorted { driver1, driver2 in
            let pos1 = driver1.line
            let pos2 = driver2.line
            return pos1 < pos2
        }
    }
}

struct iOSDriverRowView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    let driver: Driver
    @Binding var selectedDriver: String?
    
    private var isSelected: Bool {
        selectedDriver == driver.racingNumber
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Position
            if let timingData = appEnvironment.liveSessionState.timingData,
               let driverTiming = timingData.lines[driver.racingNumber] {
                Text("\(driverTiming.line)")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .frame(width: 40, alignment: .center)
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            
            // Driver info
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color(hex: driver.teamColour) ?? .gray)
                    .frame(width: 4, height: 44)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(driver.tla)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(isSelected ? .white : .primary)
                    
                    Text(driver.broadcastName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Timing data
            if let timingData = appEnvironment.liveSessionState.timingData,
               let driverTiming = timingData.lines[driver.racingNumber] {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(driverTiming.lastLapTime.value.isEmpty ? "--:--" : driverTiming.lastLapTime.value)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(isSelected ? .white : .primary)
                    
                    let gap = driverTiming.gapToLeader
                    if !gap.isEmpty {
                        Text(gap)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(isSelected ? .white.opacity(0.7) : .secondary)
                    }
                }
            }
            
            // Selection indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            isSelected ? 
            (Color(hex: driver.teamColour) ?? .blue) : 
            (appEnvironment.settingsStore.isFavoriteDriver(driver.racingNumber) ? 
             Color.blue.opacity(0.1) : Color.clear)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 4)
    }
}

#endif

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
