//
//  WeatherView.swift
//  F1-Dash
//
//  Displays current weather conditions at the track
//

import SwiftUI
import F1DashModels

struct WeatherView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    private var weatherData: WeatherData? {
        appEnvironment.liveSessionState.weatherData
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Weather", systemImage: "cloud.sun")
                .font(.headline)
            
            if let weather = weatherData {
                HStack(spacing: 20) {
                    // Temperature
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "thermometer")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("Air")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text("\(weather.airTemp)°C")
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    
                    // Track Temperature
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "road.lanes")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("Track")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text("\(weather.trackTemp)°C")
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    // Wind
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "wind")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("Wind")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text("\(weather.windSpeed) m/s")
                            .font(.caption)
                        Text("\(weather.windDirection)°")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                
                // Additional conditions
                HStack(spacing: 16) {
                    // Humidity
                    Label("\(weather.humidity)%", systemImage: "humidity")
                        .font(.caption)
                    
                    // Pressure
                    Label("\(weather.pressure) mbar", systemImage: "gauge")
                        .font(.caption)
                    
                    Spacer()
                    
                    // Rain risk
                    if let rainfallValue = Double(weather.rainfall), rainfallValue > 0 {
                        Label("\(weather.rainfall) mm", systemImage: "cloud.rain")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            } else {
                ContentUnavailableView(
                    "No Weather Data",
                    systemImage: "cloud.sun",
                    description: Text("Weather information will appear here during a session")
                )
                .frame(height: 100)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Compact Weather View

struct CompactWeatherView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    private var weatherData: WeatherData? {
        appEnvironment.liveSessionState.weatherData
    }
    
    var body: some View {
        if let weather = weatherData {
            HStack(spacing: 12) {
                // Temperature
                Label("\(weather.airTemp)°", systemImage: "thermometer")
                    .font(.caption)
                
                // Track temp
                Label("\(weather.trackTemp)°", systemImage: "road.lanes")
                    .font(.caption)
                
                // Rain indicator
                if let rainfallValue = Double(weather.rainfall), rainfallValue > 0 {
                    Image(systemName: "cloud.rain.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
        }
    }
}

#Preview("Full Weather View") {
    WeatherView()
        .environment(AppEnvironment())
        .frame(width: 350)
        .padding()
}

#Preview("Compact Weather View") {
    CompactWeatherView()
        .environment(AppEnvironment())
        .padding()
}
