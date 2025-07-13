//
//  OptimizedDriverListView.swift
//  F1-Dash
//
//  Performance-optimized driver list with view-specific models
//

import SwiftUI
import F1DashModels

// MARK: - View-Specific Data Model

@Observable
@MainActor
final class DriverListViewModel {
    private let liveSessionState: OptimizedLiveSessionState
    private var lastDriverListVersion = -1
    private var cachedSortedDrivers: [Driver] = []
    
    init(liveSessionState: OptimizedLiveSessionState) {
        self.liveSessionState = liveSessionState
    }
    
    var sortedDrivers: [Driver] {
        let drivers = liveSessionState.driverList
        
        // Only re-sort if driver list changed
        if drivers.count != cachedSortedDrivers.count || 
           drivers.values.first?.id != cachedSortedDrivers.first?.id {
            cachedSortedDrivers = drivers.values.sorted { $0.line < $1.line }
        }
        
        return cachedSortedDrivers
    }
}

// MARK: - Optimized Driver List View

struct OptimizedDriverListView: View {
//    @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @State private var viewModel: DriverListViewModel?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Driver table header
                if appEnvironment.settingsStore.showDriverTableHeader {
                    OptimizedDriverTableHeader()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                    
                    Divider()
                }
                
                if let viewModel = viewModel {
                    let drivers = viewModel.sortedDrivers
                    ForEach(drivers) { driver in
                        OptimizedDriverRowView(
                            driver: driver,
                            isLast: driver.id == drivers.last?.id
                        )
                        .equatable()
                    }
                }
            }
        }
        .background(Color.platformBackground)
        .onAppear {
            if viewModel == nil {
                viewModel = DriverListViewModel(
                    liveSessionState: appEnvironment.liveSessionState 
                )
            }
        }
    }
}

// MARK: - Driver Row Data

struct DriverRowData: Equatable {
    let driver: Driver
    let timing: TimingDataDriver?
    let stints: [Stint]
    let isFavorite: Bool
    
    static func == (lhs: DriverRowData, rhs: DriverRowData) -> Bool {
        lhs.driver.id == rhs.driver.id &&
        lhs.timing?.line == rhs.timing?.line &&
        lhs.timing?.lastLapTime?.value == rhs.timing?.lastLapTime?.value &&
        lhs.timing?.gapToLeader == rhs.timing?.gapToLeader &&
        lhs.stints.count == rhs.stints.count &&
        lhs.stints.first?.compound == rhs.stints.first?.compound &&
        lhs.isFavorite == rhs.isFavorite
    }
}

// MARK: - Optimized Driver Row

struct OptimizedDriverRowView: View, Equatable {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    let driver: Driver
    let isLast: Bool
    @State private var showingDetail = false
    
    static func == (lhs: OptimizedDriverRowView, rhs: OptimizedDriverRowView) -> Bool {
        lhs.driver.id == rhs.driver.id && lhs.isLast == rhs.isLast
    }
    
    @ViewBuilder
    private var driverRowContent: some View {
        let timing = appEnvironment.liveSessionState.timing(for: driver.racingNumber)
        let stints = appEnvironment.liveSessionState.timingAppData?.lines[driver.racingNumber]?.stints ?? []
        let isFavorite = appEnvironment.settingsStore.isFavoriteDriver(driver.racingNumber)
        
        OptimizedDriverRowContent(
            data: DriverRowData(
                driver: driver,
                timing: timing,
                stints: stints,
                isFavorite: isFavorite
            ),
            showDriversBestSectors: appEnvironment.settingsStore.showDriversBestSectors,
            showDriversMiniSectors: appEnvironment.settingsStore.showDriversMiniSectors
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            driverRowContent
                .contentShape(Rectangle())
                .onTapGesture {
                    showingDetail = true
                }
                .popover(isPresented: $showingDetail) {
                    LapTimeDetailView(driver: driver)
                }
            
            if !isLast {
                Divider()
            }
        }
    }
}

// MARK: - Driver Row Content (Pure View)

struct OptimizedDriverRowContent: View, Equatable {
    let data: DriverRowData
    let showDriversBestSectors: Bool
    let showDriversMiniSectors: Bool
    
    static func == (lhs: OptimizedDriverRowContent, rhs: OptimizedDriverRowContent) -> Bool {
        lhs.data == rhs.data &&
        lhs.showDriversBestSectors == rhs.showDriversBestSectors &&
        lhs.showDriversMiniSectors == rhs.showDriversMiniSectors
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Position
            Text(String(data.timing?.line ?? data.driver.line))
                .font(.system(.body, design: .monospaced))
                .fontWeight(.medium)
                .frame(width: 30)
            
            // Team color indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: data.driver.teamColour) ?? .gray)
                .frame(width: 4, height: 24)
            
            // Driver info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(data.driver.tla)
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.bold)
                    
                    if data.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                }
                
                Text(data.driver.broadcastName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            // Tire information
            if !data.stints.isEmpty {
                TireInfoView(stints: data.stints)
                    .frame(maxWidth: 80)
//                    .equatable()
            }
            
            Spacer()
            
            // Timing info
            TimingInfoView(
                timing: data.timing,
                showBestSectors: showDriversBestSectors,
                showMiniSectors: showDriversMiniSectors
            )
            .equatable()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(data.isFavorite ? (Color(hex: data.driver.teamColour) ?? .gray).opacity(0.05) : Color.clear)
    }
}

// MARK: - Timing Info View

struct TimingInfoView: View, Equatable {
    let timing: TimingDataDriver?
    let showBestSectors: Bool
    let showMiniSectors: Bool
    
    static func == (lhs: TimingInfoView, rhs: TimingInfoView) -> Bool {
        lhs.timing?.line == rhs.timing?.line &&
        lhs.timing?.gapToLeader == rhs.timing?.gapToLeader &&
        lhs.timing?.lastLapTime?.value == rhs.timing?.lastLapTime?.value &&
        lhs.showBestSectors == rhs.showBestSectors &&
        lhs.showMiniSectors == rhs.showMiniSectors
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Gap/Interval
            if let timing = timing {
                VStack(alignment: .trailing, spacing: 2) {
                    if let gapToLeader = timing.gapToLeader, !gapToLeader.isEmpty {
                        Text(gapToLeader)
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
            if let lastLapTime = timing?.lastLapTime, !(lastLapTime.value.isEmpty == true) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(lastLapTime.value)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(lastLapTime.personalFastest == true ? .purple : .primary)
                }
                .frame(width: 70, alignment: .trailing)
            }
            
            // Sectors (conditionally rendered)
            if showBestSectors || showMiniSectors {
                SectorViews(
                    sectors: timing?.sectors ?? [],
                    showBestSectors: showBestSectors,
                    showMiniSectors: showMiniSectors
                )
            }
        }
    }
}

// MARK: - Sector Views

struct SectorViews: View {
    let sectors: [Sector]
    let showBestSectors: Bool
    let showMiniSectors: Bool
    
    @ViewBuilder
    var body: some View {
        if showBestSectors && !sectors.isEmpty {
            HStack(spacing: 4) {
                ForEach(Array(sectors.enumerated()), id: \.offset) { index, sector in
                    Text(sector.value)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(sectorColor(for: sector))
                        .frame(minWidth: 30)
                }
            }
        }
        
        if showMiniSectors && !sectors.isEmpty {
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
}

// MARK: - Optimized Header

struct OptimizedDriverTableHeader: View, Equatable {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    static func == (lhs: OptimizedDriverTableHeader, rhs: OptimizedDriverTableHeader) -> Bool {
        true // Header is static based on settings
    }
    
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

// MARK: - Equatable Tire Info

extension TireInfoView: Equatable {
    static func == (lhs: TireInfoView, rhs: TireInfoView) -> Bool {
        lhs.stints.count == rhs.stints.count &&
        lhs.stints.first?.compound == rhs.stints.first?.compound
//        lhs.stints.first?.lapsOnTire == rhs.stints.first?.lapsOnTire
    }
}
