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
    
    public var body: some View {
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
    }
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

#Preview {
    SettingsView()
        .environment(AppEnvironment())
}
