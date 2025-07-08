//
//  F1DashAppXCodeApp.swift
//  F1DashAppXCode
//
//  Created by Jiangda on 7/2/25.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

@main
struct F1DashAppXCodeApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    @State private var appEnvironment = AppEnvironment()
    
    
    var body: some Scene {
        #if os(macOS)
        // Settings window
        Settings {
            SettingsView()
                .environment(appEnvironment)
        }
        
        // Main window scene (hidden by default)
        WindowGroup("F1 Dashboard", id: "dashboard") {
          MainTabView()
              .environment(appEnvironment)
//            MacOSDashboardView()
//                .environment(appEnvironment)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
//        .defaultSize(width: 1200, height: 800)
        .defaultPosition(.center)
        .commands {
            commands
        }
        
        // Menu bar extra
        MenuBarExtra("F1 Dash", systemImage: "flag.checkered.circle.fill") {
            SimplePopoverView()
                .environment(appEnvironment)
                .onAppear {
                    // Set the app environment in the delegate when the menu bar extra appears
                    AppDelegate.shared = appDelegate
                    appDelegate.setAppEnvironment(appEnvironment)
                }
        }
        .menuBarExtraStyle(.window)
        #else
        // iOS/iPadOS main window
        WindowGroup {
            MainTabView()
                .environment(appEnvironment)
                #if !os(macOS)
               .pictureInPictureOverlay(appEnvironment: appEnvironment)
                #endif
        }
        #endif
    }
}

// MARK: - App Delegate (macOS only)

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate?
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    var appEnvironment: AppEnvironment?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon for menu bar app
        // NOTE: Commented out for debugging - uncomment for release
        // NSApp.setActivationPolicy(.accessory)
        
        // Auto-connect on launch
        Task { @MainActor in
            // AppEnvironment will be set up by the SwiftUI app
        }
    }
    
    func setAppEnvironment(_ environment: AppEnvironment) {
        self.appEnvironment = environment
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
        // Don't open settings window if dashboard window is open
        if let appEnvironment = appEnvironment, appEnvironment.isDashboardWindowOpen {
            return
        }
        
        if #available(macOS 14.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }
    
    private var dashboardWindow: NSWindow?
    
    @MainActor
    @objc func showDashboard() {
        // Activate the app first
        NSApp.activate(ignoringOtherApps: true)
        
        // Check if we already have a dashboard window
        if let existingWindow = dashboardWindow {
            existingWindow.makeKeyAndOrderFront(nil)
            existingWindow.orderFrontRegardless()
            
            // If window was closed, recreate it
            if !existingWindow.isVisible {
                createDashboardWindow()
            }
            return
        }
        
        // Look for existing dashboard window by title
        if let dashboardWindow = NSApp.windows.first(where: { window in
            window.title == "F1 Dashboard"
        }) {
            self.dashboardWindow = dashboardWindow
            dashboardWindow.makeKeyAndOrderFront(nil)
            dashboardWindow.orderFrontRegardless()
            return
        }
        
        // Create new window if none exists
        createDashboardWindow()
    }
    
    @MainActor
    private func createDashboardWindow() {
        if #available(macOS 13.0, *) {
            Task { @MainActor in
                // Force the app to show in dock temporarily to create window
                NSApp.setActivationPolicy(.regular)
                
                if let env = appEnvironment {
                    let dashboardView = MainTabView()
                        .environment(env)
                    
                    let hostingController = NSHostingController(rootView: dashboardView)
                    let window = NSWindow(contentViewController: hostingController)
                    
                    window.title = "F1 Dashboard"
                    window.setContentSize(NSSize(width: 1200, height: 800))
                    window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
                    window.titlebarAppearsTransparent = true
                    window.titleVisibility = .hidden
                    window.center()
                    window.makeKeyAndOrderFront(nil)
                    
                    // Store reference to prevent deallocation
                    window.isReleasedWhenClosed = false
                    
                    // Keep reference to the window
                    self.dashboardWindow = window
                }
                
                // Set back to accessory after window creation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Uncomment for menu bar app behavior
                    // NSApp.setActivationPolicy(.accessory)
                }
            }
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
extension F1DashAppXCodeApp {
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
