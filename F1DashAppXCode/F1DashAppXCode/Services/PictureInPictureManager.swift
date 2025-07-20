//
//  PictureInPictureManager.swift
//  F1-Dash
//
//  Manages Picture-in-Picture state across platforms
//

import SwiftUI
import Observation
import F1DashModels

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
    // weak var appEnvironment: AppEnvironment?
    weak var appEnvironment: OptimizedAppEnvironment?
    
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
        // let contentView = NSHostingView(rootView: TrackMapPiPContent(appEnvironment: appEnv)
        //     .environment(appEnv))
        let contentView = NSHostingView(rootView: OptimizedTrackMapPiPContent(appEnvironment: appEnv)
            .environment(appEnv))
        window.contentView = contentView
        
        window.makeKeyAndOrderFront(nil)
        pipWindow = window
    }
    #endif
}

// MARK: - Original PiP Content View (kept for reference)
/*
struct TrackMapPiPContent: View {
    // Original implementation preserved as comment
    // This was replaced with OptimizedTrackMapPiPContent
}
*/
