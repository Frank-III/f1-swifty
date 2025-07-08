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
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    if let weather = weatherData {
                        TemperatureComplication(
                            value: Int(round(weather.trackTemperature ?? 0)),
                            label: "TRACK"
                        )
                        
                        TemperatureComplication(
                            value: Int(round(weather.airTemperature ?? 0)),
                            label: "AIR"
                        )
                        
                        HumidityComplication(
                            value: weather.humidityPercentage ?? 0
                        )
                        
                        RainComplication(
                            rain: weather.isRaining
                        )
                        
                        WindSpeedComplication(
                            speed: weather.windSpeedValue ?? 0,
                            directionDeg: Int(weather.windDirectionDegrees ?? 0)
                        )
                    } else {
                        ForEach(0..<5, id: \.self) { _ in
                            LoadingComplication()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color.platformBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Custom Circular Gauge

struct CircularGaugeView: View {
    let value: Double
    let minValue: Double
    let maxValue: Double
    let gradient: Gradient
    let lineWidth: CGFloat = 8
    
    private var progress: Double {
        (value - minValue) / (maxValue - minValue)
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(gradient: gradient, center: .center),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
    }
}

// MARK: - Weather Complications

struct TemperatureComplication: View {
    let value: Int
    let label: String
    
    var body: some View {
        ZStack {
            CircularGaugeView(
                value: Double(value),
                minValue: -20,
                maxValue: 60,
                gradient: temperatureGradient
            )
            
            VStack(spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Text("\(value)°")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                
                HStack(spacing: 12) {
                    Text("-20")
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                    Text("60")
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .frame(width: 100, height: 100)
    }
    
    private var temperatureGradient: Gradient {
        Gradient(stops: [
            .init(color: .blue, location: 0.0),
            .init(color: .cyan, location: 0.25),
            .init(color: .green, location: 0.5),
            .init(color: .yellow, location: 0.65),
            .init(color: .orange, location: 0.8),
            .init(color: .red, location: 1.0)
        ])
    }
}

struct HumidityComplication: View {
    let value: Double
    
    var body: some View {
        ZStack {
            CircularGaugeView(
                value: value,
                minValue: 0,
                maxValue: 100,
                gradient: Gradient(colors: [.blue.opacity(0.3), .blue])
            )
            
            VStack(spacing: 4) {
                Image(systemName: "humidity")
                    .font(.system(size: 16))
                    .foregroundStyle(.blue)
                
                Text("\(Int(value))%")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                
                Text("HUM")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 100, height: 100)
    }
}

struct RainComplication: View {
    let rain: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(rain ? Color.blue : Color.gray.opacity(0.3), lineWidth: 8)
                .animation(.easeInOut(duration: 0.3), value: rain)
            
            VStack(spacing: 4) {
                Image(systemName: rain ? "cloud.rain.fill" : "sun.max.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(rain ? .blue : .yellow)
                    .symbolEffect(.bounce, value: rain)
                
                Text(rain ? "WET" : "DRY")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(rain ? .blue : .primary)
            }
        }
        .frame(width: 100, height: 100)
    }
}

struct WindSpeedComplication: View {
    let speed: Double
    let directionDeg: Int
    
    var body: some View {
        ZStack {
            CircularGaugeView(
                value: speed,
                minValue: 0,
                maxValue: 30,
                gradient: windSpeedGradient
            )
            
            VStack(spacing: 2) {
                Image(systemName: "wind")
                    .font(.system(size: 20))
                    .foregroundStyle(.tint)
                    .rotationEffect(.degrees(Double(directionDeg)))
                
                Text("\(Int(speed))")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                
                Text("m/s")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                
                Text(windDirection)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 100, height: 100)
    }
    
    private var windSpeedGradient: Gradient {
        Gradient(colors: [.green, .yellow, .orange, .red])
    }
    
    private var windDirection: String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((Double(directionDeg) + 22.5) / 45) % 8
        return directions[index]
    }
}

struct LoadingComplication: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .strokeBorder(Color.gray.opacity(0.3), lineWidth: 8)
            .background(Circle().fill(Color.gray.opacity(0.1)))
            .frame(width: 100, height: 100)
            .opacity(isAnimating ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Compact Weather View

struct CompactWeatherView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    private var weatherData: WeatherData? {
        appEnvironment.liveSessionState.weatherData
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let weather = weatherData {
                TemperatureComplication(
                    value: Int(round(weather.trackTemperature ?? 0)),
                    label: "TRACK"
                )
                .scaleEffect(0.6)
                
                TemperatureComplication(
                    value: Int(round(weather.airTemperature ?? 0)),
                    label: "AIR"
                )
                .scaleEffect(0.6)
                
                RainComplication(
                    rain: weather.isRaining
                )
                .scaleEffect(0.6)
            } else {
                ForEach(0..<3, id: \.self) { _ in
                    LoadingComplication()
                        .scaleEffect(0.6)
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
