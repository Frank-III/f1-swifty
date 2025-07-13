//
//  LiveTimingSection.swift
//  F1-Dash
//
//  Live timing dashboard section component
//

import SwiftUI

struct LiveTimingSection: View {
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Live Timing")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            if appEnvironment.connectionStatus == .disconnected {
                DisconnectedStateView(
                    title: "Live Timing Not Available",
                    message: "Connect to live session to view timing data",
                    minHeight: 300
                )
            } else {
                // Responsive driver list with horizontal scrolling
                #if os(iOS)
                if horizontalSizeClass == .compact {
                    // Compact layout for phones with proper scrolling
                    ScrollView([.horizontal, .vertical], showsIndicators: true) {
                        EnhancedDriverListView()
                            .frame(minWidth: 850) // Fixed minimum width
                    }
                    .frame(minHeight: 300, maxHeight: 500)
                } else {
                    // Regular layout for iPads
                    ScrollView([.horizontal, .vertical]) {
                        EnhancedDriverListView()
                            .frame(minWidth: 800, minHeight: 400)
                    }
                    .frame(minHeight: 400, maxHeight: 600)
                }
                #else
                ScrollView([.horizontal, .vertical]) {
                    EnhancedDriverListView()
                        .frame(minWidth: 600, minHeight: 400)
                }
                .frame(height: 400)
                #endif
            }
        }
        .padding()
        .modifier(PlatformGlassCardModifier())
    }
}