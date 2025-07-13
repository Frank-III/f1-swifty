import Foundation
import Hummingbird
import HummingbirdWebSocket
import Logging
import F1DashModels

/// Manages WebSocket connections and broadcasts F1 data to clients
public struct WebSocketManager: Sendable {
    
    private static let logger = Logger(label: "WebSocketManager")
    
    // MARK: - Public Interface
    
    /// Create WebSocket upgrade handler for Hummingbird
    internal static func createWebSocketHandler(
        sessionStateCache: SessionStateCache
    ) -> @Sendable (WebSocketInboundStream, WebSocketOutboundWriter, any WebSocketContext) async -> Void {
        
        return { inbound, outbound, context in
            let clientId = UUID()
            let logger = Logger(label: "WebSocketClient-\(clientId)")
            
            logger.info("New WebSocket client connected")
            
            // Send initial state
            await sendInitialState(
                outbound: outbound,
                sessionStateCache: sessionStateCache
            )
            
            // Start listening for state updates
            let (subscriptionId, updateStream) = await sessionStateCache.subscribeToUpdates()
            
            // Handle client disconnection
            defer {
                Task {
                    await sessionStateCache.unsubscribe(id: subscriptionId)
                    logger.info("WebSocket client disconnected")
                }
            }
            
            // Process incoming messages and outgoing updates
            do {
                try await withThrowingTaskGroup(of: Void.self) { group in
                    
                    // Task 1: Handle incoming messages from client
                    group.addTask {
                        await handleIncomingMessages(
                            inbound: inbound,
                            outbound: outbound,
                        )
                    }
                    
                    // Task 2: Send state updates to client
                    group.addTask {
                        await handleOutgoingUpdates(
                            outbound: outbound,
                            updateStream: updateStream,
                        )
                    }
                    
                    // Wait for any task to complete (usually means disconnection)
                    try await group.next()
                    group.cancelAll()
                }
            } catch {
                logger.error("WebSocket handler error: \(error)")
            }
        }
    }
    
    // MARK: - Private Implementation
    
    private static func sendInitialState(
        outbound: WebSocketOutboundWriter,  
        sessionStateCache: SessionStateCache,
    ) async {
        do {
            let currentState = await sessionStateCache.getCurrentState()
            let message = WebSocketMessage.fullState(currentState)
            
            // Log position data info
            if let positionData = currentState.positionData {
                Self.logger.info("Sending initial state with positionData: \(positionData.position?.count ?? 0) position entries")
                if let firstEntry = positionData.position?.first {
                    Self.logger.info("First position entry has \(firstEntry.entries.count) cars at timestamp \(firstEntry.timestamp)")
                }
            } else {
                Self.logger.warning("Sending initial state WITHOUT positionData")
            }
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(message)
            let text = String(data: data, encoding: .utf8) ?? ""
            
            try await outbound.write(.text(text))
            Self.logger.info("Sent initial state to client (size: \(data.count) bytes)")
            
        } catch {
            Self.logger.error("Failed to send initial state: \(error)")
        }
    }
    
    private static func handleIncomingMessages(
        inbound: WebSocketInboundStream,
        outbound: WebSocketOutboundWriter,
    ) async {
        do {
            for try await frame in inbound {
                switch frame.opcode {
                case .text:
                    let text = String(buffer: frame.data)
                    await handleClientMessage(text: text, logger: Self.logger)
                    
                case .binary:
                    Self.logger.warning("Received unexpected binary message")
                    
                case .continuation:
                    Self.logger.trace("Received continuation frame")
                }
            }
        } catch {
            Self.logger.error("Error handling incoming messages: \(error)")
        }
    }
    
    private static func handleClientMessage(
        text: String,
        logger: Logger
    ) async {
        // For now, we don't expect many client messages
        // In the future, this could handle client preferences, filters, etc.
        logger.debug("Received client message: \(text)")
    }
    
    private static func handleOutgoingUpdates(
        outbound: WebSocketOutboundWriter,
        updateStream: AsyncStream<StateUpdate>,
    ) async {
        do {
            for await update in updateStream {
                let message = WebSocketMessage.stateUpdate(SendableJSON(update.updates))
                
                // Log if position data is in the update
                if update.updates.dictionary.keys.contains("positionData") {
                    Self.logger.info("Sending state update containing positionData")
                }
                
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                
                let data = try encoder.encode(message)
                let text = String(data: data, encoding: .utf8) ?? ""
                
                try await outbound.write(.text(text))
                Self.logger.trace("Sent state update to client with keys: \(update.updates.dictionary.keys.joined(separator: ", "))")
            }
        } catch {
            Self.logger.error("Error sending updates: \(error)")
        }
    }
}

// MARK: - Router Extension

extension Router where Context: WebSocketRequestContext {
    
    /// Add WebSocket route for F1 data streaming
    internal func addWebSocketRoute(
        sessionStateCache: SessionStateCache,
        path: String = "/v1/live"
    ) {
        self.ws(RouterPath(stringLiteral: path)) { inbound, outbound, wsContext in
            let handler = WebSocketManager.createWebSocketHandler(
                sessionStateCache: sessionStateCache
            )
            await handler(inbound, outbound, wsContext)
        }
    }
}

// Add support for basic WebSocket context if needed
extension Router {
    
    /// Add a chat WebSocket route that works with ConnectionManager  
    func addChatWebSocketRoute(
        connectionManager: ConnectionManager,
        path: String = "/chat"
    ) {
        // Note: This is a simplified version for basic WebSocket support
        // The actual implementation would depend on your WebSocket context setup
    }
}

// MARK: - Health Check Support

public struct WebSocketHealthCheck {
    
    /// Check if WebSocket service is healthy
    public static func healthCheck() -> Bool {
        // In a real implementation, this could check:
        // - Number of active connections
        // - Recent message throughput
        // - Error rates
        return true
    }
    
    /// Get WebSocket service statistics
    public static func getStatistics() -> WebSocketStatistics {
        return WebSocketStatistics(
            activeConnections: 0, // This would be tracked in a real implementation
            messagesPerSecond: 0,
            errorRate: 0.0
        )
    }
}

public struct WebSocketStatistics: Sendable, Codable {
    public let activeConnections: Int
    public let messagesPerSecond: Int
    public let errorRate: Double
    
    public init(activeConnections: Int, messagesPerSecond: Int, errorRate: Double) {
        self.activeConnections = activeConnections
        self.messagesPerSecond = messagesPerSecond
        self.errorRate = errorRate
    }
}
