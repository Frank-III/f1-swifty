//
//  PremiumLockOverlay.swift
//  F1DashAppXCode
//
//  Reusable premium lock overlay for gated features
//

import SwiftUI

struct PremiumLockOverlay: View {
    let onUnlockTapped: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        ZStack {
            // Blur background
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            // Lock content
            VStack(spacing: 20) {
                // Lock icon with animation
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.blue.opacity(0.3),
                                    Color.blue.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: 10)
                        .opacity(isHovered ? 1 : 0.6)
                    
                    // Lock icon
                    Image(systemName: isHovered ? "lock.open.fill" : "lock.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(isHovered ? 1.1 : 1.0)
                        .rotationEffect(.degrees(isHovered ? -5 : 0))
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isHovered)
                
                // Text content
                VStack(spacing: 8) {
                    Text("Premium Feature")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text("Unlock advanced weather maps and forecasts")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 280)
                }
                
                // Unlock button
                Button(action: onUnlockTapped) {
                    HStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.yellow)
                        
                        Text("Unlock Premium")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    .scaleEffect(isHovered ? 1.05 : 1.0)
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovered = hovering
                    }
                }
            }
            .padding(40)
        }
    }
}

// Compact version for smaller views
struct CompactPremiumLockOverlay: View {
    let onUnlockTapped: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        ZStack {
            // Blur background
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            // Compact lock content
            VStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                Text("Premium")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                Button {
                    onUnlockTapped()
                } label: {
                    Text("Unlock")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .scaleEffect(isHovered ? 1.05 : 1.0)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovered = hovering
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        // Sample background content
        Image(systemName: "map.fill")
            .font(.system(size: 200))
            .foregroundStyle(.gray)
        
        PremiumLockOverlay {
            print("Unlock tapped")
        }
    }
    .frame(width: 400, height: 300)
}

#Preview("Compact") {
    ZStack {
        // Sample background content
        Color.gray.opacity(0.3)
        
        CompactPremiumLockOverlay {
            print("Unlock tapped")
        }
    }
    .frame(width: 200, height: 150)
}