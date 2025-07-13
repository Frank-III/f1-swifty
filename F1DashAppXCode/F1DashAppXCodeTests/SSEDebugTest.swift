//
//  SSEDebugTest.swift
//  F1DashAppXCodeTests
//
//  Debug test for SSE connection issues
//

import XCTest
@testable import F1DashAppXCode
import EventSource

final class SSEDebugTest: XCTestCase {
    
    func testDirectEventSourceConnection() async throws {
        print("=== Starting Direct EventSource Test ===")
        
        let expectation = XCTestExpectation(description: "EventSource connection")
        let url = URL(string: "http://127.0.0.1:8080/v1/live/sse")!
        
        print("Test: Creating EventSource with URL: \(url)")
        let eventSource = EventSource(url: url)
        
        var messageCount = 0
        
        eventSource.onOpen = {
            print("Test: ✅ EventSource opened successfully!")
            print("Test: onOpen callback triggered")
        }
        
        eventSource.onMessage = { event in
            messageCount += 1
            print("Test: 📨 Message #\(messageCount)")
            print("  - Event type: \(event.event ?? "none")")
            print("  - Data length: \(event.data.count) characters")
            print("  - First 100 chars: \(String(event.data.prefix(100)))...")
            
            if messageCount == 1 {
                expectation.fulfill()
            }
            
            if messageCount >= 3 {
                Task {
                    await eventSource.close()
                }
            }
        }
        
        eventSource.onError = { error in
            if let error = error {
                print("Test: ❌ EventSource error: \(error)")
                print("  - Error type: \(type(of: error))")
                print("  - Error description: \(error.localizedDescription)")
            } else {
                print("Test: EventSource closed (no error)")
            }
        }
        
        print("Test: Waiting for connection...")
        
        await fulfillment(of: [expectation], timeout: 10.0)
        
        // Keep listening for a bit
        try await Task.sleep(for: .seconds(3))
        
        print("Test: Closing EventSource")
        await eventSource.close()
        
        print("Test: Total messages received: \(messageCount)")
    }
    
    func testURLConnection() async throws {
        print("=== Testing Basic URL Connection ===")
        
        let url = URL(string: "http://127.0.0.1:8080/v1/live/sse")!
        var request = URLRequest(url: url)
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        
        print("Test: Attempting connection to: \(url)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Test: Response status: \(httpResponse.statusCode)")
                print("Test: Response headers: \(httpResponse.allHeaderFields)")
            }
            
            let dataString = String(data: data, encoding: .utf8) ?? "Unable to decode"
            print("Test: Response data (first 500 chars): \(dataString.prefix(500))")
            
        } catch {
            print("Test: Connection error: \(error)")
            print("Test: Error type: \(type(of: error))")
            
            if let urlError = error as? URLError {
                print("Test: URLError code: \(urlError.code)")
                print("Test: URLError description: \(urlError.localizedDescription)")
            }
        }
    }
    
    func testSSEClientDebug() async throws {
        print("=== Testing SSEClient with Debug Info ===")
        
        let client = SSEClient()
        
        print("Test: Creating SSEClient")
        
        do {
            print("Test: Calling connect()...")
            try await client.connect()
            print("Test: Connect() completed")
            
            print("Test: Starting message listener...")
            
            Task {
                var count = 0
                for await message in await client.messages {
                    count += 1
                    print("Test: Received message #\(count)")
                    
                    switch message {
                    case .initial(let data):
                        print("Test: Initial state with \(data.count) keys")
                    case .update(let data):
                        print("Test: Update with keys: \(data.keys)")
                    case .error(_):
                      print("Test: failed")
                    }
                    
                    if count >= 3 {
                        break
                    }
                }
                print("Test: Message listener ended")
            }
            
            // Wait for messages
            try await Task.sleep(for: .seconds(5))
            
            print("Test: Disconnecting...")
            await client.disconnect()
            print("Test: Disconnected")
            
        } catch {
            print("Test: Error: \(error)")
        }
    }
}
