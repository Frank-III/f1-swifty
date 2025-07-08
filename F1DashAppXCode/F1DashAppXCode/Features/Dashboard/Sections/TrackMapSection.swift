//
//  TrackMapSection.swift
//  F1-Dash
//
//  Track map dashboard section component
//

import SwiftUI

struct TrackMapSection: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    @Binding var showTrackMapFullScreen: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Track Map")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                
                #if !os(macOS)
                // Picture in Picture button
                Button {
                    appEnvironment.pictureInPictureManager.togglePiP()
                } label: {
                    Image(systemName: appEnvironment.pictureInPictureManager.isPiPActive ? "pip.exit" : "pip.enter")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(PlatformGlassButtonStyle())
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
            
            TrackMapView()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
        }
        .padding()
        .modifier(PlatformGlassCardModifier())
    }
}