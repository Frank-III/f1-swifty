//
//  FloatingTrackMapView.swift
//  F1DashAppXCode
//
//  Smooth floating TrackMap PiP using Universal Overlay system
//

import SwiftUI

struct FloatingTrackMapView: View {
    @Binding var show: Bool
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    // View Properties for dragging
    @State private var offset: CGSize = .zero
    @State private var lastStoredOffset: CGSize = .zero
    
    // PiP dimensions
    private let pipWidth: CGFloat = 280
    private let pipHeight: CGFloat = 180
    
    // Computed properties to break up complex expressions
    private var circuitKey: String {
        String(appEnvironment.liveSessionState.sessionInfo?.meeting?.circuit.key ?? 0)
    }
    
    private var isConnected: Bool {
        appEnvironment.connectionStatus == .connected
    }
    
    var body: some View {
        GeometryReader { geometry in
            floatingWindow(in: geometry)
        }
        .transition(windowTransition)
    }
    
    // MARK: - View Components
    
    private func floatingWindow(in geometry: GeometryProxy) -> some View {
        let size = geometry.size
        
        return pipContent
            .frame(width: pipWidth, height: pipHeight)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(borderOverlay)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            .offset(offset)
            .gesture(dragGesture(for: size))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .onAppear { setupInitialPosition(for: size) }
    }
    
    private var pipContent: some View {
        VStack(spacing: 0) {
            headerView
            mapContentView
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Track Map")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            
            Spacer()
            
            Button {
                show = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.3))
    }
    
    private var mapContentView: some View {
        ZStack {
            backgroundGradient
            
            if isConnected {
                OptimizedTrackMapView(circuitKey: circuitKey)
                    .clipped()
            } else {
                disconnectedView
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.05, blue: 0.1),
                Color(red: 0.02, green: 0.02, blue: 0.05),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var disconnectedView: some View {
        VStack(spacing: 8) {
            Image(systemName: "map.fill")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text("Not Connected")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.white.opacity(0.2), lineWidth: 1)
    }
    
    private var windowTransition: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .scale(scale: 0.8).combined(with: .opacity)
        )
    }
    
    // MARK: - Gesture & Positioning
    
    private func dragGesture(for size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                handleDragChanged(value)
            }
            .onEnded { value in
                handleDragEnded(for: size)
            }
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        let translation = value.translation + lastStoredOffset
        offset = translation
    }
    
    private func handleDragEnded(for size: CGSize) {
        withAnimation(.snappy(duration: 0.3)) {
            snapToEdges(for: size)
        }
        lastStoredOffset = offset
    }
    
    private func snapToEdges(for size: CGSize) {
        let safeArea = SafeAreaInsets()
        
        // Calculate constraints
        let maxX = size.width - pipWidth - safeArea.trailing
        let minX = safeArea.leading
        let maxY = size.height - pipHeight - safeArea.bottom
        let minY = safeArea.top
        
        // Calculate new position
        var newX = offset.width
        var newY = offset.height
        
        // Horizontal snapping - snap to nearest edge
        let centerThreshold = size.width / 2
        if newX + pipWidth/2 < centerThreshold {
            newX = minX // Snap to left
        } else {
            newX = maxX // Snap to right
        }
        
        // Vertical constraints - keep within bounds
        if newY < minY {
            newY = minY
        } else if newY > maxY {
            newY = maxY
        }
        
        offset = CGSize(width: newX, height: newY)
    }
    
    private func setupInitialPosition(for size: CGSize) {
        let safeArea = SafeAreaInsets()
        
        offset = CGSize(
            width: size.width - pipWidth - safeArea.trailing,
            height: safeArea.top
        )
        lastStoredOffset = offset
    }
    
    // MARK: - Constants
    
    private struct SafeAreaInsets {
        let top: CGFloat = 60
        let bottom: CGFloat = 100
        let leading: CGFloat = 20
        let trailing: CGFloat = 20
    }
}

#Preview {
    RootView {
        ZStack {
            Color.blue.ignoresSafeArea()
            
            VStack {
                Text("Universal Overlay Track Map Demo")
                    .font(.title)
                    .foregroundStyle(.white)
                
                Button("Show Floating Track Map") {
                    // Demo button
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}
