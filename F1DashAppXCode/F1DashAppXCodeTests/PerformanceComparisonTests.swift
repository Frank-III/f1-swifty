//
//  PerformanceComparisonTests.swift
//  F1DashAppXCodeTests
//
//  Performance comparison between original and optimized implementations
//

import XCTest
@testable import F1DashAppXCode

final class PerformanceComparisonTests: XCTestCase {
    
    // MARK: - Test Data
    
    private func generateTestMessage(index: Int) -> [String: Any] {
        return [
            "timingData": [
                "lines": [
                    "1": [
                        "position": index,
                        "time": "\(index).123",
                        "status": "OnTrack"
                    ],
                    "44": [
                        "position": index + 1,
                        "time": "\(index).456",
                        "status": "OnTrack"
                    ]
                ]
            ],
            "carData": [
                "1": [
                    "speed": 320 + index,
                    "throttle": 100,
                    "brake": 0
                ],
                "44": [
                    "speed": 318 + index,
                    "throttle": 95,
                    "brake": 5
                ]
            ]
        ]
    }
    
    // MARK: - Buffer Performance Tests
    
    func testOriginalBufferPerformance() async {
        let buffer = DataBufferActor()
        
        measure {
            let expectation = self.expectation(description: "Buffer processing")
            
            Task {
                // Add 1000 messages
                for i in 0..<1000 {
                    await buffer.addMessage(generateTestMessage(index: i), delay: 0)
                }
                
                // Get all ready messages
                let messages = await buffer.getReadyMessages()
                XCTAssertEqual(messages.count, 1000)
                
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func testOptimizedBufferPerformance() async {
        let buffer = OptimizedDataBuffer()
        
        measure {
            let expectation = self.expectation(description: "Buffer processing")
            
            Task {
                // Add 1000 messages
                for i in 0..<1000 {
                    await buffer.push(generateTestMessage(index: i))
                }
                
                // Get latest message
                let latest = await buffer.latest()
                XCTAssertNotNil(latest)
                
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - Binary Search Performance Test
    
    func testOptimizedBufferBinarySearchPerformance() async {
        let buffer = OptimizedDataBuffer()
        
        // Pre-populate buffer with 10000 messages over 10 seconds
        for i in 0..<10000 {
            let timestamp = Date().timeIntervalSince1970 * 1000 - Double(10000 - i)
            await buffer.push(generateTestMessage(index: i), timestamp: timestamp)
        }
        
        measure {
            let expectation = self.expectation(description: "Binary search")
            
            Task {
                // Perform 1000 delayed lookups
                for _ in 0..<1000 {
                    let delay = Double.random(in: 0...10)
                    _ = await buffer.delayed(delay)
                }
                
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - State Update Performance Tests
    
    @MainActor
    func testOriginalStateUpdatePerformance() {
        let state = LiveSessionStateNew()
        
        measure {
            // Apply 100 partial updates
            for i in 0..<100 {
                state.applyPartialUpdate(generateTestMessage(index: i))
            }
            
            // Access computed properties
            _ = state.timingData
            _ = state.carData
            _ = state.sortedDrivers
        }
    }
    
    @MainActor
    func testOptimizedStateUpdatePerformance() {
        let state = OptimizedLiveSessionState()
        
        measure {
            // Apply 100 partial updates (will be batched)
            for i in 0..<100 {
                state.applyPartialUpdate(generateTestMessage(index: i))
            }
            
            // Access computed properties (will use cache)
            _ = state.timingData
            _ = state.carData
            _ = state.sortedDrivers
        }
    }
    
    // MARK: - Decoding Performance Tests
    
    @MainActor
    func testRepeatedDecodingPerformance() {
        let state = LiveSessionStateNew()
        state.setFullState([
            "timingData": generateTestMessage(index: 1)["timingData"]!,
            "carData": generateTestMessage(index: 1)["carData"]!
        ])
        
        measure {
            // Access same properties 1000 times (each triggers decoding)
            for _ in 0..<1000 {
                _ = state.timingData
                _ = state.carData
            }
        }
    }
    
    @MainActor
    func testCachedDecodingPerformance() {
        let state = OptimizedLiveSessionState()
        state.setFullState([
            "timingData": generateTestMessage(index: 1)["timingData"]!,
            "carData": generateTestMessage(index: 1)["carData"]!
        ])
        
        measure {
            // Access same properties 1000 times (uses cache after first decode)
            for _ in 0..<1000 {
                _ = state.timingData
                _ = state.carData
            }
        }
    }
}