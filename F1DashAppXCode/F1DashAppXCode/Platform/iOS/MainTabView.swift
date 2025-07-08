//
//  MainTabView.swift
//  F1-Dash
//
//  Main tab view for iOS/iPadOS and macOS
//

import SwiftUI
import F1DashModels
#if os(macOS)
import AppKit
#endif


public struct MainTabView: View {
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
                NavigationStack {
                    switch selectedTab {
                    case 0:
                        UniversalDashboardView(
                            selectedSection: $selectedDashboardSection,
                            showWeatherSheet: $showWeatherSheet,
                            showTrackMapFullScreen: $showTrackMapFullScreen
                        )
                        .navigationTitle("Dashboard")
                    case 1:
                        StandingsView()
                            .navigationTitle("Standings")
                    case 2:
                        ScheduleView()
                            .navigationTitle("Schedule")
                    case 3:
                        DashboardSettingsView()
                            .navigationTitle("Settings")
                    default:
                        Text("Select a view")
                            .navigationTitle("F1 Dash")
                    }
                }
                .platformNavigationGlass()
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
        .onAppear {
            #if os(macOS)
            appEnvironment.isDashboardWindowOpen = true
            // Auto-close settings window when dashboard opens
            closeSettingsWindow()
            #endif
        }
        .onDisappear {
            #if os(macOS)
            appEnvironment.isDashboardWindowOpen = false
            #endif
        }
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
    
    #if os(macOS)
    private func closeSettingsWindow() {
        // Find and close the settings window
        if let settingsWindow = NSApp.windows.first(where: { window in
            window.title == "Settings" || window.title == "Preferences"
        }) {
            settingsWindow.close()
        }
    }
    #endif
}

#Preview {
    MainTabView()
        .environment(AppEnvironment())
}
