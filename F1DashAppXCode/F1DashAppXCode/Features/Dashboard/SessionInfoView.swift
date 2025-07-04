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
                        Text(startDate.formatAsTime())
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Label("End", systemImage: "clock.fill")
                            .font(.caption2)
                        Text(endDate.formatAsTime())
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
        .cardStyle()
    }
}

#Preview {
    SessionInfoView()
        .environment(AppEnvironment())
        .frame(width: 300)
}
