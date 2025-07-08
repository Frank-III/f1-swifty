//
//  Color+Platform.swift
//  F1-Dash
//
//  Cross-platform color extensions
//

import SwiftUI

extension Color {
    /// Returns a platform-appropriate background color
    static var platformBackground: Color {
        #if os(macOS)
        return Color(nsColor: .controlBackgroundColor)
        #else
        return Color(uiColor: .systemBackground)
        #endif
    }
    
    /// Returns a platform-appropriate secondary background color
    static var platformSecondaryBackground: Color {
        #if os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return Color(uiColor: .secondarySystemBackground)
        #endif
    }
    
    /// Returns a platform-appropriate grouped background color
    static var platformGroupedBackground: Color {
        #if os(macOS)
        return Color(nsColor: .controlBackgroundColor)
        #else
        return Color(uiColor: .systemGroupedBackground)
        #endif
    }
    
    /// Returns background color based on OLED mode setting
    static func dynamicBackground(oledMode: Bool) -> Color {
        if oledMode {
            return Color.black
        }
        return platformBackground
    }
    
    /// Returns secondary background color based on OLED mode setting
    static func dynamicSecondaryBackground(oledMode: Bool) -> Color {
        if oledMode {
            return Color.black
        }
        return platformSecondaryBackground
    }
    
    /// Returns grouped background color based on OLED mode setting
    static func dynamicGroupedBackground(oledMode: Bool) -> Color {
        if oledMode {
            return Color.black
        }
        return platformGroupedBackground
    }
}