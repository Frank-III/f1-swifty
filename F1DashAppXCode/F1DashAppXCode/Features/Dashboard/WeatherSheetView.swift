//
//  WeatherSheetView.swift
//  F1-Dash
//
//  Weather information displayed as a sheet
//

import SwiftUI
import F1DashModels

struct WeatherSheetView: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @Environment(\.dismiss) private var dismiss
    
    private var weatherData: WeatherData? {
        appEnvironment.liveSessionState.weatherData
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let weather = weatherData {
                        // Current conditions header
                        VStack(spacing: 16) {
                            Image(systemName: weatherIcon(for: weather))
                                .font(.system(size: 60))
                                .foregroundStyle(.blue)
                            
                            Text("Current Conditions")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(.top)
                        
                        // Temperature cards
                        HStack(spacing: 16) {
                            TemperatureCard(
                                title: "Air Temperature",
                                value: "\(weather.airTemp)°C",
                                icon: "thermometer",
                                color: .blue
                            )
                            
                            TemperatureCard(
                                title: "Track Temperature", 
                                value: "\(weather.trackTemp)°C",
                                icon: "road.lanes",
                                color: .orange
                            )
                        }
                        .padding(.horizontal)
                        
                        // Wind information
                        WindCard(speed: weather.windSpeed, direction: weather.windDirection)
                            .padding(.horizontal)
                        
                        // Other conditions grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ConditionCard(
                                title: "Humidity",
                                value: "\(weather.humidity)%",
                                icon: "humidity",
                                color: .cyan
                            )
                            
                            ConditionCard(
                                title: "Pressure",
                                value: "\(weather.pressure) mbar",
                                icon: "gauge",
                                color: .purple
                            )
                            
                            if let rainfallValue = Double(weather.rainfall), rainfallValue > 0 {
                                ConditionCard(
                                    title: "Rainfall",
                                    value: "\(weather.rainfall) mm",
                                    icon: "cloud.rain.fill",
                                    color: .blue
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Track condition insights
                        TrackConditionInsights(weather: weather)
                            .padding(.horizontal)
                            .padding(.top)
                        
                    } else {
                        ContentUnavailableView(
                            "No Weather Data",
                            systemImage: "cloud.sun",
                            description: Text("Weather information will be available during a live session")
                        )
                        .frame(minHeight: 400)
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("Track Weather")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .platformNavigationGlass()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func weatherIcon(for weather: WeatherData) -> String {
        if let rainfallValue = Double(weather.rainfall), rainfallValue > 0 {
            return "cloud.rain.fill"
        } else if let temp = Double(weather.airTemp), temp > 30 {
            return "sun.max.fill"
        } else if let temp = Double(weather.airTemp), temp < 15 {
            return "cloud.fill"
        } else {
            return "cloud.sun.fill"
        }
    }
}

// MARK: - Temperature Card

struct TemperatureCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .modifier(PlatformGlassCardModifier())
    }
}

// MARK: - Wind Card

struct WindCard: View {
    let speed: String
    let direction: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "wind")
                    .font(.title2)
                    .foregroundStyle(.teal)
                
                Text("Wind")
                    .font(.headline)
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Speed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(speed) m/s")
                        .font(.title3)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Direction")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: "location.north.fill")
                            .rotationEffect(.degrees(Double(direction) ?? 0))
                        Text("\(direction)°")
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding()
        .background(Color.teal.opacity(0.1))
        .modifier(PlatformGlassCardModifier())
    }
}

// MARK: - Condition Card

struct ConditionCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(color.opacity(0.1))
        .modifier(PlatformGlassCardModifier())
    }
}

// MARK: - Track Condition Insights

struct TrackConditionInsights: View {
    let weather: WeatherData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb")
                    .foregroundStyle(.yellow)
                Text("Track Insights")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Track temperature difference
                if let trackTemp = Int(weather.trackTemp),
                   let airTemp = Int(weather.airTemp) {
                    let tempDiff = trackTemp - airTemp
                    if tempDiff > 10 {
                        InsightRow(
                            icon: "exclamationmark.triangle",
                            text: "Track is significantly hotter than air (+\(tempDiff)°C)",
                            color: .orange
                        )
                    }
                }
                
                // Rain conditions
                if let rainfallValue = Double(weather.rainfall), rainfallValue > 0 {
                    InsightRow(
                        icon: "umbrella.fill",
                        text: "Wet conditions - \(weather.rainfall)mm of rainfall",
                        color: .blue
                    )
                }
                
                // Wind conditions
                if let windSpeed = Double(weather.windSpeed), windSpeed > 5 {
                    InsightRow(
                        icon: "wind",
                        text: "Strong winds may affect car stability",
                        color: .teal
                    )
                }
                
                // Temperature conditions
                if let trackTemp = Int(weather.trackTemp), trackTemp > 40 {
                    InsightRow(
                        icon: "thermometer.sun",
                        text: "Very hot track may increase tire degradation",
                        color: .red
                    )
                }
            }
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .modifier(PlatformGlassCardModifier())
    }
}

// MARK: - Insight Row

struct InsightRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            
            Text(text)
                .font(.caption)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    WeatherSheetView()
        .environment(AppEnvironment())
}
