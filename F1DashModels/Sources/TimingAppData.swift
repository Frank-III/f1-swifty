import Foundation

/// Timing app data containing tire and stint information
public struct TimingAppData: Sendable, Codable {
    public let lines: [String: TimingAppDataDriver]
    
    public init(lines: [String: TimingAppDataDriver]) {
        self.lines = lines
    }
}

/// Timing app data for individual driver
public struct TimingAppDataDriver: Sendable, Codable {
    public let racingNumber: String
    public let stints: [Stint]
    public let line: Int
    public let gridPos: String
    
    public init(
        racingNumber: String,
        stints: [Stint],
        line: Int,
        gridPos: String
    ) {
        self.racingNumber = racingNumber
        self.stints = stints
        self.line = line
        self.gridPos = gridPos
    }
}

/// Tire stint information
public struct Stint: Sendable, Codable {
    public let totalLaps: Int?
    public let compound: TireCompound?
    public let isNew: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case totalLaps
        case compound
        case isNew = "new"
    }
    
    public init(
        totalLaps: Int? = nil,
        compound: TireCompound? = nil,
        isNew: Bool? = nil
    ) {
        self.totalLaps = totalLaps
        self.compound = compound
        self.isNew = isNew
    }
    
  public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalLaps = try container.decodeIfPresent(Int.self, forKey: .totalLaps)
        compound = try container.decodeIfPresent(TireCompound.self, forKey: .compound)
        
        // Handle "new" field which can be string "TRUE"/"FALSE" or boolean
        if let newString = try? container.decode(String.self, forKey: .isNew) {
            isNew = newString.uppercased() == "TRUE"
        } else {
            isNew = try container.decodeIfPresent(Bool.self, forKey: .isNew)
        }
    }
    
  public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(totalLaps, forKey: .totalLaps)
        try container.encodeIfPresent(compound, forKey: .compound)
        try container.encodeIfPresent(isNew, forKey: .isNew)
    }
}

/// Tire compound types
public enum TireCompound: String, Sendable, Codable, CaseIterable {
    case soft = "SOFT"
    case medium = "MEDIUM" 
    case hard = "HARD"
    case intermediate = "INTERMEDIATE"
    case wet = "WET"
    
    /// Display color for the tire compound
    public var color: String {
        switch self {
        case .soft:
            return "#FF0000" // Red
        case .medium:
            return "#FFFF00" // Yellow
        case .hard:
            return "#FFFFFF" // White
        case .intermediate:
            return "#00FF00" // Green
        case .wet:
            return "#0000FF" // Blue
        }
    }
    
    /// Display name for the tire compound
    public var displayName: String {
        switch self {
        case .soft:
            return "Soft"
        case .medium:
            return "Medium"
        case .hard:
            return "Hard"
        case .intermediate:
            return "Intermediate"
        case .wet:
            return "Wet"
        }
    }
    
    /// Short code for display
    public var shortCode: String {
        switch self {
        case .soft:
            return "S"
        case .medium:
            return "M"
        case .hard:
            return "H"
        case .intermediate:
            return "I"
        case .wet:
            return "W"
        }
    }
}
