//
//  TrackMapSection.swift
//  F1-Dash
//
//  Track map dashboard section component
//

import SwiftUI

struct TrackMapSection: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @Binding var showTrackMapFullScreen: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Track Map")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                
                if appEnvironment.connectionStatus == .connected {
                    #if os(iOS) || os(iPadOS)
                    // Picture in Picture button
                    Button {
                        // Stop video PiP if active before starting regular PiP
                        if appEnvironment.videoBasedPictureInPictureManager.isVideoPiPActive {
                            appEnvironment.videoBasedPictureInPictureManager.stopVideoPiP()
                        }
                        appEnvironment.pictureInPictureManager.togglePiP()
                    } label: {
                        Image(systemName: appEnvironment.pictureInPictureManager.isPiPActive ? "pip.exit" : "pip.enter")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(PlatformGlassButtonStyle())
                    .disabled(appEnvironment.videoBasedPictureInPictureManager.isVideoPiPActive)
                    
                    // Video-based PiP button (for background support)
                    Button {
                        Task {
                            if appEnvironment.videoBasedPictureInPictureManager.isVideoPiPActive {
                                appEnvironment.videoBasedPictureInPictureManager.stopVideoPiP()
                            } else {
                                // Stop regular PiP if active before starting video PiP
                                if appEnvironment.pictureInPictureManager.isPiPActive {
                                    appEnvironment.pictureInPictureManager.deactivatePiP()
                                }
                                await appEnvironment.videoBasedPictureInPictureManager.startVideoPiP()
                            }
                        }
                    } label: {
                        Image(systemName: appEnvironment.videoBasedPictureInPictureManager.isVideoPiPActive ? "tv.slash" : "tv")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(PlatformGlassButtonStyle())
                    .disabled(appEnvironment.pictureInPictureManager.isPiPActive)
                    #endif
                    
                    // Full screen button
                    Button {
                        showTrackMapFullScreen = true
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(PlatformGlassButtonStyle())
                }
            }
            
            if appEnvironment.connectionStatus == .disconnected {
                DisconnectedStateView(
                    title: "Track Map Not Available",
                    message: "Connect to live session to view track positions",
                    iconName: "map.fill",
                    minHeight: 200
                )
            } else {
                // Responsive track map
                GeometryReader { geometry in
                    OptimizedTrackMapView(circuitKey: String(appEnvironment.liveSessionState.sessionInfo?.meeting?.circuit.key ?? 0))
                        .frame(width: geometry.size.width, height: geometry.size.width * 0.6) // 16:10 aspect ratio
                }
                .aspectRatio(16/10, contentMode: .fit)
                .frame(minHeight: 200, maxHeight: 400)
            }
        }
        .padding()
        .modifier(PlatformGlassCardModifier())
    }
}
