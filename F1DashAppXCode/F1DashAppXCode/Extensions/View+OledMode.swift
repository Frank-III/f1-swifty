//
//  View+OledMode.swift
//  F1-Dash
//
//  OLED Mode support for views
//

import SwiftUI

// MARK: - OLED Background Modifier

struct OledBackgroundModifier: ViewModifier {
    @Environment(AppEnvironment.self) private var appEnvironment
    let defaultColor: Color
    
    func body(content: Content) -> some View {
        content
            .background(appEnvironment.settingsStore.oledMode ? Color.black : defaultColor)
    }
}

// MARK: - View Extensions

extension View {
    /// Applies a dynamic background that respects OLED mode
    func dynamicBackground(_ defaultColor: Color = Color.platformBackground) -> some View {
        self.modifier(OledBackgroundModifier(defaultColor: defaultColor))
    }
    
    /// Replaces standard background calls with OLED-aware backgrounds
    func oledAwareBackground() -> some View {
        self.modifier(OledBackgroundModifier(defaultColor: Color.platformBackground))
    }
    
    /// Applies secondary background with OLED mode support
    func oledAwareSecondaryBackground() -> some View {
        self.modifier(OledBackgroundModifier(defaultColor: Color.platformSecondaryBackground))
    }
}