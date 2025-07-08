import Foundation
import Logging
import F1DashModels
import F1DashPersistence

/// Actor responsible for maintaining the canonical F1 session state
actor SessionStateCache {
    
    // MARK: - State
    
    private var currentState = F1State()
    private var currentStateDict: [String: Any] = [:]  // Keep dictionary representation for merging
    private let logger = Logger(label: "SessionStateCache")
    private var subscribers: [UUID: (StateUpdate) async -> Void] = [:]
    private var fullStateSubscribers: [UUID: (F1State) async -> Void] = [:]
    
    // Data persistence
    private let enablePersistence: Bool
    private var persistenceEnabled = false
    
    // MARK: - Statistics
    
    private var updateCount: Int = 0
    private var lastUpdate: Date = Date()
    
    // MARK: - Initialization
    
    init(enablePersistence: Bool = false) {
        self.enablePersistence = enablePersistence
        
        if enablePersistence {
            logger.info("SessionStateCache initialized with data persistence enabled")
            Task {
                await initializePersistence()
            }
        } else {
            logger.info("SessionStateCache initialized without data persistence")
        }
    }
    
    // MARK: - Public Interface
    
    /// Get the raw state dictionary as JSONValue (for API responses when F1State decoding fails)
    func getCurrentStateAsJSON() -> JSONValue {
        return JSONValue(from: currentStateDict)
    }
    
    /// Get the current complete F1 state
    func getCurrentState() -> F1State {
        // If state dictionary is empty, return empty F1State
        if currentStateDict.isEmpty {
            logger.debug("State dictionary is empty, returning empty F1State")
            return F1State()
        }
        
        // Debug log to see what's in the dictionary
        logger.debug("Current state dictionary keys: \(currentStateDict.keys.sorted())")
        if let driverList = currentStateDict["driverList"] as? [String: Any] {
            logger.debug("DriverList has \(driverList.count) drivers")
            if let driver1 = driverList["1"] as? [String: Any] {
                logger.debug("Driver 1 line field type: \(type(of: driver1["line"] ?? "nil")), value: \(driver1["line"] ?? "nil")")
            }
        }
        
        // Try to decode the current state dictionary to F1State
        // If it fails, return the last successfully decoded state
        do {
            let data = try JSONSerialization.data(withJSONObject: currentStateDict)
            let decoder = JSONDecoder()
            let decodedState = try decoder.decode(F1State.self, from: data)
            currentState = decodedState
            logger.debug("Getting current state - has timing data: \(decodedState.timingData != nil), driver count: \(decodedState.timingData?.lines.count ?? 0)")
            return decodedState
        } catch {
            logger.warning("Failed to decode current state dictionary, returning last known good state: \(error)")
            logger.debug("Getting cached state - has timing data: \(currentState.timingData != nil), driver count: \(currentState.timingData?.lines.count ?? 0)")
            
            // If we have data but can't decode it, return a partial state with what we can
            if !currentStateDict.isEmpty {
                logger.info("Returning partially decoded state from dictionary")
                var partialState = F1State()
                
                // Try to decode individual components that we can
                if let driverListData = try? JSONSerialization.data(withJSONObject: currentStateDict["driverList"] ?? [:]),
                   let driverList = try? JSONDecoder().decode([String: Driver].self, from: driverListData) {
                    partialState.driverList = driverList
                }
                
                // Return partial state for now
                return partialState
            }
            
            return currentState
        }
    }
    
    /// Subscribe to state updates
    func subscribeToUpdates() -> (UUID, AsyncStream<StateUpdate>) {
        let id = UUID()
        let (stream, continuation) = AsyncStream.makeStream(of: StateUpdate.self)
        
        subscribers[id] = { update in
            continuation.yield(update)
        }
        
        // Clean up when stream is cancelled
        continuation.onTermination = { [weak self] _ in
            Task { [weak self] in
                await self?.unsubscribe(id: id)
            }
        }
        
        logger.debug("New update subscriber: \(id)")
        return (id, stream)
    }
    
    /// Subscribe to full state changes
    func subscribeToFullState() -> (UUID, AsyncStream<F1State>) {
        let id = UUID()
        let (stream, continuation) = AsyncStream.makeStream(of: F1State.self)
        
        fullStateSubscribers[id] = { state in
            continuation.yield(state)
        }
        
        // Clean up when stream is cancelled
        continuation.onTermination = { [weak self] _ in
            Task { [weak self] in
                await self?.unsubscribeFromFullState(id: id)
            }
        }
        
        logger.debug("New full state subscriber: \(id)")
        return (id, stream)
    }
    
    /// Unsubscribe from updates
    func unsubscribe(id: UUID) {
        subscribers.removeValue(forKey: id)
        logger.debug("Unsubscribed update subscriber: \(id)")
    }
    
    /// Unsubscribe from full state
    func unsubscribeFromFullState(id: UUID) {
        fullStateSubscribers.removeValue(forKey: id)
        logger.debug("Unsubscribed full state subscriber: \(id)")
    }
    
    /// Set the complete initial state
    func setInitialState(_ state: F1State) async {
        logger.info("Setting initial F1 state")
        
        // Convert F1State to dictionary
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(state)
            currentStateDict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            currentState = state
            
            updateCount = 0
            lastUpdate = Date()
            
            logger.info("Initial state set with keys: \(currentStateDict.keys.joined(separator: ", "))")
            
            // Notify full state subscribers
            for subscriber in fullStateSubscribers.values {
                await subscriber(state)
            }
            
            // Persist initial state if needed
            if persistenceEnabled {
                await persistInitialState()
            }
        } catch {
            logger.error("Failed to set initial state: \(error)")
        }
    }
    
    /// Apply a state update to the current state
    func applyUpdate(_ update: StateUpdate) async {
        updateCount += 1
        lastUpdate = update.timestamp
        
        let updateKeys = update.updates.dictionary.keys.joined(separator: ", ")
        logger.info("Applying state update #\(updateCount) with keys: \(updateKeys)")
        
        // Check for session restart
        if await shouldResetState(update) {
            logger.info("Detected session restart, resetting state")
            currentState = F1State()
            currentStateDict = [:]
        }
        
        // Apply updates to current state
        await mergeUpdate(update)
        
        // Persist data if enabled (mirrors Rust importer logic)
        if persistenceEnabled {
            await persistUpdateData(update)
        }
        
        // Notify subscribers
        await notifySubscribers(update)
        
        // Log statistics periodically
        if updateCount % 100 == 0 {
            await logStatistics()
        }
    }
    
    /// Reset the state (e.g., for new session)
    func resetState() async {
        logger.info("Resetting session state")
        
        currentState = F1State()
        currentStateDict = [:]
        updateCount = 0
        lastUpdate = Date()
        
        // Notify full state subscribers
        for subscriber in fullStateSubscribers.values {
            await subscriber(currentState)
        }
        
        // Persist initial state if needed
        if persistenceEnabled {
            await persistInitialState()
        }
    }
    
    // MARK: - Statistics
    
    func getStatistics() -> SessionStatistics {
        return SessionStatistics(
            updateCount: updateCount,
            lastUpdate: lastUpdate,
            subscriberCount: subscribers.count,
            fullStateSubscriberCount: fullStateSubscribers.count,
            hasData: !isEmpty()
        )
    }
    
    // MARK: - Private Implementation
    
    private func shouldResetState(_ update: StateUpdate) async -> Bool {
        // Check for session info changes that indicate a new session
        let updateDict = update.updates.dictionary
        if let sessionInfo = updateDict["sessionInfo"] as? [String: Any],
           let name = sessionInfo["name"] as? String {
            
            // If we have existing session info and the name changed, it's a new session
            if let currentSessionName = currentState.sessionInfo?.name,
               currentSessionName != name {
                return true
            }
        }
        
        return false
    }
    
    private func mergeUpdate(_ update: StateUpdate) async {
        let updateKeys = update.updates.dictionary.keys.joined(separator: ", ")
        logger.debug("Merging update with keys: \(updateKeys)")
        
        // Simply merge the update into our state dictionary
        DataTransformation.mergeStates(&currentStateDict, with: update.updates.dictionary)
        
        let stateKeys = currentStateDict.keys.sorted().joined(separator: ", ")
        logger.info("State dictionary now has \(currentStateDict.count) keys: \(stateKeys)")
        
        // Sample some data to verify it's populated
        if let driverList = currentStateDict["driverList"] as? [String: Any] {
            logger.info("DriverList has \(driverList.count) drivers")
        }
        if let timingData = currentStateDict["timingData"] as? [String: Any],
           let lines = timingData["lines"] as? [String: Any] {
            logger.info("TimingData has \(lines.count) driver lines")
        }
    }
    
    private func notifySubscribers(_ update: StateUpdate) async {
        // Notify update subscribers
        for subscriber in subscribers.values {
            await subscriber(update)
        }
        
        // Notify full state subscribers if this was a significant change
        if isSignificantUpdate(update) {
            for subscriber in fullStateSubscribers.values {
                await subscriber(currentState)
            }
        }
    }
    
    private func isSignificantUpdate(_ update: StateUpdate) -> Bool {
        // Consider updates significant if they affect core timing or session data
        let significantKeys = [
            "timingData", "sessionInfo", "trackStatus", "sessionStatus",
            "driverList", "lapCount", "raceControlMessages"
        ]
        
        return update.updates.dictionary.keys.contains { key in
            significantKeys.contains(key)
        }
    }
    
    private func isEmpty() -> Bool {
        // Check the dictionary state, not the cached decoded state
        if !currentStateDict.isEmpty {
            return false
        }
        return currentState.driverList?.isEmpty != false &&
               currentState.timingData?.lines.isEmpty != false
    }
    
    private func logStatistics() async {
        let stats = getStatistics()
        logger.info("""
            Session State Statistics:
            - Updates processed: \(stats.updateCount)
            - Last update: \(stats.lastUpdate)
            - Update subscribers: \(stats.subscriberCount)
            - Full state subscribers: \(stats.fullStateSubscriberCount)
            - Has data: \(stats.hasData)
            """)
    }
    
    // MARK: - Data Persistence
    
    /// Initialize database persistence
    private func initializePersistence() async {
        guard enablePersistence else { return }
        
        do {
            try await DatabaseManager.shared.run()
            persistenceEnabled = true
            logger.info("Database persistence initialized successfully")
        } catch {
            logger.error("Failed to initialize database persistence: \(error)")
            persistenceEnabled = false
        }
    }
    
    /// Persist update data to database (mirrors Rust importer logic)
    private func persistUpdateData(_ update: StateUpdate) async {
        let updateDict = update.updates.dictionary
        
        // Process timing data updates
        if let timingDataUpdate = updateDict["timingData"] as? [String: Any] {
            await persistTimingUpdate(timingDataUpdate)
        }
        
        // Process timing app data updates (tire information)
        if let timingAppDataUpdate = updateDict["timingAppData"] as? [String: Any] {
            await persistTireUpdate(timingAppDataUpdate)
        }
    }
    
    /// Persist timing data updates
    private func persistTimingUpdate(_ timingUpdate: [String: Any]) async {
        guard let lines = timingUpdate["lines"] as? [String: [String: Any]] else {
            return
        }
        
        let currentLap = currentState.lapCount?.currentLap
        
        for (driverNr, updateData) in lines {
            // Get current driver data
            guard let currentDriver = currentState.timingData?.lines[driverNr] else {
                continue
            }
            
            // Parse timing data
            if let timingData = DataParser.parseTimingDriver(
                nr: driverNr,
                lap: currentLap,
                driver: currentDriver,
                updateData: updateData
            ) {
                do {
                    try await DatabaseManager.shared.insertTimingDriver(timingData)
                } catch {
                    logger.error("Failed to insert timing data for driver \(driverNr): \(error)")
                }
            }
        }
    }
    
    /// Persist tire data updates
    private func persistTireUpdate(_ tireUpdate: [String: Any]) async {
        guard let lines = tireUpdate["lines"] as? [String: [String: Any]] else {
            return
        }
        
        let currentLap = currentState.lapCount?.currentLap
        
        for (driverNr, updateData) in lines {
            // Get current driver data
            guard let currentDriver = currentState.timingAppData?.lines[driverNr] else {
                continue
            }
            
            // Parse tire data
            if let tireData = DataParser.parseTireDriver(
                nr: driverNr,
                lap: currentLap,
                driver: currentDriver,
                updateData: updateData
            ) {
                do {
                    try await DatabaseManager.shared.insertTireDriver(tireData)
                } catch {
                    logger.error("Failed to insert tire data for driver \(driverNr): \(error)")
                }
            }
        }
    }
    
    /// Persist initial state data to database
    private func persistInitialState() async {
        guard persistenceEnabled else { return }
        
        let currentLap = currentState.lapCount?.currentLap
        
        // Persist initial timing data
        if let timingData = currentState.timingData {
            for (driverNr, driver) in timingData.lines {
                if let timingDriverData = DataParser.parseTimingDriver(
                    nr: driverNr,
                    lap: currentLap,
                    driver: driver
                ) {
                    do {
                        try await DatabaseManager.shared.insertTimingDriver(timingDriverData)
                    } catch {
                        logger.error("Failed to insert initial timing data for driver \(driverNr): \(error)")
                    }
                }
            }
        }
        
        // Persist initial tire data
        if let timingAppData = currentState.timingAppData {
            for (driverNr, driver) in timingAppData.lines {
                if let tireDriverData = DataParser.parseTireDriver(
                    nr: driverNr,
                    lap: currentLap,
                    driver: driver
                ) {
                    do {
                        try await DatabaseManager.shared.insertTireDriver(tireDriverData)
                    } catch {
                        logger.error("Failed to insert initial tire data for driver \(driverNr): \(error)")
                    }
                }
            }
        }
    }
    
    /// Get database health status
    func getDatabaseHealth() async -> DatabaseHealth? {
        guard enablePersistence else { return nil }
        return await DatabaseManager.shared.healthCheck()
    }
}

// MARK: - Supporting Types

public struct SessionStatistics: Sendable, Codable {
    public let updateCount: Int
    public let lastUpdate: Date
    public let subscriberCount: Int
    public let fullStateSubscriberCount: Int
    public let hasData: Bool
    
    public init(
        updateCount: Int,
        lastUpdate: Date,
        subscriberCount: Int,
        fullStateSubscriberCount: Int,
        hasData: Bool
    ) {
        self.updateCount = updateCount
        self.lastUpdate = lastUpdate
        self.subscriberCount = subscriberCount
        self.fullStateSubscriberCount = fullStateSubscriberCount
        self.hasData = hasData
    }
}
