//
//  MacOS26Extensions.swift
//  F1-Dash
//
//  macOS 26+ specific UI enhancements
//

#if os(macOS)
import SwiftUI

@available(macOS 26, *)
extension View {
    /// Apply Liquid Glass effect to navigation elements
    func applyNavigationGlass() -> some View {
        self
            .background(.ultraThinMaterial)
            .glassEffect(.regular, in: Rectangle())
    }
    
    /// Apply enhanced window styling for macOS 26
    func enhancedWindowStyling() -> some View {
        self
            .background(WindowBackgroundView())
            .preferredColorScheme(.dark) // F1 theme works better in dark mode
    }
}

@available(macOS 26, *)
struct WindowBackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color.platformSecondaryBackground,
                    Color.platformSecondaryBackground.opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Subtle texture overlay
            GeometryReader { geometry in
                Canvas { context, size in
                    // Add subtle grid pattern
                    let gridSize: CGFloat = 50
                    let lineWidth: CGFloat = 0.5
                    
                    context.stroke(
                        Path { path in
                            // Vertical lines
                            for x in stride(from: 0, through: size.width, by: gridSize) {
                                path.move(to: CGPoint(x: x, y: 0))
                                path.addLine(to: CGPoint(x: x, y: size.height))
                            }
                            
                            // Horizontal lines
                            for y in stride(from: 0, through: size.height, by: gridSize) {
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: size.width, y: y))
                            }
                        },
                        with: .color(Color.gray.opacity(0.05)),
                        lineWidth: lineWidth
                    )
                }
            }
        }
        .ignoresSafeArea()
    }
}

@available(macOS 26, *)
struct EnhancedSidebarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
            .background(.ultraThinMaterial)
            .glassEffect(.regular, in: Rectangle())
            .scrollIndicators(.hidden)
    }
}

@available(macOS 26, *)
struct LiveDataIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
            
            Text("LIVE")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.green)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

@available(macOS 26, *)
struct F1ThemeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .tint(.red) // F1 red accent
            .scrollContentBackground(.hidden)
            .background(Color.platformSecondaryBackground)
    }
}

// MARK: - Custom Controls

@available(macOS 26, *)
struct GlassButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .glassEffect(.regular, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

@available(macOS 26, *)
struct F1ProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .tint(.red)
            .controlSize(.small)
    }
}

// MARK: - Convenience Extensions

@available(macOS 26, *)
extension View {
    func f1Theme() -> some View {
        self.modifier(F1ThemeModifier())
    }
    
    func glassCard() -> some View {
        self
            .padding()
            .background(.ultraThinMaterial)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

#endif

