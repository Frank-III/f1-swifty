import Foundation

/// Utilities for transforming F1 data between formats
public struct DataTransformation {
    
    /// Convert snake_case to camelCase for F1 data
    /// Also handles PascalCase by converting first letter to lowercase
    /// Special handling for F1 topic names that need specific mappings
    public static func toCamelCase(_ string: String) -> String {
        // Special cases for F1 topics that don't follow standard camelCase
        switch string {
        case "Position":
            return "positionData"
        default:
            break
        }
        
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
        for (key, updateValue) in update {
            if let baseValue = base[key] {
                // Both are dictionaries - merge recursively
                if var baseDict = baseValue as? [String: Any],
                let updateDict = updateValue as? [String: Any] {
                    mergeStates(&baseDict, with: updateDict)
                    base[key] = baseDict
                }
                // Both are arrays - extend
                else if var baseArray = baseValue as? [Any],
                        let updateArray = updateValue as? [Any] {
                    baseArray.append(contentsOf: updateArray)
                    base[key] = baseArray
                }
                // Base is array, update is dictionary - handle indexed updates
                else if var baseArray = baseValue as? [Any],
                        let updateDict = updateValue as? [String: Any] {
                    for (indexKey, indexValue) in updateDict {
                        if let index = Int(indexKey), index < baseArray.count {
                            // Merge if both are dictionaries
                            if var baseElement = baseArray[index] as? [String: Any],
                            let updateElement = indexValue as? [String: Any] {
                                mergeStates(&baseElement, with: updateElement)
                                baseArray[index] = baseElement
                            } else {
                                baseArray[index] = indexValue
                            }
                        }
                    }
                    base[key] = baseArray
                }
                // Otherwise replace
                else {
                    base[key] = updateValue
                }
            } else {
                // Key doesn't exist in base - just add it
                base[key] = updateValue
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
