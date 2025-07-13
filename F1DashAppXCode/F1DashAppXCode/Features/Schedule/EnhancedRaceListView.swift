//
//  EnhancedRaceListView.swift
//  F1-Dash
//
//  Enhanced race list with collapsible sessions and rich colors
//

import SwiftUI
import F1DashModels

struct EnhancedRaceListView: View {
    let races: [RaceRound]
    @Binding var selectedRace: RaceRound?
    @State private var preferences = RacePreferences()
    
    var body: some View {
        List(races, selection: $selectedRace) { race in
            EnhancedRaceListRow(
                race: race,
                preferences: preferences,
                isSelected: selectedRace?.id == race.id
            )
            .tag(race as RaceRound?)
        }
        .listStyle(.sidebar)
        #if os(macOS)
        .frame(minWidth: 260, idealWidth: 280, maxWidth: 320)
        #endif
    }
}

struct EnhancedRaceListRow: View {
    let race: RaceRound
    let preferences: RacePreferences
    let isSelected: Bool
    
    @State private var isExpanded = false
    @State private var isHovering = false
    
    private var raceId: String {
        race.preferenceId
    }
    
    private var isPast: Bool {
        race.end < Date()
    }
    
    private var raceColor: Color {
        RaceColorTheme.color(for: race.countryName, isActive: race.isActive, isPast: isPast)
    }
    
    private var importantSessions: [RaceSession] {
        // Prioritize: Race > Qualifying > Sprint > Practice
        race.sessions.sorted { session1, session2 in
            let priority1 = sessionPriority(session1)
            let priority2 = sessionPriority(session2)
            return priority1 > priority2
        }
    }
    
    private func sessionPriority(_ session: RaceSession) -> Int {
        let kind = session.kind.lowercased()
        if kind.contains("race") && !kind.contains("sprint") {
            return 4
        } else if kind.contains("qualifying") && !kind.contains("sprint") {
            return 3
        } else if kind.contains("sprint") {
            return 2
        } else {
            return 1
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main race row
            HStack(spacing: 12) {
                // Colored accent bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(raceColor)
                    .frame(width: 4, height: 50)
                    .opacity(isPast ? 0.5 : 1.0)
                
                // Race info
                VStack(alignment: .leading, spacing: 6) {
                    Text(race.countryName)
                        .font(.headline)
                        .foregroundStyle(isPast ? .secondary : .primary)
                    
                    Text(race.name)
                        .font(.caption)
                        .foregroundStyle(isPast ? .tertiary : .secondary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        // Date
                        Label(race.formattedDateRange, systemImage: "calendar")
                            .font(.caption2)
                            .foregroundStyle(isPast ? .tertiary : .secondary)
                        
                        // Live indicator
                        if race.isActive {
                            Label("LIVE", systemImage: "dot.radiowaves.left.and.right")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.green)
                        }
                    }
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 10) {
                    // Expand/Collapse button with larger hit area
                    Button {
                        isExpanded.toggle()
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle")
                            .font(.system(size: 20))
                            .foregroundStyle(raceColor.opacity(isPast ? 0.5 : 1.0))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
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
                    if !isPast {
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
                }
                .opacity(isHovering ? 1 : 0.7)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? raceColor.opacity(0.1) : Color.clear)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                isExpanded.toggle()
            }
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovering = hovering
                }
            }
            
            // Collapsible sessions with animation
            VStack(spacing: 0) {
                if isExpanded {
                    VStack(spacing: 4) {
                        Divider()
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                        
                        // Show only the most important sessions (max 3)
                        ForEach(importantSessions.prefix(3)) { session in
                            EnhancedSessionRow(session: session, raceColor: raceColor)
                        }
                        
                        if race.sessions.count > 3 {
                            Text("+\(race.sessions.count - 3) more sessions")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                        }
                    }
                    .padding(.bottom, 8)
                    .transition(.asymmetric(
                        insertion: .push(from: .top).combined(with: .opacity),
                        removal: .push(from: .bottom).combined(with: .opacity)
                    ))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isExpanded)
            .clipped()
        }
    }
}

struct EnhancedSessionRow: View {
    let session: RaceSession
    let raceColor: Color
    
    private var isPast: Bool {
        session.end < Date()
    }
    
    private var isLive: Bool {
        session.isActive
    }
    
    private var sessionIcon: String {
        switch session.kind.lowercased() {
        case let k where k.contains("practice"):
            return "flag"
        case let k where k.contains("qualifying"):
            return "stopwatch"
        case let k where k.contains("sprint"):
            return "bolt.fill"
        case let k where k.contains("race") && !k.contains("sprint"):
            return "trophy.fill"
        default:
            return "flag"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Session type icon
            Image(systemName: sessionIcon)
                .font(.system(size: 14))
                .foregroundStyle(isLive ? .green : (isPast ? Color.gray : raceColor))
                .frame(width: 20)
            
            // Session name
            Text(session.kind)
                .font(.subheadline)
                .fontWeight(isLive ? .medium : .regular)
                .foregroundStyle(isPast ? .secondary : .primary)
            
            Spacer()
            
            // Session time
            VStack(alignment: .trailing, spacing: 2) {
                Text(dayOfWeek(from: session.start))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                
                Text(session.formattedTime)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(isPast ? .tertiary : .secondary)
            }
            
            // Live/Past indicator
            if isLive {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(Color.green.opacity(0.3), lineWidth: 8)
                            .blur(radius: 4)
                    )
            } else if isPast {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isLive ? Color.green.opacity(0.1) : Color.clear)
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 2)
    }
    
    private func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
}