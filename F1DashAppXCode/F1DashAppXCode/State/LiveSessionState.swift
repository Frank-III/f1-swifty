//
//  LiveSessionStateNew.swift
//  F1-Dash
//
//  The source of truth for all live UI data - Dictionary-based version
//

import SwiftUI
import Observation
import F1DashModels

@MainActor
@Observable
final class LiveSessionStateNew {
    // MARK: - State Storage
    
    // Store state as dictionary for flexible merging
    private var stateDict: [String: Any] = [:]
    
    // Track last race control message count for chime detection
    private var lastRaceControlMessageCount: Int = 0
    
    // MARK: - Computed Properties (decode on demand)
    
    var sessionInfo: SessionInfo? {
        decodeFromState("sessionInfo")
    }
    
    var trackStatus: TrackStatus? {
        decodeFromState("trackStatus")
    }
    
    var driverList: [String: Driver] {
        decodeFromState("driverList") ?? [:]
    }
    
    var timingData: TimingData? {
        decodeFromState("timingData")
    }
    
    var timingAppData: TimingAppData? {
        decodeFromState("timingAppData")
    }
    
    var positionData: PositionData? {
        // The data is nested: { "positionData": { "positionData": [...] } }
        guard let outerDict = stateDict["positionData"] as? [String: Any],
              let positionArray = outerDict["positionData"] as? [[String: Any]] else {
            print("LiveSessionState: Failed to extract position array")
            return nil
        }
        
        print("LiveSessionState: Found position array with \(positionArray.count) entries")
        
        // The PositionData model expects the array to be at the "position" key
        // JSONDecoder can handle Int to Double conversion automatically
        let wrappedData: [String: Any] = ["position": positionArray]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: wrappedData)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(PositionData.self, from: jsonData)
            print("LiveSessionState: Successfully decoded PositionData with \(decoded.position?.count ?? 0) positions")
            
            if let firstPos = decoded.position?.first {
                print("  First position timestamp: \(firstPos.timestamp)")
                print("  First position entries: \(firstPos.entries.count)")
                
                // Log a few driver positions for debugging
                for (driverNum, pos) in firstPos.entries.prefix(3) {
                    print("  Driver \(driverNum): x=\(pos.x), y=\(pos.y), z=\(pos.z), status=\(pos.status ?? "unknown")")
                }
            }
            
            return decoded
        } catch {
            print("LiveSessionState: Failed to decode position data: \(error)")
            
            // More detailed error info
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("  Type mismatch: expected \(type)")
                    print("  Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                    print("  Debug: \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("  Value not found: \(type)")
                    print("  Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                case .keyNotFound(let key, let context):
                    print("  Key not found: \(key.stringValue)")
                    print("  Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                case .dataCorrupted(let context):
                    print("  Data corrupted")
                    print("  Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                    print("  Debug: \(context.debugDescription)")
                @unknown default:
                    print("  Unknown decoding error")
                }
            }
            
            // Debug the raw data structure
            if let firstEntry = positionArray.first {
                print("  First entry keys: \(firstEntry.keys.sorted())")
                if let entries = firstEntry["entries"] as? [String: Any],
                   let firstDriverKey = entries.keys.sorted().first,
                   let firstDriver = entries[firstDriverKey] as? [String: Any] {
                    print("  First driver entry:")
                    for (key, value) in firstDriver {
                        print("    \(key): \(type(of: value)) = \(value)")
                    }
                }
            }
            
            return nil
        }
    }
    
    var carData: CarData? {
        decodeFromState("carData")
    }
    
    var weatherData: WeatherData? {
        decodeFromState("weatherData")
    }
    
    var raceControlMessages: RaceControlMessages? {
        decodeFromState("raceControlMessages")
    }
    
    var teamRadio: TeamRadio? {
        decodeFromState("teamRadio")
    }
    
    var lapCount: LapCount? {
        decodeFromState("lapCount")
    }
    
    var timingStats: TimingStats? {
        decodeFromState("timingStats")
    }
    
    var championshipPrediction: ChampionshipPrediction? {
        decodeFromState("championshipPrediction")
    }
    
    var sortedDrivers: [Driver] {
        driverList.values.sorted { lhs, rhs in
            // Sort by line number as primary sort
            lhs.line < rhs.line
        }
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
        // Replace entire state dictionary
        stateDict = state
    }
    
    func applyPartialUpdate(_ update: [String: Any]) {
        // Use the TypeScript-style merge logic
//        DictionaryMerge.mergeState(&stateDict, with: update)
        DataTransformation.mergeStates(&stateDict, with: update)
    }
    
    // Returns true if new race control messages were added
    func checkForNewRaceControlMessages() -> Bool {
        let currentCount = raceControlMessages?.messages.count ?? 0
        let hasNewMessages = currentCount > lastRaceControlMessageCount
        lastRaceControlMessageCount = currentCount
        return hasNewMessages
    }
    
    func clear() {
        stateDict = [:]
        lastRaceControlMessageCount = 0
    }
    
    // MARK: - Private Decoding Helpers
    
    private func decodeFromState<T: Decodable>(_ key: String) -> T? {
        guard let value = stateDict[key] else { return nil }
        
        do {
            // Convert to JSON data
            let data = try JSONSerialization.data(withJSONObject: value)
            
            // Decode to target type
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            // Only log errors for debugging, don't crash
            print("Failed to decode \(key): \(error)")
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
        // Get the latest position if available
        positionData?.position?.last?.entries[racingNumber]
    }
    
    // Debug helper methods
    var debugStateKeys: [String] {
        Array(stateDict.keys).sorted()
    }
    
    func debugRawData(for key: String) -> Any? {
        stateDict[key]
    }
}
