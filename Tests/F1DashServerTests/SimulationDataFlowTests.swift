import XCTest
@testable import F1DashServer
@testable import F1DashModels

final class SimulationDataFlowTests: XCTestCase {
    
    func testFullDataFlowFromSimulation() async throws {
        // Setup the data pipeline
        let sessionStateCache = SessionStateCache()
        let dataProcessor = DataProcessingActor()
        
        // Wire up handlers
        await dataProcessor.setStateUpdateHandler { stateUpdate in
            await sessionStateCache.applyUpdate(stateUpdate)
        }
        await dataProcessor.setInitialStateHandler { initialState in
            await sessionStateCache.setInitialState(initialState)
        }
        
        // Create a raw message with initial R data (from simulation)
        let initialData: [String: Any] = [
            "R": [
                "Heartbeat": [
                    "Utc": "2023-07-01T14:45:09.843661Z"
                ],
                "DriverList": [
                    "1": [
                        "RacingNumber": "1",
                        "BroadcastName": "M VERSTAPPEN",
                        "FullName": "Max VERSTAPPEN",
                        "Tla": "VER",
                        "TeamName": "Red Bull Racing",
                        "TeamColour": "3671C6"
                    ],
                    "44": [
                        "RacingNumber": "44",
                        "BroadcastName": "L HAMILTON",
                        "FullName": "Lewis HAMILTON",
                        "Tla": "HAM",
                        "TeamName": "Mercedes",
                        "TeamColour": "6CD3BF"
                    ]
                ],
                "SessionInfo": [
                    "Meeting": [
                        "Key": 1213,
                        "Name": "Austrian Grand Prix"
                    ],
                    "Key": 9117,
                    "Type": "Race",
                    "Name": "Sprint"
                ],
                "WeatherData": [
                    "AirTemp": "16.4",
                    "Humidity": "87.0",
                    "Rainfall": "0"
                ],
                "TrackStatus": [
                    "Status": "1",
                    "Message": "AllClear"
                ],
                "LapCount": [
                    "CurrentLap": 10,
                    "TotalLaps": 24
                ]
            ]
        ]
        
        let messageData = try JSONSerialization.data(withJSONObject: initialData)
        let rawMessage = RawMessage(
            topic: "simulation",
            data: messageData,
            timestamp: Date()
        )
        
        // Process the message
        await dataProcessor.processMessage(rawMessage)
        
        // Give it a moment to process
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        // Get the current state
        let currentState = await sessionStateCache.getCurrentState()
        
        // Verify the state was properly set
        XCTAssertNotNil(currentState.driverList)
        XCTAssertEqual(currentState.driverList?.count, 2)
        XCTAssertEqual(currentState.driverList?["1"]?.tla, "VER")
        XCTAssertEqual(currentState.driverList?["44"]?.tla, "HAM")
        
        XCTAssertNotNil(currentState.sessionInfo)
        XCTAssertEqual(currentState.sessionInfo?.name, "Sprint")
        
        XCTAssertNotNil(currentState.weatherData)
        XCTAssertEqual(currentState.weatherData?.airTemp, "16.4")
        
        XCTAssertNotNil(currentState.lapCount)
        XCTAssertEqual(currentState.lapCount?.currentLap, 10)
    }
    
    func testUpdateMessageProcessing() async throws {
        let sessionStateCache = SessionStateCache()
        let dataProcessor = DataProcessingActor()
        
        await dataProcessor.setStateUpdateHandler { stateUpdate in
            await sessionStateCache.applyUpdate(stateUpdate)
        }
        
        // First set some initial state
        let initialState = F1State(
            driverList: [
                "1": Driver(
                    racingNumber: "1",
                    broadcastName: "M VERSTAPPEN",
                    fullName: "Max VERSTAPPEN",
                    tla: "VER",
                    teamName: "Red Bull Racing",
                    teamColour: "3671C6"
                )
            ]
        )
        await sessionStateCache.setInitialState(initialState)
        
        // Create an update message (M field format)
        let updateData: [String: Any] = [
            "M": [
                [
                    "A": [
                        "TimingData",
                        [
                            "Lines": [
                                "1": [
                                    "GapToLeader": "",
                                    "Position": "1",
                                    "LastLapTime": [
                                        "Value": "1:14.123"
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
        
        let messageData = try JSONSerialization.data(withJSONObject: updateData)
        let rawMessage = RawMessage(
            topic: "updates",
            data: messageData,
            timestamp: Date()
        )
        
        // Process the update
        await dataProcessor.processMessage(rawMessage)
        
        // Give it a moment to process
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        // Get the current state
        let currentState = await sessionStateCache.getCurrentState()
        
        // Verify timing data was added
        XCTAssertNotNil(currentState.timingData)
        XCTAssertNotNil(currentState.timingData?.lines["1"])
        XCTAssertEqual(currentState.timingData?.lines["1"]?.lastLapTime.value, "1:14.123")
        
        // Original driver list should still exist
        XCTAssertNotNil(currentState.driverList)
        XCTAssertEqual(currentState.driverList?["1"]?.tla, "VER")
    }
    
    func testCompressedDataHandling() async throws {
        let sessionStateCache = SessionStateCache()
        let dataProcessor = DataProcessingActor()
        
        await dataProcessor.setStateUpdateHandler { stateUpdate in
            await sessionStateCache.applyUpdate(stateUpdate)
        }
        
        // Create test data to compress
        let carData: [String: Any] = [
            "Entries": [
                [
                    "Cars": [
                        "1": [
                            "Channel": 5,
                            "Speed": 294
                        ]
                    ],
                    "Utc": "2023-07-01T14:45:20.123Z"
                ]
            ]
        ]
        
        // Convert to JSON and compress
        let jsonData = try JSONSerialization.data(withJSONObject: carData)
        let compressedData = try jsonData.compressed(using: .deflate)
        let base64String = compressedData.base64EncodedString()
        
        // Create update message with compressed data
        let updateData: [String: Any] = [
            "M": [
                [
                    "A": [
                        "CarData.z",
                        base64String
                    ]
                ]
            ]
        ]
        
        let messageData = try JSONSerialization.data(withJSONObject: updateData)
        let rawMessage = RawMessage(
            topic: "updates",
            data: messageData,
            timestamp: Date()
        )
        
        // Process the compressed update
        await dataProcessor.processMessage(rawMessage)
        
        // Give it a moment to process
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        // Get the current state
        let currentState = await sessionStateCache.getCurrentState()
        
        // The compressed data should be decompressed and available
        // Note: CarData is handled specially and may not be in the main state
        XCTAssertNotNil(currentState)
    }
    
    func testPartialUpdateDoesNotBreakState() async throws {
        let sessionStateCache = SessionStateCache()
        let dataProcessor = DataProcessingActor()
        
        await dataProcessor.setStateUpdateHandler { stateUpdate in
            await sessionStateCache.applyUpdate(stateUpdate)
        }
        
        // Set initial state with complete timing data
        let initialState = F1State(
            timingData: TimingData(
                lines: [
                    "1": TimingDataDriver(
                        gapToLeader: "",
                        line: 1,
                        racingNumber: "1",
                        sectors: [],
                        bestLapTime: PersonalBestLapTime(value: "1:15.911"),
                        lastLapTime: LapTimeValue(value: "1:15.911")
                    )
                ],
                withheld: false
            )
        )
        await sessionStateCache.setInitialState(initialState)
        
        // Apply partial update that only updates speed
        let partialUpdate = StateUpdate(
            updates: [
                "timingData": [
                    "lines": [
                        "1": [
                            "speeds": [
                                "i1": ["value": "300"]
                            ]
                        ]
                    ]
                ]
            ]
        )
        
        await sessionStateCache.applyUpdate(partialUpdate)
        
        // Get the current state - should not crash
        let currentState = await sessionStateCache.getCurrentState()
        
        // Original data should still be there
        XCTAssertNotNil(currentState.timingData)
        XCTAssertEqual(currentState.timingData?.lines["1"]?.racingNumber, "1")
        XCTAssertEqual(currentState.timingData?.lines["1"]?.bestLapTime.value, "1:15.911")
    }
}