//
//  TrackStatusView.swift
//  F1-Dash
//
//  Displays current track status and flags
//

import SwiftUI
import F1DashModels

struct TrackStatusView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    private var trackStatus: TrackStatus? {
        appEnvironment.liveSessionState.trackStatus
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let trackStatus = trackStatus {
                // Flag indicator
                FlagIndicator(flag: trackStatus.status)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(trackStatus.message)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(trackStatus.status.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            } else {
                Label("No Track Status", systemImage: "flag")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(backgroundForStatus)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var backgroundForStatus: Color {
        guard let status = trackStatus?.status else {
            return Color.platformBackground
        }
        
        // Only use safety car colors if enabled
        if appEnvironment.settingsStore.useSafetyCarColors {
            // Use the color from TrackFlag with opacity
            return (Color(hex: status.color) ?? Color.gray).opacity(0.1)
        } else {
            return Color.platformBackground
        }
    }
}

struct FlagIndicator: View {
    let flag: TrackFlag
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: flag.color) ?? Color.gray)
                .frame(width: 40, height: 30)
            
            if flag == .chequered {
                // Checkered flag pattern
                GeometryReader { geometry in
                    Path { path in
                        let squareSize: CGFloat = 5
                        let rows = Int(geometry.size.height / squareSize)
                        let cols = Int(geometry.size.width / squareSize)
                        
                        for row in 0..<rows {
                            for col in 0..<cols {
                                if (row + col) % 2 == 0 {
                                    let x = CGFloat(col) * squareSize
                                    let y = CGFloat(row) * squareSize
                                    path.addRect(CGRect(x: x, y: y, width: squareSize, height: squareSize))
                                }
                            }
                        }
                    }
                    .fill(Color.black)
                }
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .frame(width: 40, height: 30)
            } else if flag == .scYellow || flag == .scRed {
                Text("SC")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            } else if flag == .vsc {
                Text("VSC")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        }
    }
}


#Preview {
    VStack(spacing: 16) {
        TrackStatusView()
            .environment(AppEnvironment())
        
        // Preview with different flags
        ForEach([TrackFlag.green, .yellow, .red, .chequered], id: \.self) { flag in
            HStack {
                FlagIndicator(flag: flag)
                Text(flag.displayName)
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    .padding()
    .frame(width: 300)
}
