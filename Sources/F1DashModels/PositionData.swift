import Foundation

/// Position data containing car coordinates on track
public struct PositionData: Sendable, Codable {
    public let position: [PositionItem]
    
    public init(position: [PositionItem]) {
        self.position = position
    }
}

/// Position data entry for a specific timestamp
public struct PositionItem: Sendable, Codable {
    public let timestamp: String
    public let entries: [String: PositionCar]
    
    public init(timestamp: String, entries: [String: PositionCar]) {
        self.timestamp = timestamp
        self.entries = entries
    }
}

/// Car position coordinates
public struct PositionCar: Sendable, Codable {
    public let status: String
    public let x: Double
    public let y: Double
    public let z: Double
    
    public init(status: String, x: Double, y: Double, z: Double) {
        self.status = status
        self.x = x
        self.y = y
        self.z = z
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
    public let rpm: Int
    public let speed: Int
    public let gear: Int
    public let throttle: Int
    public let brake: Int
    public let drs: Int
    
    private enum CodingKeys: String, CodingKey {
        case rpm = "0"
        case speed = "2"
        case gear = "3"
        case throttle = "4"
        case brake = "5"
        case drs = "45"
    }
    
    public init(
        rpm: Int,
        speed: Int,
        gear: Int,
        throttle: Int,
        brake: Int,
        drs: Int
    ) {
        self.rpm = rpm
        self.speed = speed
        self.gear = gear
        self.throttle = throttle
        self.brake = brake
        self.drs = drs
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