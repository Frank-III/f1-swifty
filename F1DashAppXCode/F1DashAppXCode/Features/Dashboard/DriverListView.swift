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
                // Driver table header
                if appEnvironment.settingsStore.showDriverTableHeader {
                    DriverTableHeader()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                    
                    Divider()
                }
                
                ForEach(appEnvironment.liveSessionState.sortedDrivers) { driver in
                    DriverRowView(driver: driver)
                    
                    if driver.id != appEnvironment.liveSessionState.sortedDrivers.last?.id {
                        Divider()
                    }
                }
            }
        }
        .background(Color.platformBackground)
    }
}

struct DriverRowView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    let driver: Driver
    @State private var showingDetail = false
    
    private var timing: TimingDataDriver? {
        appEnvironment.liveSessionState.timing(for: driver.racingNumber)
    }
    
    private var stints: [Stint] {
        appEnvironment.liveSessionState.timingAppData?.lines[driver.racingNumber]?.stints ?? []
    }
    
    private var isFavorite: Bool {
        appEnvironment.settingsStore.isFavoriteDriver(driver.racingNumber)
    }
    
    private func sectorColor(for sector: Sector) -> Color {
        if sector.overallFastest {
            return .purple
        } else if sector.personalFastest {
            return .green
        } else {
            return .primary
        }
    }
    
    private func segmentColor(for status: Int) -> Color {
        switch status {
        case 2048: return .purple  // Overall fastest
        case 2049: return .green   // Personal fastest  
        case 2051: return .yellow  // Yellow flag
        default: return .gray.opacity(0.3)
        }
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
            
            // Tire information
            if !stints.isEmpty {
                TireInfoView(stints: stints)
                    .frame(maxWidth: 80)
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
                
                // Best sectors (if enabled)
                if appEnvironment.settingsStore.showDriversBestSectors,
                   let sectors = timing?.sectors,
                   !sectors.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(Array(sectors.enumerated()), id: \.offset) { index, sector in
                            Text(sector.value)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(sectorColor(for: sector))
                                .frame(minWidth: 30)
                        }
                    }
                }
                
                // Mini sectors (if enabled)
                if appEnvironment.settingsStore.showDriversMiniSectors,
                   let sectors = timing?.sectors,
                   !sectors.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(sectors, id: \.self) { sector in
                            HStack(spacing: 1) {
                                ForEach(Array(sector.segments.enumerated()), id: \.offset) { _, segment in
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(segmentColor(for: segment.status))
                                        .frame(width: 8, height: 2)
                                }
                            }
                        }
                    }
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

struct DriverTableHeader: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    var body: some View {
        HStack(spacing: 12) {
            // Position
            Text("POS")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .frame(width: 30)
            
            // Team color indicator space
            Rectangle()
                .fill(Color.clear)
                .frame(width: 4, height: 12)
            
            // Driver
            VStack {
                Text("DRIVER")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: 80, alignment: .leading)
            
            // Tire
            Text("TIRE")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 80)
            
            Spacer()
            
            // Timing headers
            HStack(spacing: 16) {
                Text("GAP/INT")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .frame(width: 60, alignment: .trailing)
                
                Text("LAP TIME")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .frame(width: 70, alignment: .trailing)
                
                // Sectors header (if enabled)
                if appEnvironment.settingsStore.showDriversBestSectors {
                    Text("SECTORS")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 90)
                }
                
                // Mini sectors header (if enabled)
                if appEnvironment.settingsStore.showDriversMiniSectors {
                    Text("MINI")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 60)
                }
            }
        }
    }
}

#Preview {
    DriverListView()
        .environment(AppEnvironment())
        .frame(height: 400)
}
