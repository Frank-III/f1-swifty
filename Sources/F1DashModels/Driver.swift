import Foundation

/// Driver information and details
public struct Driver: Sendable, Codable, Hashable, Identifiable {
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

/// Top three drivers display information
public struct TopThree: Sendable, Codable {
    public let lines: [String: TopThreeDriver]
    
    public init(lines: [String: TopThreeDriver]) {
        self.lines = lines
    }
}

/// Top three driver entry
public struct TopThreeDriver: Sendable, Codable {
    public let position: String
    public let showPosition: Bool
    public let racingNumber: String
    public let tla: String
    public let broadcastName: String
    public let fullName: String
    public let team: String
    public let teamColour: String
    public let lapTime: String
    public let lapState: Int
    public let diffToAhead: String
    public let diffToLeader: String
    public let overallFastest: Bool
    public let personalFastest: Bool
    
    public init(
        position: String,
        showPosition: Bool,
        racingNumber: String,
        tla: String,
        broadcastName: String,
        fullName: String,
        team: String,
        teamColour: String,
        lapTime: String,
        lapState: Int,
        diffToAhead: String,
        diffToLeader: String,
        overallFastest: Bool,
        personalFastest: Bool
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