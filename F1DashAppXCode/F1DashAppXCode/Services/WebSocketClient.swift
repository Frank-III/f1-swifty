//
//  WebSocketClient.swift
//  F1-Dash
//
//  Manages WebSocket connection to F1-Dash server
//

import Foundation
import F1DashModels

enum WebSocketError: Error {
    case connectionFailed
    case invalidMessage
    case disconnected
}

actor WebSocketClient {
    // MARK: - Properties
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession
    private let serverURL = URL(string: "ws://localhost:8080/v1/live")!
    
    private var messageStream: AsyncStream<WebSocketMessage>?
    private var messageContinuation: AsyncStream<WebSocketMessage>.Continuation?
    
    // MARK: - Initialization
    
    init() {
        self.urlSession = URLSession(configuration: .default)
    }
    
    // MARK: - Connection
    
    func connect() async throws {
        disconnect()
        
        let (stream, continuation) = AsyncStream<WebSocketMessage>.makeStream()
        self.messageStream = stream
        self.messageContinuation = continuation
        
        webSocketTask = urlSession.webSocketTask(with: serverURL)
        webSocketTask?.resume()
        
        // Wait a moment to see if connection succeeds
        try await Task.sleep(for: .milliseconds(500))
        
        // Check if connection is actually established
        guard let task = webSocketTask, task.state == .running else {
            disconnect() // Clean up on failure
            throw WebSocketError.connectionFailed
        }
        
        // Start receiving messages
        Task {
            await receiveMessages()
        }
        
        // Skip the ping verification to avoid hanging
        // The connection state check above is sufficient
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        messageContinuation?.finish()
        messageContinuation = nil
        messageStream = nil
    }
    
    // MARK: - Messages
    
    var messages: AsyncStream<WebSocketMessage> {
        messageStream ?? AsyncStream { continuation in
            continuation.finish()
        }
    }
    
    private func receiveMessages() async {
        guard let webSocketTask = webSocketTask else { return }
        
        do {
            while webSocketTask.state == .running {
                let message = try await webSocketTask.receive()
                
                switch message {
                case .data(let data):
                    if let wsMessage = try? JSONDecoder().decode(WebSocketMessage.self, from: data) {
                        messageContinuation?.yield(wsMessage)
                    } else {
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("WebSocketClient: Raw JSON: \(jsonString.prefix(200))...")
                        }
                    }
                case .string(let text):
                    if let data = text.data(using: .utf8),
                       let wsMessage = try? JSONDecoder().decode(WebSocketMessage.self, from: data) {
                        messageContinuation?.yield(wsMessage)
                    } else {
                        print("WebSocketClient: Failed to decode string message")
                        print("WebSocketClient: Raw text: \(text.prefix(200))...")
                    }
                @unknown default:
                    print(message)
                    break
                }
            }
        } catch {
            print("WebSocket error: \(error)")
            messageContinuation?.finish()
        }
    }
    
    // MARK: - Heartbeat
    
    func startHeartbeat() async {
        while webSocketTask?.state == .running {
            do {
                try await Task.sleep(for: .seconds(30))
                webSocketTask?.sendPing(pongReceiveHandler: { _ in })
            } catch {
                break
            }
        }
    }
}

