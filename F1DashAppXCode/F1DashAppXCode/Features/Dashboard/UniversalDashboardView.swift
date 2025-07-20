//
//  UniversalDashboardView.swift
//  F1-Dash
//
//  Universal dashboard view for iOS/iPadOS and macOS
//

import SwiftUI
import F1DashModels

struct UniversalDashboardView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @Binding var selectedSection: DashboardSection
    @Binding var showWeatherSheet: Bool
    @Binding var showTrackMapFullScreen: Bool
    @State private var showRacePredictionSheet = false
    @State var layoutManager: DashboardLayoutManager
    @State private var trackImageService = TrackImageService.shared
    @Namespace private var animation
    
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
        ZStack {
            // Background with track image
            backgroundView
            
            dashboardContent
                .background(dashboardBackgroundColor)
        }
        #if !os(macOS)
        .navigationTitle("F1 Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            DashboardToolbar(
                layoutManager: layoutManager,
                showRacePredictionSheet: $showRacePredictionSheet,
                sessionSubtitle: sessionSubtitle
            )
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: layoutManager.isEditMode)
        .sheet(isPresented: $showRacePredictionSheet) {
            RacePredictionSheetView()
        }
    }
    
    @ViewBuilder
    private var dashboardContent: some View {
        ZStack {
            if layoutManager.isEditMode {
                // Edit mode - minimal list with fade in animation
                VStack(spacing: 0) {
                    // Edit mode header
                    HStack {
                        Label("Edit Layout", systemImage: "pencil")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("Drag to reorder")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.regularMaterial)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    
                    #if os(macOS)
                    // Try alternative approach for debugging
                    MacOSAlternativeEditView(layoutManager: layoutManager)
                    // MacOSEditableDashboardView(layoutManager: layoutManager)
                    #else
                    EditableDashboardView(layoutManager: layoutManager)
                    #endif
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95)),
                    removal: .opacity.combined(with: .scale(scale: 1.05))
                ))
            } else {
                // Normal mode - full dashboard with fade out animation
                let sectionBuilder = DashboardSectionBuilder(
                    layoutManager: layoutManager,
                    showTrackMapFullScreen: $showTrackMapFullScreen
                )
                
                Group {
                    if selectedSection == .all {
                        ScrollView {
                            VStack(spacing: 12) {
                                // Show all sections normally
                                ForEach(layoutManager.sections) { section in
                                    if section.isVisible && shouldShowSection(section.type) {
                                        sectionBuilder.buildSection(for: section.type)
                                            .matchedGeometryEffect(
                                                id: section.id,
                                                in: animation,
                                                properties: .position
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                        }
                    } else if selectedSection == .liveTiming {
                        // Live timing needs special handling to fill the screen
                        buildExpandedSection(for: .liveTiming, fullScreen: true)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Other sections can be in a ScrollView
                        ScrollView {
                            VStack(spacing: 12) {
                                if let sectionType = dashboardSectionTypeFromSelection(selectedSection) {
                                    buildExpandedSection(for: sectionType, fullScreen: true)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                            }
                        }
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 1.05)),
                    removal: .opacity.combined(with: .scale(scale: 0.95))
                ))
            }
        }
    }
    
    private var sessionSubtitle: String {
        if let session = appEnvironment.liveSessionState.sessionInfo {
            return "\(session.meeting?.name ?? "Unknown") - \(session.name ?? "Session")"
        }
        return "No Active Session"
    }
    
    private func shouldShowSection(_ type: DashboardSectionType) -> Bool {
        switch selectedSection {
        case .all:
            return true
        case .weather:
            return type == .trackMap
        case .trackMap:
            return type == .trackMap
        case .liveTiming:
            return type == .liveTiming
        case .raceControl:
            return type == .raceControl
        }
    }
    
    private func dashboardSectionTypeFromSelection(_ selection: DashboardSection) -> DashboardSectionType? {
        switch selection {
        case .all:
            return nil
        case .weather:
            return .weather
        case .trackMap:
            return .trackMap
        case .liveTiming:
            return .liveTiming
        case .raceControl:
            return .raceControl
        }
    }
    
    @ViewBuilder
  private func buildExpandedSection(for type: DashboardSectionType, fullScreen: Bool = false) -> some View {
        switch type {
        case .weather:
          VStack(spacing: 12) {
            WeatherView()
              .modifier(PlatformGlassCardModifier())
            WindMapCard()
              .modifier(PlatformGlassCardModifier())
          }
          .padding()
                
        case .trackMap:
          VStack {
            TrackMapSection(showTrackMapFullScreen: $showTrackMapFullScreen)
            ScrollView {
                TeamRadiosView()
              }
            }
            .padding()
//            .modifier(PlatformGlassCardModifier())
            
            
        case .liveTiming:
            LiveTimingSection(shouldExpand: true)
//            .modifier(PlatformGlassCardModifier())
            
        case .raceControl:
            VStack(alignment: .leading, spacing: 12) {
                Label("Race Control", systemImage: "flag.2.crossed")
                    .font(.headline)
                    .padding(.horizontal)
                
                if appEnvironment.connectionStatus == .disconnected {
                    DisconnectedStateView(
                        title: "Race Control Not Available",
                        message: "Connect to live session to view messages",
                        iconName: "flag.2.crossed.fill",
                        minHeight: 100
                    )
                } else if let messages = appEnvironment.liveSessionState.raceControlMessages?.messages, !messages.isEmpty {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(messages.sorted(by: { $0.utc > $1.utc }), id: \.utc) { message in
                                RaceControlMessageRow(message: message)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ContentUnavailableView(
                        "No Messages",
                        systemImage: "flag.2.crossed",
                        description: Text("No race control messages at this time")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
            .modifier(PlatformGlassCardModifier())
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if appEnvironment.connectionStatus == .connected,
           appEnvironment.liveSessionState.sessionInfo?.meeting?.country.name != nil {
            // Use real MapKit background
            MapKitBackground()
                .transition(.opacity.animation(.easeInOut(duration: 0.8)))
        } else if let countryName = appEnvironment.liveSessionState.sessionInfo?.meeting?.country.name {
            // Fallback gradient while not connected
            trackImageService.placeholderGradient(for: countryName)
                .ignoresSafeArea()
                .blur(radius: 10)
                .overlay(
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                )
        }
    }
    
}

#Preview {
  @Previewable @State var selectedSection = DashboardSection.all
  @Previewable @State var showWeatherSheet = false
  @Previewable @State var showTrackMapFullScreen = false
    
    return UniversalDashboardView(
        selectedSection: $selectedSection,
        showWeatherSheet: $showWeatherSheet,
        showTrackMapFullScreen: $showTrackMapFullScreen,
        layoutManager: DashboardLayoutManager()
    )
    .environment(AppEnvironment())
}
