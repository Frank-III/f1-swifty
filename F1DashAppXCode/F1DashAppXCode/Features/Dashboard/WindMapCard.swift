//
//  WindMapCard.swift
//  F1DashAppXCode
//
//  Compact wind map card with expandable weather overlay
//

import SwiftUI
import MapKit
import CoreLocation

#if canImport(WeatherKit)
import WeatherKit
#endif

struct WindMapCard: View {
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @State private var showFullMap = false
    @State private var mapRegion = MKCoordinateRegion()
    #if canImport(WeatherKit)
    @State private var weatherData: Weather?
    #endif
    @State private var isLoadingWeather = false
    
    private var sessionLocation: CLLocationCoordinate2D? {
        guard let sessionInfo = appEnvironment.liveSessionState.sessionInfo,
              let circuit = sessionInfo.meeting?.circuit else { return nil }
        
        // Get location from track data or use a default
        // For now, we'll use a placeholder - in real implementation, 
        // you'd get this from your track location data
        return getTrackLocation(for: circuit.shortName)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Compact card view
            ZStack(alignment: .topTrailing) {
                // Mini map preview
                Map(coordinateRegion: .constant(mapRegion))
                    .disabled(true)
                    #if canImport(WeatherKit)
                    .overlay(
                        // Wind overlay visualization
                        WindOverlayView(weatherData: weatherData)
                    )
                    #endif
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Expand button
                Button {
                    showFullMap = true
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(8)
            }
            .frame(height: 150)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .onAppear {
            setupMapRegion()
            loadWeatherData()
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $showFullMap) {
            ExpandedWeatherMapView(
                location: sessionLocation,
                circuitName: appEnvironment.liveSessionState.sessionInfo?.meeting?.name ?? "Circuit"
            )
        }
        #else
        .sheet(isPresented: $showFullMap) {
            ExpandedWeatherMapView(
                location: sessionLocation,
                circuitName: appEnvironment.liveSessionState.sessionInfo?.meeting?.name ?? "Circuit"
            )
            .frame(minWidth: 800, minHeight: 600)
        }
        #endif
    }
    
    private func setupMapRegion() {
        guard let location = sessionLocation else { return }
        
        mapRegion = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
    
    private func loadWeatherData() {
        #if canImport(WeatherKit)
        guard let location = sessionLocation else { return }
        
        Task {
            isLoadingWeather = true
            do {
                if #available(iOS 16.0, macOS 13.0, *) {
                    let weatherService = WeatherService()
                    weatherData = try await weatherService.weather(for: CLLocation(
                        latitude: location.latitude,
                        longitude: location.longitude
                    ))
                }
            } catch {
                print("Failed to load weather: \(error)")
            }
            isLoadingWeather = false
        }
        #endif
    }
    
    // Placeholder function - in real implementation, this would come from your data
    private func getTrackLocation(for shortName: String) -> CLLocationCoordinate2D {
        // Example coordinates for some tracks
        switch shortName {
        case "Silverstone":
            return CLLocationCoordinate2D(latitude: 52.0786, longitude: -1.0169)
        case "Monaco":
            return CLLocationCoordinate2D(latitude: 43.7347, longitude: 7.4206)
        case "Spa":
            return CLLocationCoordinate2D(latitude: 50.4372, longitude: 5.9714)
        default:
            // Default to Silverstone
            return CLLocationCoordinate2D(latitude: 52.0786, longitude: -1.0169)
        }
    }
}

// Wind overlay visualization
#if canImport(WeatherKit)
struct WindOverlayView: View {
    let weatherData: Weather?
    
    var body: some View {
        GeometryReader { geometry in
            if let weather = weatherData {
                // Simple wind direction indicator
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Label {
                                Text("\(Int(weather.currentWeather.wind.speed.value)) \(weather.currentWeather.wind.speed.unit.symbol)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            } icon: {
                                Image(systemName: "wind")
                                    .font(.caption)
                            }
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            
                            // Wind direction arrow
                            Image(systemName: "arrow.up")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .rotationEffect(.degrees(weather.currentWeather.wind.direction.value))
                                .padding(6)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .padding(8)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
        }
    }
}
#endif

// Expanded weather map view
struct ExpandedWeatherMapView: View {
    let location: CLLocationCoordinate2D?
    let circuitName: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedOverlay: WeatherOverlay = .wind
    @State private var mapRegion = MKCoordinateRegion()
    @State private var weatherData: Weather?
    @State private var forecastHour = 0
    @State private var isLoadingWeather = false
    @State private var weatherError: String?
    
    enum WeatherOverlay: String, CaseIterable {
        case wind = "Wind"
        case temperature = "Temperature"
        case precipitation = "Precipitation"
        
        var icon: String {
            switch self {
            case .wind: return "wind"
            case .temperature: return "thermometer"
            case .precipitation: return "cloud.rain"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Full screen map
            Map(coordinateRegion: $mapRegion)
                .ignoresSafeArea()
                .overlay(
                    weatherOverlayView
                )
            
            // Controls overlay
            VStack {
                // Top controls
                HStack {
                    // Weather type selector
                  if #available(iOS 26.0, macOS 26.0, *) {
                    GlassEffectContainer {
                      HStack(spacing: 0) {
                        ForEach(WeatherOverlay.allCases, id: \.self) { overlay in
                          Button {
                            selectedOverlay = overlay
                          } label: {
                            Label(overlay.rawValue, systemImage: overlay.icon)
                              .labelStyle(.iconOnly)
                              .font(.system(size: 18))
                              .foregroundStyle(selectedOverlay == overlay ? .white : .secondary)
                              .frame(width: 44, height: 44)
                              .background(
                                selectedOverlay == overlay ?
                                Color.blue : Color.clear
                              )
                          }
                        }
                      }
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                  } else {
                    // Fallback on earlier versions
                    HStack(spacing: 0) {
                      ForEach(WeatherOverlay.allCases, id: \.self) { overlay in
                        Button {
                          selectedOverlay = overlay
                        } label: {
                          Label(overlay.rawValue, systemImage: overlay.icon)
                            .labelStyle(.iconOnly)
                            .font(.system(size: 18))
                            .foregroundStyle(selectedOverlay == overlay ? .white : .secondary)
                            .frame(width: 44, height: 44)
                            .background(
                              selectedOverlay == overlay ?
                              Color.blue : Color.clear
                            )
                        }
                      }
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                  }
                  
                    Spacer()
                    
                    // Close button
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .platformGlassEffect()
                    }
                }
                .padding()
                
                Spacer()
                
                // Forecast timeline
                VStack(spacing: 12) {
                    // Circuit name
                    Text(circuitName)
                        .font(.headline)
                        .padding(.horizontal)
                    
                    // Timeline slider
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Now")
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("+\(forecastHour)h")
                                .font(.caption)
                                .fontWeight(.medium)
                                .monospacedDigit()
                            
                            Spacer()
                            
                            Text("+24h")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.secondary)
                        
                        Slider(value: Binding(
                            get: { Double(forecastHour) },
                            set: { forecastHour = Int($0) }
                        ), in: 0...24, step: 1)
                        .tint(.blue)
                    }
                    .padding(.horizontal)
                    
                    // Forecast details
                    if isLoadingWeather {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Text("Loading weather data...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    } else if let error = weatherError {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding()
                    } else if let weather = weatherData {
                        // Show current or forecast data based on slider
                        if forecastHour == 0 {
                            // Current weather
                            HStack(spacing: 20) {
                                WeatherDetailView(
                                    icon: "wind",
                                    value: "\(Int(weather.currentWeather.wind.speed.value))",
                                    unit: weather.currentWeather.wind.speed.unit.symbol
                                )
                                
                                WeatherDetailView(
                                    icon: "thermometer",
                                    value: "\(Int(weather.currentWeather.temperature.value))",
                                    unit: "°"
                                )
                                
                                WeatherDetailView(
                                    icon: "humidity",
                                    value: "\(Int(weather.currentWeather.humidity * 100))",
                                    unit: "%"
                                )
                                
                                if weather.currentWeather.pressure.value > 0 {
                                    WeatherDetailView(
                                        icon: "gauge",
                                        value: "\(Int(weather.currentWeather.pressure.value))",
                                        unit: weather.currentWeather.pressure.unit.symbol
                                    )
                                }
                            }
                            .padding(.horizontal)
                        } else if #available(iOS 16.0, macOS 13.0, *),
                                  let hourlyForecast = weather.hourlyForecast.forecast.dropFirst(forecastHour - 1).first {
                            // Hourly forecast data
                            HStack(spacing: 20) {
                                WeatherDetailView(
                                    icon: "wind",
                                    value: "\(Int(hourlyForecast.wind.speed.value))",
                                    unit: hourlyForecast.wind.speed.unit.symbol
                                )
                                
                                WeatherDetailView(
                                    icon: "thermometer",
                                    value: "\(Int(hourlyForecast.temperature.value))",
                                    unit: "°"
                                )
                                
                                WeatherDetailView(
                                    icon: "humidity",
                                    value: "\(Int(hourlyForecast.humidity * 100))",
                                    unit: "%"
                                )
                                
                                if hourlyForecast.precipitationChance > 0 {
                                    WeatherDetailView(
                                        icon: "cloud.rain",
                                        value: "\(Int(hourlyForecast.precipitationChance * 100))",
                                        unit: "%"
                                    )
                                }
                                
                                // Time label
                                VStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .font(.title3)
                                        .foregroundStyle(.indigo)
                                    
                                    Text(hourlyForecast.date, style: .time)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(minWidth: 60)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding()
            }
        }
        .onAppear {
            setupMapRegion()
            loadWeatherData()
        }
    }
    
    @ViewBuilder
    private var weatherOverlayView: some View {
        switch selectedOverlay {
        case .wind:
            WindMapOverlay(weatherData: weatherData)
        case .temperature:
            TemperatureMapOverlay(weatherData: weatherData)
        case .precipitation:
            PrecipitationMapOverlay(weatherData: weatherData)
        }
    }
    
    private func setupMapRegion() {
        guard let location = location else { return }
        
        mapRegion = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }
    
    private func loadWeatherData() {
        guard let location = location else { return }
        
        Task {
            isLoadingWeather = true
            weatherError = nil
            
            do {
                if #available(iOS 16.0, macOS 13.0, *) {
                    let weatherService = WeatherService()
                    let weather = try await weatherService.weather(
                        for: CLLocation(
                            latitude: location.latitude,
                            longitude: location.longitude
                        )
                    )
                    weatherData = weather
                }
            } catch {
                weatherError = "Unable to load weather data"
                print("Failed to load weather: \(error)")
            }
            
            isLoadingWeather = false
        }
    }
}

struct WeatherDetailView: View {
    let icon: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
            
            HStack(spacing: 2) {
                Text(value)
                    .font(.headline)
                    .monospacedDigit()
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(minWidth: 60)
    }
}

// Map overlay views
struct WindMapOverlay: View {
    let weatherData: Weather?
    
    var body: some View {
        GeometryReader { geometry in
            if let weather = weatherData,
               #available(iOS 16.0, macOS 13.0, *) {
                let wind = weather.currentWeather.wind
                
                // Wind visualization with direction and strength
                ZStack {
                    // Background gradient showing wind strength
                    LinearGradient(
                        colors: [
                            windStrengthColor(wind.speed).opacity(0.1),
                            windStrengthColor(wind.speed).opacity(0.3)
                        ],
                        startPoint: windGradientStart(for: wind.direction),
                        endPoint: windGradientEnd(for: wind.direction)
                    )
                    
                    // Wind direction arrows pattern
                    ForEach(0..<5, id: \.self) { row in
                        ForEach(0..<5, id: \.self) { col in
                            WindArrowView(
                                direction: wind.direction.value,
                                speed: wind.speed,
                                opacity: 0.3
                            )
                            .position(
                                x: geometry.size.width * CGFloat(col + 1) / 6,
                                y: geometry.size.height * CGFloat(row + 1) / 6
                            )
                        }
                    }
                    
                    // Central wind info
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                HStack(spacing: 4) {
                                    Image(systemName: "wind")
                                        .font(.caption2)
                                    Text("\(Int(wind.speed.value)) \(wind.speed.unit.symbol)")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                
                                if let gust = wind.gust {
                                    Text("Gusts: \(Int(gust.value)) \(gust.unit.symbol)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                
                                HStack(spacing: 2) {
                                    Image(systemName: "arrow.up")
                                        .font(.caption2)
                                        .rotationEffect(.degrees(wind.direction.value))
                                    Text("\(Int(wind.direction.value))°")
                                        .font(.caption2)
                                }
                            }
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding()
                    }
                }
            } else {
                // Placeholder when no weather data
                Color.gray.opacity(0.1)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func windStrengthColor(_ speed: Measurement<UnitSpeed>) -> Color {
        let kmh = speed.converted(to: .kilometersPerHour).value
        switch kmh {
        case 0..<10: return .blue
        case 10..<20: return .green
        case 20..<30: return .yellow
        case 30..<40: return .orange
        default: return .red
        }
    }
    
    private func windGradientStart(for direction: Measurement<UnitAngle>) -> UnitPoint {
        let radians = direction.converted(to: .radians).value
        let x = 0.5 + 0.5 * sin(radians)
        let y = 0.5 - 0.5 * cos(radians)
        return UnitPoint(x: x, y: y)
    }
    
    private func windGradientEnd(for direction: Measurement<UnitAngle>) -> UnitPoint {
        let radians = direction.converted(to: .radians).value + .pi
        let x = 0.5 + 0.5 * sin(radians)
        let y = 0.5 - 0.5 * cos(radians)
        return UnitPoint(x: x, y: y)
    }
}

struct WindArrowView: View {
    let direction: Double
    let speed: Measurement<UnitSpeed>
    let opacity: Double
    
    var body: some View {
        Image(systemName: "arrow.up")
            .font(.system(size: 12 + speedScale * 8))
            .fontWeight(.medium)
            .foregroundStyle(windColor)
            .rotationEffect(.degrees(direction))
            .opacity(opacity)
    }
    
    private var speedScale: Double {
        let kmh = speed.converted(to: .kilometersPerHour).value
        return min(kmh / 50, 1.0)
    }
    
    private var windColor: Color {
        let kmh = speed.converted(to: .kilometersPerHour).value
        switch kmh {
        case 0..<10: return .blue
        case 10..<20: return .green
        case 20..<30: return .yellow
        case 30..<40: return .orange
        default: return .red
        }
    }
}

struct TemperatureMapOverlay: View {
    let weatherData: Weather?
    
    var body: some View {
        GeometryReader { geometry in
            if let weather = weatherData,
               #available(iOS 16.0, macOS 13.0, *) {
                let temp = weather.currentWeather.temperature
                let feelsLike = weather.currentWeather.apparentTemperature
                
                ZStack {
                    // Temperature gradient based on actual temperature
                    RadialGradient(
                        colors: [
                            temperatureColor(temp).opacity(0.4),
                            temperatureColor(temp).opacity(0.2),
                            temperatureColor(temp).opacity(0.05)
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: geometry.size.width / 2
                    )
                    
                    // Temperature zones visualization
                    ForEach(0..<3, id: \.self) { ring in
                        Circle()
                            .stroke(
                                temperatureColor(temp).opacity(0.2 - Double(ring) * 0.05),
                                lineWidth: 2
                            )
                            .scaleEffect(0.4 + Double(ring) * 0.3)
                    }
                    
                    // Temperature info display
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                // Main temperature
                                HStack(alignment: .top, spacing: 2) {
                                    Image(systemName: "thermometer")
                                        .font(.title3)
                                        .foregroundStyle(temperatureColor(temp))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(Int(temp.value))°\(temperatureUnit(temp))")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        Text("Feels like \(Int(feelsLike.value))°")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                // Additional weather info
                                if weather.currentWeather.humidity > 0 {
                                    HStack(spacing: 4) {
                                        Image(systemName: "humidity")
                                            .font(.caption2)
                                        Text("\(Int(weather.currentWeather.humidity * 100))%")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.secondary)
                                }
                                
                                if weather.currentWeather.dewPoint.value != 0 {
                                    HStack(spacing: 4) {
                                        Image(systemName: "drop")
                                            .font(.caption2)
                                        Text("Dew: \(Int(weather.currentWeather.dewPoint.value))°")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.secondary)
                                }
                            }
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            Spacer()
                        }
                        .padding()
                    }
                }
            } else {
                // Placeholder when no weather data
                Color.gray.opacity(0.1)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func temperatureColor(_ temp: Measurement<UnitTemperature>) -> Color {
        let celsius = temp.converted(to: .celsius).value
        switch celsius {
        case ..<0: return .purple
        case 0..<10: return .blue
        case 10..<20: return .green
        case 20..<25: return .yellow
        case 25..<30: return .orange
        default: return .red
        }
    }
    
    private func temperatureUnit(_ temp: Measurement<UnitTemperature>) -> String {
        if temp.unit == .celsius {
            return "C"
        } else if temp.unit == .fahrenheit {
            return "F"
        } else {
            return "K"
        }
    }
}

struct PrecipitationMapOverlay: View {
    let weatherData: Weather?
    
    var body: some View {
        GeometryReader { geometry in
            if let weather = weatherData,
               #available(iOS 16.0, macOS 13.0, *) {
                let current = weather.currentWeather
                
                ZStack {
                    // Precipitation visualization
                    if #available(iOS 16.0, macOS 13.0, *),
                       current.precipitationIntensity.value > 0 {
                        let intensity = current.precipitationIntensity.value
                        let precipType = precipitationType(from: current.condition)
                        
                        // Rain/snow effect based on intensity
                        ForEach(0..<20, id: \.self) { index in
                            PrecipitationDropView(
                                type: precipType,
                                intensity: intensity,
                                index: index,
                                size: geometry.size
                            )
                        }
                        
                        // Background overlay showing precipitation density
                        LinearGradient(
                            colors: [
                                precipitationColor(precipType).opacity(precipitationOpacity(intensity)),
                                precipitationColor(precipType).opacity(precipitationOpacity(intensity) * 0.5)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    
                    // Precipitation info display
                    VStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                // Precipitation type and intensity
                                HStack(spacing: 6) {
                                    let precipType = precipitationType(from: current.condition)
                                    
                                    Image(systemName: precipitationIcon(precipType))
                                        .font(.title3)
                                        .foregroundStyle(precipitationColor(precipType))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(precipitationDescription(precipType))
                                            .font(.headline)
                                        
                                        if #available(iOS 16.0, macOS 13.0, *),
                                           current.precipitationIntensity.value > 0 {
                                            Text("\(String(format: "%.1f", current.precipitationIntensity.value)) \(current.precipitationIntensity.unit.symbol)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        } else {
                                            Text("No precipitation")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                
                                // Cloud cover
                                if current.cloudCover > 0 {
                                    HStack(spacing: 4) {
                                        Image(systemName: "cloud")
                                            .font(.caption2)
                                        Text("\(Int(current.cloudCover * 100))% coverage")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.secondary)
                                }
                                
                                // Visibility
                                HStack(spacing: 4) {
                                    Image(systemName: "eye")
                                        .font(.caption2)
                                    Text("Visibility: \(Int(current.visibility.value)) \(current.visibility.unit.symbol)")
                                        .font(.caption)
                                }
                                .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            Spacer()
                        }
                        .padding()
                        
                        Spacer()
                    }
                }
            } else {
                // Placeholder when no weather data
                Color.gray.opacity(0.1)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func precipitationIcon(_ type: Precipitation) -> String {
        switch type {
        case .none: return "sun.max"
        case .rain: return "cloud.rain"
        case .snow: return "cloud.snow"
        case .sleet: return "cloud.sleet"
        case .hail: return "cloud.hail"
        default: return "cloud"
        }
    }
    
    private func precipitationColor(_ type: Precipitation) -> Color {
        switch type {
        case .none: return .gray
        case .rain: return .blue
        case .snow: return .cyan
        case .sleet: return .indigo
        case .hail: return .purple
        default: return .gray
        }
    }
    
    private func precipitationDescription(_ type: Precipitation) -> String {
        switch type {
        case .none: return "Clear"
        case .rain: return "Rain"
        case .snow: return "Snow"
        case .sleet: return "Sleet"
        case .hail: return "Hail"
        default: return "Mixed"
        }
    }
    
    private func precipitationOpacity(_ intensity: Double) -> Double {
        // Map intensity to opacity (0-50mm/hr to 0.1-0.5 opacity)
        return min(0.1 + (intensity / 50) * 0.4, 0.5)
    }
    
    private func precipitationType(from condition: WeatherCondition) -> Precipitation {
        switch condition {
        case .blizzard, .blowingSnow, .flurries, .heavySnow, .snow, .wintryMix:
            return .snow
        case .hail:
            return .hail
        case .sleet, .freezingDrizzle, .freezingRain:
            return .sleet
        case .drizzle, .heavyRain, .rain, .sunShowers, .thunderstorms, .isolatedThunderstorms, .scatteredThunderstorms, .strongStorms:
            return .rain
        default:
            return .none
        }
    }
}

struct PrecipitationDropView: View {
    let type: Precipitation
    let intensity: Double
    let index: Int
    let size: CGSize
    
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        Group {
            switch type {
            case .rain:
                RainDropShape()
                    .fill(Color.blue.opacity(0.6))
                    .frame(width: 3, height: 15)
            case .snow:
                Image(systemName: "snowflake")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            default:
                Circle()
                    .fill(Color.cyan.opacity(0.6))
                    .frame(width: 5, height: 5)
            }
        }
        .position(
            x: CGFloat.random(in: 0...size.width),
            y: yOffset
        )
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        let duration = Double.random(in: 2...4) / (1 + intensity / 10)
        let delay = Double(index) * 0.1
        
        withAnimation(
            .linear(duration: duration)
            .repeatForever(autoreverses: false)
            .delay(delay)
        ) {
            yOffset = size.height + 50
        }
    }
}

struct RainDropShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addQuadCurve(
                to: CGPoint(x: rect.midX, y: rect.maxY),
                control: CGPoint(x: rect.minX, y: rect.maxY * 0.8)
            )
            path.addQuadCurve(
                to: CGPoint(x: rect.midX, y: rect.minY),
                control: CGPoint(x: rect.maxX, y: rect.maxY * 0.8)
            )
        }
    }
}

#Preview {
    WindMapCard()
        .frame(height: 150)
        .padding()
        .environment(OptimizedAppEnvironment())
}
