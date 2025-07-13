//
//  FavoriteDriversView.swift
//  F1DashAppXCode
//
//  View for selecting favorite drivers
//

import SwiftUI
import F1DashModels

struct FavoriteDriversView: View {
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @State private var drivers: [Driver] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
  
    var settings: SettingsStore {
      appEnvironment.settingsStore
    }
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading drivers...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                VStack(spacing: 16) {
                    Text("Error loading drivers")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button("Retry") {
                        Task {
                            await fetchDrivers()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(drivers) { driver in
                        DriverRow(driver: driver, settings: settings)
                    }
                }
            }
        }
        .navigationTitle("Favorite Drivers")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .task {
            await fetchDrivers()
        }
    }
    
    private func fetchDrivers() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let url = URL(string: "https://api.openf1.org/v1/drivers?session_key=latest") else {
                throw URLError(.badURL)
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let apiDrivers = try JSONDecoder().decode([OpenF1Driver].self, from: data)
            
            let convertedDrivers = apiDrivers.compactMap { apiDriver -> Driver? in
                guard let fullName = apiDriver.full_name,
                      let firstName = apiDriver.first_name,
                      let lastName = apiDriver.last_name,
                      let teamName = apiDriver.team_name,
                      let teamColour = apiDriver.team_colour,
                      let tla = apiDriver.name_acronym else {
                    return nil
                }
                
                return Driver(
                    racingNumber: "\(apiDriver.driver_number)",
                    broadcastName: apiDriver.broadcast_name ?? fullName,
                    fullName: fullName,
                    tla: tla,
                    line: 0,
                    teamName: teamName,
                    teamColour: teamColour,
                    firstName: firstName,
                    lastName: lastName,
                    reference: tla.lowercased(),
                    headshotUrl: apiDriver.headshot_url,
                    countryCode: apiDriver.country_code ?? ""
                )
            }
            
            await MainActor.run {
                self.drivers = convertedDrivers.sorted { Int($0.racingNumber) ?? 0 < Int($1.racingNumber) ?? 0 }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

struct DriverRow: View {
    let driver: Driver
    let settings: SettingsStore
    
    var body: some View {
        HStack {
            // Driver headshot
            if let headshotUrl = driver.headshotUrl, let url = URL(string: headshotUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(driver.tla)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        )
                }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(driver.tla)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("#\(driver.racingNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 40, alignment: .leading)
                    
                    Text(driver.fullName)
                        .font(.headline)
                }
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(hex: driver.teamColour)!)
                        .frame(width: 10, height: 10)
                    
                    Text(driver.teamName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { settings.isFavoriteDriver(driver.tla) },
                set: { _ in settings.toggleFavoriteDriver(driver.tla) }
            ))
            .toggleStyle(SwitchToggleStyle())
        }
        .padding(.vertical, 4)
    }
}

// OpenF1 API response model
private struct OpenF1Driver: Codable {
    let meeting_key: Int?
    let session_key: Int?
    let driver_number: Int
    let broadcast_name: String?
    let full_name: String?
    let name_acronym: String?
    let team_name: String?
    let team_colour: String?
    let first_name: String?
    let last_name: String?
    let headshot_url: String?
    let country_code: String?
}

#Preview {
    NavigationStack {
        FavoriteDriversView()
            .environment(SettingsStore())
    }
}
