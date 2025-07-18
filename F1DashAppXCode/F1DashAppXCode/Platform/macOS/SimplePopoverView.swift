//
//  SimplePopoverView.swift
//  F1-Dash
//
//  Minimal popover showing just track map and top drivers
//

import SwiftUI
import F1DashModels
#if os(macOS)
import AppKit
#endif

public struct SimplePopoverView: View {
    public init() {}
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    public var body: some View {
        VStack(spacing: 0) {
            // Compact Header
            CompactHeader()
            
            Divider()
            
            // Main content
            if appEnvironment.connectionStatus == .connected {
                VStack(spacing: 0) {
                    // Track Map
                    if appEnvironment.liveSessionState.timingData != nil {
                        // TrackMapView()
                        OptimizedTrackMapView(circuitKey: String(appEnvironment.liveSessionState.sessionInfo?.meeting?.circuit.key ?? 0))
                            .frame(height: 180)
                            .background(Color.platformBackground)
                    }
                    
                    Divider()
                    
                    // Top Drivers List
                    TopDriversList()
                        .frame(maxHeight: 300)
                }
            } else {
                // Connection status view
                SimpleConnectionView()
            }
            
            Divider()
            
            // Minimal Footer
            MinimalFooter()
        }
        .frame(width: 350, height: 375)
        .task {
            // Auto-connect when view appears
            if appEnvironment.connectionStatus == .disconnected {
                await appEnvironment.connect()
            }
        }
    }
}

// MARK: - Compact Header

struct CompactHeader: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        HStack(spacing: 8) {
            // Session info
            if let session = appEnvironment.liveSessionState.sessionInfo {
                Text("\(session.meeting?.name ?? "F1") • \(session.name ?? "Session")")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .lineLimit(1)
            } else {
                Text("F1 Dash")
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            // Track status indicator
            if let trackStatus = appEnvironment.liveSessionState.trackStatus {
                Circle()
                    .fill(trackStatusColor(trackStatus.status.rawValue))
                    .frame(width: 8, height: 8)
            }
            
            // Dashboard button
            Button {
              //TODO: bring this back
//                              #if os(macOS)
//                NSApp.sendAction(#selector(AppDelegate.showDashboard), to: nil, from: nil)
//                #endif
            } label: {
                Image(systemName: "arrow.up.right.square")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .help("Open Dashboard")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
    }
    
    private func trackStatusColor(_ status: String) -> Color {
        switch status {
        case "1": return .green
        case "2": return .yellow
        case "4": return .yellow
        case "5": return .red
        case "6", "7": return .yellow
        default: return .gray
        }
    }
}

// MARK: - Top Drivers List

struct TopDriversList: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var sortedDrivers: [Driver] {
        appEnvironment.liveSessionState.sortedDrivers
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(sortedDrivers.prefix(10)) { driver in
                    MinimalDriverRow(driver: driver)
                }
            }
        }
        .background(Color.platformBackground)
    }
}

struct MinimalDriverRow: View {
    let driver: Driver
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    private var timing: TimingDataDriver? {
        appEnvironment.liveSessionState.timing(for: driver.racingNumber)
    }
    
    private var position: Int {
        timing?.line ?? driver.line
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Position
            Text("\(position)")
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.bold)
                .frame(width: 20, alignment: .center)
            
            // Team color
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(hex: driver.teamColour) ?? .gray)
                .frame(width: 3, height: 16)
            
            // Driver TLA
            Text(driver.tla)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.bold)
                .frame(width: 35, alignment: .leading)
            
            // Driver name
            Text(driver.lastName)
                .font(.caption)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Gap/Time
            if let timing = timing {
              if position == 1, let bestLapTime = timing.bestLapTime, !bestLapTime.value.isEmpty, let lastLapTime = timing.lastLapTime {
                    Text(bestLapTime.value)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(lastLapTime.personalFastest ? .purple : .primary)
                } else if let gapToLeader = timing.gapToLeader, !gapToLeader.isEmpty {
                    Text(gapToLeader)
                        .font(.system(.caption2, design: .monospaced))
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 3)
        .background(appEnvironment.settingsStore.isFavoriteDriver(driver.racingNumber) ? Color.accentColor.opacity(0.1) : Color.clear)
    }
}

// MARK: - Simple Connection View

struct SimpleConnectionView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.title)
                .foregroundStyle(.secondary)
            
            Text("Not Connected")
                .font(.caption)
                .fontWeight(.medium)
            
            Button("Connect") {
                Task {
                    await appEnvironment.connect()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.platformBackground)
    }
}

// MARK: - Minimal Footer

struct MinimalFooter: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        HStack {
            // Connection status
            HStack(spacing: 4) {
                Circle()
                    .fill(appEnvironment.connectionStatus.color)
                    .frame(width: 6, height: 6)
                
                if appEnvironment.settingsStore.hasDataDelay {
                    Text(appEnvironment.settingsStore.formattedDelay)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Quit button
            Button("Quit") {
                #if os(macOS)
                NSApplication.shared.terminate(nil)
                #endif
            }
            .buttonStyle(.plain)
            .font(.caption2)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 3)
    }
}

#Preview {
    SimplePopoverView()
        .environment(AppEnvironment())
}
