import Foundation

/// Team radio communications
public struct TeamRadio: Sendable, Codable {
    public let captures: [RadioCapture]
    
    public init(captures: [RadioCapture]) {
        self.captures = captures
    }
}

/// Individual radio capture/transmission
public struct RadioCapture: Sendable, Codable {
    public let utc: String
    public let racingNumber: String
    public let path: String
    
    public init(utc: String, racingNumber: String, path: String) {
        self.utc = utc
        self.racingNumber = racingNumber
        self.path = path
    }
    
    /// Parse UTC timestamp to Date
    public var timestamp: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: utc)
    }
    
    /// Full URL for the audio clip
    public var audioURL: URL? {
        URL(string: "https://livetiming.formula1.com\(path)")
    }
}