import Foundation

// MARK: - Driver Standings

/// Driver standings entry
public struct DriverStanding: Sendable, Codable {
    public let position: Int
    public let driverName: String
    public let driverNumber: String?
    public let teamName: String
    public let points: Double
    public let wins: Int
    
    public init(
        position: Int,
        driverName: String,
        driverNumber: String?,
        teamName: String,
        points: Double,
        wins: Int
    ) {
        self.position = position
        self.driverName = driverName
        self.driverNumber = driverNumber
        self.teamName = teamName
        self.points = points
        self.wins = wins
    }
}

/// Collection of driver standings
public struct DriverStandings: Sendable, Codable {
    public let year: Int
    public let standings: [DriverStanding]
    public let lastUpdated: Date
    
    public init(year: Int, standings: [DriverStanding], lastUpdated: Date = Date()) {
        self.year = year
        self.standings = standings
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Team Standings

/// Team/Constructor standings entry
public struct TeamStanding: Sendable, Codable {
    public let position: Int
    public let teamName: String
    public let points: Double
    
    public init(
        position: Int,
        teamName: String,
        points: Double
    ) {
        self.position = position
        self.teamName = teamName
        self.points = points
    }
}

/// Collection of team standings
public struct TeamStandings: Sendable, Codable {
    public let year: Int
    public let standings: [TeamStanding]
    public let lastUpdated: Date
    
    public init(year: Int, standings: [TeamStanding], lastUpdated: Date = Date()) {
        self.year = year
        self.standings = standings
        self.lastUpdated = lastUpdated
    }
}