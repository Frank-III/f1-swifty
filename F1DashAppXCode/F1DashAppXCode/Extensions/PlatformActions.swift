//
//  PlatformActions.swift
//  F1-Dash
//
//  Platform-specific action handlers
//

import SwiftUI

#if os(macOS)
import AppKit
#endif

struct PlatformActions {
    /// Opens the settings window (macOS only)
    @MainActor
    static func openSettings() {
        #if os(macOS)
        if #available(macOS 14.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
        #endif
    }
    
    /// Shows the main dashboard window (macOS only)
    @MainActor
    static func showDashboard() {
        #if os(macOS)
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.title == "F1 Dash" }) {
            window.makeKeyAndOrderFront(nil)
        }
        #endif
    }
    
    /// Quits the application
    @MainActor
    static func quit() {
        #if os(macOS)
        NSApp.terminate(nil)
        #else
        // On iOS, we don't typically quit apps programmatically
        // The system manages app lifecycle
        #endif
    }
    
    /// Minimizes the current window (macOS only)
    @MainActor
    static func minimizeWindow() {
        #if os(macOS)
        NSApp.keyWindow?.miniaturize(nil)
        #endif
    }
    
    /// Brings the app to front (macOS only)
    @MainActor
    static func bringToFront() {
        #if os(macOS)
        NSApp.activate(ignoringOtherApps: true)
        #endif
    }
}

// MARK: - View Extension for Platform Actions

extension View {
    /// Adds a settings button that works across platforms
    func settingsButton() -> some View {
        Button {
            PlatformActions.openSettings()
        } label: {
            Image(systemName: "gear")
                .font(.callout)
        }
        .buttonStyle(.plain)
    }
    
    /// Adds a quit button (macOS only, hidden on iOS)
    @ViewBuilder
    func quitButton(_ title: String = "Quit") -> some View {
        #if os(macOS)
        Button(title) {
            PlatformActions.quit()
        }
        .buttonStyle(.plain)
        #endif
    }
}