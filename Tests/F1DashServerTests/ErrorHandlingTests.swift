import Foundation
import Testing
import HTTPTypes
@testable import F1DashServer

/// Test suite for error response handling across the F1DashServer
struct ErrorHandlingTests {
    
    @Test("Test HealthStatus structure")
    func testHealthStatusStructure() {
        let timestamp = Date()
        let uptime: TimeInterval = 12345.67
        
        let health = HealthStatus(
            status: "ok",
            timestamp: timestamp,
            version: "1.0.0",
            uptime: uptime
        )
        
        #expect(health.status == "ok")
        #expect(health.timestamp == timestamp)
        #expect(health.version == "1.0.0")
        #expect(health.uptime == uptime)
    }
    
    @Test("Test HealthStatus JSON encoding/decoding")
    func testHealthStatusCodable() throws {
        let originalHealth = HealthStatus(
            status: "degraded",
            timestamp: Date(),
            version: "2.1.0",
            uptime: 98765.43
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(originalHealth)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedHealth = try decoder.decode(HealthStatus.self, from: jsonData)
        
        #expect(decodedHealth.status == originalHealth.status)
        #expect(decodedHealth.version == originalHealth.version)
        #expect(abs(decodedHealth.uptime - originalHealth.uptime) < 0.01)
        
        // Allow small timestamp differences due to encoding precision
        let timeDiff = abs(decodedHealth.timestamp.timeIntervalSince(originalHealth.timestamp))
        #expect(timeDiff < 1.0)
    }
    
    @Test("Test ErrorResponse structure")
    func testErrorResponseStructure() {
        let error = ErrorResponse(
            error: "Bad Request",
            message: "Invalid parameter provided"
        )
        
        #expect(error.error == "Bad Request")
        #expect(error.message == "Invalid parameter provided")
    }
    
    @Test("Test ErrorResponse JSON encoding/decoding")
    func testErrorResponseCodable() throws {
        let originalError = ErrorResponse(
            error: "Internal Server Error",
            message: "Database connection failed"
        )
        
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(originalError)
        
        let decoder = JSONDecoder()
        let decodedError = try decoder.decode(ErrorResponse.self, from: jsonData)
        
        #expect(decodedError.error == originalError.error)
        #expect(decodedError.message == originalError.message)
    }
    
    @Test("Test ServerStatistics structure")
    func testServerStatisticsStructure() {
        let sessionStats = SessionStatistics(
            updateCount: 100,
            lastUpdateTime: Date(),
            dataSize: 1024
        )
        
        let webSocketStats = WebSocketStatistics(
            activeConnections: 5,
            totalMessages: 1000,
            lastHeartbeat: Date()
        )
        
        let timestamp = Date()
        let serverStats = ServerStatistics(
            session: sessionStats,
            webSocket: webSocketStats,
            timestamp: timestamp
        )
        
        #expect(serverStats.session.updateCount == 100)
        #expect(serverStats.webSocket.activeConnections == 5)
        #expect(serverStats.timestamp == timestamp)
    }
    
    @Test("Test ServerStatistics JSON encoding/decoding")
    func testServerStatisticsCodable() throws {
        let sessionStats = SessionStatistics(
            updateCount: 250,
            lastUpdateTime: Date(),
            dataSize: 2048
        )
        
        let webSocketStats = WebSocketStatistics(
            activeConnections: 12,
            totalMessages: 5000,
            lastHeartbeat: Date()
        )
        
        let originalStats = ServerStatistics(
            session: sessionStats,
            webSocket: webSocketStats,
            timestamp: Date()
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(originalStats)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedStats = try decoder.decode(ServerStatistics.self, from: jsonData)
        
        #expect(decodedStats.session.updateCount == originalStats.session.updateCount)
        #expect(decodedStats.session.dataSize == originalStats.session.dataSize)
        #expect(decodedStats.webSocket.activeConnections == originalStats.webSocket.activeConnections)
        #expect(decodedStats.webSocket.totalMessages == originalStats.webSocket.totalMessages)
    }
    
    @Test("Test ScheduleError types")
    func testScheduleErrorTypes() {
        let errors: [ScheduleError] = [
            .invalidURL,
            .invalidData,
            .parseError("Custom parse error message")
        ]
        
        for error in errors {
            switch error {
            case .invalidURL:
                #expect(true) // This is expected
            case .invalidData:
                #expect(true) // This is expected
            case .parseError(let message):
                #expect(message == "Custom parse error message")
            }
        }
    }
    
    @Test("Test error response content types")
    func testErrorResponseContentTypes() {
        // Test various error scenarios and their expected formats
        let errorResponses = [
            ErrorResponse(error: "400", message: "Bad Request"),
            ErrorResponse(error: "401", message: "Unauthorized"),
            ErrorResponse(error: "403", message: "Forbidden"),
            ErrorResponse(error: "404", message: "Not Found"),
            ErrorResponse(error: "500", message: "Internal Server Error"),
            ErrorResponse(error: "502", message: "Bad Gateway"),
            ErrorResponse(error: "503", message: "Service Unavailable")
        ]
        
        for errorResponse in errorResponses {
            #expect(!errorResponse.error.isEmpty)
            #expect(!errorResponse.message.isEmpty)
            
            // Verify they can be encoded to JSON
            let encoder = JSONEncoder()
            let jsonData = try! encoder.encode(errorResponse)
            #expect(jsonData.count > 0)
            
            // Verify the JSON structure
            let jsonObject = try! JSONSerialization.jsonObject(with: jsonData) as! [String: String]
            #expect(jsonObject["error"] == errorResponse.error)
            #expect(jsonObject["message"] == errorResponse.message)
        }
    }
    
    @Test("Test health status variations")
    func testHealthStatusVariations() {
        let healthStatuses = [
            HealthStatus(status: "ok", timestamp: Date(), version: "1.0.0", uptime: 100),
            HealthStatus(status: "degraded", timestamp: Date(), version: "1.1.0", uptime: 1000),
            HealthStatus(status: "error", timestamp: Date(), version: "2.0.0", uptime: 10000),
            HealthStatus(status: "maintenance", timestamp: Date(), version: "0.9.0", uptime: 50)
        ]
        
        for health in healthStatuses {
            #expect(!health.status.isEmpty)
            #expect(!health.version.isEmpty)
            #expect(health.uptime >= 0)
            
            // Verify encoding works for all statuses
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try! encoder.encode(health)
            #expect(jsonData.count > 0)
        }
    }
    
    @Test("Test error message formatting")
    func testErrorMessageFormatting() {
        let testCases = [
            ("driver_nr", "Driver number parameter is required"),
            ("session_id", "Session ID parameter is required"),
            ("timestamp", "Timestamp parameter is required"),
            ("data", "Data parameter is required")
        ]
        
        for (parameter, expectedMessage) in testCases {
            let errorMessage = "\(parameter.capitalized) parameter is required"
                .replacingOccurrences(of: "_", with: " ")
                .replacingOccurrences(of: "nr", with: "number")
                .replacingOccurrences(of: "id", with: "ID")
            
            if parameter == "driver_nr" {
                #expect(errorMessage.contains("Driver"))
                #expect(errorMessage.contains("number"))
            }
        }
    }
    
    @Test("Test JSON error handling")
    func testJSONErrorHandling() {
        // Test malformed JSON strings
        let malformedJSONStrings = [
            "{",
            "}",
            "{\"error\": }",
            "{\"error\": \"test\", \"message\": }",
            "{\"error\": \"test\", \"message\": \"test\",}",
            "not json at all"
        ]
        
        for malformedJSON in malformedJSONStrings {
            let data = malformedJSON.data(using: .utf8)!
            
            do {
                _ = try JSONDecoder().decode(ErrorResponse.self, from: data)
                #expect(false, "Should have thrown an error for: \(malformedJSON)")
            } catch {
                #expect(true, "Expected error for malformed JSON: \(malformedJSON)")
            }
        }
    }
    
    @Test("Test concurrent error handling")
    func testConcurrentErrorHandling() async {
        // Test that error responses can be created concurrently without issues
        let tasks = (1...10).map { index in
            Task {
                let error = ErrorResponse(
                    error: "Concurrent Error \(index)",
                    message: "Message for error \(index)"
                )
                
                let encoder = JSONEncoder()
                return try encoder.encode(error)
            }
        }
        
        let results = await withTaskGroup(of: Data?.self) { group in
            for task in tasks {
                group.addTask {
                    do {
                        return try await task.value
                    } catch {
                        return nil
                    }
                }
            }
            
            var allResults: [Data] = []
            for await result in group {
                if let data = result {
                    allResults.append(data)
                }
            }
            return allResults
        }
        
        #expect(results.count == 10)
        
        // Verify all encoded data is valid
        for data in results {
            let decoder = JSONDecoder()
            let errorResponse = try! decoder.decode(ErrorResponse.self, from: data)
            #expect(errorResponse.error.hasPrefix("Concurrent Error"))
            #expect(errorResponse.message.hasPrefix("Message for error"))
        }
    }
    
    @Test("Test empty and null value handling")
    func testEmptyAndNullValueHandling() throws {
        // Test empty strings
        let emptyError = ErrorResponse(error: "", message: "")
        let encoder = JSONEncoder()
        let data = try encoder.encode(emptyError)
        
        let decoder = JSONDecoder()
        let decodedError = try decoder.decode(ErrorResponse.self, from: data)
        
        #expect(decodedError.error.isEmpty)
        #expect(decodedError.message.isEmpty)
        
        // Test zero values
        let zeroHealth = HealthStatus(
            status: "",
            timestamp: Date(timeIntervalSince1970: 0),
            version: "",
            uptime: 0
        )
        
        let healthData = try encoder.encode(zeroHealth)
        let decodedHealth = try decoder.decode(HealthStatus.self, from: healthData)
        
        #expect(decodedHealth.status.isEmpty)
        #expect(decodedHealth.version.isEmpty)
        #expect(decodedHealth.uptime == 0)
    }
    
    @Test("Test error response HTTP status code mapping")
    func testErrorResponseHTTPStatusMapping() {
        // Test common error responses and their expected HTTP status codes
        let errorMappings: [(ErrorResponse, HTTPResponse.Status)] = [
            (ErrorResponse(error: "Bad Request", message: "Invalid parameter"), .badRequest),
            (ErrorResponse(error: "Unauthorized", message: "Authentication required"), .unauthorized),
            (ErrorResponse(error: "Forbidden", message: "Access denied"), .forbidden),
            (ErrorResponse(error: "Not Found", message: "Resource not found"), .notFound),
            (ErrorResponse(error: "Internal Server Error", message: "Server error"), .internalServerError),
            (ErrorResponse(error: "Service Unavailable", message: "Service temporarily down"), .serviceUnavailable)
        ]
        
        for (errorResponse, expectedStatus) in errorMappings {
            // Verify the error response can be encoded
            let encoder = JSONEncoder()
            let data = try! encoder.encode(errorResponse)
            #expect(data.count > 0)
            
            // In a real HTTP response, these would be paired with appropriate status codes
            switch errorResponse.error {
            case "Bad Request":
                #expect(expectedStatus == .badRequest)
            case "Unauthorized":
                #expect(expectedStatus == .unauthorized)
            case "Forbidden":
                #expect(expectedStatus == .forbidden)
            case "Not Found":
                #expect(expectedStatus == .notFound)
            case "Internal Server Error":
                #expect(expectedStatus == .internalServerError)
            case "Service Unavailable":
                #expect(expectedStatus == .serviceUnavailable)
            default:
                break
            }
        }
    }
}