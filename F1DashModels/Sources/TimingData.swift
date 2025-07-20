import Foundation

/// Live timing data for all drivers
public struct TimingData: Sendable, Codable {
    public let noEntries: [Int]?
    public let sessionPart: Int?
    public let cutOffTime: String?
    public let cutOffPercentage: String?
    public var lines: [String: TimingDataDriver] = [:]
    public let withheld: Bool?
    
    public init(
        noEntries: [Int]? = nil,
        sessionPart: Int? = nil,
        cutOffTime: String? = nil,
        cutOffPercentage: String? = nil,
        lines: [String: TimingDataDriver] = [:],
        withheld: Bool? = nil
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
    public let gapToLeader: String?
    public let intervalToPositionAhead: IntervalToPositionAhead?
    public let line: Int?
    public let racingNumber: String?
    public let sectors: [Sector]
    public let bestLapTime: PersonalBestLapTime?
    public let lastLapTime: LapTimeValue?
    
    public init(
        stats: [Stats]? = nil,
        timeDiffToFastest: String? = nil,
        timeDiffToPositionAhead: String? = nil,
        gapToLeader: String? = nil,
        intervalToPositionAhead: IntervalToPositionAhead? = nil,
        line: Int? = nil,
        racingNumber: String? = nil,
        sectors: [Sector] = [],
        bestLapTime: PersonalBestLapTime? = nil,
        lastLapTime: LapTimeValue? = nil
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
  
    var lastLapPersonalFastest: Bool {
      self.lastLapTime?.personalFastest ?? false
    }
  
    var lastLapTimeValue: String {
      self.lastLapTime?.value ?? ""
    }
    
    // Custom decoding to handle sectors being either array or dictionary
    private enum CodingKeys: String, CodingKey {
        case stats
        case timeDiffToFastest
        case timeDiffToPositionAhead
        case gapToLeader
        case intervalToPositionAhead
        case line
        case racingNumber
        case sectors
        case bestLapTime
        case lastLapTime
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.stats = try container.decodeIfPresent([Stats].self, forKey: .stats)
        self.timeDiffToFastest = try container.decodeIfPresent(String.self, forKey: .timeDiffToFastest)
        self.timeDiffToPositionAhead = try container.decodeIfPresent(String.self, forKey: .timeDiffToPositionAhead)
        self.gapToLeader = try container.decodeIfPresent(String.self, forKey: .gapToLeader)
        self.intervalToPositionAhead = try container.decodeIfPresent(IntervalToPositionAhead.self, forKey: .intervalToPositionAhead)
        // Handle line being either Int or Bool
        if let lineInt = try? container.decodeIfPresent(Int.self, forKey: .line) {
            self.line = lineInt
        } else if let lineBool = try? container.decodeIfPresent(Bool.self, forKey: .line) {
            // Convert false to nil (as line 0 doesn't make sense)
            self.line = lineBool ? 1 : nil
        } else {
            self.line = nil
        }
        self.racingNumber = try container.decodeIfPresent(String.self, forKey: .racingNumber)
        self.bestLapTime = try container.decodeIfPresent(PersonalBestLapTime.self, forKey: .bestLapTime)
        self.lastLapTime = try container.decodeIfPresent(LapTimeValue.self, forKey: .lastLapTime)
        
        // Handle sectors - could be array, dictionary, or missing
        if container.contains(.sectors) {
            do {
                // Try decoding as array first (expected format)
                self.sectors = try container.decode([Sector].self, forKey: .sectors)
            } catch {
                // If that fails, try decoding as dictionary
                if let sectorsDict = try? container.decode([String: Sector].self, forKey: .sectors) {
                    // Convert dictionary to array, sorted by key
                    self.sectors = sectorsDict.sorted { $0.key < $1.key }.map { $0.value }
                } else {
                    // If both fail, use empty array
                    self.sectors = []
                }
            }
        } else {
            // If sectors key is missing, use empty array
            self.sectors = []
        }
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
    public let catching: Bool?
    
    public init(value: String, catching: Bool? = nil) {
        self.value = value
        self.catching = catching
    }
}

/// Sector timing information
public struct Sector: Sendable, Codable, Hashable, Equatable {
    public let stopped: Bool
    public let value: String
    public let previousValue: String?
    public let status: Int
    public let overallFastest: Bool
    public let personalFastest: Bool
    public var segments: [Segment] = []
    
    public init(
        stopped: Bool,
        value: String,
        previousValue: String? = nil,
        status: Int,
        overallFastest: Bool,
        personalFastest: Bool,
        segments: [Segment] = []
    ) {
        self.stopped = stopped
        self.value = value
        self.previousValue = previousValue
        self.status = status
        self.overallFastest = overallFastest
        self.personalFastest = personalFastest
        self.segments = segments
    }
    
    // Custom decoding to handle status being either Int or Bool
    private enum CodingKeys: String, CodingKey {
        case stopped
        case value
        case previousValue
        case status
        case overallFastest
        case personalFastest
        case segments
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.stopped = try container.decode(Bool.self, forKey: .stopped)
        self.value = try container.decode(String.self, forKey: .value)
        self.previousValue = try container.decodeIfPresent(String.self, forKey: .previousValue)
        self.overallFastest = try container.decode(Bool.self, forKey: .overallFastest)
        self.personalFastest = try container.decode(Bool.self, forKey: .personalFastest)
        self.segments = try container.decodeIfPresent([Segment].self, forKey: .segments) ?? []
        
        // Handle status being either Int or Bool
        if let statusInt = try? container.decode(Int.self, forKey: .status) {
            self.status = statusInt
        } else if let statusBool = try? container.decode(Bool.self, forKey: .status) {
            // Convert false to 0, true to 1
            self.status = statusBool ? 1 : 0
        } else {
            // Default to 0 if neither works
            self.status = 0
        }
    }
}

/// Segment within a sector
public struct Segment: Sendable, Codable, Equatable, Hashable {
    public let status: Int
    
    public init(status: Int?) {
        self.status = status ?? 0
    }
    
    public init(status: Bool) {
        self.status = status ? 1 : 0
    }
    
    // Custom decoding to handle status being either Int or Bool
    private enum CodingKeys: String, CodingKey {
        case status
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle status being either Int or Bool
        if let statusInt = try? container.decode(Int.self, forKey: .status) {
            self.status = statusInt
        } else if let statusBool = try? container.decode(Bool.self, forKey: .status) {
            // Convert false to 0, true to 1
            self.status = statusBool ? 1 : 0
        } else {
            // Default to 0 if neither works
            self.status = 0
        }
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
    
    // Custom decoding to handle status being either Int or Bool
    private enum CodingKeys: String, CodingKey {
        case value
        case status
        case overallFastest
        case personalFastest
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.value = try container.decode(String.self, forKey: .value)
        self.overallFastest = try container.decode(Bool.self, forKey: .overallFastest)
        self.personalFastest = try container.decode(Bool.self, forKey: .personalFastest)
        
        // Handle status being either Int or Bool
        if let statusInt = try? container.decode(Int.self, forKey: .status) {
            self.status = statusInt
        } else if let statusBool = try? container.decode(Bool.self, forKey: .status) {
            // Convert false to 0, true to 1
            self.status = statusBool ? 1 : 0
        } else {
            // Default to 0 if neither works
            self.status = 0
        }
    }
}

/// Timing statistics data
public struct TimingStats: Sendable, Codable {
    public let withheld: Bool?
    public let lines: [String: TimingStatsDriver]
    public let sessionType: String?
    
    public init(
        withheld: Bool? = nil,
        lines: [String: TimingStatsDriver],
        sessionType: String? = nil
    ) {
        self.withheld = withheld
        self.lines = lines
        self.sessionType = sessionType
    }
}

/// Timing statistics for individual driver
public struct TimingStatsDriver: Sendable, Codable {
    public let line: Int?
    public let racingNumber: String?
    public let personalBestLapTime: PersonalBestLapTime?
    public let bestSectors: [PersonalBestLapTime]
    public let bestSpeeds: BestSpeeds?
    
    public init(
        line: Int? = nil,
        racingNumber: String? = nil,
        personalBestLapTime: PersonalBestLapTime? = nil,
        bestSectors: [PersonalBestLapTime] = [],
        bestSpeeds: BestSpeeds? = nil
    ) {
        self.line = line
        self.racingNumber = racingNumber
        self.personalBestLapTime = personalBestLapTime
        self.bestSectors = bestSectors
        self.bestSpeeds = bestSpeeds
    }
    
    // Custom decoding to handle line being either Int or Bool
    private enum CodingKeys: String, CodingKey {
        case line
        case racingNumber
        case personalBestLapTime
        case bestSectors
        case bestSpeeds
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle line being either Int or Bool
        if let lineInt = try? container.decodeIfPresent(Int.self, forKey: .line) {
            self.line = lineInt
        } else if let lineBool = try? container.decodeIfPresent(Bool.self, forKey: .line) {
            // Convert false to nil (as line 0 doesn't make sense)
            self.line = lineBool ? 1 : nil
        } else {
            self.line = nil
        }
        
        self.racingNumber = try container.decodeIfPresent(String.self, forKey: .racingNumber)
        self.personalBestLapTime = try container.decodeIfPresent(PersonalBestLapTime.self, forKey: .personalBestLapTime)
        self.bestSectors = try container.decodeIfPresent([PersonalBestLapTime].self, forKey: .bestSectors) ?? []
        self.bestSpeeds = try container.decodeIfPresent(BestSpeeds.self, forKey: .bestSpeeds)
    }
}

/// Best speeds across different measurement points
public struct BestSpeeds: Sendable, Codable {
    public let i1: PersonalBestLapTime?
    public let i2: PersonalBestLapTime?
    public let fl: PersonalBestLapTime?
    public let st: PersonalBestLapTime?
    
    public init(
        i1: PersonalBestLapTime? = nil,
        i2: PersonalBestLapTime? = nil,
        fl: PersonalBestLapTime? = nil,
        st: PersonalBestLapTime? = nil
    ) {
        self.i1 = i1
        self.i2 = i2
        self.fl = fl
        self.st = st
    }
}
