import Foundation
@testable import F1DashServer
@testable import F1DashModels

// Simple test runner to verify the implementation

func testSessionStateCache() async {
    print("Testing SessionStateCache...")
    
    let cache = SessionStateCache()
    
    // Test 1: Initial state setup
    print("\n1. Testing initial state setup...")
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
    
    await cache.setInitialState(initialState)
    let state1 = await cache.getCurrentState()
    
    if state1.driverList?.count == 1 && state1.driverList?["1"]?.tla == "VER" {
        print("✅ Initial state setup: PASSED")
    } else {
        print("❌ Initial state setup: FAILED")
    }
    
    // Test 2: State update merging
    print("\n2. Testing state update merging...")
    let update = StateUpdate(
        updates: [
            "driverList": [
                "44": [
                    "racingNumber": "44",
                    "broadcastName": "L HAMILTON",
                    "fullName": "Lewis HAMILTON",
                    "tla": "HAM",
                    "teamName": "Mercedes",
                    "teamColour": "6CD3BF"
                ]
            ]
        ]
    )
    
    await cache.applyUpdate(update)
    let state2 = await cache.getCurrentState()
    
    if state2.driverList?.count == 2 &&
       state2.driverList?["1"]?.tla == "VER" &&
       state2.driverList?["44"]?.tla == "HAM" {
        print("✅ State update merging: PASSED")
    } else {
        print("❌ State update merging: FAILED")
        print("  Driver count: \(state2.driverList?.count ?? 0)")
    }
    
    // Test 3: Empty state handling
    print("\n3. Testing empty state handling...")
    let emptyCache = SessionStateCache()
    let emptyState = await emptyCache.getCurrentState()
    
    if emptyState.driverList == nil && emptyState.timingData == nil {
        print("✅ Empty state handling: PASSED")
    } else {
        print("❌ Empty state handling: FAILED")
    }
    
    print("\n✅ All tests completed!")
}

// Run the test
Task {
    await testSessionStateCache()
    exit(0)
}

// Keep the program running
RunLoop.main.run()