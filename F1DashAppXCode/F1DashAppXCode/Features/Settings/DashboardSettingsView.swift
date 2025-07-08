//
//  DashboardSettingsView.swift
//  F1-Dash
//
//  Settings view for the Dashboard tab - unified, non-tabbed interface
//

import SwiftUI
#if os(macOS)
import ServiceManagement
#endif
import F1DashModels
import Sharing

public struct DashboardSettingsView: View {
    public init() {}
    @Environment(AppEnvironment.self) private var appEnvironment
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
    
    public var body: some View {
        NavigationStack {
            Form {
                // General Settings Section
                Section("General") {
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
                
                // Visual Settings Section
                Section("Visual") {
                    Toggle("Show Car Metrics (RPM, Gear, Speed)", isOn: Binding(
                        get: { appEnvironment.settingsStore.showCarMetrics },
                        set: { newValue in appEnvironment.settingsStore.$showCarMetrics.withLock { $0 = newValue } }
                    ))
                    
                    Toggle("Show Corner Numbers on Track Map", isOn: Binding(
                        get: { appEnvironment.settingsStore.showCornerNumbers },
                        set: { newValue in appEnvironment.settingsStore.$showCornerNumbers.withLock { $0 = newValue } }
                    ))
                    
                    Toggle("Show Driver Table Header", isOn: Binding(
                        get: { appEnvironment.settingsStore.showDriverTableHeader },
                        set: { newValue in appEnvironment.settingsStore.$showDriverTableHeader.withLock { $0 = newValue } }
                    ))
                    
                    Toggle("Show Driver's Best Sectors", isOn: Binding(
                        get: { appEnvironment.settingsStore.showDriversBestSectors },
                        set: { newValue in appEnvironment.settingsStore.$showDriversBestSectors.withLock { $0 = newValue } }
                    ))
                    
                    Toggle("Show Driver's Mini Sectors", isOn: Binding(
                        get: { appEnvironment.settingsStore.showDriversMiniSectors },
                        set: { newValue in appEnvironment.settingsStore.$showDriversMiniSectors.withLock { $0 = newValue } }
                    ))
                    
                    Toggle("OLED Mode (Pure Black Background)", isOn: Binding(
                        get: { appEnvironment.settingsStore.oledMode },
                        set: { newValue in appEnvironment.settingsStore.$oledMode.withLock { $0 = newValue } }
                    ))
                    
                    Toggle("Use Safety Car Colors", isOn: Binding(
                        get: { appEnvironment.settingsStore.useSafetyCarColors },
                        set: { newValue in appEnvironment.settingsStore.$useSafetyCarColors.withLock { $0 = newValue } }
                    ))
                }
                
                // Data & Connection Settings Section
                Section("Data & Connection") {
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
                                TextField("Enter seconds", text: $customDelay)
                                    .textFieldStyle(.roundedBorder)
                                    #if os(iOS)
                                    .keyboardType(.numberPad)
                                    #endif
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
                
                // Race Control Section
                Section("Race Control") {
                    Toggle("Play Chime on New Race Control Message", isOn: Binding(
                        get: { appEnvironment.settingsStore.playRaceControlChime },
                        set: { newValue in appEnvironment.settingsStore.$playRaceControlChime.withLock { $0 = newValue } }
                    ))
                }
                
                // Favorite Drivers Section
                Section("Favorite Drivers") {
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
                
                // Reset Section
                Section {
                    Button("Reset to Defaults") {
                        appEnvironment.settingsStore.resetToDefaults()
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Settings")
            #if os(macOS)
            .formStyle(.grouped)
            #endif
            .platformNavigationGlass()
        }
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

#Preview {
    DashboardSettingsView()
        .environment(AppEnvironment())
}
