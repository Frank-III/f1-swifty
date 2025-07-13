//
//  RaceDetailViews.swift
//  F1-Dash
//
//  Race detail views for popover and sheet presentations
//

import SwiftUI
import F1DashModels

// MARK: - macOS Popover

struct RaceDetailPopover: View {
    let race: RaceRound
    let preferences: RacePreferences
    @Environment(\.dismiss) private var dismiss
    
    private var raceId: String {
        race.preferenceId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text(race.countryName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(race.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let circuitName = RaceLocationData.circuitNames[race.countryName] {
                    Label(circuitName, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Divider()
            
            // Action buttons
            HStack(spacing: 12) {
                Button {
                    preferences.toggleFavorite(raceId: raceId)
                } label: {
                    Label(
                        preferences.isFavorite(raceId) ? "Favorited" : "Add to Favorites",
                        systemImage: preferences.isFavorite(raceId) ? "star.fill" : "star"
                    )
                }
                .buttonStyle(.bordered)
                .tint(preferences.isFavorite(raceId) ? .yellow : .secondary)
                
                Button {
                    preferences.toggleNotification(raceId: raceId)
                } label: {
                    Label(
                        preferences.hasNotification(raceId) ? "Notifications On" : "Notify Me",
                        systemImage: preferences.hasNotification(raceId) ? "bell.fill" : "bell"
                    )
                }
                .buttonStyle(.bordered)
                .tint(preferences.hasNotification(raceId) ? .blue : .secondary)
            }
            
            // Sessions
            VStack(alignment: .leading, spacing: 8) {
                Text("Sessions")
                    .font(.headline)
                
                ForEach(consolidatedSessions(race.sessions)) { session in
                    SessionCompactRow(session: session)
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 350)
        .frame(minHeight: 300)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private func consolidatedSessions(_ sessions: [RaceSession]) -> [RaceSession] {
        var result: [RaceSession] = []
        var practiceCount = 0
        
        for session in sessions.sorted(by: { $0.start < $1.start }) {
            let sessionType = session.kind.lowercased()
            
            if sessionType.contains("practice") {
                practiceCount += 1
                // Only show the first practice session, but modify its display name
                if practiceCount == 1 {
                    result.append(session)
                }
            } else {
                // Add qualifying, sprint, and race sessions normally
                result.append(session)
            }
        }
        
        return result
    }
}

// MARK: - iOS Sheet

#if os(iOS)
struct RaceDetailSheet: View {
    let race: RaceRound
    @Bindable var preferences: RacePreferences
    @Environment(\.dismiss) private var dismiss
    
    private var raceId: String {
        race.preferenceId
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header card
                    VStack(alignment: .leading, spacing: 8) {
                        Text(race.countryName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(race.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        if let circuitName = RaceLocationData.circuitNames[race.countryName] {
                            Label(circuitName, systemImage: "location.fill")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        
                        Label(race.formattedDateRange, systemImage: "calendar")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.platformSecondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        Button {
                            preferences.toggleFavorite(raceId: raceId)
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: preferences.isFavorite(raceId) ? "star.fill" : "star")
                                    .font(.title3)
                                    .foregroundStyle(preferences.isFavorite(raceId) ? .yellow : .primary)
                                
                                Text(preferences.isFavorite(raceId) ? "Favorited" : "Favorite")
                                    .font(.caption2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.platformSecondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            preferences.toggleNotification(raceId: raceId)
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: preferences.hasNotification(raceId) ? "bell.fill" : "bell")
                                    .font(.title3)
                                    .foregroundStyle(preferences.hasNotification(raceId) ? .blue : .primary)
                                
                                Text(preferences.hasNotification(raceId) ? "Notifying" : "Notify")
                                    .font(.caption2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.platformSecondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Sessions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Race Weekend Sessions")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        ForEach(consolidatedSessions(race.sessions)) { session in
                            SessionDetailCard(session: session)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .navigationTitle("Race Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func consolidatedSessions(_ sessions: [RaceSession]) -> [RaceSession] {
        var result: [RaceSession] = []
        var practiceCount = 0
        
        for session in sessions.sorted(by: { $0.start < $1.start }) {
            let sessionType = session.kind.lowercased()
            
            if sessionType.contains("practice") {
                practiceCount += 1
                // Only show the first practice session, but modify its display name
                if practiceCount == 1 {
                    result.append(session)
                }
            } else {
                // Add qualifying, sprint, and race sessions normally
                result.append(session)
            }
        }
        
        return result
    }
}
#endif

// MARK: - Supporting Views

struct SessionCompactRow: View {
    let session: RaceSession
    
    var displayName: String {
        if session.kind.lowercased().contains("practice") {
            return "Practice Sessions"
        }
        return session.kind
    }
    
    var body: some View {
        HStack {
            Image(systemName: session.symbolName)
                .font(.caption)
                .foregroundStyle(session.isActive ? .green : .secondary)
                .frame(width: 20)
            
            Text(displayName)
                .font(.body)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(dayOfWeek(from: session.start))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Text(session.formattedTime)
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

struct SessionDetailCard: View {
    let session: RaceSession
    
    var displayName: String {
        if session.kind.lowercased().contains("practice") {
            return "Practice Sessions"
        }
        return session.kind
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Image(systemName: session.symbolName)
                        .font(.callout)
                        .foregroundStyle(session.isActive ? .green : .primary)
                    
                    Text(displayName)
                        .font(.callout)
                        .fontWeight(.medium)
                }
                
                Text("\(session.formattedDayTime) • \(formatDuration(session.duration))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if session.isActive {
                Text("LIVE")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            } else if let timeUntil = session.timeUntilStart {
                Text(formatTimeUntil(timeUntil))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.platformBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
    
    private func formatTimeUntil(_ interval: TimeInterval) -> String {
        let days = Int(interval) / 86400
        let hours = Int(interval) % 86400 / 3600
        
        if days > 0 {
            return "in \(days)d"
        } else if hours > 0 {
            return "in \(hours)h"
        } else {
            let minutes = Int(interval) / 60
            return "in \(minutes)m"
        }
    }
}
