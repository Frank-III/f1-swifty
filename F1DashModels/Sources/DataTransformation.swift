import Foundation

/// Utilities for transforming F1 data between formats
public struct DataTransformation {
    
    /// Convert snake_case to camelCase for F1 data
    /// Also handles PascalCase by converting first letter to lowercase
    public static func toCamelCase(_ string: String) -> String {
        // Handle snake_case
        let components = string.components(separatedBy: "_")
        if components.count > 1 {
            let first = components[0].lowercased()
            let rest = components.dropFirst().map { $0.capitalized }
            return ([first] + rest).joined()
        }
        
        // Handle PascalCase (first letter uppercase) - convert to camelCase
        guard !string.isEmpty else { return string }
        return string.prefix(1).lowercased() + string.dropFirst()
    }
    
    /// Transform dictionary keys from snake_case to camelCase
    public static func transformKeys(_ dictionary: [String: Any]) -> [String: Any] {
        var transformed: [String: Any] = [:]
        
        for (key, value) in dictionary {
            // Skip _kf keys (internal F1 keys)
            if key == "_kf" {
                continue
            }
            
            let transformedKey = toCamelCase(key)
            
            if let nestedDict = value as? [String: Any] {
                transformed[transformedKey] = transformKeys(nestedDict)
            } else if let array = value as? [[String: Any]] {
                transformed[transformedKey] = array.map(transformKeys)
            } else {
                transformed[transformedKey] = value
            }
        }
        
        return transformed
    }
    
    /// Merge two F1 state dictionaries, with update taking precedence
    public static func mergeStates(_ base: inout [String: Any], with update: [String: Any]) {
        for (key, value) in update {
            switch key {
            // Special handling for driverList - each driver entry should be replaced entirely
            case "driverList":
                if var existingDrivers = base[key] as? [String: Any],
                   let updateDrivers = value as? [String: Any] {
                    // Merge at the driver level - each driver entry is replaced entirely
                    for (driverNum, driverData) in updateDrivers {
                        existingDrivers[driverNum] = driverData
                    }
                    base[key] = existingDrivers
                } else {
                    base[key] = value
                }
                
            // Handle timing data with special care for the 'lines' subdictionary
            case "timingData", "timingAppData", "carData", "positionData":
                if var existingData = base[key] as? [String: Any],
                   let updateData = value as? [String: Any] {
                    
                    // Check if this has a "lines" sub-dictionary (common pattern in F1 data)
                    if var existingLines = existingData["lines"] as? [String: Any],
                       let updateLines = updateData["lines"] as? [String: Any] {
                        // Each line entry (by driver number) should be replaced entirely
                        for (lineKey, lineValue) in updateLines {
                            existingLines[lineKey] = lineValue
                        }
                        existingData["lines"] = existingLines
                    }
                    
                    // Merge other fields at top level
                    for (k, v) in updateData {
                        if k == "lines" { continue } // Already handled above
                        existingData[k] = v
                    }
                    base[key] = existingData
                } else {
                    base[key] = value
                }
                
            // Arrays should typically be replaced entirely, not merged
            case "raceControlMessages", "teamRadio":
                if let updateArray = value as? [[String: Any]] {
                    base[key] = updateArray
                } else {
                    base[key] = value
                }
                
            // For other nested objects, do recursive merge
            default:
                if let existingDict = base[key] as? [String: Any],
                   let updateDict = value as? [String: Any] {
                    var merged = existingDict
                    mergeStates(&merged, with: updateDict)
                    base[key] = merged
                } else if let existingArray = base[key] as? [Any],
                          let updateArray = value as? [Any] {
                    // For arrays, extend with new values
                    base[key] = existingArray + updateArray
                } else {
                    // Simple value replacement
                    base[key] = value
                }
            }
        }
    }
}

/// F1 specific data parsing utilities
public struct F1DataParser {
    
    /// Parse gap string to milliseconds
    /// Examples: "", "+0.273", "1L", "20L", "LAP1"
    public static func parseGap(_ gap: String) -> Int64 {
        let trimmed = gap.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return 0
        }
        
        // Handle lap indicators
        if trimmed.contains("L") || trimmed.hasPrefix("LAP") {
            return 0
        }
        
        // Parse time gap (remove + prefix)
        let cleanGap = trimmed.replacingOccurrences(of: "+", with: "")
        
        if let seconds = Double(cleanGap) {
            return Int64(seconds * 1000) // Convert to milliseconds
        }
        
        return 0
    }
    
    /// Parse lap time string to milliseconds
    /// Examples: "1:21.306", ""
    public static func parseLaptime(_ laptime: String) -> Int64 {
        let trimmed = laptime.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return 0
        }
        
        let components = trimmed.components(separatedBy: ":")
        
        if components.count == 2,
           let minutes = Int(components[0]),
           let seconds = Double(components[1]) {
            let minutesMs = Int64(minutes * 60 * 1000)
            let secondsMs = Int64(seconds * 1000)
            return minutesMs + secondsMs
        }
        
        return 0
    }
    
    /// Parse sector time to milliseconds
    /// Examples: "26.259", ""
    public static func parseSector(_ sector: String) -> Int64 {
        let trimmed = sector.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return 0
        }
        
        if let seconds = Double(trimmed) {
            return Int64(seconds * 1000) // Convert to milliseconds
        }
        
        return 0
    }
    
    /// Format milliseconds to lap time string
    public static func formatLaptime(_ milliseconds: Int64) -> String {
        guard milliseconds > 0 else { return "" }
        
        let totalSeconds = Double(milliseconds) / 1000.0
        let minutes = Int(totalSeconds) / 60
        let seconds = totalSeconds.truncatingRemainder(dividingBy: 60)
        
        return String(format: "%d:%06.3f", minutes, seconds)
    }
    
    /// Format milliseconds to gap string
    public static func formatGap(_ milliseconds: Int64) -> String {
        guard milliseconds > 0 else { return "" }
        
        let seconds = Double(milliseconds) / 1000.0
        return String(format: "+%.3f", seconds)
    }
}