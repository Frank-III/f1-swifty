//
//  StandingsView.swift
//  F1-Dash
//
//  Live Championship Standings View
//

import SwiftUI
import F1DashModels

struct StandingsView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    private var championshipPrediction: ChampionshipPrediction? {
        appEnvironment.liveSessionState.championshipPrediction
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let prediction = championshipPrediction {
                        VStack(alignment: .leading, spacing: 12) {
                            // Drivers Championship
                            DriversStandingsSection(prediction: prediction)
                            
                            Divider()
                            
                            // Constructors Championship
                            ConstructorsStandingsSection(prediction: prediction)
                        }
                    } else {
                        ContentUnavailableView(
                            "Championship Data Unavailable",
                            systemImage: "trophy",
                            description: Text("Championship predictions will appear here during a race session")
                        )
                        .frame(height: 400)
                    }
                }
                .padding()
            }
            .navigationTitle("Championship Standings")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if championshipPrediction != nil {
                        Menu {
                            Label("Based on current race positions", systemImage: "info.circle")
                                .disabled(true)
                        } label: {
                            Image(systemName: "info.circle")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Drivers Championship Section

struct DriversStandingsSection: View {
    let prediction: ChampionshipPrediction
    @Environment(AppEnvironment.self) private var appEnvironment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Drivers' Championship", systemImage: "person.2")
                .font(.headline)
            
            VStack(spacing: 4) {
                // Header
                HStack {
                    Text("Pos")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 30, alignment: .leading)
                    
                    Text("Driver")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Current")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 60, alignment: .trailing)
                    
                    Text("Predicted")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 70, alignment: .trailing)
                    
                    Text("Δ")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 40, alignment: .trailing)
                }
                .foregroundStyle(.secondary)
                
                Divider()
                
                // Driver rows
                ForEach(sortedDrivers, id: \.racingNumber) { driver in
                    DriverStandingRow(championshipDriver: driver)
                }
            }
        }
    }
    
    private var sortedDrivers: [ChampionshipDriver] {
        prediction.drivers.values.sorted { $0.predictedPosition < $1.predictedPosition }
    }
}

struct DriverStandingRow: View {
    let championshipDriver: ChampionshipDriver
    @Environment(AppEnvironment.self) private var appEnvironment
    
    private var driver: Driver? {
        appEnvironment.liveSessionState.driver(for: championshipDriver.racingNumber)
    }
    
    var body: some View {
        HStack {
            // Position
            Text("\(championshipDriver.predictedPosition)")
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 30, alignment: .leading)
            
            // Driver info
            if let driver = driver {
                HStack(spacing: 6) {
                    // Team color indicator
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: driver.teamColour) ?? .gray)
                        .frame(width: 3, height: 16)
                    
                    Text(driver.tla)
                        .font(.caption)
                        .fontWeight(.bold)
                    
                    Text(driver.lastName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("#\(championshipDriver.racingNumber)")
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Current points
            Text("\(championshipDriver.currentPoints)")
                .font(.caption)
                .frame(width: 60, alignment: .trailing)
            
            // Predicted points
            Text("\(championshipDriver.predictedPoints)")
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 70, alignment: .trailing)
            
            // Points delta
            let delta = championshipDriver.pointsDelta
            Text(delta > 0 ? "+\(delta)" : "\(delta)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(delta > 0 ? .green : delta < 0 ? .red : .secondary)
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Constructors Championship Section

struct ConstructorsStandingsSection: View {
    let prediction: ChampionshipPrediction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Constructors' Championship", systemImage: "car.2")
                .font(.headline)
            
            VStack(spacing: 4) {
                // Header
                HStack {
                    Text("Pos")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 30, alignment: .leading)
                    
                    Text("Team")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Current")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 60, alignment: .trailing)
                    
                    Text("Predicted")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 70, alignment: .trailing)
                    
                    Text("Δ")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 40, alignment: .trailing)
                }
                .foregroundStyle(.secondary)
                
                Divider()
                
                // Team rows
                ForEach(sortedTeams, id: \.teamName) { team in
                    TeamStandingRow(championshipTeam: team)
                }
            }
        }
    }
    
    private var sortedTeams: [ChampionshipTeam] {
        prediction.teams.values.sorted { $0.predictedPosition < $1.predictedPosition }
    }
}

struct TeamStandingRow: View {
    let championshipTeam: ChampionshipTeam
    
    var body: some View {
        HStack {
            // Position
            Text("\(championshipTeam.predictedPosition)")
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 30, alignment: .leading)
            
            // Team name
            Text(championshipTeam.teamName)
                .font(.caption)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Current points
            Text("\(championshipTeam.currentPoints)")
                .font(.caption)
                .frame(width: 60, alignment: .trailing)
            
            // Predicted points
            Text("\(championshipTeam.predictedPoints)")
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 70, alignment: .trailing)
            
            // Points delta
            let delta = championshipTeam.pointsDelta
            Text(delta > 0 ? "+\(delta)" : "\(delta)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(delta > 0 ? .green : delta < 0 ? .red : .secondary)
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    StandingsView()
        .environment(AppEnvironment())
        .frame(width: 500)
        .padding()
}