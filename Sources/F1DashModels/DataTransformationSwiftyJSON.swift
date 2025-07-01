//import Foundation
//import SwiftyJSON
//
///// Utilities for transforming F1 data between formats using SwiftyJSON
//public struct DataTransformationSwiftyJSON {
//    
//    /// Convert snake_case to camelCase for F1 data
//    public static func toCamelCase(_ string: String) -> String {
//        let components = string.components(separatedBy: "_")
//        guard components.count > 1 else { return string }
//        
//        let first = components[0].lowercased()
//        let rest = components.dropFirst().map { $0.capitalized }
//        
//        return ([first] + rest).joined()
//    }
//    
//    /// Transform JSON keys from snake_case to camelCase
//    public static func transformKeys(_ json: JSON) -> JSON {
//        var transformed = JSON()
//        
//        // Handle arrays
//        if let array = json.array {
//            transformed = JSON(array.map { transformKeys($0) })
//            return transformed
//        }
//        
//        // Handle dictionaries
//        guard let dict = json.dictionary else {
//            return json
//        }
//        
//        for (key, value) in dict {
//            // Skip _kf keys (internal F1 keys)
//            if key == "_kf" {
//                continue
//            }
//            
//            let transformedKey = toCamelCase(key)
//            
//            // Recursively transform nested structures
//            if value.dictionary != nil {
//                transformed[transformedKey] = transformKeys(value)
//            } else if value.array != nil {
//                transformed[transformedKey] = transformKeys(value)
//            } else {
//                transformed[transformedKey] = value
//            }
//        }
//        
//        return transformed
//    }
//    
//    /// Merge two F1 state JSON objects using SwiftyJSON's merge
//    public static func mergeStates(_ base: inout JSON, with update: JSON) throws {
//        // SwiftyJSON's merge handles nested structures automatically
//        try base.merge(with: update)
//    }
//    
//    /// Custom merge that handles array updates by index
//    public static func mergeStatesWithArraySupport(_ base: inout JSON, with update: JSON) {
//        for (key, updateValue) in update.dictionaryValue {
//            if let baseDict = base[key].dictionary,
//               let updateDict = updateValue.dictionary {
//                // Merge nested dictionaries
//                var mergedDict = base[key]
//                mergeStatesWithArraySupport(&mergedDict, with: updateValue)
//                base[key] = mergedDict
//            } else if let baseArray = base[key].array,
//                      let updateDict = updateValue.dictionary {
//                // Handle array merging by index
//                var mergedArray = baseArray
//                for (indexStr, updateItem) in updateDict {
//                    if let index = Int(indexStr), index < mergedArray.count {
//                        mergedArray[index] = updateItem
//                    } else {
//                        // Append new item if index is out of bounds
//                        mergedArray.append(updateItem)
//                    }
//                }
//                base[key] = JSON(mergedArray)
//            } else {
//                // Direct replacement
//                base[key] = updateValue
//            }
//        }
//    }
//}
//
///// F1 specific data parsing utilities with SwiftyJSON
//public struct F1DataParserSwiftyJSON {
//    
//    /// Parse gap string to milliseconds
//    /// Examples: "", "+0.273", "1L", "20L", "LAP1"
//    public static func parseGap(_ gap: String?) -> Int64 {
//        guard let gap = gap else { return 0 }
//        
//        let trimmed = gap.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        if trimmed.isEmpty {
//            return 0
//        }
//        
//        // Handle lap indicators
//        if trimmed.contains("L") || trimmed.hasPrefix("LAP") {
//            return 0
//        }
//        
//        // Parse time gap (remove + prefix)
//        let cleanGap = trimmed.replacingOccurrences(of: "+", with: "")
//        
//        if let seconds = Double(cleanGap) {
//            return Int64(seconds * 1000) // Convert to milliseconds
//        }
//        
//        return 0
//    }
//    
//    /// Parse lap time string to milliseconds
//    /// Examples: "1:21.306", ""
//    public static func parseLaptime(_ laptime: String?) -> Int64 {
//        guard let laptime = laptime else { return 0 }
//        
//        let trimmed = laptime.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        if trimmed.isEmpty {
//            return 0
//        }
//        
//        let components = trimmed.components(separatedBy: ":")
//        
//        if components.count == 2,
//           let minutes = Int(components[0]),
//           let seconds = Double(components[1]) {
//            let minutesMs = Int64(minutes * 60 * 1000)
//            let secondsMs = Int64(seconds * 1000)
//            return minutesMs + secondsMs
//        }
//        
//        return 0
//    }
//    
//    /// Parse sector time to milliseconds
//    /// Examples: "26.259", ""
//    public static func parseSector(_ sector: String?) -> Int64 {
//        guard let sector = sector else { return 0 }
//        
//        let trimmed = sector.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        if trimmed.isEmpty {
//            return 0
//        }
//        
//        if let seconds = Double(trimmed) {
//            return Int64(seconds * 1000) // Convert to milliseconds
//        }
//        
//        return 0
//    }
//    
//    /// Parse timing data from JSON
//    public static func parseTimingFromJSON(_ json: JSON) -> (gap: Int64, lastLap: Int64, bestLap: Int64) {
//        let gap = parseGap(json["gapToLeader"].string)
//        let lastLap = parseLaptime(json["lastLapTime"]["value"].string)
//        let bestLap = parseLaptime(json["bestLapTime"]["value"].string)
//        
//        return (gap: gap, lastLap: lastLap, bestLap: bestLap)
//    }
//    
//    /// Parse sector times from JSON
//    public static func parseSectorsFromJSON(_ json: JSON) -> [Int64] {
//        var sectors: [Int64] = []
//        
//        if let sector1 = json["sectors"]["0"]["value"].string {
//            sectors.append(parseSector(sector1))
//        }
//        if let sector2 = json["sectors"]["1"]["value"].string {
//            sectors.append(parseSector(sector2))
//        }
//        if let sector3 = json["sectors"]["2"]["value"].string {
//            sectors.append(parseSector(sector3))
//        }
//        
//        return sectors
//    }
//    
//    /// Format milliseconds to lap time string
//    public static func formatLaptime(_ milliseconds: Int64) -> String {
//        guard milliseconds > 0 else { return "" }
//        
//        let totalSeconds = Double(milliseconds) / 1000.0
//        let minutes = Int(totalSeconds) / 60
//        let seconds = totalSeconds.truncatingRemainder(dividingBy: 60)
//        
//        return String(format: "%d:%06.3f", minutes, seconds)
//    }
//    
//    /// Format milliseconds to gap string
//    public static func formatGap(_ milliseconds: Int64) -> String {
//        guard milliseconds > 0 else { return "" }
//        
//        let seconds = Double(milliseconds) / 1000.0
//        return String(format: "+%.3f", seconds)
//    }
//}
