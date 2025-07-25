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
    
    let sseClient: SSEClient
    let dataBufferActor: DataBufferActor
    let settingsStore: SettingsStore
    let pictureInPictureManager: PictureInPictureManager
    let systemPictureInPictureManager: SystemPictureInPictureManager?
    let liveActivityManager: LiveActivityManager?
    private var notificationManager: NotificationManager?
    let soundManager: SoundManager
    let racePreferences: RacePreferences
    
    // MARK: - State
    
    private(set) var liveSessionState: LiveSessionStateNew
    private(set) var connectionStatus: ConnectionStatus = .disconnected
    private(set) var schedule: [RaceRound] = []
    private(set) var scheduleLoadingStatus: LoadingStatus = .idle
    var isDashboardWindowOpen: Bool = false
    
    // MARK: - Initialization
    
    public init() {
        self.sseClient = SSEClient()
        self.dataBufferActor = DataBufferActor()
        self.settingsStore = SettingsStore()
        self.pictureInPictureManager = PictureInPictureManager()
        self.liveSessionState = LiveSessionStateNew()
        self.soundManager = SoundManager()
        self.racePreferences = RacePreferences()
        
        // Initialize managers only on iOS
        #if !os(macOS)
        self.systemPictureInPictureManager = SystemPictureInPictureManager()
        self.liveActivityManager = LiveActivityManager()
        #else
        self.systemPictureInPictureManager = nil
        self.liveActivityManager = nil
        #endif
        
        // Set reference to self in managers
        // self.pictureInPictureManager.appEnvironment = self
        // self.systemPictureInPictureManager?.appEnvironment = self
        // self.liveActivityManager?.appEnvironment = self
        // Note: These managers now expect OptimizedAppEnvironment, not AppEnvironment
        
        // Initialize notification manager after self is available
        Task { @MainActor in
            self.notificationManager = NotificationManager(appEnvironment: self)
            
            // Auto-connect if enabled
            await checkAutoConnect()
        }
    }
    
    // MARK: - Connection Management
    
    private func checkAutoConnect() async {
        if settingsStore.autoConnect {
            await connect()
        }
        
        // Also fetch schedule on startup
        await fetchSchedule()
    }
    
    // MARK: - Schedule Management
    
    func fetchSchedule() async {
        guard scheduleLoadingStatus != .loading else { return }
        
        scheduleLoadingStatus = .loading
        
        do {
            let serverURL = "http://localhost:8080"
            let url = URL(string: "\(serverURL)/api/schedule")!
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decodedSchedule = try decoder.decode([RaceRound].self, from: data)
            
            // Update schedule with decoded data
          await MainActor.run {
            withAnimation {
              schedule = decodedSchedule
              scheduleLoadingStatus = .loaded
            }
          }
        } catch {
            print("Failed to fetch schedule: \(error)")
            scheduleLoadingStatus = .error(error.localizedDescription)
        }
    }
    
    // Schedule computed properties
    var upcomingRaces: [RaceRound] {
        schedule.filter { $0.isUpcoming }
    }
    
    var nextRace: RaceRound? {
        upcomingRaces.first
    }
    
    var currentRace: RaceRound? {
        schedule.first { $0.isActive }
    }
    
    func connect() async {
        // Prevent multiple simultaneous connection attempts
        guard connectionStatus == .disconnected else { return }
        
        connectionStatus = .connecting
        
        do {
            try await sseClient.connect()
            connectionStatus = .connected
            
            // Start data processing in a detached task to avoid blocking
            Task.detached { [weak self] in
                await self?.startDataProcessing()
            }
        } catch {
            connectionStatus = .disconnected
            print("Failed to connect: \(error)")
        }
    }
    
    func disconnect() async {
        await sseClient.disconnect()
        connectionStatus = .disconnected
    }
    
    // MARK: - Data Processing
    
    private func startDataProcessing() async {
        for await message in await sseClient.messages {
            switch message {
            case .initial(let state):
                await processInitialState(state)
            case .update(let update):
                await processUpdate(update)
            case .error(_):
                connectionStatus = .disconnected
            }
        }
    }
    
    private func processInitialState(_ state: [String: Any]) async {
        // For initial state, update directly without buffering
        updateState(isInitial: true, data: state)
    }
    
    private func processUpdate(_ update: [String: Any]) async {
        // Add update to buffer with configured delay
        let delay = settingsStore.dataDelay
        await dataBufferActor.addMessage(update, delay: delay)
        
        // Process buffered messages
        let bufferedMessages = await dataBufferActor.getReadyMessages()
        for bufferedMessage in bufferedMessages {
            updateState(isInitial: false, data: bufferedMessage)
        }
    }
    
    private func updateState(isInitial: Bool, data: [String: Any]) {
        if isInitial {
            liveSessionState.setFullState(data)
        } else {
            liveSessionState.applyPartialUpdate(data)
        }
        
        // Check for notifications after state update
        notificationManager?.checkForNotifications()
        
        // Check for race control chime
        if settingsStore.playRaceControlChime && liveSessionState.checkForNewRaceControlMessages() {
            soundManager.playSound(.raceControlChime)
        }
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
    
    var statusText: String {
        switch self {
        case .disconnected:
            return "Offline"
        case .connecting:
            return "Connecting"
        case .connected:
            return "Live"
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

// MARK: - Loading Status

enum LoadingStatus: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
    
    var isLoading: Bool {
        self == .loading
    }
    
    var hasError: Bool {
        if case .error = self {
            return true
        }
        return false
    }
}
