//
//  SessionInfoView.swift
//  F1-Dash
//
//  Displays current session information
//

import SwiftUI
import F1DashModels

struct SessionInfoView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    private var sessionInfo: SessionInfo? {
        appEnvironment.liveSessionState.sessionInfo
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let sessionInfo = sessionInfo {
                // Session name and type
                HStack {
                    Text(sessionInfo.meeting?.name ?? "Unknown Session")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(sessionInfo.name ?? sessionInfo.type ?? "Session")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Circuit info
                HStack {
                    Label(sessionInfo.meeting?.location ?? "Unknown Location", systemImage: "location")
                        .font(.caption)
                    
                    Spacer()
                    
                    if let country = sessionInfo.meeting?.country.name {
                        Text(country)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Session timing
                if let startDate = sessionInfo.startDate,
                   let endDate = sessionInfo.endDate {
                    HStack {
                        Label("Start", systemImage: "clock")
                            .font(.caption2)
                        Text(formatDate(startDate))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Label("End", systemImage: "clock.fill")
                            .font(.caption2)
                        Text(formatDate(endDate))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                ContentUnavailableView(
                    "No Session",
                    systemImage: "flag.checkered",
                    description: Text("Waiting for session data...")
                )
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func formatDate(_ dateString: String) -> String {
        // Parse ISO8601 date and format for display
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .none
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}

#Preview {
    SessionInfoView()
        .environment(AppEnvironment())
        .frame(width: 300)
}
