//
//  OptimizedTrackMapView.swift
//  F1-Dash
//
//  Performance-optimized track map with layer caching
//

import F1DashModels
import SwiftUI
import Combine

// MARK: - Track Map View Model

@MainActor
@Observable
final class OptimizedTrackMapViewModel {
  private let liveSessionState: OptimizedLiveSessionState
  private let settingsStore: SettingsStore
  private let mapService = MapService()

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

  // Constants
  private let space: Double = 1000
  private let rotationFix: Double = 90

  init(liveSessionState: OptimizedLiveSessionState, settingsStore: SettingsStore) {
    self.liveSessionState = liveSessionState
    self.settingsStore = settingsStore
    loadTrackMap()
  }

  func loadTrackMap() {
    Task {
      guard let circuitKey = liveSessionState.sessionInfo?.meeting?.circuit.key else {
        print("🔴 TrackMap: No circuit key available")
        return
      }

      print("🟢 TrackMap: Loading track map for circuit: \(circuitKey)")
      do {
        let map = try await mapService.fetchMap(for: circuitKey)
        await MainActor.run {
          self.trackMap = map
          self.processMapData()
          self.hasMapData = true
          print("🟢 TrackMap: Track map loaded successfully, hasMapData: \(self.hasMapData)")
        }
      } catch {
        print("🔴 TrackMap: Failed to load track map: \(error)")
        self.loadingError = "Failed to load track map"
      }
    }
  }

  private func processMapData() {
    guard let map = trackMap else { return }

    // Calculate center as the actual midpoint of coordinates
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

    let xValues = rotatedPoints.map { $0.x }
    let yValues = rotatedPoints.map { $0.y }

    let minX = xValues.min()! - space
    let maxX = xValues.max()! + space
    let minY = yValues.min()! - space
    let maxY = yValues.max()! + space

    self.minX = minX
    self.maxX = maxX
    self.minY = minY
    self.maxY = maxY
  }

  func normalizedPosition(for position: TrackPosition, in size: CGSize) -> CGPoint {
    let normalizedX = (position.x - minX) / (maxX - minX)
    let normalizedY = 1.0 - (position.y - minY) / (maxY - minY)  // Flip Y axis

    return CGPoint(
      x: normalizedX * size.width,
      y: normalizedY * size.height
    )
  }

  var driverPositions: [(driver: Driver, position: PositionCar)] {
    // Always get fresh data - caching is handled by OptimizedLiveSessionState
    let drivers = liveSessionState.driverList
    let positionData = liveSessionState.positionData

    // Get the latest position entry
    guard let latestPositions = positionData?.position?.last else {
      print("🔴 TrackMap: No position data available")
      return []
    }

    let positions: [(driver: Driver, position: PositionCar)] = drivers.compactMap {
      (_, driver) -> (driver: Driver, position: PositionCar)? in
      guard let position = latestPositions.entries[driver.racingNumber] else {
        return nil
      }
      // Skip positions at (0,0) which indicate off-track
      guard position.x != 0 || position.y != 0 else {
        return nil
      }
      return (driver, position)
    }.sorted { (a, b) in a.driver.line < b.driver.line }

    print("🟢 TrackMap: Found \(positions.count) driver positions from \(latestPositions.timestamp)")
    return positions
  }

  var sessionInfo: SessionInfo? {
    liveSessionState.sessionInfo
  }
}

// MARK: - Optimized Track Map View

struct OptimizedTrackMapView: View {
  @Environment(OptimizedAppEnvironment.self) private var appEnvironment
  @State private var trackViewModel: OptimizedTrackMapViewModel?

  private let circuitKey: String

  init(circuitKey: String) {
    self.circuitKey = circuitKey
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        // Premium gradient background
        LinearGradient(
          colors: [
            Color(red: 0.05, green: 0.05, blue: 0.1),
            Color(red: 0.02, green: 0.02, blue: 0.05),
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )

        // Subtle grid pattern overlay
        Canvas { context, size in
          let gridSize: CGFloat = 50
          let gridColor = Color.white.opacity(0.03)

          // Vertical lines
          for x in stride(from: 0, through: size.width, by: gridSize) {
            var path = Path()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
            context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
          }

          // Horizontal lines
          for y in stride(from: 0, through: size.height, by: gridSize) {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
          }
        }

        if let viewModel = trackViewModel, viewModel.hasMapData {
          let _ = print(
            "🟠 OptimizedTrackMapView: Rendering track layers, hasMapData: \(viewModel.hasMapData)")

          // Static track layer with real track data
          StaticTrackLayer(
            viewModel: viewModel,
            size: geometry.size
          )

          // Dynamic driver positions layer
          // Access positionData to trigger updates
          let posData = appEnvironment.liveSessionState.positionData
          let _ = print("🟠 OptimizedTrackMapView: Position data available: \(posData != nil)")
          DynamicDriverLayer(
            viewModel: viewModel,
            size: geometry.size
          )

          // Reload button overlay
          VStack {
            HStack {
              Spacer()
              Button {
                trackViewModel?.loadTrackMap()
              } label: {
                ZStack {
                  Circle()
                    .fill(Color(white: 0.15).opacity(0.9))
                    .frame(width: 40, height: 40)

                  Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    .frame(width: 40, height: 40)

                  Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
                }
              }
              .buttonStyle(.plain)
              .padding()
            }
            Spacer()
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
    .onAppear {
      if trackViewModel == nil {
        trackViewModel = OptimizedTrackMapViewModel(
          liveSessionState: appEnvironment.liveSessionState,
          settingsStore: appEnvironment.settingsStore
        )
      }
    }
    .onChange(of: circuitKey) { _, newValue in
      // Reload map if circuit changes
      trackViewModel?.loadTrackMap()
    }
    // .onChange(of: appEnvironment.connectionStatus) { oldStatus, newStatus in
    //   print("🔶 OptimizedTrackMapView: Connection status changed from \(oldStatus) to \(newStatus)")
    //   // No need to recreate view model anymore - liveSessionState is now stable
    // }
  }
}

// MARK: - Static Track Layer

struct StaticTrackLayer: View {
  let viewModel: OptimizedTrackMapViewModel
  let size: CGSize
  @Environment(OptimizedAppEnvironment.self) private var appEnvironment

  @State private var renderedImage: Image?
  @State private var renderTask: Task<Void, Never>?
  @State private var isViewActive = true

  var body: some View {
    Group {
      if let renderedImage = renderedImage {
        renderedImage
          .resizable()
          .aspectRatio(contentMode: .fit)
      } else {
        Canvas { context, _ in
          drawTrack(in: context, size: size)
          drawSectors(in: context, size: size)
          drawFinishLine(in: context, size: size)
          if appEnvironment.settingsStore.showCornerNumbers {
            drawCorners(in: context, size: size)
          }
        }
        .onAppear {
          isViewActive = true
          renderToImage()
        }
        .onDisappear {
          // Cancel rendering task if view disappears
          isViewActive = false
          renderTask?.cancel()
          renderTask = nil
          // Clear the rendered image to free Metal resources
          renderedImage = nil
        }
      }
    }
    .onChange(of: size) { (_, newSize) in
      // Re-render on any size change
      renderedImage = nil
      renderTask?.cancel()
      if isViewActive {
        renderToImage()
      }
    }
  }

  private func renderToImage() {
    // Cancel any existing render task
    renderTask?.cancel()

    // Don't start new rendering if view is not active
    guard isViewActive else { return }

    // Defer rendering to avoid Metal resource conflicts
    renderTask = Task { @MainActor in
      // Small delay to ensure Metal resources are ready
      try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 seconds

      // Check if task was cancelled or view is no longer active
      if Task.isCancelled || !isViewActive { return }

      // Create a separate view for rendering to avoid Metal conflicts
      let content = Canvas { context, _ in
        drawTrack(in: context, size: size)
        drawSectors(in: context, size: size)
        drawFinishLine(in: context, size: size)
        if appEnvironment.settingsStore.showCornerNumbers {
          drawCorners(in: context, size: size)
        }
      }
      .frame(width: size.width, height: size.height)
      .background(Color.clear)

      // Check again before creating renderer
      if Task.isCancelled || !isViewActive { return }

      // Render track to image once for caching
      let renderer = ImageRenderer(content: content)

      // Set explicit scale to avoid issues
      renderer.scale = 2.0

      // Perform the actual rendering in an autoreleasepool to ensure proper cleanup
      autoreleasepool {
        #if os(iOS)
          if let uiImage = renderer.uiImage {
            if !Task.isCancelled && isViewActive {
              renderedImage = Image(uiImage: uiImage)
            }
          }
        #elseif os(macOS)
          if let nsImage = renderer.nsImage {
            if !Task.isCancelled && isViewActive {
              renderedImage = Image(nsImage: nsImage)
            }
          }
        #endif
      }
    }
  }

  private func drawTrack(in context: GraphicsContext, size: CGSize) {
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

    #if os(macOS)
      let trackWidth: CGFloat = 20
    #else
      let trackWidth: CGFloat = 24
    #endif

    // Draw track glow effect
    context.stroke(
      path,
      with: .color(Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.2)),
      style: StrokeStyle(lineWidth: trackWidth + 12, lineCap: .round, lineJoin: .round)
    )

    // Draw track shadow for depth
    context.stroke(
      path,
      with: .color(.black.opacity(0.4)),
      style: StrokeStyle(lineWidth: trackWidth + 6, lineCap: .round, lineJoin: .round)
    )

    // Draw track base with gradient effect
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

    // Draw track surface texture (center line)
    context.stroke(
      path,
      with: .color(Color(white: 0.45).opacity(0.3)),
      style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [10, 5])
    )
  }

  private func drawSectors(in context: GraphicsContext, size: CGSize) {
    let trackStatus = appEnvironment.liveSessionState.trackStatus
    let raceControlMessages = appEnvironment.liveSessionState.raceControlMessages

    // Find yellow sectors from race control messages
    let yellowSectors = findYellowSectors(from: raceControlMessages)

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

      let color = getSectorColor(
        sector: sector,
        yellowSectors: yellowSectors,
        trackStatus: trackStatus
      )

      context.stroke(
        path,
        with: .color(color),
        style: StrokeStyle(
          lineWidth: color == .secondary ? 4 : 8,
          lineCap: .round,
          lineJoin: .round
        )
      )
    }
  }

  private func findYellowSectors(from messages: RaceControlMessages?) -> Set<Int> {
    guard let messages = messages?.messages else { return Set() }

    var yellowSectors = Set<Int>()
    let yellowMessages = messages.filter { $0.flag == .yellow }

    for message in yellowMessages {
      if message.scope == .track {
        // Track-wide yellow
        return Set(1...20)
      } else if message.scope == .sector, let sector = message.sector {
        yellowSectors.insert(sector)
      }
    }

    return yellowSectors
  }

  private func getSectorColor(sector: MapSector, yellowSectors: Set<Int>, trackStatus: TrackStatus?)
    -> Color
  {
    if yellowSectors.contains(sector.number) {
      return Color(red: 1.0, green: 0.8, blue: 0.0)  // Vibrant yellow
    }

    if let status = trackStatus?.status {
      switch status {
      case .green: return Color(red: 0.0, green: 0.9, blue: 0.2)  // Bright green
      case .yellow, .scYellow: return Color(red: 1.0, green: 0.8, blue: 0.0)  // Vibrant yellow
      case .red, .scRed: return Color(red: 1.0, green: 0.2, blue: 0.2)  // Bright red
      default: break
      }
    }

    return Color(white: 0.6).opacity(0.5)  // Subtle default
  }

  private func drawFinishLine(in context: GraphicsContext, size: CGSize) {
    guard let finishLine = viewModel.finishLinePosition else { return }

    let point = viewModel.normalizedPosition(for: finishLine, in: size)
    let lineRect = CGRect(
      x: point.x - 5,
      y: point.y - 10,
      width: 10,
      height: 20
    )

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

  private func drawCorners(in context: GraphicsContext, size: CGSize) {
    for corner in viewModel.rotatedCorners {
      let position = viewModel.normalizedPosition(for: corner.labelPosition, in: size)

      // Draw corner background
      let cornerRect = CGRect(
        x: position.x - 12,
        y: position.y - 10,
        width: 24,
        height: 20
      )

      context.fill(
        Path(roundedRect: cornerRect, cornerRadius: 4),
        with: .color(Color(white: 0.2).opacity(0.7))
      )

      context.stroke(
        Path(roundedRect: cornerRect, cornerRadius: 4),
        with: .color(Color.white.opacity(0.3)),
        lineWidth: 1
      )

      context.draw(
        Text("\(corner.number)")
          .font(.system(size: 11, weight: .bold, design: .rounded))
          .foregroundStyle(.white),
        at: position
      )
    }
  }
}

// MARK: - Animated Driver Marker

struct AnimatedDriverMarker: View {
  let driver: Driver
  let teamColor: Color
  let position: CGPoint
  let isOnTrack: Bool
  let isFavorite: Bool

  var body: some View {
    ZStack {
      // Outer glow for visibility
      Circle()
        .fill(teamColor.opacity(0.3))
        .frame(width: 24, height: 24)
        .blur(radius: 2)

      // Shadow for depth
      Circle()
        .fill(.black.opacity(0.5))
        .frame(width: 18, height: 18)
        .offset(x: 1, y: 1)
        .blur(radius: 1)

      // Team color circle with gradient
      Circle()
        .fill(
          LinearGradient(
            colors: [teamColor, teamColor.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
        .frame(width: 16, height: 16)

      // Inner highlight
      Circle()
        .fill(
          LinearGradient(
            colors: [Color.white.opacity(0.3), Color.clear],
            startPoint: .topLeading,
            endPoint: UnitPoint(x: 0.5, y: 0.5)
          )
        )
        .frame(width: 14, height: 14)

      // White border
      Circle()
        .stroke(.white, lineWidth: 1.5)
        .frame(width: 16, height: 16)

      // Driver number with shadow
      Text(driver.racingNumber)
        .font(.system(size: 9, weight: .bold, design: .rounded))
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)

      // Favorite indicator with animation
      if isFavorite {
        Circle()
          .stroke(
            LinearGradient(
              colors: [Color.blue, Color.cyan],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 2
          )
          .frame(width: 22, height: 22)
          .shadow(color: .blue.opacity(0.5), radius: 2)
      }
    }
    .position(position)
    .opacity(isOnTrack ? 1.0 : 0.3)
  }
}

// MARK: - Dynamic Driver Layer

struct DynamicDriverLayer: View {
  let viewModel: OptimizedTrackMapViewModel
  let size: CGSize
  @Environment(OptimizedAppEnvironment.self) private var appEnvironment

  // Track animated positions separately from actual data
  @State private var animatedPositions: [String: CGPoint] = [:]
  @State private var lastUpdateTimestamp: String = ""

  private var driverData: [(driver: Driver, position: PositionCar)] {
    // Force observation of updateCounter to ensure we get fresh data
    _ = appEnvironment.liveSessionState.updateCounter
    
    // Get data directly from environment to ensure proper observation
    let drivers = appEnvironment.liveSessionState.driverList
    let positionData = appEnvironment.liveSessionState.positionData

    guard let latestPositions = positionData?.position?.last else {
      print("🔴 DynamicDriverLayer: No position data available")
      return []
    }

    let result = drivers.compactMap { (_, driver) -> (driver: Driver, position: PositionCar)? in
      guard let position = latestPositions.entries[driver.racingNumber] else {
        return nil
      }
      guard position.x != 0 || position.y != 0 else {
        return nil
      }
      return (driver, position)
    }.sorted { (a, b) in a.driver.line < b.driver.line }
    
    print("🔵 DynamicDriverLayer: driverData computed - \(result.count) drivers with valid positions")
    return result
  }

  var body: some View {
    // Force view to update when any data changes in liveSessionState
    let currentDriverData = driverData
    let _ = print("🟡 DynamicDriverLayer: Rendering body with \(currentDriverData.count) drivers")

    ZStack {
      ForEach(currentDriverData, id: \.driver.racingNumber) { driver, position in
        let normalizedPos = getNormalizedPosition(for: position)
        let isOnTrack = position.status == "OnTrack"
        let animatedPos = animatedPositions[driver.racingNumber] ?? normalizedPos

        AnimatedDriverMarker(
          driver: driver,
          teamColor: Color(hex: driver.teamColour) ?? .gray,
          position: animatedPos,
          isOnTrack: isOnTrack,
          isFavorite: appEnvironment.settingsStore.isFavoriteDriver(driver.racingNumber)
        )
        .animation(.linear(duration: 0.8), value: animatedPositions[driver.racingNumber])
      }
    }
    .onAppear {
      // Set initial positions
      print("🔵 DynamicDriverLayer: onAppear")
      updateAnimatedPositions()
    }
    // Primary update mechanism: monitor liveSessionState updateCounter
    .onChange(of: appEnvironment.liveSessionState.updateCounter) { _, _ in
      print("🔵 DynamicDriverLayer: UpdateCounter changed, updating positions")
      updateAnimatedPositions()
    }
    // Clear cached positions on disconnect for fresh animations on reconnect
    .onChange(of: appEnvironment.connectionStatus) { _, newStatus in
      if newStatus != .connected {
        print("🟤 DynamicDriverLayer: Connection lost – clearing cached positions")
        animatedPositions.removeAll()
        lastUpdateTimestamp = ""
      }
    }
  }

  private func updateAnimatedPositions() {
    let currentDriverData = driverData
    print("🟣 DynamicDriverLayer: Updating animated positions for \(currentDriverData.count) drivers")
    print("🟣 DynamicDriverLayer: Position data available: \(appEnvironment.liveSessionState.positionData != nil)")
    print("🟣 DynamicDriverLayer: Position entries count: \(appEnvironment.liveSessionState.positionData?.position?.count ?? 0)")
    
    for (driver, position) in currentDriverData {
      let normalizedPos = getNormalizedPosition(for: position)
      animatedPositions[driver.racingNumber] = normalizedPos
      print("  - Driver \(driver.racingNumber): \(position.x),\(position.y) -> \(normalizedPos)")
    }
    print("🟣 DynamicDriverLayer: Total animated positions: \(animatedPositions.count)")
  }

  private func getNormalizedPosition(for position: PositionCar) -> CGPoint {
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

// MARK: - Lightweight Driver Marker

struct DriverMarkerView: View, Equatable {
  let driver: Driver
  let position: PositionCar

  static func == (lhs: DriverMarkerView, rhs: DriverMarkerView) -> Bool {
    lhs.driver.id == rhs.driver.id && lhs.position.x == rhs.position.x
      && lhs.position.y == rhs.position.y
  }

  var body: some View {
    ZStack {
      Circle()
        .fill(Color(hex: driver.teamColour) ?? .gray)
        .frame(width: 16, height: 16)

      Text(driver.racingNumber)
        .font(.system(size: 10, weight: .bold))
        .foregroundColor(.white)
    }
    .position(
      x: CGFloat(position.x) * 100,  // Scale based on parent size
      y: CGFloat(position.y) * 100
    )
  }
}

// MARK: - Supporting Types

struct RotatedCorner {
  let number: Int
  let position: TrackPosition
  let labelPosition: TrackPosition
}
