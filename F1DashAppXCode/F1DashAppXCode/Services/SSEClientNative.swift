//
//  SSEClient.swift
//  F1-Dash
//
//  Manages Server-Sent Events connection to F1-Dash server
//

//import Foundation
//import F1DashModels
//
//enum SSEError: Error {
//    case connectionFailed
//    case invalidMessage
//    case disconnected
//    case invalidResponse
//}
//
//enum SSEMessage {
//    case initial([String: Any])
//    case update([String: Any])
//}
//
//actor SSEClient {
//    // MARK: - Properties
//    
//    private var task: Task<Void, Never>?
//    private let serverURL = URL(string: "http://127.0.0.1:8080/v1/live/sse")!  // Use IPv4 explicitly
//    
//    private var messageStream: AsyncStream<SSEMessage>?
//    private var messageContinuation: AsyncStream<SSEMessage>.Continuation?
//    
//    // MARK: - Initialization
//    
//    init() {
//    }
//    
//    // MARK: - Connection
//    
//    func connect() async throws {
//        disconnect()
//        
//        let (stream, continuation) = AsyncStream<SSEMessage>.makeStream()
//        self.messageStream = stream
//        self.messageContinuation = continuation
//        
//        // Start the SSE connection
//        task = Task {
//            await startEventStream()
//        }
//        
//        // Wait a moment to see if connection succeeds
//        try await Task.sleep(for: .milliseconds(500))
//    }
//    
//    func disconnect() {
//        task?.cancel()
//        task = nil
//        messageContinuation?.finish()
//        messageContinuation = nil
//        messageStream = nil
//    }
//    
//    // MARK: - Messages
//    
//    var messages: AsyncStream<SSEMessage> {
//        messageStream ?? AsyncStream { continuation in
//            continuation.finish()
//        }
//    }
//    
//    // MARK: - Private Implementation
//    
//    private func startEventStream() async {
//        do {
//            var request = URLRequest(url: serverURL)
//            request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
//            request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
//            request.timeoutInterval = 0 // No timeout for SSE
//            
//            let (bytes, response) = try await URLSession.shared.bytes(for: request)
//            
//            // Validate response
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("SSEClient: Invalid response type")
//                messageContinuation?.finish()
//                return
//            }
//            
//            guard httpResponse.statusCode == 200 else {
//                print("SSEClient: HTTP error \(httpResponse.statusCode)")
//                messageContinuation?.finish()
//                return
//            }
//            
//            guard let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type"),
//                  contentType.contains("text/event-stream") else {
//                print("SSEClient: Invalid content type")
//                messageContinuation?.finish()
//                return
//            }
//            
//            print("SSEClient: Connected successfully")
//            
//            // Process the byte stream
//            await processEventStream(bytes)
//            
//        } catch {
//            print("SSEClient: Connection error: \(error)")
//            messageContinuation?.finish()
//        }
//    }
//    
//    private func processEventStream(_ bytes: URLSession.AsyncBytes) async {
//        var eventBuffer = EventBuffer()
//        
//        do {
//            for try await byte in bytes {
//                if Task.isCancelled { break }
//                
//                eventBuffer.append(byte)
//                
//                // Process complete events
//                while let event = eventBuffer.nextEvent() {
//                    await handleEvent(event)
//                }
//            }
//        } catch {
//            print("SSEClient: Stream error: \(error)")
//        }
//        
//        messageContinuation?.finish()
//    }
//    
//    private func handleEvent(_ event: SSEEvent) async {
//        // Parse JSON data
//        guard let data = event.data.data(using: .utf8) else {
//            print("SSEClient: Failed to convert event data to Data")
//            return
//        }
//        
//        do {
//            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
//                print("SSEClient: Failed to parse JSON as dictionary")
//                return
//            }
//            
//            // Log event type
//            let eventType = event.event ?? "message"
//            print("SSEClient: Received event: \(eventType) with \(json.keys.count) keys")
//            
//            // Send the appropriate message type through the stream
//            if eventType == "initial" {
//                messageContinuation?.yield(.initial(json))
//            } else if eventType == "update" {
//                messageContinuation?.yield(.update(json))
//            }
//            
//        } catch {
//            print("SSEClient: JSON parsing error: \(error)")
//            print("SSEClient: Raw data: \(event.data.prefix(200))...")
//        }
//    }
//}
//
//// MARK: - SSE Event Parsing
//
//private struct SSEEvent {
//    var id: String?
//    var event: String?
//    var data: String
//    var retry: Int?
//}
//
//private struct EventBuffer {
//    private var buffer = Data()
//    private var currentEvent = SSEEvent(data: "")
//    private var dataLines: [String] = []
//    
//    mutating func append(_ byte: UInt8) {
//        buffer.append(byte)
//    }
//    
//    mutating func nextEvent() -> SSEEvent? {
//        // Look for line breaks
//        while let lineEnd = buffer.firstIndex(of: 0x0A) { // LF
//            let lineData: Data
//            
//            // Check if preceded by CR
//            if lineEnd > 0 && buffer[lineEnd - 1] == 0x0D {
//                lineData = buffer[..<(lineEnd - 1)]
//            } else {
//                lineData = buffer[..<lineEnd]
//            }
//            
//            // Remove processed data from buffer
//            buffer.removeSubrange(...lineEnd)
//            
//            // Convert to string
//            guard let line = String(data: lineData, encoding: .utf8) else {
//                continue
//            }
//            
//            // Process the line
//            if line.isEmpty {
//                // Empty line = end of event
//                if !dataLines.isEmpty {
//                    currentEvent.data = dataLines.joined(separator: "\n")
//                    let event = currentEvent
//                    
//                    // Reset for next event
//                    currentEvent = SSEEvent(data: "")
//                    dataLines.removeAll()
//                    
//                    return event
//                }
//            } else if line.hasPrefix(":") {
//                // Comment, ignore
//                continue
//            } else if let colonIndex = line.firstIndex(of: ":") {
//                let field = String(line[..<colonIndex])
//                var value = String(line[line.index(after: colonIndex)...])
//                
//                // Remove single leading space if present
//                if value.hasPrefix(" ") {
//                    value.removeFirst()
//                }
//                
//                switch field {
//                case "id":
//                    currentEvent.id = value
//                case "event":
//                    currentEvent.event = value
//                case "data":
//                    dataLines.append(value)
//                case "retry":
//                    if let retryValue = Int(value) {
//                        currentEvent.retry = retryValue
//                    }
//                default:
//                    break
//                }
//            }
//        }
//        
//        return nil
//    }
//}
