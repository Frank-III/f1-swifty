//
//  PositionDataSimpleTest.swift
//  F1DashAppXCodeTests
//
//  Simple test to isolate position data decoding issue
//

import XCTest
@testable import F1DashAppXCode
import F1DashModels

final class PositionDataSimpleTest: XCTestCase {
    
    func testDirectPositionDataDecoding() throws {
        // Test the exact JSON structure we expect
        let jsonString = """
        {
            "position": [
                {
                    "timestamp": "2023-07-01T14:45:19.1090551Z",
                    "entries": {
                        "1": {
                            "x": -1362.0,
                            "y": 4963.0,
                            "z": 7634.0,
                            "status": "OnTrack"
                        }
                    }
                }
            ]
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let positionData = try decoder.decode(PositionData.self, from: jsonData)
            print("✅ Successfully decoded PositionData")
            print("   Position count: \(positionData.position?.count ?? 0)")
            
            XCTAssertNotNil(positionData.position)
            XCTAssertEqual(positionData.position?.count, 1)
            
            if let firstPos = positionData.position?.first {
                print("   Timestamp: \(firstPos.timestamp)")
                print("   Entries count: \(firstPos.entries.count)")
                
                if let driver1 = firstPos.entries["1"] {
                    print("   Driver 1 - x: \(driver1.x), y: \(driver1.y), z: \(driver1.z), status: \(driver1.status)")
                }
            }
        } catch {
            print("❌ Failed to decode: \(error)")
            XCTFail("Decoding failed: \(error)")
        }
    }
    
    func testPositionCarWithIntegerCoordinates() throws {
        // Test if integer coordinates cause issues
        let jsonString = """
        {
            "x": -1362,
            "y": 4963,
            "z": 7634,
            "status": "OnTrack"
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let positionCar = try decoder.decode(PositionCar.self, from: jsonData)
            print("✅ Successfully decoded PositionCar with integer coordinates")
            print("   x: \(positionCar.x), y: \(positionCar.y), z: \(positionCar.z)")
            XCTAssertEqual(positionCar.x, -1362.0)
        } catch {
            print("❌ Failed to decode PositionCar: \(error)")
            
            // Try to understand the error
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("   Type mismatch: expected \(type)")
                    print("   Path: \(context.codingPath)")
                    print("   Debug: \(context.debugDescription)")
                default:
                    print("   Other decoding error: \(decodingError)")
                }
            }
            
            XCTFail("PositionCar decoding failed with integers")
        }
    }
    
    func testActualServerDataStructure() throws {
        // Test with the actual structure from server
        let serverData: [String: Any] = [
            "positionData": [
                [
                    "timestamp": "2023-07-01T14:45:19.1090551Z",
                    "entries": [
                        "1": ["x": -1362, "y": 4963, "z": 7634, "status": "OnTrack"],
                        "10": ["x": -2738, "y": -2236, "z": 7338, "status": "OnTrack"]
                    ]
                ]
            ]
        ]
        
        // Extract the array
        guard let positionArray = serverData["positionData"] as? [[String: Any]] else {
            XCTFail("Failed to extract position array")
            return
        }
        
        print("Position array count: \(positionArray.count)")
        
        // Wrap for PositionData model
        let wrappedData: [String: Any] = ["position": positionArray]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: wrappedData)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(PositionData.self, from: jsonData)
            
            print("✅ Decoded PositionData from server structure")
            print("   Position count: \(decoded.position?.count ?? 0)")
            
            XCTAssertNotNil(decoded.position)
            XCTAssertGreaterThan(decoded.position?.count ?? 0, 0)
            
        } catch {
            print("❌ Failed to decode from server structure: \(error)")
            
            // Print the JSON to debug
            if let jsonData = try? JSONSerialization.data(withJSONObject: wrappedData, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON being decoded:")
                print(jsonString)
            }
            
            XCTFail("Failed to decode server data")
        }
    }
    
    func testManualJSONCreation() throws {
        // Manually create the exact structure PositionData expects
        let positionItem: [String: Any] = [
            "timestamp": "2023-07-01T14:45:19.1090551Z",
            "entries": [
                "1": [
                    "x": Double(-1362),  // Explicitly use Double
                    "y": Double(4963),
                    "z": Double(7634),
                    "status": "OnTrack"
                ]
            ]
        ]
        
        let data: [String: Any] = ["position": [positionItem]]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(PositionData.self, from: jsonData)
            
            print("✅ Successfully decoded with explicit Double values")
            print("   Position count: \(decoded.position?.count ?? 0)")
            
            XCTAssertEqual(decoded.position?.count, 1)
            
        } catch {
            print("❌ Failed even with explicit Double values: \(error)")
            XCTFail("Manual JSON creation failed")
        }
    }
}