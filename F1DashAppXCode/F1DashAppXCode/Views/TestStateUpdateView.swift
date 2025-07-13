//
//  TestStateUpdateView.swift
//  F1-Dash
//
//  Test view to verify state updates are working
//

import SwiftUI
import F1DashModels

struct TestStateUpdateView: View {
    @Environment(OptimizedAppEnvironment.self) private var appEnvironment
    @State private var timer: Timer?
    @State private var updateCount = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("State Update Test")
                .font(.largeTitle)
            
            Text("Update count: \(updateCount)")
                .font(.title2)
            
            // Direct state access
            VStack(alignment: .leading, spacing: 10) {
                Text("Direct State Access:")
                    .font(.headline)
                
                Text("State keys: \(appEnvironment.liveSessionState.debugStateKeys.joined(separator: ", "))")
                    .font(.system(.caption, design: .monospaced))
                
                if let rawData = appEnvironment.liveSessionState.debugRawData(for: "raceControlMessages") {
                    Text("raceControlMessages exists: YES")
                        .foregroundColor(.green)
                    
                    if let dict = rawData as? [String: Any] {
                        Text("Dict keys: \(dict.keys.joined(separator: ", "))")
                            .font(.system(.caption, design: .monospaced))
                        
                        // Check what's in the messages key
                        if let messages = dict["messages"] {
                            Text("Messages type: \(String(describing: type(of: messages)))")
                                .font(.system(.caption, design: .monospaced))
                            
                            if let messagesArray = messages as? [[String: Any]] {
                                Text("Messages array count: \(messagesArray.count)")
                                    .foregroundColor(.green)
                            } else if let messagesDict = messages as? [String: Any] {
                                Text("Messages dict count: \(messagesDict.count)")
                                    .foregroundColor(.yellow)
                            } else {
                                Text("Messages is unknown type")
                                    .foregroundColor(.red)
                            }
                        } else {
                            Text("No 'messages' key in dict")
                                .foregroundColor(.red)
                        }
                    }
                } else {
                    Text("raceControlMessages exists: NO")
                        .foregroundColor(.red)
                }
                
                if let messages = appEnvironment.liveSessionState.raceControlMessages {
                    Text("Decoded messages count: \(messages.messages.count)")
                        .foregroundColor(.blue)
                } else {
                    Text("Failed to decode messages")
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            HStack {
                Button("Force Update") {
                    updateCount += 1
                    // Access the computed property to trigger any caching
                    _ = appEnvironment.liveSessionState.raceControlMessages
                }
                .buttonStyle(.borderedProminent)
                
                Button("Print Raw JSON") {
                    if let rawData = appEnvironment.liveSessionState.debugRawData(for: "raceControlMessages") {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: rawData, options: .prettyPrinted)
                            if let jsonString = String(data: jsonData, encoding: .utf8) {
                                print("=== RAW RACE CONTROL DATA ===")
                                print(jsonString)
                                print("=== END RAW DATA ===")
                            }
                        } catch {
                            print("Error converting to JSON: \(error)")
                        }
                    } else {
                        print("No raceControlMessages in state")
                    }
                }
                .buttonStyle(.bordered)
                
                Button("Test Decode") {
                    if let rawData = appEnvironment.liveSessionState.debugRawData(for: "raceControlMessages") {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: rawData)
                            let decoder = JSONDecoder()
                            let decoded = try decoder.decode(RaceControlMessages.self, from: jsonData)
                            print("Manual decode SUCCESS: \(decoded.messages.count) messages")
                        } catch {
                            print("Manual decode FAILED: \(error)")
                            
                            // Try to decode just the structure
                            if let dict = rawData as? [String: Any],
                               let messages = dict["messages"] as? [[String: Any]],
                               let firstMessage = messages.first {
                                print("First message structure:")
                                print("Keys: \(firstMessage.keys.sorted())")
                                for (key, value) in firstMessage {
                                    print("  \(key): \(type(of: value)) = \(value)")
                                }
                            }
                        }
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            // Set up a timer to check for updates
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                updateCount += 1
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}

#Preview {
    TestStateUpdateView()
        .environment(OptimizedAppEnvironment())
        .frame(width: 400, height: 600)
}