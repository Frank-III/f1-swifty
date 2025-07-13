//
//  RaceListView.swift
//  F1-Dash
//
//  Race list sidebar for macOS and iPadOS
//

import SwiftUI
import F1DashModels

struct RaceListView: View {
    let races: [RaceRound]
    @Binding var selectedRace: RaceRound?
    @State private var preferences = RacePreferences()
    
    var body: some View {
        List(races, selection: $selectedRace) { race in
            RaceListRow(race: race, preferences: preferences)
                .tag(race as RaceRound?)
        }
        .listStyle(.sidebar)
        #if os(macOS)
        .frame(minWidth: 280, idealWidth: 320)
        #endif
    }
}

struct RaceListRow: View {
    let race: RaceRound
    let preferences: RacePreferences
    @State private var isHovering = false
    
    private var raceId: String {
        race.preferenceId
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            // Race info
            VStack(alignment: .leading, spacing: 4) {
                Text(race.countryName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(race.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(race.formattedDateRange)
                        .font(.caption)
                }
                .foregroundStyle(.tertiary)
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                // Favorite button
                Button {
                    preferences.toggleFavorite(raceId: raceId)
                } label: {
                    Image(systemName: preferences.isFavorite(raceId) ? "star.fill" : "star")
                        .foregroundStyle(preferences.isFavorite(raceId) ? .yellow : .secondary)
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .help(preferences.isFavorite(raceId) ? "Remove from favorites" : "Add to favorites")
                
                // Notification button
                Button {
                    preferences.toggleNotification(raceId: raceId)
                } label: {
                    Image(systemName: preferences.hasNotification(raceId) ? "bell.fill" : "bell")
                        .foregroundStyle(preferences.hasNotification(raceId) ? .blue : .secondary)
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .help(preferences.hasNotification(raceId) ? "Turn off notifications" : "Turn on notifications")
            }
            .opacity(isHovering ? 1 : 0.7)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
    
    private var statusColor: Color {
        if race.isActive {
            return .green
        } else if race.isUpcoming {
            return .blue
        } else {
            return .gray.opacity(0.5)
        }
    }
}
