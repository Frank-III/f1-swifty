//
//  LiveTimingSection.swift
//  F1-Dash
//
//  Live timing dashboard section component
//

import SwiftUI

struct LiveTimingSection: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Live Timing")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            // Scrollable driver list with both horizontal and vertical scrolling
            ScrollView([.horizontal, .vertical]) {
                EnhancedDriverListView()
                    .frame(minWidth: 600, minHeight: 400)
            }
            .frame(height: 400)
        }
        .padding()
        .modifier(PlatformGlassCardModifier())
    }
}