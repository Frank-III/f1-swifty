//
//  MapKitBackground.swift
//  F1-Dash
//
//  Real map background using MapKit
//

import SwiftUI
import MapKit
import F1DashModels

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct MapKitBackground: View {
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @Environment(\.colorScheme) var colorScheme
    #if os(iOS)
    @State private var mapSnapshot: UIImage?
    #elseif os(macOS)
    @State private var mapSnapshot: NSImage?
    #endif
    @State private var cameraPosition = MapCameraPosition.automatic
    
    // Track locations mapping
    private let trackLocations: [String: CLLocationCoordinate2D] = [
        "Bahrain": CLLocationCoordinate2D(latitude: 26.0325, longitude: 50.5106),
        "Saudi Arabia": CLLocationCoordinate2D(latitude: 21.6319, longitude: 39.1044),
        "Australia": CLLocationCoordinate2D(latitude: -37.8497, longitude: 144.9680),
        "Japan": CLLocationCoordinate2D(latitude: 34.8431, longitude: 136.5414),
        "China": CLLocationCoordinate2D(latitude: 31.3389, longitude: 121.2198),
        "Miami": CLLocationCoordinate2D(latitude: 25.9581, longitude: -80.2389),
        "United States": CLLocationCoordinate2D(latitude: 25.9581, longitude: -80.2389), // Miami
        "Italy": CLLocationCoordinate2D(latitude: 44.3439, longitude: 11.7134), // Imola
        "Monaco": CLLocationCoordinate2D(latitude: 43.7347, longitude: 7.4206),
        "Canada": CLLocationCoordinate2D(latitude: 45.5000, longitude: -73.5228),
        "Spain": CLLocationCoordinate2D(latitude: 41.5700, longitude: 2.2611),
        "Austria": CLLocationCoordinate2D(latitude: 47.2197, longitude: 14.7647),
        "Great Britain": CLLocationCoordinate2D(latitude: 52.0786, longitude: -1.0169),
        "United Kingdom": CLLocationCoordinate2D(latitude: 52.0786, longitude: -1.0169),
        "Hungary": CLLocationCoordinate2D(latitude: 47.5789, longitude: 19.2486),
        "Belgium": CLLocationCoordinate2D(latitude: 50.4372, longitude: 5.9714),
        "Netherlands": CLLocationCoordinate2D(latitude: 52.3888, longitude: 4.5409),
        "Monza": CLLocationCoordinate2D(latitude: 45.6156, longitude: 9.2811),
        "Singapore": CLLocationCoordinate2D(latitude: 1.2914, longitude: 103.8640),
        "Azerbaijan": CLLocationCoordinate2D(latitude: 40.3725, longitude: 49.8533),
        "USA": CLLocationCoordinate2D(latitude: 30.1327, longitude: -97.6411), // COTA
        "Mexico": CLLocationCoordinate2D(latitude: 19.4042, longitude: -99.0907),
        "Brazil": CLLocationCoordinate2D(latitude: -23.7036, longitude: -46.6997),
        "Las Vegas": CLLocationCoordinate2D(latitude: 36.1147, longitude: -115.1730),
        "Qatar": CLLocationCoordinate2D(latitude: 25.4900, longitude: 51.4542),
        "Abu Dhabi": CLLocationCoordinate2D(latitude: 24.4672, longitude: 54.6031),
        "UAE": CLLocationCoordinate2D(latitude: 24.4672, longitude: 54.6031)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark background base
                Color.black.opacity(0.8)
                
//                let _ = print("MapKitBackground: Country name: \(appEnvironment.liveSessionState.sessionInfo?.meeting?.country.name ?? "nil")")
//                let _ = print("MapKitBackground: Has snapshot: \(mapSnapshot != nil)")
                
                if let snapshot = mapSnapshot {
                    #if os(iOS)
                    Image(uiImage: snapshot)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .opacity(0.35) // More visible but still subtle
                        .clipped()
                    #elseif os(macOS)
                    Image(nsImage: snapshot)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .opacity(0.35) // More visible but still subtle
                        .clipped()
                    #endif
                } else if let countryName = appEnvironment.liveSessionState.sessionInfo?.meeting?.country.name {
                    let coordinate = findCoordinate(for: countryName)
                    
                    // Hidden MapKit view to generate snapshot
                    Map(position: .constant(.camera(
                        MapCamera(
                            centerCoordinate: coordinate,
                            distance: 15000, // 15km view distance
                            heading: 0,
                            pitch: 0
                        )
                    ))) {
                        // No markers needed for background
                    }
                    .mapStyle(colorScheme == .dark ? .standard : .standard)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .onAppear {
                        generateMapSnapshot(
                            for: coordinate,
                            size: geometry.size
                        )
                    }
                    .opacity(0.001) // Invisible but still renders
                }
                
                // Gradient overlay for better content readability
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.6),
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.6)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
        .onChange(of: appEnvironment.liveSessionState.sessionInfo?.meeting?.country.name) { oldValue, newValue in
            if newValue != nil  && oldValue != newValue {
                mapSnapshot = nil
                // Will regenerate on next appearance
            }
        }
    }
    
    private func findCoordinate(for countryName: String) -> CLLocationCoordinate2D {
        // Try exact match first
        if let coord = trackLocations[countryName] {
            return coord
        }
        
        // Try case-insensitive match
        let lowercasedCountry = countryName.lowercased()
        for (key, value) in trackLocations {
            if key.lowercased() == lowercasedCountry {
                return value
            }
        }
        
        // Try partial match
        for (key, value) in trackLocations {
            if countryName.contains(key) || key.contains(countryName) {
                return value
            }
        }
        
        // Default to Monaco if no match found
        print("MapKitBackground: No match found for '\(countryName)', using Monaco as default")
        return CLLocationCoordinate2D(latitude: 43.7347, longitude: 7.4206)
    }
    
    private func generateMapSnapshot(for coordinate: CLLocationCoordinate2D, size: CGSize) {
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 15000,
            longitudinalMeters: 15000
        )
        options.size = size
        
        #if os(iOS)
        options.scale = UIScreen.main.scale
        
        // Configure for dark/light mode on iOS
        if colorScheme == .dark {
            options.traitCollection = UITraitCollection(userInterfaceStyle: .dark)
            if #available(iOS 16.0, *) {
                options.preferredConfiguration = MKStandardMapConfiguration()
            }
        } else {
            options.traitCollection = UITraitCollection(userInterfaceStyle: .light)
        }
        #elseif os(macOS)
        // macOS configuration
        if #available(macOS 13.0, *) {
            options.preferredConfiguration = MKStandardMapConfiguration()
        }
        #endif
        
        let snapshotter = MKMapSnapshotter(options: options)
        
        snapshotter.start { snapshot, error in
            if let error = error {
                print("MapKitBackground: Error generating snapshot: \(error)")
            } else if let snapshot = snapshot {
                DispatchQueue.main.async {
                    self.mapSnapshot = snapshot.image
                    print("MapKitBackground: Snapshot generated successfully")
                }
            }
        }
    }
}
