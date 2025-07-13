#!/usr/bin/env swift

import Foundation

// Sample position data structure
let jsonString = """
{
    "positionData": [
        {
            "timestamp": "2023-07-01T14:45:19.1090551Z",
            "entries": {
                "1": {"x": -1362, "y": 4963, "z": 7634, "status": "OnTrack"},
                "10": {"x": -2738, "y": -2236, "z": 7338, "status": "OnTrack"},
                "11": {"x": -6686, "y": 5674, "z": 7833, "status": "OnTrack"}
            }
        }
    ]
}
"""

print("=== Position Data Decoding Test ===")

// Parse JSON
guard let jsonData = jsonString.data(using: .utf8),
      let outerDict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
      let positionArray = outerDict["positionData"] as? [[String: Any]] else {
    print("Failed to parse JSON")
    exit(1)
}

print("Raw position array count: \(positionArray.count)")

// Check first entry
if let firstEntry = positionArray.first {
    print("\nFirst entry keys: \(firstEntry.keys.sorted())")
    
    if let entries = firstEntry["entries"] as? [String: Any] {
        print("Entries count: \(entries.count)")
        
        // Check driver 1 data
        if let driver1 = entries["1"] as? [String: Any] {
            print("\nDriver 1 raw data:")
            for (key, value) in driver1 {
                print("  \(key): \(type(of: value)) = \(value)")
            }
        }
    }
}

// Test conversion logic
print("\n=== Testing Conversion Logic ===")

var convertedArray: [[String: Any]] = []

for entry in positionArray {
    guard let timestamp = entry["timestamp"] as? String,
          let entries = entry["entries"] as? [String: Any] else {
        print("Skipping malformed entry")
        continue
    }
    
    var convertedEntries: [String: Any] = [:]
    
    for (driverNumber, driverData) in entries {
        guard let driverDict = driverData as? [String: Any] else {
            continue
        }
        
        var convertedDriver: [String: Any] = [:]
        
        // Status is required
        guard let status = driverDict["status"] as? String else {
            print("Missing status for driver \(driverNumber)")
            continue
        }
        convertedDriver["status"] = status
        
        // Convert x, y, z to Double
        if let x = driverDict["x"] {
            if let intX = x as? Int {
                convertedDriver["x"] = Double(intX)
                print("Driver \(driverNumber): Converted x from Int(\(intX)) to Double")
            } else if let doubleX = x as? Double {
                convertedDriver["x"] = doubleX
            }
        }
        
        if let y = driverDict["y"] {
            if let intY = y as? Int {
                convertedDriver["y"] = Double(intY)
            } else if let doubleY = y as? Double {
                convertedDriver["y"] = doubleY
            }
        }
        
        if let z = driverDict["z"] {
            if let intZ = z as? Int {
                convertedDriver["z"] = Double(intZ)
            } else if let doubleZ = z as? Double {
                convertedDriver["z"] = doubleZ
            }
        }
        
        if let x = convertedDriver["x"], let y = convertedDriver["y"], let z = convertedDriver["z"] {
            convertedEntries[driverNumber] = convertedDriver
            print("Driver \(driverNumber): Successfully converted with all coordinates")
        } else {
            print("Driver \(driverNumber): Missing coordinates after conversion")
        }
    }
    
    convertedArray.append([
        "timestamp": timestamp,
        "entries": convertedEntries
    ])
}

print("\nConverted array count: \(convertedArray.count)")
print("First converted entry has \(convertedArray.first?["entries"] as? [String: Any])?.count ?? 0) drivers")

// Now create the wrapped data for PositionData model
let wrappedData: [String: Any] = ["position": convertedArray]

// Convert to JSON and print
do {
    let jsonData = try JSONSerialization.data(withJSONObject: wrappedData, options: .prettyPrinted)
    if let jsonString = String(data: jsonData, encoding: .utf8) {
        print("\n=== JSON for PositionData Model ===")
        print(jsonString.prefix(500))
        print("...")
    }
} catch {
    print("Failed to convert to JSON: \(error)")
}

print("\n=== Test Complete ===")