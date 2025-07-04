import Foundation

/// Race control messages and announcements
public struct RaceControlMessages: Sendable, Codable {
    public let messages: [RaceControlMessage]
    
    public init(messages: [RaceControlMessage]) {
        self.messages = messages
    }
}

/// Individual race control message
public struct RaceControlMessage: Sendable, Codable, Identifiable {
    public let utc: String
    public let lap: Int?
    public let category: MessageCategory
    public let message: String
    public let status: MessageStatus
    public let flag: MessageFlag?
    public let scope: MessageScope?
    public let sector: Int?
    public let racingNumber: String?
    
    public var id: String {
        "\(utc)-\(message.hashValue)"
    }
    
    public init(
        utc: String,
        lap: Int? = nil,
        category: MessageCategory,
        message: String,
        status: MessageStatus,
        flag: MessageFlag? = nil,
        scope: MessageScope? = nil,
        sector: Int? = nil,
        racingNumber: String? = nil
    ) {
        self.utc = utc
        self.lap = lap
        self.category = category
        self.message = message
        self.status = status
        self.flag = flag
        self.scope = scope
        self.sector = sector
        self.racingNumber = racingNumber
    }
    
    /// Parse UTC timestamp to Date
    public var timestamp: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: utc)
    }
}

/// Race control message categories
public enum MessageCategory: String, Sendable, Codable, CaseIterable {
    case flag = "Flag"
    case drs = "Drs"
    case safetycar = "SafetyCar"
    case carEvent = "CarEvent"
    case track = "Track"
    case other = "Other"
    
    public var displayName: String {
        switch self {
        case .flag:
            return "Flag"
        case .drs:
            return "DRS"
        case .safetycar:
            return "Safety Car"
        case .carEvent:
            return "Car Event"
        case .track:
            return "Track"
        case .other:
            return "Other"
        }
    }
    
    public var color: String {
        switch self {
        case .flag:
            return "#FF0000"
        case .drs:
            return "#00FF00"
        case .safetycar:
            return "#FFFF00"
        case .carEvent:
            return "#FFA500"
        case .track:
            return "#0000FF"
        case .other:
            return "#808080"
        }
    }
}

/// Message status
public enum MessageStatus: String, Sendable, Codable, CaseIterable {
    case published = "PUBLISHED"
    case deleted = "DELETED"
    case updated = "UPDATED"
    
    public var displayName: String {
        switch self {
        case .published:
            return "Published"
        case .deleted:
            return "Deleted"
        case .updated:
            return "Updated"
        }
    }
}

/// Message flag type
public enum MessageFlag: String, Sendable, Codable, CaseIterable {
    case green = "GREEN"
    case yellow = "YELLOW"
    case red = "RED"
    case blue = "BLUE"
    case white = "WHITE"
    case chequered = "CHEQUERED"
    case black = "BLACK"
    case blackOrange = "BLACK_ORANGE"
    
    public var color: String {
        switch self {
        case .green:
            return "#00FF00"
        case .yellow:
            return "#FFFF00"
        case .red:
            return "#FF0000"
        case .blue:
            return "#0000FF"
        case .white:
            return "#FFFFFF"
        case .chequered:
            return "#000000"
        case .black:
            return "#000000"
        case .blackOrange:
            return "#FFA500"
        }
    }
    
    public var displayName: String {
        switch self {
        case .green:
            return "Green Flag"
        case .yellow:
            return "Yellow Flag"
        case .red:
            return "Red Flag"
        case .blue:
            return "Blue Flag"
        case .white:
            return "White Flag"
        case .chequered:
            return "Chequered Flag"
        case .black:
            return "Black Flag"
        case .blackOrange:
            return "Black & Orange Flag"
        }
    }
}

/// Message scope
public enum MessageScope: String, Sendable, Codable, CaseIterable {
    case track = "Track"
    case sector = "Sector"
    case driver = "Driver"
    
    public var displayName: String {
        rawValue
    }
}