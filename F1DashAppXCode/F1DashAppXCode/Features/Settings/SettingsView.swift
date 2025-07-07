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

public struct SettingsView: View {
    public init() {}
    @Environment(AppEnvironment.self) private var appEnvironment
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
            .navigationTitle("Settings")
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
    @Environment(AppEnvironment.self) private var appEnvironment
    
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

// MARK: - Drivers Settings

struct DriversSettingsView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Favorite Drivers")
                .font(.headline)
                .padding(.horizontal)
            
            Text("Select your favorite drivers to highlight them in the timing list")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                    ForEach(appEnvironment.liveSessionState.sortedDrivers) { driver in
                        DriverSelectionCard(driver: driver)
                    }
                }
                .padding()
            }
        }
        .padding(.vertical)
    }
}

struct DriverSelectionCard: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    let driver: Driver
    
    private var isSelected: Bool {
        appEnvironment.settingsStore.isFavoriteDriver(driver.racingNumber)
    }
    
    var body: some View {
        Button {
            appEnvironment.settingsStore.toggleFavoriteDriver(driver.racingNumber)
        } label: {
            HStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: driver.teamColour) ?? .gray)
                    .frame(width: 4)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(driver.tla)
                        .font(.caption)
                        .fontWeight(.bold)
                    Text(driver.broadcastName)
                        .font(.caption2)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "star.fill" : "star")
                    .foregroundStyle(isSelected ? .yellow : .secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? (Color(hex: driver.teamColour) ?? .gray).opacity(0.1) : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? (Color(hex: driver.teamColour) ?? .gray) : Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Data Settings

struct DataSettingsView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    @State private var customDelay: String = ""
    
    var body: some View {
        Form {
            Section("Data Delay") {
                Text("Add a delay to the live timing data to sync with your TV broadcast")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Picker("Delay", selection: Binding(
                    get: { appEnvironment.settingsStore.dataDelay },
                    set: { newValue in appEnvironment.settingsStore.$dataDelay.withLock { $0 = newValue } }
                )) {
                    ForEach(SettingsStore.delayOptions, id: \.seconds) { option in
                        Text(option.label)
                            .tag(TimeInterval(option.seconds))
                    }
                }
                .pickerStyle(.automatic)
                
                HStack {
                    TextField("Custom delay (seconds)", text: $customDelay)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 150)
                    
                    Button("Apply") {
                        if let seconds = Int(customDelay) {
                            appEnvironment.settingsStore.$dataDelay.withLock { $0 = TimeInterval(seconds) }
                        }
                    }
                    .disabled(customDelay.isEmpty)
                }
            }
            
            Section("Connection") {
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
    @Environment(AppEnvironment.self) private var appEnvironment
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

struct iOSDriversSettingsView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                    ForEach(appEnvironment.liveSessionState.sortedDrivers) { driver in
                        DriverSelectionCard(driver: driver)
                    }
                }
                .padding()
            }
            .navigationTitle("Favorite Drivers")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppEnvironment())
}
