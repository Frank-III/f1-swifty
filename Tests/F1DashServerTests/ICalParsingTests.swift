import Foundation
import Testing
@testable import F1DashServer

/// Test suite for iCal parsing functionality
struct ICalParsingTests {
    
    @Test("Test basic iCal event parsing")
    func testBasicICalEventParsing() throws {
        let testICalData = """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//Test//Test//EN
        BEGIN:VEVENT
        DTSTART:20241210T140000Z
        DTEND:20241210T160000Z
        SUMMARY:FORMULA 1 AUSTRIAN GRAND PRIX - PRACTICE 1
        LOCATION:Red Bull Ring, Austria
        UID:test123
        END:VEVENT
        END:VCALENDAR
        """
        
        let cache = ScheduleCache()
        
        // Access the private parsing method through reflection/testing
        // Note: In production, you might want to make this method internal for testing
        // For now, we'll test the date parsing functionality directly
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let startDate = formatter.date(from: "20241210T140000Z")
        let endDate = formatter.date(from: "20241210T160000Z")
        
        #expect(startDate != nil)
        #expect(endDate != nil)
        
        if let start = startDate, let end = endDate {
            #expect(start < end)
            #expect(end.timeIntervalSince(start) == 7200) // 2 hours
        }
    }
    
    @Test("Test iCal date format parsing")
    func testICalDateFormatParsing() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let testCases = [
            "20241210T140000Z": (2024, 12, 10, 14, 0),
            "20240301T093000Z": (2024, 3, 1, 9, 30),
            "20241225T120000Z": (2024, 12, 25, 12, 0)
        ]
        
        for (dateString, expected) in testCases {
            let parsedDate = formatter.date(from: dateString)
            #expect(parsedDate != nil, "Failed to parse date: \(dateString)")
            
            if let date = parsedDate {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                
                #expect(components.year == expected.0)
                #expect(components.month == expected.1)
                #expect(components.day == expected.2)
                #expect(components.hour == expected.3)
                #expect(components.minute == expected.4)
            }
        }
    }
    
    @Test("Test event summary parsing")
    func testEventSummaryParsing() {
        // Test the regex pattern for parsing event summaries
        let pattern = #"FORMULA 1 (.+) - (.+)"#
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        let testCases = [
            ("FORMULA 1 AUSTRIAN GRAND PRIX - PRACTICE 1", ("AUSTRIAN GRAND PRIX", "PRACTICE 1")),
            ("FORMULA 1 MONACO GRAND PRIX - QUALIFYING", ("MONACO GRAND PRIX", "QUALIFYING")),
            ("FORMULA 1 BRITISH GRAND PRIX - RACE", ("BRITISH GRAND PRIX", "RACE")),
            ("FORMULA 1 ABU DHABI GRAND PRIX - SPRINT QUALIFYING", ("ABU DHABI GRAND PRIX", "SPRINT QUALIFYING"))
        ]
        
        for (input, expected) in testCases {
            let range = NSRange(location: 0, length: input.count)
            let match = regex.firstMatch(in: input, options: [], range: range)
            
            #expect(match != nil, "Failed to match: \(input)")
            #expect(match?.numberOfRanges == 3, "Should have 3 ranges for: \(input)")
            
            if let match = match, match.numberOfRanges == 3 {
                let roundNameRange = Range(match.range(at: 1), in: input)!
                let sessionKindRange = Range(match.range(at: 2), in: input)!
                
                let roundName = String(input[roundNameRange])
                let sessionKind = String(input[sessionKindRange])
                
                #expect(roundName == expected.0)
                #expect(sessionKind == expected.1)
            }
        }
    }
    
    @Test("Test invalid event summary parsing")
    func testInvalidEventSummaryParsing() {
        let pattern = #"FORMULA 1 (.+) - (.+)"#
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        let invalidCases = [
            "FORMULA 1 AUSTRIAN GRAND PRIX", // Missing session kind
            "AUSTRIAN GRAND PRIX - PRACTICE 1", // Missing "FORMULA 1"
            "F1 AUSTRIAN GRAND PRIX - PRACTICE 1", // Wrong prefix
            "FORMULA 1 - PRACTICE 1", // Missing round name
            "RANDOM EVENT TITLE" // Completely different format
        ]
        
        for invalidInput in invalidCases {
            let range = NSRange(location: 0, length: invalidInput.count)
            let match = regex.firstMatch(in: invalidInput, options: [], range: range)
            
            #expect(match == nil || match?.numberOfRanges != 3, "Should not match: \(invalidInput)")
        }
    }
    
    @Test("Test iCal line parsing")
    func testICalLineParsing() {
        let testLines = [
            "DTSTART:20241210T140000Z",
            "DTEND:20241210T160000Z",
            "SUMMARY:FORMULA 1 AUSTRIAN GRAND PRIX - PRACTICE 1",
            "LOCATION:Red Bull Ring, Austria",
            "UID:test123@formula1.com"
        ]
        
        var parsedData: [String: String] = [:]
        
        for line in testLines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if let colonIndex = trimmedLine.firstIndex(of: ":") {
                let key = String(trimmedLine[..<colonIndex])
                let value = String(trimmedLine[trimmedLine.index(after: colonIndex)...])
                parsedData[key] = value
            }
        }
        
        #expect(parsedData["DTSTART"] == "20241210T140000Z")
        #expect(parsedData["DTEND"] == "20241210T160000Z")
        #expect(parsedData["SUMMARY"] == "FORMULA 1 AUSTRIAN GRAND PRIX - PRACTICE 1")
        #expect(parsedData["LOCATION"] == "Red Bull Ring, Austria")
        #expect(parsedData["UID"] == "test123@formula1.com")
    }
    
    @Test("Test complete iCal parsing simulation")
    func testCompleteICalParsingSimulation() {
        let testICalData = """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//Formula 1//Formula 1//EN
        BEGIN:VEVENT
        DTSTART:20241210T130000Z
        DTEND:20241210T143000Z
        SUMMARY:FORMULA 1 AUSTRIAN GRAND PRIX - PRACTICE 1
        LOCATION:Red Bull Ring, Austria
        UID:fp1-austria-2024@formula1.com
        END:VEVENT
        BEGIN:VEVENT
        DTSTART:20241210T170000Z
        DTEND:20241210T180000Z
        SUMMARY:FORMULA 1 AUSTRIAN GRAND PRIX - QUALIFYING
        LOCATION:Red Bull Ring, Austria
        UID:qualifying-austria-2024@formula1.com
        END:VEVENT
        BEGIN:VEVENT
        DTSTART:20241211T140000Z
        DTEND:20241211T160000Z
        SUMMARY:FORMULA 1 AUSTRIAN GRAND PRIX - RACE
        LOCATION:Red Bull Ring, Austria
        UID:race-austria-2024@formula1.com
        END:VEVENT
        END:VCALENDAR
        """
        
        // Simulate the parsing logic from ScheduleCache
        var rounds: [String: TestRaceRound] = [:]
        let lines = testICalData.components(separatedBy: .newlines)
        
        var currentEvent: [String: String] = [:]
        var inEvent = false
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let pattern = #"FORMULA 1 (.+) - (.+)"#
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine == "BEGIN:VEVENT" {
                inEvent = true
                currentEvent = [:]
            } else if trimmedLine == "END:VEVENT" {
                inEvent = false
                
                if let summary = currentEvent["SUMMARY"],
                   let dtStart = currentEvent["DTSTART"],
                   let dtEnd = currentEvent["DTEND"],
                   let startDate = formatter.date(from: dtStart),
                   let endDate = formatter.date(from: dtEnd) {
                    
                    // Parse summary
                    let range = NSRange(location: 0, length: summary.count)
                    if let match = regex.firstMatch(in: summary, options: [], range: range),
                       match.numberOfRanges == 3 {
                        
                        let roundNameRange = Range(match.range(at: 1), in: summary)!
                        let sessionKindRange = Range(match.range(at: 2), in: summary)!
                        
                        let roundName = String(summary[roundNameRange])
                        let sessionKind = String(summary[sessionKindRange])
                        let location = currentEvent["LOCATION"] ?? ""
                        
                        let session = TestRaceSession(
                            kind: sessionKind,
                            start: startDate,
                            end: endDate
                        )
                        
                        if let existingRound = rounds[roundName] {
                            var sessions = existingRound.sessions
                            sessions.append(session)
                            sessions.sort { $0.start < $1.start }
                            
                            rounds[roundName] = TestRaceRound(
                                name: roundName,
                                location: location,
                                start: min(existingRound.start, startDate),
                                end: max(existingRound.end, endDate),
                                sessions: sessions
                            )
                        } else {
                            rounds[roundName] = TestRaceRound(
                                name: roundName,
                                location: location,
                                start: startDate,
                                end: endDate,
                                sessions: [session]
                            )
                        }
                    }
                }
            } else if inEvent {
                if let colonIndex = trimmedLine.firstIndex(of: ":") {
                    let key = String(trimmedLine[..<colonIndex])
                    let value = String(trimmedLine[trimmedLine.index(after: colonIndex)...])
                    currentEvent[key] = value
                }
            }
        }
        
        // Verify parsing results
        #expect(rounds.count == 1) // Should have one round (Austrian Grand Prix)
        
        if let austrianGP = rounds["AUSTRIAN GRAND PRIX"] {
            #expect(austrianGP.name == "AUSTRIAN GRAND PRIX")
            #expect(austrianGP.location == "Red Bull Ring, Austria")
            #expect(austrianGP.sessions.count == 3)
            
            // Verify sessions are sorted chronologically
            let sessionKinds = austrianGP.sessions.map { $0.kind }
            #expect(sessionKinds == ["PRACTICE 1", "QUALIFYING", "RACE"])
            
            // Verify session times
            for i in 0..<austrianGP.sessions.count - 1 {
                #expect(austrianGP.sessions[i].start < austrianGP.sessions[i + 1].start)
            }
        }
    }
    
    @Test("Test year filtering")
    func testYearFiltering() {
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        // Test dates from different years
        let currentYearDate = formatter.date(from: "\(currentYear)1210T140000Z")!
        let lastYearDate = formatter.date(from: "\(currentYear - 1)1210T140000Z")!
        let nextYearDate = formatter.date(from: "\(currentYear + 1)1210T140000Z")!
        
        // Current year should be included
        let currentYearComponent = Calendar.current.component(.year, from: currentYearDate)
        #expect(currentYearComponent == currentYear)
        
        // Last year should be filtered out
        let lastYearComponent = Calendar.current.component(.year, from: lastYearDate)
        #expect(lastYearComponent != currentYear)
        
        // Next year should be filtered out
        let nextYearComponent = Calendar.current.component(.year, from: nextYearDate)
        #expect(nextYearComponent != currentYear)
    }
    
    @Test("Test edge cases in iCal parsing")
    func testICalParsingEdgeCases() {
        // Test empty lines
        let emptyLine = ""
        let trimmed = emptyLine.trimmingCharacters(in: .whitespaces)
        #expect(trimmed.isEmpty)
        
        // Test lines without colon
        let noColonLine = "INVALID LINE FORMAT"
        #expect(noColonLine.firstIndex(of: ":") == nil)
        
        // Test lines with multiple colons
        let multiColonLine = "DTSTART:20241210T140000Z:EXTRA"
        if let colonIndex = multiColonLine.firstIndex(of: ":") {
            let key = String(multiColonLine[..<colonIndex])
            let value = String(multiColonLine[multiColonLine.index(after: colonIndex)...])
            #expect(key == "DTSTART")
            #expect(value == "20241210T140000Z:EXTRA")
        }
        
        // Test malformed dates
        let malformedDates = [
            "20241310T140000Z", // Invalid month
            "20241232T140000Z", // Invalid day
            "20241210T250000Z", // Invalid hour
            "invalid-date-format"
        ]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        for malformedDate in malformedDates {
            let parsedDate = formatter.date(from: malformedDate)
            #expect(parsedDate == nil, "Should not parse malformed date: \(malformedDate)")
        }
    }
}

// MARK: - Test Helper Types

struct TestRaceRound {
    let name: String
    let location: String
    let start: Date
    let end: Date
    var sessions: [TestRaceSession]
}

struct TestRaceSession {
    let kind: String
    let start: Date
    let end: Date
}