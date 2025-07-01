//
//  AppEnvironment.swift
//  F1-Dash
//
//  Central app coordinator holding references to core services
//

import SwiftUI
import Observation
import F1DashModels

// MARK: - App Environment

@MainActor
@Observable
public final class AppEnvironment {
    // MARK: - Services
    
    let webSocketClient: WebSocketClient
    let dataBufferActor: DataBufferActor
    let settingsStore: SettingsStore
    private var notificationManager: NotificationManager?
    
    // MARK: - State
    
    private(set) var liveSessionState: LiveSessionState
    private(set) var connectionStatus: ConnectionStatus = .disconnected
    
    // MARK: - Initialization
    
    public init() {
        self.webSocketClient = WebSocketClient()
        self.dataBufferActor = DataBufferActor()
        self.settingsStore = SettingsStore()
        self.liveSessionState = LiveSessionState()
        
        // Initialize notification manager after self is available
        Task { @MainActor in
            self.notificationManager = NotificationManager(appEnvironment: self)
        }
    }
    
    // MARK: - Connection Management
    
    func connect() async {
        connectionStatus = .connecting
        
        do {
            try await webSocketClient.connect()
            connectionStatus = .connected
            await startDataProcessing()
        } catch {
            connectionStatus = .disconnected
            print("Failed to connect: \(error)")
        }
    }
    
    func disconnect() async {
        await webSocketClient.disconnect()
        connectionStatus = .disconnected
    }
    
    // MARK: - Data Processing
    
    private func startDataProcessing() async {
        for await message in await webSocketClient.messages {
            await processMessage(message)
        }
    }
    
    private func processMessage(_ message: WebSocketMessage) async {
        // Add message to buffer with configured delay
        let delay = settingsStore.dataDelay
        await dataBufferActor.addMessage(message, delay: delay)
        
        // Process buffered messages
        let bufferedMessages = await dataBufferActor.getReadyMessages()
        for bufferedMessage in bufferedMessages {
            updateState(with: bufferedMessage)
        }
    }
    
    private func updateState(with message: WebSocketMessage) {
        switch message {
        case .fullState(let state):
            liveSessionState.updateFullState(state)
        case .stateUpdate(let update):
            liveSessionState.applyUpdate(update)
        case .connectionStatus:
            break
        }
        
        // Check for notifications after state update
        notificationManager?.checkForNotifications()
    }
}

// MARK: - Connection Status

enum ConnectionStatus {
    case disconnected
    case connecting
    case connected
    
    var isConnected: Bool {
        self == .connected
    }
    
    var description: String {
        switch self {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting..."
        case .connected:
            return "Connected"
        }
    }
    
    var color: Color {
        switch self {
        case .disconnected:
            return .red
        case .connecting:
            return .orange
        case .connected:
            return .green
        }
    }
}
