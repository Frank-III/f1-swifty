import SwiftUI
import EventSource

// Completely isolated test in UITests folder to avoid main app compilation

struct IsolatedTrackMapTestView: View {
    @State private var positions: [String: (x: Double, y: Double)] = [:]
    @State private var drivers: [(number: String, tla: String, color: String)] = []
    @State private var eventSource: EventSource?
    @State private var isConnected = false
    @State private var animatedPositions: [String: CGPoint] = [:]
    @State private var lastTimestamp = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Circle()
                    .fill(isConnected ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                
                Text(isConnected ? "Connected" : "Disconnected")
                    .font(.headline)
                
                Spacer()
                
                Text("\(drivers.count) drivers, \(positions.count) positions")
                    .font(.caption)
                
                Button(isConnected ? "Disconnect" : "Connect") {
                    if isConnected {
                        disconnect()
                    } else {
                        connect()
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            // Track Canvas
            GeometryReader { geometry in
                Canvas { context, size in
                    drawTrack(context: context, size: size)
                    drawDrivers(context: context, size: size)
                }
                .background(Color(red: 0.05, green: 0.05, blue: 0.1))
            }
        }
        .onDisappear {
            disconnect()
        }
    }
    
    private func drawTrack(context: GraphicsContext, size: CGSize) {
        // Simple oval track
        let padding: CGFloat = 50
        let trackRect = CGRect(
            x: padding,
            y: padding,
            width: size.width - padding * 2,
            height: size.height - padding * 2
        )
        
        let path = Path(ellipseIn: trackRect)
        
        // Track layers
        context.stroke(
            path,
            with: .color(Color.blue.opacity(0.2)),
            style: StrokeStyle(lineWidth: 36, lineCap: .round)
        )
        
        context.stroke(
            path,
            with: .color(Color.black.opacity(0.4)),
            style: StrokeStyle(lineWidth: 30, lineCap: .round)
        )
        
        context.stroke(
            path,
            with: .color(Color.gray),
            style: StrokeStyle(lineWidth: 24, lineCap: .round)
        )
    }
    
    private func drawDrivers(context: GraphicsContext, size: CGSize) {
        for (number, position) in animatedPositions {
            guard let driver = drivers.first(where: { $0.number == number }) else { continue }
            
            let color = Color(hex: driver.color) ?? .gray
            
            // Glow
            context.fill(
                Path(ellipseIn: CGRect(x: position.x - 12, y: position.y - 12, width: 24, height: 24)),
                with: .color(color.opacity(0.3))
            )
            
            // Shadow
            context.fill(
                Path(ellipseIn: CGRect(x: position.x - 9, y: position.y - 9, width: 18, height: 18)),
                with: .color(.black.opacity(0.5))
            )
            
            // Driver circle
            context.fill(
                Path(ellipseIn: CGRect(x: position.x - 8, y: position.y - 8, width: 16, height: 16)),
                with: .color(color)
            )
            
            // Border
            context.stroke(
                Path(ellipseIn: CGRect(x: position.x - 8, y: position.y - 8, width: 16, height: 16)),
                with: .color(.white),
                lineWidth: 1.5
            )
            
            // TLA
            context.draw(
                Text(driver.tla)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white),
                at: position
            )
        }
    }
    
    private func connect() {
        print("🔵 Connecting to SSE...")
        eventSource = EventSource(url: URL(string: "http://127.0.0.1:3000/v1/live/sse")!)
        
        eventSource?.onOpen = {
            Task { @MainActor in
                isConnected = true
                print("✅ SSE Connected")
            }
        }
        
        eventSource?.onMessage = { event in
            Task { @MainActor in
                guard let data = event.data.data(using: .utf8),
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
                
                processSSEData(json)
            }
        }
        
        eventSource?.onError = { error in
            Task { @MainActor in
                isConnected = false
                print("❌ SSE Error: \(String(describing: error))")
            }
        }
    }
    
    private func disconnect() {
        print("🔴 Disconnecting SSE...")
        Task {
            await eventSource?.close()
            eventSource = nil
            isConnected = false
            
            // Clear all data
            positions.removeAll()
            drivers.removeAll()
            animatedPositions.removeAll()
            lastTimestamp = ""
        }
    }
    
    private func processSSEData(_ data: [String: Any]) {
        // Extract driver list
        if let driverList = data["driverList"] as? [[String: Any]] {
            drivers = driverList.compactMap { dict in
                guard let number = dict["racingNumber"] as? String,
                      let tla = dict["tla"] as? String,
                      let color = dict["teamColour"] as? String else { return nil }
                return (number, tla, color)
            }
            print("📋 Found \(drivers.count) drivers")
        }
        
        // Extract positions
        if let posData = data["positionData"] as? [String: Any],
           let posArray = posData["positionData"] as? [[String: Any]] {
            
            if let lastPos = posArray.last,
               let timestamp = lastPos["timestamp"] as? String,
               timestamp != lastTimestamp,
               let entries = lastPos["entries"] as? [String: [String: Any]] {
                
                lastTimestamp = timestamp
                
                var newPositions: [String: (x: Double, y: Double)] = [:]
                for (racingNumber, posData) in entries {
                    if let x = extractCoordinate(from: posData["x"]),
                       let y = extractCoordinate(from: posData["y"]),
                       x != 0 || y != 0 {
                        newPositions[racingNumber] = (x, y)
                    }
                }
                
                positions = newPositions
                print("📍 Updated \(positions.count) positions at \(timestamp)")
                updateAnimatedPositions()
            }
        }
    }
    
    private func extractCoordinate(from value: Any?) -> Double? {
        if let double = value as? Double { return double }
        if let int = value as? Int { return Double(int) }
        if let bool = value as? Bool { return 0.0 }
        if let string = value as? String, let double = Double(string) { return double }
        return nil
    }
    
    private func updateAnimatedPositions() {
        print("🎯 Animating \(positions.count) positions")
        
        // Simple oval track positioning
        let centerX: Double = 400
        let centerY: Double = 300
        let radiusX: Double = 300
        let radiusY: Double = 200
        
        for (number, pos) in positions {
            // Map position to oval track
            let angle = atan2(pos.y, pos.x)
            let normalizedDistance = sqrt(pos.x * pos.x + pos.y * pos.y) / 2000.0
            
            let x = centerX + cos(angle) * radiusX * (0.8 + normalizedDistance * 0.2)
            let y = centerY + sin(angle) * radiusY * (0.8 + normalizedDistance * 0.2)
            
            withAnimation(.linear(duration: 0.8)) {
                animatedPositions[number] = CGPoint(x: x, y: y)
            }
        }
    }
}

// Color extension
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}

// Preview
#Preview("Isolated Track Map Test") {
    IsolatedTrackMapTestView()
        .frame(width: 800, height: 600)
}
