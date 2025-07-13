//
//  DashboardView.swift
//  F1-Dash
//
//  Main dashboard view combining all components
//

import SwiftUI
import F1DashModels
#if canImport(AppKit)
import AppKit
#endif

struct DashboardView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @State private var selectedTab: DashboardTab? = .timing
    
    enum DashboardTab: String, CaseIterable, Identifiable {
        case timing = "Timing"
        case session = "Session"
        case standings = "Standings"
        case weather = "Weather"
        case control = "Race Control"
        case trackMap = "Track Map"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .timing: return "stopwatch"
            case .session: return "flag.checkered"
            case .standings: return "trophy"
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
            
            // Navigation split view
            NavigationSplitView {
                // Sidebar with navigation options
                List(selection: $selectedTab) {
                    ForEach(DashboardTab.allCases) { tab in
                        Label(tab.rawValue, systemImage: tab.icon)
                            .tag(tab)
                    }
                }
                .navigationTitle("F1 Dashboard")
                .frame(minWidth: 150)
            } detail: {
                // Detail view based on selection
                if let selectedTab = selectedTab {
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
                            .padding()
                            
                        case .session:
                            VStack(spacing: 12) {
                                SessionInfoView()
                                TrackStatusView()
                                
                                if appEnvironment.settingsStore.compactMode {
                                    CompactWeatherView()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding()
                            
                        case .standings:
                            StandingsView()
                                .padding()
                            
                        case .weather:
                            VStack(spacing: 12) {
                                WeatherView()
                                
                                // Wind map card
                                WindMapCard()
                                    .frame(height: 150)
                                
                                // Latest race control message
                                CompactRaceControlView()
                            }
                            .padding()
                            
                        case .control:
                            RaceControlView()
                                .padding()
                            
                        case .trackMap:
                            VStack(spacing: 12) {
                                // TrackMapView()
                                OptimizedTrackMapView(circuitKey: String(appEnvironment.liveSessionState.sessionInfo?.meeting?.circuit.key ?? 0))
                                    .frame(height: 400)
                                
                                // Team radios view
                                TeamRadiosView()
                                    .frame(maxHeight: 200)
                                
                                // Compact info below map
                                HStack {
                                    CompactWeatherView()
                                    Spacer()
                                }
                            }
                            .padding()
                        }
                    }
                    .navigationTitle(selectedTab.rawValue)
//                    .navigationBarTitleDisplayMode(.inline)
                } else {
                    Text("Select a section from the sidebar")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.platformSecondaryBackground)
    }
}

struct DashboardHeader: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
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
            
            // Compact weather info
            CompactHeaderWeatherView()
            
            Spacer()
            
            // Connection status
            ConnectionStatusIndicator()
            
            // Settings button
            #if os(macOS)
            SettingsLink {
                Image(systemName: "gear")
                    .font(.callout)
            }
            .buttonStyle(.plain)
            #else
            Button {
                // For iOS, we could navigate to settings or show a sheet
            } label: {
                Image(systemName: "gear")
                    .font(.callout)
            }
            .buttonStyle(.plain)
            #endif
        }
        .padding()
        .background(Color.platformBackground)
    }
}

struct ConnectionStatusIndicator: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
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
        .background(Color.platformBackground.opacity(0.5))
        .clipShape(Capsule())
    }
}

// MARK: - Popover Dashboard (Compact)

struct PopoverDashboardView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        VStack(spacing: 0) {
            // Compact header
            HStack(spacing: 8) {
                Image(systemName: "flag.checkered.circle.fill")
                    .foregroundStyle(.red)
                    .font(.title3)
                
                Text("F1 Dash")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                // Mini connection status
                HStack(spacing: 4) {
                    Circle()
                        .fill(appEnvironment.connectionStatus.color)
                        .frame(width: 6, height: 6)
                    
                    Text(appEnvironment.connectionStatus.statusText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.platformBackground)
            
            // Content based on connection status
            if appEnvironment.connectionStatus == .connected {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        // Quick stats row
                        HStack(spacing: 12) {
                            // Weather icon + temp
                            HStack(spacing: 4) {
                                Image(systemName: "thermometer.medium")
                                    .foregroundStyle(.orange)
                                Text("24°C")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                            
                            // Session type
                            Text("Practice 1")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                        
                        // Compact driver list (top 5)
                        VStack(spacing: 2) {
                            ForEach(0..<5, id: \.self) { index in
                                HStack(spacing: 8) {
                                    Text("\(index + 1)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 20, alignment: .leading)
                                    
                                    Text("VER")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .frame(width: 30, alignment: .leading)
                                    
                                    Text("Max Verstappen")
                                        .font(.caption)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    Text("1:23.456")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .frame(height: 180)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: appEnvironment.connectionStatus == .connecting ? "wifi.exclamationmark" : "wifi.slash")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    Text(appEnvironment.connectionStatus == .connecting ? "Connecting..." : "Not Connected")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if appEnvironment.connectionStatus == .connecting {
                        Text("Connecting to F1 timing server")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Connect to view live timing")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if !appEnvironment.settingsStore.autoConnect {
                            Button("Connect") {
                                Task {
                                    await appEnvironment.connect()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        } else {
                            Button("Retry Connection") {
                                Task {
                                    await appEnvironment.connect()
                                }
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                }
                .frame(height: 140)
                .padding()
            }
            
            // Compact footer
            HStack(spacing: 0) {
                #if os(macOS)
                SettingsLink {
                    HStack(spacing: 4) {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .background(Color.platformBackground.opacity(0.5))
                #else
                Button(action: {
                    // iOS settings handling can be added here if needed
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .background(Color.platformBackground.opacity(0.5))
                #endif
                
                Divider()
                    .frame(height: 20)
                
                Button(action: {
                    #if os(macOS)
                    NSApp.sendAction(#selector(AppDelegate.showDashboard), to: nil, from: nil)
                    #endif
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "rectangle.expand.vertical")
                        Text("Dashboard")
                    }
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .background(Color.platformBackground.opacity(0.5))
            }
            .background(Color.platformBackground)
        }
        .frame(width: 280, height: 240)
        .background(Color.platformSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
