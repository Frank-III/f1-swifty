//
//  DebugRaceControlView.swift
//  F1-Dash
//
//  Debug view to check race control messages
//

import SwiftUI
import F1DashModels

struct DebugRaceControlView: View {
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @State private var rawData: String = ""
    @State private var decodedMessages: [RaceControlMessage] = []
    @State private var error: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Race Control Debug")
                .font(.largeTitle)
                .padding()
            
            // Connection Status
            HStack {
                Text("Connection:")
                Text(String(describing: appEnvironment.connectionStatus))
                    .foregroundColor(appEnvironment.connectionStatus == .connected ? .green : .red)
            }
            .padding(.horizontal)
            
            // State Dict Keys
            VStack(alignment: .leading) {
                Text("State Dict Keys:")
                    .font(.headline)
                ForEach(appEnvironment.liveSessionState.debugStateKeys, id: \.self) { key in
                    Text("• \(key)")
                        .font(.system(.body, design: .monospaced))
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
            
            // Raw Data
            VStack(alignment: .leading) {
                Text("Raw Race Control Data:")
                    .font(.headline)
                ScrollView {
                    Text(rawData.isEmpty ? "No data" : rawData)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 200)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
            
            // Decoded Messages
            VStack(alignment: .leading) {
                Text("Decoded Messages: \(decodedMessages.count)")
                    .font(.headline)
                
                if let error = error {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                }
                
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(decodedMessages, id: \.id) { message in
                            VStack(alignment: .leading) {
                                Text(message.message)
                                    .font(.headline)
                                Text("UTC: \(message.utc)")
                                    .font(.caption)
                                Text("Category: \(message.category.rawValue)")
                                    .font(.caption)
                            }
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                        }
                    }
                }
                .frame(height: 200)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
            
            // Actions
            HStack {
                Button("Refresh Data") {
                    fetchRawData()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Test Decode") {
                    testDecode()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            
            Spacer()
        }
        .onAppear {
            fetchRawData()
        }
    }
    
    private func fetchRawData() {
        // Access the state dict directly
        if let raceControlData = appEnvironment.liveSessionState.debugRawData(for: "raceControlMessages") {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: raceControlData, options: .prettyPrinted)
                rawData = String(data: jsonData, encoding: .utf8) ?? "Failed to convert to string"
            } catch {
                rawData = "Error serializing: \(error)"
            }
        } else {
            rawData = "No raceControlMessages key in state dict"
        }
    }
    
    private func testDecode() {
        guard let raceControlData = appEnvironment.liveSessionState.debugRawData(for: "raceControlMessages") else {
            error = "No raceControlMessages in state dict"
            return
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: raceControlData)
            let decoder = JSONDecoder()
            let messages = try decoder.decode(RaceControlMessages.self, from: jsonData)
            decodedMessages = messages.messages
            error = nil
        } catch {
            self.error = error.localizedDescription
            print("Decode error: \(error)")
        }
    }
}

// Extension removed - using dataState directly in OptimizedLiveSessionState

#Preview {
    DebugRaceControlView()
        .environment(OptimizedAppEnvironment())
        .frame(width: 600, height: 800)
}