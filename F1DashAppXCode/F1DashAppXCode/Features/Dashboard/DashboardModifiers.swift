//
//  DashboardModifiers.swift
//  F1-Dash
//
//  Shared modifiers for dashboard components
//

import SwiftUI

// MARK: - Drag and Drop Support

struct DraggableSectionModifier: ViewModifier {
    let type: DashboardSectionType
    let isEditMode: Bool
    
    func body(content: Content) -> some View {
        if isEditMode {
            content
                .opacity(0.95)
                .scaleEffect(0.98)
                .animation(.easeInOut(duration: 0.2), value: isEditMode)
        } else {
            content
        }
    }
}

extension View {
    func draggableSection(type: DashboardSectionType, isEditMode: Bool) -> some View {
        self.modifier(DraggableSectionModifier(type: type, isEditMode: isEditMode))
    }
}