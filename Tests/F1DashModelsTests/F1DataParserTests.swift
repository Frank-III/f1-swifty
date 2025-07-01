import XCTest
@testable import F1DashModels

final class F1DataParserTests: XCTestCase {
    
    func testParseGap() {
        XCTAssertEqual(F1DataParser.parseGap(""), 0)
        XCTAssertEqual(F1DataParser.parseGap("+0.273"), 273)
        XCTAssertEqual(F1DataParser.parseGap("1L"), 0)
        XCTAssertEqual(F1DataParser.parseGap("20L"), 0)
        XCTAssertEqual(F1DataParser.parseGap("LAP1"), 0)
        XCTAssertEqual(F1DataParser.parseGap("+1.500"), 1500)
    }
    
    func testParseLaptime() {
        XCTAssertEqual(F1DataParser.parseLaptime(""), 0)
        XCTAssertEqual(F1DataParser.parseLaptime("1:21.306"), 81306)
        XCTAssertEqual(F1DataParser.parseLaptime("0:59.123"), 59123)
        XCTAssertEqual(F1DataParser.parseLaptime("2:00.000"), 120000)
    }
    
    func testParseSector() {
        XCTAssertEqual(F1DataParser.parseSector(""), 0)
        XCTAssertEqual(F1DataParser.parseSector("26.259"), 26259)
        XCTAssertEqual(F1DataParser.parseSector("30.000"), 30000)
        XCTAssertEqual(F1DataParser.parseSector("invalid"), 0)
    }
    
    func testFormatLaptime() {
        XCTAssertEqual(F1DataParser.formatLaptime(0), "")
        XCTAssertEqual(F1DataParser.formatLaptime(81306), "1:21.306")
        XCTAssertEqual(F1DataParser.formatLaptime(59123), "0:59.123")
        XCTAssertEqual(F1DataParser.formatLaptime(120000), "2:00.000")
    }
    
    func testFormatGap() {
        XCTAssertEqual(F1DataParser.formatGap(0), "")
        XCTAssertEqual(F1DataParser.formatGap(273), "+0.273")
        XCTAssertEqual(F1DataParser.formatGap(1500), "+1.500")
    }
}