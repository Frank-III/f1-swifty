//
//  EditableDashboardView.swift
//  F1-Dash
//
//  Provides drag and drop functionality for dashboard sections
//

import SwiftUI
import UniformTypeIdentifiers

struct EditableDashboardView: View {
    @Bindable var layoutManager: DashboardLayoutManager
    
    var body: some View {
        List {
            ForEach(layoutManager.sections) { section in
                if section.isVisible {
                    DashboardSectionRow(section: section, layoutManager: layoutManager)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
            }
            .onMove { source, destination in
                layoutManager.move(from: source, to: destination)
            }
            
            // Hidden sections
            let hiddenSections = layoutManager.sections.filter { !$0.isVisible }
            if !hiddenSections.isEmpty {
                Section("Hidden Sections") {
                    ForEach(hiddenSections) { section in
                        DashboardSectionRow(section: section, layoutManager: layoutManager)
                            .opacity(0.6)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}