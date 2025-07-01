import XCTest
@testable import F1DashModels

final class DataTransformationTests: XCTestCase {
    
    func testToCamelCase() {
        XCTAssertEqual(DataTransformation.toCamelCase("snake_case"), "snakeCase")
        XCTAssertEqual(DataTransformation.toCamelCase("timing_data"), "timingData")
        XCTAssertEqual(DataTransformation.toCamelCase("simple"), "simple")
        XCTAssertEqual(DataTransformation.toCamelCase("multiple_word_example"), "multipleWordExample")
    }
    
    func testTransformKeys() {
        let input: [String: Any] = [
            "timing_data": [
                "driver_number": "44",
                "lap_time": "1:23.456"
            ],
            "track_status": "Green",
            "_kf": true // Should be filtered out
        ]
        
        let result = DataTransformation.transformKeys(input)
        
        XCTAssertTrue(result.keys.contains("timingData"))
        XCTAssertTrue(result.keys.contains("trackStatus"))
        XCTAssertFalse(result.keys.contains("_kf"))
        
        if let timingData = result["timingData"] as? [String: Any] {
            XCTAssertTrue(timingData.keys.contains("driverNumber"))
            XCTAssertTrue(timingData.keys.contains("lapTime"))
        } else {
            XCTFail("timingData should be a dictionary")
        }
    }
    
    func testMergeStates() {
        var base: [String: Any] = [
            "driverList": [
                "44": ["name": "Hamilton"]
            ],
            "timingData": [
                "lap": 1
            ]
        ]
        
        let update: [String: Any] = [
            "driverList": [
                "77": ["name": "Bottas"]
            ],
            "timingData": [
                "lap": 2
            ]
        ]
        
        DataTransformation.mergeStates(&base, with: update)
        
        if let driverList = base["driverList"] as? [String: Any] {
            XCTAssertNotNil(driverList["44"])
            XCTAssertNotNil(driverList["77"])
        } else {
            XCTFail("driverList should be preserved and merged")
        }
        
        if let timingData = base["timingData"] as? [String: Any],
           let lap = timingData["lap"] as? Int {
            XCTAssertEqual(lap, 2) // Should be updated
        } else {
            XCTFail("timingData lap should be updated")
        }
    }
}