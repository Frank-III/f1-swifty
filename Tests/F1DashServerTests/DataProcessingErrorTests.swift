import Foundation
import Testing
import SWCompression
@testable import F1DashServer
@testable import F1DashModels

/// Test suite for error handling scenarios in DataProcessingActor
struct DataProcessingErrorTests {
    
    @Test("Test ProcessingError cases")
    func testProcessingErrorCases() {
        let invalidBase64Error = DataProcessingActor.ProcessingError.invalidBase64
        let decompressionError = DataProcessingActor.ProcessingError.decompressionFailed
        let invalidJsonError = DataProcessingActor.ProcessingError.invalidJSON
        let missingDataError = DataProcessingActor.ProcessingError.missingData
        
        #expect(invalidBase64Error.errorDescription == "Invalid base64 encoding")
        #expect(decompressionError.errorDescription == "Failed to decompress data")
        #expect(invalidJsonError.errorDescription == "Invalid JSON format")
        #expect(missingDataError.errorDescription == "Missing required data")
    }
    
    @Test("Test malformed JSON message")
    func testMalformedJsonMessage() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        let malformedJson = """
        {
            "R": {
                "TimingData": {
                    "Lines": {
                        "1": {
                            "Position": "1",
                            "RacingNumber": "1"
                            // Missing closing brace
                        }
                    }
                }
            // Missing closing braces
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "test",
            data: malformedJson,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        // Should handle the error gracefully without crashing
        #expect(receivedUpdates.isEmpty)
    }
    
    @Test("Test message with missing required fields")
    func testMessageWithMissingRequiredFields() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        // Message without R or M fields
        let incompleteMessage = """
        {
            "C": "connection-info",
            "S": 1
        }
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "test",
            data: incompleteMessage,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        // Should handle gracefully and not produce updates
        #expect(receivedUpdates.isEmpty)
    }
    
    @Test("Test update message with malformed A field")
    func testUpdateMessageWithMalformedAField() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        // M field with A field that doesn't have the expected structure
        let malformedUpdate = """
        {
            "M": [{
                "A": ["OnlyOneTopic"]
            }]
        }
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "updates",
            data: malformedUpdate,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        // Should handle gracefully
        #expect(receivedUpdates.isEmpty)
    }
    
    @Test("Test update message with non-string topic in A field")
    func testUpdateMessageWithNonStringTopicInAField() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        let invalidTopicUpdate = """
        {
            "M": [{
                "A": [123, {"data": "value"}]
            }]
        }
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "updates",
            data: invalidTopicUpdate,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        // Should handle gracefully
        #expect(receivedUpdates.isEmpty)
    }
    
    @Test("Test compressed message with invalid base64")
    func testCompressedMessageWithInvalidBase64() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        let invalidBase64Message = """
        {
            "M": [{
                "A": ["TimingData.z", "invalid base64 characters !@#$%^&*()"]
            }]
        }
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "updates",
            data: invalidBase64Message,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        // Should handle the base64 decode error gracefully
        #expect(receivedUpdates.isEmpty)
    }
    
    @Test("Test compressed message with valid base64 but invalid zlib data")
    func testCompressedMessageWithInvalidZlibData() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        // Create valid base64 but with content that isn't valid zlib compressed data
        let invalidZlibData = "This is not compressed data".data(using: .utf8)!
        let validBase64InvalidZlib = invalidZlibData.base64EncodedString()
        
        let invalidZlibMessage = """
        {
            "R": "\(validBase64InvalidZlib)"
        }
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "TimingData.z",
            data: invalidZlibMessage,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        // Should handle the decompression error gracefully
        #expect(receivedUpdates.isEmpty)
    }
    
    @Test("Test compressed message with valid zlib but invalid JSON")
    func testCompressedMessageWithInvalidJson() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        // Create compressed data that contains invalid JSON
        let invalidJsonText = "{ invalid json structure"
        let invalidJsonData = invalidJsonText.data(using: .utf8)!
        let compressedInvalidJson = try ZlibArchive.archive(data: invalidJsonData)
        let base64CompressedInvalidJson = compressedInvalidJson.base64EncodedString()
        
        let invalidJsonMessage = """
        {
            "M": [{
                "A": ["TimingData.z", "\(base64CompressedInvalidJson)"]
            }]
        }
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "updates",
            data: invalidJsonMessage,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        // Should handle the JSON parsing error gracefully
        #expect(receivedUpdates.isEmpty)
    }
    
    @Test("Test initial message with non-dictionary R field")
    func testInitialMessageWithNonDictionaryRField() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        let nonDictionaryRField = """
        {
            "R": "this should be a dictionary"
        }
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "TimingData",
            data: nonDictionaryRField,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        // Should handle gracefully when R field is not a dictionary
        #expect(receivedUpdates.isEmpty)
    }
    
    @Test("Test update message with non-array M field")
    func testUpdateMessageWithNonArrayMField() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        let nonArrayMField = """
        {
            "M": "this should be an array"
        }
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "updates",
            data: nonArrayMField,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        // Should handle gracefully when M field is not an array
        #expect(receivedUpdates.isEmpty)
    }
    
    @Test("Test mixed valid and invalid updates in same message")
    func testMixedValidInvalidUpdatesInSameMessage() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        // Create a message with both valid and invalid compressed data
        let validJson = """{"Lines": {"1": {"Position": "1"}}}"""
        let validData = validJson.data(using: .utf8)!
        let compressedValid = try ZlibArchive.archive(data: validData)
        let validBase64 = compressedValid.base64EncodedString()
        
        let mixedMessage = """
        {
            "M": [
                {
                    "A": ["TimingData.z", "\(validBase64)"]
                },
                {
                    "A": ["InvalidData.z", "invalid_base64_data!@#"]
                },
                {
                    "A": ["WeatherData", {
                        "air_temp": "16.4",
                        "track_temp": "21.0"
                    }]
                }
            ]
        }
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "updates",
            data: mixedMessage,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        // Should process valid updates and skip invalid ones
        #expect(receivedUpdates.count == 1)
        let update = receivedUpdates.first!
        
        // Valid updates should be present
        #expect(update.updates.keys.contains("timingData"))
        #expect(update.updates.keys.contains("weatherData"))
        
        // Invalid update should be skipped
        #expect(update.updates.keys.contains("invalidData") == false)
    }
    
    @Test("Test nil state update handler")
    func testNilStateUpdateHandler() async throws {
        let actor = DataProcessingActor()
        // Don't set a state update handler
        
        let testData = """
        {
            "R": {
                "TimingData": {
                    "Lines": {
                        "1": {"Position": "1", "RacingNumber": "1"}
                    }
                }
            }
        }
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "test",
            data: testData,
            timestamp: Date()
        )
        
        // Should not crash even without a handler
        await actor.processMessage(rawMessage)
        
        // Test passes if no crash occurs
        #expect(true)
    }
    
    @Test("Test empty arrays and objects in message")
    func testEmptyArraysAndObjectsInMessage() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        let emptyStructuresMessage = """
        {
            "M": []
        }
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "updates",
            data: emptyStructuresMessage,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        // Should handle empty arrays gracefully
        #expect(receivedUpdates.isEmpty)
    }
}