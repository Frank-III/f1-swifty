//
//  DriverListView.swift
//  F1-Dash
//
//  Compact driver timing list for the menu bar popover
//

import SwiftUI
import F1DashModels

struct DriverListView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(appEnvironment.liveSessionState.sortedDrivers) { driver in
                    DriverRowView(driver: driver)
                    
                    if driver.id != appEnvironment.liveSessionState.sortedDrivers.last?.id {
                        Divider()
                    }
                }
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct DriverRowView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    let driver: Driver
    @State private var showingDetail = false
    
    private var timing: TimingDataDriver? {
        appEnvironment.liveSessionState.timing(for: driver.racingNumber)
    }
    
    private var isFavorite: Bool {
        appEnvironment.settingsStore.isFavoriteDriver(driver.racingNumber)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Position
            Text(String(timing?.line ?? driver.line))
                .font(.system(.body, design: .monospaced))
                .fontWeight(.medium)
                .frame(width: 30)
            
            // Team color indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: driver.teamColour) ?? .gray)
                .frame(width: 4, height: 24)
            
            // Driver info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(driver.tla)
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.bold)
                    
                    if isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                }
                
                Text(driver.broadcastName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Timing info
            HStack(spacing: 16) {
                // Gap/Interval
                if let timing = timing {
                    VStack(alignment: .trailing, spacing: 2) {
                        if !timing.gapToLeader.isEmpty {
                            Text(timing.gapToLeader)
                                .font(.system(.caption, design: .monospaced))
                        }
                        
                        if let interval = timing.intervalToPositionAhead?.value {
                            Text(interval)
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 60, alignment: .trailing)
                }
                
                // Last lap time
                if !(timing?.lastLapTime.value.isEmpty == true) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(timing?.lastLapTime.value ?? "")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(timing?.lastLapTime.personalFastest == true ? .purple : .primary)
                    }
                    .frame(width: 70, alignment: .trailing)
                }
                
                // Status indicators (commented out - properties don't exist in current model)
                HStack(spacing: 4) {
                    /*if timing?.inPit == true {
                        Text("PIT")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    
                    if timing?.knockedOut == true {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }*/
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isFavorite ? (Color(hex: driver.teamColour) ?? .gray).opacity(0.05) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetail = true
        }
        .popover(isPresented: $showingDetail) {
            LapTimeDetailView(driver: driver)
        }
    }
}

#Preview {
    DriverListView()
        .environment(AppEnvironment())
        .frame(height: 400)
}
