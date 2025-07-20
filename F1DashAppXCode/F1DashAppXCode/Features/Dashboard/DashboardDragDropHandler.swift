//
//  DashboardDragDropHandler.swift
//  F1-Dash
//
//  Handles drag and drop for dashboard sections across platforms
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Drag and Drop Data

struct DashboardSectionDragData: Codable {
    let sectionType: DashboardSectionType
    let sourceIndex: Int
}

// MARK: - Custom UTType for Dashboard Sections

extension UTType {
    static let dashboardSection = UTType(exportedAs: "com.f1dash.dashboardsection")
}

// MARK: - Draggable Dashboard Section

struct DraggableDashboardSection: View {
    let section: DashboardSectionItem
    let index: Int
    let layoutManager: DashboardLayoutManager
    let content: AnyView
    
    #if os(macOS)
    @State private var isDragging = false
    @State private var isTargeted = false
    #endif
    
    var body: some View {
        content
            #if os(macOS)
            .onDrag {
                isDragging = true
                let data = DashboardSectionDragData(
                    sectionType: section.type,
                    sourceIndex: index
                )
                return NSItemProvider(object: DragData(data))
            }
            .onDrop(of: [.dashboardSection], delegate: DashboardDropDelegate(
                section: section,
                index: index,
                layoutManager: layoutManager,
                isTargeted: $isTargeted
            ))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isTargeted ? Color.accentColor : Color.clear, lineWidth: 2)
                    .padding(2)
                    .animation(.easeInOut(duration: 0.2), value: isTargeted)
            )
            .opacity(isDragging ? 0.5 : 1.0)
            .onChange(of: isDragging) { _, newValue in
                if !newValue {
                    isDragging = false
                }
            }
            #endif
    }
}

#if os(macOS)
// MARK: - Drag Data for macOS

class DragData: NSObject, NSItemProviderWriting {
    let data: DashboardSectionDragData
    
    init(_ data: DashboardSectionDragData) {
        self.data = data
    }
    
    static var writableTypeIdentifiersForItemProvider: [String] {
        [UTType.dashboardSection.identifier]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping @Sendable (Data?, Error?) -> Void) -> Progress? {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(data)
            completionHandler(data, nil)
        } catch {
            completionHandler(nil, error)
        }
        return nil
    }
}

// MARK: - Drop Delegate for macOS

struct DashboardDropDelegate: DropDelegate {
    let section: DashboardSectionItem
    let index: Int
    let layoutManager: DashboardLayoutManager
    @Binding var isTargeted: Bool
    
    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [.dashboardSection]).first else {
            return false
        }
        
        itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.dashboardSection.identifier) { data, error in
            guard let data = data,
                  let dragData = try? JSONDecoder().decode(DashboardSectionDragData.self, from: data) else {
                return
            }
            
            DispatchQueue.main.async {
                // Find the current indices
                guard let sourceIndex = layoutManager.sections.firstIndex(where: { $0.type == dragData.sectionType }),
                      let destinationIndex = layoutManager.sections.firstIndex(where: { $0.type == section.type }) else {
                    return
                }
                
                // Move the item
                if sourceIndex != destinationIndex {
                    layoutManager.sections.move(fromOffsets: IndexSet(integer: sourceIndex), toOffset: destinationIndex > sourceIndex ? destinationIndex + 1 : destinationIndex)
                    layoutManager.saveLayout()
                }
            }
        }
        
        return true
    }
    
    func dropEntered(info: DropInfo) {
        isTargeted = true
    }
    
    func dropExited(info: DropInfo) {
        isTargeted = false
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [.dashboardSection])
    }
}
#endif