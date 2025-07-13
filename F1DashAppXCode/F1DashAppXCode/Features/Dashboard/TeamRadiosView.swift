//
//  TeamRadiosView.swift
//  F1DashAppXCode
//
//  Displays team radio communications with playback controls
//

import SwiftUI
import AVKit
import F1DashModels

struct TeamRadiosView: View {
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    private var teamRadios: [RadioCapture] {
        appEnvironment.liveSessionState.teamRadio?.captures ?? []
    }
    
    private var sessionPath: String? {
        appEnvironment.liveSessionState.sessionInfo?.path
    }
    
    private var gmtOffset: String {
        appEnvironment.liveSessionState.sessionInfo?.gmtOffset ?? "00:00:00"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Label("Team Radio", systemImage: "radio")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !teamRadios.isEmpty {
                    Text("\(teamRadios.count) messages")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Radio messages list
            if appEnvironment.connectionStatus == .disconnected {
                CompactDisconnectedStateView(title: "Team Radio not available")
            } else if teamRadios.isEmpty {
                ContentUnavailableView(
                    "No Radio Messages",
                    systemImage: "radio",
                    description: Text("Team radio messages will appear here during the session")
                )
                .frame(height: 200)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        // Show latest 20 messages
                        ForEach(sortedRadios.prefix(20), id: \.path) { radio in
                            if let driver = appEnvironment.liveSessionState.driver(for: radio.racingNumber) {
                                RadioMessageView(
                                    radio: radio,
                                    driver: driver,
                                    basePath: basePath,
                                    gmtOffset: gmtOffset,
                                    isFavorite: appEnvironment.settingsStore.isFavoriteDriver(radio.racingNumber)
                                )
                            }
                        }
                    }
                }
                .frame(maxHeight: 400)
            }
        }
        .padding()
        .background(Color.platformBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var sortedRadios: [RadioCapture] {
        teamRadios.sorted { $0.utc > $1.utc }
    }
    
    private var basePath: String {
        guard let path = sessionPath else { return "" }
        return "https://livetiming.formula1.com/static/\(path)"
    }
}

// MARK: - Radio Message View

struct RadioMessageView: View {
    let radio: RadioCapture
    let driver: Driver
    let basePath: String
    let gmtOffset: String
    let isFavorite: Bool
    
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var duration: Double = 10
    @State private var player: AVPlayer?
    @State private var timeObserver: Any?
    
    private var localTime: String {
        radio.timestamp?.formatted(date: .omitted, time: .standard) ?? radio.utc
    }
    
    private var trackTime: String {
        // Convert to track time using GMT offset
        // This is simplified - in production you'd properly parse the offset
        radio.timestamp?.formatted(date: .omitted, time: .shortened) ?? ""
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Timestamp
            HStack(spacing: 8) {
                Text(localTime)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("·")
                    .foregroundStyle(.tertiary)
                
                Text(trackTime)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            
            // Main content
            HStack(spacing: 12) {
                // Driver tag
                DriverTag(
                    tla: driver.tla,
                    teamColor: Color(hex: driver.teamColour) ?? .gray
                )
                
                // Play button
                Button {
                    togglePlayback()
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title2)
                        .foregroundStyle(isPlaying ? .orange : .blue)
                }
                .buttonStyle(.plain)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 2)
                            .fill(isPlaying ? Color.orange : Color.blue)
                            .frame(width: geometry.size.width * progress, height: 4)
                    }
                }
                .frame(height: 4)
                
                // Duration
                Text(formatTime(duration * progress) + " / " + formatTime(duration))
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .frame(width: 80, alignment: .trailing)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isFavorite ? Color.blue.opacity(0.1) : Color.platformSecondaryBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isFavorite ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .onDisappear {
            cleanup()
        }
    }
    
    private func togglePlayback() {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            if player == nil {
                setupPlayer()
            }
            player?.play()
            isPlaying = true
        }
    }
    
    private func setupPlayer() {
        let url = URL(string: basePath + radio.path)!
        player = AVPlayer(url: url)
        
        // Get duration
        player?.currentItem?.asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            DispatchQueue.main.async { [self] in
                if let duration = player?.currentItem?.duration {
                    self.duration = CMTimeGetSeconds(duration)
                }
            }
        }
        
        // Track progress
        let interval = CMTime(seconds: 0.01, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [self] time in
            guard let player = player, let duration = player.currentItem?.duration else { return }
            
            let currentTime = CMTimeGetSeconds(time)
            let totalTime = CMTimeGetSeconds(duration)
            
            if totalTime > 0 {
                self.progress = currentTime / totalTime
            }
            
            // Check if playback ended
            if currentTime >= totalTime {
                self.isPlaying = false
                self.progress = 0
                self.player?.seek(to: .zero)
            }
        }
    }
    
    private func cleanup() {
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        player = nil
        isPlaying = false
        progress = 0
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Driver Tag

struct DriverTag: View {
    let tla: String
    let teamColor: Color
    
    var body: some View {
        Text(tla)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(teamColor)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

// MARK: - Compact Version for Dashboard

struct CompactTeamRadiosView: View {
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    private var latestRadios: [RadioCapture] {
        let radios = appEnvironment.liveSessionState.teamRadio?.captures ?? []
        return Array(radios.sorted { $0.utc > $1.utc }.prefix(3))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Recent Radio", systemImage: "radio")
                .font(.subheadline)
                .fontWeight(.medium)
            
            if latestRadios.isEmpty {
                Text("No recent messages")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 6) {
                    ForEach(latestRadios, id: \.path) { radio in
                        if let driver = appEnvironment.liveSessionState.driver(for: radio.racingNumber) {
                            HStack(spacing: 8) {
                                DriverTag(
                                    tla: driver.tla,
                                    teamColor: Color(hex: driver.teamColour) ?? .gray
                                )
                                
                                Text(radio.timestamp?.formatted(date: .omitted, time: .shortened) ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                Image(systemName: "play.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color.platformBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview("Team Radios View") {
    TeamRadiosView()
        .environment(OptimizedAppEnvironment())
        .frame(width: 400)
        .padding()
}

#Preview("Compact Team Radios") {
    CompactTeamRadiosView()
        .environment(OptimizedAppEnvironment())
        .frame(width: 300)
        .padding()
}