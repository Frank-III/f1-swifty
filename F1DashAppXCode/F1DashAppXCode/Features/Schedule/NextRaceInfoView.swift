//
//  NextRaceInfoView.swift
//  F1DashAppXCode
//
//  Displays next race information with animated countdown timers
//

import SwiftUI
import F1DashModels

struct NextRaceInfoView: View {
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @State private var currentTime = Date()
    @State private var timer: Timer?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var nextRace: RaceRound? {
        appEnvironment.schedule.first { $0.end > currentTime }
    }
    
    private var nextSession: (name: String, date: Date)? {
        guard let race = nextRace else { return nil }
        
        // Find the next upcoming session
        for session in race.sessions {
            if session.start > currentTime {
                return (session.kind, session.start)
            }
        }
        
        return nil
    }
    
    private var isCompact: Bool {
        #if os(macOS)
        return false
        #else
        return horizontalSizeClass == .compact
        #endif
    }
    
    var body: some View {
        Group {
            if let race = nextRace {
                GeometryReader { geometry in
                    if geometry.size.width < 600 || isCompact {
                        // Compact single row layout
                        compactLayout(race: race)
                    } else {
                        // Expanded layout with more info
                        expandedLayout(race: race, width: geometry.size.width)
                    }
                }
                .frame(height: {
                    #if os(iOS)
                    return (isCompact || UIDevice.current.userInterfaceIdiom == .phone) ? 60 : 80
                    #else
                    return 80
                    #endif
                }())
            } else {
                // No upcoming races
                HStack {
                    Image(systemName: "flag.checkered.2.crossed")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text("Season Complete")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    @ViewBuilder
    private func compactLayout(race: RaceRound) -> some View {
        HStack(spacing: 12) {
            // Country flag
            Text(race.countryKey?.f1CountryFlag ?? "🏁")
                .font(.system(size: 24))
            
            // Race info
            VStack(alignment: .leading, spacing: 2) {
                Text(race.countryName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                
                Text(race.name)
                    .font(.system(size: 14, weight: .bold))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Compact countdown
            if let session = nextSession {
                CompactCountdown(
                    label: session.name,
                    targetDate: session.date,
                    currentTime: currentTime
                )
            } else if let raceSession = race.raceSession {
                CompactCountdown(
                    label: "Race",
                    targetDate: raceSession.start,
                    currentTime: currentTime
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    @ViewBuilder
    private func expandedLayout(race: RaceRound, width: CGFloat) -> some View {
        HStack(spacing: 0) {
            // Left side - Race info
            HStack(spacing: 12) {
                // Country flag
                Text(race.countryKey?.f1CountryFlag ?? "🏁")
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(race.countryName)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.secondary)
                    
                    Text(race.name)
                        .font(.system(size: 18, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    // Date range
                    Text(race.formattedDateRange)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(width: width * 0.35, alignment: .leading)
            
            Spacer()
            
            // Right side - Sessions and countdown
            if width > 800 {
                // Show session schedule
                HStack(spacing: 20) {
                    if let sessions = getUpcomingSessions(race: race) {
                        ForEach(sessions.prefix(3), id: \.name) { session in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(session.name)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.secondary)
                                Text(formatSessionTime(session.date))
                                    .font(.system(size: 13, weight: .semibold))
                            }
                        }
                    }
                    
                    Divider()
                        .frame(height: 40)
                    
                    // Countdown timers
                    HStack(spacing: 16) {
                        if let session = nextSession {
                            MediumCountdown(
                                title: "Next: \(session.name)",
                                targetDate: session.date,
                                currentTime: currentTime,
                                accentColor: .orange
                            )
                        }
                        
                        if let raceSession = race.raceSession {
                            MediumCountdown(
                                title: "Race",
                                targetDate: raceSession.start,
                                currentTime: currentTime,
                                accentColor: .red
                            )
                        }
                    }
                }
            } else {
                // Medium width - just countdown
                HStack(spacing: 16) {
                    if let session = nextSession {
                        MediumCountdown(
                            title: "Next: \(session.name)",
                            targetDate: session.date,
                            currentTime: currentTime,
                            accentColor: .orange
                        )
                    }
                    
                    if let raceSession = race.raceSession {
                        MediumCountdown(
                            title: "Race",
                            targetDate: raceSession.start,
                            currentTime: currentTime,
                            accentColor: .red
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func getUpcomingSessions(race: RaceRound) -> [(name: String, date: Date)]? {
        let upcomingSessions = race.sessions.filter { $0.start > currentTime }
        guard !upcomingSessions.isEmpty else { return nil }
        
        return upcomingSessions.map { (name: $0.kind, date: $0.start) }
    }
    
    private func formatSessionTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E HH:mm"
        return formatter.string(from: date)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            currentTime = Date()
        }
    }
}

struct CompactCountdown: View {
    let label: String
    let targetDate: Date
    let currentTime: Date
    
    private var timeString: String {
        let interval = targetDate.timeIntervalSince(currentTime)
        guard interval > 0 else { return "Now" }
        
        let days = Int(interval) / 86400
        let hours = (Int(interval) % 86400) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if days > 0 {
            return "\(days)d \(hours)h"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            let seconds = Int(interval) % 60
            return "\(minutes)m \(seconds)s"
        }
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
            Text(timeString)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.orange)
        }
    }
}

struct MediumCountdown: View {
    let title: String
    let targetDate: Date
    let currentTime: Date
    let accentColor: Color
    
    private var timeComponents: (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let interval = targetDate.timeIntervalSince(currentTime)
        
        guard interval > 0 else {
            return (0, 0, 0, 0)
        }
        
        let days = Int(interval) / 86400
        let hours = (Int(interval) % 86400) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        
        return (days, hours, minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
            
            HStack(spacing: 4) {
                if timeComponents.days > 0 {
                    SmallTimeUnit(value: timeComponents.days, unit: "d", color: accentColor)
                }
                
                SmallTimeUnit(value: timeComponents.hours, unit: "h", color: accentColor)
                SmallTimeUnit(value: timeComponents.minutes, unit: "m", color: accentColor)
                
                if timeComponents.days == 0 {
                    SmallTimeUnit(value: timeComponents.seconds, unit: "s", color: accentColor)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(accentColor.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(accentColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct SmallTimeUnit: View {
    let value: Int
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 1) {
            Text(String(format: "%02d", value))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(unit)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(color.opacity(0.7))
        }
    }
}

struct CountdownTimer: View {
    let title: String
    let targetDate: Date
    let currentTime: Date
    let accentColor: Color
    
    @State private var animateNumbers = false
    
    private var timeComponents: (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let interval = targetDate.timeIntervalSince(currentTime)
        
        guard interval > 0 else {
            return (0, 0, 0, 0)
        }
        
        let days = Int(interval) / 86400
        let hours = (Int(interval) % 86400) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        
        return (days, hours, minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 8) {
                if timeComponents.days > 0 {
                    TimeUnit(value: timeComponents.days, unit: "d", color: accentColor)
                        .transition(.scale.combined(with: .opacity))
                }
                
                TimeUnit(value: timeComponents.hours, unit: "h", color: accentColor)
                    .transition(.scale.combined(with: .opacity))
                
                TimeUnit(value: timeComponents.minutes, unit: "m", color: accentColor)
                    .transition(.scale.combined(with: .opacity))
                
                TimeUnit(value: timeComponents.seconds, unit: "s", color: accentColor)
                    .transition(.scale.combined(with: .opacity))
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: timeComponents.seconds)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(accentColor.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(accentColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct TimeUnit: View {
    let value: Int
    let unit: String
    let color: Color
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%02d", value))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .scaleEffect(scale)
                .onChange(of: value) { _, _ in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                        scale = 1.1
                    }
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5).delay(0.1)) {
                        scale = 1.0
                    }
                }
            
            Text(unit)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(color.opacity(0.7))
        }
        .frame(minWidth: 40)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        NextRaceInfoView()
            .padding()
        
        Spacer()
    }
    .environment(OptimizedAppEnvironment())
}
