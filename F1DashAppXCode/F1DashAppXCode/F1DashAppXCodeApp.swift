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
import RevenueCat

// TEST MODE - Simple isolated track map test
//@main
//struct F1DashAppXCodeApp: App {
//    var body: some Scene {
//        WindowGroup {
//            TestIsolatedTrackMap()
//                .frame(width: 800, height: 600)
//        }
//    }
//}

/// The main F1 Dashboard application structure.
///
/// This app provides a comprehensive F1 live timing experience across multiple platforms
/// with specialized interfaces for different use cases and device types.
///
/// ## Key Features
/// - **Multi-Platform Support**: Native experiences for macOS, iOS, and iPadOS
/// - **Menu Bar Integration**: Quick access via macOS menu bar with live data
/// - **Full Dashboard View**: Comprehensive timing data in a dedicated window
/// - **Settings Management**: Configurable preferences and connection settings
/// - **Live Data Streaming**: Real-time F1 timing data with optimized performance
///
/// ## Application Architecture
/// ```
/// F1DashAppXCodeApp (main)
/// ├── macOS Scenes
/// │   ├── Settings Window
/// │   │   └── SettingsView()
/// │   ├── Dashboard Window (hidden by default)
/// │   │   └── MainTabView()
/// │   └── MenuBarExtra
/// │       └── SimplePopoverView()
/// └── iOS/iPadOS Scenes
///     └── Main Window
///         └── MainTabView()
/// ```
///
/// ## State Management
/// The app uses `OptimizedAppEnvironment` for centralized state management:
/// - **Connection Management**: Handles F1 API connections and disconnections
/// - **Data Synchronization**: Ensures consistent data across all views
/// - **Window State Tracking**: Manages which windows are open (prevents conflicts)
/// - **Performance Optimization**: Efficient data updates and memory management
///
/// ## Platform-Specific Behaviors
/// ### macOS
/// - **Menu Bar App**: Primary interface via menu bar icon with system integration
/// - **Dashboard Window**: On-demand full-screen timing data (Cmd+D to open)
/// - **Settings Window**: System-standard preferences window
/// - **App Delegate**: Handles application lifecycle and window management
/// - **Dock Integration**: Can hide from dock for menu bar-only operation
///
/// ### iOS/iPadOS  
/// - **Full Screen App**: MainTabView as primary interface
/// - **Touch Optimized**: UI adapted for touch interaction
/// - **Native Navigation**: Standard iOS navigation patterns
@main
struct F1DashAppXCodeApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    // @State private var appEnvironment = AppEnvironment()
    @State private var appEnvironment = OptimizedAppEnvironment()
    @State private var premiumStore = PremiumStore()
    
    init() {
        // Configure RevenueCat
        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        
        // TODO: Replace with your actual RevenueCat API key
        // Get it from https://app.revenuecat.com
        let apiKey = "appl_SleKyNbPDNXlbVAbKnexDeCOGlz"
        
        if apiKey != "YOUR_REVENUECAT_API_KEY" {
            Purchases.configure(withAPIKey: apiKey)
        } else {
            print("⚠️ RevenueCat API key not configured - purchases will not work!")
        }
    }
    
    var body: some Scene {
        #if os(macOS)
        // Settings window
        Settings {
            SettingsView()
                .environment(appEnvironment)
                .environment(premiumStore)
        }
        
        // Main window scene (hidden by default)
        WindowGroup("F1 Dashboard", id: "dashboard") {
           MainTabView()
               .environment(appEnvironment)
               .environment(premiumStore)
//          TestStateUpdateView()
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
                .environment(premiumStore)
                .onAppear {
                    // Set the app environment in the delegate when the menu bar extra appears
                    AppDelegate.shared = appDelegate
                    appDelegate.setAppEnvironment(appEnvironment)
                    appDelegate.premiumStore = premiumStore
                }
        }
        .menuBarExtraStyle(.window)
        #else
        // iOS/iPadOS main window
        WindowGroup {
            RootView {
                MainTabView()
                    .environment(appEnvironment)
                    .environment(premiumStore)
            }
        }
        #endif
    }
}

// MARK: - App Delegate (macOS only)

/// macOS-specific application delegate that handles system integration and window management.
///
/// The AppDelegate provides essential macOS functionality including:
/// - **Application Lifecycle**: Launch, termination, and cleanup handling
/// - **Window Management**: Dashboard window creation and state tracking  
/// - **Menu Bar Integration**: Coordinates with SwiftUI MenuBarExtra
/// - **System Integration**: Dock visibility and activation policies
///
/// ## Window Management Strategy
/// The delegate maintains references to dashboard windows to:
/// - Prevent duplicate window creation
/// - Enable programmatic window control via menu commands
/// - Handle proper cleanup on app termination
/// - Support switching between menu bar and regular app modes
///
/// ## Environment Integration
/// The delegate receives the `OptimizedAppEnvironment` from SwiftUI to:
/// - Access live data streams for window content
/// - Coordinate connection lifecycle with app state
/// - Prevent settings conflicts when dashboard is open
#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate?
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    // var appEnvironment: AppEnvironment?
    var appEnvironment: OptimizedAppEnvironment?
    var premiumStore: PremiumStore?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon for menu bar app
        // NOTE: Commented out for debugging - uncomment for release
        // NSApp.setActivationPolicy(.accessory)
        
        // Auto-connect on launch
        Task { @MainActor in
            // AppEnvironment will be set up by the SwiftUI app
        }
    }
    
    // func setAppEnvironment(_ environment: AppEnvironment) {
    func setAppEnvironment(_ environment: OptimizedAppEnvironment) {
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
                        .environment(premiumStore ?? PremiumStore())
                    
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

