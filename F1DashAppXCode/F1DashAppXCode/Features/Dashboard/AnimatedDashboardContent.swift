//
//  AnimatedDashboardContent.swift
//  F1-Dash
//
//  Provides animated transitions between dashboard views and edit mode
//

import SwiftUI

struct AnimatedDashboardContent: View {
    @State var layoutManager: DashboardLayoutManager
    @Binding var showTrackMapFullScreen: Bool
    @Namespace private var namespace
    
    var body: some View {
        ZStack {
            if layoutManager.isEditMode {
                // Edit mode - minimal list view
                editModeContent
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 1.2).combined(with: .opacity)
                    ))
            } else {
                // Normal mode - full dashboard
                normalModeContent
                    .transition(.asymmetric(
                        insertion: .scale(scale: 1.2).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: layoutManager.isEditMode)
    }
    
    @ViewBuilder
    private var editModeContent: some View {
        VStack(spacing: 0) {
            // Animated header
            HStack {
                Text("Edit Dashboard Layout")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("Drag to reorder • Tap eye to hide/show")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .transition(.move(edge: .top).combined(with: .opacity))
            
            #if os(macOS)
            MacOSEditableDashboardView(layoutManager: layoutManager)
            #else
            EditableDashboardView(layoutManager: layoutManager)
            #endif
        }
    }
    
    @ViewBuilder
    private var normalModeContent: some View {
        let sectionBuilder = DashboardSectionBuilder(
            layoutManager: layoutManager,
            showTrackMapFullScreen: $showTrackMapFullScreen
        )
        
        ScrollView {
            VStack(spacing: 16) {
                ForEach(layoutManager.sections) { section in
                    if section.isVisible && shouldShowSection(section.type) {
                        sectionBuilder.buildSection(for: section.type)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale(scale: 0.8).combined(with: .opacity)
                            ))
                            .id(section.id)
                    }
                }
            }
            .padding(.bottom)
        }
    }
    
    private func shouldShowSection(_ type: DashboardSectionType) -> Bool {
        // This would need to be passed in or accessed from environment
        // For now, returning true for all sections
        return true
    }
}

// MARK: - Minimizable Section Wrapper

struct MinimizableDashboardSection: View {
    let section: DashboardSectionItem
    let isEditMode: Bool
    let content: AnyView
    @State private var isMinimizing = false
    
    var body: some View {
        Group {
            if isEditMode {
                DashboardSectionRow(
                    section: section,
                    layoutManager: DashboardLayoutManager() // This would need to be passed in
                )
                .scaleEffect(isMinimizing ? 0.95 : 1.0)
                .opacity(isMinimizing ? 0.8 : 1.0)
            } else {
                content
                    .scaleEffect(isMinimizing ? 1.05 : 1.0)
                    .opacity(isMinimizing ? 0.8 : 1.0)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isMinimizing)
        .onChange(of: isEditMode) { _, newValue in
            withAnimation(.easeInOut(duration: 0.2)) {
                isMinimizing = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isMinimizing = false
                }
            }
        }
    }
}