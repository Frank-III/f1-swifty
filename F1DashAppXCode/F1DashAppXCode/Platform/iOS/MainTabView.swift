//
//  MainTabView.swift
//  F1-Dash
//
//  Main tab view for iOS/iPadOS and macOS
//

import SwiftUI
import F1DashModels

enum DashboardSection: String, CaseIterable {
    case all = "All"
    case trackMap = "Track Map"
    case liveTiming = "Live Timing"
    case raceControl = "Race Control"
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .trackMap: return "map"
        case .liveTiming: return "speedometer"
        case .raceControl: return "flag.2.crossed"
        }
    }
}

public struct MainTabView: View {
    public init() {}
    @Environment(AppEnvironment.self) private var appEnvironment
    @State private var selectedTab = 0
    @State private var showWeatherSheet = false
    @State private var showTrackMapFullScreen = false
    @State private var selectedDashboardSection: DashboardSection = .all
    
    public var body: some View {
        Group {
            #if os(macOS)
            // For macOS, use NavigationSplitView
            NavigationSplitView {
                List(selection: $selectedTab) {
                    Label("Dashboard", systemImage: "speedometer")
                        .tag(0)
                    
                    Label("Standings", systemImage: "list.number")
                        .tag(1)
                    
                    Label("Schedule", systemImage: "calendar")
                        .tag(2)
                    
                    Label("Settings", systemImage: "gear")
                        .tag(3)
                }
                .navigationTitle("F1 Dash")
                .frame(minWidth: 180, idealWidth: 220)
            } detail: {
                ZStack {
                    switch selectedTab {
                    case 0:
                        UniversalDashboardView(
                            selectedSection: $selectedDashboardSection,
                            showWeatherSheet: $showWeatherSheet,
                            showTrackMapFullScreen: $showTrackMapFullScreen
                        )
                    case 1:
                        StandingsView()
                    case 2:
                        ScheduleView()
                    case 3:
                        SettingsView()
                    default:
                        Text("Select a view")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            #else
            // For iOS, use TabView
            TabView(selection: $selectedTab) {
                UniversalDashboardView(
                    selectedSection: $selectedDashboardSection,
                    showWeatherSheet: $showWeatherSheet,
                    showTrackMapFullScreen: $showTrackMapFullScreen
                )
                .tabItem {
                    Label("Dashboard", systemImage: "speedometer")
                }
                .tag(0)
                
                StandingsView()
                    .tabItem {
                        Label("Standings", systemImage: "list.number")
                    }
                    .tag(1)
                
                ScheduleView()
                    .tabItem {
                        Label("Schedule", systemImage: "calendar")
                    }
                    .tag(2)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(3)
            }
            #endif
        }
        .modifier(iOS26TabAccessoryModifier(
            appEnvironment: appEnvironment,
            selectedTab: $selectedTab,
            showWeatherSheet: $showWeatherSheet,
            showTrackMapFullScreen: $showTrackMapFullScreen,
            selectedDashboardSection: $selectedDashboardSection
        ))
//        .modifier(PlatformTabBarModifier())
        .task {
            // Auto-connect when view appears
            if appEnvironment.connectionStatus == .disconnected {
                await appEnvironment.connect()
            }
        }
        .sheet(isPresented: $showWeatherSheet) {
            WeatherSheetView()
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $showTrackMapFullScreen) {
            NavigationStack {
                TrackMapView()
                    .navigationTitle("Track Map")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") {
                                showTrackMapFullScreen = false
                            }
                        }
                    }
            }
        }
        #else
        .sheet(isPresented: $showTrackMapFullScreen) {
            TrackMapView()
                .frame(minWidth: 600, minHeight: 400)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") {
                            showTrackMapFullScreen = false
                        }
                    }
                }
        }
        #endif
    }
}

// MARK: - Universal Dashboard View

struct UniversalDashboardView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    @Binding var selectedSection: DashboardSection
    @Binding var showWeatherSheet: Bool
    @Binding var showTrackMapFullScreen: Bool
    @State private var showRacePredictionSheet = false
    
    private var dashboardBackgroundColor: Color {
        // Apply safety car colors to dashboard background if enabled
        if appEnvironment.settingsStore.useSafetyCarColors,
           let status = appEnvironment.liveSessionState.trackStatus?.status,
           (status == .scYellow || status == .scRed || status == .vsc) {
            return (Color(hex: status.color) ?? Color.clear).opacity(0.05)
        }
        return Color.clear
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Combined header with connection, session info, and track status
                UnifiedHeaderView()
                
                // Main scrollable content
                ScrollView {
                    VStack(spacing: 16) {
                        // Track Map - full width
                        if selectedSection == .all || selectedSection == .trackMap {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Track Map")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    
                                    #if !os(macOS)
                                    // Picture in Picture button
                                    Button {
                                        appEnvironment.pictureInPictureManager.togglePiP()
                                    } label: {
                                        Image(systemName: appEnvironment.pictureInPictureManager.isPiPActive ? "pip.exit" : "pip.enter")
                                            .foregroundStyle(.secondary)
                                    }
                                    .buttonStyle(PlatformGlassButtonStyle())
                                    #endif
                                    
                                    // Full screen button
                                    Button {
                                        showTrackMapFullScreen = true
                                    } label: {
                                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                                            .foregroundStyle(.secondary)
                                    }
                                    .buttonStyle(PlatformGlassButtonStyle())
                                }
                                
                                TrackMapView()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 300)
                            }
                            .padding()
                            .modifier(PlatformGlassCardModifier())
                        }
                        
                        // Weather view integrated into dashboard
                        if selectedSection == .all {
                            WeatherView()
                                .modifier(PlatformGlassCardModifier())
                        }
                        
                        // Driver timing with fixed height for proper scrolling
                        if selectedSection == .all || selectedSection == .liveTiming {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Live Timing")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                
                                // Fixed height for driver list to enable internal scrolling
                                DriverListView()
                                    .frame(height: 400)
                            }
                            .padding()
                            .modifier(PlatformGlassCardModifier())
                        }
                        
                        // Race control with improved layout
                        if selectedSection == .all || selectedSection == .raceControl {
                            RaceControlView()
                                .modifier(PlatformGlassCardModifier())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .modifier(PlatformEnhancedScrollingModifier())
            }
            .background(dashboardBackgroundColor)
            .navigationTitle("F1 Dashboard")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    // Race prediction button (if we have prediction data)
                    if appEnvironment.liveSessionState.championshipPrediction != nil {
                        Button {
                            showRacePredictionSheet = true
                        } label: {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showRacePredictionSheet) {
            RacePredictionSheetView()
        }
    }
}

// MARK: - Unified Header View

// Simple flag view
struct TrackFlagView: View {
    let status: TrackFlag
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(hex: status.color) ?? Color.gray)
            .overlay(
                Group {
                    if status == .chequered {
                        // Simplified checkered pattern
                        HStack(spacing: 2) {
                            ForEach(0..<4, id: \.self) { _ in
                                VStack(spacing: 2) {
                                    ForEach(0..<3, id: \.self) { i in
                                        Rectangle()
                                            .fill(i % 2 == 0 ? Color.black : Color.white)
                                            .frame(width: 5, height: 5)
                                    }
                                }
                            }
                        }
                    } else if status == .scYellow || status == .scRed {
                        Text("SC")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    } else if status == .vsc {
                        Text("VSC")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            )
    }
}

struct UnifiedHeaderView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    private var headerBackgroundColor: Color {
        // Apply safety car colors to header if enabled
        if appEnvironment.settingsStore.useSafetyCarColors,
           let status = appEnvironment.liveSessionState.trackStatus?.status,
           (status == .scYellow || status == .scRed || status == .vsc) {
            return (Color(hex: status.color) ?? Color.clear).opacity(0.15)
        }
        return Color.clear
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Connection status bar
            HStack {
                // Connection status
                HStack(spacing: 6) {
                    Circle()
                        .fill(appEnvironment.connectionStatus.color)
                        .frame(width: 8, height: 8)
                    
                    Text(appEnvironment.connectionStatus.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Data delay indicator
                if appEnvironment.settingsStore.hasDataDelay {
                    Label(appEnvironment.settingsStore.formattedDelay, systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Connect/Disconnect button
                if appEnvironment.connectionStatus == .disconnected {
                    Button("Connect") {
                        Task {
                            await appEnvironment.connect()
                        }
                    }
                    .buttonStyle(PlatformGlassButtonStyle())
                    .controlSize(.small)
                } else {
                    Button {
                        Task {
                            await appEnvironment.disconnect()
                        }
                    } label: {
                        Image(systemName: "xmark.circle")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .controlSize(.small)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Session info and track status in one row
            if appEnvironment.connectionStatus == .connected {
                HStack(spacing: 16) {
                    // Session info
                    if let session = appEnvironment.liveSessionState.sessionInfo {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.meeting?.name ?? "Unknown Session")
                                .font(.headline)
                            Text(session.name ?? "Session")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        // Track status
                        if let trackStatus = appEnvironment.liveSessionState.trackStatus {
                            HStack(spacing: 8) {
                                TrackFlagView(status: trackStatus.status)
                                    .frame(width: 30, height: 20)
                                
                                Text(trackStatus.message)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                    } else {
                        Text("No Active Session")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .background(headerBackgroundColor)
        .modifier(PlatformGlassHeaderModifier())
    }
}


// MARK: - Platform 26+ Enhancement Modifiers and Styles

/// Liquid Glass card modifier for iOS/macOS 26+ with fallback
struct PlatformGlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 26, *) {
            content
                .background(Color(uiColor: .systemBackground))
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12), isEnabled: true)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            content
                .background(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        }
        #elseif os(macOS)
        if #available(macOS 26, *) {
            content
                .background(Color(nsColor: .controlBackgroundColor))
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12), isEnabled: true)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            content
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        }
        #else
        content
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        #endif
    }
}

/// Liquid Glass button style for iOS/macOS 26+ with fallback
struct PlatformGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        #if os(iOS) || os(macOS)
        if #available(iOS 26, macOS 26, *) {
            configuration.label
                .buttonStyle(.glass)
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        } else {
            fallbackButtonStyle(configuration: configuration)
        }
        #else
        fallbackButtonStyle(configuration: configuration)
        #endif
    }
    
    private func fallbackButtonStyle(configuration: Configuration) -> some View {
        #if os(macOS)
        configuration.label
            .buttonStyle(.borderedProminent)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        #else
        configuration.label
            .padding(8)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        #endif
    }
}

/// Enhanced scrolling modifier for iOS/macOS 26+ with fallback
struct PlatformEnhancedScrollingModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS) || os(macOS)
        if #available(iOS 26, macOS 26, *) {
            content
                .backgroundExtensionEffect()
        } else {
            content
        }
        #else
        content
        #endif
    }
}

/// Tab bar enhancement modifier for iOS 26+ with fallback
struct PlatformTabBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 26, *) {
            content
                .tabBarMinimizeBehavior(.automatic)
        } else {
            content
        }
        #else
        content
        #endif
    }
}

/// Glass header modifier for iOS/macOS 26+ with fallback  
struct PlatformGlassHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 26, *) {
            content
                .background(.ultraThinMaterial)
                .glassEffect(.regular, in: Rectangle(), isEnabled: true)
        } else {
            content
                .background(Color(uiColor: .systemBackground))
        }
        #elseif os(macOS)
        if #available(macOS 26, *) {
            content
                .background(.ultraThinMaterial)
                .glassEffect(.regular, in: Rectangle(), isEnabled: true)
        } else {
            content
                .background(Color(nsColor: .windowBackgroundColor))
        }
        #else
        content
            .background(Color.clear)
        #endif
    }
}

// MARK: - iOS 26+ Tab Accessory Modifier

struct iOS26TabAccessoryModifier: ViewModifier {
    let appEnvironment: AppEnvironment
    @Binding var selectedTab: Int
    @Binding var showWeatherSheet: Bool
    @Binding var showTrackMapFullScreen: Bool
    @Binding var selectedDashboardSection: DashboardSection
    
    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 26, *) {
            content
                .tabViewBottomAccessory {
                    // TODO: some bugs in iOS26
//                    if appEnvironment.connectionStatus != .disconnected && selectedTab == 0 {
                        DashboardSectionPills(
                          selectedSection: $selectedDashboardSection,
                            showTrackMapFullScreen: $showTrackMapFullScreen
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
//                    }
                }
                .tabBarMinimizeBehavior(.never)
                .tabViewStyle(.sidebarAdaptable)
        } else {
            content
        }
        #else
        content
        #endif
    }
}

#Preview {
    MainTabView()
        .environment(AppEnvironment())
}
