//
//  SettingsView.swift
//  F1-Dash
//
//  Settings view for the app
//

import SwiftUI
#if os(macOS)
import ServiceManagement
#endif
import F1DashModels
import Sharing

public struct SettingsView: View {
    public init() {}
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    #if os(macOS)
    @State private var selectedTab = 0
    #endif
    
    public var body: some View {
        #if os(macOS)
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            VisualSettingsView()
                .tabItem {
                    Label("Visual", systemImage: "eye")
                }
            
            DriversSettingsView()
                .tabItem {
                    Label("Drivers", systemImage: "person.2")
                }
            
            DataSettingsView()
                .tabItem {
                    Label("Data", systemImage: "network")
                }
        }
        .frame(width: 500, height: 400)
        #else
        NavigationStack {
            Form {
                // General Settings Section
                Section("General") {
                    Toggle("Show Notifications", isOn: Binding(
                        get: { appEnvironment.settingsStore.showNotifications },
                        set: { newValue in appEnvironment.settingsStore.$showNotifications.withLock { $0 = newValue } }
                    ))
                    
                    Toggle("Compact Mode", isOn: Binding(
                        get: { appEnvironment.settingsStore.compactMode },
                        set: { newValue in appEnvironment.settingsStore.$compactMode.withLock { $0 = newValue } }
                    ))
                }
                
                // Track Map Settings Section
                Section("Track Map") {
                    HStack {
                        Text("Zoom Level")
                        Slider(value: Binding(
                            get: { appEnvironment.settingsStore.trackMapZoom },
                            set: { newValue in appEnvironment.settingsStore.$trackMapZoom.withLock { $0 = newValue } }
                        ), in: 0.5...2.0)
                        Text("\(Int(appEnvironment.settingsStore.trackMapZoom * 100))%")
                            .monospacedDigit()
                            .frame(width: 50, alignment: .trailing)
                    }
                }
                
                // Data & Connection Settings Section
                Section("Data & Connection") {
                    iOSDataSettingsContent()
                }
                
                // Visual Settings Section
                Section("Visual") {
                    iOSVisualSettingsContent()
                }
                
                // Race Control Section
                Section("Race Control") {
                    iOSRaceControlSettingsContent()
                }
                
                // Favorite Drivers Section
                Section("Favorite Drivers") {
                    favoriteDriversSection
                }
                
                // Reset Section
                Section {
                    Button("Reset to Defaults") {
                        appEnvironment.settingsStore.resetToDefaults()
                    }
                    .foregroundStyle(.red)
                }
            }
            #if !os(macOS)
            .navigationTitle("Settings")
            #endif
        }
        #endif
    }
    
    #if !os(macOS)
    @ViewBuilder
    private var favoriteDriversSection: some View {
        Text("Select your favorite drivers to highlight them in the timing list")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        
        NavigationLink {
            FavoriteDriversView()
        } label: {
            HStack {
                Text("Manage Favorite Drivers")
                Spacer()
              Text("\(appEnvironment.settingsStore.favoriteDriverIDs.count) selected")
                    .foregroundStyle(.secondary)
            }
        }
    }
    #endif
}

// MARK: - General Settings

struct GeneralSettingsView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        Form {
            Section {
                #if os(macOS)
                Toggle("Launch at Login", isOn: Binding(
                    get: { appEnvironment.settingsStore.launchAtLogin },
                    set: { newValue in 
                        appEnvironment.settingsStore.$launchAtLogin.withLock { $0 = newValue }
                        configureLaunchAtLogin(newValue)
                    }
                ))
                #endif
                
                Toggle("Show Notifications", isOn: Binding(
                    get: { appEnvironment.settingsStore.showNotifications },
                    set: { newValue in appEnvironment.settingsStore.$showNotifications.withLock { $0 = newValue } }
                ))
                
                Toggle("Compact Mode", isOn: Binding(
                    get: { appEnvironment.settingsStore.compactMode },
                    set: { newValue in appEnvironment.settingsStore.$compactMode.withLock { $0 = newValue } }
                ))
            }
            
            Section("Track Map") {
                HStack {
                    Text("Zoom Level")
                    Slider(value: Binding(
                        get: { appEnvironment.settingsStore.trackMapZoom },
                        set: { newValue in appEnvironment.settingsStore.$trackMapZoom.withLock { $0 = newValue } }
                    ), in: 0.5...2.0)
                    Text("\(Int(appEnvironment.settingsStore.trackMapZoom * 100))%")
                        .monospacedDigit()
                        .frame(width: 50, alignment: .trailing)
                }
            }
            
            Section {
                Button("Reset to Defaults") {
                    appEnvironment.settingsStore.resetToDefaults()
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
    
    #if os(macOS)
    private func configureLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to configure launch at login: \(error)")
        }
    }
    #endif
}

// MARK: - Visual Settings

struct VisualSettingsView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @Shared(.appStorage("showCarMetrics")) var showCarMetrics = true
    @Shared(.appStorage("showCornerNumbers")) var showCornerNumbers = false
    @Shared(.appStorage("showDriverTableHeader")) var showDriverTableHeader = true
    @Shared(.appStorage("showDriversBestSectors")) var showDriversBestSectors = true
    @Shared(.appStorage("showDriversMiniSectors")) var showDriversMiniSectors = true
    @Shared(.appStorage("oledMode")) var oledMode = false
    @Shared(.appStorage("useSafetyCarColors")) var useSafetyCarColors = true
    @Shared(.appStorage("playRaceControlChime")) var playRaceControlChime = true
    
    var body: some View {
        Form {
            displayOptionsSection
            appearanceSection
            raceControlSection
        }
        .formStyle(.grouped)
        .padding()
    }
    
    @ViewBuilder
    private var displayOptionsSection: some View {
        Section("Display Options") {
            Toggle("Show Car Metrics (RPM, Gear, Speed)", isOn: Binding($showCarMetrics))
            Toggle("Show Corner Numbers on Track Map", isOn: Binding($showCornerNumbers))
            Toggle("Show Driver Table Header", isOn: Binding($showDriverTableHeader))
            Toggle("Show Driver's Best Sectors", isOn: Binding($showDriversBestSectors))
            Toggle("Show Driver's Mini Sectors", isOn: Binding($showDriversMiniSectors))
        }
    }
    
    @ViewBuilder
    private var appearanceSection: some View {
        Section("Appearance") {
            Toggle("OLED Mode (Pure Black Background)", isOn: Binding($oledMode))
            Toggle("Use Safety Car Colors", isOn: Binding($useSafetyCarColors))
        }
    }
    
    @ViewBuilder
    private var raceControlSection: some View {
        Section("Race Control") {
            Toggle("Play Chime on New Race Control Message", isOn: Binding($playRaceControlChime))
        }
    }
}

// MARK: - Drivers Settings

struct DriversSettingsView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        NavigationLink {
            FavoriteDriversView()
        } label: {
            driverSettingsLabel
        }
        .buttonStyle(.plain)
        .padding()
    }
    
    @ViewBuilder
    private var driverSettingsLabel: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerSection
            
            if !appEnvironment.settingsStore.favoriteDriverIDs.isEmpty {
                currentFavoritesSection
            }
        }
      #if os(macOS)
        .background(Color(NSColor.controlBackgroundColor))
      #else
        .background(Color.secondary.opacity(0.1))
      #endif
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    @ViewBuilder
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Favorite Drivers")
                    .font(.headline)
                Text("Select your favorite drivers to highlight them in the timing list")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(appEnvironment.settingsStore.favoriteDriverIDs.count)")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("selected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    
    @ViewBuilder
    private var currentFavoritesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current Favorites")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            favoriteDriversScrollView
        }
        .padding(.bottom)
    }
    
    @ViewBuilder
    private var favoriteDriversScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
              ForEach(appEnvironment.settingsStore.favoriteDriverIDs.sorted {$0 < $1}, id: \.self) { driverId in
                    if let driver = findDriver(by: driverId) {
                        driverBadge(for: driver)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func findDriver(by id: String) -> Driver? {
        appEnvironment.liveSessionState.driverList.values.first { driver in
            driver.racingNumber == id || driver.tla == id
        }
    }
    
    @ViewBuilder
    private func driverBadge(for driver: Driver) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(Color(hex: driver.teamColour) ?? .gray)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(driver.tla)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            Text(driver.lastName)
                .font(.caption2)
                .lineLimit(1)
                .frame(width: 60)
        }
    }
}


// MARK: - Data Settings

struct DataSettingsView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @State private var customDelay: String = ""
    @State private var showCustomInput: Bool = false
    
    private var isCustomDelayActive: Bool {
        let currentDelay = appEnvironment.settingsStore.dataDelay
        return currentDelay > 0 && !SettingsStore.delayOptions.contains { option in
            option.seconds != -1 && TimeInterval(option.seconds) == currentDelay
        }
    }
    
    private var currentDelayLabel: String {
        if appEnvironment.settingsStore.dataDelay == 0 {
            return "None"
        } else if isCustomDelayActive {
            return "Custom (\(Int(appEnvironment.settingsStore.dataDelay))s)"
        } else {
            return SettingsStore.delayOptions.first { 
                TimeInterval($0.seconds) == appEnvironment.settingsStore.dataDelay 
            }?.label ?? "None"
        }
    }
    
    var body: some View {
        Form {
            Section("Data Delay") {
                Text("Add a delay to the live timing data to sync with your TV broadcast")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Picker("Delay", selection: Binding(
                    get: { 
                        if isCustomDelayActive {
                            return TimeInterval(-1) // Return "Custom" value
                        } else {
                            return appEnvironment.settingsStore.dataDelay
                        }
                    },
                    set: { newValue in
                        if newValue == -1 {
                            showCustomInput = true
                            if isCustomDelayActive {
                                customDelay = String(Int(appEnvironment.settingsStore.dataDelay))
                            }
                        } else {
                            showCustomInput = false
                            appEnvironment.settingsStore.$dataDelay.withLock { $0 = newValue }
                        }
                    }
                )) {
                    ForEach(SettingsStore.delayOptions, id: \.seconds) { option in
                        Text(option.label)
                            .tag(TimeInterval(option.seconds))
                    }
                }
                .pickerStyle(.menu)
                
                if showCustomInput || isCustomDelayActive {
                    HStack {
                        TextField("Custom delay (seconds)", text: $customDelay)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 150)
                            .onAppear {
                                if isCustomDelayActive && customDelay.isEmpty {
                                    customDelay = String(Int(appEnvironment.settingsStore.dataDelay))
                                }
                            }
                        
                        Button("Apply") {
                            if let seconds = Int(customDelay), seconds >= 0 {
                                appEnvironment.settingsStore.$dataDelay.withLock { $0 = TimeInterval(seconds) }
                                showCustomInput = false
                            }
                        }
                        .disabled(customDelay.isEmpty)
                    }
                }
                
                HStack {
                    Text("Current delay:")
                        .foregroundStyle(.secondary)
                    Text(currentDelayLabel)
                        .fontWeight(.medium)
                }
            }
            
            Section("Connection") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Server URL:")
                        TextField("Server URL", text: Binding(
                            get: { appEnvironment.settingsStore.serverURL },
                            set: { newValue in appEnvironment.settingsStore.$serverURL.withLock { $0 = newValue } }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 250)
                    }
                    
                    Text("Enter your F1 Dash server URL (e.g., https://tunnel.trycloudflare.com)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Toggle("Auto-connect on launch", isOn: Binding(
                    get: { appEnvironment.settingsStore.autoConnect },
                    set: { newValue in appEnvironment.settingsStore.$autoConnect.withLock { $0 = newValue } }
                ))
                
                Text("Automatically connect to the F1 timing server when the app starts")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text("Server Status:")
                    Text(appEnvironment.connectionStatus.description)
                        .foregroundStyle(appEnvironment.connectionStatus.color)
                    Spacer()
                    if appEnvironment.connectionStatus == .disconnected {
                        Button("Connect") {
                            Task {
                                await appEnvironment.connect()
                            }
                        }
                    } else if appEnvironment.connectionStatus == .connected {
                        Button("Disconnect") {
                            Task {
                                await appEnvironment.disconnect()
                            }
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - iOS-Specific Views

struct iOSDataSettingsContent: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @State private var customDelay: String = ""
    @State private var showCustomInput: Bool = false
    
    private var isCustomDelayActive: Bool {
        let currentDelay = appEnvironment.settingsStore.dataDelay
        return !SettingsStore.delayOptions.contains { option in
            option.seconds != -1 && TimeInterval(option.seconds) == currentDelay
        }
    }
    
    var body: some View {
        Group {
            // Data Delay
            VStack(alignment: .leading, spacing: 8) {
                Text("Add a delay to the live timing data to sync with your TV broadcast")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Picker("Data Delay", selection: Binding(
                    get: { 
                        if isCustomDelayActive {
                            return TimeInterval(-1) // Return "Custom" value
                        } else {
                            return appEnvironment.settingsStore.dataDelay
                        }
                    },
                    set: { (newValue: TimeInterval) in
                        if newValue == -1 {
                            showCustomInput = true
                        } else {
                            showCustomInput = false
                            appEnvironment.settingsStore.$dataDelay.withLock { $0 = newValue }
                        }
                    }
                )) {
                    ForEach(SettingsStore.delayOptions, id: \.seconds) { option in
                        Text(option.label)
                            .tag(TimeInterval(option.seconds))
                    }
                }
                .pickerStyle(.menu)
                
                // Show custom delay input when Custom is selected or already active
                if showCustomInput || isCustomDelayActive {
                    HStack {
                        TextField("Enter seconds", text: $customDelay)
                            .textFieldStyle(.roundedBorder)
                      #if os(iOS)
                            .keyboardType(.numberPad)
                      #endif
                            .onAppear {
                                if isCustomDelayActive && customDelay.isEmpty {
                                    customDelay = String(Int(appEnvironment.settingsStore.dataDelay))
                                }
                            }
                        
                        Button("Apply") {
                            if let seconds = Int(customDelay), seconds >= 0 {
                                appEnvironment.settingsStore.$dataDelay.withLock { $0 = TimeInterval(seconds) }
                                showCustomInput = false
                            }
                        }
                        .disabled(customDelay.isEmpty)
                    }
                    .animation(.easeInOut(duration: 0.2), value: showCustomInput)
                }
            }
            
            // Server URL Setting
            HStack {
                Text("Server URL")
                Spacer()
                TextField("Server URL", text: Binding(
                    get: { appEnvironment.settingsStore.serverURL },
                    set: { newValue in appEnvironment.settingsStore.$serverURL.withLock { $0 = newValue } }
                ))
                .textFieldStyle(.roundedBorder)
//                .autocapitalization(.none)
                .disableAutocorrection(true)
                .frame(maxWidth: 200)
                .onSubmit {
                    // Force immediate reconnection on submit
                    if appEnvironment.connectionStatus == .connected {
                        Task {
                            await appEnvironment.disconnect()
                            try? await Task.sleep(nanoseconds: 500_000_000)
                            await appEnvironment.connect()
                        }
                    }
                }
            }
            
            HStack(spacing: 4) {
                Text("Enter your F1 Dash server URL (e.g., https://tunnel.trycloudflare.com)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if appEnvironment.connectionStatus == .connected {
                    Text("• Auto-reconnects after 1.5s")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
            
            // Connection Settings
            Toggle("Auto-connect on launch", isOn: Binding(
                get: { appEnvironment.settingsStore.autoConnect },
                set: { newValue in appEnvironment.settingsStore.$autoConnect.withLock { $0 = newValue } }
            ))
            
            Text("Automatically connect to the F1 timing server when the app starts")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            // Connection Status
            HStack {
                Text("Server Status:")
                Text(appEnvironment.connectionStatus.description)
                    .foregroundStyle(appEnvironment.connectionStatus.color)
                Spacer()
                if appEnvironment.connectionStatus == .disconnected {
                    Button("Connect") {
                        Task {
                            await appEnvironment.connect()
                        }
                    }
                } else if appEnvironment.connectionStatus == .connected {
                    Button("Disconnect") {
                        Task {
                            await appEnvironment.disconnect()
                        }
                    }
                }
            }
        }
    }
}

struct iOSVisualSettingsContent: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
  
    var settingsStore: SettingsStore {
      appEnvironment.settingsStore
    }
    
    
    var body: some View {
        Group {
          Toggle("Show Car Metrics", isOn: Binding(settingsStore.$showCarMetrics))
            Toggle("Show Corner Numbers", isOn: Binding(settingsStore.$showCornerNumbers))
            Toggle("Show Driver Table Header", isOn: Binding( settingsStore.$showDriverTableHeader))
            Toggle("Show Best Sectors", isOn: Binding(settingsStore.$showDriversBestSectors))
            Toggle("Show Mini Sectors", isOn: Binding(settingsStore.$showDriversMiniSectors))
            Toggle("OLED Mode", isOn: Binding(settingsStore.$oledMode))
            Toggle("Use Safety Car Colors", isOn: Binding(settingsStore.$useSafetyCarColors))
        }
    }
}

struct iOSRaceControlSettingsContent: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    var body: some View {
        Toggle("Play Chime on Message", isOn: Binding(
            appEnvironment.settingsStore.$playRaceControlChime,
        ))
    }
}

#Preview {
    SettingsView()
        .environment(AppEnvironment())
}
