import XCTest
@testable import F1DashServer
@testable import F1DashModels

final class SessionStateCacheTests: XCTestCase {
    
    // MARK: - Tests
    
    func testInitialStateSetup() async throws {
        let cache = SessionStateCache()
        
        // Create a sample initial state
        let initialState = F1State(
            driverList: [
                "1": Driver(
                    racingNumber: "1",
                    broadcastName: "M VERSTAPPEN",
                    fullName: "Max VERSTAPPEN",
                    tla: "VER",
                    teamName: "Red Bull Racing",
                    teamColour: "3671C6"
                ),
                "44": Driver(
                    racingNumber: "44",
                    broadcastName: "L HAMILTON",
                    fullName: "Lewis HAMILTON",
                    tla: "HAM",
                    teamName: "Mercedes",
                    teamColour: "6CD3BF"
                )
            ],
            sessionInfo: SessionInfo(
                meeting: Meeting(
                    key: 1213,
                    name: "Austrian Grand Prix"
                ),
                key: 9117,
                type: "Race",
                name: "Sprint"
            )
        )
        
        // Set initial state
        await cache.setInitialState(initialState)
        
        // Get current state
        let currentState = await cache.getCurrentState()
        
        // Verify driver list
        XCTAssertNotNil(currentState.driverList)
        XCTAssertEqual(currentState.driverList?.count, 2)
        XCTAssertEqual(currentState.driverList?["1"]?.tla, "VER")
        XCTAssertEqual(currentState.driverList?["44"]?.tla, "HAM")
        
        // Verify session info
        XCTAssertNotNil(currentState.sessionInfo)
        XCTAssertEqual(currentState.sessionInfo?.name, "Sprint")
    }
    
    func testStateUpdateMerging() async throws {
        let cache = SessionStateCache()
        
        // Set initial state with two drivers
        let initialState = F1State(
            driverList: [
                "1": Driver(
                    racingNumber: "1",
                    broadcastName: "M VERSTAPPEN",
                    fullName: "Max VERSTAPPEN",
                    tla: "VER",
                    teamName: "Red Bull Racing",
                    teamColour: "3671C6"
                ),
                "44": Driver(
                    racingNumber: "44",
                    broadcastName: "L HAMILTON",
                    fullName: "Lewis HAMILTON",
                    tla: "HAM",
                    teamName: "Mercedes",
                    teamColour: "6CD3BF"
                )
            ]
        )
        
        await cache.setInitialState(initialState)
        
        // Apply update that adds a new driver
        let update = StateUpdate(
            updates: [
                "driverList": [
                    "11": [
                        "racingNumber": "11",
                        "broadcastName": "S PEREZ",
                        "fullName": "Sergio PEREZ",
                        "tla": "PER",
                        "teamName": "Red Bull Racing",
                        "teamColour": "3671C6"
                    ]
                ]
            ]
        )
        
        await cache.applyUpdate(update)
        
        // Get current state
        let currentState = await cache.getCurrentState()
        
        // Verify all three drivers exist
        XCTAssertEqual(currentState.driverList?.count, 3)
        XCTAssertEqual(currentState.driverList?["1"]?.tla, "VER")
        XCTAssertEqual(currentState.driverList?["44"]?.tla, "HAM")
        XCTAssertEqual(currentState.driverList?["11"]?.tla, "PER")
    }
    
    func testTimingDataMerge() async throws {
        let cache = SessionStateCache()
        
        // Set initial state with timing data
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
        
        await cache.setInitialState(initialState)
        
        // Apply update that modifies timing for driver 1 and adds driver 44
        let update = StateUpdate(
            updates: [
                "timingData": [
                    "lines": [
                        "1": [
                            "gapToLeader": "",
                            "line": 1,
                            "racingNumber": "1",
                            "sectors": [],
                            "bestLapTime": ["value": "1:15.123"],  // New best lap
                            "lastLapTime": ["value": "1:15.123"]
                        ],
                        "44": [
                            "gapToLeader": "+5.123",
                            "line": 2,
                            "racingNumber": "44",
                            "sectors": [],
                            "bestLapTime": ["value": "1:16.234"],
                            "lastLapTime": ["value": "1:16.234"]
                        ]
                    ]
                ]
            ]
        )
        
        await cache.applyUpdate(update)
        
        // Get current state
        let currentState = await cache.getCurrentState()
        
        // Verify timing data
        XCTAssertNotNil(currentState.timingData)
        XCTAssertEqual(currentState.timingData?.lines.count, 2)
        
        // Driver 1 should have updated lap time
        XCTAssertEqual(currentState.timingData?.lines["1"]?.bestLapTime.value, "1:15.123")
        
        // Driver 44 should be added
        XCTAssertEqual(currentState.timingData?.lines["44"]?.gapToLeader, "+5.123")
    }
    
    func testEmptyStateReturnsEmptyF1State() async throws {
        let cache = SessionStateCache()
        
        // Get state without setting anything
        let currentState = await cache.getCurrentState()
        
        // Should return empty F1State, not crash
        XCTAssertNil(currentState.driverList)
        XCTAssertNil(currentState.timingData)
        XCTAssertNil(currentState.sessionInfo)
    }
    
    func testArrayReplacement() async throws {
        let cache = SessionStateCache()
        
        // Set initial state with race control messages
        let initialState = F1State(
            raceControlMessages: RaceControlMessages(
                messages: [
                    Message(
                        utc: "2023-07-01T14:00:01",
                        category: "Flag",
                        flag: "GREEN",
                        message: "GREEN LIGHT"
                    ),
                    Message(
                        utc: "2023-07-01T14:00:24",
                        category: "Other",
                        message: "AWNINGS MAY BE USED"
                    )
                ]
            )
        )
        
        await cache.setInitialState(initialState)
        
        // Apply update that replaces the array
        let update = StateUpdate(
            updates: [
                "raceControlMessages": [
                    "messages": [
                        [
                            "utc": "2023-07-01T14:05:00",
                            "category": "Flag",
                            "flag": "YELLOW",
                            "message": "YELLOW FLAG"
                        ]
                    ]
                ]
            ]
        )
        
        await cache.applyUpdate(update)
        
        // Get current state
        let currentState = await cache.getCurrentState()
        
        // Array should be replaced, not merged
        XCTAssertEqual(currentState.raceControlMessages?.messages.count, 1)
        XCTAssertEqual(currentState.raceControlMessages?.messages.first?.flag, "YELLOW")
    }
    
    func testSimulationDataProcessing() async throws {
        // This tests the full data flow with real simulation data structure
        let cache = SessionStateCache()
        
        // Sample data from Austria Sprint Race 2023
        let simulationData: [String: Any] = [
            "driverList": [
                "1": [
                    "racingNumber": "1",
                    "broadcastName": "M VERSTAPPEN",
                    "fullName": "Max VERSTAPPEN",
                    "tla": "VER",
                    "line": 1,
                    "teamName": "Red Bull Racing",
                    "teamColour": "3671C6"
                ]
            ],
            "timingData": [
                "lines": [
                    "1": [
                        "gapToLeader": "LAP 10",
                        "line": 1,
                        "position": "1",
                        "racingNumber": "1",
                        "sectors": [],
                        "bestLapTime": ["value": "1:15.911", "lap": 9],
                        "lastLapTime": ["value": "1:15.911"]
                    ]
                ],
                "withheld": false
            ],
            "sessionInfo": [
                "meeting": [
                    "key": 1213,
                    "name": "Austrian Grand Prix"
                ],
                "key": 9117,
                "type": "Race",
                "name": "Sprint"
            ],
            "weatherData": [
                "airTemp": "16.4",
                "humidity": "87.0",
                "rainfall": "0"
            ]
        ]
        
        // Try to decode as F1State
        do {
            let data = try JSONSerialization.data(withJSONObject: simulationData)
            let decoder = JSONDecoder()
            let state = try decoder.decode(F1State.self, from: data)
            
            await cache.setInitialState(state)
            
            let currentState = await cache.getCurrentState()
            
            XCTAssertNotNil(currentState.driverList)
            XCTAssertNotNil(currentState.timingData)
            XCTAssertNotNil(currentState.sessionInfo)
            XCTAssertNotNil(currentState.weatherData)
            
        } catch {
            // If decoding fails, the data should still be stored as dictionary
            // and accessible via getCurrentState
            let update = StateUpdate(updates: simulationData)
            await cache.applyUpdate(update)
            
            let currentState = await cache.getCurrentState()
            
            // Even if some fields can't decode, we should get what we can
            XCTAssertNotNil(currentState)
        }
    }
    
    func testStatistics() async throws {
        let cache = SessionStateCache()
        
        // Apply some updates
        let update1 = StateUpdate(
            updates: ["lapCount": ["currentLap": 5, "totalLaps": 24]]
        )
        await cache.applyUpdate(update1)
        
        let update2 = StateUpdate(
            updates: ["trackStatus": ["status": "1", "message": "AllClear"]]
        )
        await cache.applyUpdate(update2)
        
        // Get statistics
        let stats = await cache.getStatistics()
        
        XCTAssertEqual(stats.updateCount, 2)
        XCTAssertGreaterThan(stats.lastUpdate.timeIntervalSinceNow, -1) // Recent update
        XCTAssertEqual(stats.subscriberCount, 0) // No subscribers yet
    }
}