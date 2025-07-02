import Foundation
import Testing
import SWCompression
@testable import F1DashServer
@testable import F1DashModels

/// Test suite for compression/decompression functionality in DataProcessingActor
struct CompressionTests {
    
    @Test("Test zlib compression and decompression")
    func testZlibCompressionDecompression() async throws {
        let originalJson = """
        {
            "Lines": {
                "1": {
                    "Position": "1",
                    "racing_number": "1",
                    "lap_time": "1:15.911"
                },
                "27": {
                    "Position": "2",
                    "racing_number": "27",
                    "lap_time": "1:17.026"
                }
            }
        }
        """
        
        let originalData = originalJson.data(using: .utf8)!
        
        // Compress the data
        let compressedData = try ZlibArchive.archive(data: originalData)
        let base64Compressed = compressedData.base64EncodedString()
        
        // Decompress the data (simulating what DataProcessingActor does)
        let decodedData = Data(base64Encoded: base64Compressed)!
        let decompressedData = try ZlibArchive.unarchive(archive: decodedData)
        
        // Parse back to JSON
        let jsonObject = try JSONSerialization.jsonObject(with: decompressedData) as! [String: Any]
        
        #expect(jsonObject.keys.contains("Lines"))
        
        if let lines = jsonObject["Lines"] as? [String: Any] {
            #expect(lines.keys.contains("1"))
            #expect(lines.keys.contains("27"))
            
            if let driver1 = lines["1"] as? [String: Any] {
                #expect(driver1["Position"] as? String == "1")
                #expect(driver1["racing_number"] as? String == "1")
            }
        }
    }
    
    @Test("Test compressed message processing through DataProcessingActor")
    func testCompressedMessageProcessing() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        // Create realistic F1 timing data
        let timingDataJson = """
        {
            "Lines": {
                "1": {
                    "Position": "1",
                    "racing_number": "1",
                    "broadcast_name": "M VERSTAPPEN",
                    "best_lap_time": {
                        "value": "1:15.911",
                        "lap": 9
                    }
                },
                "27": {
                    "Position": "2",
                    "racing_number": "27",
                    "broadcast_name": "N HULKENBERG",
                    "best_lap_time": {
                        "value": "1:17.026",
                        "lap": 9
                    }
                }
            }
        }
        """
        
        // Compress the timing data
        let jsonData = timingDataJson.data(using: .utf8)!
        let compressedData = try ZlibArchive.archive(data: jsonData)
        let base64Compressed = compressedData.base64EncodedString()
        
        // Create the message structure that would come from SignalR
        let messageData = """
        {
            "M": [{
                "A": ["TimingData.z", "\(base64Compressed)"]
            }]
        }
        """.data(using: .utf8)!
        
        let rawMessage = RawMessage(
            topic: "updates",
            data: messageData,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        #expect(receivedUpdates.count == 1)
        let update = receivedUpdates.first!
        #expect(update.updates.keys.contains("timingData"))
        
        // Verify the decompressed and transformed data
        if let timingData = update.updates["timingData"] as? [String: Any],
           let lines = timingData["Lines"] as? [String: Any] {
            
            #expect(lines.keys.contains("1"))
            #expect(lines.keys.contains("27"))
            
            if let driver1 = lines["1"] as? [String: Any] {
                #expect(driver1["racingNumber"] as? String == "1")
                #expect(driver1["broadcastName"] as? String == "M VERSTAPPEN")
                
                if let bestLapTime = driver1["bestLapTime"] as? [String: Any] {
                    #expect(bestLapTime["value"] as? String == "1:15.911")
                    #expect(bestLapTime["lap"] as? Int == 9)
                }
            }
        }
    }
    
    @Test("Test compressed initial state message")
    func testCompressedInitialStateMessage() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        // Create weather data
        let weatherDataJson = """
        {
            "air_temp": "16.4",
            "humidity": "87.0",
            "pressure": "932.7",
            "track_temp": "21.0",
            "wind_direction": "263",
            "wind_speed": "1.7"
        }
        """
        
        let jsonData = weatherDataJson.data(using: .utf8)!
        let compressedData = try ZlibArchive.archive(data: jsonData)
        let base64Compressed = compressedData.base64EncodedString()
        
        let messageData = """
        {
            "R": "\(base64Compressed)"
        }
        """.data(using: .utf8)!
        
        let rawMessage = RawMessage(
            topic: "WeatherData.z",
            data: messageData,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        #expect(receivedUpdates.count == 1)
        let update = receivedUpdates.first!
        #expect(update.updates.keys.contains("weatherData"))
        
        if let weatherData = update.updates["weatherData"] as? [String: Any] {
            #expect(weatherData["airTemp"] as? String == "16.4")
            #expect(weatherData["humidity"] as? String == "87.0")
            #expect(weatherData["trackTemp"] as? String == "21.0")
            #expect(weatherData["windDirection"] as? String == "263")
            #expect(weatherData["windSpeed"] as? String == "1.7")
        }
    }
    
    @Test("Test invalid base64 compressed data")
    func testInvalidBase64CompressedData() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        let messageData = """
        {
            "M": [{
                "A": ["TimingData.z", "invalid-base64-data!@#$"]
            }]
        }
        """.data(using: .utf8)!
        
        let rawMessage = RawMessage(
            topic: "updates",
            data: messageData,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        // Should not crash, but also should not produce updates
        #expect(receivedUpdates.isEmpty)
    }
    
    @Test("Test corrupted compressed data")
    func testCorruptedCompressedData() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        // Create valid base64 but corrupted compressed data
        let corruptedData = Data([0x78, 0x9C, 0xFF, 0xFF, 0xFF, 0xFF]) // Invalid zlib data
        let base64Corrupted = corruptedData.base64EncodedString()
        
        let messageData = """
        {
            "R": "\(base64Corrupted)"
        }
        """.data(using: .utf8)!
        
        let rawMessage = RawMessage(
            topic: "TimingData.z",
            data: messageData,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        // Should not crash, but also should not produce updates
        #expect(receivedUpdates.isEmpty)
    }
    
    @Test("Test mixed compressed and uncompressed data in single message")
    func testMixedCompressedUncompressedData() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        // Create compressed timing data
        let timingDataJson = """
        {
            "Lines": {
                "1": {"Position": "1", "racing_number": "1"}
            }
        }
        """
        let jsonData = timingDataJson.data(using: .utf8)!
        let compressedData = try ZlibArchive.archive(data: jsonData)
        let base64Compressed = compressedData.base64EncodedString()
        
        // Create message with both compressed and uncompressed data
        let messageData = """
        {
            "M": [
                {
                    "A": ["TimingData.z", "\(base64Compressed)"]
                },
                {
                    "A": ["TrackStatus", {
                        "status": "1",
                        "message": "AllClear"
                    }]
                }
            ]
        }
        """.data(using: .utf8)!
        
        let rawMessage = RawMessage(
            topic: "updates",
            data: messageData,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        #expect(receivedUpdates.count == 1)
        let update = receivedUpdates.first!
        
        // Both compressed and uncompressed data should be processed
        #expect(update.updates.keys.contains("timingData"))
        #expect(update.updates.keys.contains("trackStatus"))
        
        if let trackStatus = update.updates["trackStatus"] as? [String: Any] {
            #expect(trackStatus["status"] as? String == "1")
            #expect(trackStatus["message"] as? String == "AllClear")
        }
        
        if let timingData = update.updates["timingData"] as? [String: Any],
           let lines = timingData["Lines"] as? [String: Any],
           let driver1 = lines["1"] as? [String: Any] {
            #expect(driver1["racingNumber"] as? String == "1")
        }
    }
    
    @Test("Test large compressed payload")
    func testLargeCompressedPayload() async throws {
        let actor = DataProcessingActor()
        var receivedUpdates: [StateUpdate] = []
        
        await actor.setStateUpdateHandler { update in
            receivedUpdates.append(update)
        }
        
        // Create a larger, more realistic F1 data payload
        var largePayload: [String: Any] = [:]
        
        // Add multiple driver entries
        var lines: [String: Any] = [:]
        for i in 1...20 {
            lines["\(i)"] = [
                "Position": "\(i)",
                "racing_number": "\(i)",
                "broadcast_name": "DRIVER \(i)",
                "lap_time": "1:\(15 + i).123",
                "sectors": [
                    "0": ["value": "\(18 + i % 5).123"],
                    "1": ["value": "\(33 + i % 3).456"],
                    "2": ["value": "\(23 + i % 2).789"]
                ]
            ]
        }
        largePayload["Lines"] = lines
        
        let jsonData = try JSONSerialization.data(withJSONObject: largePayload)
        let compressedData = try ZlibArchive.archive(data: jsonData)
        let base64Compressed = compressedData.base64EncodedString()
        
        let messageData = """
        {
            "R": "\(base64Compressed)"
        }
        """.data(using: .utf8)!
        
        let rawMessage = RawMessage(
            topic: "TimingData.z",
            data: messageData,
            timestamp: Date()
        )
        
        await actor.processMessage(rawMessage)
        
        #expect(receivedUpdates.count == 1)
        let update = receivedUpdates.first!
        #expect(update.updates.keys.contains("timingData"))
        
        if let timingData = update.updates["timingData"] as? [String: Any],
           let processedLines = timingData["Lines"] as? [String: Any] {
            #expect(processedLines.count == 20)
            
            // Verify key transformation worked on large payload
            if let driver1 = processedLines["1"] as? [String: Any] {
                #expect(driver1["racingNumber"] as? String == "1")
                #expect(driver1["broadcastName"] as? String == "DRIVER 1")
            }
        }
    }
}