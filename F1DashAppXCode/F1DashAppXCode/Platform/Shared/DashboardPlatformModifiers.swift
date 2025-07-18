//
//  DashboardPlatformModifiers.swift
//  F1-Dash
//
//  Platform-specific modifiers for dashboard views
//

import SwiftUI

// MARK: - Platform 26+ Enhancement Modifiers and Styles

/// Liquid Glass card modifier for iOS/macOS 26+ with fallback
struct PlatformGlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 26, *) {
            content
                .background(Color(uiColor: .systemBackground))
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12), isEnabled: true)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            content
                .background(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        }
        #elseif os(macOS)
        if #available(macOS 26, *) {
            content
                .background(Color(nsColor: .controlBackgroundColor))
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12), isEnabled: true)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            content
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        }
        #else
        content
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        #endif
    }
}

/// Liquid Glass button style for iOS/macOS 26+ with fallback
struct PlatformGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        #if os(iOS) || os(macOS)
        if #available(iOS 26, macOS 26, *) {
            configuration.label
                .buttonStyle(.glass)
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        } else {
            fallbackButtonStyle(configuration: configuration)
        }
        #else
        fallbackButtonStyle(configuration: configuration)
        #endif
    }
    
    private func fallbackButtonStyle(configuration: Configuration) -> some View {
        #if os(macOS)
        configuration.label
            .buttonStyle(.borderedProminent)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        #else
        configuration.label
            .padding(8)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        #endif
    }
}

/// Enhanced scrolling modifier for iOS/macOS 26+ with fallback
struct PlatformEnhancedScrollingModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS) || os(macOS)
        if #available(iOS 26, macOS 26, *) {
            content
                .backgroundExtensionEffect()
        } else {
            content
        }
        #else
        content
        #endif
    }
}

/// Tab bar enhancement modifier for iOS 26+ with fallback
struct PlatformTabBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 26, *) {
            content
                .tabBarMinimizeBehavior(.automatic)
        } else {
            content
        }
        #else
        content
        #endif
    }
}

/// Glass header modifier for iOS/macOS 26+ with fallback  
struct PlatformGlassHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 26, *) {
            content
                .background(.ultraThinMaterial)
                .glassEffect(.regular, in: Rectangle(), isEnabled: true)
        } else {
            content
                .background(Color(uiColor: .systemBackground))
        }
        #elseif os(macOS)
        if #available(macOS 26, *) {
            content
                .background(.ultraThinMaterial)
                .glassEffect(.regular, in: Rectangle(), isEnabled: true)
        } else {
            content
                .background(Color(nsColor: .windowBackgroundColor))
        }
        #else
        content
            .background(Color.clear)
        #endif
    }
}

// MARK: - iOS 26+ Tab Accessory Modifier

struct iOS26TabAccessoryModifier: ViewModifier {
    let appEnvironment: OptimizedAppEnvironment
    @Binding var selectedTab: Int
    @Binding var showWeatherSheet: Bool
    @Binding var showTrackMapFullScreen: Bool
    @Binding var selectedDashboardSection: DashboardSection
    var layoutManager: DashboardLayoutManager? = nil
    
    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 26, *) {
            content
                .tabViewBottomAccessory {
                    // TODO: some bugs in iOS26
//                    if appEnvironment.connectionStatus != .disconnected && selectedTab == 0 {
                        DashboardSectionPills(
                          selectedSection: $selectedDashboardSection,
                            showTrackMapFullScreen: $showTrackMapFullScreen,
                            layoutManager: layoutManager
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
//                    }
                }
                .tabBarMinimizeBehavior(.onScrollDown)
                .tabViewStyle(.sidebarAdaptable)
        } else {
            content
        }
        #else
        content
        #endif
    }
}
