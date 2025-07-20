import Foundation
import Hummingbird
import HTTPTypes
import Logging
import F1DashModels
import F1DashPersistence
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Router for REST API endpoints
public struct APIRouter: Sendable {
    
    private let logger = Logger(label: "APIRouter")
    private let scheduleCache = ScheduleCache()
    private let standingsService = StandingsService()
    
    // MARK: - Public Interface
    
    /// Add API routes to the router
    internal static func addRoutes<Context: RequestContext>(
        to router: Router<Context>,
        sessionStateCache: SessionStateCache
    ) {
        let apiRouter = APIRouter()
        
        // Health check endpoint
        router.get("/api/health") { request, context in
            return try await apiRouter.healthCheck(request: request, context: context)
        }
        
        // Schedule endpoint
        router.get("/api/schedule") { request, context in
            return try await apiRouter.getSchedule(request: request, context: context)
        }
        
        // Session state endpoint (for debugging)
        router.get("/api/state") { request, context in
            return try await apiRouter.getCurrentState(
                request: request,
                context: context,
                sessionStateCache: sessionStateCache
            )
        }
        
        // Session statistics endpoint
        router.get("/api/stats") { request, context in
            return try await apiRouter.getStatistics(
                request: request,
                context: context,
                sessionStateCache: sessionStateCache
            )
        }
        
        // Analytics endpoints (mirrors Rust analytics service)
        router.get("/api/analytics/laptime/:driver_nr") { request, context in
            return try await apiRouter.getDriverLaptimes(
                request: request,
                context: context
            )
        }
        
        router.get("/api/analytics/gap/:driver_nr") { request, context in
            return try await apiRouter.getDriverGaps(
                request: request,
                context: context
            )
        }
        
        // Database health check endpoint
        router.get("/api/database/health") { request, context in
            return try await apiRouter.getDatabaseHealth(
                request: request,
                context: context,
                sessionStateCache: sessionStateCache
            )
        }
        
        // Standings endpoints
        router.get("/api/standings/drivers/:year") { request, context in
            return try await apiRouter.getDriverStandings(
                request: request,
                context: context
            )
        }
        
        router.get("/api/standings/teams/:year") { request, context in
            return try await apiRouter.getTeamStandings(
                request: request,
                context: context
            )
        }
    }
    
    // MARK: - Route Handlers
    
    private func healthCheck(
        request: Request,
        context: some RequestContext
    ) async throws -> Response {
        
        let health = HealthStatus(
            status: "ok",
            timestamp: Date(),
            version: "1.0.0",
            uptime: ProcessInfo.processInfo.systemUptime
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(health)
        
        return Response(
            status: .ok,
            headers: HTTPFields(dictionaryLiteral:
                (.contentType, "application/json"),
                (.cacheControl, "no-cache")
            ),
            body: .init(byteBuffer: .init(data: data))
        )
    }
    
    private func getSchedule(
        request: Request,
        context: some RequestContext
    ) async throws -> Response {
        
        do {
            let schedule = try await scheduleCache.getSchedule()
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(schedule)
            
            return Response(
                status: .ok,
                headers: HTTPFields(dictionaryLiteral:
                    (.contentType, "application/json"),
                    (.cacheControl, "public, max-age=3600"), // Cache for 1 hour
                    (.accessControlAllowOrigin, "*"),
                    (.accessControlAllowMethods, "GET, OPTIONS"),
                    (.accessControlAllowHeaders, "Content-Type")
                ),
                body: .init(byteBuffer: .init(data: data))
            )
            
        } catch {
            logger.error("Failed to get schedule: \(error)")
            
            let errorResponse = ErrorResponse(
                error: "Internal Server Error",
                message: "Failed to fetch schedule data"
            )
            
            let encoder = JSONEncoder()
            let data = try encoder.encode(errorResponse)
            
            return Response(
                status: .internalServerError,
                headers: HTTPFields(dictionaryLiteral: (.contentType, "application/json")),
                body: .init(byteBuffer: .init(data: data))
            )
        }
    }
    
    private func getCurrentState(
        request: Request,
        context: some RequestContext,
        sessionStateCache: SessionStateCache
    ) async throws -> Response {
        
        // Get the raw state as JSONValue instead of trying to decode to F1State
        let jsonValue = await sessionStateCache.getCurrentStateAsJSON()
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(jsonValue)
        
        return Response(
            status: .ok,
            headers: HTTPFields(dictionaryLiteral:
                (.contentType, "application/json"),
                (.cacheControl, "no-cache"),
                (.accessControlAllowOrigin, "*")
            ),
            body: .init(byteBuffer: .init(data: data))
        )
    }
    
    private func getStatistics(
        request: Request,
        context: some RequestContext,
        sessionStateCache: SessionStateCache
    ) async throws -> Response {
        
        let sessionStats = await sessionStateCache.getStatistics()
        let webSocketStats = WebSocketHealthCheck.getStatistics()
        
        let stats = ServerStatistics(
            session: sessionStats,
            webSocket: webSocketStats,
            timestamp: Date()
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(stats)
        
        return Response(
            status: .ok,
            headers: HTTPFields(dictionaryLiteral:
                (.contentType, "application/json"),
                (.cacheControl, "no-cache"),
                (.accessControlAllowOrigin, "*")
            ),
            body: .init(byteBuffer: .init(data: data))
        )
    }
    
    // MARK: - Analytics Endpoints
    
    private func getDriverLaptimes(
        request: Request,
        context: some RequestContext
    ) async throws -> Response {
        
        guard let driverNr = context.parameters.get("driver_nr") else {
            let errorResponse = ErrorResponse(
                error: "Bad Request",
                message: "Driver number parameter is required"
            )
            
            let encoder = JSONEncoder()
            let data = try encoder.encode(errorResponse)
            
            return Response(
                status: .badRequest,
                headers: HTTPFields(dictionaryLiteral: (.contentType, "application/json")),
                body: .init(byteBuffer: .init(data: data))
            )
        }
        
        do {
            let laptimes = try await DatabaseManager.shared.getLaptimes(for: driverNr)
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(laptimes)
            
            return Response(
                status: .ok,
                headers: HTTPFields(dictionaryLiteral:
                    (.contentType, "application/json"),
                    (.cacheControl, "public, max-age=300"), // Cache for 5 minutes
                    (.accessControlAllowOrigin, "*"),
                    (.accessControlAllowMethods, "GET, OPTIONS"),
                    (.accessControlAllowHeaders, "Content-Type")
                ),
                body: .init(byteBuffer: .init(data: data))
            )
            
        } catch {
            logger.error("Failed to get laptime data for driver \(driverNr): \(error)")
            
            let errorResponse = ErrorResponse(
                error: "Internal Server Error",
                message: "Failed to fetch laptime data"
            )
            
            let encoder = JSONEncoder()
            let data = try encoder.encode(errorResponse)
            
            return Response(
                status: .internalServerError,
                headers: HTTPFields(dictionaryLiteral: (.contentType, "application/json")),
                body: .init(byteBuffer: .init(data: data))
            )
        }
    }
    
    private func getDriverGaps(
        request: Request,
        context: some RequestContext
    ) async throws -> Response {
        
        guard let driverNr = context.parameters.get("driver_nr") else {
            let errorResponse = ErrorResponse(
                error: "Bad Request",
                message: "Driver number parameter is required"
            )
            
            let encoder = JSONEncoder()
            let data = try encoder.encode(errorResponse)
            
            return Response(
                status: .badRequest,
                headers: HTTPFields(dictionaryLiteral: (.contentType, "application/json")),
                body: .init(byteBuffer: .init(data: data))
            )
        }
        
        do {
            let gaps = try await DatabaseManager.shared.getGaps(for: driverNr)
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(gaps)
            
            return Response(
                status: .ok,
                headers: HTTPFields(dictionaryLiteral:
                    (.contentType, "application/json"),
                    (.cacheControl, "public, max-age=300"), // Cache for 5 minutes
                    (.accessControlAllowOrigin, "*"),
                    (.accessControlAllowMethods, "GET, OPTIONS"),
                    (.accessControlAllowHeaders, "Content-Type")
                ),
                body: .init(byteBuffer: .init(data: data))
            )
            
        } catch {
            logger.error("Failed to get gap data for driver \(driverNr): \(error)")
            
            let errorResponse = ErrorResponse(
                error: "Internal Server Error",
                message: "Failed to fetch gap data"
            )
            
            let encoder = JSONEncoder()
            let data = try encoder.encode(errorResponse)
            
            return Response(
                status: .internalServerError,
                headers: HTTPFields(dictionaryLiteral: (.contentType, "application/json")),
                body: .init(byteBuffer: .init(data: data))
            )
        }
    }
    
    private func getDatabaseHealth(
        request: Request,
        context: some RequestContext,
        sessionStateCache: SessionStateCache
    ) async throws -> Response {
        
        let databaseHealth = await sessionStateCache.getDatabaseHealth()
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(databaseHealth)
        
        return Response(
            status: .ok,
            headers: HTTPFields(dictionaryLiteral:
                (.contentType, "application/json"),
                (.cacheControl, "no-cache"),
                (.accessControlAllowOrigin, "*")
            ),
            body: .init(byteBuffer: .init(data: data))
        )
    }
    
    // MARK: - Standings Endpoints
    
    private func getDriverStandings(
        request: Request,
        context: some RequestContext
    ) async throws -> Response {
        
        guard let yearString = context.parameters.get("year"),
              let year = Int(yearString) else {
            let errorResponse = ErrorResponse(
                error: "Bad Request",
                message: "Valid year parameter is required"
            )
            
            let encoder = JSONEncoder()
            let data = try encoder.encode(errorResponse)
            
            return Response(
                status: .badRequest,
                headers: HTTPFields(dictionaryLiteral: (.contentType, "application/json")),
                body: .init(byteBuffer: .init(data: data))
            )
        }
        
        do {
            let standings = try await standingsService.getDriverStandings(year: year)
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(standings)
            
            return Response(
                status: .ok,
                headers: HTTPFields(dictionaryLiteral:
                    (.contentType, "application/json"),
                    (.cacheControl, "public, max-age=3600"), // Cache for 1 hour
                    (.accessControlAllowOrigin, "*"),
                    (.accessControlAllowMethods, "GET, OPTIONS"),
                    (.accessControlAllowHeaders, "Content-Type")
                ),
                body: .init(byteBuffer: .init(data: data))
            )
            
        } catch {
            logger.error("Failed to get driver standings for year \(year): \(error)")
            
            let errorResponse = ErrorResponse(
                error: "Internal Server Error",
                message: "Failed to fetch driver standings"
            )
            
            let encoder = JSONEncoder()
            let data = try encoder.encode(errorResponse)
            
            return Response(
                status: .internalServerError,
                headers: HTTPFields(dictionaryLiteral: (.contentType, "application/json")),
                body: .init(byteBuffer: .init(data: data))
            )
        }
    }
    
    private func getTeamStandings(
        request: Request,
        context: some RequestContext
    ) async throws -> Response {
        
        guard let yearString = context.parameters.get("year"),
              let year = Int(yearString) else {
            let errorResponse = ErrorResponse(
                error: "Bad Request",
                message: "Valid year parameter is required"
            )
            
            let encoder = JSONEncoder()
            let data = try encoder.encode(errorResponse)
            
            return Response(
                status: .badRequest,
                headers: HTTPFields(dictionaryLiteral: (.contentType, "application/json")),
                body: .init(byteBuffer: .init(data: data))
            )
        }
        
        do {
            let standings = try await standingsService.getTeamStandings(year: year)
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(standings)
            
            return Response(
                status: .ok,
                headers: HTTPFields(dictionaryLiteral:
                    (.contentType, "application/json"),
                    (.cacheControl, "public, max-age=3600"), // Cache for 1 hour
                    (.accessControlAllowOrigin, "*"),
                    (.accessControlAllowMethods, "GET, OPTIONS"),
                    (.accessControlAllowHeaders, "Content-Type")
                ),
                body: .init(byteBuffer: .init(data: data))
            )
            
        } catch {
            logger.error("Failed to get team standings for year \(year): \(error)")
            
            let errorResponse = ErrorResponse(
                error: "Internal Server Error",
                message: "Failed to fetch team standings"
            )
            
            let encoder = JSONEncoder()
            let data = try encoder.encode(errorResponse)
            
            return Response(
                status: .internalServerError,
                headers: HTTPFields(dictionaryLiteral: (.contentType, "application/json")),
                body: .init(byteBuffer: .init(data: data))
            )
        }
    }
}

// MARK: - Schedule Cache

/// In-memory cache for F1 race schedule
actor ScheduleCache {
    
    private var cachedSchedule: [RaceRound]?
    private var lastFetch: Date?
    private let cacheTimeout: TimeInterval = 3600 // 1 hour
    private let logger = Logger(label: "ScheduleCache")
    
    func getSchedule() async throws -> [RaceRound] {
        // Check if we have valid cached data
        if let cached = cachedSchedule,
           let lastFetch = lastFetch,
           Date().timeIntervalSince(lastFetch) < cacheTimeout {
            return cached
        }
        
        // Fetch fresh data
        logger.info("Fetching fresh schedule data")
        let schedule = try await fetchScheduleFromAPI()
        
        cachedSchedule = schedule
        lastFetch = Date()
        
        return schedule
    }
    
    private func fetchScheduleFromAPI() async throws -> [RaceRound] {
        let currentYear = Calendar.current.component(.year, from: Date())
        
        // F1 calendar iCal URL
        let calendarURL = "https://ics.ecal.com/ecal-sub/660897ca63f9ca0008bcbea6/Formula%201.ics"
        
        guard let url = URL(string: calendarURL) else {
            throw ScheduleError.invalidURL
        }
        
        // Fetch iCal data
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let icalString = String(data: data, encoding: .utf8) else {
            throw ScheduleError.invalidData
        }
        
        // Parse iCal and convert to RaceRounds
        return try parseICalToRaceRounds(icalString, year: currentYear)
    }
    
    private func parseICalToRaceRounds(_ icalString: String, year: Int) throws -> [RaceRound] {
        var rounds: [String: RaceRound] = [:]
        let lines = icalString.components(separatedBy: .newlines)
        
        var currentEvent: [String: String] = [:]
        var inEvent = false
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine == "BEGIN:VEVENT" {
                inEvent = true
                currentEvent = [:]
            } else if trimmedLine == "END:VEVENT" {
                inEvent = false
                
                if let summary = currentEvent["SUMMARY"],
                   let (roundName, sessionKind) = parseEventSummary(summary),
                   let dtStart = currentEvent["DTSTART"],
                   let dtEnd = currentEvent["DTEND"],
                   let startDate = parseICalDate(dtStart),
                   let endDate = parseICalDate(dtEnd),
                   Calendar.current.component(.year, from: startDate) == year {
                    
                    let location = currentEvent["LOCATION"] ?? ""
                    let session = RaceSession(kind: sessionKind, start: startDate, end: endDate)
                    
                    if let existingRound = rounds[roundName] {
                        // Update existing round
                        var sessions = existingRound.sessions
                        sessions.append(session)
                        sessions.sort { $0.start < $1.start }
                        
                        let roundStart = min(existingRound.start, startDate)
                        let roundEnd = max(existingRound.end, endDate)
                        
                        rounds[roundName] = RaceRound(
                            name: roundName,
                            countryName: location,
                            countryKey: existingRound.countryKey,
                            start: roundStart,
                            end: roundEnd,
                            sessions: sessions,
                            over: roundEnd < Date()
                        )
                    } else {
                        // Create new round
                        rounds[roundName] = RaceRound(
                            name: roundName,
                            countryName: location,
                            countryKey: nil,
                            start: startDate,
                            end: endDate,
                            sessions: [session],
                            over: endDate < Date()
                        )
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
        
        // Convert to array and sort by start date
        var sortedRounds = Array(rounds.values)
        sortedRounds.sort { $0.start < $1.start }
        
        return sortedRounds
    }
    
    private func parseEventSummary(_ summary: String) -> (String, String)? {
        // Parse "FORMULA 1 ROUND_NAME - SESSION_KIND" format
        let pattern = #"FORMULA 1 (.+) - (.+)"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        guard let regex = regex,
              let match = regex.firstMatch(in: summary, options: [], range: NSRange(location: 0, length: summary.count)),
              match.numberOfRanges == 3 else {
            return nil
        }
        
        let roundNameRange = Range(match.range(at: 1), in: summary)!
        let sessionKindRange = Range(match.range(at: 2), in: summary)!
        
        let roundName = String(summary[roundNameRange])
        let sessionKind = String(summary[sessionKindRange])
        
        return (roundName, sessionKind)
    }
    
    private func parseICalDate(_ dateString: String) -> Date? {
        // Parse format: 20241210T140000Z
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.date(from: dateString)
    }
}

// MARK: - Supporting Types

enum ScheduleError: Error {
    case invalidURL
    case invalidData
    case parseError(String)
}

public struct HealthStatus: Sendable, Codable {
    public let status: String
    public let timestamp: Date
    public let version: String
    public let uptime: TimeInterval
    
    public init(status: String, timestamp: Date, version: String, uptime: TimeInterval) {
        self.status = status
        self.timestamp = timestamp
        self.version = version
        self.uptime = uptime
    }
}

public struct ErrorResponse: Sendable, Codable {
    public let error: String
    public let message: String
    
    public init(error: String, message: String) {
        self.error = error
        self.message = message
    }
}

public struct ServerStatistics: Sendable, Codable {
    public let session: SessionStatistics
    public let webSocket: WebSocketStatistics
    public let timestamp: Date
    
    public init(session: SessionStatistics, webSocket: WebSocketStatistics, timestamp: Date) {
        self.session = session
        self.webSocket = webSocket
        self.timestamp = timestamp
    }
}

public struct RaceRound: Sendable, Codable {
    public let name: String
    public let countryName: String
    public let countryKey: String?
    public let start: Date
    public let end: Date
    public let sessions: [RaceSession]
    public let over: Bool
    
    public init(
        name: String,
        countryName: String,
        countryKey: String?,
        start: Date,
        end: Date,
        sessions: [RaceSession],
        over: Bool
    ) {
        self.name = name
        self.countryName = countryName
        self.countryKey = countryKey
        self.start = start
        self.end = end
        self.sessions = sessions
        self.over = over
    }
}

public struct RaceSession: Sendable, Codable {
    public let kind: String
    public let start: Date
    public let end: Date
    
    public init(kind: String, start: Date, end: Date) {
        self.kind = kind
        self.start = start
        self.end = end
    }
}
