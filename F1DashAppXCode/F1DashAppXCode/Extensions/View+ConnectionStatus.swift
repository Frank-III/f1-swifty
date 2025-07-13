//
//  View+ConnectionStatus.swift
//  F1-Dash
//
//  View modifier for showing content not available when disconnected
//

import SwiftUI

struct ConnectionStatusModifier: ViewModifier {
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    let sectionName: String
    
    func body(content: Content) -> some View {
        Group {
            if appEnvironment.connectionStatus == .disconnected {
                VStack(spacing: 12) {
                    Image(systemName: "wifi.slash")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                    
                    Text("\(sectionName) Not Available")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text("Connect to live session to view")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, minHeight: 100)
                .padding(.vertical, 24)
            } else {
                content
            }
        }
    }
}

extension View {
    func requiresConnection(_ sectionName: String) -> some View {
        modifier(ConnectionStatusModifier(sectionName: sectionName))
    }
}