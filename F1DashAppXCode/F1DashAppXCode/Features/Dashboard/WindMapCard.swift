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
                        .platformGlassEffect()
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
                    .platformGlassEffect()
                    
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
                    if let weather = weatherData {
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
                        }
                        .padding(.horizontal)
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
        // This would show wind patterns - simplified for example
        Color.blue.opacity(0.1)
            .allowsHitTesting(false)
    }
}

struct TemperatureMapOverlay: View {
    let weatherData: Weather?
    
    var body: some View {
        // This would show temperature gradient - simplified for example
        LinearGradient(
            colors: [.blue.opacity(0.1), .red.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .allowsHitTesting(false)
    }
}

struct PrecipitationMapOverlay: View {
    let weatherData: Weather?
    
    var body: some View {
        // This would show precipitation data - simplified for example
        Color.cyan.opacity(0.1)
            .allowsHitTesting(false)
    }
}

#Preview {
    WindMapCard()
        .frame(height: 150)
        .padding()
        .environment(OptimizedAppEnvironment())
}