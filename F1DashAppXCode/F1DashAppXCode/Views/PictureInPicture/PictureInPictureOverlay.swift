//
//  PictureInPictureOverlay.swift
//  F1-Dash
//
//  Picture-in-Picture overlay for iOS/iPadOS
//

import SwiftUI

#if !os(macOS)
struct PictureInPictureOverlay: View {
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @State private var dragOffset: CGSize = .zero
    @State private var lastDragValue: DragGesture.Value?
    
    private var pipManager: PictureInPictureManager {
        appEnvironment.pictureInPictureManager
    }
    
    var body: some View {
        GeometryReader { geometry in
            if pipManager.isPiPActive {
                TrackMapPiPView()
                    .frame(width: pipManager.pipSize.width, height: pipManager.pipSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .offset(
                        x: pipManager.pipPosition.x + dragOffset.width,
                        y: pipManager.pipPosition.y + dragOffset.height
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                pipManager.isDragging = true
                                dragOffset = value.translation
                                lastDragValue = value
                            }
                            .onEnded { _ in
                                pipManager.isDragging = false
                                
                                let newPosition = CGPoint(
                                    x: pipManager.pipPosition.x + dragOffset.width,
                                    y: pipManager.pipPosition.y + dragOffset.height
                                )
                                
                                pipManager.updatePosition(newPosition, in: geometry.frame(in: .global))
                                
                                // Snap to corner after drag
                                pipManager.snapToNearestCorner(in: geometry.frame(in: .global))
                                
                                dragOffset = .zero
                                lastDragValue = nil
                            }
                    )
                    .scaleEffect(pipManager.isDragging ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: pipManager.isDragging)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: pipManager.isPiPActive)
    }
}

// MARK: - View Modifier

struct PictureInPictureModifier: ViewModifier {
    // let appEnvironment: AppEnvironment
    let appEnvironment: OptimizedAppEnvironment
    
    func body(content: Content) -> some View {
        ZStack {
            content
            PictureInPictureOverlay()
                .environment(appEnvironment)
                .allowsHitTesting(true)
        }
    }
}

extension View {
    // func pictureInPictureOverlay(appEnvironment: AppEnvironment) -> some View {
    func pictureInPictureOverlay(appEnvironment: OptimizedAppEnvironment) -> some View {
        modifier(PictureInPictureModifier(appEnvironment: appEnvironment))
    }
}
#endif
