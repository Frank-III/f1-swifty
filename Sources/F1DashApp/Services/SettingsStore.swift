//
//  SettingsStore.swift
//  F1-Dash
//
//  Manages user settings with swift-sharing
//

import SwiftUI
import Sharing

@MainActor
@Observable
final class SettingsStore {
    // MARK: - Shared Settings
    
    @ObservationIgnored
    @Shared(.appStorage("launchAtLogin")) var launchAtLogin = false
    
    @ObservationIgnored
    @Shared(.appStorage("favoriteDrivers")) var favoriteDriverIDsString: String = ""
    
    @ObservationIgnored
    @Shared(.appStorage("dataDelay")) var dataDelay: TimeInterval = 0.0
    
    @ObservationIgnored
    @Shared(.appStorage("showNotifications")) var showNotifications = true
    
    @ObservationIgnored
    @Shared(.appStorage("trackMapZoom")) var trackMapZoom: Double = 1.0
    
    @ObservationIgnored
    @Shared(.appStorage("compactMode")) var compactMode = false
    
    @ObservationIgnored
    @Shared(.appStorage("showCornerNumbers")) var showCornerNumbers = false
    
    // MARK: - Computed Properties
    
    var favoriteDriverIDs: Set<String> {
      get { Set(favoriteDriverIDsString.components(separatedBy: ";")) }
      set { $favoriteDriverIDsString.withLock { $0 = Array(newValue).joined(separator: ";") } }
    }
    
    var hasDataDelay: Bool {
        dataDelay > 0
    }
    
    var formattedDelay: String {
        if dataDelay == 0 {
            return "Live"
        } else if dataDelay < 60 {
            return "\(Int(dataDelay))s"
        } else {
            let minutes = Int(dataDelay / 60)
            let seconds = Int(dataDelay.truncatingRemainder(dividingBy: 60))
            return seconds > 0 ? "\(minutes)m \(seconds)s" : "\(minutes)m"
        }
    }
    
    // MARK: - Methods
    
    func toggleFavoriteDriver(_ driverID: String) {
        $favoriteDriverIDsString.withLock { str in
          if str.contains(driverID) {
            str = str.replacingOccurrences(of: "\(driverID)", with: "")
                .replacingOccurrences(of: ";;", with: ";")
                .trimmingCharacters(in: CharacterSet(charactersIn: ";"))
          } else {
            str = str + (str.isEmpty ? "" : ";") + driverID
          }
        }
    }
    
    func isFavoriteDriver(_ driverID: String) -> Bool {
        favoriteDriverIDs.contains(driverID)
    }
    
    func setDataDelayFromSeconds(_ seconds: Int) {
        $dataDelay.withLock { $0 = TimeInterval(seconds) }
    }
    
    func resetToDefaults() {
        $launchAtLogin.withLock { $0 = false }
        $favoriteDriverIDsString.withLock { $0 = "" }
        $dataDelay.withLock { $0 = 0.0 }
        $showNotifications.withLock { $0 = true }
        $trackMapZoom.withLock { $0 = 1.0 }
        $compactMode.withLock { $0 = false }
        $showCornerNumbers.withLock { $0 = false }
    }
}

// MARK: - Predefined Delay Options

extension SettingsStore {
    static let delayOptions: [(label: String, seconds: Int)] = [
        ("Live", 0),
        ("5 seconds", 5),
        ("10 seconds", 10),
        ("30 seconds", 30),
        ("1 minute", 60),
        ("2 minutes", 120),
        ("5 minutes", 300)
    ]
}
