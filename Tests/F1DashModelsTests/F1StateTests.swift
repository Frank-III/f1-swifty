import XCTest
@testable import F1DashModels

final class F1StateTests: XCTestCase {
    
    func testF1StateInitialization() {
        let state = F1State()
        
        XCTAssertNil(state.driverList)
        XCTAssertNil(state.timingData)
        XCTAssertNil(state.trackStatus)
        XCTAssertNil(state.sessionInfo)
    }
    
    func testWebSocketMessageEncoding() throws {
        let state = F1State()
        let message = WebSocketMessage.fullState(state)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        
        XCTAssertGreaterThan(data.count, 0)
        
        let decoder = JSONDecoder()
        let decodedMessage = try decoder.decode(WebSocketMessage.self, from: data)
        
        switch decodedMessage {
        case .fullState(let decodedState):
            XCTAssertNil(decodedState.driverList)
        case .stateUpdate, .connectionStatus:
            XCTFail("Expected fullState message")
        }
    }
    
    func testDriverModel() {
        let driver = Driver(
            racingNumber: "44",
            broadcastName: "L HAMILTON",
            fullName: "Lewis Hamilton",
            tla: "HAM",
            line: 1,
            teamName: "Mercedes",
            teamColour: "#00D2BE",
            firstName: "Lewis",
            lastName: "Hamilton",
            reference: "HAMLEW01",
            countryCode: "GBR"
        )
        
        XCTAssertEqual(driver.racingNumber, "44")
        XCTAssertEqual(driver.tla, "HAM")
        XCTAssertEqual(driver.teamName, "Mercedes")
    }
    
    func testTireCompound() {
        XCTAssertEqual(TireCompound.soft.color, "#FF0000")
        XCTAssertEqual(TireCompound.medium.displayName, "Medium")
        XCTAssertEqual(TireCompound.hard.shortCode, "H")
    }
    
    func testTrackFlag() {
        XCTAssertEqual(TrackFlag.green.color, "#00FF00")
        XCTAssertEqual(TrackFlag.yellow.displayName, "Yellow")
        XCTAssertEqual(TrackFlag.red.color, "#FF0000")
    }
}