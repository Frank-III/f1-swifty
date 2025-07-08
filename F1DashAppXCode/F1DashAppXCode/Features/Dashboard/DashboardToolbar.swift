//
//  DashboardToolbar.swift
//  F1-Dash
//
//  Dashboard toolbar component
//

import SwiftUI

struct DashboardToolbar: ToolbarContent {
    @Environment(AppEnvironment.self) private var appEnvironment
    let layoutManager: DashboardLayoutManager
    @Binding var showRacePredictionSheet: Bool
    let sessionSubtitle: String
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            // Session info as subtitle
            if appEnvironment.connectionStatus == .connected {
                VStack(spacing: 2) {
                    Text("F1 Dashboard")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(sessionSubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        
        ToolbarItemGroup(placement: .primaryAction) {
            // Edit mode toggle
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    layoutManager.isEditMode.toggle()
                }
            } label: {
                Image(systemName: layoutManager.isEditMode ? "checkmark.circle.fill" : "pencil")
                    .foregroundStyle(layoutManager.isEditMode ? .green : .primary)
            }
            .help(layoutManager.isEditMode ? "Done Editing" : "Edit Layout")
            
            // Connection status indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(appEnvironment.connectionStatus.color)
                    .frame(width: 8, height: 8)
                
                Text(appEnvironment.connectionStatus.statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Connect/Disconnect button
            if appEnvironment.connectionStatus == .disconnected {
                Button("Connect") {
                    Task {
                        await appEnvironment.connect()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            } else if appEnvironment.connectionStatus == .connected {
                Button {
                    Task {
                        await appEnvironment.disconnect()
                    }
                } label: {
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            // Race prediction button (if we have prediction data)
            if appEnvironment.liveSessionState.championshipPrediction != nil {
                Button {
                    showRacePredictionSheet = true
                } label: {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                }
            }
        }
    }
}