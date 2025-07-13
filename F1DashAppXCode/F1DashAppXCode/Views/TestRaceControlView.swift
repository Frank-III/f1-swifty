//
//  TestRaceControlView.swift
//  F1-Dash
//
//  Test view to debug race control messages
//

import SwiftUI
import F1DashModels

struct TestRaceControlView: View {
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @State private var isConnecting = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Race Control Test")
                .font(.largeTitle)
            
            // Connection status
            HStack {
                Circle()
                    .fill(connectionColor)
                    .frame(width: 10, height: 10)
                Text("Status: \(String(describing: appEnvironment.connectionStatus))")
            }
            
            // Connect button
            Button(action: {
                Task {
                    isConnecting = true
                    await appEnvironment.connect()
                    isConnecting = false
                }
            }) {
                if isConnecting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                } else {
                    Text("Connect to SSE")
                }
            }
            .disabled(appEnvironment.connectionStatus == .connected || isConnecting)
            .buttonStyle(.borderedProminent)
            
            // State keys
            VStack(alignment: .leading) {
                Text("State Keys:")
                    .font(.headline)
                ForEach(appEnvironment.liveSessionState.debugStateKeys, id: \.self) { key in
                    Text("• \(key)")
                        .font(.system(.caption, design: .monospaced))
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Race control messages
            if let messages = appEnvironment.liveSessionState.raceControlMessages {
                VStack(alignment: .leading) {
                    Text("Race Control Messages: \(messages.messages.count)")
                        .font(.headline)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(messages.messages.prefix(10), id: \.id) { message in
                                VStack(alignment: .leading) {
                                    Text(message.message)
                                        .font(.system(.body, weight: .medium))
                                    Text(message.utc)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(4)
                            }
                        }
                    }
                    .frame(maxHeight: 300)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            } else {
                Text("No race control messages")
                    .foregroundColor(.secondary)
                    .padding()
            }
            
            // Actual RaceControlView
            Divider()
            Text("Actual RaceControlView:")
                .font(.headline)
            RaceControlView()
                .frame(height: 250)
            
            Spacer()
        }
        .padding()
        .frame(width: 500, height: 800)
    }
    
    private var connectionColor: Color {
        switch appEnvironment.connectionStatus {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .red
//        case .error: return .red
        }
    }
}

#Preview {
    TestRaceControlView()
        .environment(OptimizedAppEnvironment())
}
