//
//  LiveSessionState.swift
//  F1-Dash
//
//  The source of truth for all live UI data
//

import SwiftUI
import Observation
import F1DashModels

@MainActor
@Observable
final class LiveSessionState {
    // MARK: - State Properties
    
    private(set) var sessionInfo: SessionInfo?
    private(set) var trackStatus: TrackStatus?
    private(set) var driverList: [String: Driver] = [:]
    private(set) var timingData: TimingData?
    private(set) var timingAppData: TimingAppData?
    private(set) var positionData: PositionData?
    private(set) var carData: CarData?
    private(set) var weatherData: WeatherData?
    private(set) var raceControlMessages: RaceControlMessages?
    private(set) var teamRadio: TeamRadio?
    private(set) var timingStats: TimingStats?
    private(set) var championshipPrediction: ChampionshipPrediction?
    
    // Track last race control message count for chime detection
    private var lastRaceControlMessageCount: Int = 0
    
    // MARK: - Computed Properties
    
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
    
    func updateFullState(_ state: F1State) {
        sessionInfo = state.sessionInfo
        trackStatus = state.trackStatus
        driverList = state.driverList ?? [:]
        timingData = state.timingData
        timingAppData = state.timingAppData
        positionData = state.positionData
        carData = state.carData
        weatherData = state.weatherData
        raceControlMessages = state.raceControlMessages
        teamRadio = state.teamRadio
        timingStats = state.timingStats
        championshipPrediction = state.championshipPrediction
    }
    
    func applyUpdate(_ update: SendableJSON) {
        do {
            // Create current state representation for merging
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()
            
            // Convert current state to dictionary format
            let currentStateData = try encoder.encode(createCurrentF1State())
            var stateDict = try JSONSerialization.jsonObject(with: currentStateData) as? [String: Any] ?? [:]
            
            // Merge the update using the same logic as SessionStateCache
            DataTransformation.mergeStates(&stateDict, with: update.dictionary)
            
            // Convert back to F1State and update individual properties
            let mergedData = try JSONSerialization.data(withJSONObject: stateDict)
            let mergedState = try decoder.decode(F1State.self, from: mergedData)
            
            // Update individual properties from merged state
            if let sessionInfo = mergedState.sessionInfo {
                self.sessionInfo = sessionInfo
            }
            
            if let trackStatus = mergedState.trackStatus {
                self.trackStatus = trackStatus
            }
            
            if let driverList = mergedState.driverList {
                self.driverList = driverList
            }
            
            if let timingData = mergedState.timingData {
                self.timingData = timingData
            }
            
            if let timingAppData = mergedState.timingAppData {
                self.timingAppData = timingAppData
            }
            
            if let positionData = mergedState.positionData {
                self.positionData = positionData
            }
            
            if let carData = mergedState.carData {
                self.carData = carData
            }
            
            if let weatherData = mergedState.weatherData {
                self.weatherData = weatherData
            }
            
            if let raceControlMessages = mergedState.raceControlMessages {
                self.raceControlMessages = raceControlMessages
            }
            
            if let teamRadio = mergedState.teamRadio {
                self.teamRadio = teamRadio
            }
            
            if let timingStats = mergedState.timingStats {
                self.timingStats = timingStats
            }
            
            if let championshipPrediction = mergedState.championshipPrediction {
                self.championshipPrediction = championshipPrediction
            }
            
        } catch {
            print("Failed to apply state update: \(error)")
            
            // Log additional debug info for decoding errors
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("  → Missing key '\(key.stringValue)' at path: \(context.codingPath.map { $0.stringValue }.joined(separator: " → "))")
                case .typeMismatch(let type, let context):
                    print("  → Type mismatch for \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: " → "))")
                case .valueNotFound(let type, let context):
                    print("  → Value not found for \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: " → "))")
                case .dataCorrupted(let context):
                    print("  → Data corrupted at path: \(context.codingPath.map { $0.stringValue }.joined(separator: " → "))")
                @unknown default:
                    print("  → Unknown decoding error: \(decodingError)")
                }
            }
        }
    }
    
    // Returns true if new race control messages were added
    func checkForNewRaceControlMessages() -> Bool {
        let currentCount = raceControlMessages?.messages.count ?? 0
        let hasNewMessages = currentCount > lastRaceControlMessageCount
        lastRaceControlMessageCount = currentCount
        return hasNewMessages
    }
    
    private func createCurrentF1State() -> F1State {
        return F1State(
            driverList: driverList.isEmpty ? nil : driverList,
            timingData: timingData,
            timingAppData: timingAppData,
            positionData: positionData,
            carData: carData,
            trackStatus: trackStatus,
            sessionInfo: sessionInfo,
            weatherData: weatherData,
            timingStats: timingStats,
            raceControlMessages: raceControlMessages,
            teamRadio: teamRadio,
            championshipPrediction: championshipPrediction
        )
    }
    
    func clear() {
        sessionInfo = nil
        trackStatus = nil
        driverList = [:]
        timingData = nil
        timingAppData = nil
        positionData = nil
        carData = nil
        weatherData = nil
        raceControlMessages = nil
        teamRadio = nil
        timingStats = nil
        championshipPrediction = nil
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
}
