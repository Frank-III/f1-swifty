//
//  PositionDataSSETests.swift
//  F1DashAppXCodeTests
//
//  Tests for position data handling through SSE
//

import XCTest
@testable import F1DashAppXCode
import F1DashModels

final class PositionDataSSETests: XCTestCase {
    
    var sseClient: SSEClient!
    var appEnvironment: OptimizedAppEnvironment!
    
    override func setUp() async throws {
        try await super.setUp()
        sseClient = SSEClient()
        appEnvironment = await MainActor.run {
            OptimizedAppEnvironment()
        }
    }
    
    override func tearDown() async throws {
        await sseClient.disconnect()
        sseClient = nil
        appEnvironment = nil
        try await super.tearDown()
    }
    
    func testPositionDataInInitialState() async throws {
        print("=== Testing Position Data in Initial State ===")
        
        let expectation = XCTestExpectation(description: "Position data received")
        var foundPositionData = false
        
        try await sseClient.connect()
        
        Task {
            for await message in await sseClient.messages {
                switch message {
                case .initial(let data):
                    print("Test: Received initial state")
                    
                    // Check if positionData exists
                    if let positionData = data["positionData"] as? [String: Any] {
                        print("Test: Found positionData in initial state")
                        
                        // Check the structure
                        if let nestedPositionData = positionData["positionData"] as? [[String: Any]] {
                            print("Test: Found nested positionData array with \(nestedPositionData.count) entries")
                            foundPositionData = true
                            
                            // Examine first entry
                            if let firstEntry = nestedPositionData.first {
                                print("Test: First entry keys: \(firstEntry.keys.sorted())")
                                
                                if let timestamp = firstEntry["timestamp"] as? String {
                                    print("Test: First timestamp: \(timestamp)")
                                }
                                
                                if let entries = firstEntry["entries"] as? [String: Any] {
                                    print("Test: First entry has \(entries.count) drivers")
                                    
                                    // Check a driver's data
                                    if let firstDriverKey = entries.keys.sorted().first,
                                       let driverData = entries[firstDriverKey] as? [String: Any] {
                                        print("Test: Driver \(firstDriverKey) data:")
                                        for (key, value) in driverData {
                                            print("  \(key): \(type(of: value)) = \(value)")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    expectation.fulfill()
                    
                case .update(_):
                    break // Ignore updates for this test
                    
                case .error(let error):
                    XCTFail("SSE error: \(error)")
                }
                
                if foundPositionData {
                    break
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
        XCTAssertTrue(foundPositionData, "Should have found position data in initial state")
    }
    
    func testPositionDataDecoding() async throws {
        print("=== Testing Position Data Decoding ===")
        
        let expectation = XCTestExpectation(description: "Position data decoded")
        var decodedSuccessfully = false
        var positionCount = 0
        var driverCount = 0
        
        try await sseClient.connect()
        
        Task {
            for await message in await sseClient.messages {
                switch message {
                case .initial(let data):
                    // Apply to live session state
                    await MainActor.run {
                        appEnvironment.liveSessionState.setFullState(data)
                    }
                    
                    // Try to get decoded position data
                    if let positionData = await MainActor.run(body: { appEnvironment.liveSessionState.positionData }) {
                        print("Test: Successfully decoded PositionData")
                        positionCount = positionData.position?.count ?? 0
                        print("Test: Position count: \(positionCount)")
                        
                        if let firstPos = positionData.position?.first {
                            print("Test: First position timestamp: \(firstPos.timestamp)")
                            driverCount = firstPos.entries.count
                            print("Test: First position has \(driverCount) drivers")
                            
                            // Verify coordinate values are reasonable
                            for (driverNum, pos) in firstPos.entries.prefix(3) {
                                print("Test: Driver \(driverNum) - x: \(pos.x), y: \(pos.y), z: \(pos.z), status: \(pos.status ?? "unknown")")
                                
                                // Basic sanity checks
                                XCTAssertNotEqual(pos.x, 0, "X coordinate should not be zero")
                                XCTAssertNotEqual(pos.y, 0, "Y coordinate should not be zero")
                                // Status is now optional, so we don't require it
                                // XCTAssertFalse(pos.status?.isEmpty ?? true, "Status should not be empty if present")
                            }
                            
                            decodedSuccessfully = true
                        }
                    } else {
                        print("Test: Failed to decode position data")
                        
                        // Debug raw data
                        if let rawData = await MainActor.run(body: { appEnvironment.liveSessionState.debugRawData(for: "positionData") }) {
                            print("Test: Raw positionData exists")
                            if let dict = rawData as? [String: Any] {
                                print("Test: Raw data keys: \(dict.keys)")
                                debugPositionData(dict)
                            }
                        }
                    }
                    
                    expectation.fulfill()
                    
                case .update(_):
                    break
                    
                case .error(let error):
                    XCTFail("SSE error: \(error)")
                }
                
                if decodedSuccessfully {
                    break
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
        XCTAssertTrue(decodedSuccessfully, "Should have successfully decoded position data")
        XCTAssertGreaterThan(positionCount, 0, "Should have at least one position entry")
        XCTAssertGreaterThan(driverCount, 0, "Should have at least one driver with position")
    }
    
    func testPositionDataUpdates() async throws {
        print("=== Testing Position Data Updates ===")
        
        let expectation = XCTestExpectation(description: "Position data updated")
        var initialPositionCount = 0
        var receivedUpdate = false
        
        try await sseClient.connect()
        
        Task {
            for await message in await sseClient.messages {
                switch message {
                case .initial(let data):
                    await MainActor.run {
                        appEnvironment.liveSessionState.setFullState(data)
                    }
                    
                    if let positionData = await MainActor.run(body: { appEnvironment.liveSessionState.positionData }) {
                        initialPositionCount = positionData.position?.count ?? 0
                        print("Test: Initial position count: \(initialPositionCount)")
                    }
                    
                case .update(let data):
                    // Apply update
                    await MainActor.run {
                        appEnvironment.liveSessionState.applyPartialUpdate(data)
                    }
                    
                    // Check if position data was updated
                    if data.keys.contains("positionData") {
                        print("Test: Received position data update")
                        
                        if let positionData = await MainActor.run(body: { appEnvironment.liveSessionState.positionData }) {
                            let newCount = positionData.position?.count ?? 0
                            print("Test: New position count: \(newCount)")
                            
                            if newCount > 0 {
                                receivedUpdate = true
                                expectation.fulfill()
                            }
                        }
                    }
                    
                case .error(let error):
                    XCTFail("SSE error: \(error)")
                }
                
                if receivedUpdate {
                    break
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 20.0)
        XCTAssertTrue(receivedUpdate, "Should have received position data update")
    }
    
    func testDriverPositionLookup() async throws {
        print("=== Testing Driver Position Lookup ===")
        
        let expectation = XCTestExpectation(description: "Driver positions found")
        var foundDriverPositions = false
        
        try await sseClient.connect()
        
        Task {
            for await message in await sseClient.messages {
                switch message {
                case .initial(let data):
                    await MainActor.run {
                        appEnvironment.liveSessionState.setFullState(data)
                    }
                    
                    // Get drivers
                    let drivers = await MainActor.run { appEnvironment.liveSessionState.driverList }
                    print("Test: Found \(drivers.count) drivers")
                    
                    // Try to get positions for each driver
                    var positionsFound = 0
                    for (racingNumber, driver) in drivers.prefix(5) {
                        if let position = await MainActor.run(body: { appEnvironment.liveSessionState.position(for: racingNumber) }) {
                            print("Test: Driver \(driver.tla) (#\(racingNumber)) - x: \(position.x), y: \(position.y)")
                            positionsFound += 1
                        } else {
                            print("Test: No position for driver \(driver.tla) (#\(racingNumber))")
                        }
                    }
                    
                    if positionsFound > 0 {
                        foundDriverPositions = true
                        print("Test: Found positions for \(positionsFound) drivers")
                    }
                    
                    expectation.fulfill()
                    
                case .update(_):
                    break
                    
                case .error(let error):
                    XCTFail("SSE error: \(error)")
                }
                
                if foundDriverPositions {
                    break
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
        XCTAssertTrue(foundDriverPositions, "Should have found driver positions")
    }
}

// MARK: - Test Helpers

extension PositionDataSSETests {
    
    func debugPositionData(_ data: [String: Any]) {
        print("\n=== Position Data Debug ===")
        
        if let positionData = data["positionData"] as? [String: Any] {
            print("positionData keys: \(positionData.keys)")
            
            if let nestedArray = positionData["positionData"] as? [[String: Any]] {
                print("Nested array count: \(nestedArray.count)")
                
                if let first = nestedArray.first {
                    print("First entry structure:")
                    for (key, value) in first {
                        print("  \(key): \(type(of: value))")
                    }
                }
            }
        }
        
        print("=== End Debug ===\n")
    }
}