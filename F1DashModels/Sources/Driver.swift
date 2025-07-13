import Foundation

/// Driver information and details
public struct Driver: Sendable, Hashable, Identifiable {
    public let racingNumber: String
    public let broadcastName: String
    public let fullName: String
    public let tla: String
    public let line: Int
    public let teamName: String
    public let teamColour: String
    public let firstName: String
    public let lastName: String
    public let reference: String
    public let headshotUrl: String?
    public let countryCode: String
    
    public var id: String { racingNumber }
    
    public init(
        racingNumber: String,
        broadcastName: String,
        fullName: String,
        tla: String,
        line: Int,
        teamName: String,
        teamColour: String,
        firstName: String,
        lastName: String,
        reference: String,
        headshotUrl: String? = nil,
        countryCode: String
    ) {
        self.racingNumber = racingNumber
        self.broadcastName = broadcastName
        self.fullName = fullName
        self.tla = tla
        self.line = line
        self.teamName = teamName
        self.teamColour = teamColour
        self.firstName = firstName
        self.lastName = lastName
        self.reference = reference
        self.headshotUrl = headshotUrl
        self.countryCode = countryCode
    }
}

// MARK: - Codable implementation with flexible line field
extension Driver: Codable {
    private enum CodingKeys: String, CodingKey {
        case racingNumber, broadcastName, fullName, tla, line
        case teamName, teamColour, firstName, lastName
        case reference, headshotUrl, countryCode
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        racingNumber = try container.decode(String.self, forKey: .racingNumber)
        broadcastName = try container.decode(String.self, forKey: .broadcastName)
        fullName = try container.decode(String.self, forKey: .fullName)
        tla = try container.decode(String.self, forKey: .tla)
        
        // Handle line field that can be either Int or Bool
        if let lineInt = try? container.decode(Int.self, forKey: .line) {
            line = lineInt
        } else if let lineBool = try? container.decode(Bool.self, forKey: .line) {
            // Convert bool to int: true = 1, false = 0
            line = lineBool ? 1 : 0
        } else {
            // Default to 0 if missing or invalid
            line = 0
        }
        
        teamName = try container.decode(String.self, forKey: .teamName)
        teamColour = try container.decode(String.self, forKey: .teamColour)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        reference = try container.decode(String.self, forKey: .reference)
        headshotUrl = try container.decodeIfPresent(String.self, forKey: .headshotUrl)
        countryCode = try container.decode(String.self, forKey: .countryCode)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(racingNumber, forKey: .racingNumber)
        try container.encode(broadcastName, forKey: .broadcastName)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(tla, forKey: .tla)
        try container.encode(line, forKey: .line)
        try container.encode(teamName, forKey: .teamName)
        try container.encode(teamColour, forKey: .teamColour)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(reference, forKey: .reference)
        try container.encodeIfPresent(headshotUrl, forKey: .headshotUrl)
        try container.encode(countryCode, forKey: .countryCode)
    }
}

/// Top three drivers display information
public struct TopThree: Sendable, Codable {
    public let lines: [String: TopThreeDriver]
    
    public init(lines: [String: TopThreeDriver]) {
        self.lines = lines
    }
}

/// Top three driver entry
public struct TopThreeDriver: Sendable, Codable {
    public let position: String?
    public let showPosition: Bool?
    public let racingNumber: String?
    public let tla: String?
    public let broadcastName: String?
    public let fullName: String?
    public let team: String?
    public let teamColour: String?
    public let lapTime: String?
    public let lapState: Int?
    public let diffToAhead: String?
    public let diffToLeader: String?
    public let overallFastest: Bool?
    public let personalFastest: Bool?
    
    public init(
        position: String? = nil,
        showPosition: Bool? = nil,
        racingNumber: String? = nil,
        tla: String? = nil,
        broadcastName: String? = nil,
        fullName: String? = nil,
        team: String? = nil,
        teamColour: String? = nil,
        lapTime: String? = nil,
        lapState: Int? = nil,
        diffToAhead: String? = nil,
        diffToLeader: String? = nil,
        overallFastest: Bool? = nil,
        personalFastest: Bool? = nil
    ) {
        self.position = position
        self.showPosition = showPosition
        self.racingNumber = racingNumber
        self.tla = tla
        self.broadcastName = broadcastName
        self.fullName = fullName
        self.team = team
        self.teamColour = teamColour
        self.lapTime = lapTime
        self.lapState = lapState
        self.diffToAhead = diffToAhead
        self.diffToLeader = diffToLeader
        self.overallFastest = overallFastest
        self.personalFastest = personalFastest
    }
}