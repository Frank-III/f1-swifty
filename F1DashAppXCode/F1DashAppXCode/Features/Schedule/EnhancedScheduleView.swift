//
//  EnhancedScheduleView.swift
//  F1-Dash
//
//  Enhanced schedule view with map and list
//

import SwiftUI
import F1DashModels

struct EnhancedScheduleView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @State private var selectedRace: RaceRound?
    @State private var preferences = RacePreferences()
    @State private var showSidebar = true
    @State private var showRaceList = false
    @State private var rotationAngle: Double = 0
    @State private var currentWidth: CGFloat = 0
    
    var body: some View {
        #if os(iOS)
        // iOS: NavigationStack with proper toolbar
        NavigationStack {
          if #available(iOS 26.0, *) {
            scheduleContent
              .safeAreaBar(edge: .top) {
                NextRaceInfoView()
                  .padding(.horizontal)
                  .padding(.vertical, 8)
              }
          } else {
            scheduleContent
              .safeAreaInset(edge: .top) {
                NextRaceInfoView()
                  .padding(.horizontal)
                  .padding(.vertical, 8)
              }
          }

        }
        .navigationTitle("Race Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 12) {
                        Button {
                            showRaceList = true
                        } label: {
                            Image(systemName: "list.bullet")
                        }
                        
                        // Sidebar toggle button for iPad
                        if shouldShowToggleButton(width: currentWidth) {
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    showSidebar.toggle()
                                }
                            } label: {
                                Image(systemName: showSidebar ? "sidebar.left" : "sidebar.right")
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 8) {
                        // Status indicator
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                            .overlay(
                                Circle()
                                    .stroke(statusColor.opacity(0.3), lineWidth: 2)
                            )
                            .animation(.easeInOut(duration: 0.3), value: statusColor)
                        
                        Button {
                            Task {
                                await appEnvironment.fetchSchedule()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .rotationEffect(.degrees(rotationAngle))
                        }
                        .disabled(appEnvironment.scheduleLoadingStatus.isLoading)
                    }
                }
            }
        .task {
            if appEnvironment.schedule.isEmpty {
                await appEnvironment.fetchSchedule()
            }
        }
        .sheet(isPresented: $showRaceList) {
            RaceListSheet(
                races: appEnvironment.schedule,
                selectedRace: $selectedRace,
                preferences: preferences
            )
        }
        .onChange(of: appEnvironment.scheduleLoadingStatus) { _, newStatus in
            if case .loading = newStatus {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
            } else {
                withAnimation(.easeOut(duration: 0.3)) {
                    rotationAngle = 0
                }
            }
        }
        #else
        // macOS: NavigationStack with transparent toolbar
        NavigationStack {
            VStack(spacing: 0) {
                // Next race info header
                NextRaceInfoView()
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                Divider()
                
                ZStack {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                        // Race list - show/hide based on width
                        if showSidebar && shouldShowSidebar(width: geometry.size.width) {
                            EnhancedRaceListView(
                                races: appEnvironment.schedule,
                                selectedRace: $selectedRace
                            )
                            .padding(.top, 5)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                            
                            Divider()
                        }
                        
                        // Map - always visible
                        ZStack(alignment: .topLeading) {
                            EnhancedRaceMapView(
                                races: appEnvironment.schedule,
                                selectedRace: $selectedRace
                            )
                            
                            // Toggle button for sidebar
                            if shouldShowToggleButton(width: geometry.size.width) {
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        showSidebar.toggle()
                                    }
                                } label: {
                                    Image(systemName: showSidebar ? "sidebar.left" : "sidebar.right")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.primary)
                                        .padding(10)
                                        .background(.regularMaterial)
                                        .clipShape(Circle())
                                        .shadow(radius: 2)
                                }
                                .buttonStyle(PlatformGlassButtonStyle())
                                .padding()
                            }
                        }
                    }
                    .ignoresSafeArea(edges: .top)
                    .onAppear {
                        // Auto-hide sidebar on small screens
                        showSidebar = shouldShowSidebar(width: geometry.size.width)
                    }
                    .onChange(of: geometry.size.width) { _, newWidth in
                        // Auto-show/hide sidebar based on width
                        if newWidth < 600 && showSidebar {
                            withAnimation {
                                showSidebar = false
                            }
                        } else if newWidth > 900 && !showSidebar {
                            withAnimation {
                                showSidebar = true
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Race Schedule")
        #if os(macOS)
            .toolbarBackground(.ultraThinMaterial, for: .windowToolbar)
            .toolbarBackground(.visible, for: .windowToolbar)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 8) {
                        // Status indicator
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                            .overlay(
                                Circle()
                                    .stroke(statusColor.opacity(0.3), lineWidth: 2)
                            )
                            .animation(.easeInOut(duration: 0.3), value: statusColor)
                        
                        Button {
                            Task {
                                await appEnvironment.fetchSchedule()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .rotationEffect(.degrees(rotationAngle))
                        }
                        .disabled(appEnvironment.scheduleLoadingStatus.isLoading)
                    }
                }
            }
        .task {
            if appEnvironment.schedule.isEmpty {
                await appEnvironment.fetchSchedule()
            }
        }
        .sheet(isPresented: $showRaceList) {
            RaceListSheet(
                races: appEnvironment.schedule,
                selectedRace: $selectedRace,
                preferences: preferences
            )
        }
        .onChange(of: appEnvironment.scheduleLoadingStatus) { _, newStatus in
            if case .loading = newStatus {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
            } else {
                withAnimation(.easeOut(duration: 0.3)) {
                    rotationAngle = 0
                }
            }
        }
        }
        #endif
    }
  
  @ViewBuilder
  private var scheduleContent: some View {
    GeometryReader { geometry in
        HStack(spacing: 0) {
        // Race list - show/hide based on width
        if showSidebar && shouldShowSidebar(width: geometry.size.width) {
            EnhancedRaceListView(
                races: appEnvironment.schedule,
                selectedRace: $selectedRace
            )
            .transition(.move(edge: .leading).combined(with: .opacity))
            
            Divider()
        }
        
        // Map - always visible
        EnhancedRaceMapView(
            races: appEnvironment.schedule,
            selectedRace: $selectedRace
        )
        }
        .onAppear {
            // Auto-hide sidebar on small screens
            currentWidth = geometry.size.width
            showSidebar = shouldShowSidebar(width: geometry.size.width)
        }
        .onChange(of: geometry.size.width) { _, newWidth in
            currentWidth = newWidth
            // For iOS/iPadOS, handle orientation changes
          #if !os(macOS)
          if UIDevice.current.userInterfaceIdiom == .pad {
                let shouldShow = shouldShowSidebar(width: newWidth)
                if shouldShow != showSidebar {
                    withAnimation {
                        showSidebar = shouldShow
                    }
                }
            }
          #endif
        }
    }
    .ignoresSafeArea()
  }
    
    private var statusColor: Color {
        switch appEnvironment.scheduleLoadingStatus {
        case .loading:
            return .orange
        case .error:
            return .red
        default:
            return .green
        }
    }
    
    private func shouldShowSidebar(width: CGFloat) -> Bool {
        #if os(macOS)
        return width > 600  // Hide sidebar on very narrow windows
        #else
        // For iOS/iPadOS, check device and orientation
        if UIDevice.current.userInterfaceIdiom == .phone {
            return false  // Never show sidebar on iPhone
        } else {
            // iPad: show sidebar in landscape or on large iPads
            return width > 700  // Lower threshold for iPads
        }
        #endif
    }
    
    private func shouldShowToggleButton(width: CGFloat) -> Bool {
        #if os(macOS)
        return width > 600 && width < 900  // Show toggle in medium width range
        #else
        // Show toggle on iPad when sidebar could be shown but isn't
        if UIDevice.current.userInterfaceIdiom == .pad {
            return width > 600  // Show toggle on iPad when there's enough space
        }
        return false
        #endif
    }
}

struct RaceListSheet: View {
    let races: [RaceRound]
    @Binding var selectedRace: RaceRound?
    @Bindable var preferences: RacePreferences
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(races) { race in
                Button {
                    selectedRace = race
                    dismiss()
                } label: {
                    RaceListSheetRow(race: race, preferences: preferences)
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Race Schedule")
          #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
          #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct RaceListSheetRow: View {
    let race: RaceRound
    let preferences: RacePreferences
    
    private var raceId: String {
        race.preferenceId
    }
    
    private var isPast: Bool {
        race.end < Date()
    }
    
    private var raceColor: Color {
        RaceColorTheme.color(for: race.countryName, isActive: race.isActive, isPast: isPast)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Colored accent bar
            RoundedRectangle(cornerRadius: 4)
                .fill(raceColor)
                .frame(width: 4, height: 60)
                .opacity(isPast ? 0.5 : 1.0)
            
            // Race info
            VStack(alignment: .leading, spacing: 6) {
                Text(race.countryName)
                    .font(.headline)
                    .foregroundStyle(isPast ? .secondary : .primary)
                
                Text(race.name)
                    .font(.subheadline)
                    .foregroundStyle(isPast ? .tertiary : .secondary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    // Date
                    Label(race.formattedDateRange, systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(isPast ? .tertiary : .secondary)
                    
                    // Live indicator
                    if race.isActive {
                        Label("LIVE", systemImage: "dot.radiowaves.left.and.right")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                    }
                }
            }
            
            Spacer()
            
            // Indicators
            VStack(spacing: 4) {
                if preferences.isFavorite(raceId) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
                
                if preferences.hasNotification(raceId) {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(.blue)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 8)
    }
}


#Preview {
  EnhancedScheduleView()
    .environment(AppEnvironment())
}
