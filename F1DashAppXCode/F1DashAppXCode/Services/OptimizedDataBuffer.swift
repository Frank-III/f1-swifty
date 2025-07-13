//
//  OptimizedDataBuffer.swift
//  F1-Dash
//
//  High-performance time-delay buffer inspired by TypeScript implementation
//

import Foundation

actor OptimizedDataBuffer {
    // MARK: - Types
    
    private struct Frame<T> {
        let data: T
        let timestamp: TimeInterval
    }
    
    // MARK: - Properties
    
    private var frames: [Frame<[String: Any]>] = []
    private let keepBufferSeconds: TimeInterval = 5.0
    private let maxBufferSize = 2000
    
    // MARK: - Public Methods
    
    func push(_ data: [String: Any], timestamp: TimeInterval? = nil) {
        let frameTimestamp = timestamp ?? Date().timeIntervalSince1970 * 1000 // Convert to milliseconds
        let frame = Frame(data: data, timestamp: frameTimestamp)
        
        frames.append(frame)
        
        // Keep buffer sorted by timestamp for binary search
        if frames.count > 1 && frames[frames.count - 1].timestamp < frames[frames.count - 2].timestamp {
            frames.sort { $0.timestamp < $1.timestamp }
        }
        
        // Trim buffer if it gets too large
        if frames.count > maxBufferSize {
            frames.removeFirst(frames.count - maxBufferSize)
        }
    }
    
    func latest() -> [String: Any]? {
        frames.last?.data
    }
    
    func delayed(_ delaySeconds: TimeInterval) -> [String: Any]? {
        guard !frames.isEmpty else { return nil }
        
        let delayedTime = (Date().timeIntervalSince1970 - delaySeconds) * 1000
        
        // Handle edge cases
        if frames[0].timestamp > delayedTime { return nil }
        if frames[frames.count - 1].timestamp <= delayedTime {
            return frames[frames.count - 1].data
        }
        
        // Binary search for the closest frame before delayedTime
        var left = 0
        var right = frames.count - 1
        
        while left <= right {
            let mid = (left + right) / 2
            
            if frames[mid].timestamp <= delayedTime && 
               (mid == frames.count - 1 || frames[mid + 1].timestamp > delayedTime) {
                return frames[mid].data
            }
            
            if frames[mid].timestamp <= delayedTime {
                left = mid + 1
            } else {
                right = mid - 1
            }
        }
        
        return nil
    }
    
    func cleanup(_ delaySeconds: TimeInterval) {
        guard frames.count > 1 else { return }
        
        let delayedTime = (Date().timeIntervalSince1970 - delaySeconds) * 1000
        let thresholdTime = delayedTime - (keepBufferSeconds * 1000)
        
        // Find the index of the first frame newer than threshold
        var index = 0
        while index < frames.count && frames[index].timestamp <= thresholdTime {
            index += 1
        }
        
        // Keep at least one frame
        if index > 0 && index < frames.count {
            frames = Array(frames[(index - 1)...])
        } else if index >= frames.count {
            frames = [frames[frames.count - 1]]
        }
    }
    
    func clear() {
        frames.removeAll()
    }
    
    var maxDelay: TimeInterval {
        guard !frames.isEmpty else { return 0 }
        return floor((Date().timeIntervalSince1970 * 1000 - frames[0].timestamp) / 1000)
    }
    
    var count: Int {
        frames.count
    }
}