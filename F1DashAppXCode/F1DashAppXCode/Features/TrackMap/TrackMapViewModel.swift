//
//  TrackMapViewModel.swift
//  F1-Dash
//
//  View model for track map visualization
//

import SwiftUI
import Observation
import F1DashModels

@MainActor
@Observable
final class TrackMapViewModel {
    // MARK: - Properties
    
    private let appEnvironment: AppEnvironment
    private let mapService = MapService()
    // Timer removed for now - updates are handled by data changes
    
    // Track data
    private(set) var trackMap: TrackMap?
    private(set) var sectors: [MapSector] = []
    private(set) var rotatedPoints: [TrackPosition] = []
    private(set) var rotatedCorners: [RotatedCorner] = []
    private(set) var finishLinePosition: TrackPosition?
    private(set) var loadingError: String?
    
    // Update tracker to force view refreshes
    private(set) var lastUpdateTime: Date = Date()
    
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
    
    var hasMapData: Bool {
        trackMap != nil
    }
    
    // MARK: - Initialization
    
    init(appEnvironment: AppEnvironment) {
        self.appEnvironment = appEnvironment
        startUpdating()
        loadTrackMap()
        
        // Retry loading when session info becomes available
        Task {
            for await _ in Timer.publish(every: 5, on: .main, in: .default).autoconnect().values {
                if trackMap == nil && appEnvironment.liveSessionState.sessionInfo != nil {
                    loadTrackMap()
                }
            }
        }
    }
    
    func retryLoading() {
        loadTrackMap()
    }
    
    // deinit not needed without timer
    
    // MARK: - Map Loading
    
    private func loadTrackMap() {
        Task {
            // Clear any previous error
            self.loadingError = nil
            
            guard let sessionInfo = appEnvironment.liveSessionState.sessionInfo else {
                self.loadingError = "Waiting for session data..."
                return
            }
            
            guard let circuitKey = sessionInfo.meeting?.circuit.key else {
                self.loadingError = "No circuit information available"
                return
            }
            
            do {
                let map = try await mapService.fetchMap(for: circuitKey)
                await MainActor.run {
                    self.trackMap = map
                    self.loadingError = nil
                    self.processMapData()
                }
            } catch {
                self.loadingError = "Failed to load track map"
                print("Failed to load map: \(error)")
            }
        }
    }
    
    private func processMapData() {
        guard let map = trackMap else { return }
        
        // Calculate center
        let xValues = map.x
        let yValues = map.y
        
        let originalCenterX = (xValues.max()! - xValues.min()!) / 2
        let originalCenterY = (yValues.max()! - yValues.min()!) / 2
        
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
            
            sectors.append(MapSector(
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
    
    // MARK: - Updates
    
    private func startUpdating() {
        // Observe changes in the live session state
        Task { @MainActor in
            // Re-load track map if circuit changes
            _ = withObservationTracking {
                appEnvironment.liveSessionState.sessionInfo?.meeting?.circuit.key
            } onChange: { [weak self] in
                Task { @MainActor [weak self] in
                    self?.loadTrackMap()
                }
            }
            
            // Track position data updates for real-time car movement
            _ = withObservationTracking {
                appEnvironment.liveSessionState.positionData
            } onChange: { [weak self] in
                Task { @MainActor [weak self] in
                    // Trigger view update by updating timestamp
                    self?.lastUpdateTime = Date()
                }
            }
            
            // Track status changes for sector colors
            _ = withObservationTracking {
                appEnvironment.liveSessionState.trackStatus
            } onChange: { [weak self] in
                Task { @MainActor [weak self] in
                    // Trigger view update by updating timestamp
                    self?.lastUpdateTime = Date()
                }
            }
            
            // Race control messages for yellow flags
            _ = withObservationTracking {
                appEnvironment.liveSessionState.raceControlMessages
            } onChange: { [weak self] in
                Task { @MainActor [weak self] in
                    // Trigger view update by updating timestamp
                    self?.lastUpdateTime = Date()
                }
            }
            
            // Timing data for pit/retirement status
            _ = withObservationTracking {
                appEnvironment.liveSessionState.timingData
            } onChange: { [weak self] in
                Task { @MainActor [weak self] in
                    // Trigger view update by updating timestamp
                    self?.lastUpdateTime = Date()
                }
            }
        }
    }
    
    // MARK: - Public Methods
    
    func getRotatedTrackPoints(for size: CGSize) -> [CGPoint] {
        return rotatedPoints.map { point in
            normalizedPosition(for: point, in: size)
        }
    }
    
    func getRenderedSectors(for size: CGSize) -> [RenderedSector] {
        let trackStatus = appEnvironment.liveSessionState.trackStatus
        let yellowSectors = findYellowSectors()
        
        return sectors.map { sector in
            let points = sector.points.map { point in
                normalizedPosition(for: point, in: size)
            }
            
            let color = getSectorColor(sector: sector, yellowSectors: yellowSectors, trackStatus: trackStatus)
            let strokeWidth: CGFloat = color == .secondary ? 4 : 8
            
            return RenderedSector(
                number: sector.number,
                points: points,
                color: color,
                strokeWidth: strokeWidth
            )
        }
    }
    
    func getFinishLine(for size: CGSize) -> CGPoint? {
        guard let finishLine = finishLinePosition else { return nil }
        return normalizedPosition(for: finishLine, in: size)
    }
    
    func getCornerPositions(for size: CGSize) -> [CornerPosition] {
        return rotatedCorners.map { corner in
            CornerPosition(
                number: corner.number,
                position: normalizedPosition(for: corner.labelPosition, in: size)
            )
        }
    }
    
    func getDriverPositions(for size: CGSize) -> [DriverMapPosition] {
        guard let positionData = appEnvironment.liveSessionState.positionData,
              let latestPosition = positionData.position.last else {
            return []
        }
        
        var positions: [DriverMapPosition] = []
        
        // Add safety cars
        for safetyCarNumber in ["241", "242", "243"] {
            if let carPos = latestPosition.entries[safetyCarNumber],
               carPos.z != 0 {
                let rotatedPos = TrackMap.rotate(
                    x: carPos.x, y: carPos.y,
                    angle: trackMap?.rotation ?? 0 + rotationFix,
                    centerX: centerX, centerY: centerY
                )
                
                let point = normalizedPosition(for: rotatedPos, in: size)
                let color: Color = safetyCarNumber == "243" ? Color(hex: "B90F09") ?? .red : Color(hex: "229971") ?? .green
                
                positions.append(DriverMapPosition(
                    racingNumber: safetyCarNumber,
                    tla: "SC",
                    point: point,
                    color: color,
                    isOnTrack: true,
                    isSafetyCar: true,
                    isInPit: false,
                    isHidden: false,
                    isFavorite: false
                ))
            }
        }
        
        // Add regular drivers
        for (racingNumber, carPos) in latestPosition.entries {
            guard let driver = appEnvironment.liveSessionState.driver(for: racingNumber),
                  !["-1", "241", "242", "243"].contains(racingNumber),
                  carPos.x != 0 && carPos.y != 0 else {
                continue
            }
            
            let rotatedPos = TrackMap.rotate(
                x: carPos.x, y: carPos.y,
                angle: trackMap?.rotation ?? 0 + rotationFix,
                centerX: centerX, centerY: centerY
            )
            
            let point = normalizedPosition(for: rotatedPos, in: size)
            
            // Get timing data for pit/retirement status
            let timingData = appEnvironment.liveSessionState.timingData
            _ = timingData?.lines[racingNumber]
            
            let isInPit = false // Not available in current TimingDataDriver
            let isHidden = false // Not available in current TimingDataDriver
            
            positions.append(DriverMapPosition(
                racingNumber: racingNumber,
                tla: driver.tla,
                point: point,
                color: Color(hex: driver.teamColour) ?? .gray,
                isOnTrack: carPos.status == "OnTrack",
                isSafetyCar: false,
                isInPit: isInPit,
                isHidden: isHidden,
                isFavorite: appEnvironment.settingsStore.isFavoriteDriver(racingNumber)
            ))
        }
        
        return positions
    }
    
    // MARK: - Helper Methods
    
    private func normalizedPosition(for position: TrackPosition, in size: CGSize) -> CGPoint {
        let normalizedX = (position.x - minX) / (maxX - minX)
        let normalizedY = 1.0 - (position.y - minY) / (maxY - minY) // Flip Y axis
        
        return CGPoint(
            x: normalizedX * size.width,
            y: normalizedY * size.height
        )
    }
    
    private func findYellowSectors() -> Set<Int> {
        guard let messages = appEnvironment.liveSessionState.raceControlMessages?.messages else {
            return Set()
        }
        
        let flagMessages: [RaceControlMessage] = messages
            .filter { msg in
                guard let flag = msg.flag else { return false }
                return flag == .yellow
            }
            .sorted { $0.utc < $1.utc }
        
        var yellowSectors = Set<Int>()
        var clearedSectors = Set<Int>()
        
        for message in flagMessages {
            if message.scope == .track && message.flag == .yellow {
                // Track-wide yellow - mark all sectors
                for i in 1...20 {
                    yellowSectors.insert(i)
                }
                return yellowSectors
            }
            
            if message.scope == .sector, let sector = message.sector {
                if message.flag == .green {
                    clearedSectors.insert(sector)
                } else if !clearedSectors.contains(sector) {
                    yellowSectors.insert(sector)
                }
            }
        }
        
        return yellowSectors
    }
    
    private func getSectorColor(sector: MapSector, yellowSectors: Set<Int>, trackStatus: TrackStatus?) -> Color {
        // Check if this sector has yellow flag
        if yellowSectors.contains(sector.number) {
            return .yellow
        }
        
        // Check track status for global colors
        if let status = trackStatus?.status {
            switch status {
            case .green: return .green  // Green flag
            case .yellow: return .yellow // Yellow flag
            case .red: return .red    // Red flag
            // Add other cases as needed
            default: break
            }
        }
        
        return .secondary // Default track color
    }
}

// MARK: - Supporting Types

struct RotatedCorner {
    let number: Int
    let position: TrackPosition
    let labelPosition: TrackPosition
}

struct RenderedSector {
    let number: Int
    let points: [CGPoint]
    let color: Color
    let strokeWidth: CGFloat
}

struct CornerPosition {
    let number: Int
    let position: CGPoint
}

struct DriverMapPosition {
    let racingNumber: String
    let tla: String
    let point: CGPoint
    let color: Color
    let isOnTrack: Bool
    let isSafetyCar: Bool
    let isInPit: Bool
    let isHidden: Bool
    let isFavorite: Bool
}
