import Foundation
import Hummingbird
import HTTPTypes
import NIOCore
import Logging
import F1DashModels
import ServiceLifecycle

/// Manages Server-Sent Events connections for F1 data streaming
public struct SSEManager: Sendable {
    
    private static let logger = Logger(label: "SSEManager")
    
    // MARK: - Public Interface
    
    /// Add SSE route to the router
    internal static func addSSERoute<Context: RequestContext>(
        to router: Router<Context>,
        sessionStateCache: SessionStateCache,
        path: String = "/v1/live/sse"
    ) {
        router.get(RouterPath(stringLiteral: path)) { request, context in
            return try await handleSSEConnection(
                request: request,
                context: context,
                sessionStateCache: sessionStateCache
            )
        }
    }
    
    // MARK: - Private Implementation
    
    private static func handleSSEConnection<Context: RequestContext>(
        request: Request,
        context: Context,
        sessionStateCache: SessionStateCache
    ) async throws -> Response {
        
        let clientId = UUID()
        logger.info("New SSE client connected: \(clientId)")
        
        // Create response headers for SSE
        var headers = HTTPFields()
        headers[.contentType] = "text/event-stream"
        headers[.cacheControl] = "no-cache"
        headers[.connection] = "keep-alive"
        headers[.accessControlAllowOrigin] = "*"
        headers[.accessControlAllowMethods] = "GET, OPTIONS"
        headers[.accessControlAllowHeaders] = "Content-Type"
        
        // Create the response body with AsyncSequence
        let response = Response(
            status: .ok,
            headers: headers,
            body: .init { writer in
                let allocator = ByteBufferAllocator()
                
                // Subscribe to updates
                let (subscriptionId, updateStream) = await sessionStateCache.subscribeToUpdates()
                
                // Use withGracefulShutdownHandler for proper cleanup
                try await withGracefulShutdownHandler {
                    // Send initial state
                    await sendInitialState(
                        writer: &writer,
                        allocator: allocator,
                        sessionStateCache: sessionStateCache
                    )
                    
                    // Send heartbeat comment to establish connection
                    let heartbeatBuffer = allocator.buffer(string: ": Connection established\n\n")
                    try await writer.write(heartbeatBuffer)
                    
                    // Stream updates
                    for await update in updateStream {
                        try await sendUpdate(
                            writer: &writer,
                            allocator: allocator,
                            update: update
                        )
                    }
                } onGracefulShutdown: {
                    // Cleanup on graceful shutdown
                    Task {
                        await sessionStateCache.unsubscribe(id: subscriptionId)
                        logger.info("SSE client disconnected: \(clientId)")
                    }
                }
                
                // Finish the stream
                try await writer.finish(nil)
            }
        )
        
        return response
    }
    
    private static func sendInitialState(
        writer: inout some ResponseBodyWriter,
        allocator: ByteBufferAllocator,
        sessionStateCache: SessionStateCache
    ) async {
        do {
            // Get current state as JSON dictionary
            let jsonValue = await sessionStateCache.getCurrentStateAsJSON()
            
            // Log position data info
            if case .object(let dict) = jsonValue,
               let positionData = dict["positionData"],
               case .object(let posDict) = positionData {
                logger.info("Sending initial state with positionData")
                if let positionEntry = posDict["position"],
                   case .array(let positionArray) = positionEntry {
                    logger.info("Position data has \(positionArray.count) entries")
                }
            }
            
            // Create SSE event
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let eventData = try encoder.encode(jsonValue)
            guard let dataString = String(data: eventData, encoding: .utf8) else {
                logger.error("Failed to encode initial state to string")
                return
            }
            
            // Format as SSE event
            let sseEvent = formatSSEEvent(
                event: "initial",
                data: dataString,
                id: nil,
                retry: 3000
            )
            
            // Write to stream
            let buffer = allocator.buffer(string: sseEvent)
            try await writer.write(buffer)
            
            logger.info("Sent initial state via SSE (size: \(eventData.count) bytes)")
            
        } catch {
            logger.error("Failed to send initial state: \(error)")
        }
    }
    
    private static func sendUpdate(
        writer: inout some ResponseBodyWriter,
        allocator: ByteBufferAllocator,
        update: StateUpdate
    ) async throws {
        // Log if position data is in the update
        if case .object(let dict) = update.updates,
           dict.keys.contains("positionData") {
            logger.info("Sending state update containing positionData")
        }
        
        // Send raw update dictionary
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let eventData = try encoder.encode(update.updates)
        guard let dataString = String(data: eventData, encoding: .utf8) else {
            logger.error("Failed to encode update to string")
            return
        }
        
        // Format as SSE event
        let sseEvent = formatSSEEvent(
            event: "update",
            data: dataString
        )
        
        // Write to stream
        let buffer = allocator.buffer(string: sseEvent)
        try await writer.write(buffer)
        
        if case .object(let dict) = update.updates {
            logger.trace("Sent state update via SSE with keys: \(dict.keys.joined(separator: ", "))")
        }
    }
    
    // MARK: - SSE Formatting
    
    /// Format a string as an SSE event
    private static func formatSSEEvent(
        event: String? = nil,
        data: String,
        id: String? = nil,
        retry: Int? = nil
    ) -> String {
        var output = ""
        
        // Add event type if specified
        if let event = event {
            output += "event: \(event)\n"
        }
        
        // Add id if specified
        if let id = id {
            output += "id: \(id)\n"
        }
        
        // Add retry if specified
        if let retry = retry {
            output += "retry: \(retry)\n"
        }
        
        // Add data lines (handle multiline data)
        let lines = data.split(separator: "\n", omittingEmptySubsequences: false)
        for line in lines {
            output += "data: \(line)\n"
        }
        
        // End event with blank line
        output += "\n"
        
        return output
    }
}

// MARK: - Health Check Support

extension SSEManager {
    
    /// Check if SSE service is healthy
    public static func healthCheck() -> Bool {
        // In a real implementation, this could check:
        // - Number of active SSE connections
        // - Recent message throughput
        // - Error rates
        return true
    }
    
    /// Get SSE service statistics
    public static func getStatistics() -> SSEStatistics {
        return SSEStatistics(
            activeConnections: 0, // This would be tracked in a real implementation
            messagesPerSecond: 0,
            errorRate: 0.0
        )
    }
}

public struct SSEStatistics: Sendable, Codable {
    public let activeConnections: Int
    public let messagesPerSecond: Int
    public let errorRate: Double
    
    public init(activeConnections: Int, messagesPerSecond: Int, errorRate: Double) {
        self.activeConnections = activeConnections
        self.messagesPerSecond = messagesPerSecond
        self.errorRate = errorRate
    }
}