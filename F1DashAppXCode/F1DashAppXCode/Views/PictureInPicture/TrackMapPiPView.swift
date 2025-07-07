//
//  TrackMapPiPView.swift
//  F1-Dash
//
//  Wrapper view for PiP content that ensures environment is available
//

import SwiftUI

struct TrackMapPiPView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    var body: some View {
        if appEnvironment.pictureInPictureManager.isPiPActive {
            TrackMapPiPContent(appEnvironment: appEnvironment)
        }
    }
}
