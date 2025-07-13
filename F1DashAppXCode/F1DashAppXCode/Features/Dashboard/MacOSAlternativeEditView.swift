//
//  MacOSAlternativeEditView.swift
//  F1-Dash
//
//  Alternative macOS edit view using VStack with manual drag handling
//

#if os(macOS)
import SwiftUI

struct MacOSAlternativeEditView: View {
    @Bindable var layoutManager: DashboardLayoutManager
    @State private var draggedItem: DashboardSectionType?
    @State private var draggedOverItem: DashboardSectionType?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(Array(layoutManager.sections.enumerated()), id: \.element.id) { index, section in
                    if section.isVisible {
                        DashboardSectionRow(section: section, layoutManager: layoutManager)
                            .background(draggedOverItem == section.type ? Color.accentColor.opacity(0.1) : Color.clear)
                            .onDrag {
                                print("🎯 Alternative: Starting drag for \(section.type.rawValue)")
                                self.draggedItem = section.type
                                return NSItemProvider(object: section.type.rawValue as NSString)
                            }
                            .onDrop(of: [.text], delegate: SectionDropDelegate(
                                item: section.type,
                                draggedItem: $draggedItem,
                                draggedOverItem: $draggedOverItem,
                                layoutManager: layoutManager
                            ))
                    }
                }
                
                // Hidden sections
                let hiddenSections = layoutManager.sections.filter { !$0.isVisible }
                if !hiddenSections.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hidden Sections")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 16)
                        
                        ForEach(hiddenSections) { section in
                            DashboardSectionRow(section: section, layoutManager: layoutManager)
                                .opacity(0.6)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct SectionDropDelegate: DropDelegate {
    let item: DashboardSectionType
    @Binding var draggedItem: DashboardSectionType?
    @Binding var draggedOverItem: DashboardSectionType?
    let layoutManager: DashboardLayoutManager
    
    func dropEntered(info: DropInfo) {
        print("📥 Drop entered over: \(item.rawValue)")
        draggedOverItem = item
    }
    
    func dropExited(info: DropInfo) {
        print("📤 Drop exited from: \(item.rawValue)")
        draggedOverItem = nil
    }
    
    func performDrop(info: DropInfo) -> Bool {
        print("💧 Perform drop on: \(item.rawValue)")
        draggedOverItem = nil
        
        guard let draggedItem = draggedItem else {
            print("   ❌ No dragged item")
            return false
        }
        
        guard draggedItem != item else {
            print("   ❌ Same item")
            return false
        }
        
        guard let fromIndex = layoutManager.sections.firstIndex(where: { $0.type == draggedItem }),
              let toIndex = layoutManager.sections.firstIndex(where: { $0.type == item }) else {
            print("   ❌ Couldn't find indices")
            return false
        }
        
        print("   ✅ Moving from \(fromIndex) to \(toIndex)")
        
        withAnimation {
            layoutManager.sections.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex
            )
            layoutManager.saveLayout()
        }
        
        return true
    }
}
#endif