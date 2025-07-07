//
//  RacePredictionSheetView.swift
//  F1-Dash
//
//  Race prediction and championship implications displayed as a sheet
//

import SwiftUI
import F1DashModels

struct RacePredictionSheetView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTab = 0
    
    private var prediction: ChampionshipPrediction? {
        appEnvironment.liveSessionState.championshipPrediction
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let prediction = prediction {
                    // Tab selector
                    Picker("View", selection: $selectedTab) {
                        Text("Drivers").tag(0)
                        Text("Constructors").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // Content
                    ScrollView {
                        if selectedTab == 0 {
                            DriversChampionshipPrediction(drivers: prediction.drivers)
                        } else {
                            ConstructorsChampionshipPrediction(teams: prediction.teams)
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "No Predictions Available",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Championship predictions will appear during a race session")
                    )
                }
            }
            .navigationTitle("Championship Predictions")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Drivers Championship Prediction

struct DriversChampionshipPrediction: View {
    let drivers: [String: ChampionshipDriver]
    
    private var sortedDrivers: [(String, ChampionshipDriver)] {
        drivers.sorted { $0.value.predictedPosition < $1.value.predictedPosition }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Summary card
            PredictionSummaryCard(
                title: "Race Impact",
                subtitle: "How current positions affect the championship"
            )
            
            // Driver predictions
            LazyVStack(spacing: 12) {
                ForEach(sortedDrivers, id: \.0) { driverNumber, prediction in
                    DriverPredictionRow(
                        driverNumber: driverNumber,
                        prediction: prediction
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

// MARK: - Constructors Championship Prediction

struct ConstructorsChampionshipPrediction: View {
    let teams: [String: ChampionshipTeam]
    
    private var sortedTeams: [(String, ChampionshipTeam)] {
        teams.sorted { $0.value.predictedPosition < $1.value.predictedPosition }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Summary card
            PredictionSummaryCard(
                title: "Constructor Impact",
                subtitle: "How current positions affect team standings"
            )
            
            // Team predictions
            LazyVStack(spacing: 12) {
                ForEach(sortedTeams, id: \.0) { teamKey, prediction in
                    TeamPredictionRow(
                        teamKey: teamKey,
                        prediction: prediction
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

// MARK: - Prediction Summary Card

struct PredictionSummaryCard: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.blue)
                Text(title)
                    .font(.headline)
            }
            
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text("Predictions are based on current race positions and assume they finish as is.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .italic()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.blue.opacity(0.1))
        .modifier(PlatformGlassCardModifier())
        .padding(.horizontal)
    }
}

// MARK: - Driver Prediction Row

struct DriverPredictionRow: View {
    let driverNumber: String
    let prediction: ChampionshipDriver
    @Environment(AppEnvironment.self) private var appEnvironment
    
    private var driverInfo: Driver? {
        appEnvironment.liveSessionState.driverList[driverNumber]
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Position indicator
            VStack(spacing: 4) {
                Text("P\(prediction.predictedPosition)")
                    .font(.title3)
                    .fontWeight(.bold)
                
                if prediction.positionChange != 0 {
                    HStack(spacing: 2) {
                        Image(systemName: prediction.positionChange < 0 ? "arrow.up" : "arrow.down")
                            .font(.caption2)
                        Text("\(abs(prediction.positionChange))")
                            .font(.caption)
                    }
                    .foregroundStyle(prediction.positionChange < 0 ? .green : .red)
                }
            }
            .frame(width: 50)
            
            // Driver info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if let teamColour = driverInfo?.teamColour,
                       let color = Color(hex: teamColour) {
                        Circle()
                            .fill(color)
                            .frame(width: 8, height: 8)
                    }
                    
                    Text(driverInfo?.broadcastName ?? "#\(driverNumber)")
                        .font(.body)
                        .fontWeight(.medium)
                }
                
                Text(driverInfo?.teamName ?? "Unknown Team")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Points info
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(prediction.predictedPoints) pts")
                    .font(.body)
                    .fontWeight(.medium)
                
                if prediction.pointsDelta != 0 {
                    Text("\(prediction.pointsDelta > 0 ? "+" : "")\(prediction.pointsDelta)")
                        .font(.caption)
                        .foregroundStyle(prediction.pointsDelta > 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(Color.platformBackground)
        .modifier(PlatformGlassCardModifier())
    }
}

// MARK: - Team Prediction Row

struct TeamPredictionRow: View {
    let teamKey: String
    let prediction: ChampionshipTeam
    @Environment(AppEnvironment.self) private var appEnvironment
    
    private var teamColor: Color? {
        // Find team color from any driver
        for driver in appEnvironment.liveSessionState.driverList.values {
            if driver.teamName == prediction.teamName {
                if let color = Color(hex: driver.teamColour) {
                    return color
                }
            }
        }
        return nil
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Position indicator
            VStack(spacing: 4) {
                Text("P\(prediction.predictedPosition)")
                    .font(.title3)
                    .fontWeight(.bold)
                
                if prediction.positionChange != 0 {
                    HStack(spacing: 2) {
                        Image(systemName: prediction.positionChange < 0 ? "arrow.up" : "arrow.down")
                            .font(.caption2)
                        Text("\(abs(prediction.positionChange))")
                            .font(.caption)
                    }
                    .foregroundStyle(prediction.positionChange < 0 ? .green : .red)
                }
            }
            .frame(width: 50)
            
            // Team info
            HStack {
                if let color = teamColor {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                }
                
                Text(prediction.teamName)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            // Points info
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(prediction.predictedPoints) pts")
                    .font(.body)
                    .fontWeight(.medium)
                
                if prediction.pointsDelta != 0 {
                    Text("\(prediction.pointsDelta > 0 ? "+" : "")\(prediction.pointsDelta)")
                        .font(.caption)
                        .foregroundStyle(prediction.pointsDelta > 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(Color.platformBackground)
        .modifier(PlatformGlassCardModifier())
    }
}

#Preview {
    RacePredictionSheetView()
        .environment(AppEnvironment())
}
