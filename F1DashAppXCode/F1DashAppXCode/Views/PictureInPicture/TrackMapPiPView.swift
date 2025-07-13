//
//  TrackMapPiPView.swift
//  F1-Dash
//
//  Wrapper view for PiP content that ensures environment is available
//

import SwiftUI

struct TrackMapPiPView: View {
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        if appEnvironment.pictureInPictureManager.isPiPActive {
            // TrackMapPiPContent(appEnvironment: appEnvironment)
            OptimizedTrackMapPiPContent(appEnvironment: appEnvironment)
        }
    }
}
