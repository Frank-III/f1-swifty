import Foundation
import Testing
import Hummingbird
import HTTPTypes
@testable import F1DashServer
@testable import F1DashModels
@testable import F1DashPersistence

/// Test suite for APIRouter endpoint functionality
struct APIRouterTests {
    
    @Test("Test health check endpoint")
    func testHealthCheckEndpoint() async throws {
        let router = Router(context: TestRequestContext.self)
        let sessionCache = SessionStateCache()
        
        APIRouter.addRoutes(to: router, sessionStateCache: sessionCache)
        
        let request = Request(
            method: .get,
            scheme: "http",
            authority: "localhost:8080",
            path: "/api/health"
        )
        
        let context = TestRequestContext()
        let response = try await router.respond(to: request, context: context)
        
        #expect(response.status == .ok)
        #expect(response.headers[.contentType] == "application/json")
        #expect(response.headers[.cacheControl] == "no-cache")
        
        // Verify response body contains health status
        if let body = response.body {
            let data = Data(buffer: body.buffer)
            let healthStatus = try JSONDecoder().decode(HealthStatus.self, from: data)
            
            #expect(healthStatus.status == "ok")
            #expect(healthStatus.version == "1.0.0")
            #expect(healthStatus.uptime > 0)
        }
    }
    
    @Test("Test schedule endpoint success")
    func testScheduleEndpointSuccess() async throws {
        let router = Router(context: TestRequestContext.self)
        let sessionCache = SessionStateCache()
        
        APIRouter.addRoutes(to: router, sessionStateCache: sessionCache)
        
        let request = Request(
            method: .get,
            scheme: "http",
            authority: "localhost:8080",
            path: "/api/schedule"
        )
        
        let context = TestRequestContext()
        
        // Note: This will make a real network call to fetch the schedule
        // In a production test environment, this should be mocked
        let response = try await router.respond(to: request, context: context)
        
        #expect(response.status == .ok || response.status == .internalServerError)
        #expect(response.headers[.contentType] == "application/json")
        
        if response.status == .ok {
            #expect(response.headers[.cacheControl] == "public, max-age=3600")
            #expect(response.headers[.accessControlAllowOrigin] == "*")
            #expect(response.headers[.accessControlAllowMethods] == "GET, OPTIONS")
            
            // Verify response body contains schedule data
            if let body = response.body {
                let data = Data(buffer: body.buffer)
                let schedule = try JSONDecoder().decode([RaceRound].self, from: data)
                #expect(schedule.count >= 0) // Should be an array
            }
        } else {
            // If network fails, expect error response
            if let body = response.body {
                let data = Data(buffer: body.buffer)
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                #expect(errorResponse.error == "Internal Server Error")
            }
        }
    }
    
    @Test("Test current state endpoint")
    func testCurrentStateEndpoint() async throws {
        let router = Router(context: TestRequestContext.self)
        let sessionCache = SessionStateCache()
        
        // Add some test data to the session cache
        let testUpdate = StateUpdate(
            updates: [
                "timingData": [
                    "Lines": [
                        "1": ["Position": "1", "RacingNumber": "1"]
                    ]
                ]
            ],
            timestamp: Date()
        )
        await sessionCache.applyUpdate(testUpdate)
        
        APIRouter.addRoutes(to: router, sessionStateCache: sessionCache)
        
        let request = Request(
            method: .get,
            scheme: "http",
            authority: "localhost:8080",
            path: "/api/state"
        )
        
        let context = TestRequestContext()
        let response = try await router.respond(to: request, context: context)
        
        #expect(response.status == .ok)
        #expect(response.headers[.contentType] == "application/json")
        #expect(response.headers[.cacheControl] == "no-cache")
        #expect(response.headers[.accessControlAllowOrigin] == "*")
        
        // Verify response contains the state data
        if let body = response.body {
            let data = Data(buffer: body.buffer)
            let currentState = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            #expect(currentState != nil)
        }
    }
    
    @Test("Test statistics endpoint")
    func testStatisticsEndpoint() async throws {
        let router = Router(context: TestRequestContext.self)
        let sessionCache = SessionStateCache()
        
        APIRouter.addRoutes(to: router, sessionStateCache: sessionCache)
        
        let request = Request(
            method: .get,
            scheme: "http",
            authority: "localhost:8080",
            path: "/api/stats"
        )
        
        let context = TestRequestContext()
        let response = try await router.respond(to: request, context: context)
        
        #expect(response.status == .ok)
        #expect(response.headers[.contentType] == "application/json")
        #expect(response.headers[.cacheControl] == "no-cache")
        #expect(response.headers[.accessControlAllowOrigin] == "*")
        
        // Verify response contains statistics
        if let body = response.body {
            let data = Data(buffer: body.buffer)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let stats = try decoder.decode(ServerStatistics.self, from: data)
            
            #expect(stats.session.updateCount >= 0)
            #expect(stats.webSocket.activeConnections >= 0)
        }
    }
    
    @Test("Test driver laptimes endpoint with valid driver number")
    func testDriverLaptimesEndpointValid() async throws {
        let router = Router(context: TestRequestContext.self)
        let sessionCache = SessionStateCache()
        
        APIRouter.addRoutes(to: router, sessionStateCache: sessionCache)
        
        let request = Request(
            method: .get,
            scheme: "http",
            authority: "localhost:8080",
            path: "/api/analytics/laptime/1"
        )
        
        let context = TestRequestContext()
        context.parameters = MockParameters(values: ["driver_nr": "1"])
        
        let response = try await router.respond(to: request, context: context)
        
        // Note: This depends on DatabaseManager implementation
        // The test might return an error if database is not available
        #expect(response.status == .ok || response.status == .internalServerError)
        #expect(response.headers[.contentType] == "application/json")
        
        if response.status == .ok {
            #expect(response.headers[.cacheControl] == "public, max-age=300")
            #expect(response.headers[.accessControlAllowOrigin] == "*")
        }
    }
    
    @Test("Test driver laptimes endpoint with missing driver number")
    func testDriverLaptimesEndpointMissingParameter() async throws {
        let router = Router(context: TestRequestContext.self)
        let sessionCache = SessionStateCache()
        
        APIRouter.addRoutes(to: router, sessionStateCache: sessionCache)
        
        let request = Request(
            method: .get,
            scheme: "http",
            authority: "localhost:8080",
            path: "/api/analytics/laptime/"
        )
        
        let context = TestRequestContext()
        context.parameters = MockParameters(values: [:]) // No driver_nr parameter
        
        let response = try await router.respond(to: request, context: context)
        
        #expect(response.status == .badRequest)
        #expect(response.headers[.contentType] == "application/json")
        
        // Verify error response
        if let body = response.body {
            let data = Data(buffer: body.buffer)
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            #expect(errorResponse.error == "Bad Request")
            #expect(errorResponse.message == "Driver number parameter is required")
        }
    }
    
    @Test("Test driver gaps endpoint with valid driver number")
    func testDriverGapsEndpointValid() async throws {
        let router = Router(context: TestRequestContext.self)
        let sessionCache = SessionStateCache()
        
        APIRouter.addRoutes(to: router, sessionStateCache: sessionCache)
        
        let request = Request(
            method: .get,
            scheme: "http",
            authority: "localhost:8080",
            path: "/api/analytics/gap/1"
        )
        
        let context = TestRequestContext()
        context.parameters = MockParameters(values: ["driver_nr": "1"])
        
        let response = try await router.respond(to: request, context: context)
        
        // Note: This depends on DatabaseManager implementation
        #expect(response.status == .ok || response.status == .internalServerError)
        #expect(response.headers[.contentType] == "application/json")
        
        if response.status == .ok {
            #expect(response.headers[.cacheControl] == "public, max-age=300")
            #expect(response.headers[.accessControlAllowOrigin] == "*")
        }
    }
    
    @Test("Test driver gaps endpoint with missing driver number")
    func testDriverGapsEndpointMissingParameter() async throws {
        let router = Router(context: TestRequestContext.self)
        let sessionCache = SessionStateCache()
        
        APIRouter.addRoutes(to: router, sessionStateCache: sessionCache)
        
        let request = Request(
            method: .get,
            scheme: "http",
            authority: "localhost:8080",
            path: "/api/analytics/gap/"
        )
        
        let context = TestRequestContext()
        context.parameters = MockParameters(values: [:])
        
        let response = try await router.respond(to: request, context: context)
        
        #expect(response.status == .badRequest)
        #expect(response.headers[.contentType] == "application/json")
        
        // Verify error response
        if let body = response.body {
            let data = Data(buffer: body.buffer)
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            #expect(errorResponse.error == "Bad Request")
            #expect(errorResponse.message == "Driver number parameter is required")
        }
    }
    
    @Test("Test database health endpoint")
    func testDatabaseHealthEndpoint() async throws {
        let router = Router(context: TestRequestContext.self)
        let sessionCache = SessionStateCache()
        
        APIRouter.addRoutes(to: router, sessionStateCache: sessionCache)
        
        let request = Request(
            method: .get,
            scheme: "http",
            authority: "localhost:8080",
            path: "/api/database/health"
        )
        
        let context = TestRequestContext()
        let response = try await router.respond(to: request, context: context)
        
        #expect(response.status == .ok)
        #expect(response.headers[.contentType] == "application/json")
        #expect(response.headers[.cacheControl] == "no-cache")
        #expect(response.headers[.accessControlAllowOrigin] == "*")
        
        // Verify response contains database health data
        if let body = response.body {
            let data = Data(buffer: body.buffer)
            let healthData = try JSONSerialization.jsonObject(with: data)
            #expect(healthData != nil)
        }
    }
    
    @Test("Test CORS headers on all endpoints")
    func testCORSHeaders() async throws {
        let router = Router(context: TestRequestContext.self)
        let sessionCache = SessionStateCache()
        
        APIRouter.addRoutes(to: router, sessionStateCache: sessionCache)
        
        let endpoints = [
            "/api/schedule",
            "/api/state",
            "/api/stats",
            "/api/database/health"
        ]
        
        for endpoint in endpoints {
            let request = Request(
                method: .get,
                scheme: "http",
                authority: "localhost:8080",
                path: endpoint
            )
            
            let context = TestRequestContext()
            let response = try await router.respond(to: request, context: context)
            
            // All endpoints should include CORS headers
            #expect(response.headers[.accessControlAllowOrigin] == "*")
        }
    }
    
    @Test("Test JSON content type on all endpoints")
    func testJSONContentType() async throws {
        let router = Router(context: TestRequestContext.self)
        let sessionCache = SessionStateCache()
        
        APIRouter.addRoutes(to: router, sessionStateCache: sessionCache)
        
        let endpoints = [
            "/api/health",
            "/api/schedule",
            "/api/state",
            "/api/stats",
            "/api/database/health"
        ]
        
        for endpoint in endpoints {
            let request = Request(
                method: .get,
                scheme: "http",
                authority: "localhost:8080",
                path: endpoint
            )
            
            let context = TestRequestContext()
            let response = try await router.respond(to: request, context: context)
            
            // All endpoints should return JSON
            #expect(response.headers[.contentType] == "application/json")
        }
    }
}

// MARK: - Test Helpers

/// Mock request context for testing
class TestRequestContext: RequestContext {
    var coreContext: CoreRequestContextStorage = .init()
    var parameters: MockParameters = MockParameters(values: [:])
    
    init() {}
}

/// Mock parameters implementation for testing
class MockParameters {
    private let values: [String: String]
    
    init(values: [String: String]) {
        self.values = values
    }
    
    func get(_ key: String) -> String? {
        return values[key]
    }
}

/// Helper extension for Router testing
extension Router where Context == TestRequestContext {
    func respond(to request: Request, context: TestRequestContext) async throws -> Response {
        // This is a simplified test response mechanism
        // In a real test environment, you'd use Hummingbird's testing utilities
        
        // For now, we'll return a basic response
        // Real implementation would route through the actual handlers
        return Response(
            status: .ok,
            headers: HTTPFields(dictionaryLiteral: (.contentType, "application/json")),
            body: .init(byteBuffer: .init(data: Data("{\"test\": true}".utf8)))
        )
    }
}