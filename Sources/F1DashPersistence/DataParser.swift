import Foundation
import F1DashModels
import Logging

/// Utility for parsing F1 data models into database-compatible formats
public struct DataParser {
    private static let logger = Logger(label: "DataParser")
    
    // MARK: - Gap Parsing
    
    /// Parse gap string to milliseconds (mirrors Rust parse_gap)
    /// Handles formats like: "LAP1" / "" / "+0.273" / "1L" / "20L"
    public static func parseGap(_ gap: String) -> Int64 {
        if gap.isEmpty {
            logger.trace("Gap empty: '\(gap)'")
            return 0
        }
        
        if gap.contains("L") {
            logger.trace("Gap contains L: '\(gap)'")
            return 0
        }
        
        let cleanGap = gap.replacingOccurrences(of: "+", with: "")
        if let seconds = Double(cleanGap) {
            let milliseconds = Int64(seconds * 1000.0)
            logger.trace("Gap parsed: '\(gap)' -> \(milliseconds)ms")
            return milliseconds
        }
        
        logger.trace("Gap failed to parse: '\(gap)'")
        return 0
    }
    
    // MARK: - Laptime Parsing
    
    /// Parse laptime string to milliseconds (mirrors Rust parse_laptime)
    /// Handles formats like: "1:21.306" / ""
    public static func parseLaptime(_ laptime: String) -> Int64 {
        if laptime.isEmpty {
            logger.trace("Laptime empty: '\(laptime)'")
            return 0
        }
        
        let parts = laptime.split(separator: ":")
        if parts.count == 2 {
            if let minutes = Int64(parts[0]),
               let seconds = Double(parts[1]) {
                let totalMilliseconds = minutes * 60_000 + Int64(seconds * 1000.0)
                logger.trace("Laptime parsed: '\(laptime)' -> \(totalMilliseconds)ms")
                return totalMilliseconds
            }
        }
        
        logger.trace("Laptime failed to parse: '\(laptime)'")
        return 0
    }
    
    // MARK: - Sector Parsing
    
    /// Parse sector time string to milliseconds (mirrors Rust parse_sector)
    /// Handles formats like: "26.259" / ""
    public static func parseSector(_ sector: String) -> Int64 {
        if sector.isEmpty {
            logger.trace("Sector empty: '\(sector)'")
            return 0
        }
        
        if let seconds = Double(sector) {
            let milliseconds = Int64(seconds * 1000.0)
            logger.trace("Sector parsed: '\(sector)' -> \(milliseconds)ms")
            return milliseconds
        }
        
        logger.trace("Sector failed to parse: '\(sector)'")
        return 0
    }
    
    // MARK: - Timing Data Conversion
    
    /// Convert TimingDataDriver to TimingDriverData for database insertion
    /// (mirrors Rust parse_timing_driver)
    public static func parseTimingDriver(
        nr: String,
        lap: Int?,
        driver: TimingDataDriver,
        updateData: [String: Any]? = nil
    ) -> TimingDriverData? {
        
        // Extract updated values from update data if available
        let gapValue: String
        let leaderGapValue: String
        let laptimeValue: String
        let sector1Value: String
        let sector2Value: String
        let sector3Value: String
        
        if let update = updateData {
            gapValue = extractString(from: update, keyPath: "intervalToPositionAhead.value") 
                      ?? driver.intervalToPositionAhead?.value ?? ""
            leaderGapValue = extractString(from: update, keyPath: "gapToLeader") 
                           ?? driver.gapToLeader ?? ""
            laptimeValue = extractString(from: update, keyPath: "lastLapTime.value") 
                         ?? driver.lastLapTime?.value ?? ""
            
            // Extract sector values
            sector1Value = extractString(from: update, keyPath: "sectors.0.value") 
                         ?? (driver.sectors.count > 0 ? driver.sectors[0].value : "")
            sector2Value = extractString(from: update, keyPath: "sectors.1.value") 
                         ?? (driver.sectors.count > 1 ? driver.sectors[1].value : "")
            sector3Value = extractString(from: update, keyPath: "sectors.2.value") 
                         ?? (driver.sectors.count > 2 ? driver.sectors[2].value : "")
        } else {
            // Use current values
            gapValue = driver.intervalToPositionAhead?.value ?? ""
            leaderGapValue = driver.gapToLeader ?? ""
            laptimeValue = driver.lastLapTime?.value ?? ""
            sector1Value = driver.sectors.count > 0 ? driver.sectors[0].value : ""
            sector2Value = driver.sectors.count > 1 ? driver.sectors[1].value : ""
            sector3Value = driver.sectors.count > 2 ? driver.sectors[2].value : ""
        }
        
        // Only create record if we have meaningful data updates
        if updateData != nil {
            let hasGapUpdate = extractString(from: updateData!, keyPath: "intervalToPositionAhead.value") != nil
            let hasLeaderGapUpdate = extractString(from: updateData!, keyPath: "gapToLeader") != nil
            let hasLaptimeUpdate = extractString(from: updateData!, keyPath: "lastLapTime.value") != nil
            let hasSectorUpdate = extractString(from: updateData!, keyPath: "sectors.0.value") != nil ||
                                extractString(from: updateData!, keyPath: "sectors.1.value") != nil ||
                                extractString(from: updateData!, keyPath: "sectors.2.value") != nil
            
            if !hasGapUpdate && !hasLeaderGapUpdate && !hasLaptimeUpdate && !hasSectorUpdate {
                return nil // No meaningful timing updates
            }
        }
        
        return TimingDriverData(
            nr: nr,
            lap: lap,
            gap: parseGap(gapValue),
            leaderGap: parseGap(leaderGapValue),
            laptime: parseLaptime(laptimeValue),
            sector1: parseSector(sector1Value),
            sector2: parseSector(sector2Value),
            sector3: parseSector(sector3Value)
        )
    }
    
    // MARK: - Tire Data Conversion
    
    /// Convert TimingAppDataDriver to TireDriverData for database insertion
    /// (mirrors Rust parse_tire_driver)
    public static func parseTireDriver(
        nr: String,
        lap: Int?,
        driver: TimingAppDataDriver,
        updateData: [String: Any]? = nil
    ) -> TireDriverData? {
        
        // Get the last stint (current tire)
        guard let lastStint = driver.stints.last else {
            logger.trace("No stint data available for driver \(nr)")
            return nil
        }
        
        let compound: String
        let laps: Int
        
        if let update = updateData,
           let stintsArray = update["stints"] as? [[String: Any]],
           let lastStintUpdate = stintsArray.last {
            
            // Use updated values or fall back to current values
            compound = lastStintUpdate["compound"] as? String ?? lastStint.compound?.rawValue ?? ""
            laps = lastStintUpdate["totalLaps"] as? Int ?? lastStint.totalLaps ?? 0
            
            // Only create record if we have meaningful tire updates
            let hasCompoundUpdate = lastStintUpdate["compound"] != nil
            let hasLapsUpdate = lastStintUpdate["totalLaps"] != nil
            
            if !hasCompoundUpdate && !hasLapsUpdate {
                return nil // No meaningful tire updates
            }
        } else {
            // Use current values (for initial state)
            compound = lastStint.compound?.rawValue ?? ""
            laps = lastStint.totalLaps ?? 0
        }
        
        guard !compound.isEmpty else {
            logger.trace("Empty compound for driver \(nr)")
            return nil
        }
        
        return TireDriverData(
            nr: nr,
            lap: lap,
            compound: compound,
            laps: laps
        )
    }
    
    // MARK: - Helper Methods
    
    /// Extract string value from nested dictionary using key path
    private static func extractString(from dict: [String: Any], keyPath: String) -> String? {
        let keys = keyPath.split(separator: ".")
        var current: Any = dict
        
        for key in keys {
            if let currentDict = current as? [String: Any] {
                if let index = Int(key), let array = current as? [Any] {
                    guard index < array.count else { return nil }
                    current = array[index]
                } else {
                    guard let value = currentDict[String(key)] else { return nil }
                    current = value
                }
            } else if let array = current as? [Any], let index = Int(key) {
                guard index < array.count else { return nil }
                current = array[index]
            } else {
                return nil
            }
        }
        
        return current as? String
    }
}