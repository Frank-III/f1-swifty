//
//  OptimizedLiveSessionState.swift
//  F1-Dash
//
//  Optimized session state with caching and efficient updates
//

import SwiftUI
import Observation
import F1DashModels

@MainActor
@Observable
final class OptimizedLiveSessionState {
    // MARK: - State Storage
    
    private var dataState: [String: Any] = [:]
    private var lastRaceControlMessageCount: Int = 0
    
    // Force UI updates when state changes
    private var updateCounter: Int = 0
    
    // MARK: - Cache Storage
    
    private struct Cache {
        var sessionInfo: (value: SessionInfo?, version: Int)?
        var trackStatus: (value: TrackStatus?, version: Int)?
        var driverList: (value: [String: Driver]?, version: Int)?
        var timingData: (value: TimingData?, version: Int)?
        var timingAppData: (value: TimingAppData?, version: Int)?
        var positionData: (value: PositionData?, version: Int)?
        var carData: (value: CarData?, version: Int)?
        var weatherData: (value: WeatherData?, version: Int)?
        var raceControlMessages: (value: RaceControlMessages?, version: Int)?
        var teamRadio: (value: TeamRadio?, version: Int)?
        var timingStats: (value: TimingStats?, version: Int)?
        var championshipPrediction: (value: ChampionshipPrediction?, version: Int)?
        var lapCount: (value: LapCount?, version: Int)?
    }
    
    private var cache = Cache()
    private var stateVersions: [String: Int] = [:]
    
    // MARK: - Batch Update Support
    
    private var pendingUpdates: [[String: Any]] = []
    private var updateTimer: Timer?
    private let batchInterval: TimeInterval = 0.05 // 50ms batching
    
    // MARK: - Computed Properties with Caching
    
    var sessionInfo: SessionInfo? {
        getCached("sessionInfo", cache: \.sessionInfo) { self.cache.sessionInfo = $0 }
    }
    
    var trackStatus: TrackStatus? {
        getCached("trackStatus", cache: \.trackStatus) { self.cache.trackStatus = $0 }
    }
    
    var driverList: [String: Driver] {
        // Access updateCounter to ensure UI updates
        _ = updateCounter
        return getCached("driverList", cache: \.driverList) { self.cache.driverList = $0 } ?? [:]
    }
    
    var timingData: TimingData? {
        // Access updateCounter to ensure UI updates
        _ = updateCounter
        return getCached("timingData", cache: \.timingData) { self.cache.timingData = $0 }
    }
    
    var timingAppData: TimingAppData? {
        getCached("timingAppData", cache: \.timingAppData) { self.cache.timingAppData = $0 }
    }
    
    var positionData: PositionData? {
        // Access updateCounter to ensure UI updates
        _ = updateCounter
        return getCached("positionData", cache: \.positionData) { self.cache.positionData = $0 }
    }
    
    var carData: CarData? {
        getCached("carData", cache: \.carData) { self.cache.carData = $0 }
    }
    
    var weatherData: WeatherData? {
        getCached("weatherData", cache: \.weatherData) { self.cache.weatherData = $0 }
    }
    
    var raceControlMessages: RaceControlMessages? {
        // Access updateCounter to ensure UI updates
        _ = updateCounter
        return getCached("raceControlMessages", cache: \.raceControlMessages) { self.cache.raceControlMessages = $0 }
    }
  
    var teamRadio: TeamRadio? {
        getCached("teamRadio", cache: \.teamRadio) { self.cache.teamRadio = $0 }
    }
    
    var timingStats: TimingStats? {
        getCached("timingStats", cache: \.timingStats) { self.cache.timingStats = $0 }
    }
    
    var championshipPrediction: ChampionshipPrediction? {
        getCached("championshipPrediction", cache: \.championshipPrediction) { self.cache.championshipPrediction = $0 }
    }
    
    var lapCount: LapCount? {
        getCached("lapCount", cache: \.lapCount) { self.cache.lapCount = $0 }
    }
    
    var sortedDrivers: [Driver] {
        driverList.values.sorted { $0.line < $1.line }
    }
    
    var isSessionActive: Bool {
        sessionInfo != nil && trackStatus != nil
    }
    
    var currentFlag: String {
        trackStatus?.status.rawValue ?? "1"
    }
    
    var latestRaceControlMessage: RaceControlMessage? {
        raceControlMessages?.messages.max { $0.utc < $1.utc }
    }
    
    // MARK: - Update Methods
    
    func setFullState(_ state: [String: Any]) {
        // Cancel any pending batch updates
        updateTimer?.invalidate()
        pendingUpdates.removeAll()
        
        // Replace entire state
        dataState = state
        
        // Increment all versions to invalidate cache
        for key in state.keys {
            stateVersions[key, default: 0] += 1
        }
    }
    
    func applyPartialUpdate(_ update: [String: Any]) {
        // Add to pending updates for batching
        pendingUpdates.append(update)
        
        // Schedule batch processing if not already scheduled
        if updateTimer == nil {
            updateTimer = Timer.scheduledTimer(withTimeInterval: batchInterval, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    self?.processBatchedUpdates()
                }
            }
        }
    }
    
    private func processBatchedUpdates() {
        guard !pendingUpdates.isEmpty else { return }
        
//        print("OptimizedLiveSessionState: Processing \(pendingUpdates.count) batched updates")
        
        // Merge all pending updates
        var mergedUpdate: [String: Any] = [:]
        for update in pendingUpdates {
            DataTransformation.mergeStates(&mergedUpdate, with: update)
        }
        
//        print("OptimizedLiveSessionState: Merged updates contain keys: \(mergedUpdate.keys.joined(separator: ", "))")
        
        // Apply merged update to state
        DataTransformation.mergeStates(&dataState, with: mergedUpdate)
        
        // Update versions for changed keys
        for key in mergedUpdate.keys {
            stateVersions[key, default: 0] += 1
        }
        
        // Clear pending updates
        pendingUpdates.removeAll()
        updateTimer = nil
        
        // Force UI update
        updateCounter += 1
//        print("OptimizedLiveSessionState: Update counter incremented to \(updateCounter)")
    }
    
    func checkForNewRaceControlMessages() -> Bool {
        let messages = raceControlMessages
//        print("OptimizedLiveSessionState: Checking race control messages - messages exist: \(messages != nil)")
        let currentCount = messages?.messages.count ?? 0
        let hasNewMessages = currentCount > lastRaceControlMessageCount
        lastRaceControlMessageCount = currentCount
//        print("OptimizedLiveSessionState: Race control count - current: \(currentCount), last: \(lastRaceControlMessageCount), hasNew: \(hasNewMessages)")
        return hasNewMessages
    }
    
    func clear() {
        updateTimer?.invalidate()
        pendingUpdates.removeAll()
        dataState = [:]
        stateVersions = [:]
        cache = Cache()
        lastRaceControlMessageCount = 0
    }
    
    // MARK: - Private Caching Helpers
    
    private func getCached<T: Decodable>(
        _ key: String,
        cache keyPath: KeyPath<Cache, (value: T?, version: Int)?>,
        setter: @escaping ((value: T?, version: Int)?) -> Void
    ) -> T? {
        let currentVersion = stateVersions[key] ?? 0
        
        // Check if cache is valid
        if let cached = cache[keyPath: keyPath],
           cached.version == currentVersion {
            return cached.value
        }
        
        // Decode and cache
        let decoded: T? = decodeFromState(key)
        setter((value: decoded, version: currentVersion))
        return decoded
    }
    
    private func decodeFromState<T: Decodable>(_ key: String) -> T? {
        guard let value = dataState[key] else {
            print("OptimizedLiveSessionState: No value for key '\(key)' in dataState")
            print("Available keys: \(dataState.keys.joined(separator: ", "))")
            return nil
        }
        
        // Special handling for positionData which has a nested structure
        if key == "positionData", T.self == PositionData.self {
            // Check if the value is already the nested structure
            if let positionDict = value as? [String: Any] {
                // First check if we have the direct array (from initial state)
                if let positionArray = positionDict["positionData"] as? [[String: Any]] {
                    print("OptimizedLiveSessionState: Found nested position array with \(positionArray.count) entries")
                    
                    // The PositionData model expects: { "position": [...] }
                    let wrappedData: [String: Any] = ["position": positionArray]
                    
                    do {
                        let data = try JSONSerialization.data(withJSONObject: wrappedData)
                        let decoder = JSONDecoder()
                        let decoded = try decoder.decode(T.self, from: data)
                        print("OptimizedLiveSessionState: Successfully decoded positionData")
                        
                        if let positionData = decoded as? PositionData {
                            print("  Position count: \(positionData.position?.count ?? 0)")
                            if let firstPos = positionData.position?.first {
                                print("  First position has \(firstPos.entries.count) drivers")
                            }
                        }
                        
                        return decoded
                    } catch {
                        print("OptimizedLiveSessionState: Failed to decode positionData: \(error)")
                        // Don't fall through - return nil for position data
                        return nil
                    }
                }
            }
            // Also handle the case where value is directly the array (shouldn't happen but let's be safe)
            else if let positionArray = value as? [[String: Any]] {
                print("OptimizedLiveSessionState: Found direct position array with \(positionArray.count) entries")
                
                let wrappedData: [String: Any] = ["position": positionArray]
                
                do {
                    let data = try JSONSerialization.data(withJSONObject: wrappedData)
                    let decoder = JSONDecoder()
                    let decoded = try decoder.decode(T.self, from: data)
                    print("OptimizedLiveSessionState: Successfully decoded positionData from direct array")
                    
                    if let positionData = decoded as? PositionData {
                        print("  Position count: \(positionData.position?.count ?? 0)")
                        if let firstPos = positionData.position?.first {
                            print("  First position has \(firstPos.entries.count) drivers")
                        }
                    }
                    
                    return decoded
                } catch {
                    print("OptimizedLiveSessionState: Failed to decode positionData from direct array: \(error)")
                    return nil
                }
            }
            
            // If we get here for position data, it means the structure is not what we expected
            print("OptimizedLiveSessionState: Position data has unexpected structure")
            return nil
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: value)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(T.self, from: data)
            print("OptimizedLiveSessionState: Successfully decoded \(key)")
            
            // Special logging for race control messages
            if key == "raceControlMessages", let messages = decoded as? RaceControlMessages {
                print("OptimizedLiveSessionState: RaceControlMessages decoded with \(messages.messages.count) messages")
                if !messages.messages.isEmpty {
                    print("First message: \(messages.messages.first!.message)")
                }
            }
            
            return decoded
        } catch {
            print("OptimizedLiveSessionState: Failed to decode \(key): \(error)")
            
            // Special handling for raceControlMessages to debug
            if key == "raceControlMessages" {
                print("RaceControlMessages decoding error details:")
                print("Error type: \(type(of: error))")
                print("Error description: \(error)")
                
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context.debugDescription)")
                        print("Coding path: \(context.codingPath)")
                    case .keyNotFound(let key, let context):
                        print("Key not found: \(key)")
                        print("Context: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch: expected \(type)")
                        print("Context: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Value not found: \(type)")
                        print("Context: \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
            }
            
            // Print the raw JSON for debugging
            if let jsonString = String(data: try! JSONSerialization.data(withJSONObject: value, options: .prettyPrinted), encoding: .utf8) {
                print("Raw JSON for \(key):\n\(jsonString.prefix(500))...")
            }
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    func driver(for racingNumber: String) -> Driver? {
        driverList[racingNumber]
    }
    
    func timing(for racingNumber: String) -> TimingDataDriver? {
        timingData?.lines[racingNumber]
    }
    
    func position(for racingNumber: String) -> PositionCar? {
        positionData?.position?.last?.entries[racingNumber]
    }
    
    // Debug helper
    var debugStateKeys: [String] {
        Array(dataState.keys)
    }
    
    // Debug access to raw state data
    func debugRawData(for key: String) -> Any? {
        dataState[key]
    }
}
