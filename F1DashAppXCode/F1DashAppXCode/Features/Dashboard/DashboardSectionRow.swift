//
//  DashboardSectionRow.swift
//  F1-Dash
//
//  Minimal row view for dashboard sections in edit mode
//

import SwiftUI

struct DashboardSectionRow: View {
    let section: DashboardSectionItem
    let layoutManager: DashboardLayoutManager
    @State private var isHovering = false
    @State private var appeared = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 24)
                #if os(macOS)
                .onHover { hovering in
                    if hovering != isHovering {
                        print("🖱️ Hover on \(section.type.rawValue): \(hovering)")
                    }
                    isHovering = hovering
                }
                .scaleEffect(isHovering ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isHovering)
                #endif
            
            // Icon and title
            Label(section.type.title, systemImage: section.type.icon)
                .font(.body)
                .foregroundStyle(.primary)
            
            Spacer()
            
            // Visibility toggle
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    layoutManager.toggleVisibility(for: section.type)
                }
            } label: {
                Image(systemName: section.isVisible ? "eye" : "eye.slash")
                    .foregroundStyle(section.isVisible ? .primary : .secondary)
            }
            .buttonStyle(.plain)
            #if os(macOS)
            .help(section.isVisible ? "Hide Section" : "Show Section")
            #endif
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
        )
        .scaleEffect(appeared ? 1.0 : 0.8)
        .opacity(appeared ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(section.type.sortOrder) * 0.05)) {
                appeared = true
            }
        }
        .onDisappear {
            appeared = false
        }
    }
}

// Add sort order for staggered animation
extension DashboardSectionType {
    var sortOrder: Int {
        switch self {
        case .weather: return 0
        case .trackMap: return 1
        case .liveTiming: return 2
        case .raceControl: return 3
        }
    }
}