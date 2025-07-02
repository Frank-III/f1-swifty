//
//  TireInfoView.swift
//  F1-Dash
//
//  Tire compound and stint information display
//

import SwiftUI
import F1DashModels

struct TireInfoView: View {
    let stints: [Stint]
    
    var body: some View {
        HStack(spacing: 8) {
            if let currentStint = stints.last {
                // Current tire compound
                TireCompoundIndicator(
                    compound: currentStint.compound,
                    laps: currentStint.totalLaps,
                    isNew: currentStint.isNew
                )
                
                // Stint history if more than one stint
                if stints.count > 1 {
                    Text("•")
                        .foregroundStyle(.secondary)
                        .font(.caption2)
                    
                    StintHistoryView(stints: Array(stints.dropLast()))
                }
            } else {
                Text("No tire data")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Tire Compound Indicator

struct TireCompoundIndicator: View {
    let compound: TireCompound?
    let laps: Int?
    let isNew: Bool?
    
    var body: some View {
        HStack(spacing: 4) {
            // Tire compound circle
            Circle()
                .fill(compoundColor)
                .frame(width: 16, height: 16)
                .overlay(
                    Text(compound?.shortCode ?? "?")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(textColor)
                )
            
            // Lap count
            if let laps = laps {
                Text("\(laps)")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            
            // New tire indicator
            if isNew == true {
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(.yellow)
            }
        }
    }
    
    private var compoundColor: Color {
        guard let compound = compound else { return .gray }
        return Color(hex: compound.color) ?? .gray
    }
    
    private var textColor: Color {
        // Use black text for light colored tires (white, yellow)
        // Use white text for dark colored tires (red, green, blue)
        guard let compound = compound else { return .primary }
        switch compound {
        case .hard, .medium:
            return .black
        case .soft, .intermediate, .wet:
            return .white
        }
    }
}

// MARK: - Stint History View

struct StintHistoryView: View {
    let stints: [Stint]
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(stints.enumerated()), id: \.offset) { index, stint in
                CompactTireIndicator(compound: stint.compound)
            }
        }
    }
}

// MARK: - Compact Tire Indicator

struct CompactTireIndicator: View {
    let compound: TireCompound?
    
    var body: some View {
        Circle()
            .fill(compoundColor)
            .frame(width: 8, height: 8)
    }
    
    private var compoundColor: Color {
        guard let compound = compound else { return .gray.opacity(0.3) }
        return Color(hex: compound.color) ?? .gray
    }
}

// MARK: - Detailed Tire Info View

struct DetailedTireInfoView: View {
    let stints: [Stint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tire Strategy")
                .font(.headline)
            
            if !stints.isEmpty {
                VStack(spacing: 6) {
                    // Header
                    HStack {
                        Text("Stint")
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(width: 40, alignment: .leading)
                        
                        Text("Compound")
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(width: 80, alignment: .leading)
                        
                        Text("Laps")
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(width: 40, alignment: .trailing)
                        
                        Text("Condition")
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .foregroundStyle(.secondary)
                    
                    Divider()
                    
                    // Stint rows
                    ForEach(Array(stints.enumerated()), id: \.offset) { index, stint in
                        StintRow(stintNumber: index + 1, stint: stint, isCurrent: index == stints.count - 1)
                    }
                }
            } else {
                ContentUnavailableView(
                    "No Tire Data",
                    systemImage: "circle.dotted",
                    description: Text("Tire strategy information will appear here during a session")
                )
                .frame(height: 80)
            }
        }
    }
}

// MARK: - Stint Row

struct StintRow: View {
    let stintNumber: Int
    let stint: Stint
    let isCurrent: Bool
    
    var body: some View {
        HStack {
            // Stint number
            Text("\(stintNumber)")
                .font(.caption)
                .fontWeight(isCurrent ? .bold : .regular)
                .frame(width: 40, alignment: .leading)
            
            // Compound with indicator
            HStack(spacing: 6) {
                TireCompoundIndicator(
                    compound: stint.compound,
                    laps: nil,
                    isNew: stint.isNew
                )
                
                Text(stint.compound?.displayName ?? "Unknown")
                    .font(.caption)
            }
            .frame(width: 80, alignment: .leading)
            
            // Lap count
            Text(stint.totalLaps.map { "\($0)" } ?? "-")
                .font(.caption)
                .fontWeight(isCurrent ? .bold : .regular)
                .frame(width: 40, alignment: .trailing)
            
            // Condition and current indicator
            HStack {
                if stint.isNew == true {
                    Text("New")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .foregroundStyle(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                
                if isCurrent {
                    Text("Current")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .foregroundStyle(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 2)
        .background(isCurrent ? Color.blue.opacity(0.05) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#Preview {
    let sampleStints = [
        Stint(totalLaps: 15, compound: .hard, isNew: true),
        Stint(totalLaps: 22, compound: .medium, isNew: false),
        Stint(totalLaps: 8, compound: .soft, isNew: true)
    ]
    
    VStack(spacing: 20) {
        // Compact view
        TireInfoView(stints: sampleStints)
        
        Divider()
        
        // Detailed view
        DetailedTireInfoView(stints: sampleStints)
        
        Divider()
        
        // Empty state
        TireInfoView(stints: [])
    }
    .padding()
    .frame(width: 300)
}