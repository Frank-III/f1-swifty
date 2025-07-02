//
//  F1DashApp.swift
//  F1-Dash
//
//  Main app entry point for all platforms
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

@main
struct F1DashApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    @State private var appEnvironment = AppEnvironment()
    
    var body: some Scene {
        #if os(macOS)
        // macOS-specific scenes
        Group {
            // Settings window
            Settings {
                SettingsView()
                    .environment(appEnvironment)
            }
            
            // Main window scene (hidden by default)
            WindowGroup("F1 Dash") {
                DashboardView()
                    .environment(appEnvironment)
            }
            .windowStyle(.hiddenTitleBar)
            .windowResizability(.contentSize)
            .defaultSize(width: 400, height: 600)
            
            // Menu bar extra
            MenuBarExtra("F1 Dash", systemImage: "flag.checkered.circle.fill") {
                PopoverDashboardView()
                    .environment(appEnvironment)
            }
            .menuBarExtraStyle(.window)
        }
        #else
        // iOS/iPadOS main window
        WindowGroup {
            MainTabView()
                .environment(appEnvironment)
        }
        #endif
    }
}

// MARK: - App Delegate (macOS only)

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var appEnvironment: AppEnvironment?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon for menu bar app
        // NOTE: Commented out for debugging - uncomment for release
        // NSApp.setActivationPolicy(.accessory)
        
        // Auto-connect on launch
        Task { @MainActor in
            // AppEnvironment will be set up by the SwiftUI app
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean disconnect
        Task { @MainActor in
            if let env = appEnvironment {
                await env.disconnect()
            }
        }
    }
    
    @MainActor
    @objc func openSettings() {
        if #available(macOS 14.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }
    
    @MainActor
    @objc func showDashboard() {
        // Show the main window
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.title == "F1 Dash" }) {
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    @MainActor
    @objc func quit() {
        NSApp.terminate(nil)
    }
}
#endif

// MARK: - Menu Commands (macOS only)

#if os(macOS)
extension F1DashApp {
    var commands: some Commands {
        Group {
            CommandGroup(replacing: .appInfo) {
                Button("About F1 Dash") {
                    showAboutPanel()
                }
            }
            
            CommandGroup(after: .appInfo) {
                Divider()
                Button("Open Dashboard") {
                    NSApp.sendAction(#selector(AppDelegate.showDashboard), to: nil, from: nil)
                }
                .keyboardShortcut("d", modifiers: [.command])
            }
        }
    }
    
    private func showAboutPanel() {
        let aboutView = VStack(spacing: 16) {
            Image(systemName: "flag.checkered.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.red)
            
            Text("F1 Dash")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Live F1 Timing Data")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("Version 1.0.0")
                .font(.caption)
            
            Divider()
            
            Text("A native macOS client for F1 live timing data")
                .font(.caption)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 250)
        }
        .padding(32)
        .frame(width: 350, height: 300)
        
        let hostingController = NSHostingController(rootView: aboutView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "About F1 Dash"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.center()
        window.makeKeyAndOrderFront(nil)
    }
}
#endif
