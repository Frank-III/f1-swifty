import Foundation

/// Live timing data for all drivers
public struct TimingData: Sendable, Codable {
    public let noEntries: [Int]?
    public let sessionPart: Int?
    public let cutOffTime: String?
    public let cutOffPercentage: String?
    public let lines: [String: TimingDataDriver]
    public let withheld: Bool
    
    public init(
        noEntries: [Int]? = nil,
        sessionPart: Int? = nil,
        cutOffTime: String? = nil,
        cutOffPercentage: String? = nil,
        lines: [String: TimingDataDriver],
        withheld: Bool
    ) {
        self.noEntries = noEntries
        self.sessionPart = sessionPart
        self.cutOffTime = cutOffTime
        self.cutOffPercentage = cutOffPercentage
        self.lines = lines
        self.withheld = withheld
    }
}

/// Timing data for individual driver
public struct TimingDataDriver: Sendable, Codable {
    public let stats: [Stats]?
    public let timeDiffToFastest: String?
    public let timeDiffToPositionAhead: String?
    public let gapToLeader: String
    public let intervalToPositionAhead: IntervalToPositionAhead?
    public let line: Int
    public let racingNumber: String
    public let sectors: [Sector]
    public let bestLapTime: PersonalBestLapTime
    public let lastLapTime: LapTimeValue
    
    public init(
        stats: [Stats]? = nil,
        timeDiffToFastest: String? = nil,
        timeDiffToPositionAhead: String? = nil,
        gapToLeader: String,
        intervalToPositionAhead: IntervalToPositionAhead? = nil,
        line: Int,
        racingNumber: String,
        sectors: [Sector],
        bestLapTime: PersonalBestLapTime,
        lastLapTime: LapTimeValue
    ) {
        self.stats = stats
        self.timeDiffToFastest = timeDiffToFastest
        self.timeDiffToPositionAhead = timeDiffToPositionAhead
        self.gapToLeader = gapToLeader
        self.intervalToPositionAhead = intervalToPositionAhead
        self.line = line
        self.racingNumber = racingNumber
        self.sectors = sectors
        self.bestLapTime = bestLapTime
        self.lastLapTime = lastLapTime
    }
}

/// Driver statistics
public struct Stats: Sendable, Codable {
    public let timeDiffToFastest: String
    public let timeDiffToPositionAhead: String
    
    public init(timeDiffToFastest: String, timeDiffToPositionAhead: String) {
        self.timeDiffToFastest = timeDiffToFastest
        self.timeDiffToPositionAhead = timeDiffToPositionAhead
    }
}

/// Gap interval to position ahead
public struct IntervalToPositionAhead: Sendable, Codable {
    public let value: String
    public let catching: Bool
    
    public init(value: String, catching: Bool) {
        self.value = value
        self.catching = catching
    }
}

/// Sector timing information
public struct Sector: Sendable, Codable {
    public let stopped: Bool
    public let value: String
    public let previousValue: String?
    public let status: Int
    public let overallFastest: Bool
    public let personalFastest: Bool
    public let segments: [Segment]
    
    public init(
        stopped: Bool,
        value: String,
        previousValue: String? = nil,
        status: Int,
        overallFastest: Bool,
        personalFastest: Bool,
        segments: [Segment]
    ) {
        self.stopped = stopped
        self.value = value
        self.previousValue = previousValue
        self.status = status
        self.overallFastest = overallFastest
        self.personalFastest = personalFastest
        self.segments = segments
    }
}

/// Segment within a sector
public struct Segment: Sendable, Codable {
    public let status: Int
    
    public init(status: Int) {
        self.status = status
    }
}

/// Personal best lap time
public struct PersonalBestLapTime: Sendable, Codable {
    public let value: String
    
    public init(value: String) {
        self.value = value
    }
}

/// Lap time value with status
public struct LapTimeValue: Sendable, Codable {
    public let value: String
    public let status: Int
    public let overallFastest: Bool
    public let personalFastest: Bool
    
    public init(
        value: String,
        status: Int,
        overallFastest: Bool,
        personalFastest: Bool
    ) {
        self.value = value
        self.status = status
        self.overallFastest = overallFastest
        self.personalFastest = personalFastest
    }
}

/// Timing statistics data
public struct TimingStats: Sendable, Codable {
    public let withheld: Bool
    public let lines: [String: TimingStatsDriver]
    public let sessionType: String
    
    public init(
        withheld: Bool,
        lines: [String: TimingStatsDriver],
        sessionType: String
    ) {
        self.withheld = withheld
        self.lines = lines
        self.sessionType = sessionType
    }
}

/// Timing statistics for individual driver
public struct TimingStatsDriver: Sendable, Codable {
    public let line: Int
    public let racingNumber: String
    public let personalBestLapTime: PersonalBestLapTime
    public let bestSectors: [PersonalBestLapTime]
    public let bestSpeeds: BestSpeeds
    
    public init(
        line: Int,
        racingNumber: String,
        personalBestLapTime: PersonalBestLapTime,
        bestSectors: [PersonalBestLapTime],
        bestSpeeds: BestSpeeds
    ) {
        self.line = line
        self.racingNumber = racingNumber
        self.personalBestLapTime = personalBestLapTime
        self.bestSectors = bestSectors
        self.bestSpeeds = bestSpeeds
    }
}

/// Best speeds across different measurement points
public struct BestSpeeds: Sendable, Codable {
    public let i1: PersonalBestLapTime
    public let i2: PersonalBestLapTime
    public let fl: PersonalBestLapTime
    public let st: PersonalBestLapTime
    
    public init(
        i1: PersonalBestLapTime,
        i2: PersonalBestLapTime,
        fl: PersonalBestLapTime,
        st: PersonalBestLapTime
    ) {
        self.i1 = i1
        self.i2 = i2
        self.fl = fl
        self.st = st
    }
}