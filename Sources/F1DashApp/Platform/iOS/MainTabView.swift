//
//  MainTabView.swift
//  F1-Dash
//
//  Main tab view for iOS/iPadOS
//

import SwiftUI

public struct MainTabView: View {
    public init() {}
    @Environment(AppEnvironment.self) private var appEnvironment
    
    public var body: some View {
        TabView {
            DashboardViewPlaceholder()
                .tabItem {
                    Label("Dashboard", systemImage: "speedometer")
                }
            
            StandingsView()
                .tabItem {
                    Label("Standings", systemImage: "list.number")
                }
            
            WeatherViewPlaceholder()
                .tabItem {
                    Label("Weather", systemImage: "cloud.sun")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .task {
            // Auto-connect when view appears
            if appEnvironment.connectionStatus == .disconnected {
                await appEnvironment.connect()
            }
        }
    }
}

// MARK: - Dashboard View Placeholder

struct DashboardViewPlaceholder: View {
    var body: some View {
        NavigationStack {
            Text("Dashboard - Coming Soon")
                .navigationTitle("F1 Dashboard")
        }
    }
}

// MARK: - Standings View

struct StandingsView: View {
    var body: some View {
        NavigationStack {
            Text("Standings - Coming Soon")
                .navigationTitle("Championship Standings")
        }
    }
}

// MARK: - Weather View Placeholder

struct WeatherViewPlaceholder: View {
    var body: some View {
        NavigationStack {
            Text("Weather - Coming Soon")
                .navigationTitle("Weather")
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppEnvironment())
}
