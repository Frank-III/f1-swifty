import Foundation

/// Heartbeat data from the live timing feed
public struct Heartbeat: Sendable, Codable {
    public let utc: String
    
    public init(utc: String) {
        self.utc = utc
    }
    
    /// Parse UTC timestamp to Date
    public var timestamp: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: utc)
    }
}

/// Extrapolated clock for session timing
public struct ExtrapolatedClock: Sendable, Codable {
    public let utc: String
    public let remaining: String?
    public let extrapolating: Bool
    
    public init(utc: String, remaining: String? = nil, extrapolating: Bool) {
        self.utc = utc
        self.remaining = remaining
        self.extrapolating = extrapolating
    }
    
    /// Parse UTC timestamp to Date
    public var timestamp: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: utc)
    }
    
    /// Parse remaining time as TimeInterval (seconds)
    public var remainingSeconds: TimeInterval? {
        guard let remaining = remaining else { return nil }
        
        // Format is typically "HH:MM:SS" or "MM:SS"
        let components = remaining.split(separator: ":")
        
        switch components.count {
        case 2: // MM:SS
            guard let minutes = Double(components[0]),
                  let seconds = Double(components[1]) else { return nil }
            return minutes * 60 + seconds
            
        case 3: // HH:MM:SS
            guard let hours = Double(components[0]),
                  let minutes = Double(components[1]),
                  let seconds = Double(components[2]) else { return nil }
            return hours * 3600 + minutes * 60 + seconds
            
        default:
            return nil
        }
    }
    
    /// Formatted remaining time string
    public var remainingFormatted: String {
        guard let seconds = remainingSeconds else { return remaining ?? "Unknown" }
        
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
}