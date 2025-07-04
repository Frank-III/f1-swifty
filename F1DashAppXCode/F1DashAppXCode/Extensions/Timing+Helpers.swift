//
//  Timing+Helpers.swift
//  F1-Dash
//
//  Timing data formatting and helpers
//

import SwiftUI
import F1DashModels

extension String {
    /// Formats a lap time string (e.g., "1:23.456") with proper styling
    var formattedLapTime: String {
        // Remove any leading/trailing whitespace
        let cleanTime = self.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If it's empty or just dashes, return a placeholder
        if cleanTime.isEmpty || cleanTime == "-" || cleanTime == "--" {
            return "--:--.---"
        }
        
        return cleanTime
    }
    
    /// Converts a time string to a more readable format
    var readableLapTime: String {
        let time = formattedLapTime
        
        // Handle different time formats
        if time.contains(":") {
            return time // Already in MM:SS.sss format
        }
        
        // Convert from seconds-only format if needed
        if let seconds = Double(time) {
            let minutes = Int(seconds) / 60
            let remainingSeconds = seconds.truncatingRemainder(dividingBy: 60)
            return String(format: "%d:%06.3f", minutes, remainingSeconds)
        }
        
        return time
    }
    
    /// Returns true if this represents a valid lap time
    var isValidLapTime: Bool {
        let formatted = formattedLapTime
        return !formatted.isEmpty && 
               formatted != "--:--.---" && 
               formatted != "-" && 
               formatted != "--"
    }
}

// MARK: - Timing Status Helpers

extension TimingDataDriver {
    /// Returns the driver's current status as a readable string based on position data
    func statusDescription(positionStatus: String?) -> String {
        guard let status = positionStatus else {
            return "ON TRACK"
        }
        
        switch status {
        case "OutLap", "InLap":
            return "PIT"
        case "Stopped":
            return "STOP"
        case "Retired":
            return "OUT"
        default:
            return "ON TRACK"
        }
    }
    
    /// Returns the appropriate color for the driver's status
    func statusColor(positionStatus: String?) -> Color {
        guard let status = positionStatus else {
            return .green
        }
        
        switch status {
        case "Stopped", "Retired":
            return .red
        case "OutLap", "InLap":
            return .orange
        default:
            return .green
        }
    }
    
    /// Returns true if the driver should be shown with reduced opacity
    func shouldShowDimmed(positionStatus: String?) -> Bool {
        guard let status = positionStatus else {
            return false
        }
        
        return status == "Stopped" || status == "Retired"
    }
}

// MARK: - Position Helpers

extension String {
    /// Formats a position string with proper suffix (1st, 2nd, 3rd, etc.)
    var formattedPosition: String {
        guard let position = Int(self) else { return self }
        
        let suffix: String
        switch position % 10 {
        case 1 where position % 100 != 11:
            suffix = "st"
        case 2 where position % 100 != 12:
            suffix = "nd"
        case 3 where position % 100 != 13:
            suffix = "rd"
        default:
            suffix = "th"
        }
        
        return "\(position)\(suffix)"
    }
}