import Foundation

/// Weather information for the session
public struct WeatherData: Sendable, Codable {
    public let airTemp: String
    public let humidity: String
    public let pressure: String
    public let rainfall: String
    public let trackTemp: String
    public let windDirection: String
    public let windSpeed: String
    
    public init(
        airTemp: String,
        humidity: String,
        pressure: String,
        rainfall: String,
        trackTemp: String,
        windDirection: String,
        windSpeed: String
    ) {
        self.airTemp = airTemp
        self.humidity = humidity
        self.pressure = pressure
        self.rainfall = rainfall
        self.trackTemp = trackTemp
        self.windDirection = windDirection
        self.windSpeed = windSpeed
    }
    
    /// Air temperature as a double value
    public var airTemperature: Double? {
        Double(airTemp)
    }
    
    /// Track temperature as a double value
    public var trackTemperature: Double? {
        Double(trackTemp)
    }
    
    /// Humidity as a percentage
    public var humidityPercentage: Double? {
        Double(humidity)
    }
    
    /// Pressure as a double value
    public var pressureValue: Double? {
        Double(pressure)
    }
    
    /// Rainfall as a boolean (is it raining?)
    public var isRaining: Bool {
        rainfall != "0" && !rainfall.isEmpty
    }
    
    /// Wind speed as a double value
    public var windSpeedValue: Double? {
        Double(windSpeed)
    }
    
    /// Wind direction as a double value (degrees)
    public var windDirectionDegrees: Double? {
        Double(windDirection)
    }
}