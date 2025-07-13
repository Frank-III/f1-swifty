//
//  OptimizedNotificationManager.swift
//  F1-Dash
//
//  Notification manager that works with OptimizedAppEnvironment
//

import Foundation
import UserNotifications
import F1DashModels
#if os(iOS)
import UIKit
#endif

@MainActor
final class OptimizedNotificationManager {
    // MARK: - Properties
    
    private let appEnvironment: OptimizedAppEnvironment
    private var lastTrackStatus: TrackFlag?
    private var lastLeader: String?
    private var lastRaceControlMessageCount = 0
    
    // MARK: - Initialization
    
    init(appEnvironment: OptimizedAppEnvironment) {
        self.appEnvironment = appEnvironment
        
        Task {
            await requestNotificationPermission()
        }
    }
    
    // MARK: - Permission
    
    private func requestNotificationPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                print("Notification permission granted")
            }
        } catch {
            print("Failed to request notification permission: \(error)")
        }
    }
    
    // MARK: - Notification Checking
    
    func checkForNotifications() {
        guard appEnvironment.settingsStore.showNotifications else { return }
        
        checkTrackStatusChange()
        checkPositionChange()
        checkRaceControlMessages()
    }
    
    private func checkTrackStatusChange() {
        // Track status notifications are always enabled when notifications are on
        guard appEnvironment.settingsStore.showNotifications else { return }
        
        let currentStatus = appEnvironment.liveSessionState.trackStatus?.status
        
        if let currentStatus = currentStatus, currentStatus != lastTrackStatus {
            if let lastStatus = lastTrackStatus {
                // Only notify for significant changes
                let significantChanges: Set<TrackFlag> = [.green, .yellow, .red, .vsc, .scYellow, .scRed]
                if significantChanges.contains(currentStatus) || significantChanges.contains(lastStatus) {
                    sendNotification(
                        title: "Track Status Changed",
                        body: "Track status is now \(currentStatus.displayName)",
                        identifier: "track-status-\(currentStatus.rawValue)"
                    )
                }
            }
            lastTrackStatus = currentStatus
        }
    }
    
    private func checkPositionChange() {
        // Position change notifications for favorite drivers
        guard appEnvironment.settingsStore.showNotifications else { return }
        
        let favoriteDrivers = appEnvironment.settingsStore.favoriteDriverIDs
        let drivers = appEnvironment.liveSessionState.driverList
        
        // Check for position changes of favorite drivers
        for driverId in favoriteDrivers {
            if let driver = drivers[driverId] {
                // Check if driver is now leading (line 1 = position 1)
                if driver.line == 1 && driver.racingNumber != lastLeader {
                    sendNotification(
                        title: "New Race Leader",
                        body: "\(driver.fullName) is now leading the race!",
                        identifier: "leader-\(driver.racingNumber)"
                    )
                    lastLeader = driver.racingNumber
                }
            }
        }
    }
    
    private func checkRaceControlMessages() {
        // Race control notifications are always enabled when notifications are on
        guard appEnvironment.settingsStore.showNotifications else { return }
        
        guard let raceControlData = appEnvironment.liveSessionState.raceControlMessages else { return }
        let messages = raceControlData.messages
        
        if messages.count > lastRaceControlMessageCount {
            // Get new messages
            let newMessages = Array(messages.suffix(messages.count - lastRaceControlMessageCount))
            
            for message in newMessages {
                // Filter important messages
                if isImportantRaceControlMessage(message) {
                    sendNotification(
                        title: "Race Control",
                        body: message.message,
                        identifier: "race-control-\(message.utc)"
                    )
                }
            }
            
            lastRaceControlMessageCount = messages.count
        }
    }
    
    private func isImportantRaceControlMessage(_ message: RaceControlMessage) -> Bool {
        let importantKeywords = ["penalty", "investigation", "unsafe", "warning", "black", "flag"]
        let lowercasedMessage = message.message.lowercased()
        
        return importantKeywords.contains { keyword in
            lowercasedMessage.contains(keyword)
        }
    }
    
    // MARK: - Send Notification
    
    private func sendNotification(title: String, body: String, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Add app icon badge
        content.badge = 1
        
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
    
    // MARK: - Clear Notifications
    
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Clear badge
        #if os(iOS)
        Task { @MainActor in
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        #endif
    }
}