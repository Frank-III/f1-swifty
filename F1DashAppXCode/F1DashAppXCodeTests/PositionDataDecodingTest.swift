//
//  PositionDataDecodingTest.swift
//  F1DashAppXCodeTests
//
//  Test position data decoding from raw JSON
//

import XCTest
@testable import F1DashAppXCode
import F1DashModels

final class PositionDataDecodingTest: XCTestCase {
    
    func testPositionDataDecoding() throws {
        print("=== Position Data Decoding Test ===")
        
        // Sample position data from the SSE stream
        let jsonString = """
        {
            "positiondata": [
                {
                    "timestamp": "2023-07-01t14:45:19.1090551z",
                    "entries": {
                        "1": {"x": -1362, "y": 4963, "z": 7634, "status": "ontrack"},
                        "10": {"x": -2738, "y": -2236, "z": 7338, "status": "ontrack"},
                        "11": {"x": -6686, "y": 5674, "z": 7833, "status": "ontrack"}
                    }
                },
                {
                    "timestamp": "2023-07-01t14:45:19.2890276z",
                    "entries": {
                        "1": {"x": -1248, "y": 4960, "z": 7628, "status": "ontrack"},
                        "10": {"x": -2800, "y": -2242, "z": 7344, "status": "ontrack"}
                    }
                }
            ]
        }
        """
        
        // Parse JSON to dictionary
        guard let jsonData = jsonString.data(using: .utf8),
              let outerDict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let positionArray = outerDict["positionData"] as? [[String: Any]] else {
            XCTFail("Failed to parse JSON")
            return
        }
        
        print("Raw position array count: \(positionArray.count)")
        
        // Test type checking
        if let firstEntry = positionArray.first {
            print("First entry keys: \(firstEntry.keys.sorted())")
            
            if let entries = firstEntry["entries"] as? [String: Any] {
                print("Entries count: \(entries.count)")
                
                if let firstDriver = entries["1"] as? [String: Any] {
                    print("Driver 1 data:")
                    for (key, value) in firstDriver {
                        print("  \(key): \(type(of: value)) = \(value)")
                    }
                }
            }
        }
        
        // Test the decoding logic from LiveSessionState
        var convertedArray: [[String: Any]] = []
        
        for entry in positionArray {
            guard let timestamp = entry["timestamp"] as? String,
                  let entries = entry["entries"] as? [String: Any] else {
                print("Skipping malformed entry")
                continue
            }
            
            var convertedEntries: [String: Any] = [:]
            
            for (driverNumber, driverData) in entries {
                guard let driverDict = driverData as? [String: Any] else {
                    continue
                }
                
                var convertedDriver: [String: Any] = [:]
                
                // Status is required
                guard let status = driverDict["status"] as? String else {
                    print("Missing status for driver \(driverNumber)")
                    continue
                }
                convertedDriver["status"] = status
                
                // Convert x, y, z to Double
                if let x = driverDict["x"] {
                    if let intX = x as? Int {
                        convertedDriver["x"] = Double(intX)
                    } else if let doubleX = x as? Double {
                        convertedDriver["x"] = doubleX
                    }
                }
                
                if let y = driverDict["y"] {
                    if let intY = y as? Int {
                        convertedDriver["y"] = Double(intY)
                    } else if let doubleY = y as? Double {
                        convertedDriver["y"] = doubleY
                    }
                }
                
                if let z = driverDict["z"] {
                    if let intZ = z as? Int {
                        convertedDriver["z"] = Double(intZ)
                    } else if let doubleZ = z as? Double {
                        convertedDriver["z"] = doubleZ
                    }
                }
                
                print("Driver \(driverNumber) - converted keys: \(convertedDriver.keys.sorted())")
                
                // Only add if we have all required fields
                if let _ = convertedDriver["x"], let _ = convertedDriver["y"], let _ = convertedDriver["z"] {
                    convertedEntries[driverNumber] = convertedDriver
                } else {
                    print("  Missing coordinates for driver \(driverNumber)")
                }
            }
            
            convertedArray.append([
                "timestamp": timestamp,
                "entries": convertedEntries
            ])
        }
        
        print("\nConverted array count: \(convertedArray.count)")
        
        // Now try to decode
        let wrappedData: [String: Any] = ["position": convertedArray]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: wrappedData)
            
            // Print the JSON for debugging
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("\nJSON to decode:")
                print(jsonString.prefix(500))
            }
            
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(PositionData.self, from: jsonData)
            
            print("\nDecode successful!")
            print("Position count: \(decoded.position?.count ?? 0)")
            
            if let firstPos = decoded.position?.first {
                print("First timestamp: \(firstPos.timestamp)")
                print("First entries count: \(firstPos.entries.count)")
                
                for (driverNum, position) in firstPos.entries.prefix(3) {
                  print("Driver \(driverNum): x=\(position.x), y=\(position.y), z=\(position.z), status=\(position.status ?? "unknown")")
                }
            }
            
            XCTAssertNotNil(decoded.position)
            XCTAssertEqual(decoded.position?.count, 2)
            XCTAssertEqual(decoded.position?.first?.entries.count, 3)
            
        } catch {
            print("\nDecode failed: \(error)")
            
            // Try to understand the error
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("Type mismatch: expected \(type)")
                    print("Context: \(context)")
                    print("Debug description: \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("Value not found: \(type)")
                    print("Context: \(context)")
                case .keyNotFound(let key, let context):
                    print("Key not found: \(key)")
                    print("Context: \(context)")
                case .dataCorrupted(let context):
                    print("Data corrupted")
                    print("Context: \(context)")
                @unknown default:
                    print("Unknown decoding error")
                }
            }
            
            XCTFail("Failed to decode: \(error)")
        }
    }
    
    func testLiveSessionStatePositionData() async throws {
        print("\n=== Live Session State Position Data Test ===")
        
        let appEnvironment = await MainActor.run {
            OptimizedAppEnvironment()
        }
        
        // Simulate receiving position data
        let update: [String: Any] = [
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
            ]
        ]
        
        // Apply update
        await MainActor.run {
            appEnvironment.liveSessionState.applyPartialUpdate(update)
        }
        
        // Check if position data is decoded
        let positionData = await MainActor.run { appEnvironment.liveSessionState.positionData }
        
        print("Position data exists: \(positionData != nil)")
        print("Position count: \(positionData?.position?.count ?? 0)")
        
        XCTAssertNotNil(positionData)
        XCTAssertEqual(positionData?.position?.count, 1)
        
        if let firstPos = positionData?.position?.first {
            print("Timestamp: \(firstPos.timestamp)")
            print("Entries: \(firstPos.entries.count)")
            
            for (driver, pos) in firstPos.entries {
                print("  Driver \(driver): x=\(pos.x), y=\(pos.y), z=\(pos.z)")
            }
        }
    }
}

