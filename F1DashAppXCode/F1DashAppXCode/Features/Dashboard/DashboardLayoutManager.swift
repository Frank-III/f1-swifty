//
//  DashboardLayoutManager.swift
//  F1-Dash
//
//  Manages dashboard section ordering and layout preferences
//

import SwiftUI
import Observation

enum DashboardSectionType: String, CaseIterable, Codable {
    case weather = "weather"
    case trackMap = "trackMap"
    case liveTiming = "liveTiming"
    case raceControl = "raceControl"
    
    var title: String {
        switch self {
        case .weather: return "Weather"
        case .trackMap: return "Track Map"
        case .liveTiming: return "Live Timing"
        case .raceControl: return "Race Control"
        }
    }
    
    var icon: String {
        switch self {
        case .weather: return "cloud.sun"
        case .trackMap: return "map"
        case .liveTiming: return "speedometer"
        case .raceControl: return "flag.2.crossed"
        }
    }
}

struct DashboardSectionItem: Identifiable, Codable {
    let id = UUID()
    let type: DashboardSectionType
    var isVisible: Bool = true
    
    // For custom coding to preserve order
    enum CodingKeys: String, CodingKey {
        case type
        case isVisible
    }
}

@MainActor
@Observable
class DashboardLayoutManager {
    var sections: [DashboardSectionItem] = []
    var isEditMode: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let layoutKey = "dashboardLayout"
    
    init() {
        loadLayout()
    }
    
    private func loadLayout() {
        if let data = userDefaults.data(forKey: layoutKey),
           let decoded = try? JSONDecoder().decode([DashboardSectionItem].self, from: data) {
            sections = decoded
        } else {
            // Default order
            sections = [
                DashboardSectionItem(type: .weather),
                DashboardSectionItem(type: .trackMap),
                DashboardSectionItem(type: .liveTiming),
                DashboardSectionItem(type: .raceControl)
            ]
        }
    }
    
    func saveLayout() {
        if let encoded = try? JSONEncoder().encode(sections) {
            userDefaults.set(encoded, forKey: layoutKey)
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        print("🔄 DashboardLayoutManager.move called")
        print("   Source indices: \(source)")
        print("   Destination: \(destination)")
        print("   Current sections order: \(sections.map { $0.type.rawValue })")
        
        sections.move(fromOffsets: source, toOffset: destination)
        
        print("   New sections order: \(sections.map { $0.type.rawValue })")
        saveLayout()
    }
    
    func toggleVisibility(for type: DashboardSectionType) {
        if let index = sections.firstIndex(where: { $0.type == type }) {
            sections[index].isVisible.toggle()
            saveLayout()
        }
    }
    
    func resetToDefault() {
        sections = [
            DashboardSectionItem(type: .weather),
            DashboardSectionItem(type: .trackMap),
            DashboardSectionItem(type: .liveTiming),
            DashboardSectionItem(type: .raceControl)
        ]
        saveLayout()
    }
}