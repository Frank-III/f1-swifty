//
//  NotificationManager.swift
//  F1-Dash
//
//  Manages user notifications for important events
//

import Foundation
import UserNotifications
import F1DashModels

@MainActor
final class NotificationManager {
    // MARK: - Properties
    
    private let appEnvironment: AppEnvironment
    private var lastTrackStatus: TrackFlag?
    private var lastLeader: String?
    private var isNotificationAvailable = false
    
    // MARK: - Initialization
    
    init(appEnvironment: AppEnvironment) {
        self.appEnvironment = appEnvironment
        
        // Check if we're running in a proper app bundle context
        if Bundle.main.bundleIdentifier != nil {
            Task {
                await requestAuthorization()
            }
        } else {
            print("NotificationManager: Running without app bundle context, notifications disabled")
        }
    }
    
    // MARK: - Authorization
    
    private func requestAuthorization() async {
        do {
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isNotificationAvailable = granted
        } catch {
            print("Failed to request notification authorization: \(error)")
            isNotificationAvailable = false
        }
    }
    
    // MARK: - Notification Handling
    
    func checkForNotifications() {
        guard isNotificationAvailable,
              appEnvironment.settingsStore.showNotifications else { return }
        
        checkTrackStatusChange()
        checkLeaderChange()
        checkFavoriteDriverEvents()
    }
    
    private func checkTrackStatusChange() {
        guard let currentStatus = appEnvironment.liveSessionState.trackStatus?.status else { return }
        
        if let lastStatus = lastTrackStatus, lastStatus != currentStatus {
            switch currentStatus {
            case .red:
                sendNotification(
                    title: "🔴 Red Flag",
                    body: "Session has been red flagged",
                    identifier: "track_status_red"
                )
            case .scYellow, .scRed:
                sendNotification(
                    title: "🟠 Safety Car",
                    body: "Safety car has been deployed",
                    identifier: "track_status_sc"
                )
            case .vsc:
                sendNotification(
                    title: "🟡 Virtual Safety Car",
                    body: "Virtual safety car deployed",
                    identifier: "track_status_vsc"
                )
            case .chequered:
                sendNotification(
                    title: "🏁 Chequered Flag",
                    body: "Session has ended",
                    identifier: "track_status_chequered"
                )
            default:
                break
            }
        }
        
        lastTrackStatus = currentStatus
    }
    
    private func checkLeaderChange() {
        // Find current leader (position 1)
        let currentLeader = appEnvironment.liveSessionState.sortedDrivers.first { driver in
            appEnvironment.liveSessionState.timing(for: driver.racingNumber)?.line == 1
        }
        
        if let leader = currentLeader,
           let lastLeader = lastLeader,
           leader.racingNumber != lastLeader {
            sendNotification(
                title: "🏆 New Leader",
                body: "\(leader.broadcastName) takes the lead!",
                identifier: "leader_change"
            )
        }
        
        lastLeader = currentLeader?.racingNumber
    }
    
    private func checkFavoriteDriverEvents() {
        let favoriteDrivers = appEnvironment.liveSessionState.sortedDrivers.filter { driver in
            appEnvironment.settingsStore.isFavoriteDriver(driver.racingNumber)
        }
        
        for driver in favoriteDrivers {
            guard let timing = appEnvironment.liveSessionState.timing(for: driver.racingNumber) else { continue }
            
            // Check for personal best lap
            if timing.lastLapTime.personalFastest {
                sendNotification(
                    title: "⭐ Personal Best",
                    body: "\(driver.broadcastName) sets a personal best lap!",
                    identifier: "pb_\(driver.racingNumber)"
                )
            }
            
            // Check for overall fastest lap
            if timing.lastLapTime.overallFastest {
                sendNotification(
                    title: "👑 Fastest Lap",
                    body: "\(driver.broadcastName) sets the fastest lap!",
                    identifier: "fastest_\(driver.racingNumber)"
                )
            }
        }
    }
    
    // MARK: - Send Notification
    
    private func sendNotification(title: String, body: String, identifier: String) {
        guard isNotificationAvailable else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil // Deliver immediately
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
}
