//
//  ScheduleData.swift
//  F1DashModels
//
//  Created for F1 Dashboard
//

import Foundation

/// Represents a race weekend in the F1 calendar
public struct RaceRound: Codable, Identifiable, Sendable {
    public let id = UUID()
    public let name: String           // e.g., "Austrian Grand Prix"
    public let countryName: String    // e.g., "Austria"
    public let countryKey: String?    // e.g., "AT" (optional)
    public let start: Date           // Start of first session
    public let end: Date             // End of last session
    public let sessions: [RaceSession] // All sessions in the weekend
    public let over: Bool            // Whether the race weekend has finished
    
    public init(name: String, countryName: String, countryKey: String? = nil, 
                start: Date, end: Date, sessions: [RaceSession], over: Bool) {
        self.name = name
        self.countryName = countryName
        self.countryKey = countryKey
        self.start = start
        self.end = end
        self.sessions = sessions
        self.over = over
    }
    
    /// The main race session (if available)
    public var raceSession: RaceSession? {
        sessions.first { $0.kind.lowercased().contains("race") && !$0.kind.lowercased().contains("sprint") }
    }
    
    /// The qualifying session (if available)
    public var qualifyingSession: RaceSession? {
        sessions.first { $0.kind.lowercased().contains("qualifying") }
    }
    
    /// The sprint session (if available)
    public var sprintSession: RaceSession? {
        sessions.first { $0.kind.lowercased().contains("sprint") }
    }
    
    /// Whether this is the current or next race weekend
    public var isUpcoming: Bool {
        !over && end > Date()
    }
    
    /// Whether any session is currently active
    public var isActive: Bool {
        let now = Date()
        return sessions.contains { now >= $0.start && now <= $0.end }
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, countryName, countryKey, start, end, sessions, over
    }
}

/// Represents an individual session within a race weekend
public struct RaceSession: Codable, Identifiable, Sendable {
    public let id = UUID()
    public let kind: String    // e.g., "Practice 1", "Qualifying", "Race", "Sprint Race"
    public let start: Date     // Session start time
    public let end: Date       // Session end time
    
    public init(kind: String, start: Date, end: Date) {
        self.kind = kind
        self.start = start
        self.end = end
    }
    
    /// Whether this session is currently active
    public var isActive: Bool {
        let now = Date()
        return now >= start && now <= end
    }
    
    /// Whether this session is upcoming
    public var isUpcoming: Bool {
        start > Date()
    }
    
    /// Whether this session has finished
    public var isFinished: Bool {
        end < Date()
    }
    
    /// Duration of the session in seconds
    public var duration: TimeInterval {
        end.timeIntervalSince(start)
    }
    
    /// SF Symbol name for the session type
    public var symbolName: String {
        switch kind.lowercased() {
        case let k where k.contains("practice"):
            return "flag.checkered"
        case let k where k.contains("qualifying"):
            return "timer"
        case let k where k.contains("sprint"):
            return "bolt.fill"
        case let k where k.contains("race") && !k.contains("sprint"):
            return "trophy.fill"
        default:
            return "flag"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case kind, start, end
    }
}

/// Extension for formatted display
extension RaceRound {
    /// Formatted date range for the race weekend
    public var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let startStr = formatter.string(from: start)
        
        // If same month, show "Mar 15-17"
        if Calendar.current.isDate(start, equalTo: end, toGranularity: .month) {
            formatter.dateFormat = "d"
            let endStr = formatter.string(from: end)
            return "\(startStr)-\(endStr)"
        } else {
            // Different months, show "Mar 30 - Apr 2"
            let endStr = formatter.string(from: end)
            return "\(startStr) - \(endStr)"
        }
    }
}

extension RaceSession {
    /// Formatted time for the session
    public var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: start)
    }
    
    /// Formatted day and time for the session
    public var formattedDayTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E HH:mm"
        return formatter.string(from: start)
    }
    
    /// Time until session starts (or nil if already started)
    public var timeUntilStart: TimeInterval? {
        let interval = start.timeIntervalSinceNow
        return interval > 0 ? interval : nil
    }
}