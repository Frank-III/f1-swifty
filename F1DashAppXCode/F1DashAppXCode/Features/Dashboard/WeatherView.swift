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
        VStack(alignment: .leading, spacing: 8) {
            Label("Weather", systemImage: "cloud.sun")
                .font(.subheadline)
                .fontWeight(.medium)
            
            ScrollView(.horizontal, showsIndicators: false) {
                PlatformHStackContainer(spacing: 12) {
                    weatherContent
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(12)
        .background(Color.platformBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    @ViewBuilder
    private var weatherContent: some View {
        if let weather = weatherData {
          HStack {
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
          }
          .padding(.vertical, 6)
          .padding(.horizontal, 4)
        } else {
            ForEach(0..<5, id: \.self) { _ in
                EnhancedWeatherLoadingComplication()
            }
        }
    }
}

// MARK: - Custom Circular Gauge

struct CircularGaugeView: View {
    let value: Double
    let minValue: Double
    let maxValue: Double
    let gradient: Gradient
    let lineWidth: CGFloat = 6
    
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
        gaugeContent
            .platformGlassEffect()
    }
    
  #if os(macOS)
  @ViewBuilder
    private var gaugeContent: some View {
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
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                
                HStack(spacing: 8) {
                    Text("-20")
                        .font(.system(size: 8))
                        .foregroundStyle(.tertiary)
                    Text("60")
                        .font(.system(size: 8))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .frame(width: 50, height: 50)
    }
  #endif
    
    #if os(iOS) || os(iPadOS)
    @ViewBuilder
    private var gaugeContent: some View {
        Gauge(value: Double(value), in: -20...60) {
        Text("\(label)")
            .font(.footnote)
        } currentValueLabel: {
          Text("\(value)")
        }
      .foregroundStyle(temperatureGradient)
      .gaugeStyle(.accessoryCircular)
      .tint(temperatureGradient)
    }
    #endif
    
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
        gaugeContent
            .platformGlassEffect()
    }
    
  #if os(macOS)
  @ViewBuilder
    private var gaugeContent: some View {
        ZStack {
            CircularGaugeView(
                value: value,
                minValue: 0,
                maxValue: 100,
                gradient: Gradient(colors: [.blue.opacity(0.3), .blue])
            )
            
            VStack(spacing: 4) {
                Image(systemName: "humidity")
                    .font(.system(size: 14))
                    .foregroundStyle(.blue)
                
                Text("\(Int(value))%")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                
                Text("HUM")
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 50, height: 50)
    }
  #endif
  
  #if os(iOS) || os(iPadOS)
  @ViewBuilder
    private var gaugeContent: some View {
      
      Gauge(value: value, in: 0...100) {
        Image(systemName: "humidity")
            .font(.system(size: 14))
            .foregroundStyle(.blue)
      } currentValueLabel: {
        Text("\(Int(value))")
      }
      .gaugeStyle(.accessoryCircular)
      .tint(Gradient(colors: [.blue.opacity(0.3), .blue]))
    }
  #endif
}

struct RainComplication: View {
    let rain: Bool
    
    var body: some View {
        gaugeContent
            .platformGlassEffect()
    }
    
    @ViewBuilder
    private var gaugeContent: some View {
        ZStack {
            Circle()
                .stroke(rain ? Color.blue : Color.gray.opacity(0.3), lineWidth: 6)
                .animation(.easeInOut(duration: 0.3), value: rain)
            
            VStack(spacing: 4) {
                Image(systemName: rain ? "cloud.rain.fill" : "sun.max.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(rain ? .blue : .yellow)
                    .symbolEffect(.bounce, value: rain)
                
                Text(rain ? "WET" : "DRY")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(rain ? .blue : .primary)
            }
        }
        .frame(width: 50, height: 50)
    }
}

struct WindSpeedComplication: View {
    let speed: Double
    let directionDeg: Int
    
    var body: some View {
        gaugeContent
            .platformGlassEffect()
    }
    
    @ViewBuilder
    private var gaugeContent: some View {
        ZStack {
            CircularGaugeView(
                value: speed,
                minValue: 0,
                maxValue: 30,
                gradient: windSpeedGradient
            )
            
            VStack(spacing: 2) {
                Image(systemName: "wind")
                    .font(.system(size: 18))
                    .foregroundStyle(.tint)
                    .rotationEffect(.degrees(Double(directionDeg)))
                
                Text("\(Int(speed))")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                
                Text("m/s")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                
                Text(windDirection)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 50, height: 50)
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
                .scaleEffect(0.8)
                
                TemperatureComplication(
                    value: Int(round(weather.airTemperature ?? 0)),
                    label: "AIR"
                )
                .scaleEffect(0.8)
                
                RainComplication(
                    rain: weather.isRaining
                )
                .scaleEffect(0.8)
            } else {
                ForEach(0..<3, id: \.self) { _ in
                    EnhancedWeatherLoadingComplication()
                        .scaleEffect(0.8)
                }
            }
        }
    }
}

// MARK: - Compact Header Weather View

struct CompactHeaderWeatherView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    private var weatherData: WeatherData? {
        appEnvironment.liveSessionState.weatherData
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if let weather = weatherData {
                // Track temperature
                HStack(spacing: 4) {
                    Image(systemName: "thermometer")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Track")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                        Text("\(Int(round(weather.trackTemperature ?? 0)))°")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                
                // Air temperature
                HStack(spacing: 4) {
                    Image(systemName: "wind")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Air")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                        Text("\(Int(round(weather.airTemperature ?? 0)))°")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                
                // Rain status
                HStack(spacing: 4) {
                    Image(systemName: weather.isRaining ? "cloud.rain.fill" : "sun.max.fill")
                        .font(.caption)
                        .foregroundStyle(weather.isRaining ? .blue : .yellow)
                    Text(weather.isRaining ? "Wet" : "Dry")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(weather.isRaining ? .blue : .primary)
                }
                
                // Humidity
                if let humidity = weather.humidityPercentage {
                    HStack(spacing: 4) {
                        Image(systemName: "humidity")
                            .font(.caption)
                            .foregroundStyle(.cyan)
                        Text("\(Int(humidity))%")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
            } else {
                // Loading state
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { _ in
                        HStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 12, height: 12)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 20, height: 10)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.platformSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 6))
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
