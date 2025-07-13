//
//  RacePreferences.swift
//  F1-Dash
//
//  User preferences for race favorites and notifications
//

import SwiftUI
import Observation

@MainActor
@Observable
final class RacePreferences {
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "favoriteRaces"
    private let notificationsKey = "notificationRaces"
    
    private(set) var favoriteRaces: Set<String> = []
    private(set) var notificationRaces: Set<String> = []
    
    init() {
        loadPreferences()
    }
    
    private func loadPreferences() {
        if let favorites = userDefaults.array(forKey: favoritesKey) as? [String] {
            favoriteRaces = Set(favorites)
        }
        
        if let notifications = userDefaults.array(forKey: notificationsKey) as? [String] {
            notificationRaces = Set(notifications)
        }
    }
    
    func toggleFavorite(raceId: String) {
        if favoriteRaces.contains(raceId) {
            favoriteRaces.remove(raceId)
        } else {
            favoriteRaces.insert(raceId)
        }
        savePreferences()
    }
    
    func toggleNotification(raceId: String) {
        if notificationRaces.contains(raceId) {
            notificationRaces.remove(raceId)
        } else {
            notificationRaces.insert(raceId)
        }
        savePreferences()
    }
    
    func isFavorite(_ raceId: String) -> Bool {
        favoriteRaces.contains(raceId)
    }
    
    func hasNotification(_ raceId: String) -> Bool {
        notificationRaces.contains(raceId)
    }
    
    private func savePreferences() {
        userDefaults.set(Array(favoriteRaces), forKey: favoritesKey)
        userDefaults.set(Array(notificationRaces), forKey: notificationsKey)
    }
}