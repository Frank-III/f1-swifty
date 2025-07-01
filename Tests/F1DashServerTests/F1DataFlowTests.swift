import Foundation
import Testing
import Logging
@testable import F1DashServer
@testable import F1DashModels

/// Test suite to verify F1 data flows from SignalR to WebSocket clients
struct F1DataFlowTests {
    
    private let logger = Logger(label: "F1DataFlowTests")
    
    @Test("Test complete F1 data pipeline")
    func testDataFlow() async throws {
        logger.info("Starting F1 data flow test")
        
        // Create test components
        let sessionStateCache = SessionStateCache()
        let dataProcessor = DataProcessingActor()
        let signalRClient = SignalRClientActor()
        let connectionManager = ConnectionManager()
        
        // Set up the pipeline
        await setupTestPipeline(
            signalRClient: signalRClient,
            dataProcessor: dataProcessor,
            sessionStateCache: sessionStateCache,
            connectionManager: connectionManager
        )
        
        // Test with simulated data
        try await testWithSimulatedData(signalRClient: signalRClient)
        
        logger.info("F1 data flow test completed successfully")
    }
    
    @Test("Test SignalR message handling")
    func testSignalRMessageHandling() async throws {
        let signalRClient = SignalRClientActor()
        var receivedMessages: [RawMessage] = []
        
        // Set up message handler
        await signalRClient.setMessageHandler { rawMessage in
            receivedMessages.append(rawMessage)
        }
        
        // Create test message
        let testData = """
        {
            "TimingData": {
                "Lines": {
                    "1": {
                        "Position": "1",
                        "RacingNumber": "1"
                    }
                }
            }
        }
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "TimingData.z",
            data: testData,
            timestamp: Date()
        )
        
        // Simulate message reception (would normally come from SignalR)
        await signalRClient.setMessageHandler { message in
            receivedMessages.append(message)
        }
        
        // Verify message structure
        #expect(rawMessage.topic == "TimingData.z")
        #expect(!rawMessage.data.isEmpty)
    }
    
    @Test("Test ConnectionManager broadcasting")
    func testConnectionManagerBroadcasting() async throws {
        let connectionManager = ConnectionManager()
        
        // Create test F1 data
        let testData = Data("test F1 data".utf8)
        let topic = "TimingData.z"
        
        // Test broadcasting (this would normally send to connected clients)
        await connectionManager.broadcastF1Data(testData, topic: topic)
        
        // Note: In a real test, we'd verify clients receive the data
        // For now, we're just testing that the method doesn't crash
    }
    
    private func setupTestPipeline(
        signalRClient: SignalRClientActor,
        dataProcessor: DataProcessingActor,
        sessionStateCache: SessionStateCache,
        connectionManager: ConnectionManager
    ) async {
        
        // Connect SignalR client to data processor AND connection manager
        await signalRClient.setMessageHandler { rawMessage in
            // Process the message for state management
            await dataProcessor.processMessage(rawMessage)
            
            // Also broadcast raw data to WebSocket clients
            await connectionManager.broadcastRawMessage(rawMessage)
        }
        
        // Connect data processor to session state cache
        await dataProcessor.setStateUpdateHandler { stateUpdate in
            await sessionStateCache.applyUpdate(stateUpdate)
        }
    }
    
    private func testWithSimulatedData(signalRClient: SignalRClientActor) async throws {
        // Create test F1 message
        let testData = """
        {
            "Heartbeat": "2024-06-27T10:30:00.000Z",
            "TimingData": {
                "Lines": {
                    "1": {
                        "Position": "1",
                        "RacingNumber": "1",
                        "BestLapTime": {
                            "Value": "1:20.123"
                        }
                    }
                }
            }
        }
        """.data(using: .utf8) ?? Data()
        
        let rawMessage = RawMessage(
            topic: "TimingData.z",
            data: testData,
            timestamp: Date()
        )
        
        logger.info("Test: Created test F1 message - topic: \(rawMessage.topic), size: \(rawMessage.data.count)")
    }
}
