import Foundation
import Testing
import SWCompression
@testable import F1DashServer
@testable import F1DashModels

/// Test suite for DataProcessingActor message processing capabilities
struct DataProcessingActorTests {
    
    @Test("Test initial message parsing with R field")
    func testInitialMessageParsing() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        let testData = """
        {
            "R": {
                "TimingData": {
                    "Lines": {
                        "1": {
                            "Position": "1",
                            "RacingNumber": "1"
                        }
                    }
                }
            }
        }
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "initial",
            data: testData,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        #expect(receivedUpdates.count == 1)
        #expect(receivedUpdates.first?.updates.keys.contains("timingData") == true)
    }
    
    @Test("Test update message parsing with M field")
    func testUpdateMessageParsing() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        let testData = """
        {
            "M": [{
                "A": ["TimingData", {
                    "Lines": {
                        "1": {
                            "Position": "1",
                            "RacingNumber": "1"
                        }
                    }
                }]
            }]
        }
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "updates",
            data: testData,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        #expect(receivedUpdates.count == 1)
        #expect(receivedUpdates.first?.updates.keys.contains("timingData") == true)
    }
    
    @Test("Test compressed data parsing with .z suffix")
    func testCompressedDataParsing() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        // Create test JSON data
        let testJson = """
        {
            "Lines": {
                "1": {
                    "Position": "1",
                    "racing_number": "1"
                }
            }
        }
        """
        
        // Compress the JSON data
        let jsonData = testJson.data(using: .utf8)!
        let compressedData = try ZlibArchive.archive(data: jsonData)
        let base64Compressed = compressedData.base64EncodedString()
        
        let testData = """
        {
            "R": "\(base64Compressed)"
        }
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "TimingData.z",
            data: testData,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        #expect(receivedUpdates.count == 1)
        #expect(receivedUpdates.first?.updates.keys.contains("timingData") == true)
        
        if let timingData = receivedUpdates.first?.updates["timingData"] as? [String: Any],
           let lines = timingData["Lines"] as? [String: Any],
           let driver1 = lines["1"] as? [String: Any] {
            #expect(driver1["racingNumber"] as? String == "1")
        }
    }
    
    @Test("Test multiple update messages processing")
    func testMultipleUpdateMessages() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        let testData = """
        {
            "M": [
                {
                    "A": ["TimingData", {
                        "Lines": {
                            "1": {"Position": "1", "RacingNumber": "1"}
                        }
                    }]
                },
                {
                    "A": ["WeatherData", {
                        "AirTemp": "16.4",
                        "TrackTemp": "21.0"
                    }]
                }
            ]
        }
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "updates",
            data: testData,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        #expect(receivedUpdates.count == 1)
        let update = receivedUpdates.first!
        #expect(update.updates.keys.contains("timingData") == true)
        #expect(update.updates.keys.contains("weatherData") == true)
    }
    
    @Test("Test full state simulation message")
    func testFullStateSimulationMessage() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        let testData = """
        {
            "R": {
                "TimingData": {
                    "Lines": {
                        "1": {"Position": "1", "racing_number": "1"}
                    }
                },
                "WeatherData": {
                    "air_temp": "16.4",
                    "track_temp": "21.0"
                },
                "DriverList.z": "H4sIAAAAAAAAA6tWyk5NzCvJzE21UoIBnaLSxKJUK2t1HaViI31DI6VShaJcJSsrKz19czNzKytdJVCrHlQfE1dfI6gKJCIkJKSvhI8cM7G+CkCmqVKeEgyAFJ4BAAAA"
            }
        }
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "simulation",
            data: testData,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        #expect(receivedUpdates.count == 1)
        let update = receivedUpdates.first!
        #expect(update.updates.keys.contains("timingData") == true)
        #expect(update.updates.keys.contains("weatherData") == true)
        #expect(update.updates.keys.contains("driverList") == true)
        
        // Verify camelCase transformation
        if let timingData = update.updates["timingData"] as? [String: Any],
           let lines = timingData["Lines"] as? [String: Any],
           let driver1 = lines["1"] as? [String: Any] {
            #expect(driver1["racingNumber"] as? String == "1")
        }
        
        if let weatherData = update.updates["weatherData"] as? [String: Any] {
            #expect(weatherData["airTemp"] as? String == "16.4")
            #expect(weatherData["trackTemp"] as? String == "21.0")
        }
    }
    
    @Test("Test invalid JSON handling")
    func testInvalidJsonHandling() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        let invalidData = "invalid json data".data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "test",
            data: invalidData,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        // Should not crash and should not produce any updates
        #expect(receivedUpdates.isEmpty)
    }
    
    @Test("Test empty message handling")
    func testEmptyMessageHandling() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        let emptyData = Data()
        
        let rawMessage = RawMessage(
            topic: "test",
            data: emptyData,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        // Should not crash and should not produce any updates
        #expect(receivedUpdates.isEmpty)
    }
    
    @Test("Test message with filtered metadata keys")
    func testMessageWithFilteredMetadata() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        let testData = """
        {
            "R": {
                "TimingData": {
                    "Lines": {
                        "1": {"Position": "1", "RacingNumber": "1"}
                    },
                    "_kf": true
                },
                "_kf": true
            }
        }
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "initial",
            data: testData,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        #expect(receivedUpdates.count == 1)
        let update = receivedUpdates.first!
        
        // _kf metadata should be filtered out
        #expect(update.updates.keys.contains("_kf") == false)
        
        if let timingData = update.updates["timingData"] as? [String: Any] {
            #expect(timingData.keys.contains("_kf") == false)
        }
    }
}