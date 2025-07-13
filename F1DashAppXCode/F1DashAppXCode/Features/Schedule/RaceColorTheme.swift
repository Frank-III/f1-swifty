//
//  RaceColorTheme.swift
//  F1-Dash
//
//  Color themes for races based on country
//

import SwiftUI

struct RaceColorTheme {
    static let countryColors: [String: Color] = [
        "Austria": Color(red: 0.9, green: 0.2, blue: 0.2),          // Red (Austrian flag)
        "United Kingdom": Color(red: 0.0, green: 0.2, blue: 0.6),   // Navy Blue
        "Belgium": Color(red: 0.9, green: 0.7, blue: 0.0),          // Yellow (Belgian flag)
        "Hungary": Color(red: 0.0, green: 0.5, blue: 0.3),          // Green (Hungarian flag)
        "Netherlands": Color(red: 1.0, green: 0.5, blue: 0.0),      // Orange
        "Italy": Color(red: 0.0, green: 0.5, blue: 0.3),            // Italian Green
        "Azerbaijan": Color(red: 0.0, green: 0.7, blue: 0.8),       // Turquoise
        "Singapore": Color(red: 0.8, green: 0.0, blue: 0.4),        // Deep Pink
        "United States": Color(red: 0.2, green: 0.4, blue: 0.8),    // Blue
        "Mexico": Color(red: 0.0, green: 0.4, blue: 0.2),           // Mexican Green
        "Brazil": Color(red: 0.0, green: 0.6, blue: 0.2),           // Brazilian Green
        "Qatar": Color(red: 0.5, green: 0.0, blue: 0.3),            // Maroon
        "United Arab Emirates": Color(red: 0.7, green: 0.5, blue: 0.0) // Gold
    ]
    
    static func color(for countryName: String, isActive: Bool = false, isPast: Bool = false) -> Color {
        if isPast {
            return .gray
        }
        if isActive {
            return .green
        }
        return countryColors[countryName] ?? .blue
    }
    
    static func gradient(for countryName: String, isActive: Bool = false, isPast: Bool = false) -> LinearGradient {
        let baseColor = color(for: countryName, isActive: isActive, isPast: isPast)
        return LinearGradient(
            colors: [baseColor.opacity(0.8), baseColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}