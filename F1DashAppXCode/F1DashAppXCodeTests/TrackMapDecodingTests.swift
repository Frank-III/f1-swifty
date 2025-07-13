//
//  TrackMapDecodingTests.swift
//  F1DashAppXCodeTests
//
//  Tests for TrackMap JSON decoding
//

import Testing
import Foundation
import F1DashModels

@Suite("TrackMap Decoding Tests")
struct TrackMapDecodingTests {
    
    @Test("Decode TrackMap from API response")
    func testTrackMapDecoding() async throws {
        // Test with the exact URL provided
        let url = URL(string: "https://api.multiviewer.app/api/v1/circuits/19/2023")!
        
        let session = URLSession.shared
        let (data, response) = try await session.data(from: url)
        
        // Verify we got a valid response
        guard let httpResponse = response as? HTTPURLResponse else {
            Issue.record("Response is not HTTPURLResponse")
            return
        }
        
        #expect(httpResponse.statusCode == 200, "Expected status code 200, got \(httpResponse.statusCode)")
        
        // Print raw JSON for debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON response (first 500 chars):")
            print(String(jsonString.prefix(500)))
        }
        
        // First, try standard decoder to see the exact error
        print("\n=== Testing standard JSONDecoder ===")
        let decoder = JSONDecoder()
        
        do {
            let _ = try decoder.decode(TrackMap.self, from: data)
            print("Standard decoder succeeded unexpectedly!")
        } catch {
            print("Standard decoder failed as expected: \(error)")
            
            // Extract the underlying error for more details
            if let decodingError = error as? DecodingError,
               case .dataCorrupted(let context) = decodingError,
               let underlyingError = context.underlyingError as NSError? {
                print("Underlying error code: \(underlyingError.code)")
                print("Underlying error domain: \(underlyingError.domain)")
                print("Underlying error userInfo: \(underlyingError.userInfo)")
            }
        }
        
        // Now try our custom decoder
        print("\n=== Testing custom TrackMap decoder ===")
        
        do {
            let trackMap = try TrackMap.decode(from: data)
            
            // Verify basic properties
            #expect(trackMap.circuitKey == 19)
            #expect(trackMap.year <= 2023)
            #expect(!trackMap.circuitName.isEmpty)
            #expect(!trackMap.countryName.isEmpty)
            
            // Verify arrays are not empty
            #expect(!trackMap.x.isEmpty, "X coordinates should not be empty")
            #expect(!trackMap.y.isEmpty, "Y coordinates should not be empty")
            #expect(trackMap.x.count == trackMap.y.count, "X and Y arrays should have same length")
            
            // Verify corners
            #expect(!trackMap.corners.isEmpty, "Corners should not be empty")
            
            // Verify marshal sectors
            #expect(!trackMap.marshalSectors.isEmpty, "Marshal sectors should not be empty")
            
            print("\nSuccessfully decoded TrackMap with custom decoder:")
            print("Circuit: \(trackMap.circuitName)")
            print("Country: \(trackMap.countryName)")
            print("Year: \(trackMap.year)")
            print("Number of track points: \(trackMap.x.count)")
            print("Number of corners: \(trackMap.corners.count)")
            print("Number of marshal sectors: \(trackMap.marshalSectors.count)")
            print("Rotation: \(trackMap.rotation)")
            
            // Print some sample coordinates to verify precision handling
            print("\nFirst 5 X coordinates:")
            for (i, x) in trackMap.x.prefix(5).enumerated() {
                print("  [\(i)]: \(x)")
            }
            
            print("\nFirst 3 corners:")
            for corner in trackMap.corners.prefix(3) {
                print("  Corner \(corner.number): angle=\(corner.angle), length=\(corner.length), position=(\(corner.trackPosition.x), \(corner.trackPosition.y))")
            }
            
        } catch let decodingError as DecodingError {
            print("Decoding error details:")
            switch decodingError {
            case .typeMismatch(let type, let context):
                print("Type mismatch: Expected \(type)")
                print("Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                print("Debug description: \(context.debugDescription)")
                
            case .valueNotFound(let type, let context):
                print("Value not found: \(type)")
                print("Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                print("Debug description: \(context.debugDescription)")
                
            case .keyNotFound(let key, let context):
                print("Key not found: \(key.stringValue)")
                print("Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                print("Debug description: \(context.debugDescription)")
                
            case .dataCorrupted(let context):
                print("Data corrupted")
                print("Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                print("Debug description: \(context.debugDescription)")
                
            @unknown default:
                print("Unknown decoding error")
            }
            
            throw decodingError
        } catch {
            print("Other error: \(error)")
            throw error
        }
    }
    
    @Test("Decode TrackMap JSON structure")
    func testJSONStructure() async throws {
        let url = URL(string: "https://api.multiviewer.app/api/v1/circuits/19/2023")!
        
        let session = URLSession.shared
        let (data, _) = try await session.data(from: url)
        
        // Parse as generic JSON to examine structure
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let dict = json as? [String: Any] else {
            Issue.record("JSON is not a dictionary")
            return
        }
        
        // Print all keys
        print("JSON Keys:")
        for key in dict.keys.sorted() {
            let valueType = type(of: dict[key]!)
            print("  \(key): \(valueType)")
        }
        
        // Check for required keys
        let requiredKeys = [
            "corners", "marshalLights", "marshalSectors", "candidateLap",
            "circuitKey", "circuitName", "countryIocCode", "countryKey",
            "countryName", "location", "meetingKey", "meetingName",
            "meetingOfficialName", "raceDate", "rotation", "round",
            "trackPositionTime", "x", "y", "year"
        ]
        
        for key in requiredKeys {
            #expect(dict[key] != nil, "Missing required key: \(key)")
        }
        
        // Check candidate lap structure
        if let candidateLap = dict["candidateLap"] as? [String: Any] {
            print("\nCandidate Lap Keys:")
            for key in candidateLap.keys.sorted() {
                let valueType = type(of: candidateLap[key]!)
                print("  \(key): \(valueType)")
            }
        }
        
        // Check corner structure
        if let corners = dict["corners"] as? [[String: Any]], let firstCorner = corners.first {
            print("\nFirst Corner Keys:")
            for key in firstCorner.keys.sorted() {
                let valueType = type(of: firstCorner[key]!)
                print("  \(key): \(valueType)")
            }
        }
    }
    
    @Test("Test problematic number parsing")
    func testProblematicNumberParsing() async throws {
        // The error mentioned "Number 1018.847 is not representable in Swift"
        // Let's test this specific case
        
        let problematicJSON = """
        {
            "value": 1018.847,
            "largeValue": 999999999999999.9,
            "preciseValue": 1234.5678901234567890
        }
        """.data(using: .utf8)!
        
        // Test with standard decoder
        do {
            let _ = try JSONDecoder().decode([String: Double].self, from: problematicJSON)
            print("Standard decoder handled problematic numbers")
        } catch {
            print("Standard decoder failed with problematic numbers: \(error)")
        }
        
        // Test with JSONSerialization
        if let parsed = try JSONSerialization.jsonObject(with: problematicJSON) as? [String: Any] {
            print("\nJSONSerialization results:")
            for (key, value) in parsed {
                print("  \(key): \(value) (type: \(type(of: value)))")
                if let number = value as? NSNumber {
                    print("    as Double: \(number.doubleValue)")
                }
            }
        }
    }
    
    @Test("Test custom decoder for problematic fields")
    func testCustomDecoding() async throws {
        // Create a simple test JSON with potential problematic values
        let testJSON = """
        {
            "corners": [],
            "marshalLights": [],
            "marshalSectors": [],
            "candidateLap": {
                "driverNumber": "1",
                "lapNumber": 1,
                "lapStartDate": "2023-01-01",
                "lapStartSessionTime": 1000,
                "lapTime": 90000,
                "session": "R",
                "sessionStartTime": 0
            },
            "circuitKey": 19,
            "circuitName": "Test Circuit",
            "countryIocCode": "USA",
            "countryKey": 1,
            "countryName": "United States",
            "location": "Test Location",
            "meetingKey": "1234",
            "meetingName": "Test GP",
            "meetingOfficialName": "Test Grand Prix",
            "raceDate": "2023-01-01",
            "rotation": 90.5,
            "round": 1,
            "trackPositionTime": [0.0, 1.0, 2.0],
            "x": [100.0, 200.0, 300.0],
            "y": [100.0, 200.0, 300.0],
            "year": 2023
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let trackMap = try decoder.decode(TrackMap.self, from: testJSON)
        
        #expect(trackMap.circuitKey == 19)
        #expect(trackMap.rotation == 90.5)
        #expect(trackMap.x.count == 3)
        #expect(trackMap.y.count == 3)
    }
}
