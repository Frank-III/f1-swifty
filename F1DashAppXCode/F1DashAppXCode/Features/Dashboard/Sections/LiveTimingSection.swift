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
    
    private let tableContentWidth: CGFloat = 650 // Content width without padding
    private let horizontalPadding: CGFloat = 16 // Match the row padding
    let shouldExpand : Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with padding
            HStack {
                Text("Live Timing")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding()
            
            if appEnvironment.connectionStatus == .disconnected {
                DisconnectedStateView(
                    title: "Live Timing Not Available",
                    message: "Connect to live session to view timing data",
                    minHeight: 300
                )
                .padding(.horizontal)
                .padding(.bottom)
            } else {
                // Content with proper scrolling
                GeometryReader { geometry in
                    let totalTableWidth = tableContentWidth + (horizontalPadding * 2)
                    let needsHorizontalScroll = geometry.size.width < totalTableWidth
                    
                    if needsHorizontalScroll {
                        ScrollView([.horizontal, .vertical], showsIndicators: true) {
                            EnhancedDriverListView()
                                .frame(width: totalTableWidth)
                        }
                    } else {
                        ScrollView(.vertical, showsIndicators: true) {
                            HStack {
                                Spacer()
                                EnhancedDriverListView()
                                Spacer()
                            }
                            .frame(width: geometry.size.width)
                        }
                    }
                }
                .frame(minHeight: 400, maxHeight: shouldExpand ? .infinity: 600)
            }
        }
        .modifier(PlatformGlassCardModifier())
    }
}
