import Foundation

/// Position data containing car coordinates on track
public struct PositionData: Sendable, Codable, Equatable {
    public let position: [PositionItem]?
    
    public init(position: [PositionItem]? = nil) {
        self.position = position
    }
}

/// Position data entry for a specific timestamp
public struct PositionItem: Sendable, Codable, Equatable {
    public let timestamp: String
    public let entries: [String: PositionCar]
    
    public init(timestamp: String, entries: [String: PositionCar]) {
        self.timestamp = timestamp
        self.entries = entries
    }
}

/// Car position coordinates
public struct PositionCar: Sendable, Codable, Equatable {
    public let status: String?
    public let x: Double
    public let y: Double
    public let z: Double
    
    public init(status: String? = nil, x: Double, y: Double, z: Double) {
        self.status = status
        self.x = x
        self.y = y
        self.z = z
    }
    
    private enum CodingKeys: String, CodingKey {
        case status, x, y, z
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Status is optional
        self.status = try container.decodeIfPresent(String.self, forKey: .status)
        
        // Handle x, y, z which can be either Double, Int, Bool, or String
        func decodeCoordinate(key: CodingKeys) throws -> Double {
            // First try to decode as Double
            if let doubleValue = try? container.decode(Double.self, forKey: key) {
                return doubleValue
            }
            // Then try to decode as Int and convert to Double
            if let intValue = try? container.decode(Int.self, forKey: key) {
                return Double(intValue)
            }
            // Check if it's a Bool - both true and false map to 0.0 for off-track
            if let boolValue = try? container.decode(Bool.self, forKey: key) {
                // When car is off track, coordinates are often set to boolean values
                return 0.0
            }
            // Check if it's a String that might represent a number or special value
            if let stringValue = try? container.decode(String.self, forKey: key) {
                // Try to parse as Double
                if let doubleFromString = Double(stringValue) {
                    return doubleFromString
                }
                // Common string values that mean "no position"
                if stringValue.lowercased() == "false" || stringValue.lowercased() == "null" || stringValue.isEmpty {
                    return 0.0
                }
            }
            // If none of the above work, return 0.0 as a fallback
            // This is better than failing the entire decoding
            return 0.0
        }
        
        self.x = try decodeCoordinate(key: .x)
        self.y = try decodeCoordinate(key: .y)
        self.z = try decodeCoordinate(key: .z)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
        try container.encode(z, forKey: .z)
    }
}

/// Car telemetry data
public struct CarData: Sendable, Codable {
    public let entries: [CarDataEntry]
    
    public init(entries: [CarDataEntry]) {
        self.entries = entries
    }
}

/// Car data entry for a specific timestamp
public struct CarDataEntry: Sendable, Codable {
    public let utc: String
    public let cars: [String: CarDataChannels]
    
    public init(utc: String, cars: [String: CarDataChannels]) {
        self.utc = utc
        self.cars = cars
    }
}

/// Car telemetry channels
public struct CarDataChannels: Sendable, Codable {
    public let rpm: Int?
    public let speed: Int?
    public let gear: Int?
    public let throttle: Int?
    public let brake: Int?
    public let drs: Int?
    
    private enum CodingKeys: String, CodingKey {
        case rpm = "0"
        case speed = "2"
        case gear = "3"
        case throttle = "4"
        case brake = "5"
        case drs = "45"
    }
    
    public init(
        rpm: Int? = nil,
        speed: Int? = nil,
        gear: Int? = nil,
        throttle: Int? = nil,
        brake: Int? = nil,
        drs: Int? = nil
    ) {
        self.rpm = rpm
        self.speed = speed
        self.gear = gear
        self.throttle = throttle
        self.brake = brake
        self.drs = drs
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.rpm = try container.decodeIfPresent(Int.self, forKey: .rpm)
        self.speed = try container.decodeIfPresent(Int.self, forKey: .speed)
        self.gear = try container.decodeIfPresent(Int.self, forKey: .gear)
        self.throttle = try container.decodeIfPresent(Int.self, forKey: .throttle)
        self.brake = try container.decodeIfPresent(Int.self, forKey: .brake)
        self.drs = try container.decodeIfPresent(Int.self, forKey: .drs)
    }
}

/// Speed data across different measurement points
public struct Speeds: Sendable, Codable {
    public let i1: LapTimeValue
    public let i2: LapTimeValue
    public let fl: LapTimeValue
    public let st: LapTimeValue
    
    public init(
        i1: LapTimeValue,
        i2: LapTimeValue,
        fl: LapTimeValue,
        st: LapTimeValue
    ) {
        self.i1 = i1
        self.i2 = i2
        self.fl = fl
        self.st = st
    }
}
