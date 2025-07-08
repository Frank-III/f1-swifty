import XCTest
@testable import F1DashModels

final class DataTransformationTests: XCTestCase {
    
    // MARK: - Driver List Merge Tests
    
    func testDriverListMerge_ReplacesEntireDriverEntry() {
        var base: [String: Any] = [
            "driverList": [
                "1": [
                    "racingNumber": "1",
                    "firstName": "Max",
                    "lastName": "Verstappen",
                    "teamName": "Red Bull Racing"
                ],
                "44": [
                    "racingNumber": "44",
                    "firstName": "Lewis",
                    "lastName": "Hamilton",
                    "teamName": "Mercedes"
                ]
            ]
        ]
        
        let update: [String: Any] = [
            "driverList": [
                "1": [
                    "racingNumber": "1",
                    "firstName": "Max",
                    "lastName": "Verstappen",
                    "teamName": "Red Bull Racing",
                    "position": 1  // New field
                ]
            ]
        ]
        
        DataTransformation.mergeStates(&base, with: update)
        
        let driverList = base["driverList"] as? [String: Any]
        let driver1 = driverList?["1"] as? [String: Any]
        let driver44 = driverList?["44"] as? [String: Any]
        
        // Driver 1 should be completely replaced with the update (including new position field)
        XCTAssertEqual(driver1?["position"] as? Int, 1)
        XCTAssertEqual(driver1?["firstName"] as? String, "Max")
        
        // Driver 44 should remain unchanged
        XCTAssertEqual(driver44?["firstName"] as? String, "Lewis")
        XCTAssertNil(driver44?["position"])
    }
    
    func testDriverListMerge_AddsNewDrivers() {
        var base: [String: Any] = [
            "driverList": [
                "1": [
                    "racingNumber": "1",
                    "firstName": "Max",
                    "lastName": "Verstappen"
                ]
            ]
        ]
        
        let update: [String: Any] = [
            "driverList": [
                "16": [
                    "racingNumber": "16",
                    "firstName": "Charles",
                    "lastName": "Leclerc"
                ]
            ]
        ]
        
        DataTransformation.mergeStates(&base, with: update)
        
        let driverList = base["driverList"] as? [String: Any]
        
        // Both drivers should exist
        XCTAssertNotNil(driverList?["1"])
        XCTAssertNotNil(driverList?["16"])
        XCTAssertEqual((driverList?["16"] as? [String: Any])?["firstName"] as? String, "Charles")
    }
    
    // MARK: - Timing Data Merge Tests
    
    func testTimingDataMerge_ReplacesLineEntries() {
        var base: [String: Any] = [
            "timingData": [
                "sessionTime": "1:23:45",
                "lines": [
                    "1": [
                        "position": 1,
                        "lapTime": "1:21.345",
                        "gap": ""
                    ],
                    "44": [
                        "position": 2,
                        "lapTime": "1:21.456",
                        "gap": "+0.111"
                    ]
                ]
            ]
        ]
        
        let update: [String: Any] = [
            "timingData": [
                "sessionTime": "1:24:00",
                "lines": [
                    "1": [
                        "position": 1,
                        "lapTime": "1:21.123",  // Updated lap time
                        "gap": "",
                        "bestLap": true  // New field
                    ]
                ]
            ]
        ]
        
        DataTransformation.mergeStates(&base, with: update)
        
        let timingData = base["timingData"] as? [String: Any]
        let lines = timingData?["lines"] as? [String: Any]
        let line1 = lines?["1"] as? [String: Any]
        let line44 = lines?["44"] as? [String: Any]
        
        // Session time should be updated
        XCTAssertEqual(timingData?["sessionTime"] as? String, "1:24:00")
        
        // Line 1 should be completely replaced
        XCTAssertEqual(line1?["lapTime"] as? String, "1:21.123")
        XCTAssertEqual(line1?["bestLap"] as? Bool, true)
        
        // Line 44 should remain unchanged
        XCTAssertEqual(line44?["lapTime"] as? String, "1:21.456")
        XCTAssertNil(line44?["bestLap"])
    }
    
    // MARK: - Array Merge Tests
    
    func testRaceControlMessagesMerge_ReplacesEntireArray() {
        var base: [String: Any] = [
            "raceControlMessages": [
                ["message": "Track is wet", "flag": "YELLOW"],
                ["message": "Safety car deployed", "flag": "SC"]
            ]
        ]
        
        let update: [String: Any] = [
            "raceControlMessages": [
                ["message": "Track is clear", "flag": "GREEN"]
            ]
        ]
        
        DataTransformation.mergeStates(&base, with: update)
        
        let messages = base["raceControlMessages"] as? [[String: Any]]
        
        // Array should be completely replaced, not merged
        XCTAssertEqual(messages?.count, 1)
        XCTAssertEqual(messages?[0]["message"] as? String, "Track is clear")
    }
    
    // MARK: - Nested Object Merge Tests
    
    func testNestedObjectMerge_RecursivelyMerges() {
        var base: [String: Any] = [
            "sessionInfo": [
                "meeting": [
                    "name": "Monaco Grand Prix",
                    "location": "Monte Carlo"
                ],
                "type": "Race"
            ]
        ]
        
        let update: [String: Any] = [
            "sessionInfo": [
                "meeting": [
                    "location": "Monte Carlo, Monaco",  // Updated
                    "country": "Monaco"  // New field
                ]
            ]
        ]
        
        DataTransformation.mergeStates(&base, with: update)
        
        let sessionInfo = base["sessionInfo"] as? [String: Any]
        let meeting = sessionInfo?["meeting"] as? [String: Any]
        
        // Meeting should be recursively merged
        XCTAssertEqual(meeting?["name"] as? String, "Monaco Grand Prix")  // Preserved
        XCTAssertEqual(meeting?["location"] as? String, "Monte Carlo, Monaco")  // Updated
        XCTAssertEqual(meeting?["country"] as? String, "Monaco")  // Added
        
        // Type should be preserved
        XCTAssertEqual(sessionInfo?["type"] as? String, "Race")
    }
    
    // MARK: - Value Replacement Tests
    
    func testSimpleValueReplacement() {
        var base: [String: Any] = [
            "lapCount": 45,
            "sessionTime": "1:23:45"
        ]
        
        let update: [String: Any] = [
            "lapCount": 46,
            "sessionTime": "1:24:00"
        ]
        
        DataTransformation.mergeStates(&base, with: update)
        
        XCTAssertEqual(base["lapCount"] as? Int, 46)
        XCTAssertEqual(base["sessionTime"] as? String, "1:24:00")
    }
    
    // MARK: - Key Transformation Tests
    
    func testCamelCaseTransformation() {
        XCTAssertEqual(DataTransformation.toCamelCase("snake_case_example"), "snakeCaseExample")
        XCTAssertEqual(DataTransformation.toCamelCase("PascalCase"), "pascalCase")
        XCTAssertEqual(DataTransformation.toCamelCase("alreadyCamelCase"), "alreadyCamelCase")
        XCTAssertEqual(DataTransformation.toCamelCase("single"), "single")
        XCTAssertEqual(DataTransformation.toCamelCase(""), "")
    }
    
    func testTransformKeys() {
        let input: [String: Any] = [
            "driver_list": [
                "racing_number": "1",
                "first_name": "Max"
            ],
            "_kf": "should_be_skipped",
            "nested_object": [
                "inner_value": 123
            ]
        ]
        
        let transformed = DataTransformation.transformKeys(input)
        
        XCTAssertNotNil(transformed["driverList"])
        XCTAssertNil(transformed["driver_list"])
        XCTAssertNil(transformed["_kf"])
        
        let driverList = transformed["driverList"] as? [String: Any]
        XCTAssertNotNil(driverList?["racingNumber"])
        XCTAssertNotNil(driverList?["firstName"])
        
        let nestedObject = transformed["nestedObject"] as? [String: Any]
        XCTAssertEqual(nestedObject?["innerValue"] as? Int, 123)
    }
}