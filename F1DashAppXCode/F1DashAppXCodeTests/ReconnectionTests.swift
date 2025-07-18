//
//  ReconnectionTests.swift
//  F1DashAppXCodeTests
//
//  Tests for view reconnection behavior
//

import XCTest
import SwiftUI
@testable import F1DashAppXCode
@testable import F1DashModels

@MainActor
class ReconnectionTests: XCTestCase {
    var appEnvironment: OptimizedAppEnvironment!
    var liveSessionState: OptimizedLiveSessionState!
    
    override func setUp() async throws {
        await super.setUp()
        appEnvironment = OptimizedAppEnvironment()
        liveSessionState = appEnvironment.liveSessionState
    }
    
    func testDynamicDriverLayerUpdatesAfterReconnection() async throws {
        // Simulate initial connection
        appEnvironment.connectionStatus = .connected
        
        // Add some position data
        let initialPositionData = PositionData()
        var position1 = PositionDataEntry(timestamp: "2024-01-01T10:00:00Z", entries: [:])
        position1.entries["1"] = PositionCar(timestamp: "2024-01-01T10:00:00Z", driverNumber: "1", x: 100, y: 200, z: 0, status: "OnTrack")
        position1.entries["44"] = PositionCar(timestamp: "2024-01-01T10:00:00Z", driverNumber: "44", x: 150, y: 250, z: 0, status: "OnTrack")
        
        var positionData = initialPositionData
        positionData.position = [position1]
        
        // Set initial state
        liveSessionState.setFullState([
            "positionData": try JSONEncoder().encode(positionData),
            "driverList": try JSONEncoder().encode([
                "1": Driver(racingNumber: "1", tla: "VER", teamColour: "0072C6", teamName: "Red Bull Racing", line: 1, lastName: "Verstappen"),
                "44": Driver(racingNumber: "44", tla: "HAM", teamColour: "00D2BE", teamName: "Mercedes", line: 2, lastName: "Hamilton")
            ])
        ])
        
        // Simulate disconnection
        appEnvironment.connectionStatus = .disconnected
        
        // Wait a bit
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Simulate reconnection
        appEnvironment.connectionStatus = .connected
        
        // Add new position data after reconnection
        var position2 = PositionDataEntry(timestamp: "2024-01-01T10:00:01Z", entries: [:])
        position2.entries["1"] = PositionCar(timestamp: "2024-01-01T10:00:01Z", driverNumber: "1", x: 200, y: 300, z: 0, status: "OnTrack")
        position2.entries["44"] = PositionCar(timestamp: "2024-01-01T10:00:01Z", driverNumber: "44", x: 250, y: 350, z: 0, status: "OnTrack")
        
        positionData.position?.append(position2)
        
        // Update with new position
        liveSessionState.setDelta([
            "positionData": try JSONEncoder().encode(positionData)
        ])
        
        // Verify that the position data has been updated
        let latestPosition = liveSessionState.positionData?.position?.last
        XCTAssertNotNil(latestPosition)
        XCTAssertEqual(latestPosition?.timestamp, "2024-01-01T10:00:01Z")
        
        // Verify driver positions have updated values
        let driver1Position = latestPosition?.entries["1"]
        XCTAssertNotNil(driver1Position)
        XCTAssertEqual(driver1Position?.x, 200)
        XCTAssertEqual(driver1Position?.y, 300)
    }
    
    func testLiveTimingSectionShowsDataAfterReconnection() async throws {
        // Simulate initial connection
        appEnvironment.connectionStatus = .connected
        
        // Add initial timing data
        var timingData = TimingData()
        timingData.lines["1"] = TimingDataDriver(
            line: 1,
            racingNumber: "1",
            gapToLeader: "",
            intervalToPositionAhead: IntervalToPositionAhead(value: "", catching: nil),
            sectors: [],
            speeds: SpeedData(i1: nil, i2: nil, fl: nil, st: nil),
            bestLapTime: TimingDataTime(value: "1:23.456"),
            lastLapTime: TimingDataTime(value: "1:24.789")
        )
        
        // Set initial state
        liveSessionState.setFullState([
            "timingData": try JSONEncoder().encode(timingData),
            "driverList": try JSONEncoder().encode([
                "1": Driver(racingNumber: "1", tla: "VER", teamColour: "0072C6", teamName: "Red Bull Racing", line: 1, lastName: "Verstappen")
            ])
        ])
        
        // Verify initial data is present
        XCTAssertNotNil(liveSessionState.timingData)
        XCTAssertEqual(liveSessionState.timingData?.lines.count, 1)
        
        // Simulate disconnection
        appEnvironment.connectionStatus = .disconnected
        
        // Simulate reconnection
        appEnvironment.connectionStatus = .connected
        
        // Update timing data after reconnection
        timingData.lines["1"]?.lastLapTime = TimingDataTime(value: "1:23.123")
        
        liveSessionState.setDelta([
            "timingData": try JSONEncoder().encode(timingData)
        ])
        
        // Verify updated data is available
        let updatedTiming = liveSessionState.timing(for: "1")
        XCTAssertNotNil(updatedTiming)
        XCTAssertEqual(updatedTiming?.lastLapTime?.value, "1:23.123")
    }
}