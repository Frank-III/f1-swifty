//
//  SplitSessionStates.swift
//  F1-Dash
//
//  Split session state into focused observable objects to minimize view updates
//

import SwiftUI
import Observation
import F1DashModels

// MARK: - Timing State (High Frequency Updates)

@MainActor
@Observable
final class TimingState {
    private var timingData: TimingData?
    private var timingAppData: TimingAppData?
    private var timingStats: TimingStats?
    
    func update(from state: [String: Any]) {
        if let timing = state["timingData"] {
            self.timingData = decode(timing)
        }
        if let appData = state["timingAppData"] {
            self.timingAppData = decode(appData)
        }
        if let stats = state["timingStats"] {
            self.timingStats = decode(stats)
        }
    }
    
    func timing(for racingNumber: String) -> TimingDataDriver? {
        timingData?.lines[racingNumber]
    }
    
    func stints(for racingNumber: String) -> [Stint] {
        timingAppData?.lines[racingNumber]?.stints ?? []
    }
    
    var allTimingData: TimingData? { timingData }
    var allTimingAppData: TimingAppData? { timingAppData }
    var allTimingStats: TimingStats? { timingStats }
    
    private func decode<T: Decodable>(_ value: Any) -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: value),
              let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        return decoded
    }
}

// MARK: - Position State (High Frequency Updates)

@MainActor
@Observable
final class PositionState {
    private var positionData: PositionData?
    private var carData: CarData?
    
    func update(from state: [String: Any]) {
        if let position = state["positionData"] {
            self.positionData = decode(position)
        }
        if let car = state["carData"] {
            self.carData = decode(car)
        }
    }
    
    func position(for racingNumber: String) -> PositionCar? {
        positionData?.position?.last?.entries[racingNumber]
    }
    
    func carTelemetry(for racingNumber: String) -> CarDataChannels? {
        carData?.entries.last?.cars[racingNumber]
    }
    
    var allPositions: PositionData? { positionData }
    var allCarData: CarData? { carData }
    
    private func decode<T: Decodable>(_ value: Any) -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: value),
              let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        return decoded
    }
}

// MARK: - Session Info State (Low Frequency Updates)

@MainActor
@Observable
final class SessionInfoState {
    private var sessionInfo: SessionInfo?
    private var trackStatus: TrackStatus?
    private var weatherData: WeatherData?
    private var sessionStatus: String?
    private var sessionData: [String: Any]?
    
    func update(from state: [String: Any]) {
        if let info = state["sessionInfo"] {
            self.sessionInfo = decode(info)
        }
        if let status = state["trackStatus"] {
            self.trackStatus = decode(status)
        }
        if let weather = state["weatherData"] {
            self.weatherData = decode(weather)
        }
        if let status = state["sessionStatus"] as? String {
            self.sessionStatus = status
        }
        if let data = state["sessionData"] as? [String: Any] {
            self.sessionData = data
        }
    }
    
    var currentSessionInfo: SessionInfo? { sessionInfo }
    var currentTrackStatus: TrackStatus? { trackStatus }
    var currentWeatherData: WeatherData? { weatherData }
    var currentSessionStatus: String? { sessionStatus }
    
    var isSessionActive: Bool {
        sessionInfo != nil && trackStatus != nil
    }
    
    var currentFlag: String {
        trackStatus?.status.rawValue ?? "1"
    }
    
    private func decode<T: Decodable>(_ value: Any) -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: value),
              let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        return decoded
    }
}

// MARK: - Driver List State (Medium Frequency Updates)

@MainActor
@Observable
final class DriverListState {
    private var driverList: [String: Driver] = [:]
    private var cachedSortedDrivers: [Driver] = []
    private var lastDriverCount = 0
    
    func update(from state: [String: Any]) {
        if let drivers = state["driverList"] {
            if let decoded: [String: Driver] = decode(drivers) {
                self.driverList = decoded
                // Invalidate sorted cache
                if decoded.count != lastDriverCount {
                    lastDriverCount = decoded.count
                    cachedSortedDrivers = []
                }
            }
        }
    }
    
    var drivers: [String: Driver] { driverList }
    
    var sortedDrivers: [Driver] {
        if cachedSortedDrivers.isEmpty && !driverList.isEmpty {
            cachedSortedDrivers = driverList.values.sorted { $0.line < $1.line }
        }
        return cachedSortedDrivers
    }
    
    func driver(for racingNumber: String) -> Driver? {
        driverList[racingNumber]
    }
    
    private func decode<T: Decodable>(_ value: Any) -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: value),
              let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        return decoded
    }
}

// MARK: - Messages State (Low Frequency Updates)

@MainActor
@Observable
final class MessagesState {
    private var raceControlMessages: RaceControlMessages?
    private var teamRadio: TeamRadio?
    private var lastMessageCount = 0
    
    func update(from state: [String: Any]) {
        if let messages = state["raceControlMessages"] {
            self.raceControlMessages = decode(messages)
        }
        if let radio = state["teamRadio"] {
            self.teamRadio = decode(radio)
        }
    }
    
    var currentRaceControlMessages: RaceControlMessages? { raceControlMessages }
    var currentTeamRadio: TeamRadio? { teamRadio }
    
    var latestRaceControlMessage: RaceControlMessage? {
        raceControlMessages?.messages.max { $0.utc < $1.utc }
    }
    
    func checkForNewMessages() -> Bool {
        let currentCount = raceControlMessages?.messages.count ?? 0
        let hasNew = currentCount > lastMessageCount
        lastMessageCount = currentCount
        return hasNew
    }
    
    private func decode<T: Decodable>(_ value: Any) -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: value),
              let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        return decoded
    }
}

// MARK: - Split Session State Coordinator

@MainActor
@Observable
final class SplitSessionStateCoordinator {
    let timingState = TimingState()
    let positionState = PositionState()
    let sessionInfoState = SessionInfoState()
    let driverListState = DriverListState()
    let messagesState = MessagesState()
    
    private var updateQueue = DispatchQueue(label: "session.update", qos: .userInteractive)
    
    func setFullState(_ state: [String: Any]) {
        // Update all sub-states
        timingState.update(from: state)
        positionState.update(from: state)
        sessionInfoState.update(from: state)
        driverListState.update(from: state)
        messagesState.update(from: state)
    }
    
    func applyPartialUpdate(_ update: [String: Any]) {
        // Route updates to appropriate sub-states
        updateQueue.async { [weak self] in
            guard let self = self else { return }
            
            let timingKeys = ["timingData", "timingAppData", "timingStats"]
            let positionKeys = ["positionData", "carData"]
            let sessionKeys = ["sessionInfo", "trackStatus", "weatherData", "sessionStatus", "sessionData"]
            let driverKeys = ["driverList"]
            let messageKeys = ["raceControlMessages", "teamRadio"]
            
            Task { @MainActor in
                // Only update states that have relevant data
                if update.keys.contains(where: { timingKeys.contains($0) }) {
                    self.timingState.update(from: update)
                }
                
                if update.keys.contains(where: { positionKeys.contains($0) }) {
                    self.positionState.update(from: update)
                }
                
                if update.keys.contains(where: { sessionKeys.contains($0) }) {
                    self.sessionInfoState.update(from: update)
                }
                
                if update.keys.contains(where: { driverKeys.contains($0) }) {
                    self.driverListState.update(from: update)
                }
                
                if update.keys.contains(where: { messageKeys.contains($0) }) {
                    self.messagesState.update(from: update)
                }
            }
        }
    }
    
    func clear() {
        setFullState([:])
    }
}