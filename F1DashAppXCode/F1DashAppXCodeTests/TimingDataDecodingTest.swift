//
//  TimingDataDecodingTest.swift
//  F1DashAppXCodeTests
//
//  Test for TimingData decoding with mixed status types
//

import XCTest
@testable import F1DashAppXCode
import F1DashModels

final class TimingDataDecodingTest: XCTestCase {
    
    func testLapTimeValueWithBooleanStatus() throws {
        // Test data where status is a boolean false instead of int
        let json = """
        {
            "value": "1:23.456",
            "status": false,
            "overallFastest": false,
            "personalFastest": false
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        // This should not throw anymore with our custom decoder
        let lapTime = try decoder.decode(LapTimeValue.self, from: data)
        
        XCTAssertEqual(lapTime.value, "1:23.456")
        XCTAssertEqual(lapTime.status, 0) // false should be converted to 0
        XCTAssertEqual(lapTime.overallFastest, false)
        XCTAssertEqual(lapTime.personalFastest, false)
    }
    
    func testLapTimeValueWithIntegerStatus() throws {
        // Test data where status is an integer as expected
        let json = """
        {
            "value": "1:23.456",
            "status": 2064,
            "overallFastest": false,
            "personalFastest": true
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        let lapTime = try decoder.decode(LapTimeValue.self, from: data)
        
        XCTAssertEqual(lapTime.value, "1:23.456")
        XCTAssertEqual(lapTime.status, 2064)
        XCTAssertEqual(lapTime.overallFastest, false)
        XCTAssertEqual(lapTime.personalFastest, true)
    }
    
    func testSectorWithBooleanStatus() throws {
        // Test sector data where status is boolean
        let json = """
        {
            "stopped": false,
            "value": "23.456",
            "status": false,
            "overallFastest": false,
            "personalFastest": false,
            "segments": []
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        let sector = try decoder.decode(Sector.self, from: data)
        
        XCTAssertEqual(sector.value, "23.456")
        XCTAssertEqual(sector.status, 0) // false should be converted to 0
        XCTAssertEqual(sector.stopped, false)
    }
    
    func testSegmentWithBooleanStatus() throws {
        // Test segment data where status is boolean
        let json = """
        {
            "status": false
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        let segment = try decoder.decode(Segment.self, from: data)
        
        XCTAssertEqual(segment.status, 0) // false should be converted to 0
    }
    
    func testFullTimingDataWithMixedStatuses() throws {
        // Test a more complex scenario with full timing data
        let json = """
        {
            "lines": {
                "77": {
                    "racingNumber": "77",
                    "line": 5,
                    "sectors": [
                        {
                            "stopped": false,
                            "value": "26.789",
                            "status": false,
                            "overallFastest": false,
                            "personalFastest": false
                        }
                    ],
                    "lastLapTime": {
                        "value": "1:23.456",
                        "status": false,
                        "overallFastest": false,
                        "personalFastest": false
                    }
                }
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        // This should decode successfully now
        let timingData = try decoder.decode(TimingData.self, from: data)
        
        XCTAssertNotNil(timingData.lines["77"])
        let driver = timingData.lines["77"]!
        XCTAssertEqual(driver.racingNumber, "77")
        XCTAssertEqual(driver.line, 5)
        
        // Check sector
        XCTAssertEqual(driver.sectors.count, 1)
        XCTAssertEqual(driver.sectors[0].status, 0)
        
        // Check last lap time
        XCTAssertNotNil(driver.lastLapTime)
        XCTAssertEqual(driver.lastLapTime?.status, 0)
    }
    
    func testTimingDataDriverWithBooleanLine() throws {
        // Test when line field is a boolean false instead of int
        let json = """
        {
            "lines": {
                "1": {
                    "racingNumber": "1",
                    "line": false,
                    "gapToLeader": "+1.234"
                }
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        // This should not throw anymore with our custom decoder
        let timingData = try decoder.decode(TimingData.self, from: data)
        
        XCTAssertNotNil(timingData.lines["1"])
        let driver = timingData.lines["1"]!
        XCTAssertEqual(driver.racingNumber, "1")
        XCTAssertNil(driver.line) // false should be converted to nil
        XCTAssertEqual(driver.gapToLeader, "+1.234")
    }
    
    func testTimingStatsDriverWithBooleanLine() throws {
        // Test when line field is a boolean in TimingStats
        let json = """
        {
            "lines": {
                "1": {
                    "racingNumber": "1",
                    "line": false,
                    "bestSectors": []
                }
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        // This should decode successfully now
        let timingStats = try decoder.decode(TimingStats.self, from: data)
        
        XCTAssertNotNil(timingStats.lines["1"])
        let driver = timingStats.lines["1"]!
        XCTAssertEqual(driver.racingNumber, "1")
        XCTAssertNil(driver.line) // false should be converted to nil
    }
    
    func testTimingAppDataDriverWithBooleanLine() throws {
        // Test when line field is a boolean in TimingAppData
        let json = """
        {
            "lines": {
                "1": {
                    "racingNumber": "1",
                    "line": false,
                    "gridPos": "1",
                    "stints": []
                }
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        // This should decode successfully now
        let timingAppData = try decoder.decode(TimingAppData.self, from: data)
        
        XCTAssertNotNil(timingAppData.lines["1"])
        let driver = timingAppData.lines["1"]!
        XCTAssertEqual(driver.racingNumber, "1")
        XCTAssertEqual(driver.line, 0) // false should be converted to 0 (since line is not optional)
        XCTAssertEqual(driver.gridPos, "1")
    }
}