//
//  OptimizedAppEnvironment.swift
//  F1-Dash
//
//  Performance-optimized version with efficient buffering and state management
//

import SwiftUI
import Observation
import F1DashModels
import Combine

@MainActor
@Observable
public final class OptimizedAppEnvironment {
    // MARK: - Services
    
    let sseClient: SSEClient
    let dataBuffer: OptimizedDataBuffer
    let settingsStore: SettingsStore
    let pictureInPictureManager: PictureInPictureManager
    let systemPictureInPictureManager: SystemPictureInPictureManager?
    let liveActivityManager: LiveActivityManager?
    let videoBasedPictureInPictureManager: VideoBasedPictureInPictureManager
    // private var notificationManager: NotificationManager?
    private var notificationManager: OptimizedNotificationManager?
    let soundManager: SoundManager
    let racePreferences: RacePreferences
    
    // MARK: - State
    
    private(set) var liveSessionState: OptimizedLiveSessionState
    private(set) var connectionStatus: ConnectionStatus = .disconnected
    private(set) var schedule: [RaceRound] = []
    private(set) var scheduleLoadingStatus: LoadingStatus = .idle
    var isDashboardWindowOpen: Bool = false
    
    // MARK: - Performance Monitoring
    
    private var updateTimer: Timer?
    private let updateInterval: TimeInterval = 0.1 // 100ms update cycle
    private var messageProcessingTask: Task<Void, Never>?
    private var serverURLObservationTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    public init() {
        self.settingsStore = SettingsStore()
        self.sseClient = SSEClient(baseURL: settingsStore.serverURL)
        self.dataBuffer = OptimizedDataBuffer()
        self.pictureInPictureManager = PictureInPictureManager()
        self.liveSessionState = OptimizedLiveSessionState()
        self.soundManager = SoundManager()
        self.racePreferences = RacePreferences()
        self.videoBasedPictureInPictureManager = VideoBasedPictureInPictureManager()
        
        // Initialize managers only on iOS
        #if !os(macOS)
        self.systemPictureInPictureManager = SystemPictureInPictureManager()
        self.liveActivityManager = LiveActivityManager()
        #else
        self.systemPictureInPictureManager = nil
        self.liveActivityManager = nil
        #endif
        
        // Set reference to self in managers
        // TODO: Update managers to accept OptimizedAppEnvironment or use a protocol
        // For now, managers won't have reference to app environment
        self.pictureInPictureManager.appEnvironment = self
        self.systemPictureInPictureManager?.appEnvironment = self  // This one now accepts OptimizedAppEnvironment
        self.liveActivityManager?.appEnvironment = self
        self.videoBasedPictureInPictureManager.appEnvironment = self
        
        // Initialize notification manager and start update timer
        Task { @MainActor in
            // NotificationManager expects AppEnvironment, so we need to handle this differently
            // For now, we'll skip notification manager initialization
            // self.notificationManager = NotificationManager(appEnvironment: self)
            self.notificationManager = OptimizedNotificationManager(appEnvironment: self)
            self.startUpdateTimer()
            self.startServerURLObservation()
            await checkAutoConnect()
        }
    }
    
    // deinit cannot be used with actors
    // Cleanup is handled in disconnect() method instead
    
    // MARK: - Update Timer
    
    private func startUpdateTimer() {
        print("OptimizedAppEnvironment: Starting update timer with interval \(updateInterval)s")
        updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.processBufferedData()
            }
        }
    }
    
    // MARK: - Server URL Observation
    
    private func startServerURLObservation() {
        serverURLObservationTask = Task { @MainActor [weak self] in
            guard let self else { return }
            
            var previousURL = settingsStore.serverURL
            
            // Use debounce to avoid reconnecting on every keystroke
            for await _ in settingsStore.$serverURL.publisher
                .debounce(for: .seconds(1.5), scheduler: DispatchQueue.main)
                .values {
                
                let currentURL = settingsStore.serverURL
                
                // Only reconnect if URL actually changed and we were connected
                if currentURL != previousURL && connectionStatus == .connected {
                    print("Server URL changed from \(previousURL) to \(currentURL), reconnecting...")
                    
                    // Update SSE client with new URL
                    await sseClient.updateServerURL(currentURL)
                    
                    // Disconnect and reconnect
                    await disconnect()
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                    await connect()
                }
                
                previousURL = currentURL
            }
        }
    }
    
    private func processBufferedData() async {
        guard connectionStatus == .connected else {
          print("OptimizedAppEnvironment: processBufferedData called but not connected (\(connectionStatus))")
          return
        }
        let delay = settingsStore.dataDelay
        
        if delay == 0 {
            // No delay - use latest data
            if let latestData = await dataBuffer.latest() {
                print("OptimizedAppEnvironment: Processing latest data with \(latestData.count) keys: \(latestData.keys.joined(separator: ", "))")
                if latestData.keys.contains("raceControlMessages") {
                    print("OptimizedAppEnvironment: Processing data contains raceControlMessages!")
                }
                liveSessionState.applyPartialUpdate(latestData)
                checkForNotifications()
            } else {
                print("OptimizedAppEnvironment: No latest data available")
            }
        } else {
            // Apply delay - get delayed data
            if let delayedData = await dataBuffer.delayed(delay) {
                print("OptimizedAppEnvironment: Processing delayed data (\(delay)s) with \(delayedData.count) keys")
                liveSessionState.applyPartialUpdate(delayedData)
                checkForNotifications()
                
                // Cleanup old buffer data
                await dataBuffer.cleanup(delay)
            } else {
                print("OptimizedAppEnvironment: No delayed data available for \(delay)s delay")
            }
        }
    }
    
    // MARK: - Connection Management
    
    private func checkAutoConnect() async {
        if settingsStore.autoConnect {
            await connect()
        }
        await fetchSchedule()
    }
    
    // MARK: - Schedule Management
    
    func fetchSchedule() async {
        guard scheduleLoadingStatus != .loading else { return }
        
        scheduleLoadingStatus = .loading
        
        do {
            let serverURL = settingsStore.serverURL
            let url = URL(string: "\(serverURL)/api/schedule")!
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decodedSchedule = try decoder.decode([RaceRound].self, from: data)
            
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
        guard connectionStatus == .disconnected else { return }
        
        connectionStatus = .connecting
        
        // Ensure SSE client has latest URL
        await sseClient.updateServerURL(settingsStore.serverURL)
        
        do {
            try await sseClient.connect()
            connectionStatus = .connected

            // Restart periodic update timer if it was stopped during a previous disconnect
            if updateTimer == nil {
                print("OptimizedAppEnvironment: No update timer found, starting new one")
                startUpdateTimer()
            } else {
                print("OptimizedAppEnvironment: Update timer already exists, not starting new one")
            }

            // Start data processing in background
            messageProcessingTask = Task.detached(priority: .high) { [weak self] in
                await self?.startDataProcessing()
            }
        } catch {
            connectionStatus = .disconnected
            print("Failed to connect: \(error)")
        }
    }
    
    func disconnect() async {
        print("OptimizedAppEnvironment: Disconnecting - invalidating update timer")
        updateTimer?.invalidate()
        updateTimer = nil
        messageProcessingTask?.cancel()
        messageProcessingTask = nil
        await sseClient.disconnect()
        await dataBuffer.clear()
        connectionStatus = .disconnected
        
        // Clean up PiP if active
        if videoBasedPictureInPictureManager.isVideoPiPActive {
            videoBasedPictureInPictureManager.stopVideoPiP()
        }
        
        // Clear animation state to ensure fresh start on reconnect
        liveSessionState.clearState()
    }
    
    // MARK: - Data Processing
    
    private func startDataProcessing() async {
        for await message in await sseClient.messages {
            await processMessage(message)
        }
    }
    
    private func processMessage(_ message: SSEMessage) async {
        switch message {
        case .initial(let state):
            await MainActor.run {
                liveSessionState.setFullState(state)
                checkForNotifications()
            }
            
        case .update(let update):
            // Add to buffer for time-delayed processing
            print("OptimizedAppEnvironment: Received update with \(update.count) keys: \(update.keys.joined(separator: ", "))")
            if update.keys.contains("raceControlMessages") {
                print("OptimizedAppEnvironment: Update contains raceControlMessages!")
            }
            await dataBuffer.push(update)
            
        case .error(_):
            await MainActor.run {
                connectionStatus = .disconnected
            }
        }
    }
    
    private func checkForNotifications() {
        notificationManager?.checkForNotifications()
        
        // Check for race control chime
        if settingsStore.playRaceControlChime && liveSessionState.checkForNewRaceControlMessages() {
            soundManager.playSound(.raceControlChime)
        }
    }
}

// MARK: - Extensions for Compatibility

extension OptimizedAppEnvironment {
    // Compatibility wrapper for existing code
    typealias AppEnvironment = OptimizedAppEnvironment
}
