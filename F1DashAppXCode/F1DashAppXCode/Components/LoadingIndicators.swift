//
//  LoadingIndicators.swift
//  F1-Dash
//
//  Enhanced loading indicators for iOS 26+
//

import SwiftUI

// MARK: - LoadingArc Shape for iOS 26+

#if os(iOS) || os(macOS)
@available(iOS 26, macOS 26, *)
@Animatable
struct LoadingArc: Shape {
    var center: CGPoint
    var radius: CGFloat
    var startAngle: Angle
    var endAngle: Angle
    @AnimatableIgnored var drawPathClockwise: Bool = true
    
    var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<Double, Double>> {
        get {
            AnimatablePair(
                AnimatablePair(center.x, center.y),
                AnimatablePair(startAngle.degrees, endAngle.degrees)
            )
        }
        set {
            center.x = newValue.first.first
            center.y = newValue.first.second
            startAngle = .degrees(newValue.second.first)
            endAngle = .degrees(newValue.second.second)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: drawPathClockwise
        )
        return path
    }
}

// MARK: - Enhanced Loading View

@available(iOS 26, macOS 26, *)
struct EnhancedLoadingView: View {
    @State private var rotation: Double = 0
    @State private var arcEndAngle: Double = 60
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                .frame(width: size, height: size)
            
            // Animated loading arc
            LoadingArc(
                center: CGPoint(x: size/2, y: size/2),
                radius: size/2,
                startAngle: .degrees(0),
                endAngle: .degrees(arcEndAngle)
            )
            .stroke(
                LinearGradient(
                    colors: [.red, .orange],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(
                    lineWidth: 4,
                    lineCap: .round
                )
            )
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation))
            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotation)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: arcEndAngle)
        }
        .onAppear {
            rotation = 360
            arcEndAngle = 120
        }
    }
}
#endif

// MARK: - Loading View with Fallback

struct F1LoadingView: View {
    let message: String
    let size: CGFloat
    
    var body: some View {
        VStack(spacing: 16) {
            #if os(iOS) || os(macOS)
            if #available(iOS 26, macOS 26, *) {
                EnhancedLoadingView(size: size)
            } else {
                ProgressView()
                    .controlSize(.large)
            }
            #else
            ProgressView()
                .controlSize(.large)
            #endif
            
            Text(message)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Compact Loading Indicator

struct F1CompactLoadingView: View {
    let size: CGFloat
    
    var body: some View {
        #if os(iOS) || os(macOS)
        if #available(iOS 26, macOS 26, *) {
            EnhancedLoadingView(size: size)
        } else {
            ProgressView()
                .scaleEffect(size / 20)
        }
        #else
        ProgressView()
            .scaleEffect(size / 20)
        #endif
    }
}

// MARK: - Weather Loading Complication

struct EnhancedWeatherLoadingComplication: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .strokeBorder(Color.gray.opacity(0.3), lineWidth: 6)
            .background(Circle().fill(Color.gray.opacity(0.1)))
            .frame(width: 70, height: 70)
            .opacity(isAnimating ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

#Preview("F1 Loading View") {
    VStack(spacing: 40) {
        F1LoadingView(message: "Loading track map...", size: 60)
        
        HStack(spacing: 20) {
            F1CompactLoadingView(size: 30)
            F1CompactLoadingView(size: 40)
            F1CompactLoadingView(size: 50)
        }
        
        EnhancedWeatherLoadingComplication()
    }
    .padding()
    .background(Color.platformBackground)
}