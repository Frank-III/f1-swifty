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
    private var updateTimer: Timer?
    
    // Track bounds
    private(set) var minX: Double = 0
    private(set) var maxX: Double = 1000
    private(set) var minY: Double = 0
    private(set) var maxY: Double = 1000
    
    // Driver positions
    private(set) var driverPositions: [DriverPosition] = []
    
    // MARK: - Initialization
    
    init(appEnvironment: AppEnvironment) {
        self.appEnvironment = appEnvironment
        startUpdating()
    }
    
    deinit {
        // Timer cleanup handled by MainActor
    }
    
    // MARK: - Updates
    
    private func startUpdating() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                self.updatePositions()
            }
        }
    }
    
    private func updatePositions() {
        guard let positionData = appEnvironment.liveSessionState.positionData,
              let latestPosition = positionData.position.last else {
            return
        }
        
        var positions: [DriverPosition] = []
        
        for (racingNumber, carPosition) in latestPosition.entries {
            guard let driver = appEnvironment.liveSessionState.driver(for: racingNumber) else {
                continue
            }
            
            let x = carPosition.x
            let y = carPosition.y
            
            let position = DriverPosition(
                racingNumber: racingNumber,
                driver: driver,
                x: x,
                y: y,
                status: carPosition.status
            )
            positions.append(position)
        }
        
        self.driverPositions = positions
        updateTrackBounds()
    }
    
    private func updateTrackBounds() {
        guard !driverPositions.isEmpty else { return }
        
        let xValues = driverPositions.map { $0.x }
        let yValues = driverPositions.map { $0.y }
        
        if let minX = xValues.min(), let maxX = xValues.max(),
           let minY = yValues.min(), let maxY = yValues.max() {
            // Add padding
            let xPadding = (maxX - minX) * 0.1
            let yPadding = (maxY - minY) * 0.1
            
            self.minX = minX - xPadding
            self.maxX = maxX + xPadding
            self.minY = minY - yPadding
            self.maxY = maxY + yPadding
        }
    }
    
    // MARK: - Coordinate Conversion
    
    func normalizedPosition(for position: DriverPosition, in size: CGSize) -> CGPoint {
        let normalizedX = (position.x - minX) / (maxX - minX)
        let normalizedY = 1.0 - (position.y - minY) / (maxY - minY) // Flip Y axis
        
        return CGPoint(
            x: normalizedX * size.width,
            y: normalizedY * size.height
        )
    }
}

// MARK: - Driver Position Model

struct DriverPosition: Identifiable {
    let id = UUID()
    let racingNumber: String
    let driver: Driver
    let x: Double
    let y: Double
    let status: String
    
    var isOnTrack: Bool {
        status == "OnTrack"
    }
    
    var color: Color {
        Color(hex: driver.teamColour) ?? .gray
    }
}
