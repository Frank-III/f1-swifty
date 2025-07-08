//
//  UniversalDashboardView.swift
//  F1-Dash
//
//  Universal dashboard view for iOS/iPadOS and macOS
//

import SwiftUI
import F1DashModels

struct UniversalDashboardView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    @Binding var selectedSection: DashboardSection
    @Binding var showWeatherSheet: Bool
    @Binding var showTrackMapFullScreen: Bool
    @State private var showRacePredictionSheet = false
    @State private var layoutManager = DashboardLayoutManager()
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
        NavigationStack {
            dashboardContent
                .background(dashboardBackgroundColor)
                #if !os(macOS)
                .navigationTitle("F1 Dashboard")
                .navigationBarTitleDisplayMode(.large)
                #endif
                .toolbar {
                    DashboardToolbar(
                        layoutManager: layoutManager,
                        showRacePredictionSheet: $showRacePredictionSheet,
                        sessionSubtitle: sessionSubtitle
                    )
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: layoutManager.isEditMode)
        }
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
                
                ScrollView {
                    VStack(spacing: 16) {
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
                    .padding(.bottom)
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
        case .trackMap:
            return type == .trackMap
        case .liveTiming:
            return type == .liveTiming
        case .raceControl:
            return type == .raceControl
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
        showTrackMapFullScreen: $showTrackMapFullScreen
    )
    .environment(AppEnvironment())
}
