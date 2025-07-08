//
//  MacOSEditableDashboardView.swift
//  F1-Dash
//
//  macOS-specific implementation of editable dashboard with proper drag and drop
//

#if os(macOS)
import SwiftUI
import UniformTypeIdentifiers

struct MacOSEditableDashboardView: View {
    @Bindable var layoutManager: DashboardLayoutManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with instructions
            HStack {
                Label("Drag sections to reorder", systemImage: "arrow.up.arrow.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Reset Layout") {
                    print("🔄 Reset button clicked")
                    layoutManager.resetToDefault()
                }
                .buttonStyle(.link)
                .controlSize(.small)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.regularMaterial)
            .onAppear {
                print("✅ MacOSEditableDashboardView appeared")
                print("   Sections count: \(layoutManager.sections.count)")
                print("   Visible sections: \(layoutManager.sections.filter { $0.isVisible }.map { $0.type.rawValue })")
            }
            
            // Main list with drag and drop - using simple List for better macOS support
            List {
                ForEach(layoutManager.sections) { section in
                    if section.isVisible {
                        DashboardSectionRow(section: section, layoutManager: layoutManager)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .onDrag {
                                print("🎯 macOS onDrag triggered for: \(section.type.rawValue)")
                                return NSItemProvider(object: section.type.rawValue as NSString)
                            }
                    }
                }
                .onMove { source, destination in
                    print("🚀 macOS onMove triggered")
                    print("   Source: \(source)")
                    print("   Destination: \(destination)")
                    layoutManager.move(from: source, to: destination)
                }
                .onInsert(of: [.text]) { index, items in
                    print("📍 macOS onInsert triggered at index: \(index)")
                    print("   Items: \(items)")
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
            .listStyle(.inset)
        }
    }
}

#endif