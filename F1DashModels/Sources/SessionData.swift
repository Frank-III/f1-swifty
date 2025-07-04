import Foundation

/// Session information and metadata
public struct SessionInfo: Sendable, Codable {
    public let meeting: Meeting?
    public let archiveStatus: ArchiveStatus?
    public let key: Int?
    public let type: String?
    public let name: String?
    public let startDate: String?
    public let endDate: String?
    public let gmtOffset: String?
    public let path: String?
    
    public init(
        meeting: Meeting? = nil,
        archiveStatus: ArchiveStatus? = nil,
        key: Int? = nil,
        type: String? = nil,
        name: String? = nil,
        startDate: String? = nil,
        endDate: String? = nil,
        gmtOffset: String? = nil,
        path: String? = nil
    ) {
        self.meeting = meeting
        self.archiveStatus = archiveStatus
        self.key = key
        self.type = type
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.gmtOffset = gmtOffset
        self.path = path
    }
}

/// Meeting information
public struct Meeting: Sendable, Codable {
    public let key: Int
    public let name: String
    public let officialName: String
    public let location: String
    public let country: Country
    public let circuit: Circuit
    
    public init(
        key: Int,
        name: String,
        officialName: String,
        location: String,
        country: Country,
        circuit: Circuit
    ) {
        self.key = key
        self.name = name
        self.officialName = officialName
        self.location = location
        self.country = country
        self.circuit = circuit
    }
}

/// Country information
public struct Country: Sendable, Codable {
    public let key: Int
    public let code: String
    public let name: String
    
    public init(key: Int, code: String, name: String) {
        self.key = key
        self.code = code
        self.name = name
    }
}

/// Circuit information
public struct Circuit: Sendable, Codable {
    public let key: Int
    public let shortName: String
    
    public init(key: Int, shortName: String) {
        self.key = key
        self.shortName = shortName
    }
}

/// Archive status
public struct ArchiveStatus: Sendable, Codable {
    public let status: String
    
    public init(status: String) {
        self.status = status
    }
}

/// Session data with additional metadata
public struct SessionData: Sendable, Codable {
    public let series: [DataSeries]?
    public let statusSeries: [StatusSeries]?
    
    public init(series: [DataSeries]? = nil, statusSeries: [StatusSeries]? = nil) {
        self.series = series
        self.statusSeries = statusSeries
    }
}

/// Data series entry
public struct DataSeries: Sendable, Codable {
    public let utc: String
    public let lap: Int?
    
    public init(utc: String, lap: Int? = nil) {
        self.utc = utc
        self.lap = lap
    }
}

/// Status series entry
public struct StatusSeries: Sendable, Codable {
    public let utc: String
    public let trackStatus: String?
    public let sessionStatus: String?
    
    public init(utc: String, trackStatus: String? = nil, sessionStatus: String? = nil) {
        self.utc = utc
        self.trackStatus = trackStatus
        self.sessionStatus = sessionStatus
    }
}

/// Track status information
public struct TrackStatus: Sendable, Codable {
    public let status: TrackFlag
    public let message: String
    
    public init(status: TrackFlag, message: String) {
        self.status = status
        self.message = message
    }
    
  public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
        
        // Handle status as either string or number
        if let statusString = try? container.decode(String.self, forKey: .status) {
            status = TrackFlag(rawValue: statusString) ?? .unknown
        } else if let statusInt = try? container.decode(Int.self, forKey: .status) {
            status = TrackFlag(intValue: statusInt)
        } else {
            status = .unknown
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case status, message
    }
}

/// Session status information
public struct SessionStatus: Sendable, Codable {
    public let status: SessionFlag
    
    public init(status: SessionFlag) {
        self.status = status
    }
    
  public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let statusString = try? container.decode(String.self) {
            status = SessionFlag(rawValue: statusString) ?? .unknown
        } else {
            status = .unknown
        }
    }
}

/// Track flag status
public enum TrackFlag: String, Sendable, Codable, CaseIterable {
    case green = "1"
    case yellow = "2"
    case scYellow = "3"
    case red = "4"
    case scRed = "5"
    case vsc = "6"
    case scEndOfSession = "7"
    case chequered = "8"
    case unknown = "0"
    
    init(intValue: Int) {
        self = TrackFlag(rawValue: String(intValue)) ?? .unknown
    }
    
    /// Display color for the flag
    public var color: String {
        switch self {
        case .green:
            return "#00FF00"
        case .yellow, .scYellow, .vsc:
            return "#FFFF00"
        case .red, .scRed:
            return "#FF0000"
        case .chequered:
            return "#000000"
        case .scEndOfSession:
            return "#FFA500"
        case .unknown:
            return "#808080"
        }
    }
    
    /// Display name for the flag
    public var displayName: String {
        switch self {
        case .green:
            return "Green"
        case .yellow:
            return "Yellow"
        case .scYellow:
            return "Safety Car"
        case .red:
            return "Red"
        case .scRed:
            return "Safety Car Red"
        case .vsc:
            return "Virtual Safety Car"
        case .scEndOfSession:
            return "End of Session"
        case .chequered:
            return "Chequered"
        case .unknown:
            return "Unknown"
        }
    }
}

/// Session status
public enum SessionFlag: String, Sendable, Codable, CaseIterable {
    case inactive = "Inactive"
    case started = "Started"
    case finished = "Finished"
    case finalised = "Finalised"
    case ends = "Ends"
    case aborted = "Aborted"
    case unknown = "Unknown"
    
    /// Display color for the session status
    public var color: String {
        switch self {
        case .inactive:
            return "#808080"
        case .started:
            return "#00FF00"
        case .finished, .finalised:
            return "#FF0000"
        case .ends:
            return "#FFFF00"
        case .aborted:
            return "#FF0000"
        case .unknown:
            return "#808080"
        }
    }
}

/// Lap count information
public struct LapCount: Sendable, Codable {
    public let currentLap: Int
    public let totalLaps: Int
    
    public init(currentLap: Int, totalLaps: Int) {
        self.currentLap = currentLap
        self.totalLaps = totalLaps
    }
}
