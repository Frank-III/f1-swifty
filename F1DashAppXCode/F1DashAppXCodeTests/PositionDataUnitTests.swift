//
//  PositionDataUnitTests.swift
//  F1DashAppXCodeTests
//
//  Unit tests for position data decoding without SSE
//

import XCTest
@testable import F1DashAppXCode
import F1DashModels

final class PositionDataUnitTests: XCTestCase {
    
    func testPositionDataDecodingWithIntegerCoordinates() throws {
        // Test that JSONDecoder handles Int to Double conversion
        let jsonData = """
        {
            "position": [
                {
                    "timestamp": "2023-07-01T14:45:19.1090551Z",
                    "entries": {
                        "1": {
                            "x": -1362,
                            "y": 4963,
                            "z": 7634,
                            "status": "OnTrack"
                        },
                        "10": {
                            "x": -2738,
                            "y": -2236,
                            "z": 7338,
                            "status": "OnTrack"
                        }
                    }
                }
            ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let positionData = try decoder.decode(PositionData.self, from: jsonData)
        
        XCTAssertNotNil(positionData.position)
        XCTAssertEqual(positionData.position?.count, 1)
        
        if let firstPos = positionData.position?.first {
            XCTAssertEqual(firstPos.entries.count, 2)
            
            // Check driver 1
            if let driver1 = firstPos.entries["1"] {
                XCTAssertEqual(driver1.x, -1362.0)
                XCTAssertEqual(driver1.y, 4963.0)
                XCTAssertEqual(driver1.z, 7634.0)
                XCTAssertEqual(driver1.status, "OnTrack")
            } else {
                XCTFail("Driver 1 not found")
            }
            
            // Check driver 10
            if let driver10 = firstPos.entries["10"] {
                XCTAssertEqual(driver10.x, -2738.0)
                XCTAssertEqual(driver10.y, -2236.0)
                XCTAssertEqual(driver10.z, 7338.0)
                XCTAssertEqual(driver10.status, "OnTrack")
            } else {
                XCTFail("Driver 10 not found")
            }
        }
    }
    
    func testLiveSessionStatePositionDataDecoding() async throws {
        // Create app environment
        let appEnvironment = await MainActor.run {
            OptimizedAppEnvironment()
        }
        
        // Create test data matching server structure
        let testData: [String: Any] = [
            "positionData": [
                "positionData": [
                    [
                        "timestamp": "2023-07-01T14:45:19.1090551Z",
                        "entries": [
                            "1": ["x": -1362, "y": 4963, "z": 7634, "status": "OnTrack"],
                            "10": ["x": -2738, "y": -2236, "z": 7338, "status": "OnTrack"],
                            "11": ["x": -6686, "y": 5674, "z": 7833, "status": "OnTrack"]
                        ]
                    ],
                    [
                        "timestamp": "2023-07-01T14:45:19.2890276Z",
                        "entries": [
                            "1": ["x": -1248, "y": 4960, "z": 7628, "status": "OnTrack"],
                            "10": ["x": -2800, "y": -2242, "z": 7344, "status": "OnTrack"]
                        ]
                    ]
                ]
            ]
        ]
        
        // Apply the test data
        await MainActor.run {
            appEnvironment.liveSessionState.setFullState(testData)
        }
        
        // Get decoded position data
        let positionData = await MainActor.run {
            appEnvironment.liveSessionState.positionData
        }
        
        XCTAssertNotNil(positionData, "Position data should decode successfully")
        XCTAssertEqual(positionData?.position?.count, 2, "Should have 2 position entries")
        
        // Check first position entry
        if let firstPos = positionData?.position?.first {
            XCTAssertEqual(firstPos.entries.count, 3, "First position should have 3 drivers")
            
            // Verify all drivers are present
            XCTAssertNotNil(firstPos.entries["1"])
            XCTAssertNotNil(firstPos.entries["10"])
            XCTAssertNotNil(firstPos.entries["11"])
            
            // Check coordinate conversion
            if let driver1 = firstPos.entries["1"] {
                XCTAssertEqual(driver1.x, -1362.0, "X coordinate should be converted to Double")
                XCTAssertEqual(driver1.y, 4963.0, "Y coordinate should be converted to Double")
                XCTAssertEqual(driver1.z, 7634.0, "Z coordinate should be converted to Double")
            }
        }
        
        // Check second position entry
        if let secondPos = positionData?.position?[1] {
            XCTAssertEqual(secondPos.entries.count, 2, "Second position should have 2 drivers")
            XCTAssertEqual(secondPos.timestamp, "2023-07-01T14:45:19.2890276Z")
        }
    }
    
    func testPositionLookupHelper() async throws {
        // Create app environment
        let appEnvironment = await MainActor.run {
            OptimizedAppEnvironment()
        }
        
        // Create test data
        let testData: [String: Any] = [
            "positionData": [
                "positionData": [
                    [
                        "timestamp": "2023-07-01T14:45:19.1090551Z",
                        "entries": [
                            "1": ["x": -1362, "y": 4963, "z": 7634, "status": "OnTrack"],
                            "10": ["x": -2738, "y": -2236, "z": 7338, "status": "OnTrack"]
                        ]
                    ]
                ]
            ],
            "driverList": [
                "1": ["racingNumber": "1", "tla": "VER", "line": 1, "teamColour": "3671C6"],
                "10": ["racingNumber": "10", "tla": "GAS", "line": 10, "teamColour": "0093CC"]
            ]
        ]
        
        // Apply the test data
        await MainActor.run {
            appEnvironment.liveSessionState.setFullState(testData)
        }
        
        // Test position lookup
        let position1 = await MainActor.run {
            appEnvironment.liveSessionState.position(for: "1")
        }
        
        XCTAssertNotNil(position1, "Should find position for driver 1")
        XCTAssertEqual(position1?.x, -1362.0)
        XCTAssertEqual(position1?.y, 4963.0)
        
        let position10 = await MainActor.run {
            appEnvironment.liveSessionState.position(for: "10")
        }
        
        XCTAssertNotNil(position10, "Should find position for driver 10")
        XCTAssertEqual(position10?.x, -2738.0)
        XCTAssertEqual(position10?.y, -2236.0)
        
        // Test non-existent driver
        let positionNone = await MainActor.run {
            appEnvironment.liveSessionState.position(for: "99")
        }
        
        XCTAssertNil(positionNone, "Should return nil for non-existent driver")
    }
    
    func testEmptyPositionData() async throws {
        // Test handling of empty position data
        let appEnvironment = await MainActor.run {
            OptimizedAppEnvironment()
        }
        
        let emptyData: [String: Any] = [
            "positionData": [
                "positionData": []
            ]
        ]
        
        await MainActor.run {
            appEnvironment.liveSessionState.setFullState(emptyData)
        }
        
        let positionData = await MainActor.run {
            appEnvironment.liveSessionState.positionData
        }
        
        XCTAssertNotNil(positionData, "Should handle empty position array")
        XCTAssertEqual(positionData?.position?.count, 0, "Should have 0 positions")
    }
}