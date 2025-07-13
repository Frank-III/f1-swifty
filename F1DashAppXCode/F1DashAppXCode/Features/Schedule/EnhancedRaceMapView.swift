//
//  EnhancedRaceMapView.swift
//  F1-Dash
//
//  Enhanced map view with proper popover positioning
//

import SwiftUI
import MapKit
import F1DashModels

struct EnhancedRaceMapView: View {
    let races: [RaceRound]
    @Binding var selectedRace: RaceRound?
    @State private var preferences = RacePreferences()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 100)
    )
    @State private var sheetRace: RaceRound?
    @State private var popoverRace: RaceRound?
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: races) { race in
            MapAnnotation(coordinate: coordinateForRace(race)) {
                EnhancedRaceMapMarker(
                    race: race,
                    isSelected: selectedRace?.id == race.id,
                    preferences: preferences,
                    onTap: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedRace = race
                            #if os(iOS)
                            sheetRace = race
                            #else
                            popoverRace = race
                            #endif
                        }
                    }
                )
                #if os(macOS)
                .popover(isPresented: Binding(
                    get: { popoverRace?.id == race.id },
                    set: { if !$0 { popoverRace = nil } }
                ), attachmentAnchor: .point(.top), arrowEdge: .bottom) {
                    if popoverRace?.id == race.id {
                        RaceDetailPopover(race: race, preferences: preferences)
                            .frame(width: 350, height: 400)
                    }
                }
                #endif
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .onChange(of: selectedRace) { _, newRace in
            if let race = newRace {
                #if os(iOS)
                sheetRace = race
                #else
                popoverRace = race
                #endif
            }
        }
        #if os(iOS)
        .sheet(item: $sheetRace) { race in
            RaceDetailSheet(race: race, preferences: preferences)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        #endif
    }
    
    private func coordinateForRace(_ race: RaceRound) -> CLLocationCoordinate2D {
        RaceLocationData.locations[race.countryName] ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
}

struct EnhancedRaceMapMarker: View {
    let race: RaceRound
    let isSelected: Bool
    let preferences: RacePreferences
    let onTap: () -> Void
    
    @State private var isHovering = false
    
    private var raceId: String {
        race.preferenceId
    }
    
    private var isPast: Bool {
        race.end < Date()
    }
    
    private var markerColor: Color {
        RaceColorTheme.color(for: race.countryName, isActive: race.isActive, isPast: isPast)
    }
    
    var body: some View {
        ZStack {
            // Shadow for depth
            Circle()
                .fill(Color.black.opacity(0.2))
                .frame(width: isSelected || isHovering ? 36 : 28,
                       height: isSelected || isHovering ? 36 : 28)
                .blur(radius: 3)
                .offset(y: 2)
            
            // 3D pin with adaptive background
            VStack(spacing: -2) {
                // Circular head with gradient
                ZStack {
                    // Background circle with subtle tint
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    markerColor.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: isSelected || isHovering ? 28 : 22,
                               height: isSelected || isHovering ? 28 : 22)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            (isPast ? Color.gray : markerColor).opacity(0.8),
                                            (isPast ? Color.gray : markerColor)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                    
                    // Inner colored circle with gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    (isPast ? Color.gray : markerColor).opacity(0.8),
                                    isPast ? Color.gray : markerColor
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: isSelected || isHovering ? 18 : 14,
                               height: isSelected || isHovering ? 18 : 14)
                        .overlay(
                            // Highlight for 3D effect
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.5),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .center
                                    )
                                )
                                .frame(width: isSelected || isHovering ? 12 : 8,
                                       height: isSelected || isHovering ? 12 : 8)
                                .offset(x: -2, y: -2)
                        )
                    
                    // Icons overlay
                    if preferences.isFavorite(raceId) {
                        Image(systemName: "star.fill")
                            .font(.system(size: isSelected || isHovering ? 10 : 8))
                            .foregroundStyle(.white)
                            .shadow(color: Color.black.opacity(0.3), radius: 1)
                    }
                }
                
                // Pin tail with gradient
                PinTail()
                    .fill(
                        LinearGradient(
                            colors: [
                                isPast ? Color.gray : markerColor,
                                (isPast ? Color.gray : markerColor).opacity(0.7)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 8, height: 10)
                    .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
            }
            
            // Live indicator
            if race.isActive {
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
                    .overlay(
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.white.opacity(0.8), Color.clear],
                                    center: .topLeading,
                                    startRadius: 1,
                                    endRadius: 3
                                )
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .shadow(color: Color.green.opacity(0.5), radius: 2)
                    .offset(x: isSelected || isHovering ? 12 : 10, 
                            y: isSelected || isHovering ? -12 : -10)
            }
        }
        .scaleEffect(isSelected ? 1.2 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
        .animation(.easeInOut(duration: 0.2), value: isHovering)
        .onTapGesture(perform: onTap)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

struct PinTail: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addQuadCurve(
                to: CGPoint(x: rect.midX, y: rect.maxY),
                control: CGPoint(x: rect.maxX, y: rect.midY)
            )
            path.addQuadCurve(
                to: CGPoint(x: rect.minX, y: rect.minY),
                control: CGPoint(x: rect.minX, y: rect.midY)
            )
            path.closeSubpath()
        }
    }
}