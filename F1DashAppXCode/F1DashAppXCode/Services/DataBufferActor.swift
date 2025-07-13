//
//  DataBufferActor.swift
//  F1-Dash
//
//  Manages time-delay buffer for the data stream
//

import Foundation

actor DataBufferActor {
    // MARK: - Types
    
    private struct BufferedMessage {
        let message: [String: Any]
        let readyTime: Date
    }
    
    // MARK: - Properties
    
    private var buffer: [BufferedMessage] = []
    private let maxBufferSize = 1000
    
    // MARK: - Public Methods
    
    func addMessage(_ message: [String: Any], delay: TimeInterval) {
        let readyTime = Date().addingTimeInterval(delay)
        let bufferedMessage = BufferedMessage(message: message, readyTime: readyTime)
        
        buffer.append(bufferedMessage)
        
        // Trim buffer if it gets too large
        if buffer.count > maxBufferSize {
            buffer.removeFirst(buffer.count - maxBufferSize)
        }
    }
    
    func getReadyMessages() -> [[String: Any]] {
        let now = Date()
        
        // Find messages that are ready to be processed
        let readyMessages = buffer.filter { $0.readyTime <= now }
            .map { $0.message }
        
        // Remove processed messages from buffer
        buffer.removeAll { $0.readyTime <= now }
        
        return readyMessages
    }
    
    func clear() {
        buffer.removeAll()
    }
    
    var bufferedMessageCount: Int {
        buffer.count
    }
}
