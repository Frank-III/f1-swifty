//
//  TeamRadioView.swift
//  F1-Dash
//
//  Displays team radio communications
//

import SwiftUI
import F1DashModels

struct TeamRadioView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    private var teamRadio: TeamRadio? {
        appEnvironment.liveSessionState.teamRadio
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Team Radio", systemImage: "radio")
                .font(.headline)
            
            if let captures = teamRadio?.captures, !captures.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(captures.sorted(by: { $0.utc > $1.utc }).prefix(20), id: \.utc) { capture in
                            TeamRadioRow(capture: capture)
                        }
                    }
                }
                .frame(maxHeight: 300)
            } else {
                ContentUnavailableView(
                    "No Radio Messages",
                    systemImage: "radio",
                    description: Text("Team radio messages will appear here during a session")
                )
                .frame(height: 100)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct TeamRadioRow: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    let capture: RadioCapture
    
    private var driver: Driver? {
        appEnvironment.liveSessionState.driver(for: capture.racingNumber)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Team color indicator
            if let driver = driver {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: driver.teamColour) ?? .gray)
                    .frame(width: 4, height: 40)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    // Driver info
                    if let driver = driver {
                        Text(driver.tla)
                            .font(.caption)
                            .fontWeight(.bold)
                        
                        Text(driver.broadcastName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // Timestamp
                    Text(formatTime(capture.utc))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                // Radio indicator
                HStack(spacing: 4) {
                    Image(systemName: "radio.fill")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                    
                    
                    Spacer()
                    
                    // Play button (placeholder)
                    Button {
                        // TODO: Implement audio playback
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.body)
                    }
                    .buttonStyle(.plain)
                    .disabled(true) // For now
                }
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 6))
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

// MARK: - Compact Team Radio View

struct CompactTeamRadioView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    private var latestCapture: RadioCapture? {
        appEnvironment.liveSessionState.teamRadio?.captures
            .sorted(by: { $0.utc > $1.utc })
            .first
    }
    
    private var driver: Driver? {
        guard let capture = latestCapture else { return nil }
        return appEnvironment.liveSessionState.driver(for: capture.racingNumber)
    }
    
    var body: some View {
        if let capture = latestCapture, let driver = driver {
            HStack(spacing: 8) {
                Image(systemName: "radio.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)
                
                Text(driver.tla)
                    .font(.caption)
                    .fontWeight(.bold)
                
                Text("Team Radio")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(formatTime(capture.utc))
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
    TeamRadioView()
        .environment(AppEnvironment())
        .frame(width: 400)
        .padding()
}

#Preview("Compact View") {
    CompactTeamRadioView()
        .environment(AppEnvironment())
        .padding()
}
