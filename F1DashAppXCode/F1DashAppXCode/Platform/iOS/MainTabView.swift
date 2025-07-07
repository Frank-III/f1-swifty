//
//  MainTabView.swift
//  F1-Dash
//
//  Main tab view for iOS/iPadOS
//

import SwiftUI

    enum DashboardSection: String, CaseIterable {
          case all = "All"
          case trackMap = "Track Map"
          case trackStatus = "Track Status"
          case session = "Session"
          case liveTiming = "Live Timing"
          case raceControl = "Race Control"
    
         var icon: String {
            switch self {
             case .all: return "square.grid.2x2"
             case .trackMap: return "map"
             case .trackStatus: return "flag.checkered"
             case .session: return "info.circle"
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
        TabView(selection: $selectedTab) {
            iOSDashboardView(selectedSection: $selectedDashboardSection)
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

// MARK: - iOS Dashboard View

struct iOSDashboardView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    @Binding var selectedSection: DashboardSection
    @State private var showWeatherSheet = false
    @State private var showRacePredictionSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Connection status header
                ConnectionStatusHeader()
                
                // Single scrollable content with all important info
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Track Map - most critical for visual race understanding
                        if selectedSection == .all || selectedSection == .trackMap {
                            VStack(spacing: 12) {
                            HStack {
                                Text("Track Map")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                                
                                // Picture in Picture button
                                Button {
                                    appEnvironment.pictureInPictureManager.togglePiP()
                                } label: {
                                    Image(systemName: appEnvironment.pictureInPictureManager.isPiPActive ? "pip.exit" : "pip.enter")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(PlatformGlassButtonStyle())
                                
                                // Quick navigation to dedicated full-screen map
                                NavigationLink(destination: TrackMapView()) {
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(PlatformGlassButtonStyle())
                            }
                            
                            TrackMapView()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 250)
                            }
                            .padding()
                            .modifier(PlatformGlassCardModifier())
                        }
                        
                        // Track status - current race state
                        if selectedSection == .all || selectedSection == .trackStatus {
                            TrackStatusView()
                                .modifier(PlatformGlassCardModifier())
                        }
                        
                        // Session info card with weather indicator
                        if selectedSection == .all || selectedSection == .session {
                            VStack(spacing: 12) {
                            HStack {
                                Text("Session")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                // Compact weather indicator
                                CompactWeatherView()
                                    .onTapGesture {
                                        showWeatherSheet = true
                                    }
                            }
                            
                            SessionInfoView()
                            }
                            .padding()
                            .modifier(PlatformGlassCardModifier())
                        }
                        
                        // Driver timing - main content
                        if selectedSection == .all || selectedSection == .liveTiming {
                            VStack(spacing: 12) {
                            HStack {
                                Text("Live Timing")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                                
                                // Quick navigation to other views
                                Menu("More") {
                                    NavigationLink(destination: RaceControlView()) {
                                        Label("Race Control", systemImage: "flag.2.crossed")
                                    }
                                }
                                .buttonStyle(PlatformGlassButtonStyle())
                            }
                            
                            DriverListView()
                            }
                            .padding()
                            .modifier(PlatformGlassCardModifier())
                        }
                        
                        // Latest race control message
                        if selectedSection == .all || selectedSection == .raceControl {
                            VStack(spacing: 12) {
                            HStack {
                                Text("Race Control")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            CompactRaceControlView()
                            }
                            .padding()
                            .modifier(PlatformGlassCardModifier())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .modifier(PlatformEnhancedScrollingModifier())
            }
            .navigationTitle("F1 Dashboard")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    // Weather button
                    Button {
                        showWeatherSheet = true
                    } label: {
                        Image(systemName: "cloud.sun")
                    }
                    
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
        .sheet(isPresented: $showWeatherSheet) {
            WeatherSheetView()
        }
        .sheet(isPresented: $showRacePredictionSheet) {
            RacePredictionSheetView()
        }
    }
}

struct ConnectionStatusHeader: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    var body: some View {
        HStack {
            HStack(spacing: 6) {
                Circle()
                    .fill(appEnvironment.connectionStatus.color)
                    .frame(width: 8, height: 8)
                
                Text(appEnvironment.connectionStatus.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if appEnvironment.connectionStatus == .disconnected {
                Button("Connect") {
                    Task {
                        await appEnvironment.connect()
                    }
                }
                .buttonStyle(PlatformGlassButtonStyle())
                .controlSize(.small)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
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
