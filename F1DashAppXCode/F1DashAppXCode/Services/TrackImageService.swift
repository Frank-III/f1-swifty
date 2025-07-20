//
//  TrackImageService.swift
//  F1-Dash
//
//  Service for fetching track images
//

import SwiftUI
import Observation

@MainActor
@Observable
final class TrackImageService {
    static let shared = TrackImageService()
    
    private(set) var trackImages: [String: Image] = [:]
    private var loadingTasks: [String: Task<Void, Never>] = [:]
    
    // Track image URLs - using public F1 track map images
    private let trackImageURLs: [String: String] = [
        "Austria": "https://www.formula1.com/content/dam/fom-website/2018-redesign-assets/Track%20icons%204x3/Austria.png",
        "United Kingdom": "https://www.formula1.com/content/dam/fom-website/2018-redesign-assets/Track%20icons%204x3/Great%20Britain.png",
        "Belgium": "https://www.formula1.com/content/dam/fom-website/2018-redesign-assets/Track%20icons%204x3/Belgium.png",
        "Hungary": "https://www.formula1.com/content/dam/fom-website/2018-redesign-assets/Track%20icons%204x3/Hungary.png",
        "Netherlands": "https://www.formula1.com/content/dam/fom-website/2018-redesign-assets/Track%20icons%204x3/Netherlands.png",
        "Italy": "https://www.formula1.com/content/dam/fom-website/2018-redesign-assets/Track%20icons%204x3/Italy.png",
        "Azerbaijan": "https://www.formula1.com/content/dam/fom-website/2018-redesign-assets/Track%20icons%204x3/Azerbaijan.png",
        "Singapore": "https://www.formula1.com/content/dam/fom-website/2018-redesign-assets/Track%20icons%204x3/Singapore.png",
        "United States": "https://www.formula1.com/content/dam/fom-website/2018-redesign-assets/Track%20icons%204x3/USA.png",
        "Mexico": "https://www.formula1.com/content/dam/fom-website/2018-redesign-assets/Track%20icons%204x3/Mexico.png",
        "Brazil": "https://www.formula1.com/content/dam/fom-website/2018-redesign-assets/Track%20icons%204x3/Brazil.png",
        "Qatar": "https://www.formula1.com/content/dam/fom-website/2018-redesign-assets/Track%20icons%204x3/Qatar.png",
        "United Arab Emirates": "https://www.formula1.com/content/dam/fom-website/2018-redesign-assets/Track%20icons%204x3/Abu%20Dhabi.png"
    ]
    
    private init() {}
    
    func loadTrackImage(for countryName: String) {
        // Check if already loaded or loading
        guard trackImages[countryName] == nil,
              loadingTasks[countryName] == nil,
              let urlString = trackImageURLs[countryName],
              let url = URL(string: urlString) else { return }
        
        // Start loading task
        let task = Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                #if os(iOS) || os(tvOS) || os(watchOS)
                if let uiImage = UIImage(data: data) {
                    self.trackImages[countryName] = Image(uiImage: uiImage)
                }
                #elseif os(macOS)
                if let nsImage = NSImage(data: data) {
                    self.trackImages[countryName] = Image(nsImage: nsImage)
                }
                #endif
            } catch {
                print("Failed to load track image for \(countryName): \(error)")
            }
            
            // Clean up task reference
            self.loadingTasks.removeValue(forKey: countryName)
        }
        
        loadingTasks[countryName] = task
    }
    
    func trackImage(for countryName: String) -> Image? {
        // Try to load if not available
        if trackImages[countryName] == nil {
            loadTrackImage(for: countryName)
        }
        return trackImages[countryName]
    }
    
    // Generate a placeholder gradient based on country
    func placeholderGradient(for countryName: String) -> LinearGradient {
        let colors: [Color] = switch countryName {
        case "Austria": [Color(hex: "#DC0000") ?? .red, .white]
        case "United Kingdom": [Color(hex: "#012169") ?? .blue, .white, Color(hex: "#C8102E") ?? .red]
        case "Belgium": [.black, Color(hex: "#FDDA24") ?? .yellow, Color(hex: "#EF3340") ?? .red]
        case "Hungary": [Color(hex: "#CE2939") ?? .red, .white, Color(hex: "#477050") ?? .green]
        case "Netherlands": [Color(hex: "#AE1C28") ?? .red, .white, Color(hex: "#21468B") ?? .blue]
        case "Italy": [Color(hex: "#009246") ?? .green, .white, Color(hex: "#CE2B37") ?? .red]
        case "Azerbaijan": [Color(hex: "#0092BC") ?? .blue, Color(hex: "#E4002B") ?? .red, Color(hex: "#00AF66") ?? .green]
        case "Singapore": [Color(hex: "#EF3340") ?? .red, .white]
        case "United States": [Color(hex: "#0A3161") ?? .blue, .white, Color(hex: "#B31942") ?? .red]
        case "Mexico": [Color(hex: "#006341") ?? .green, .white, Color(hex: "#CE1126") ?? .red]
        case "Brazil": [Color(hex: "#009C3B") ?? .green, Color(hex: "#FFDF00") ?? .yellow, Color(hex: "#002776") ?? .blue]
        case "Qatar": [Color(hex: "#8D1B3D") ?? .purple, .white]
        case "United Arab Emirates": [Color(hex: "#FF0000") ?? .red, Color(hex: "#00732F") ?? .green, .white, .black]
        default: [
            // Default F1-inspired gradient
            Color(hex: "#E10600") ?? .red,  // F1 Red
            Color(hex: "#1E1E1E") ?? .black, // Dark gray
            Color(hex: "#FFFFFF") ?? .white  // White
        ]
        }
        
        return LinearGradient(
            colors: colors.map { $0.opacity(0.8) }, // Soften colors for background
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}