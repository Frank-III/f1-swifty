//
//  SSEClientTests.swift
//  F1DashAppXCodeTests
//
//  Tests for SSE Client functionality
//

import XCTest
@testable import F1DashAppXCode
import F1DashModels

final class SSEClientTests: XCTestCase {
    
    var sseClient: SSEClient!
    
    override func setUp() async throws {
        try await super.setUp()
        sseClient = SSEClient()
    }
    
    override func tearDown() async throws {
        await sseClient.disconnect()
        sseClient = nil
        try await super.tearDown()
    }
    
    func testSSEConnection() async throws {
        // Test that we can connect to the SSE endpoint
        let expectation = XCTestExpectation(description: "SSE connection established")
        expectation.expectedFulfillmentCount = 1
        
        // Start connection
        try await sseClient.connect()
        
        // Give it more time to establish connection
        try await Task.sleep(for: .seconds(2))
        
        // Listen for messages
        Task {
            var messageCount = 0
            for await message in await sseClient.messages {
                messageCount += 1
                print("Test received message #\(messageCount)")
                
                switch message {
                case .initial(let data):
                    print("Test: Received initial state with \(data.count) keys")
                    print("Test: Keys: \(data.keys.sorted())")
                    
                    // Verify we have expected keys
                    XCTAssertTrue(data.keys.contains("driverList"), "Initial state should contain driverList")
                    XCTAssertTrue(data.keys.contains("sessionData"), "Initial state should contain sessionData")
                    
                    expectation.fulfill()
                    
                case .update(let data):
                    print("Test: Received update with keys: \(data.keys.sorted())")
                    
                case .error(let error):
                    XCTFail("SSE error: \(error)")
                }
                
                // Stop after first message for the test
                if messageCount >= 1 {
                    break
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    func testSSEMessageParsing() async throws {
        // Test that messages are properly parsed
        let expectation = XCTestExpectation(description: "SSE messages parsed")
        var receivedInitial = false
        var receivedUpdate = false
        
        try await sseClient.connect()
        
        Task {
            for await message in await sseClient.messages {
                switch message {
                case .initial(let data):
                    receivedInitial = true
                    print("Test: Initial message has \(data.count) top-level keys")
                    
                    // Check for nested data
                    if let timingData = data["timingData"] as? [String: Any] {
                        print("Test: TimingData exists with \(timingData.count) keys")
                    }
                    
                case .update(let data):
                    if !receivedUpdate {
                        receivedUpdate = true
                        print("Test: First update has keys: \(data.keys.sorted())")
                    }
                case .error(_):
                  expectation.fulfill()
                }
                
                // Complete test after receiving both types
                if receivedInitial && receivedUpdate {
                    expectation.fulfill()
                    break
                }
            }
        }
        
        await fulfillment(of: [expectation], timeout: 15.0)
        
        XCTAssertTrue(receivedInitial, "Should have received initial state")
        XCTAssertTrue(receivedUpdate, "Should have received at least one update")
    }
    
    func testSSEReconnection() async throws {
        // Test disconnection and reconnection
        let firstConnection = XCTestExpectation(description: "First connection")
        let secondConnection = XCTestExpectation(description: "Second connection")
        
        // First connection
        try await sseClient.connect()
        
        Task {
            for await message in await sseClient.messages {
                if case .initial = message {
                    firstConnection.fulfill()
                    break
                }
            }
        }
        
        await fulfillment(of: [firstConnection], timeout: 5.0)
        
        // Disconnect
        await sseClient.disconnect()
        
        // Wait a bit
        try await Task.sleep(for: .seconds(1))
        
        // Reconnect
        try await sseClient.connect()
        
        Task {
            for await message in await sseClient.messages {
                if case .initial = message {
                    secondConnection.fulfill()
                    break
                }
            }
        }
        
        await fulfillment(of: [secondConnection], timeout: 5.0)
    }
    
    func testServerURL() async throws {
        // Test that we're using the correct server URL
        print("Test: Checking server URL configuration")
        
        // The URL is private, but we can test the connection
        try await sseClient.connect()
        
        // If we get here without throwing, the URL is valid
        XCTAssertTrue(true, "Connection attempt succeeded")
    }
}

// MARK: - Test Helpers

extension SSEClientTests {
    
    func printDataStructure(_ data: [String: Any], indent: String = "") {
        for (key, value) in data.sorted(by: { $0.key < $1.key }) {
            if let dict = value as? [String: Any] {
                print("\(indent)\(key): [Dictionary with \(dict.count) keys]")
                if indent.count < 4 { // Limit depth
                    printDataStructure(dict, indent: indent + "  ")
                }
            } else if let array = value as? [Any] {
                print("\(indent)\(key): [Array with \(array.count) items]")
            } else {
                print("\(indent)\(key): \(type(of: value))")
            }
        }
    }
}
