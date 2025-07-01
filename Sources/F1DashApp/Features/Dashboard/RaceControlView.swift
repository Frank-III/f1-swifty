//
//  RaceControlView.swift
//  F1-Dash
//
//  Displays race control messages
//

import SwiftUI
import F1DashModels

struct RaceControlView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    private var raceControlMessages: RaceControlMessages? {
        appEnvironment.liveSessionState.raceControlMessages
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Race Control", systemImage: "flag.2.crossed")
                .font(.headline)
            
            if let messages = raceControlMessages?.messages, !messages.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(messages.sorted(by: { $0.utc > $1.utc }).prefix(10), id: \.utc) { message in
                            RaceControlMessageRow(message: message)
                        }
                    }
                }
                .frame(maxHeight: 200)
            } else {
                ContentUnavailableView(
                    "No Messages",
                    systemImage: "flag.2.crossed",
                    description: Text("Race control messages will appear here")
                )
                .frame(height: 100)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct RaceControlMessageRow: View {
    let message: RaceControlMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // Category indicator
                Circle()
                    .fill(colorForCategory(message.category))
                    .frame(width: 8, height: 8)
                
                // Timestamp
                Text(formatTime(message.utc))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                // Lap number if available
                if let lap = message.lap {
                    Text("Lap \(lap)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Message text
            Text(message.message)
                .font(.caption)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(backgroundForCategory(message.category))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    private func colorForCategory(_ category: MessageCategory) -> Color {
        Color(hex: category.color) ?? Color.gray
    }
    
    private func backgroundForCategory(_ category: MessageCategory) -> Color {
        colorForCategory(category).opacity(0.1)
    }
    
    private func formatTime(_ utcString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: utcString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .none
            displayFormatter.timeStyle = .medium
            return displayFormatter.string(from: date)
        }
        
        return String(utcString.prefix(8))
    }
}

// MARK: - Compact Race Control View

struct CompactRaceControlView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    private var latestMessage: RaceControlMessage? {
        appEnvironment.liveSessionState.latestRaceControlMessage
    }
    
    var body: some View {
        if let message = latestMessage {
            HStack(spacing: 8) {
                Image(systemName: "flag.2.crossed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(message.message)
                    .font(.caption)
                    .lineLimit(1)
                
                Spacer()
                
                Text(formatTime(message.utc))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
    
    private func formatTime(_ utcString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: utcString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .none
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        
        return String(utcString.prefix(5))
    }
}

#Preview("Full View") {
    RaceControlView()
        .environment(AppEnvironment())
        .frame(width: 400)
        .padding()
}

#Preview("Compact View") {
    CompactRaceControlView()
        .environment(AppEnvironment())
        .padding()
}
