//
//  Driver+Helpers.swift
//  F1-Dash
//
//  Driver model extensions and helpers
//

import SwiftUI
import F1DashModels

extension Driver {
    /// Returns the team color as a SwiftUI Color, with fallback to gray
    var teamColor: Color {
        return Color(hex: teamColour) ?? .gray
    }
    
    /// Returns the driver's full name in "FirstName LastName" format
    var fullDisplayName: String {
        return "\(firstName) \(lastName)"
    }
    
    /// Returns a short display format: "TLA - LastName"
    var shortDisplayName: String {
        return "\(tla) - \(lastName)"
    }
    
    /// Returns the driver's initials from first and last name
    var initials: String {
        let firstInitial = firstName.first?.uppercased() ?? ""
        let lastInitial = lastName.first?.uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
}

// MARK: - Driver Collection Helpers

extension Collection where Element == Driver {
    /// Sorts drivers by their racing number
    func sortedByNumber() -> [Driver] {
        return sorted { driver1, driver2 in
            guard let num1 = Int(driver1.racingNumber),
                  let num2 = Int(driver2.racingNumber) else {
                return driver1.racingNumber < driver2.racingNumber
            }
            return num1 < num2
        }
    }
    
    /// Sorts drivers by their broadcast name alphabetically
    func sortedByName() -> [Driver] {
        return sorted { $0.broadcastName < $1.broadcastName }
    }
    
    /// Filters drivers by team
    func filtered(by team: String) -> [Driver] {
        return filter { $0.teamName.lowercased().contains(team.lowercased()) }
    }
}