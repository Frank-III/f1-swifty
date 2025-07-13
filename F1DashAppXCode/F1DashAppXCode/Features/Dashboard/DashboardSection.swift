//
//  DashboardSection.swift
//  F1-Dash
//
//  Dashboard section types
//

import SwiftUI

enum DashboardSection: String, CaseIterable {
    case all = "All"
    case weather = "Weather"
    case trackMap = "Track Map"
    case liveTiming = "Live Timing"
    case raceControl = "Race Control"
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .weather: return "cloud.sun"
        case .trackMap: return "map"
        case .liveTiming: return "speedometer"
        case .raceControl: return "flag.2.crossed"
        }
    }
}
