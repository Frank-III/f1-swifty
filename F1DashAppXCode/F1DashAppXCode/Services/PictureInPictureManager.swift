//
//  PictureInPictureManager.swift
//  F1-Dash
//
//  Manages Picture-in-Picture state across platforms
//

import SwiftUI
import Observation

@MainActor
@Observable
public final class PictureInPictureManager {
    // MARK: - Properties
    
    /// Whether PiP is currently active
    private(set) var isPiPActive = false
    
    /// PiP window position (for iOS/iPadOS)
    var pipPosition: CGPoint = CGPoint(x: 20, y: 100)
    
    /// PiP window size
    var pipSize: CGSize = CGSize(width: 300, height: 200)
    
    /// Whether PiP is being dragged
    var isDragging = false
    
    /// Whether user is interacting with PiP (prevents auto-hide)
    var isInteracting = false
    
    // MARK: - Platform-specific properties
    
    #if os(macOS)
    /// Reference to the PiP window on macOS
    weak var pipWindow: NSWindow?
    #endif
    
    /// Reference to the app environment (set during initialization)
    weak var appEnvironment: AppEnvironment?
    
    // MARK: - Public Methods
    
    func togglePiP() {
        print("PiP: togglePiP called, current state: \(isPiPActive)")
        if isPiPActive {
            deactivatePiP()
        } else {
            activatePiP()
        }
    }
    
    func activatePiP() {
        guard appEnvironment != nil else {
            print("Warning: Cannot activate PiP - AppEnvironment not set")
            return
        }
        
        isPiPActive = true
        
        #if os(macOS)
        // macOS implementation will create a separate window
        createMacOSPiPWindow()
        #endif
    }
    
    func deactivatePiP() {
        isPiPActive = false
        
        #if os(macOS)
        pipWindow?.close()
        pipWindow = nil
        #endif
    }
    
    // MARK: - Position Management
    
    func updatePosition(_ newPosition: CGPoint, in screenBounds: CGRect) {
        // Constrain position to keep PiP window fully visible
        let minX = screenBounds.minX
        let maxX = screenBounds.maxX - pipSize.width
        let minY = screenBounds.minY
        let maxY = screenBounds.maxY - pipSize.height
        
        pipPosition = CGPoint(
            x: max(minX, min(maxX, newPosition.x)),
            y: max(minY, min(maxY, newPosition.y))
        )
        
        #if os(macOS)
        // Update macOS window position
        if let window = pipWindow {
            let screenHeight = NSScreen.main?.frame.height ?? 0
            window.setFrameOrigin(NSPoint(
                x: pipPosition.x,
                y: screenHeight - pipPosition.y - pipSize.height
            ))
        }
        #endif
    }
    
    func snapToNearestCorner(in screenBounds: CGRect) {
        let corners = [
            CGPoint(x: 20, y: 100), // Top-left
            CGPoint(x: screenBounds.width - pipSize.width - 20, y: 100), // Top-right
            CGPoint(x: 20, y: screenBounds.height - pipSize.height - 100), // Bottom-left
            CGPoint(x: screenBounds.width - pipSize.width - 20, y: screenBounds.height - pipSize.height - 100) // Bottom-right
        ]
        
        // Find nearest corner
        let nearestCorner = corners.min { corner1, corner2 in
            distance(from: pipPosition, to: corner1) < distance(from: pipPosition, to: corner2)
        } ?? corners[0]
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            pipPosition = nearestCorner
        }
    }
    
    private func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        let dx = point1.x - point2.x
        let dy = point1.y - point2.y
        return sqrt(dx * dx + dy * dy)
    }
    
    // MARK: - macOS Window Management
    
    #if os(macOS)
    private func createMacOSPiPWindow() {
        guard let appEnv = appEnvironment else {
            print("Error: Cannot create PiP window - AppEnvironment is nil")
            isPiPActive = false
            return
        }
        
        let window = NSWindow(
            contentRect: NSRect(x: pipPosition.x, y: pipPosition.y, width: pipSize.width, height: pipSize.height),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        window.hasShadow = true
        
        // Set content view with environment
        let contentView = NSHostingView(rootView: TrackMapPiPContent(appEnvironment: appEnv)
            .environment(appEnv))
        window.contentView = contentView
        
        window.makeKeyAndOrderFront(nil)
        pipWindow = window
    }
    #endif
}

// MARK: - Simplified PiP Content View

struct TrackMapPiPContent: View {
    let appEnvironment: AppEnvironment
    @State private var viewModel: TrackMapViewModel
    
    init(appEnvironment: AppEnvironment) {
        print("PiP: TrackMapPiPContent init with appEnvironment: \(appEnvironment)")
        self.appEnvironment = appEnvironment
        self._viewModel = State(wrappedValue: TrackMapViewModel(appEnvironment: appEnvironment))
    }
    
    var body: some View {
        ZStack {
            // Background with glass effect
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
            
            // Track map content
            if viewModel.hasMapData {
                GeometryReader { geometry in
                    Canvas { context, size in
                        // Draw simplified track
                        drawSimplifiedTrack(in: context, size: size)
                        
                        // Draw driver positions with larger dots for visibility
                        drawDriverPositions(in: context, size: size)
                    }
                    .padding(8)
                }
                
                // Minimal overlay info
                VStack {
                    HStack {
                        // Session status indicator
                        if let trackStatus = appEnvironment.liveSessionState.trackStatus {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color(hex: trackStatus.status.color) ?? .gray)
                                    .frame(width: 8, height: 8)
                                Text(trackStatus.status.displayName)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                            .padding(6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        }
                        
                        Spacer()
                        
                        // Close button for iOS (macOS has window controls)
                        #if !os(macOS)
                        Button {
                            appEnvironment.pictureInPictureManager.deactivatePiP()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                        #endif
                    }
                    .padding(8)
                    
                    Spacer()
                }
            } else {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
    }
    
    private func drawSimplifiedTrack(in context: GraphicsContext, size: CGSize) {
        
        // Draw track with thicker line for better visibility
        var path = Path()
        let points = viewModel.getRotatedTrackPoints(for: size)
        
        if let first = points.first {
            path.move(to: first)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            path.closeSubpath()
        }
        
        // Simple track rendering
        context.stroke(
            path,
            with: .color(.secondary),
            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
        )
    }
    
    private func drawDriverPositions(in context: GraphicsContext, size: CGSize) {
        
        let positions = viewModel.getDriverPositions(for: size)
        
        for position in positions where position.isOnTrack {
            let dotSize: CGFloat = position.isFavorite ? 10 : 8
            
            let rect = CGRect(
                x: position.point.x - dotSize/2,
                y: position.point.y - dotSize/2,
                width: dotSize,
                height: dotSize
            )
            
            // Draw driver dot
            context.fill(
                Circle().path(in: rect),
                with: .color(position.color)
            )
            
            // White border for visibility
            context.stroke(
                Circle().path(in: rect),
                with: .color(.white),
                lineWidth: 1
            )
            
            // Show TLA only for favorite drivers in PiP mode
            if position.isFavorite {
                context.draw(
                    Text(position.tla)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white),
                    at: CGPoint(
                        x: position.point.x,
                        y: position.point.y + dotSize + 4
                    )
                )
            }
        }
    }
}
