//
//  EnhancedDriverListView.swift
//  F1-Dash
//
//  Enhanced driver timing list with horizontal and vertical scrolling
//

import SwiftUI
import F1DashModels

struct EnhancedDriverListView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        VStack(spacing: 0) {
            // Enhanced driver table header (always visible)
            if appEnvironment.settingsStore.showDriverTableHeader {
                EnhancedDriverTableHeader()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                
                Divider()
            }
            
            // Driver rows with horizontal scrolling capability
            LazyVStack(spacing: 0) {
                ForEach(appEnvironment.liveSessionState.sortedDrivers) { driver in
                    EnhancedDriverRowView(driver: driver)
                    
                    if driver.id != appEnvironment.liveSessionState.sortedDrivers.last?.id {
                        Divider()
                    }
                }
            }
        }
        .background(Color.platformBackground)
    }
}

struct EnhancedDriverTableHeader: View {
    var body: some View {
        HStack(spacing: 12) {
            // Position
            Text("POS")
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.bold)
                .frame(width: 30)
            
            // Team color
            Rectangle()
                .fill(Color.clear)
                .frame(width: 4, height: 16)
            
            // Driver info
            HStack {
                Text("DRIVER")
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.bold)
                Spacer()
            }
            .frame(width: 80)
            
            // Gap
            Text("GAP")
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.bold)
                .frame(width: 60)
            
            // Interval
            Text("INT")
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.bold)
                .frame(width: 50)
            
            // Best lap
            Text("BEST")
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.bold)
                .frame(width: 80)
            
            // Last lap
            Text("LAST")
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.bold)
                .frame(width: 80)
            
            // Sectors
            HStack(spacing: 8) {
                Text("S1")
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.bold)
                    .frame(width: 50)
                
                Text("S2")
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.bold)
                    .frame(width: 50)
                
                Text("S3")
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.bold)
                    .frame(width: 50)
            }
            
            // Tyre info
            Text("TYRE")
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.bold)
                .frame(width: 40)
        }
        .foregroundStyle(.secondary)
    }
}

struct EnhancedDriverRowView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
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
                
                Text(driver.lastName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 80, alignment: .leading)
            
            // Gap to leader
            Text(timing?.gapToLeader ?? "")
                .font(.system(.caption, design: .monospaced))
                .frame(width: 60, alignment: .trailing)
            
            // Interval
            Text(timing?.intervalToPositionAhead?.value ?? "")
                .font(.system(.caption, design: .monospaced))
                .frame(width: 50, alignment: .trailing)
            
            // Best lap time
          Text(timing?.bestLapTime?.value ?? "")
                .font(.system(.caption, design: .monospaced))
                .frame(width: 80, alignment: .trailing)
            
            // Last lap time
            Text(timing?.lastLapTime?.value ?? "")
                .font(.system(.caption, design: .monospaced))
                .frame(width: 80, alignment: .trailing)
            
            // Sector times
            HStack(spacing: 8) {
                Text(timing?.sectors.first?.value ?? "")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(timing?.sectors.first.map(sectorColor) ?? .primary)
                    .frame(width: 50, alignment: .trailing)
                
                Text(timing?.sectors.count ?? 0 > 1 ? timing?.sectors[1].value ?? "" : "")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(timing?.sectors.count ?? 0 > 1 ? sectorColor(for: timing!.sectors[1]) : .primary)
                    .frame(width: 50, alignment: .trailing)
                
                Text(timing?.sectors.count ?? 0 > 2 ? timing?.sectors[2].value ?? "" : "")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(timing?.sectors.count ?? 0 > 2 ? sectorColor(for: timing!.sectors[2]) : .primary)
                    .frame(width: 50, alignment: .trailing)
            }
            
            // Tyre info
            VStack(spacing: 2) {
                if let currentStint = stints.last {
                    if let compound = currentStint.compound {
                        Text(compound.rawValue.prefix(1))
                            .font(.system(.caption2, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(hex: compound.color) ?? .gray)
                        
                        if let laps = currentStint.totalLaps {
                            Text("\(laps)")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("--")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("--")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 40)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isFavorite ? Color.yellow.opacity(0.1) : Color.clear)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            LapTimeDetailView(driver: driver)
        }
    }
}

#Preview {
    EnhancedDriverListView()
        .environment(AppEnvironment())
}
