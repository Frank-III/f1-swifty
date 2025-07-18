//
//  StandingsView.swift
//  F1-Dash
//
//  Live Championship Standings View
//

import SwiftUI
import F1DashModels

struct StandingsView: View {
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @State private var driverStandings: DriverStandingsResponse?
    @State private var teamStandings: TeamStandingsResponse?
    @State private var isLoadingStandings = false
    @State private var standingsError: String?
    
    private var championshipPrediction: ChampionshipPrediction? {
        appEnvironment.liveSessionState.championshipPrediction
    }
    
    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let prediction = championshipPrediction {
                        // Show live championship prediction during race
                        VStack(alignment: .leading, spacing: 12) {
                            // Drivers Championship
                            DriversStandingsSection(prediction: prediction)
                            
                            Divider()
                            
                            // Constructors Championship
                            ConstructorsStandingsSection(prediction: prediction)
                        }
                    } else if let drivers = driverStandings, let teams = teamStandings {
                        // Show current standings when no live prediction
                        VStack(alignment: .leading, spacing: 12) {
                            // Current Drivers Standings
                            CurrentDriversStandingsSection(standings: drivers)
                            
                            Divider()
                            
                            // Current Teams Standings
                            CurrentTeamsStandingsSection(standings: teams)
                        }
                    } else if isLoadingStandings {
                        VStack {
                            ProgressView("Loading standings...")
                                .progressViewStyle(CircularProgressViewStyle())
                            Text("Fetching current championship standings")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else if let error = standingsError {
                        ContentUnavailableView {
                            Label("Unable to Load Standings", systemImage: "exclamationmark.triangle")
                        } description: {
                            Text(error)
                        } actions: {
                            Button("Retry") {
                                Task {
                                    await fetchStandings()
                                }
                            }
                        }
                    } else {
                        ContentUnavailableView(
                            "Championship Data Unavailable",
                            systemImage: "trophy",
                            description: Text("Championship standings will appear here")
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
                    } else if driverStandings != nil {
                        Menu {
                            Label("Current \(currentYear) standings", systemImage: "info.circle")
                                .disabled(true)
                        } label: {
                            Image(systemName: "calendar")
                        }
                    }
                }
            }
        }
        .task {
            // Only fetch standings if no live prediction available
            if championshipPrediction == nil {
                await fetchStandings()
            }
        }
    }
    
    private func fetchStandings() async {
        guard championshipPrediction == nil else { return }
        
        isLoadingStandings = true
        standingsError = nil
        
        do {
            async let drivers = fetchDriverStandings()
            async let teams = fetchTeamStandings()
            
            let (driverResult, teamResult) = try await (drivers, teams)
            
            self.driverStandings = driverResult
            self.teamStandings = teamResult
            
        } catch {
            standingsError = "Failed to load standings: \(error.localizedDescription)"
        }
        
        isLoadingStandings = false
    }
    
    private func fetchDriverStandings() async throws -> DriverStandingsResponse {
        let url = URL(string: "\(appEnvironment.settingsStore.serverURL)/api/standings/drivers/\(currentYear)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DriverStandingsResponse.self, from: data)
    }
    
    private func fetchTeamStandings() async throws -> TeamStandingsResponse {
        let url = URL(string: "\(appEnvironment.settingsStore.serverURL)/api/standings/teams/\(currentYear)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(TeamStandingsResponse.self, from: data)
    }
}

// MARK: - Drivers Championship Section

struct DriversStandingsSection: View {
    let prediction: ChampionshipPrediction
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
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
    // @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
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

// MARK: - Current Standings Sections

struct CurrentDriversStandingsSection: View {
    let standings: DriverStandingsResponse
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
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
                    
                    Text("Team")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 100, alignment: .leading)
                    
                    Text("Points")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 60, alignment: .trailing)
                    
                    Text("Wins")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 40, alignment: .trailing)
                }
                .foregroundStyle(.secondary)
                
                Divider()
                
                // Driver rows
                ForEach(standings.standings, id: \.position) { standing in
                    CurrentDriverStandingRow(standing: standing)
                }
            }
        }
    }
}

struct CurrentDriverStandingRow: View {
    let standing: DriverStanding
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    
    private var driver: Driver? {
        // Try to match driver by name
        appEnvironment.liveSessionState.driverList.values.first { driver in
            standing.driverName.contains(driver.lastName) ||
            standing.driverName.contains(driver.fullName)
        }
    }
    
    var body: some View {
        HStack {
            // Position
            Text("\(standing.position)")
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 30, alignment: .leading)
            
            // Driver info
            HStack(spacing: 6) {
                if let driver = driver {
                    // Team color indicator
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: driver.teamColour) ?? .gray)
                        .frame(width: 3, height: 16)
                    
                    Text(driver.tla)
                        .font(.caption)
                        .fontWeight(.bold)
                } else if let code = standing.driverCode {
                    Text(code)
                        .font(.caption)
                        .fontWeight(.bold)
                }
                
                Text(standing.driverName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Team
            Text(standing.teamName)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(width: 100, alignment: .leading)
            
            // Points
            Text("\(Int(standing.points))")
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 60, alignment: .trailing)
            
            // Wins
            Text("\(standing.wins)")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }
}

struct CurrentTeamsStandingsSection: View {
    let standings: TeamStandingsResponse
    
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
                    
                    Text("Points")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 60, alignment: .trailing)
                }
                .foregroundStyle(.secondary)
                
                Divider()
                
                // Team rows
                ForEach(standings.standings, id: \.position) { standing in
                    CurrentTeamStandingRow(standing: standing)
                }
            }
        }
    }
}

struct CurrentTeamStandingRow: View {
    let standing: TeamStanding
    
    var body: some View {
        HStack {
            // Position
            Text("\(standing.position)")
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 30, alignment: .leading)
            
            // Team name
            Text(standing.teamName)
                .font(.caption)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Points
            Text("\(Int(standing.points))")
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Response Models

struct DriverStandingsResponse: Codable {
    let year: Int
    let standings: [DriverStanding]
}

struct DriverStanding: Codable {
    let position: Int
    let driverName: String
    let driverCode: String?
    let teamName: String
    let points: Double
    let wins: Int
}

struct TeamStandingsResponse: Codable {
    let year: Int
    let standings: [TeamStanding]
}

struct TeamStanding: Codable {
    let position: Int
    let teamName: String
    let points: Double
}

#Preview {
    StandingsView()
        .environment(AppEnvironment())
        .frame(width: 500)
        .padding()
}
