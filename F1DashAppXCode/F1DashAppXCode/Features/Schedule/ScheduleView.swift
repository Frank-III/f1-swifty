//
//  ScheduleView.swift
//  F1-Dash
//
//  Race Schedule view showing upcoming and past races
//

import SwiftUI
import F1DashModels

struct ScheduleView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    @State private var selectedRace: RaceRound?
    @State private var showPastRaces = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Loading or error state
                    if appEnvironment.scheduleLoadingStatus.isLoading {
                        ProgressView("Loading schedule...")
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if case .error(let message) = appEnvironment.scheduleLoadingStatus {
                        ErrorView(message: message) {
                            Task {
                                await appEnvironment.fetchSchedule()
                            }
                        }
                        .padding()
                    } else {
                        // Next race highlight
                        if let nextRace = appEnvironment.nextRace {
                            NextRaceCard(race: nextRace)
                                .padding(.horizontal)
                                .padding(.top)
                        }
                        
                        // Upcoming races section
                        if !appEnvironment.upcomingRaces.isEmpty {
                            UpcomingRacesSection(races: appEnvironment.upcomingRaces)
                                .padding(.top, 24)
                        }
                        
                        // Past races section with progressive disclosure
                        PastRacesSection(
                            races: appEnvironment.schedule.filter { !$0.isUpcoming },
                            showPastRaces: $showPastRaces
                        )
                        .padding(.top, 24)
                    }
                }
                .padding(.bottom)
            }
            .modifier(PlatformEnhancedScrollingModifier())
            #if !os(macOS)
            .navigationTitle("Race Schedule")
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await appEnvironment.fetchSchedule()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(appEnvironment.scheduleLoadingStatus.isLoading)
                }
            }
            .sheet(item: $selectedRace) { race in
                RaceDetailView(race: race)
            }
            .refreshable {
                await appEnvironment.fetchSchedule()
            }
        }
        .task {
            // Fetch schedule if not already loaded
            if appEnvironment.schedule.isEmpty {
                await appEnvironment.fetchSchedule()
            }
        }
    }
}

// MARK: - Next Race Card

struct NextRaceCard: View {
    let race: RaceRound
    @State private var timeRemaining = ""
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with race name and location
            VStack(alignment: .leading, spacing: 4) {
                Text("NEXT RACE")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Text(race.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack {
                    Image(systemName: "location.fill")
                        .font(.caption)
                    Text(race.countryName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            // Race weekend dates
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                Text(race.formattedDateRange)
                    .font(.body)
                Spacer()
            }
            
            // Time until race
            if let raceSession = race.raceSession {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.secondary)
                    Text(timeRemaining.isEmpty ? "Calculating..." : timeRemaining)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    Spacer()
                }
                .onReceive(timer) { _ in
                    updateTimeRemaining(until: raceSession.start)
                }
                .onAppear {
                    updateTimeRemaining(until: raceSession.start)
                }
            }
            
            // Sessions preview
            VStack(alignment: .leading, spacing: 8) {
                Text("Sessions")
                    .font(.headline)
                    .padding(.top, 8)
                
                ForEach(race.sessions.prefix(3)) { session in
                    SessionRow(session: session, compact: true)
                }
                
                if race.sessions.count > 3 {
                    Text("+ \(race.sessions.count - 3) more sessions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color.accentColor.opacity(0.1))
        .modifier(PlatformGlassCardModifier())
    }
    
    private func updateTimeRemaining(until date: Date) {
        let interval = date.timeIntervalSinceNow
        if interval > 0 {
            let days = Int(interval) / 86400
            let hours = Int(interval) % 86400 / 3600
            let minutes = Int(interval) % 3600 / 60
            
            if days > 0 {
                timeRemaining = "\(days)d \(hours)h"
            } else if hours > 0 {
                timeRemaining = "\(hours)h \(minutes)m"
            } else {
                timeRemaining = "\(minutes)m"
            }
        } else {
            timeRemaining = "In Progress"
        }
    }
}

// MARK: - Upcoming Races Section

struct UpcomingRacesSection: View {
    let races: [RaceRound]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming Races")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(races) { race in
                        RaceCard(race: race)
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 16)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1.0 : 0.8)
                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.95)
                            }
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal)
            }
            .scrollTargetBehavior(.viewAligned)
        }
    }
}

// MARK: - Race Card

struct RaceCard: View {
    let race: RaceRound
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(race.name)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "location")
                        .font(.caption)
                    Text(race.countryName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            // Date
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(race.formattedDateRange)
                    .font(.caption)
            }
            
            // Race time if available
            if let raceSession = race.raceSession {
                HStack {
                    Image(systemName: "flag.checkered")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Race: \(raceSession.formattedDayTime)")
                        .font(.caption)
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 160)
        .modifier(PlatformGlassCardModifier())
    }
}

// MARK: - Past Races Section

struct PastRacesSection: View {
    let races: [RaceRound]
    @Binding var showPastRaces: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation {
                    showPastRaces.toggle()
                }
            } label: {
                HStack {
                    Text("Past Races")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Image(systemName: showPastRaces ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            
            if showPastRaces && !races.isEmpty {
                LazyVStack(spacing: 12) {
                    ForEach(races) { race in
                        PastRaceRow(race: race)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Past Race Row

struct PastRaceRow: View {
    let race: RaceRound
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(race.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                HStack {
                    Image(systemName: "location")
                        .font(.caption2)
                    Text(race.countryName)
                        .font(.caption)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(race.formattedDateRange)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.body)
        }
        .padding()
        .background(Color.platformBackground)
        .modifier(PlatformGlassCardModifier())
    }
}

// MARK: - Session Row

struct SessionRow: View {
    let session: RaceSession
    let compact: Bool
    
    var body: some View {
        HStack {
            Image(systemName: session.symbolName)
                .font(compact ? .caption : .body)
                .foregroundStyle(session.isActive ? .green : .secondary)
                .frame(width: 20)
            
            Text(session.kind)
                .font(compact ? .caption : .body)
                .fontWeight(session.isActive ? .medium : .regular)
            
            Spacer()
            
            Text(session.formattedDayTime)
                .font(compact ? .caption2 : .caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Race Detail View

struct RaceDetailView: View {
    let race: RaceRound
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Race info header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(race.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: "location.fill")
                            Text(race.countryName)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(race.formattedDateRange)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    
                    // Sessions list
                    VStack(alignment: .leading, spacing: 16) {
                        Text("All Sessions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(race.sessions) { session in
                            SessionDetailRow(session: session)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Race Details")
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

// MARK: - Session Detail Row

struct SessionDetailRow: View {
    let session: RaceSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: session.symbolName)
                    .font(.title3)
                    .foregroundStyle(session.isActive ? .green : .primary)
                
                Text(session.kind)
                    .font(.headline)
                
                Spacer()
                
                if session.isActive {
                    Text("LIVE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(session.formattedDayTime)
                        .font(.body)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatDuration(session.duration))
                        .font(.body)
                }
            }
        }
        .padding()
        .modifier(PlatformGlassCardModifier())
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Error View

struct ErrorView: View {
    let message: String
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            
            Text("Failed to load schedule")
                .font(.headline)
            
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                retry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ScheduleView()
        .environment(AppEnvironment())
}