//
//  F1DashAppTests.swift
//  F1DashAppTests
//
//  Basic tests for F1DashApp
//

import XCTest
@testable import F1DashApp
@testable import F1DashModels

final class F1DashAppTests: XCTestCase {
    
    func testDriverCreation() {
        let driver = Driver(
            racingNumber: "1",
            broadcastName: "M. VERSTAPPEN",
            fullName: "Max Verstappen",
            tla: "VER",
            line: 1,
            teamName: "Red Bull Racing",
            teamColour: "3671C6",
            firstName: "Max",
            lastName: "Verstappen",
            reference: "VERSTAPPEN",
            headshotUrl: nil,
            countryCode: "NL"
        )
        
        XCTAssertEqual(driver.racingNumber, "1")
        XCTAssertEqual(driver.tla, "VER")
        XCTAssertEqual(driver.id, "1")
    }
    
    func testConnectionStatus() {
        XCTAssertEqual(ConnectionStatus.disconnected.description, "Disconnected")
        XCTAssertEqual(ConnectionStatus.connecting.description, "Connecting...")
        XCTAssertEqual(ConnectionStatus.connected.description, "Connected")
        
        XCTAssertTrue(ConnectionStatus.connected.isConnected)
        XCTAssertFalse(ConnectionStatus.disconnected.isConnected)
    }
    
    func testSettingsStoreDefaults() {
        let settings = SettingsStore()
        
        XCTAssertFalse(settings.launchAtLogin)
        XCTAssertTrue(settings.showNotifications)
        XCTAssertFalse(settings.compactMode)
        XCTAssertEqual(settings.trackMapZoom, 1.0)
        XCTAssertEqual(settings.dataDelay, 0)
        XCTAssertTrue(settings.favoriteDrivers.isEmpty)
    }
    
    func testColorExtension() {
        // Test valid hex color
        let blueColor = Color(hex: "3671C6")
        XCTAssertNotNil(blueColor)
        
        // Test invalid hex color
        let invalidColor = Color(hex: "INVALID")
        XCTAssertNil(invalidColor)
        
        // Test short hex color
        let shortColor = Color(hex: "FFF")
        XCTAssertNotNil(shortColor)
    }
    
    func testWebSocketMessage() throws {
        // Test full state message
        let state = F1State()
        let fullStateMessage = WebSocketMessage.fullState(state)
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(fullStateMessage)
        let decoded = try decoder.decode(WebSocketMessage.self, from: data)
        
        if case .fullState = decoded {
            XCTAssertTrue(true)
        } else {
            XCTFail("Failed to decode full state message")
        }
        
        // Test connection status message
        let statusMessage = WebSocketMessage.connectionStatus(.connected)
        let statusData = try encoder.encode(statusMessage)
        let decodedStatus = try decoder.decode(WebSocketMessage.self, from: statusData)
        
        if case .connectionStatus(let status) = decodedStatus {
            XCTAssertEqual(status, .connected)
        } else {
            XCTFail("Failed to decode connection status message")
        }
    }
}
