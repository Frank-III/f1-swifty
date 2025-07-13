//
//  HybridTrackMapTestView.swift
//  F1-Dash
//
//  Test implementation of hybrid track map rendering
//  Canvas for static track elements + SwiftUI views for animated drivers
//

import SwiftUI
import F1DashModels

// MARK: - Test View Model

@MainActor
@Observable
final class HybridTestViewModel {
    // Simulated driver positions for testing
    private(set) var driverPositions: [TestDriverPosition] = []
    private var updateTimer: Timer?
    
    // Track bounds for normalization
    let trackBounds = (minX: -1000.0, maxX: 1000.0, minY: -1000.0, maxY: 1000.0)
    
    init() {
        setupInitialPositions()
        startSimulatedUpdates()
    }
    
    deinit {
        // Timer cleanup handled in startSimulatedUpdates
    }
    
    private func setupInitialPositions() {
        // Create 20 test drivers with initial positions
        // Split into smaller arrays to help compiler
        let teamsRB = [("1", "VER", "#1B2A48"), ("11", "PER", "#1B2A48")]
        let teamsMerc = [("44", "HAM", "#00A19B"), ("63", "RUS", "#00A19B")]
        let teamsFer = [("16", "LEC", "#DC0000"), ("55", "SAI", "#DC0000")]
        let teamsMcL = [("4", "NOR", "#FF8700"), ("81", "PIA", "#FF8700")]
        let teamsAM = [("14", "ALO", "#229971"), ("18", "STR", "#229971")]
        let teamsAlp = [("31", "OCO", "#FF87BC"), ("10", "GAS", "#FF87BC")]
        let teamsStake = [("77", "BOT", "#52E252"), ("24", "ZHO", "#52E252")]
        let teamsRBVT = [("22", "TSU", "#5E8FAA"), ("3", "RIC", "#5E8FAA")]
        let teamsWil = [("23", "ALB", "#6692FF"), ("2", "SAR", "#6692FF")]
        let teamsHaas = [("20", "MAG", "#B6BABD"), ("27", "HUL", "#B6BABD")]
        
        let allTeams = teamsRB + teamsMerc + teamsFer + teamsMcL + teamsAM + 
                       teamsAlp + teamsStake + teamsRBVT + teamsWil + teamsHaas
        
        var positions: [TestDriverPosition] = []
        
        for (index, team) in allTeams.enumerated() {
            // Distribute drivers around the track
            let angle = Double(index) / Double(allTeams.count) * 2 * .pi
            let radius = 500.0
            let position = TestDriverPosition(
                id: team.0,
                number: team.0,
                tla: team.1,
                teamColor: Color(hex: team.2) ?? .gray,
                x: cos(angle) * radius,
                y: sin(angle) * radius
            )
            positions.append(position)
        }
        
        driverPositions = positions
    }
    
    private func startSimulatedUpdates() {
        // Simulate position updates every second
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                self.updatePositions()
            }
        }
    }
    
    func updatePositions() {
        // Move drivers along circular path
        for i in driverPositions.indices {
            let currentAngle = atan2(driverPositions[i].y, driverPositions[i].x)
            let newAngle = currentAngle + 0.1 // Move 0.1 radians
            let radius = sqrt(pow(driverPositions[i].x, 2) + pow(driverPositions[i].y, 2))
            
            driverPositions[i].x = cos(newAngle) * radius
            driverPositions[i].y = sin(newAngle) * radius
        }
    }
    
    func normalizedPosition(x: Double, y: Double, in size: CGSize) -> CGPoint {
        let normalizedX = (x - trackBounds.minX) / (trackBounds.maxX - trackBounds.minX)
        let normalizedY = 1.0 - (y - trackBounds.minY) / (trackBounds.maxY - trackBounds.minY)
        
        return CGPoint(
            x: normalizedX * size.width,
            y: normalizedY * size.height
        )
    }
}

// MARK: - Test Driver Position Model

struct TestDriverPosition: Identifiable, Equatable {
    let id: String
    let number: String
    let tla: String
    let teamColor: Color
    var x: Double
    var y: Double
    
    static func == (lhs: TestDriverPosition, rhs: TestDriverPosition) -> Bool {
        lhs.id == rhs.id &&
        lhs.x == rhs.x &&
        lhs.y == rhs.y
    }
}

// MARK: - Static Track Canvas Layer

struct HybridTrackCanvas: View {
    let viewModel: HybridTestViewModel
    let size: CGSize
    
    var body: some View {
        Canvas { context, _ in
            // Draw simple circular track for testing
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) * 0.35
            
            // Track outline
            let trackPath = Path { path in
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .zero,
                    endAngle: .degrees(360),
                    clockwise: true
                )
            }
            
            // Draw track base
            context.stroke(
                trackPath,
                with: .color(Color(white: 0.3)),
                style: StrokeStyle(lineWidth: 40, lineCap: .round)
            )
            
            // Draw track centerline
            context.stroke(
                trackPath,
                with: .color(Color(white: 0.5).opacity(0.5)),
                style: StrokeStyle(
                    lineWidth: 2,
                    dash: [10, 10]
                )
            )
            
            // Draw start/finish line
            let finishLine = Path { path in
                path.move(to: CGPoint(x: center.x + radius - 20, y: center.y))
                path.addLine(to: CGPoint(x: center.x + radius + 20, y: center.y))
            }
            
            context.stroke(
                finishLine,
                with: .color(.red),
                style: StrokeStyle(lineWidth: 4)
            )
            
            // Add some corner numbers for reference
            for i in 0..<4 {
                let angle = Double(i) * .pi / 2
                let cornerX = center.x + cos(angle) * (radius + 40)
                let cornerY = center.y + sin(angle) * (radius + 40)
                
                context.draw(
                    Text("\(i + 1)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.secondary),
                    at: CGPoint(x: cornerX, y: cornerY)
                )
            }
        }
    }
}

// MARK: - Animated Driver Layer

struct HybridDriverLayer: View {
    let viewModel: HybridTestViewModel
    let size: CGSize
    @State private var animatedPositions: [String: CGPoint] = [:]
    
    var body: some View {
        ZStack {
            ForEach(viewModel.driverPositions) { driver in
                DriverMarker(
                    driver: driver,
                    position: animatedPositions[driver.id] ?? .zero
                )
                .animation(.linear(duration: 1.0), value: animatedPositions[driver.id])
            }
        }
        .onChange(of: viewModel.driverPositions) { _, newPositions in
            // Update animated positions when model changes
            for driver in newPositions {
                animatedPositions[driver.id] = viewModel.normalizedPosition(
                    x: driver.x,
                    y: driver.y,
                    in: size
                )
            }
        }
        .onAppear {
            // Set initial positions
            for driver in viewModel.driverPositions {
                animatedPositions[driver.id] = viewModel.normalizedPosition(
                    x: driver.x,
                    y: driver.y,
                    in: size
                )
            }
        }
    }
}

// MARK: - Driver Marker View

struct DriverMarker: View {
    let driver: TestDriverPosition
    let position: CGPoint
    
    var body: some View {
        ZStack {
            // Shadow for depth
            Circle()
                .fill(.black.opacity(0.3))
                .frame(width: 18, height: 18)
                .offset(x: 1, y: 1)
            
            // Team color circle
            Circle()
                .fill(driver.teamColor)
                .frame(width: 16, height: 16)
            
            // White border
            Circle()
                .stroke(.white, lineWidth: 1)
                .frame(width: 16, height: 16)
            
            // Driver number
            Text(driver.number)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white)
        }
        .position(position)
    }
}

// MARK: - Main Hybrid Test View

struct HybridTrackMapTestView: View {
    @State private var viewModel = HybridTestViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black
                
                // Static track layer (Canvas)
                HybridTrackCanvas(
                    viewModel: viewModel,
                    size: geometry.size
                )
                
                // Animated driver layer (SwiftUI views)
                HybridDriverLayer(
                    viewModel: viewModel,
                    size: geometry.size
                )
                
                // Reload button overlay (simulates new positions)
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            viewModel.updatePositions()
                        } label: {
                            Label("Update Positions", systemImage: "arrow.clockwise")
                                .labelStyle(.iconOnly)
                                .font(.system(size: 16))
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                        .padding()
                    }
                    Spacer()
                }
            }
        }
        .navigationTitle("Hybrid Track Map Test")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HybridTrackMapTestView()
    }
}

// MARK: - Preview with Different Sizes

//#Preview("iPad") {
//    NavigationStack {
//        HybridTrackMapTestView()
//    }
//    .previewDevice("iPad Pro (12.9-inch)")
//}
//
//#Preview("Small iPhone") {
//    NavigationStack {
//        HybridTrackMapTestView()
//    }
//    .previewDevice("iPhone SE (3rd generation)")
//}
