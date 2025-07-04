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
            iOSDashboardView()
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
        .modifier(PlatformTabBarModifier())
        .task {
            // Auto-connect when view appears
            if appEnvironment.connectionStatus == .disconnected {
                await appEnvironment.connect()
            }
        }
    }
}

// MARK: - iOS Dashboard View

struct iOSDashboardView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Connection status header
                ConnectionStatusHeader()
                
                // Single scrollable content with all important info
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Track Map - most critical for visual race understanding
                        VStack(spacing: 12) {
                            HStack {
                                Text("Track Map")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                                
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
                        
                        // Track status - current race state
                        TrackStatusView()
                            .modifier(PlatformGlassCardModifier())
                        
                        // Session info card
                        VStack(spacing: 12) {
                            HStack {
                                Text("Session")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            SessionInfoView()
                        }
                        .padding()
                        .modifier(PlatformGlassCardModifier())
                        
                        // Driver timing - main content
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
                        
                        // Latest race control message
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
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .modifier(PlatformEnhancedScrollingModifier())
            }
            .navigationTitle("F1 Dashboard")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .task {
            // Auto-connect when view appears
            if appEnvironment.connectionStatus == .disconnected {
                await appEnvironment.connect()
            }
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


// MARK: - Weather View Placeholder

struct WeatherViewPlaceholder: View {
    var body: some View {
        NavigationStack {
            Text("Weather - Coming Soon")
                .navigationTitle("Weather")
        }
    }
}

// MARK: - Platform 26+ Enhancement Modifiers and Styles

/// Liquid Glass card modifier for iOS/macOS 26+ with fallback
struct PlatformGlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS) || os(macOS)
        if #available(iOS 26, macOS 26, *) {
            content
                .background(Color.platformBackground)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12), isEnabled: true)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            content
                .background(Color.platformBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        }
        #else
        content
            .background(Color.platformBackground)
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
        #if os(iOS) || os(macOS)
        if #available(iOS 26, macOS 26, *) {
            content
                .background(.ultraThinMaterial)
                .glassEffect(.regular, in: Rectangle(), isEnabled: true)
        } else {
            content
                .background(Color.platformBackground)
        }
        #else
        content
            .background(Color.platformBackground)
        #endif
    }
}

#Preview {
    MainTabView()
        .environment(AppEnvironment())
}
