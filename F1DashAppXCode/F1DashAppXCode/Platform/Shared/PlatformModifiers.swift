//
//  PlatformModifiers.swift
//  F1-Dash
//
//  Platform-specific UI modifiers with proper abstractions
//

import SwiftUI

// MARK: - Navigation Glass Effect

extension View {
    /// Applies navigation glass effect on supported platforms
    func platformNavigationGlass() -> some View {
        #if os(macOS)
        self.modifier(PlatformNavigationGlassModifier())
        #else
        self
        #endif
    }
}

#if os(macOS)
struct PlatformNavigationGlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            content.applyNavigationGlass()
        } else {
            content
        }
    }
}
#endif

// MARK: - Glass Effect Containers

extension View {
    /// Applies glass effect on supported platforms with fallback
    func platformGlassEffect() -> some View {
        self.modifier(PlatformGlassEffectModifier())
    }
}

struct PlatformGlassEffectModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS) || os(macOS)
        if #available(iOS 26, macOS 26, *) {
            content.glassEffect(.regular.interactive())
        } else {
            content
        }
        #else
        content
        #endif
    }
}

// MARK: - Container Views

struct PlatformHStackContainer<Content: View>: View {
    let spacing: CGFloat
    let content: Content
    
    init(spacing: CGFloat = 12, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        #if os(iOS) || os(macOS)
        if #available(iOS 26, macOS 26, *) {
            GlassEffectContainer(spacing: spacing) {
                content
            }
        } else {
            HStack(spacing: spacing) {
                content
            }
        }
        #else
        HStack(spacing: spacing) {
            content
        }
        #endif
    }
}

// MARK: - Preview Examples

#Preview("Platform Modifiers Example") {
    VStack(spacing: 20) {
        Text("Navigation Glass Effect Demo")
            .font(.title2)
            .platformNavigationGlass()
        
        Text("Glass Effect Demo")
            .padding()
            .background(.ultraThinMaterial)
            .platformGlassEffect()
        
        PlatformHStackContainer(spacing: 16) {
            ForEach(0..<3) { i in
                Text("Item \(i)")
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    .padding()
}
