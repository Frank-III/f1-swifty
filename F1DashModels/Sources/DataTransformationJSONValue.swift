import Foundation

/// Utilities for transforming F1 data between formats using JSONValue
public struct DataTransformationJSONValue {
    
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
    public static func transformKeys(_ value: JSONValue) -> JSONValue {
        switch value {
        case .object(let dict):
            var transformed: [String: JSONValue] = [:]
            
            for (key, value) in dict {
                // Skip _kf keys (internal F1 keys)
                if key == "_kf" {
                    continue
                }
                
                let transformedKey = toCamelCase(key)
                transformed[transformedKey] = transformKeys(value)
            }
            
            return .object(transformed)
            
        case .array(let array):
            return .array(array.map(transformKeys))
            
        default:
            return value
        }
    }
    
    /// Merge two F1 state values, with update taking precedence
    public static func mergeStates(_ base: JSONValue, with update: JSONValue, parentKey: String? = nil) -> JSONValue {
        switch (base, update) {
        case (.object(let baseDict), .object(let updateDict)):
            var merged = baseDict
            
            // Special handling based on parent key
            if let parentKey = parentKey {
                switch parentKey {
                // For driverList and similar dictionaries, replace entries entirely
                case "driverList", "lines":
                    for (key, updateValue) in updateDict {
                        merged[key] = updateValue // Replace entire entry
                    }
                    return .object(merged)
                    
                default:
                    break
                }
            }
            
            // Default object merging
            for (key, updateValue) in updateDict {
                switch key {
                // Special handling for known dictionary collections
                case "driverList":
                    if case .object(var existingDrivers) = merged[key],
                       case .object(let updateDrivers) = updateValue {
                        // Merge at the driver level - each driver entry is replaced entirely
                        for (driverNum, driverData) in updateDrivers {
                            existingDrivers[driverNum] = driverData
                        }
                        merged[key] = .object(existingDrivers)
                    } else {
                        merged[key] = updateValue
                    }
                    
                // Handle timing data with special care for the 'lines' subdictionary
                case "timingData", "timingAppData", "carData", "positionData":
                    if case .object(var existingData) = merged[key],
                       case .object(let updateData) = updateValue {
                        
                        // Check if this has a "lines" sub-dictionary
                        if case .object(var existingLines) = existingData["lines"],
                           case .object(let updateLines) = updateData["lines"] {
                            // Each line entry should be replaced entirely
                            for (lineKey, lineValue) in updateLines {
                                existingLines[lineKey] = lineValue
                            }
                            existingData["lines"] = .object(existingLines)
                        }
                        
                        // Merge other fields
                        for (k, v) in updateData {
                            if k == "lines" { continue } // Already handled
                            existingData[k] = v
                        }
                        merged[key] = .object(existingData)
                    } else {
                        merged[key] = updateValue
                    }
                    
                // Arrays should be replaced entirely
                case "raceControlMessages", "teamRadio":
                    merged[key] = updateValue
                    
                // Default recursive merge for other objects
                default:
                    if let existingValue = merged[key] {
                        merged[key] = mergeStates(existingValue, with: updateValue, parentKey: key)
                    } else {
                        merged[key] = updateValue
                    }
                }
            }
            
            return .object(merged)
            
        case (.array(let baseArray), .array(let updateArray)):
            // Arrays are extended with new values
            return .array(baseArray + updateArray)
            
        case (.array(_), .object(_)):
            // Don't support array merging by index - just replace
            return update
            
        default:
            // For all other cases, update takes precedence
            return update
        }
    }
    
    /// Convert [String: Any] to JSONValue and transform keys
    public static func transformFromDictionary(_ dictionary: [String: Any]) -> JSONValue {
        let jsonValue = JSONValue(from: dictionary)
        return transformKeys(jsonValue)
    }
    
    /// Merge [String: Any] dictionaries and return JSONValue
    public static func mergeFromDictionaries(_ base: [String: Any], with update: [String: Any]) -> JSONValue {
        let baseValue = JSONValue(from: base)
        let updateValue = JSONValue(from: update)
        return mergeStates(baseValue, with: updateValue, parentKey: nil)
    }
}

/// Extension to help with migration from [String: Any] to JSONValue
public extension JSONValue {
    /// Safe subscript access for object values
    subscript(key: String) -> JSONValue? {
        switch self {
        case .object(let dict):
            return dict[key]
        default:
            return nil
        }
    }
    
    /// Safe subscript access for array values
    subscript(index: Int) -> JSONValue? {
        switch self {
        case .array(let array) where index >= 0 && index < array.count:
            return array[index]
        default:
            return nil
        }
    }
    
    /// Get string value if this is a string
    var stringValue: String? {
        switch self {
        case .string(let value):
            return value
        default:
            return nil
        }
    }
    
    /// Get integer value if this is an int
    var intValue: Int? {
        switch self {
        case .int(let value):
            return value
        default:
            return nil
        }
    }
    
    /// Get double value if this is a double or int
    var doubleValue: Double? {
        switch self {
        case .double(let value):
            return value
        case .int(let value):
            return Double(value)
        default:
            return nil
        }
    }
    
    /// Get boolean value if this is a bool
    var boolValue: Bool? {
        switch self {
        case .bool(let value):
            return value
        default:
            return nil
        }
    }
}