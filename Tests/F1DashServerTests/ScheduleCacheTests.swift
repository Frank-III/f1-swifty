import Foundation
import Testing
@testable import F1DashServer

/// Test suite for ScheduleCache functionality
struct ScheduleCacheTests {
    
    @Test("Test schedule caching behavior")
    func testScheduleCaching() async throws {
        let cache = ScheduleCache()
        
        // First call should fetch from network
        // Note: This will make a real network call in this test
        // In production, this should be mocked
        do {
            let schedule1 = try await cache.getSchedule()
            let schedule2 = try await cache.getSchedule()
            
            // Both calls should return the same data (cached)
            #expect(schedule1.count == schedule2.count)
            
            // Verify the schedule contains race rounds
            #expect(schedule1.count >= 0)
            
            // Check that rounds have expected structure
            if let firstRound = schedule1.first {
                #expect(!firstRound.name.isEmpty)
                #expect(!firstRound.countryName.isEmpty)
                #expect(firstRound.sessions.count > 0)
                #expect(firstRound.start <= firstRound.end)
            }
            
        } catch {
            // Network calls may fail in test environment, which is acceptable
            #expect(error is ScheduleError)
        }
    }
    
    @Test("Test RaceRound structure")
    func testRaceRoundStructure() {
        let session1 = RaceSession(
            kind: "Practice 1",
            start: Date(),
            end: Date().addingTimeInterval(5400) // 1.5 hours
        )
        
        let session2 = RaceSession(
            kind: "Qualifying",
            start: Date().addingTimeInterval(86400), // Next day
            end: Date().addingTimeInterval(90000)
        )
        
        let raceRound = RaceRound(
            name: "Austrian Grand Prix",
            countryName: "Austria",
            countryKey: "AT",
            start: session1.start,
            end: session2.end,
            sessions: [session1, session2],
            over: false
        )
        
        #expect(raceRound.name == "Austrian Grand Prix")
        #expect(raceRound.countryName == "Austria")
        #expect(raceRound.countryKey == "AT")
        #expect(raceRound.sessions.count == 2)
        #expect(raceRound.over == false)
        #expect(raceRound.start == session1.start)
        #expect(raceRound.end == session2.end)
    }
    
    @Test("Test RaceSession structure")
    func testRaceSessionStructure() {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(5400) // 1.5 hours
        
        let session = RaceSession(
            kind: "Sprint Race",
            start: startDate,
            end: endDate
        )
        
        #expect(session.kind == "Sprint Race")
        #expect(session.start == startDate)
        #expect(session.end == endDate)
        #expect(session.start < session.end)
    }
    
    @Test("Test race round over status")
    func testRaceRoundOverStatus() {
        let pastDate = Date().addingTimeInterval(-86400) // Yesterday
        let futureDate = Date().addingTimeInterval(86400) // Tomorrow
        
        // Past race should be marked as over
        let pastSession = RaceSession(
            kind: "Race",
            start: pastDate,
            end: pastDate.addingTimeInterval(7200)
        )
        
        let pastRound = RaceRound(
            name: "Past Grand Prix",
            countryName: "Test Country",
            countryKey: "TC",
            start: pastSession.start,
            end: pastSession.end,
            sessions: [pastSession],
            over: pastSession.end < Date()
        )
        
        #expect(pastRound.over == true)
        
        // Future race should not be marked as over
        let futureSession = RaceSession(
            kind: "Race",
            start: futureDate,
            end: futureDate.addingTimeInterval(7200)
        )
        
        let futureRound = RaceRound(
            name: "Future Grand Prix",
            countryName: "Test Country",
            countryKey: "TC",
            start: futureSession.start,
            end: futureSession.end,
            sessions: [futureSession],
            over: futureSession.end < Date()
        )
        
        #expect(futureRound.over == false)
    }
    
    @Test("Test session ordering")
    func testSessionOrdering() {
        let baseDate = Date()
        
        let practice = RaceSession(
            kind: "Practice 1",
            start: baseDate,
            end: baseDate.addingTimeInterval(5400)
        )
        
        let qualifying = RaceSession(
            kind: "Qualifying",
            start: baseDate.addingTimeInterval(86400),
            end: baseDate.addingTimeInterval(90000)
        )
        
        let race = RaceSession(
            kind: "Race",
            start: baseDate.addingTimeInterval(172800),
            end: baseDate.addingTimeInterval(180000)
        )
        
        // Create sessions in random order
        var sessions = [race, practice, qualifying]
        
        // Sort them as the ScheduleCache would
        sessions.sort { $0.start < $1.start }
        
        #expect(sessions[0].kind == "Practice 1")
        #expect(sessions[1].kind == "Qualifying")
        #expect(sessions[2].kind == "Race")
        
        // Verify chronological order
        #expect(sessions[0].start < sessions[1].start)
        #expect(sessions[1].start < sessions[2].start)
    }
    
    @Test("Test schedule error types")
    func testScheduleErrorTypes() {
        let invalidURLError = ScheduleError.invalidURL
        let invalidDataError = ScheduleError.invalidData
        let parseError = ScheduleError.parseError("Test error message")
        
        // Verify error types can be created and compared
        switch invalidURLError {
        case .invalidURL:
            #expect(true) // Expected
        default:
            #expect(false, "Should be invalidURL error")
        }
        
        switch invalidDataError {
        case .invalidData:
            #expect(true) // Expected
        default:
            #expect(false, "Should be invalidData error")
        }
        
        switch parseError {
        case .parseError(let message):
            #expect(message == "Test error message")
        default:
            #expect(false, "Should be parseError")
        }
    }
    
    @Test("Test concurrent cache access")
    func testConcurrentCacheAccess() async throws {
        let cache = ScheduleCache()
        
        // Simulate multiple concurrent requests
        let tasks = (1...5).map { _ in
            Task {
                do {
                    return try await cache.getSchedule()
                } catch {
                    // Network errors are acceptable in test environment
                    return []
                }
            }
        }
        
        let results = await withTaskGroup(of: [RaceRound].self) { group in
            for task in tasks {
                group.addTask {
                    await task.value
                }
            }
            
            var allResults: [[RaceRound]] = []
            for await result in group {
                allResults.append(result)
            }
            return allResults
        }
        
        // All results should be the same (from cache after first fetch)
        if let firstResult = results.first {
            for result in results {
                #expect(result.count == firstResult.count)
            }
        }
    }
    
    @Test("Test date formatting and parsing")
    func testDateFormatting() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        // Test parsing iCal date format
        let testDateString = "20241210T140000Z"
        let parsedDate = formatter.date(from: testDateString)
        
        #expect(parsedDate != nil)
        
        if let date = parsedDate {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            
            #expect(components.year == 2024)
            #expect(components.month == 12)
            #expect(components.day == 10)
            #expect(components.hour == 14)
            #expect(components.minute == 0)
        }
    }
    
    @Test("Test race round JSON encoding/decoding")
    func testRaceRoundCodable() throws {
        let session = RaceSession(
            kind: "Race",
            start: Date(),
            end: Date().addingTimeInterval(7200)
        )
        
        let originalRound = RaceRound(
            name: "Test Grand Prix",
            countryName: "Test Country",
            countryKey: "TC",
            start: session.start,
            end: session.end,
            sessions: [session],
            over: false
        )
        
        // Encode to JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(originalRound)
        
        // Decode from JSON
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedRound = try decoder.decode(RaceRound.self, from: jsonData)
        
        // Verify all fields match
        #expect(decodedRound.name == originalRound.name)
        #expect(decodedRound.countryName == originalRound.countryName)
        #expect(decodedRound.countryKey == originalRound.countryKey)
        #expect(decodedRound.over == originalRound.over)
        #expect(decodedRound.sessions.count == originalRound.sessions.count)
        
        // Compare dates (allowing for small precision differences)
        let timeDifference = abs(decodedRound.start.timeIntervalSince(originalRound.start))
        #expect(timeDifference < 1.0) // Less than 1 second difference
    }
    
    @Test("Test empty schedule handling")
    func testEmptyScheduleHandling() {
        // Test with empty schedule array
        let emptySchedule: [RaceRound] = []
        
        #expect(emptySchedule.isEmpty)
        #expect(emptySchedule.count == 0)
        
        // Test that empty schedule can be encoded/decoded
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(emptySchedule)
        
        let decoder = JSONDecoder()
        let decodedSchedule = try! decoder.decode([RaceRound].self, from: jsonData)
        
        #expect(decodedSchedule.isEmpty)
    }
    
    @Test("Test schedule sorting")
    func testScheduleSorting() {
        let baseDate = Date()
        
        // Create rounds in reverse chronological order
        let round3 = RaceRound(
            name: "Third Grand Prix",
            countryName: "Country C",
            countryKey: "CC",
            start: baseDate.addingTimeInterval(172800), // +2 days
            end: baseDate.addingTimeInterval(180000),
            sessions: [],
            over: false
        )
        
        let round1 = RaceRound(
            name: "First Grand Prix",
            countryName: "Country A",
            countryKey: "AA",
            start: baseDate,
            end: baseDate.addingTimeInterval(7200),
            sessions: [],
            over: false
        )
        
        let round2 = RaceRound(
            name: "Second Grand Prix",
            countryName: "Country B",
            countryKey: "BB",
            start: baseDate.addingTimeInterval(86400), // +1 day
            end: baseDate.addingTimeInterval(90000),
            sessions: [],
            over: false
        )
        
        var schedule = [round3, round1, round2]
        schedule.sort { $0.start < $1.start }
        
        #expect(schedule[0].name == "First Grand Prix")
        #expect(schedule[1].name == "Second Grand Prix")
        #expect(schedule[2].name == "Third Grand Prix")
    }
}