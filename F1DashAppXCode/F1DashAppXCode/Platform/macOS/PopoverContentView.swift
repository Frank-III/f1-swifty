//
//  PopoverContentView.swift
//  F1-Dash
//
//  Main content view for the macOS menu bar popover
//

import SwiftUI
import F1DashModels
#if os(macOS)
import AppKit
#endif

public struct PopoverContentView: View {
    public init() {}
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView()
            
            Divider()
            
            // Main content
            if appEnvironment.connectionStatus == .connected {
                VStack(spacing: 0) {
                    // Track Map
                    // TrackMapView()
                    OptimizedTrackMapView(circuitKey: String(appEnvironment.liveSessionState.sessionInfo?.meeting?.circuit.key ?? 0))
                        .frame(height: 300)
                        .background(Color.platformBackground)
                    
                    Divider()
                    
                    // Driver List
                    // DriverListView()
                    OptimizedDriverListView()
                        .frame(maxHeight: 400)
                }
            } else {
                // Connection status view
                ConnectionStatusView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Divider()
            
            // Footer
            FooterView()
        }
        .frame(width: 600, height: 750)
        .task {
            // Auto-connect when view appears
            if appEnvironment.connectionStatus == .disconnected {
                await appEnvironment.connect()
            }
        }
    }
}

// MARK: - Header View

struct HeaderView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        HStack {
            // Session info
            VStack(alignment: .leading, spacing: 4) {
                if let session = appEnvironment.liveSessionState.sessionInfo {
                    Text(session.meeting?.name ?? "Unknown Meeting")
                        .font(.headline)
                    Text(session.name ?? "Unknown Session")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No Active Session")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Track status
            if let trackStatus = appEnvironment.liveSessionState.trackStatus {
                TrackStatusBadge(status: trackStatus.status.rawValue)
            }
            
            // Settings button
            Button {
                #if os(macOS)
                if #available(macOS 13, *) {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil as Any?, from: nil as Any?)
                } else {
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil as Any?, from: nil as Any?)
                }
                #endif
            } label: {
                Image(systemName: "gear")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Footer View

struct FooterView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        HStack {
            // Connection indicator
            HStack(spacing: 4) {
                Circle()
                    .fill(appEnvironment.connectionStatus.color)
                    .frame(width: 8, height: 8)
                Text(appEnvironment.connectionStatus.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Delay indicator
            if appEnvironment.settingsStore.hasDataDelay {
                Label(appEnvironment.settingsStore.formattedDelay, systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Debug button
            Button("Debug") {
                #if os(macOS)
                openWindow(id: "test-race-control")
                #endif
            }
            .buttonStyle(.plain)
            .font(.caption)
            
            // Quit button
            Button("Quit") {
                #if os(macOS)
                NSApplication.shared.terminate(nil as Any?)
                #endif
            }
            .buttonStyle(.plain)
            .font(.caption)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Connection Status View

struct ConnectionStatusView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: appEnvironment.connectionStatus.icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text(appEnvironment.connectionStatus.message)
                .font(.headline)
            
            if appEnvironment.connectionStatus == .disconnected {
                Button("Connect") {
                    Task {
                        await appEnvironment.connect()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.platformBackground)
    }
}

// MARK: - Track Status Badge

struct TrackStatusBadge: View {
    let status: String
    
    var statusColor: Color {
        switch status {
        case "1": return .green
        case "2": return .yellow
        case "4": return .yellow
        case "5": return .red
        case "6", "7": return .yellow
        default: return .gray
        }
    }
    
    var statusDescription: String {
        switch status {
        case "1": return "All Clear"
        case "2": return "Yellow Flag"
        case "4": return "Safety Car"
        case "5": return "Red Flag"
        case "6": return "Virtual Safety Car"
        case "7": return "VSC Ending"
        default: return "Unknown"
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
            Text(statusDescription)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.2))
        .clipShape(Capsule())
    }
}

// MARK: - Extensions

extension ConnectionStatus {
    var icon: String {
        switch self {
        case .disconnected: return "wifi.slash"
        case .connecting: return "wifi.exclamationmark"
        case .connected: return "wifi"
        }
    }
    
    var message: String {
        switch self {
        case .disconnected: return "Not connected to F1 Dash Server"
        case .connecting: return "Connecting to server..."
        case .connected: return "Connected to live timing"
        }
    }
}

#Preview {
    PopoverContentView()
        // .environment(AppEnvironment())
        .environment(OptimizedAppEnvironment())
}
