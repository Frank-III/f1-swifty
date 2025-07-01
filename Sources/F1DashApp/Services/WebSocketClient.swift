//
//  WebSocketClient.swift
//  F1-Dash
//
//  Manages WebSocket connection to F1-Dash server
//

import Foundation
import F1DashModels

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
        
        // Start receiving messages
        Task {
            await receiveMessages()
        }
        
        // Send initial ping
        webSocketTask?.sendPing(pongReceiveHandler: { _ in })
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
                    }
                case .string(let text):
                    if let data = text.data(using: .utf8),
                       let wsMessage = try? JSONDecoder().decode(WebSocketMessage.self, from: data) {
                        messageContinuation?.yield(wsMessage)
                    }
                @unknown default:
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

