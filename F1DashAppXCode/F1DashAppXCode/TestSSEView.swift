//
//  TestSSEView.swift
//  F1DashAppXCode
//
//  Test view for SSE connection debugging
//

import SwiftUI
import F1DashModels

struct TestSSEView: View {
    @State private var sseClient = SSEClient()
    @State private var isConnected = false
    @State private var messageCount = 0
    @State private var lastMessage = "No messages yet"
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("SSE Test View")
                .font(.largeTitle)
            
            HStack {
                Circle()
                    .fill(isConnected ? Color.green : Color.red)
                    .frame(width: 20, height: 20)
                Text(isConnected ? "Connected" : "Disconnected")
            }
            
            Text("Messages received: \(messageCount)")
            
            Text("Last message: \(lastMessage)")
                .font(.caption)
                .lineLimit(3)
            
            if !errorMessage.isEmpty {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
            
            HStack(spacing: 20) {
                Button("Connect") {
                    Task {
                        await connect()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Disconnect") {
                    Task {
                        await disconnect()
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
        }
        .padding()
        .task {
            // Auto-connect when view appears
            await connect()
        }
    }
    
    private func connect() async {
        do {
            print("TestSSEView: Connecting...")
            errorMessage = ""
            
            try await sseClient.connect()
            isConnected = true
            
            print("TestSSEView: Starting message listener")
            
            // Listen for messages
            Task {
                for await message in await sseClient.messages {
                    await MainActor.run {
                        messageCount += 1
                        
                        switch message {
                        case .initial(let data):
                            lastMessage = "Initial: \(data.count) keys - \(Array(data.keys.prefix(5)))"
                            print("TestSSEView: Got initial state")
                            
                        case .update(let data):
                            lastMessage = "Update: \(data.keys)"
                            print("TestSSEView: Got update")
                        case .error(_):
                            print("TestSSEView: Failure")
                        }
                    }
                }
                
                // Stream ended
                await MainActor.run {
                    isConnected = false
                    print("TestSSEView: Message stream ended")
                }
            }
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isConnected = false
                print("TestSSEView: Connection error: \(error)")
            }
        }
    }
    
    private func disconnect() async {
        print("TestSSEView: Disconnecting...")
        await sseClient.disconnect()
        isConnected = false
        messageCount = 0
    }
}
