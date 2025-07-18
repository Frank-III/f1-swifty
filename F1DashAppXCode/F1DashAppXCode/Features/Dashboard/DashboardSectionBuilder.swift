//
//  DashboardSectionBuilder.swift
//  F1-Dash
//
//  Builder for dashboard section views with edit mode support
//

import SwiftUI

@MainActor
struct DashboardSectionBuilder {
    let layoutManager: DashboardLayoutManager
    @Binding var showTrackMapFullScreen: Bool
    
    @ViewBuilder
    func buildSection(for type: DashboardSectionType) -> some View {
        let baseView = Group {
            switch type {
            case .weather:
                WeatherSection()
                
            case .trackMap:
                TrackMapSection(showTrackMapFullScreen: $showTrackMapFullScreen)
                
            case .liveTiming:
                LiveTimingSection(shouldExpand: false)
                
            case .raceControl:
                RaceControlSection()
            }
        }
        
        if layoutManager.isEditMode {
            baseView
                .draggableSection(type: type, isEditMode: true)
                .contextMenu {
                    Button {
                        layoutManager.toggleVisibility(for: type)
                    } label: {
                        Label("Hide Section", systemImage: "eye.slash")
                    }
                    
                    Divider()
                    
                    Button {
                        layoutManager.resetToDefault()
                    } label: {
                        Label("Reset Layout", systemImage: "arrow.counterclockwise")
                    }
                }
        } else {
            baseView
                .draggableSection(type: type, isEditMode: false)
        }
    }
}
