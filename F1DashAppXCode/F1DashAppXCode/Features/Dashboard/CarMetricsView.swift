//
//  CarMetricsView.swift
//  F1-Dash
//
//  Live car telemetry metrics (RPM, throttle, brake, etc.)
//

import SwiftUI
import F1DashModels

struct CarMetricsView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    let carData: CarDataChannels?
    
    var body: some View {
        if appEnvironment.settingsStore.showCarMetrics {
            VStack(alignment: .leading, spacing: 8) {
                Text("Car Telemetry")
                    .font(.headline)
            
            if let data = carData {
                VStack(spacing: 12) {
                    // First row: RPM and Speed
                    HStack(spacing: 16) {
                        RPMGauge(rpm: data.rpm)
                        SpeedGauge(speed: data.speed)
                    }
                    
                    // Second row: Throttle and Brake
                    HStack(spacing: 16) {
                        ThrottleGauge(throttle: data.throttle)
                        BrakeGauge(brake: data.brake)
                    }
                    
                    // Third row: Gear and DRS
                    HStack(spacing: 16) {
                        GearIndicator(gear: data.gear)
                        DRSIndicator(drs: data.drs)
                    }
                }
            } else {
                ContentUnavailableView(
                    "No Telemetry Data",
                    systemImage: "gauge.with.dots.needle.33percent",
                    description: Text("Car telemetry data will appear here during a session")
                )
                .frame(height: 100)
            }
        }
        } else {
            EmptyView()
        }
    }
}

// MARK: - RPM Gauge

struct RPMGauge: View {
    let rpm: Int
    
    private let maxRPM = 15000.0
    
    var body: some View {
        VStack(spacing: 4) {
            Text("RPM")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                // RPM progress
                Circle()
                    .trim(from: 0, to: rpmPercentage)
                    .stroke(rpmColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                // RPM value
                Text("\(rpm)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(rpmColor)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var rpmPercentage: CGFloat {
        min(CGFloat(rpm) / maxRPM, 1.0)
    }
    
    private var rpmColor: Color {
        switch rpmPercentage {
        case 0.0..<0.6: return .green
        case 0.6..<0.85: return .yellow
        default: return .red
        }
    }
}

// MARK: - Speed Gauge

struct SpeedGauge: View {
    let speed: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Speed")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 2) {
                Text("\(speed)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                
                Text("km/h")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 60, height: 60)
            .background(Circle().fill(Color.blue.opacity(0.1)))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Throttle Gauge

struct ThrottleGauge: View {
    let throttle: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Throttle")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 4) {
                // Vertical bar gauge
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 20, height: 40)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.green)
                        .frame(width: 20, height: CGFloat(throttle) / 100.0 * 40)
                }
                
                Text("\(throttle)%")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.green)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Brake Gauge

struct BrakeGauge: View {
    let brake: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Brake")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 4) {
                // Vertical bar gauge
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 20, height: 40)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.red)
                        .frame(width: 20, height: CGFloat(brake) / 100.0 * 40)
                }
                
                Text("\(brake)%")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Gear Indicator

struct GearIndicator: View {
    let gear: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Gear")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(gearColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text(gearText)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(gearColor)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var gearText: String {
        switch gear {
        case 0: return "N"
        case -1: return "R"
        default: return "\(gear)"
        }
    }
    
    private var gearColor: Color {
        switch gear {
        case 0: return .orange
        case -1: return .red
        default: return .blue
        }
    }
}

// MARK: - DRS Indicator

struct DRSIndicator: View {
    let drs: Int
    
    private var isActive: Bool {
        drs > 0
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("DRS")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isActive ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Text("DRS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(isActive ? .green : .gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack(spacing: 20) {
        // Active telemetry
        CarMetricsView(
            carData: CarDataChannels(
                rpm: 12000,
                speed: 280,
                gear: 6,
                throttle: 85,
                brake: 0,
                drs: 1
            )
        )
        
        Divider()
        
        // Braking scenario
        CarMetricsView(
            carData: CarDataChannels(
                rpm: 8000,
                speed: 120,
                gear: 3,
                throttle: 0,
                brake: 95,
                drs: 0
            )
        )
        
        Divider()
        
        // No data
        CarMetricsView(carData: nil)
    }
    .padding()
    .frame(width: 300)
}