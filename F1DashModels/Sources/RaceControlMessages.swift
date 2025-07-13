import Foundation

/// Race control messages and announcements
public struct RaceControlMessages: Sendable, Codable {
    public let messages: [RaceControlMessage]
    
    public init(messages: [RaceControlMessage]) {
        self.messages = messages
    }
    
    // Custom decoding to handle messages being either array or dictionary
    private enum CodingKeys: String, CodingKey {
        case messages
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if container.contains(.messages) {
            do {
                // Try decoding as array first (expected format)
                self.messages = try container.decode([RaceControlMessage].self, forKey: .messages)
            } catch {
                // If that fails, try decoding as dictionary
                if let messagesDict = try? container.decode([String: RaceControlMessage].self, forKey: .messages) {
                    // Convert dictionary to array, sorted by key
                    self.messages = messagesDict.sorted { $0.key < $1.key }.map { $0.value }
                } else {
                    // If both fail, use empty array
                    self.messages = []
                }
            }
        } else {
            // If messages key is missing, use empty array
            self.messages = []
        }
    }
}

/// Individual race control message
public struct RaceControlMessage: Sendable, Codable, Identifiable {
    public let utc: String
    public let lap: Bool?
    public let category: MessageCategory
    public let message: String
    public let status: MessageStatus?
    public let flag: MessageFlag?
    public let scope: MessageScope?
    public let sector: Int?
    public let racingNumber: String?
    
    public var id: String {
        "\(utc)-\(message.hashValue)"
    }
    
    public init(
        utc: String,
        lap: Bool? = nil,
        category: MessageCategory,
        message: String,
        status: MessageStatus? = nil,
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
    
    // Handle case-insensitive decoding
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        // Try exact match first
        if let category = MessageCategory(rawValue: rawValue) {
            self = category
        } else {
            // Try case-insensitive match
            let lowercased = rawValue.lowercased()
            switch lowercased {
            case "flag": self = .flag
            case "drs": self = .drs
            case "safetycar": self = .safetycar
            case "carevent": self = .carEvent
            case "track": self = .track
            case "other": self = .other
            default: self = .other // Default to other if unknown
            }
        }
    }
    
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
public enum MessageStatus: String, Sendable, Codable {
    case published = "PUBLISHED"
    case deleted = "DELETED"
    case updated = "UPDATED"
    case disabled = "DISABLED"  // DRS status
    case enabled = "ENABLED"    // DRS status
    case unknown = "UNKNOWN"
    
    public static var allCases: [MessageStatus] {
        return [.published, .deleted, .updated, .disabled, .enabled]
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        // Try exact match first
        if let status = MessageStatus(rawValue: rawValue) {
            self = status
        } else {
            // Default to unknown for unrecognized values
            self = .unknown
            print("Unknown MessageStatus value: \(rawValue)")
        }
    }
    
    public var displayName: String {
        switch self {
        case .published:
            return "Published"
        case .deleted:
            return "Deleted"
        case .updated:
            return "Updated"
        case .disabled:
            return "Disabled"
        case .enabled:
            return "Enabled"
        case .unknown:
            return "Unknown"
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
    case clear = "CLEAR"
    
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
        case .clear:
            return "#00FF00"
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
        case .clear:
            return "Clear"
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
    
    // Handle case-insensitive decoding
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        // Try exact match first
        if let scope = MessageScope(rawValue: rawValue) {
            self = scope
        } else {
            // Try case-insensitive match
            let lowercased = rawValue.lowercased()
            switch lowercased {
            case "track": self = .track
            case "sector": self = .sector
            case "driver": self = .driver
            default: throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown scope: \(rawValue)")
            }
        }
    }
}