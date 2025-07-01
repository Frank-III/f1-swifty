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
    private(set) var positionData: PositionData?
    private(set) var weatherData: WeatherData?
    private(set) var raceControlMessages: RaceControlMessages?
    private(set) var teamRadio: TeamRadio?
    private(set) var timingStats: TimingStats?
    
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
        positionData = state.positionData
        weatherData = state.weatherData
        raceControlMessages = state.raceControlMessages
        teamRadio = state.teamRadio
        timingStats = state.timingStats
    }
    
    func applyUpdate(_ update: SendableJSON) {
        _ = update.dictionary
        
        // Update each field if present in the update
        // This is a simplified version - in production you'd parse each field properly
        // For now, we'll just mark that an update was received
    }
    
    func clear() {
        sessionInfo = nil
        trackStatus = nil
        driverList = [:]
        timingData = nil
        positionData = nil
        weatherData = nil
        raceControlMessages = nil
        teamRadio = nil
        timingStats = nil
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
        positionData?.position.last?.entries[racingNumber]
    }
}
