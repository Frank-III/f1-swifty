//
//  LiveActivityManager.swift
//  F1-Dash
//
//  Manages Live Activities for F1 race tracking
//

import SwiftUI
#if os(iOS)
import ActivityKit
#endif
import Observation
import F1DashModels

@MainActor
@Observable
public final class LiveActivityManager {
    // MARK: - Properties
    
    #if os(iOS)
    private var currentActivity: Activity<F1RaceActivityAttributes>?
    #endif
    // weak var appEnvironment: AppEnvironment?
    weak var appEnvironment: OptimizedAppEnvironment?
    
    // State
    private(set) var isLiveActivityActive = false
    private var updateTimer: Timer?
    
    // MARK: - Public Methods
    
    func startLiveActivity() async {
        #if os(iOS)
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }
        
        guard let appEnvironment = appEnvironment else {
            print("AppEnvironment not set")
            return
        }
        
        // Get current race info
        let raceName = appEnvironment.currentRace?.name ?? "F1 Race"
        let circuitName = appEnvironment.currentRace?.countryName ?? "Unknown Circuit"
        
        // Create attributes
        let attributes = F1RaceActivityAttributes(
            raceName: raceName,
            circuitName: circuitName
        )
        
        // Create initial content state
        let contentState = createContentState(from: appEnvironment)
        
        do {
            // Request to start the activity
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: Date().addingTimeInterval(30))
            )
            
            currentActivity = activity
            isLiveActivityActive = true
            
            // Start update timer
            startUpdateTimer()
            
            print("Started Live Activity: \(activity.id)")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
        #else
        print("Live Activities are not supported on macOS")
        #endif
    }
    
    func updateLiveActivity() async {
        #if os(iOS)
        guard let activity = currentActivity,
              let appEnvironment = appEnvironment else { return }
        
        let contentState = createContentState(from: appEnvironment)
        
        await activity.update(
            ActivityContent(
                state: contentState,
                staleDate: Date().addingTimeInterval(30)
            )
        )
        #endif
    }
    
    func endLiveActivity() async {
        #if os(iOS)
        guard let activity = currentActivity else { return }
        
        // Stop update timer
        stopUpdateTimer()
        
        // Create final content state
        let finalContentState = createFinalContentState()
        
        await activity.end(
            ActivityContent(state: finalContentState, staleDate: nil),
            dismissalPolicy: .default
        )
        
        currentActivity = nil
        isLiveActivityActive = false
        #else
        // Stop update timer
        stopUpdateTimer()
        isLiveActivityActive = false
        #endif
    }
    
    // MARK: - Private Methods
    #if !os(macOS)
      // private func createContentState(from environment: AppEnvironment) -> F1RaceActivityAttributes.ContentState {
      private func createContentState(from environment: OptimizedAppEnvironment) -> F1RaceActivityAttributes.ContentState {
          let sessionInfo = environment.liveSessionState.sessionInfo
          let timingData = environment.liveSessionState.timingData
          let trackStatus = environment.liveSessionState.trackStatus
          let drivers = environment.liveSessionState.driverList
          
          // Get session info
          let sessionType = sessionInfo?.name ?? "Unknown"
          let currentLap = 0 // TODO: Get from appropriate data source
          let totalLaps = 0 // TODO: Get from appropriate data source
          
          // Get top 3 drivers
          let topThreeDrivers = getTopThreeDrivers(from: drivers, timingData: timingData)
          
          // Get favorite driver if set
          let favoriteDriver = getFavoriteDriver(from: drivers, timingData: timingData, environment: environment)
          
          // Get leader info
          let leader = topThreeDrivers.first
          
          return F1RaceActivityAttributes.ContentState(
              sessionType: sessionType,
              currentLap: currentLap,
              totalLaps: totalLaps,
              leaderTLA: leader?.tla ?? "---",
              leaderName: leader?.name ?? "Unknown",
              leaderGap: leader?.gap ?? "---",
              trackStatus: F1RaceActivityAttributes.ContentState.TrackStatus(
                  status: trackStatus?.status.displayName ?? "Unknown",
                  message: trackStatus?.message ?? "",
                  color: trackStatus?.status.color ?? "#808080"
              ),
              topThreeDrivers: topThreeDrivers,
              favoriteDriver: favoriteDriver,
              sessionTimeRemaining: getSessionTimeRemaining(from: sessionInfo)
          )
      }
    #endif
    
  
#if !os(macOS)
  private func createFinalContentState() -> F1RaceActivityAttributes.ContentState {
        guard let appEnvironment = appEnvironment else {
            return F1RaceActivityAttributes.ContentState(
                sessionType: "Finished",
                currentLap: 0,
                totalLaps: 0,
                leaderTLA: "---",
                leaderName: "Session Ended",
                leaderGap: "---",
                trackStatus: .init(status: "Finished", message: "", color: "#808080"),
                topThreeDrivers: [],
                favoriteDriver: nil,
                sessionTimeRemaining: nil
            )
        }
        
        // Create a final state with race results
        return createContentState(from: appEnvironment)
    }
  #endif
    
  #if !os(macOS)
    private func getTopThreeDrivers(
        from drivers: [String: Driver],
        timingData: TimingData?
    ) -> [F1RaceActivityAttributes.ContentState.CompactDriverInfo] {
        // Sort drivers by position
        let sortedDrivers = drivers.values.sorted { $0.line < $1.line }
        
        // Get top 3
        return sortedDrivers.prefix(3).compactMap { driver in
            let timing = timingData?.lines[driver.racingNumber]
            let gap = timing?.gapToLeader ?? "---"
            
            return F1RaceActivityAttributes.ContentState.CompactDriverInfo(
                position: driver.line,
                tla: driver.tla,
                name: driver.fullName,
                gap: driver.line == 1 ? "Leader" : gap,
                teamColor: driver.teamColour
            )
        }
    }
  #endif
    
#if !os(macOS)
    private func getFavoriteDriver(
        from drivers: [String: Driver],
        timingData: TimingData?,
        environment: OptimizedAppEnvironment
    ) -> F1RaceActivityAttributes.ContentState.CompactDriverInfo? {
        // Find favorite driver
        guard let favoriteDriver = drivers.values.first(where: {
            environment.settingsStore.isFavoriteDriver($0.racingNumber)
        }) else { return nil }
        
        let timing = timingData?.lines[favoriteDriver.racingNumber]
        let gap = timing?.gapToLeader ?? "---"
        
        return F1RaceActivityAttributes.ContentState.CompactDriverInfo(
            position: favoriteDriver.line,
            tla: favoriteDriver.tla,
            name: favoriteDriver.fullName,
            gap: gap,
            teamColor: favoriteDriver.teamColour
        )
    }
#endif

    private func getSessionTimeRemaining(from sessionInfo: SessionInfo?) -> String? {
        guard sessionInfo != nil else { return nil }
        
        // This would calculate remaining time based on session data
        // For now, return a placeholder
        return nil
    }
    
    // MARK: - Timer Management
    
    private func startUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task { @MainActor in
                await self.updateLiveActivity()
            }
        }
    }
    
    private func stopUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
}

// MARK: - Integration with AppEnvironment

extension AppEnvironment {
    func startLiveActivity() async {
        // This would be called when a race session starts
        if let liveActivityManager = self.liveActivityManager {
            await liveActivityManager.startLiveActivity()
        }
    }
    
    func endLiveActivity() async {
        // This would be called when a race session ends
        if let liveActivityManager = self.liveActivityManager {
            await liveActivityManager.endLiveActivity()
        }
    }
}
