//
//  DisconnectedStateView.swift
//  F1-Dash
//
//  Reusable view for showing disconnected state
//

import SwiftUI

struct DisconnectedStateView: View {
    let title: String
    let message: String
    let iconName: String
    let minHeight: CGFloat
    
    init(
        title: String,
        message: String = "Connect to live session to view",
        iconName: String = "wifi.slash",
        minHeight: CGFloat = 100
    ) {
        self.title = title
        self.message = message
        self.iconName = iconName
        self.minHeight = minHeight
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, minHeight: minHeight)
        .padding(.vertical, 32)
    }
}

// Compact version for smaller sections
struct CompactDisconnectedStateView: View {
    let title: String
    let iconName: String
    
    init(
        title: String,
        iconName: String = "wifi.slash"
    ) {
        self.title = title
        self.iconName = iconName
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundStyle(.tertiary)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 60)
        .padding(.vertical, 8)
    }
}

#Preview("Full Size") {
    DisconnectedStateView(
        title: "Live Timing Not Available",
        message: "Connect to live session to view timing data"
    )
    .frame(width: 300)
    .background(Color.gray.opacity(0.1))
}

#Preview("Compact") {
    CompactDisconnectedStateView(
        title: "Weather data not available"
    )
    .frame(width: 300)
    .background(Color.gray.opacity(0.1))
}