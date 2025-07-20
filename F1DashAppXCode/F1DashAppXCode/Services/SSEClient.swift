//
//  SSEClientEventSource.swift
//  F1-Dash
//
//  Manages Server-Sent Events connection to F1-Dash server using EventSource package
//

import Foundation
import F1DashModels
import EventSource

enum SSEError: Error {
    case connectionFailed
    case invalidMessage
    case disconnected
    case invalidResponse
}

enum SSEMessage {
    case initial([String: Any])
    case update([String: Any])
    case error(Error?)
}

actor SSEClient {
    // MARK: - Properties
    
  
    private var eventSource: EventSource?
    private var serverURL: URL
    
    private var messageStream: AsyncStream<SSEMessage>?
    private var messageContinuation: AsyncStream<SSEMessage>.Continuation?
  
    // MARK: - Initialization
    
    init(baseURL: String = "http://127.0.0.1:3000") {
        self.serverURL = URL(string: "\(baseURL)/v1/live/sse")!
    }
    
    func updateServerURL(_ baseURL: String) {
        self.serverURL = URL(string: "\(baseURL)/v1/live/sse")!
        print("SSEClient: Updated server URL to: \(self.serverURL)")
    }
    
    // MARK: - Connection
    
    func connect() async throws {
        print("SSEClient: Connecting to \(serverURL)")
        
        // Always disconnect first to ensure clean state
        if eventSource != nil {
            print("SSEClient: Cleaning up existing connection")
            await disconnect()
            // Wait a bit for cleanup
            try await Task.sleep(for: .milliseconds(100))
        }
        
        let (stream, continuation) = AsyncStream<SSEMessage>.makeStream()
        self.messageStream = stream
        self.messageContinuation = continuation
        
        // Create EventSource but don't store it yet
        let eventSource = EventSource(url: serverURL)
        
        // Set up event handlers BEFORE storing (to avoid race condition)
        eventSource.onOpen = { [weak self] in
            Task {
                await self?.handleOpen()
            }
        }
        
        eventSource.onMessage = { [weak self] event in
            Task {
                await self?.handleMessage(event)
            }
        }
        
        eventSource.onError = { [weak self] error in
            Task {
                await self?.handleError(error)
            }
        }
        
        // Now store it (this triggers connection)
        self.eventSource = eventSource
        
        // Wait a moment to see if connection succeeds
        try await Task.sleep(for: .milliseconds(500))
    }
    
    func disconnect() async {
        // Store reference before clearing
        
        // Clear references first
        await eventSource?.close()
        eventSource = nil
        
        // Finish the stream
        messageContinuation?.finish()
        messageContinuation = nil
        messageStream = nil
    }
    
    // MARK: - Messages
    
    var messages: AsyncStream<SSEMessage> {
        messageStream ?? AsyncStream { continuation in
            continuation.finish()
        }
    }
    
    // MARK: - Private Implementation
    
    private func handleOpen() async {
        print("SSEClient: Connection established")
    }
    
    private func handleMessage(_ event: EventSource.Event) async {
        // EventSource library sends the event type in the event property
        let eventType = event.event ?? "message"
        
        // For debugging
        print("SSEClient: Received event type: \(eventType)")
        
        // Parse JSON data
        guard let data = event.data.data(using: .utf8) else {
            print("SSEClient: Failed to convert event data to Data")
            return
        }
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("SSEClient: Failed to parse JSON as dictionary")
                return
            }
            
            print("SSEClient: Parsed event with \(json.keys.count) keys: \(json.keys.joined(separator: ", "))")
//            
//            // Check if raceControlMessages is present
//            if let raceControl = json["raceControlMessages"] {
//                print("SSEClient: Found raceControlMessages in data")
//                // Try to see what's in it
//                if let raceControlDict = raceControl as? [String: Any] {
//                    print("SSEClient: raceControlMessages keys: \(raceControlDict.keys.joined(separator: ", "))")
//                    if let messages = raceControlDict["messages"] as? [[String: Any]] {
//                        print("SSEClient: Found \(messages.count) race control messages")
//                    }
//                }
//            }
            
            // Send the appropriate message type through the stream
            if eventType == "initial" {
                messageContinuation?.yield(.initial(json))
            } else if eventType == "update" {
                messageContinuation?.yield(.update(json))
            } else {
                // Handle regular message events as updates
                messageContinuation?.yield(.update(json))
            }
            
        } catch {
            print("SSEClient: JSON parsing error: \(error)")
            print("SSEClient: Raw data: \(event.data.prefix(200))...")
        }
    }
    
    private func handleError(_ error: Error?) async {
        messageContinuation?.yield(.error(error))
        if let error = error {
            print("SSEClient: Error: \(error)")
        } else {
            print("SSEClient: Connection closed")
        }
        messageContinuation?.finish()
    }
}
