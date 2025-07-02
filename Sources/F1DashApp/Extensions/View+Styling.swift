//
//  View+Styling.swift
//  F1-Dash
//
//  Common view styling extensions
//

import SwiftUI

extension View {
    /// Applies a standard card style with padding, background, and rounded corners
    func cardStyle(cornerRadius: CGFloat = 8, padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(Color.platformBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    /// Applies a secondary card style with lighter background
    func secondaryCardStyle(cornerRadius: CGFloat = 8, padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(Color.platformSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    /// Applies a subtle background with rounded corners
    func subtleBackground(cornerRadius: CGFloat = 8, opacity: Double = 0.1) -> some View {
        self
            .background(Color.gray.opacity(opacity))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    /// Applies platform-appropriate grouped background
    func groupedBackground(cornerRadius: CGFloat = 8) -> some View {
        self
            .background(Color.platformGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    /// Conditional modifier - only applies the modifier if the condition is true
    @ViewBuilder
    func conditionalModifier<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Platform-specific modifiers

extension View {
    /// Applies macOS-specific styling
    func macOSStyle() -> some View {
        #if os(macOS)
        return self
            .buttonStyle(.plain)
        #else
        return self
        #endif
    }
    
    /// Applies iOS-specific styling
    func iOSStyle() -> some View {
        #if os(iOS)
        return self
            .buttonStyle(.borderless)
        #else
        return self
        #endif
    }
}