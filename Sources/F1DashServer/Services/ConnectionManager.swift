import Foundation
import Hummingbird
import HummingbirdWebSocket
import Logging
import F1DashModels
import ServiceLifecycle

/// Manages WebSocket connections and broadcasts F1 data to clients
final actor ConnectionManager: Service {
    
    private let logger = Logger(label: "ConnectionManager")
    private let clients: ClientStorage = ClientStorage()
    private var messageCounter: Int = 0
    
    // MARK: - Service Lifecycle
    
    func run() async throws {
        logger.info("ConnectionManager service started")
        
        // Keep the service running
        try await withTaskCancellationHandler {
            while !Task.isCancelled {
                try await Task.sleep(for: .seconds(60))
                await logStatistics()
            }
        } onCancel: {
            Task {
                await self.shutdownAllConnections()
            }
        }
    }
    
    // MARK: - Client Management
    
    /// Add a new WebSocket client
    func addUser(
        name: String,
        inbound: WebSocketInboundStream,
        outbound: WebSocketOutboundWriter
    ) async -> AsyncStream<ConnectionOutput> {
        
        let clientId = UUID().uuidString
        logger.info("Adding new client: \(name) (\(clientId))")
        
        let client = ClientConnection(
            id: clientId,
            name: name,
            outbound: outbound
        )
        
        await clients.addClient(client)
        
        // Create output stream for this client
        let (stream, continuation) = AsyncStream.makeStream(of: ConnectionOutput.self)
        
        // Handle client messages in background
        Task {
            await handleClientMessages(
                clientId: clientId,
                inbound: inbound,
                continuation: continuation
            )
        }
        
        // Send welcome message
        Task {
            await sendToClient(
                clientId: clientId,
                message: "Welcome to F1-Dash, \(name)!"
            )
        }
        
        return stream
    }
    
    /// Remove a client
    func removeClient(id: String) async {
        if let client = await clients.removeClient(id: id) {
            logger.info("Removing client: \(client.name) (\(id))")
        }
    }
    
    // MARK: - F1 Data Broadcasting
    
    /// Broadcast F1 data to all connected clients
    func broadcastF1Data(_ data: Data, topic: String) async {
        messageCounter += 1
        
        let message = F1WebSocketMessage(
            type: "f1_data",
            topic: topic,
            data: data,
            timestamp: Date()
        )
        
        await broadcastMessage(message)
    }
    
    /// Broadcast raw message from SignalR
    func broadcastRawMessage(_ rawMessage: RawMessage) async {
        let data = rawMessage.data
        let topic = rawMessage.topic
        
        await broadcastF1Data(data, topic: topic)
        
        logger.trace("Broadcasted F1 data: topic=\(topic), size=\(data.count) bytes")
    }
    
    // MARK: - Private Implementation
    
    private func handleClientMessages(
        clientId: String,
        inbound: WebSocketInboundStream,
        continuation: AsyncStream<ConnectionOutput>.Continuation
    ) async {
        do {
            for try await frame in inbound {
                switch frame.opcode {
                case .text:
                    let text = String(buffer: frame.data)
                    await handleClientTextMessage(clientId: clientId, text: text)
                    
                case .binary:
                    logger.trace("Received binary frame from client \(clientId)")
                    
                default:
                    logger.trace("Received frame with opcode: \(frame.opcode)")
                }
            }
        } catch {
            logger.error("Error handling client \(clientId) messages: \(error)")
            continuation.yield(.close("Connection error: \(error.localizedDescription)"))
            continuation.finish()
            await removeClient(id: clientId)
        }
    }
    
    private func handleClientTextMessage(clientId: String, text: String) async {
        logger.debug("Received message from client \(clientId): \(text)")
        
        // Handle client commands
        if text.hasPrefix("/") {
            await handleClientCommand(clientId: clientId, command: text)
        } else {
            // For now, just echo back to the client
            await sendToClient(clientId: clientId, message: "Echo: \(text)")
        }
    }
    
    private func handleClientCommand(clientId: String, command: String) async {
        switch command {
        case "/status":
            let clientCount = await clients.getClientCount()
            let status = "Connected clients: \(clientCount), Messages sent: \(messageCounter)"
            await sendToClient(clientId: clientId, message: status)
            
        case "/help":
            let help = "Available commands: /status, /help, /quit"
            await sendToClient(clientId: clientId, message: help)
            
        case "/quit":
            await sendToClient(clientId: clientId, message: "Goodbye!")
            await removeClient(id: clientId)
            
        default:
            await sendToClient(clientId: clientId, message: "Unknown command: \(command)")
        }
    }
    
    private func sendToClient(clientId: String, message: String) async {
        guard let client = await clients.getClient(id: clientId) else { return }
        
        do {
            try await client.outbound.write(.text(message))
        } catch {
            logger.error("Failed to send message to client \(clientId): \(error)")
            await removeClient(id: clientId)
        }
    }
    
    private func broadcastMessage(_ message: F1WebSocketMessage) async {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let jsonData = try encoder.encode(message)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            
            // Send to all connected clients
            let allClients = await clients.getAllClients()
            for (clientId, client) in allClients {
                do {
                    try await client.outbound.write(.text(jsonString))
                } catch {
                    logger.error("Failed to broadcast to client \(clientId): \(error)")
                    await removeClient(id: clientId)
                }
            }
            
            let clientCount = await clients.getClientCount()
            if clientCount > 0 {
                logger.trace("Broadcasted message to \(clientCount) clients")
            }
            
        } catch {
            logger.error("Failed to encode broadcast message: \(error)")
        }
    }
    
    private func logStatistics() async {
        let clientCount = await clients.getClientCount()
        logger.info("ConnectionManager stats - Clients: \(clientCount), Messages: \(messageCounter)")
    }
    
    private func shutdownAllConnections() async {
        logger.info("Shutting down all WebSocket connections")
        
        let allClients = await clients.getAllClients()
        for (clientId, client) in allClients {
            do {
                try await client.outbound.write(.text("Server shutting down"))
                try await client.outbound.close(.goingAway, reason: "Server is shutting down")
            } catch {
                logger.error("Error closing client \(clientId): \(error)")
            }
        }
        
        await clients.removeAllClients()
    }
}

// MARK: - Supporting Types

actor ClientStorage {
    private var clients: [String: ClientConnection] = [:]
    
    func addClient(_ client: ClientConnection) {
        clients[client.id] = client
    }
    
    func removeClient(id: String) -> ClientConnection? {
        return clients.removeValue(forKey: id)
    }
    
    func getClient(id: String) -> ClientConnection? {
        return clients[id]
    }
    
    func getAllClients() -> [(String, ClientConnection)] {
        return Array(clients)
    }
    
    func getClientCount() -> Int {
        return clients.count
    }
    
    func removeAllClients() {
        clients.removeAll()
    }
}

struct ClientConnection: Sendable {
    let id: String
    let name: String
    let outbound: WebSocketOutboundWriter
    let connectedAt: Date
    
    init(id: String, name: String, outbound: WebSocketOutboundWriter) {
        self.id = id
        self.name = name
        self.outbound = outbound
        self.connectedAt = Date()
    }
}

struct F1WebSocketMessage: Codable, Sendable {
    let type: String
    let topic: String
    let data: Data
    let timestamp: Date
}

enum ConnectionOutput: Sendable {
    case message(String)
    case close(String)
}
