//
//  DashboardView.swift
//  F1-Dash
//
//  Main dashboard view combining all components
//

import SwiftUI
import F1DashModels

struct DashboardView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    @State private var selectedTab = DashboardTab.timing
    
    enum DashboardTab: String, CaseIterable {
        case timing = "Timing"
        case session = "Session"
        case weather = "Weather"
        case control = "Race Control"
        case trackMap = "Track Map"
        
        var icon: String {
            switch self {
            case .timing: return "stopwatch"
            case .session: return "flag.checkered"
            case .weather: return "cloud.sun"
            case .control: return "flag.2.crossed"
            case .trackMap: return "map"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with connection status
            DashboardHeader()
            
            // Tab selection
            Picker("View", selection: $selectedTab) {
                ForEach(DashboardTab.allCases, id: \.self) { tab in
                    Label(tab.rawValue, systemImage: tab.icon)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content
            ScrollView {
                switch selectedTab {
                case .timing:
                    VStack(spacing: 12) {
                        // Track status always visible
                        TrackStatusView()
                        
                        // Driver list
                        DriverListView()
                            .frame(maxHeight: 400)
                    }
                    
                case .session:
                    VStack(spacing: 12) {
                        SessionInfoView()
                        TrackStatusView()
                        
                        if appEnvironment.settingsStore.compactMode {
                            CompactWeatherView()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                case .weather:
                    VStack(spacing: 12) {
                        WeatherView()
                        
                        // Latest race control message
                        CompactRaceControlView()
                    }
                    
                case .control:
                    RaceControlView()
                    
                case .trackMap:
                    VStack(spacing: 12) {
                        TrackMapView()
                            .frame(height: 400)
                        
                        // Compact info below map
                        HStack {
                            CompactWeatherView()
                            Spacer()
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(width: 400, height: 600)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct DashboardHeader: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    var body: some View {
        HStack {
            // App icon and title
            HStack(spacing: 8) {
                Image(systemName: "flag.checkered.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.red)
                
                Text("F1 Dash")
                    .font(.headline)
            }
            
            Spacer()
            
            // Connection status
            ConnectionStatusIndicator()
            
            // Settings button
            Button {
                NSApp.sendAction(#selector(AppDelegate.openSettings), to: nil, from: nil)
            } label: {
                Image(systemName: "gear")
                    .font(.callout)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct ConnectionStatusIndicator: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(appEnvironment.connectionStatus.color)
                .frame(width: 8, height: 8)
            
            Text(appEnvironment.connectionStatus.description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .clipShape(Capsule())
    }
}

// MARK: - Popover Dashboard (Compact)

struct PopoverDashboardView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    @State private var showFullDashboard = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Compact header
            HStack {
                Label("F1 Dash", systemImage: "flag.checkered.circle.fill")
                    .font(.headline)
                
                Spacer()
                
                ConnectionStatusIndicator()
            }
            .padding()
            
            Divider()
            
            // Content based on connection status
            if appEnvironment.connectionStatus == .connected {
                ScrollView {
                    VStack(spacing: 12) {
                        // Track status
                        TrackStatusView()
                            .padding(.horizontal)
                        
                        // Driver list
                        DriverListView()
                            .frame(maxHeight: 300)
                        
                        // Compact info
                        HStack(spacing: 12) {
                            CompactWeatherView()
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // Latest race control
                        CompactRaceControlView()
                            .padding(.horizontal)
                        
                        // Mini track map
                        TrackMapMiniView()
                            .frame(height: 150)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                }
            } else {
                VStack(spacing: 16) {
                    ContentUnavailableView(
                        "Not Connected",
                        systemImage: "wifi.slash",
                        description: Text("Connect to view live timing data")
                    )
                    
                    Button("Connect") {
                        Task {
                            await appEnvironment.connect()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(height: 200)
            }
            
            Divider()
            
            // Footer buttons
            HStack {
                Button("Settings") {
                    NSApp.sendAction(#selector(AppDelegate.openSettings), to: nil, from: nil)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button("Open Dashboard") {
                    showFullDashboard = true
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .frame(width: 350, height: 500)
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showFullDashboard) {
            DashboardView()
        }
    }
}

#Preview("Full Dashboard") {
    DashboardView()
        .environment(AppEnvironment())
}

#Preview("Popover Dashboard") {
    PopoverDashboardView()
        .environment(AppEnvironment())
}
