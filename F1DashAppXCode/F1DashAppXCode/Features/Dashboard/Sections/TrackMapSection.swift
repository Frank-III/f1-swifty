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
    @State private var showUniversalOverlayPiP: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Track Map")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                
                if appEnvironment.connectionStatus == .connected {
                    #if os(iOS) || os(iPadOS)
                    // Universal Overlay PiP button (NEW - smooth floating)
                    Button {
                        // Stop other PiP modes if active
                        if appEnvironment.videoBasedPictureInPictureManager.isVideoPiPActive {
                            appEnvironment.videoBasedPictureInPictureManager.stopVideoPiP()
                        }
                        if appEnvironment.pictureInPictureManager.isPiPActive {
                            appEnvironment.pictureInPictureManager.deactivatePiP()
                        }
                        showUniversalOverlayPiP.toggle()
                    } label: {
                        Image(systemName: showUniversalOverlayPiP ? "rectangle.inset.filled" : "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(PlatformGlassButtonStyle())
                    .universalOverlay(show: $showUniversalOverlayPiP) {
                        FloatingTrackMapView(show: $showUniversalOverlayPiP)
                    }
                    
                    // Legacy Picture in Picture button
                    Button {
                        // Stop other PiP modes if active
                        if appEnvironment.videoBasedPictureInPictureManager.isVideoPiPActive {
                            appEnvironment.videoBasedPictureInPictureManager.stopVideoPiP()
                        }
                        if showUniversalOverlayPiP {
                            showUniversalOverlayPiP = false
                        }
                        appEnvironment.pictureInPictureManager.togglePiP()
                    } label: {
                        Image(systemName: appEnvironment.pictureInPictureManager.isPiPActive ? "pip.exit" : "pip.enter")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(PlatformGlassButtonStyle())
                    .disabled(appEnvironment.videoBasedPictureInPictureManager.isVideoPiPActive || showUniversalOverlayPiP)
                    
                    // Video-based PiP button (for background support)
                    Button {
                        Task {
                            if appEnvironment.videoBasedPictureInPictureManager.isVideoPiPActive {
                                appEnvironment.videoBasedPictureInPictureManager.stopVideoPiP()
                            } else {
                                // Stop other PiP modes if active
                                if appEnvironment.pictureInPictureManager.isPiPActive {
                                    appEnvironment.pictureInPictureManager.deactivatePiP()
                                }
                                if showUniversalOverlayPiP {
                                    showUniversalOverlayPiP = false
                                }
                                await appEnvironment.videoBasedPictureInPictureManager.startVideoPiP()
                            }
                        }
                    } label: {
                        Image(systemName: appEnvironment.videoBasedPictureInPictureManager.isVideoPiPActive ? "tv.slash" : "tv")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(PlatformGlassButtonStyle())
                    .disabled(appEnvironment.pictureInPictureManager.isPiPActive || showUniversalOverlayPiP)
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
