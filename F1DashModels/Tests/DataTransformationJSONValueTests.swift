import XCTest
@testable import F1DashModels

final class DataTransformationJSONValueTests: XCTestCase {
    
    // MARK: - Driver List Merge Tests
    
    func testDriverListMerge_JSONValue_ReplacesEntireDriverEntry() {
        let base = JSONValue.object([
            "driverList": .object([
                "1": .object([
                    "racingNumber": .string("1"),
                    "firstName": .string("Max"),
                    "lastName": .string("Verstappen"),
                    "teamName": .string("Red Bull Racing")
                ]),
                "44": .object([
                    "racingNumber": .string("44"),
                    "firstName": .string("Lewis"),
                    "lastName": .string("Hamilton"),
                    "teamName": .string("Mercedes")
                ])
            ])
        ])
        
        let update = JSONValue.object([
            "driverList": .object([
                "1": .object([
                    "racingNumber": .string("1"),
                    "firstName": .string("Max"),
                    "lastName": .string("Verstappen"),
                    "teamName": .string("Red Bull Racing"),
                    "position": .int(1)  // New field
                ])
            ])
        ])
        
        let merged = DataTransformationJSONValue.mergeStates(base, with: update)
        
        // Driver 1 should be completely replaced
        let driver1 = merged["driverList"]?["1"]
        XCTAssertEqual(driver1?["position"]?.intValue, 1)
        XCTAssertEqual(driver1?["firstName"]?.stringValue, "Max")
        
        // Driver 44 should remain unchanged
        let driver44 = merged["driverList"]?["44"]
        XCTAssertEqual(driver44?["firstName"]?.stringValue, "Lewis")
        XCTAssertNil(driver44?["position"])
    }
    
    func testDriverListMerge_JSONValue_AddsNewDrivers() {
        let base = JSONValue.object([
            "driverList": .object([
                "1": .object([
                    "racingNumber": .string("1"),
                    "firstName": .string("Max")
                ])
            ])
        ])
        
        let update = JSONValue.object([
            "driverList": .object([
                "16": .object([
                    "racingNumber": .string("16"),
                    "firstName": .string("Charles")
                ])
            ])
        ])
        
        let merged = DataTransformationJSONValue.mergeStates(base, with: update)
        
        // Both drivers should exist
        XCTAssertNotNil(merged["driverList"]?["1"])
        XCTAssertNotNil(merged["driverList"]?["16"])
        XCTAssertEqual(merged["driverList"]?["16"]?["firstName"]?.stringValue, "Charles")
    }
    
    // MARK: - Timing Data Merge Tests
    
    func testTimingDataMerge_JSONValue_ReplacesLineEntries() {
        let base = JSONValue.object([
            "timingData": .object([
                "sessionTime": .string("1:23:45"),
                "lines": .object([
                    "1": .object([
                        "position": .int(1),
                        "lapTime": .string("1:21.345"),
                        "gap": .string("")
                    ]),
                    "44": .object([
                        "position": .int(2),
                        "lapTime": .string("1:21.456"),
                        "gap": .string("+0.111")
                    ])
                ])
            ])
        ])
        
        let update = JSONValue.object([
            "timingData": .object([
                "sessionTime": .string("1:24:00"),
                "lines": .object([
                    "1": .object([
                        "position": .int(1),
                        "lapTime": .string("1:21.123"),
                        "gap": .string(""),
                        "bestLap": .bool(true)  // New field
                    ])
                ])
            ])
        ])
        
        let merged = DataTransformationJSONValue.mergeStates(base, with: update)
        
        // Session time should be updated
        XCTAssertEqual(merged["timingData"]?["sessionTime"]?.stringValue, "1:24:00")
        
        // Line 1 should be completely replaced
        let line1 = merged["timingData"]?["lines"]?["1"]
        XCTAssertEqual(line1?["lapTime"]?.stringValue, "1:21.123")
        XCTAssertEqual(line1?["bestLap"]?.boolValue, true)
        
        // Line 44 should remain unchanged
        let line44 = merged["timingData"]?["lines"]?["44"]
        XCTAssertEqual(line44?["lapTime"]?.stringValue, "1:21.456")
        XCTAssertNil(line44?["bestLap"])
    }
    
    // MARK: - Array Merge Tests
    
    func testRaceControlMessagesMerge_JSONValue_ReplacesEntireArray() {
        let base = JSONValue.object([
            "raceControlMessages": .array([
                .object(["message": .string("Track is wet"), "flag": .string("YELLOW")]),
                .object(["message": .string("Safety car deployed"), "flag": .string("SC")])
            ])
        ])
        
        let update = JSONValue.object([
            "raceControlMessages": .array([
                .object(["message": .string("Track is clear"), "flag": .string("GREEN")])
            ])
        ])
        
        let merged = DataTransformationJSONValue.mergeStates(base, with: update)
        
        // Array should be completely replaced
        if case .array(let messages) = merged["raceControlMessages"] {
            XCTAssertEqual(messages.count, 1)
            XCTAssertEqual(messages[0]["message"]?.stringValue, "Track is clear")
        } else {
            XCTFail("Expected raceControlMessages to be an array")
        }
    }
    
    func testArrayExtension_JSONValue() {
        let base = JSONValue.object([
            "customArray": .array([
                .string("first"),
                .string("second")
            ])
        ])
        
        let update = JSONValue.object([
            "customArray": .array([
                .string("third"),
                .string("fourth")
            ])
        ])
        
        let merged = DataTransformationJSONValue.mergeStates(base, with: update)
        
        // Arrays should be extended by default
        if case .array(let items) = merged["customArray"] {
            XCTAssertEqual(items.count, 4)
            XCTAssertEqual(items[0].stringValue, "first")
            XCTAssertEqual(items[3].stringValue, "fourth")
        } else {
            XCTFail("Expected customArray to be an array")
        }
    }
    
    // MARK: - Nested Object Merge Tests
    
    func testNestedObjectMerge_JSONValue_RecursivelyMerges() {
        let base = JSONValue.object([
            "sessionInfo": .object([
                "meeting": .object([
                    "name": .string("Monaco Grand Prix"),
                    "location": .string("Monte Carlo")
                ]),
                "type": .string("Race")
            ])
        ])
        
        let update = JSONValue.object([
            "sessionInfo": .object([
                "meeting": .object([
                    "location": .string("Monte Carlo, Monaco"),
                    "country": .string("Monaco")
                ])
            ])
        ])
        
        let merged = DataTransformationJSONValue.mergeStates(base, with: update)
        
        // Meeting should be recursively merged
        let meeting = merged["sessionInfo"]?["meeting"]
        XCTAssertEqual(meeting?["name"]?.stringValue, "Monaco Grand Prix")  // Preserved
        XCTAssertEqual(meeting?["location"]?.stringValue, "Monte Carlo, Monaco")  // Updated
        XCTAssertEqual(meeting?["country"]?.stringValue, "Monaco")  // Added
        
        // Type should be preserved
        XCTAssertEqual(merged["sessionInfo"]?["type"]?.stringValue, "Race")
    }
    
    // MARK: - Key Transformation Tests
    
    func testTransformKeys_JSONValue() {
        let input = JSONValue.object([
            "driver_list": .object([
                "racing_number": .string("1"),
                "first_name": .string("Max")
            ]),
            "_kf": .string("should_be_skipped"),
            "nested_array": .array([
                .object(["inner_value": .int(123)])
            ])
        ])
        
        let transformed = DataTransformationJSONValue.transformKeys(input)
        
        // Check top level keys
        XCTAssertNotNil(transformed["driverList"])
        XCTAssertNil(transformed["driver_list"])
        XCTAssertNil(transformed["_kf"])
        
        // Check nested object keys
        let driverList = transformed["driverList"]
        XCTAssertNotNil(driverList?["racingNumber"])
        XCTAssertNotNil(driverList?["firstName"])
        
        // Check array transformation
        if case .array(let array) = transformed["nestedArray"],
           let firstItem = array.first {
            XCTAssertNotNil(firstItem["innerValue"])
            XCTAssertEqual(firstItem["innerValue"]?.intValue, 123)
        } else {
            XCTFail("Expected nestedArray to be an array")
        }
    }
    
    // MARK: - Edge Case Tests
    
    func testMergeWithNullValues() {
        let base = JSONValue.object([
            "value": .string("original")
        ])
        
        let update = JSONValue.object([
            "value": .null(NSNull())
        ])
        
        let merged = DataTransformationJSONValue.mergeStates(base, with: update)
        
        // Null should replace the original value
        if case .null = merged["value"] {
            // Success
        } else {
            XCTFail("Expected value to be null")
        }
    }
    
    func testMergeFromDictionaries() {
        let base: [String: Any] = [
            "driverList": [
                "1": ["firstName": "Max"]
            ]
        ]
        
        let update: [String: Any] = [
            "driverList": [
                "44": ["firstName": "Lewis"]
            ]
        ]
        
        let merged = DataTransformationJSONValue.mergeFromDictionaries(base, with: update)
        
        // Both drivers should exist after merge
        XCTAssertNotNil(merged["driverList"]?["1"])
        XCTAssertNotNil(merged["driverList"]?["44"])
    }
}