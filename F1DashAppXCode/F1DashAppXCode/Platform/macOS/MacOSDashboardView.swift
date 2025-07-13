//
//  MacOSDashboardView.swift
//  F1-Dash
//
//  Enhanced macOS Dashboard with all features and macOS 26 design
//

import SwiftUI
import F1DashModels

#if os(macOS)
struct MacOSDashboardView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @State private var selectedSection: DashboardSection = .dashboard
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var showWeatherSheet = false
    @State private var showRacePredictionSheet = false
    
    enum DashboardSection: String, CaseIterable, Identifiable {
        case dashboard = "Dashboard"
        case schedule = "Schedule"
        case standings = "Standings"
        case trackMap = "Track Map"
        case weather = "Weather"
        case raceControl = "Race Control"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .dashboard: return "speedometer"
            case .schedule: return "calendar"
            case .standings: return "trophy"
            case .trackMap: return "map"
            case .weather: return "cloud.sun"
            case .raceControl: return "flag.2.crossed"
            }
        }
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            List(selection: $selectedSection) {
                Section("Live Data") {
                    ForEach([DashboardSection.dashboard, .trackMap, .weather, .raceControl], id: \.self) { section in
                        Label(section.rawValue, systemImage: section.icon)
                            .tag(section)
                    }
                }
                
                Section("Championship") {
                    ForEach([DashboardSection.schedule, .standings], id: \.self) { section in
                        Label(section.rawValue, systemImage: section.icon)
                            .tag(section)
                    }
                }
            }
            .navigationTitle("F1 Dash")
            .navigationSplitViewColumnWidth(min: 180, ideal: 220)
            .modifier(MacOS26SidebarModifier())
        } detail: {
            // Detail view
            ZStack {
              switch selectedSection {
              case .dashboard:
                MacOSDashboardContent()
              case .schedule:
                MacOSScheduleView()
              case .standings:
                MacOSStandingsView()
              case .trackMap:
                MacOSTrackMapView()
              case .weather:
                MacOSWeatherView()
              case .raceControl:
                MacOSRaceControlView()
              }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.platformSecondaryBackground)
        }
        .task {
            // Auto-connect and fetch data when view appears
            if appEnvironment.connectionStatus == .disconnected {
                await appEnvironment.connect()
            }
            if appEnvironment.schedule.isEmpty {
                await appEnvironment.fetchSchedule()
            }
        }
        .sheet(isPresented: $showWeatherSheet) {
            WeatherSheetView()
        }
        .sheet(isPresented: $showRacePredictionSheet) {
            RacePredictionSheetView()
        }
    }
}


// MARK: - Dashboard Content

struct MacOSDashboardContent: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @State private var showTrackMapFullScreen = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Connection Status Header
                    MacOSConnectionHeader()
                    
                    // Main content grid
                    if appEnvironment.connectionStatus == .connected {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            // Session Info & Track Status
                            VStack(spacing: 16) {
                                SessionInfoCard()
                                TrackStatusCard()
                            }
                            
                            // Track Map
                            TrackMapCard(showFullScreen: $showTrackMapFullScreen)
                                .aspectRatio(1.5, contentMode: .fit)
                        }
                        .padding(.horizontal)
                        
                        // Driver List
                        DriverListCard()
                            .padding(.horizontal)
                        
                        // Additional info row
                        HStack(spacing: 16) {
                            WeatherCard()
                            LatestRaceControlCard()
                        }
                        .padding(.horizontal)
                        
                        // Team Radio if available
                        if let teamRadio = appEnvironment.liveSessionState.teamRadio,
                           !teamRadio.captures.isEmpty {
                            TeamRadioCard()
                                .padding(.horizontal)
                        }
                    } else {
                        // Disconnected state
                        ConnectionPlaceholder()
                            .frame(height: 400)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .navigationSubtitle(sessionSubtitle)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    if appEnvironment.connectionStatus == .connected {
                        Button {
                            showTrackMapFullScreen = true
                        } label: {
                            Image(systemName: "map.fill")
                        }
                        .help("Full Screen Track Map")
                    }
                    
                    Button {
                        Task {
                            if appEnvironment.connectionStatus == .disconnected {
                                await appEnvironment.connect()
                            } else {
                                await appEnvironment.disconnect()
                            }
                        }
                    } label: {
                        Image(systemName: appEnvironment.connectionStatus == .connected ? "wifi" : "wifi.slash")
                    }
                    .help(appEnvironment.connectionStatus == .connected ? "Disconnect" : "Connect")
                }
            }
        }
        .sheet(isPresented: $showTrackMapFullScreen) {
            TrackMapFullScreenView()
        }
    }
    
    private var sessionSubtitle: String {
        if let session = appEnvironment.liveSessionState.sessionInfo {
            return "\(session.meeting?.name ?? "Unknown") - \(session.name ?? "Session")"
        }
        return "No Active Session"
    }
}

// MARK: - Component Cards

struct SessionInfoCard: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Session Info", systemImage: "info.circle")
                .font(.headline)
            
            SessionInfoView()
                .labelStyle(.iconOnly)
        }
        .modifier(MacOSCardModifier())
    }
}

struct TrackStatusCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Track Status", systemImage: "flag.checkered")
                .font(.headline)
            
            TrackStatusView()
        }
        .modifier(MacOSCardModifier())
    }
}

struct TrackMapCard: View {
    @Binding var showFullScreen: Bool
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Track Map", systemImage: "map")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    appEnvironment.pictureInPictureManager.togglePiP()
                } label: {
                    Image(systemName: appEnvironment.pictureInPictureManager.isPiPActive ? "pip.exit" : "pip.enter")
                }
                .buttonStyle(PlatformGlassButtonStyle())
                .help("Picture in Picture")
                
                Button {
                    showFullScreen = true
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                }
                .buttonStyle(PlatformGlassButtonStyle())
                .help("Full Screen")
            }
            
            // TrackMapView()
            OptimizedTrackMapView(circuitKey: String(appEnvironment.liveSessionState.sessionInfo?.meeting?.circuit.key ?? 0))
                .frame(height: 250)
        }
        .modifier(MacOSCardModifier())
    }
}

struct DriverListCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Live Timing", systemImage: "speedometer")
                .font(.headline)
            
            // DriverListView()
            OptimizedDriverListView()
                .frame(height: 400)
        }
        .modifier(MacOSCardModifier())
    }
}

struct WeatherCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Weather", systemImage: "cloud.sun")
                .font(.headline)
            
            CompactWeatherView()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .modifier(MacOSCardModifier())
    }
}

struct LatestRaceControlCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Race Control", systemImage: "flag.2.crossed")
                .font(.headline)
            
            CompactRaceControlView()
        }
        .modifier(MacOSCardModifier())
    }
}

struct TeamRadioCard: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Team Radio", systemImage: "radio")
                .font(.headline)
            
            TeamRadioView()
                .frame(height: 200)
        }
        .modifier(MacOSCardModifier())
    }
}

// MARK: - Enhanced Views for macOS

struct MacOSScheduleView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        NavigationStack {
            EnhancedScheduleView()
                .navigationTitle("Race Schedule")
                .navigationSubtitle(sessionSubtitle)
        }
    }
    
    private var sessionSubtitle: String {
        if let session = appEnvironment.liveSessionState.sessionInfo {
            return "\(session.meeting?.name ?? "Unknown") - \(session.name ?? "Session")"
        }
        return "No Active Session"
    }
}

struct MacOSStandingsView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        NavigationStack {
            ScrollView {
                StandingsView()
                    .padding()
            }
            .navigationTitle("Championship Standings")
            .navigationSubtitle(sessionSubtitle)
        }
    }
    
    private var sessionSubtitle: String {
        if let session = appEnvironment.liveSessionState.sessionInfo {
            return "\(session.meeting?.name ?? "Unknown") - \(session.name ?? "Session")"
        }
        return "No Active Session"
    }
}

struct MacOSTrackMapView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        NavigationStack {
            // TrackMapView()
            OptimizedTrackMapView(circuitKey: String(appEnvironment.liveSessionState.sessionInfo?.meeting?.circuit.key ?? 0))
                .padding()
            .navigationTitle("Track Map")
            .navigationSubtitle(sessionSubtitle)
        }
    }
    
    private var sessionSubtitle: String {
        if let session = appEnvironment.liveSessionState.sessionInfo {
            return "\(session.meeting?.name ?? "Unknown") - \(session.name ?? "Session")"
        }
        return "No Active Session"
    }
}

struct MacOSWeatherView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        NavigationStack {
            ScrollView {
                WeatherView()
                    .padding()
            }
            .navigationTitle("Weather")
            .navigationSubtitle(sessionSubtitle)
        }
    }
    
    private var sessionSubtitle: String {
        if let session = appEnvironment.liveSessionState.sessionInfo {
            return "\(session.meeting?.name ?? "Unknown") - \(session.name ?? "Session")"
        }
        return "No Active Session"
    }
}

struct MacOSRaceControlView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        NavigationStack {
            RaceControlView()
                .padding()
            .navigationTitle("Race Control")
            .navigationSubtitle(sessionSubtitle)
        }
    }
    
    private var sessionSubtitle: String {
        if let session = appEnvironment.liveSessionState.sessionInfo {
            return "\(session.meeting?.name ?? "Unknown") - \(session.name ?? "Session")"
        }
        return "No Active Session"
    }
}

// MARK: - Connection Components

struct MacOSConnectionHeader: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(appEnvironment.connectionStatus.color)
                    .frame(width: 10, height: 10)
                
                Text(appEnvironment.connectionStatus.description)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if appEnvironment.settingsStore.hasDataDelay {
                Label(appEnvironment.settingsStore.formattedDelay, systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
    }
}

struct ConnectionPlaceholder: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text("Not Connected")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Connect to F1 Dash server to view live timing data")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Connect") {
                Task {
                    await appEnvironment.connect()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: 400)
    }
}

// MARK: - Full Screen Views

struct TrackMapFullScreenView: View {
    @Environment(\.dismiss) private var dismiss
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        NavigationStack {
            // TrackMapView()
            OptimizedTrackMapView(circuitKey: String(appEnvironment.liveSessionState.sessionInfo?.meeting?.circuit.key ?? 0))
                .ignoresSafeArea()
                .navigationTitle("Track Map")
                .platformNavigationGlass()
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

// MARK: - Modifiers

struct MacOSCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.platformBackground)
            .modifier(PlatformGlassCardModifier())
    }
}

struct MacOS26SidebarModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(macOS)
        if #available(macOS 26, *) {
            content
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
                .background(.ultraThinMaterial)
        } else {
            content
                .listStyle(.sidebar)
        }
        #else
        content
        #endif
    }
}

#Preview {
    MacOSDashboardView()
        .environment(AppEnvironment())
        .frame(width: 1200, height: 800)
}
#endif
