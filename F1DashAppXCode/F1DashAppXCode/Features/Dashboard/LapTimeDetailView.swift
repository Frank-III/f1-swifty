//
//  LapTimeDetailView.swift
//  F1-Dash
//
//  Detailed lap time and sector information
//

import SwiftUI
import F1DashModels

struct LapTimeDetailView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    let driver: Driver
    
    private var timing: TimingDataDriver? {
        appEnvironment.liveSessionState.timing(for: driver.racingNumber)
    }
    
    private var timingStats: TimingStatsDriver? {
        appEnvironment.liveSessionState.timingStats?.lines[driver.racingNumber]
    }
    
    private var carData: CarDataChannels? {
        appEnvironment.liveSessionState.carData?.entries.last?.cars[driver.racingNumber]
    }
    
    private var stints: [Stint] {
        appEnvironment.liveSessionState.timingAppData?.lines[driver.racingNumber]?.stints ?? []
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: driver.teamColour) ?? .gray)
                    .frame(width: 4, height: 30)
                
                VStack(alignment: .leading) {
                    Text(driver.tla)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(driver.broadcastName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("#\(driver.racingNumber)")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // Lap times
            VStack(alignment: .leading, spacing: 12) {
                // Best lap time
              if let bestLap = timing?.bestLapTime?.value, !bestLap.isEmpty {
                    LapTimeRow(
                        title: "Best Lap",
                        time: bestLap,
                        isPersonalBest: true,
                        isOverallBest: timingStats?.personalBestLapTime?.value == bestLap
                    )
                }
                
                // Last lap time
                if let lastLap = timing?.lastLapTime {
                    LapTimeRow(
                        title: "Last Lap",
                        time: lastLap.value,
                        isPersonalBest: lastLap.personalFastest,
                        isOverallBest: lastLap.overallFastest
                    )
                }
            }
            
            Divider()
            
            // Sector times
            if appEnvironment.settingsStore.showDriversBestSectors,
               let sectors = timing?.sectors, !sectors.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sectors")
                        .font(.headline)
                    
                    HStack(spacing: 16) {
                        ForEach(Array(sectors.enumerated()), id: \.offset) { index, sector in
                            SectorView(
                                sectorNumber: index + 1,
                                sector: sector,
                                bestSector: timingStats?.bestSectors[safe: index],
                                showMiniSectors: appEnvironment.settingsStore.showDriversMiniSectors
                            )
                        }
                    }
                }
            }
            
            Divider()
            
            // Speed trap
            if let bestSpeeds = timingStats?.bestSpeeds {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Speed Trap")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        SpeedTrapItem(label: "I1", speed: bestSpeeds.i1?.value ?? "")
                        SpeedTrapItem(label: "I2", speed: bestSpeeds.i2?.value ?? "")
                        SpeedTrapItem(label: "FL", speed: bestSpeeds.fl?.value ?? "")
                        SpeedTrapItem(label: "ST", speed: bestSpeeds.st?.value ?? "")
                    }
                }
            }
            
            Divider()
            
            // Gap information
            if let timing = timing {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gaps")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        if let gapToLeader = timing.gapToLeader, !gapToLeader.isEmpty {
                            GapItem(label: "To Leader", value: gapToLeader)
                        }
                        
                        if let interval = timing.intervalToPositionAhead {
                            GapItem(
                                label: "Interval",
                                value: interval.value,
                                isCatching: interval.catching ?? false
                            )
                        }
                    }
                }
            }
            
            Divider()
            
            // Tire strategy
            DetailedTireInfoView(stints: stints)
            
            Divider()
            
            // Car telemetry
            CarMetricsView(carData: carData)
        }
        .padding()
        .frame(width: 350)
        .background(Color.platformBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Components

struct LapTimeRow: View {
    let title: String
    let time: String
    let isPersonalBest: Bool
    let isOverallBest: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text(time)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(isPersonalBest ? .medium : .regular)
                    .foregroundStyle(isOverallBest ? .purple : .primary)
                
                if isOverallBest {
                    Image(systemName: "crown.fill")
                        .font(.caption)
                        .foregroundStyle(.purple)
                } else if isPersonalBest {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
            }
        }
    }
}

struct SectorView: View {
    let sectorNumber: Int
    let sector: Sector
    let bestSector: PersonalBestLapTime?
    let showMiniSectors: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text("S\(sectorNumber)")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(sector.value)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(sector.personalFastest ? .medium : .regular)
                .foregroundStyle(sectorColor)
            
            if let best = bestSector {
                Text(best.value)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            
            // Mini segments (if enabled)
            if showMiniSectors {
                HStack(spacing: 2) {
                    ForEach(Array(sector.segments.enumerated()), id: \.offset) { _, segment in
                        RoundedRectangle(cornerRadius: 1)
                        .fill(segmentColor(for: segment.status))
                            .frame(width: 12, height: 3)
                    }
                }
            }
        }
        .frame(minWidth: 60)
    }
    
    private var sectorColor: Color {
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
}

struct SpeedTrapItem: View {
    let label: String
    let speed: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(speed)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.medium)
            
            Text("km/h")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}

struct GapItem: View {
    let label: String
    let value: String
    var isCatching: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 4) {
                Text(value)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.medium)
                
                if isCatching {
                    Image(systemName: "arrow.down")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
        }
    }
}

// MARK: - Safe Array Access

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    LapTimeDetailView(
        driver: Driver(
            racingNumber: "1",
            broadcastName: "M. VERSTAPPEN",
            fullName: "Max Verstappen",
            tla: "VER",
            line: 1,
            teamName: "Red Bull Racing",
            teamColour: "3671C6",
            firstName: "Max",
            lastName: "Verstappen",
            reference: "VERSTAPPEN",
            headshotUrl: nil,
            countryCode: "NL"
        )
    )
    .environment(AppEnvironment())
    .padding()
}
