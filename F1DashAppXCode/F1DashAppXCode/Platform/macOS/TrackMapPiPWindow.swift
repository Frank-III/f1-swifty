//
//  TrackMapPiPWindow.swift
//  F1-Dash
//
//  macOS Picture-in-Picture window for track map
//

#if os(macOS)
import SwiftUI
import AppKit

struct TrackMapPiPWindow: Scene {
    let appEnvironment: AppEnvironment
    
    var body: some Scene {
        Window("Track Map", id: "track-map-pip") {
            TrackMapPiPContent(appEnvironment: appEnvironment)
                .environment(appEnvironment)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.topTrailing)
    }
}

// MARK: - Window Controller

extension PictureInPictureManager {
    func createMacOSPiPWindowAlternative() {
        // This is an alternative approach using SwiftUI Scene
        // The actual implementation in PictureInPictureManager uses NSWindow directly
        // which provides more control over window behavior
    }
}
#endif