import Foundation

/// Championship prediction data
public struct ChampionshipPrediction: Sendable, Codable {
    public let drivers: [String: ChampionshipDriver]
    public let teams: [String: ChampionshipTeam]
    
    public init(drivers: [String: ChampionshipDriver], teams: [String: ChampionshipTeam]) {
        self.drivers = drivers
        self.teams = teams
    }
}

/// Championship standings for individual driver
public struct ChampionshipDriver: Sendable, Codable {
    public let racingNumber: String
    public let currentPosition: Int
    public let predictedPosition: Int
    public let currentPoints: Int
    public let predictedPoints: Int
    
    public init(
        racingNumber: String,
        currentPosition: Int,
        predictedPosition: Int,
        currentPoints: Int,
        predictedPoints: Int
    ) {
        self.racingNumber = racingNumber
        self.currentPosition = currentPosition
        self.predictedPosition = predictedPosition
        self.currentPoints = currentPoints
        self.predictedPoints = predictedPoints
    }
    
    /// Points gained/lost from current position
    public var pointsDelta: Int {
        predictedPoints - currentPoints
    }
    
    /// Position change (negative = improvement)
    public var positionChange: Int {
        predictedPosition - currentPosition
    }
}

/// Championship standings for team
public struct ChampionshipTeam: Sendable, Codable {
    public let teamName: String
    public let currentPosition: Int
    public let predictedPosition: Int
    public let currentPoints: Int
    public let predictedPoints: Int
    
    public init(
        teamName: String,
        currentPosition: Int,
        predictedPosition: Int,
        currentPoints: Int,
        predictedPoints: Int
    ) {
        self.teamName = teamName
        self.currentPosition = currentPosition
        self.predictedPosition = predictedPosition
        self.currentPoints = currentPoints
        self.predictedPoints = predictedPoints
    }
    
    /// Points gained/lost from current position
    public var pointsDelta: Int {
        predictedPoints - currentPoints
    }
    
    /// Position change (negative = improvement)
    public var positionChange: Int {
        predictedPosition - currentPosition
    }
}