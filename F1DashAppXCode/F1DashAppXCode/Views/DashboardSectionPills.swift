//
//  DashboardSectionPills.swift
//  F1-Dash
//
//  Dashboard section selector pills for tab bottom accessory
//

import SwiftUI
import F1DashModels


#if !os(macOS)
@available(iOS 26.0, *)
struct DashboardSectionPills: View {
//    @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @Environment(\.tabViewBottomAccessoryPlacement) var placement
    @Binding var selectedSection: DashboardSection
    @Binding var showTrackMapFullScreen: Bool
    @State private var pulseAnimation = false
    var layoutManager: DashboardLayoutManager? = nil
    
    private func getSectionsInOrder() -> [DashboardSection] {
        var sections: [DashboardSection] = [.all]
        
        if let layoutManager = layoutManager {
            // Use the order from layout manager
            for sectionItem in layoutManager.sections where sectionItem.isVisible {
                switch sectionItem.type {
                case .weather:
                    sections.append(.weather)
                case .trackMap:
                    sections.append(.trackMap)
                case .liveTiming:
                    sections.append(.liveTiming)
                case .raceControl:
                    sections.append(.raceControl)
                }
            }
        } else {
            // Default order
            sections.append(contentsOf: [.weather, .trackMap, .liveTiming, .raceControl])
        }
        
        return sections
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Live indicator
            if appEnvironment.connectionStatus == .connected {
                Circle()
                    .fill(.red)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(.red, lineWidth: 2)
                            .scaleEffect(pulseAnimation ? 1.5 : 1.0)
                            .opacity(pulseAnimation ? 0 : 1)
                            .animation(.easeOut(duration: 1).repeatForever(autoreverses: false), value: pulseAnimation)
                    )
                    .onAppear { pulseAnimation = true }
                    .padding(.horizontal, 4)
            }
          
            switch placement {
            case .expanded:
                expandedView
            case .inline:
                inlineView
            default:
                expandedView
            }
            // Section pills
        }
    }
  
  @ViewBuilder
  var expandedView: some View {
    let sections = getSectionsInOrder()
    ForEach(sections, id: \.self) { section in
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedSection = section
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: section.icon)
                    .font(.caption)
                
              if section != .all {
                    Text(section.rawValue)
                        .font(.caption)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                selectedSection == section
                    ? AnyShapeStyle(.tint)
                    : AnyShapeStyle(.ultraThinMaterial)
            )
            .foregroundStyle(selectedSection == section ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
  }
  
  @ViewBuilder
  var inlineView: some View {
    let sections = getSectionsInOrder()
    ForEach(sections, id: \.self) { section in
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedSection = section
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: section.icon)
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                selectedSection == section
                    ? AnyShapeStyle(.tint)
                    : AnyShapeStyle(.ultraThinMaterial)
            )
            .foregroundStyle(selectedSection == section ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
  }
}

#Preview("Dashboard Section Pills") {
    VStack(spacing: 20) {
        Text("Section Pills")
            .font(.headline)
      if #available(iOS 26.0, *) {
        DashboardSectionPills(
          selectedSection: .constant(.all),
          showTrackMapFullScreen: .constant(false)
        )
      } else {
        // Fallback on earlier versions
      }
    }
    .padding()
    .background(Color.gray.opacity(0.2))
    .environment(AppEnvironment())
}

#endif
