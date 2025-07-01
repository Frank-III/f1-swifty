//import Foundation
//import Logging
//import F1DashModels
//import F1DashPersistence
//import SwiftyJSON
//
///// Actor responsible for maintaining the canonical F1 session state (SwiftyJSON version)
//actor SessionStateCacheSwiftyJSON {
//    
//    // MARK: - State
//    
//    private var currentState = JSON()  // Using SwiftyJSON instead of F1State
//    private let logger = Logger(label: "SessionStateCache")
//    private var subscribers: [UUID: (StateUpdate) async -> Void] = [:]
//    private var fullStateSubscribers: [UUID: (JSON) async -> Void] = [:]
//    
//    // Data persistence
//    private let enablePersistence: Bool
//    private var persistenceEnabled = false
//    
//    // MARK: - Statistics
//    
//    private var updateCount: Int = 0
//    private var lastUpdate: Date = Date()
//    
//    // MARK: - Initialization
//    
//    init(enablePersistence: Bool = false) {
//        self.enablePersistence = enablePersistence
//        
//        if enablePersistence {
//            logger.info("SessionStateCache initialized with data persistence enabled")
//            Task {
//                await initializePersistence()
//            }
//        } else {
//            logger.info("SessionStateCache initialized without data persistence")
//        }
//    }
//    
//    // MARK: - Public Interface
//    
//    /// Get the current complete F1 state as F1State model
//    func getCurrentState() -> F1State? {
//        do {
//            let data = try currentState.rawData()
//            return try JSONDecoder().decode(F1State.self, from: data)
//        } catch {
//            logger.error("Failed to decode current state: \(error)")
//            return nil
//        }
//    }
//    
//    /// Get the current state as JSON
//    func getCurrentStateJSON() -> JSON {
//        return currentState
//    }
//    
//    /// Subscribe to state updates
//    func subscribeToUpdates() -> (UUID, AsyncStream<StateUpdate>) {
//        let id = UUID()
//        let (stream, continuation) = AsyncStream.makeStream(of: StateUpdate.self)
//        
//        subscribers[id] = { update in
//            continuation.yield(update)
//        }
//        
//        // Clean up when stream is cancelled
//        continuation.onTermination = { [weak self] _ in
//            Task { [weak self] in
//                await self?.unsubscribe(id: id)
//            }
//        }
//        
//        logger.debug("New update subscriber: \(id)")
//        return (id, stream)
//    }
//    
//    /// Subscribe to full state changes
//    func subscribeToFullState() -> (UUID, AsyncStream<JSON>) {
//        let id = UUID()
//        let (stream, continuation) = AsyncStream.makeStream(of: JSON.self)
//        
//        fullStateSubscribers[id] = { state in
//            continuation.yield(state)
//        }
//        
//        // Clean up when stream is cancelled
//        continuation.onTermination = { [weak self] _ in
//            Task { [weak self] in
//                await self?.unsubscribeFromFullState(id: id)
//            }
//        }
//        
//        logger.debug("New full state subscriber: \(id)")
//        return (id, stream)
//    }
//    
//    /// Unsubscribe from updates
//    func unsubscribe(id: UUID) {
//        subscribers.removeValue(forKey: id)
//        logger.debug("Unsubscribed update subscriber: \(id)")
//    }
//    
//    /// Unsubscribe from full state
//    func unsubscribeFromFullState(id: UUID) {
//        fullStateSubscribers.removeValue(forKey: id)
//        logger.debug("Unsubscribed full state subscriber: \(id)")
//    }
//    
//    /// Apply a state update to the current state
//    func applyUpdate(_ update: StateUpdate) async {
//        updateCount += 1
//        lastUpdate = update.timestamp
//        
//        logger.trace("Applying state update with \(updateCount) changes")
//        
//        // Convert update dictionary to SwiftyJSON
//        let updateJSON = JSON(update.updates.dictionary)
//        
//        // Check for session restart
//        if await shouldResetState(updateJSON) {
//            logger.info("Detected session restart, resetting state")
//            currentState = JSON()
//        }
//        
//        // Apply updates to current state using SwiftyJSON's merge
//        await mergeUpdate(updateJSON)
//        
//        // Persist data if enabled
//        if persistenceEnabled {
//            await persistUpdateData(updateJSON)
//        }
//        
//        // Notify subscribers
//        await notifySubscribers(update)
//        
//        // Log statistics periodically
//        if updateCount % 100 == 0 {
//            await logStatistics()
//        }
//    }
//    
//    /// Reset the state (e.g., for new session)
//    func resetState() async {
//        logger.info("Resetting session state")
//        
//        currentState = JSON()
//        updateCount = 0
//        lastUpdate = Date()
//        
//        // Notify full state subscribers
//        for subscriber in fullStateSubscribers.values {
//            await subscriber(currentState)
//        }
//        
//        // Persist initial state if needed
//        if persistenceEnabled {
//            await persistInitialState()
//        }
//    }
//    
//    // MARK: - Statistics
//    
//    func getStatistics() -> SessionStatistics {
//        return SessionStatistics(
//            updateCount: updateCount,
//            lastUpdate: lastUpdate,
//            subscriberCount: subscribers.count,
//            fullStateSubscriberCount: fullStateSubscribers.count,
//            hasData: !isEmpty()
//        )
//    }
//    
//    // MARK: - Private Implementation
//    
//    private func shouldResetState(_ update: JSON) async -> Bool {
//        // Check for session info changes that indicate a new session
//        if let sessionName = update["sessionInfo"]["name"].string {
//            // If we have existing session info and the name changed, it's a new session
//            if let currentSessionName = currentState["sessionInfo"]["name"].string,
//               currentSessionName != sessionName {
//                return true
//            }
//        }
//        
//        return false
//    }
//    
//    private func mergeUpdate(_ update: JSON) async {
//        // Using SwiftyJSON's merge functionality
//        do {
//            try currentState.merge(with: update)
//        } catch {
//            logger.error("Failed to merge state update: \(error)")
//        }
//    }
//    
//    private func notifySubscribers(_ update: StateUpdate) async {
//        // Notify update subscribers
//        for subscriber in subscribers.values {
//            await subscriber(update)
//        }
//        
//        // Notify full state subscribers if this was a significant change
//        if isSignificantUpdate(update) {
//            for subscriber in fullStateSubscribers.values {
//                await subscriber(currentState)
//            }
//        }
//    }
//    
//    private func isSignificantUpdate(_ update: StateUpdate) -> Bool {
//        // Consider updates significant if they affect core timing or session data
//        let significantKeys = [
//            "timingData", "sessionInfo", "trackStatus", "sessionStatus",
//            "driverList", "lapCount", "raceControlMessages"
//        ]
//        
//        return update.updates.dictionary.keys.contains { key in
//            significantKeys.contains(key)
//        }
//    }
//    
//    private func isEmpty() -> Bool {
//        // Using SwiftyJSON's cleaner syntax
//        let hasDrivers = currentState["driverList"].array?.isEmpty == false
//        let hasTimingData = currentState["timingData"]["lines"].dictionary?.isEmpty == false
//        return !hasDrivers && !hasTimingData
//    }
//    
//    private func logStatistics() async {
//        let stats = getStatistics()
//        logger.info("""
//            Session State Statistics:
//            - Updates processed: \(stats.updateCount)
//            - Last update: \(stats.lastUpdate)
//            - Update subscribers: \(stats.subscriberCount)
//            - Full state subscribers: \(stats.fullStateSubscriberCount)
//            - Has data: \(stats.hasData)
//            """)
//    }
//    
//    // MARK: - Data Persistence
//    
//    /// Initialize database persistence
//    private func initializePersistence() async {
//        guard enablePersistence else { return }
//        
//        do {
//            try await DatabaseManager.shared.run()
//            persistenceEnabled = true
//            logger.info("Database persistence initialized successfully")
//        } catch {
//            logger.error("Failed to initialize database persistence: \(error)")
//            persistenceEnabled = false
//        }
//    }
//    
//    /// Persist update data to database
//    private func persistUpdateData(_ update: JSON) async {
//        // Process timing data updates - much cleaner with SwiftyJSON
//        if let timingLines = update["timingData"]["lines"].dictionary {
//            await persistTimingUpdate(timingLines)
//        }
//        
//        // Process timing app data updates (tire information)
//        if let timingAppLines = update["timingAppData"]["lines"].dictionary {
//            await persistTireUpdate(timingAppLines)
//        }
//    }
//    
//    /// Persist timing data updates
//    private func persistTimingUpdate(_ lines: [String: JSON]) async {
//        let currentLap = currentState["lapCount"]["currentLap"].int
//        
//        for (driverNr, updateData) in lines {
//            // Get current driver data - much cleaner syntax
//            guard let currentDriver = currentState["timingData"]["lines"][driverNr].dictionaryObject else {
//                continue
//            }
//          
//            
//            // Create TimingDataDriver from currentDriver dictionary
//            // Note: We need to get the current driver data in the correct format
//            // For now, create a minimal TimingDataDriver with available fields
//            guard let line = currentDriver["line"] as? Int,
//                  let racingNumber = currentDriver["racingNumber"] as? String else {
//                continue
//            }
//            
//            // Extract sectors data
//            var sectors: [Sector] = []
//            if let sectorsDict = currentDriver["sectors"] as? [String: Any] {
//                // Convert sectors dictionary to array
//                for i in 0..<3 {
//                    if let sectorData = sectorsDict[String(i)] as? [String: Any],
//                       let value = sectorData["value"] as? String {
//                        let sector = Sector(
//                            stopped: sectorData["stopped"] as? Bool ?? false,
//                            value: value,
//                            previousValue: sectorData["previousValue"] as? String,
//                            status: sectorData["status"] as? Int ?? 0,
//                            overallFastest: sectorData["overallFastest"] as? Bool ?? false,
//                            personalFastest: sectorData["personalFastest"] as? Bool ?? false,
//                            segments: []
//                        )
//                        sectors.append(sector)
//                    }
//                }
//            }
//            
//            // Extract best lap time
//            let bestLapTime = PersonalBestLapTime(
//                value: (currentDriver["bestLapTime"] as? [String: Any])?["value"] as? String ?? ""
//            )
//            
//            // Extract last lap time
//            let lastLapTime: LapTimeValue
//            if let lastLapDict = currentDriver["lastLapTime"] as? [String: Any] {
//                lastLapTime = LapTimeValue(
//                    value: lastLapDict["value"] as? String ?? "",
//                    status: lastLapDict["status"] as? Int ?? 0,
//                    overallFastest: lastLapDict["overallFastest"] as? Bool ?? false,
//                    personalFastest: lastLapDict["personalFastest"] as? Bool ?? false
//                )
//            } else {
//                lastLapTime = LapTimeValue(value: "", status: 0, overallFastest: false, personalFastest: false)
//            }
//            
//            let timingDriver = TimingDataDriver(
//                stats: nil,
//                timeDiffToFastest: currentDriver["timeDiffToFastest"] as? String,
//                timeDiffToPositionAhead: currentDriver["timeDiffToPositionAhead"] as? String,
//                gapToLeader: currentDriver["gapToLeader"] as? String ?? "",
//                intervalToPositionAhead: nil,
//                line: line,
//                racingNumber: racingNumber,
//                sectors: sectors,
//                bestLapTime: bestLapTime,
//                lastLapTime: lastLapTime
//            )
//            
//            // Parse timing data
//            if let timingData = DataParser.parseTimingDriver(
//                nr: driverNr,
//                lap: currentLap,
//                driver: timingDriver,
//                updateData: updateData.dictionaryObject ?? [:]
//            ) {
//                do {
//                    try await DatabaseManager.shared.insertTimingDriver(timingData)
//                } catch {
//                    logger.error("Failed to insert timing data for driver \(driverNr): \(error)")
//                }
//            }
//        }
//    }
//    
//    /// Persist tire data updates
//    private func persistTireUpdate(_ lines: [String: JSON]) async {
//        let currentLap = currentState["lapCount"]["currentLap"].int
//        
//        for (driverNr, updateData) in lines {
//            // Get current driver data
//            guard let currentDriver = currentState["timingAppData"]["lines"][driverNr].dictionaryObject else {
//                continue
//            }
//            
//            // Create TimingAppDataDriver from dictionary
//            guard let line = currentDriver["line"] as? Int,
//                  let gridPos = currentDriver["gridPos"] as? String else {
//                continue
//            }
//            
//            // Parse stints array
//            var stints: [Stint] = []
//            if let stintsArray = currentDriver["stints"] as? [[String: Any]] {
//                for stintDict in stintsArray {
//                    let stint = Stint(
//                        totalLaps: stintDict["totalLaps"] as? Int,
//                        compound: TireCompound(rawValue: stintDict["compound"] as? String ?? ""),
//                        isNew: stintDict["new"] as? Bool
//                    )
//                    stints.append(stint)
//                }
//            }
//            
//            let timingAppDriver = TimingAppDataDriver(
//                racingNumber: driverNr,
//                stints: stints,
//                line: line,
//                gridPos: gridPos
//            )
//            
//            // Parse tire data
//            if let tireData = DataParser.parseTireDriver(
//                nr: driverNr,
//                lap: currentLap,
//                driver: timingAppDriver,
//                updateData: updateData.dictionaryObject ?? [:]
//            ) {
//                do {
//                    try await DatabaseManager.shared.insertTireDriver(tireData)
//                } catch {
//                    logger.error("Failed to insert tire data for driver \(driverNr): \(error)")
//                }
//            }
//        }
//    }
//    
//    /// Persist initial state data to database
//    private func persistInitialState() async {
//        guard persistenceEnabled else { return }
//        
//        let currentLap = currentState["lapCount"]["currentLap"].int
//        
//        // Persist initial timing data - cleaner iteration with SwiftyJSON
//        for (driverNr, driverJSON) in currentState["timingData"]["lines"].dictionary ?? [:] {
//            guard let driverDict = driverJSON.dictionaryObject else { continue }
//            
//            // Create TimingDataDriver from dictionary
//            guard let line = driverDict["line"] as? Int else {
//                continue
//            }
//            
//            // Extract sectors data
//            var sectors: [Sector] = []
//            if let sectorsDict = driverDict["sectors"] as? [String: Any] {
//                // Convert sectors dictionary to array
//                for i in 0..<3 {
//                    if let sectorData = sectorsDict[String(i)] as? [String: Any],
//                       let value = sectorData["value"] as? String {
//                        let sector = Sector(
//                            stopped: sectorData["stopped"] as? Bool ?? false,
//                            value: value,
//                            previousValue: sectorData["previousValue"] as? String,
//                            status: sectorData["status"] as? Int ?? 0,
//                            overallFastest: sectorData["overallFastest"] as? Bool ?? false,
//                            personalFastest: sectorData["personalFastest"] as? Bool ?? false,
//                            segments: []
//                        )
//                        sectors.append(sector)
//                    }
//                }
//            }
//            
//            // Extract best lap time
//            let bestLapTime = PersonalBestLapTime(
//                value: (driverDict["bestLapTime"] as? [String: Any])?["value"] as? String ?? ""
//            )
//            
//            // Extract last lap time  
//            let lastLapTime: LapTimeValue
//            if let lastLapDict = driverDict["lastLapTime"] as? [String: Any] {
//                lastLapTime = LapTimeValue(
//                    value: lastLapDict["value"] as? String ?? "",
//                    status: lastLapDict["status"] as? Int ?? 0,
//                    overallFastest: lastLapDict["overallFastest"] as? Bool ?? false,
//                    personalFastest: lastLapDict["personalFastest"] as? Bool ?? false
//                )
//            } else {
//                lastLapTime = LapTimeValue(value: "", status: 0, overallFastest: false, personalFastest: false)
//            }
//            
//            let timingDriver = TimingDataDriver(
//                stats: nil,
//                timeDiffToFastest: driverDict["timeDiffToFastest"] as? String,
//                timeDiffToPositionAhead: driverDict["timeDiffToPositionAhead"] as? String,
//                gapToLeader: driverDict["gapToLeader"] as? String ?? "",
//                intervalToPositionAhead: nil,
//                line: line,
//                racingNumber: driverDict["racingNumber"] as? String ?? "",
//                sectors: sectors,
//                bestLapTime: bestLapTime,
//                lastLapTime: lastLapTime
//            )
//            
//            if let timingDriverData = DataParser.parseTimingDriver(
//                nr: driverNr,
//                lap: currentLap,
//                driver: timingDriver
//            ) {
//                do {
//                    try await DatabaseManager.shared.insertTimingDriver(timingDriverData)
//                } catch {
//                    logger.error("Failed to insert initial timing data for driver \(driverNr): \(error)")
//                }
//            }
//        }
//        
//        // Persist initial tire data
//        for (driverNr, driverJSON) in currentState["timingAppData"]["lines"].dictionary ?? [:] {
//            guard let driverDict = driverJSON.dictionaryObject else { continue }
//            
//            guard let line = driverDict["line"] as? Int,
//                  let gridPos = driverDict["gridPos"] as? String else {
//                continue  
//            }
//            
//            // Parse stints array
//            var stints: [Stint] = []
//            if let stintsArray = driverDict["stints"] as? [[String: Any]] {
//                for stintDict in stintsArray {
//                    let stint = Stint(
//                        totalLaps: stintDict["totalLaps"] as? Int,
//                        compound: TireCompound(rawValue: stintDict["compound"] as? String ?? ""),
//                        isNew: stintDict["new"] as? Bool
//                    )
//                    stints.append(stint)
//                }
//            }
//            
//            let timingAppDriver = TimingAppDataDriver(
//                racingNumber: driverNr,
//                stints: stints,
//                line: line,
//                gridPos: gridPos
//            )
//            
//            if let tireDriverData = DataParser.parseTireDriver(
//                nr: driverNr,
//                lap: currentLap,
//                driver: timingAppDriver
//            ) {
//                do {
//                    try await DatabaseManager.shared.insertTireDriver(tireDriverData)
//                } catch {
//                    logger.error("Failed to insert initial tire data for driver \(driverNr): \(error)")
//                }
//            }
//        }
//    }
//    
//    /// Get database health status
//    func getDatabaseHealth() async -> DatabaseHealth? {
//        guard enablePersistence else { return nil }
//        return await DatabaseManager.shared.healthCheck()
//    }
//}
//
//// Keep the same SessionStatistics struct as before
