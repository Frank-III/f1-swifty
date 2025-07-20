import F1DashModels
import Foundation
import Logging
import ServiceLifecycle
import SignalRClient

/// Actor responsible for managing the SignalR connection to F1 live timing
public actor SignalRClientActor: Service {

  // MARK: - Configuration

  private let f1BaseURL = "https://livetiming.formula1.com/signalr"

  private let subscriptionTopics = [
    "Heartbeat",
    "CarData.z",
    "Position.z",
    "ExtrapolatedClock",
    "TopThree",
    "RcmSeries",
    "TimingStats",
    "TimingAppData",
    "WeatherData",
    "TrackStatus",
    "SessionStatus",
    "DriverList",
    "RaceControlMessages",
    "SessionInfo",
    "SessionData",
    "LapCount",
    "TimingData",
    "TeamRadio",
    "PitLaneTimeCollection",
    "ChampionshipPrediction",
  ]

  // MARK: - State

  private var hubConnection: HubConnection?
  private let logger = Logger(label: "SignalRClientActor")
  private var connectionState: ConnectionState = .disconnected
  private var retryCount = 0
  private let maxRetries = 10
  private var retryTask: Task<Void, Never>?
  private var simulationTask: Task<Void, Never>?
  private var messageHandler: (@Sendable (RawMessage) async -> Void)?

  // Service configuration
  private let simulationFile: String?

  public init(simulationFile: String? = nil) {
    self.simulationFile = simulationFile
  }

  // MARK: - Types

  enum ConnectionState {
    case disconnected
    case connecting
    case connected
    case reconnecting
    case failed
  }

  struct ConnectionError: Error {
    let message: String
  }

  // MARK: - Lifecycle

  deinit {
    simulationTask?.cancel()
    retryTask?.cancel()
  }

  // MARK: - Service Protocol

  public func run() async throws {
    logger.info("SignalRClientActor service started")

    // Start connection based on mode
    let connectionTask = Task {
      do {
        if let simulationFile = simulationFile {
          let fileURL = URL(fileURLWithPath: simulationFile)
          try await connectSimulation(logFile: fileURL)
        } else {
          try await connect()
        }
      } catch {
        logger.error("Failed to establish connection: \(error)")
      }
    }

    // Keep the service running until cancelled
    try await withTaskCancellationHandler {
      while !Task.isCancelled {
        try await Task.sleep(for: .seconds(60))
      }
    } onCancel: {
      connectionTask.cancel()
      Task {
        logger.info("SignalRClientActor service stopping")
        await self.disconnect()
      }
    }

    logger.info("SignalRClientActor service stopped")
  }

  // MARK: - Public Interface

  /// Set the message handler for incoming data
  func setMessageHandler(_ handler: @escaping @Sendable (RawMessage) async -> Void) {
    messageHandler = handler
  }

  /// Start the SignalR connection
  func connect() async throws {
    guard connectionState != .connecting && connectionState != .connected else {
      logger.warning("Already connecting or connected")
      return
    }

    connectionState = .connecting
    logger.info("Starting SignalR connection to F1 live timing")

    do {
      try await performConnection()
      connectionState = .connected
      retryCount = 0
      logger.info("Successfully connected to F1 live timing")
    } catch {
      connectionState = .failed
      logger.error("Failed to connect: \(error)")

      // Schedule retry
      await scheduleReconnect()
      throw error
    }
  }

  /// Disconnect from SignalR
  func disconnect() async {
    logger.info("Disconnecting from F1 live timing")

    retryTask?.cancel()
    retryTask = nil

    simulationTask?.cancel()
    simulationTask = nil

    await hubConnection?.stop()
    hubConnection = nil
    connectionState = .disconnected
  }

  /// Get current connection state
  var isConnected: Bool {
    connectionState == .connected
  }

  /// Set connection state (used by simulation task)
  private func setConnectionState(_ state: ConnectionState) {
    connectionState = state
  }

  // MARK: - Private Implementation

  private func performConnection() async throws {
    // Create hub connection with the correct builder pattern
    let connection = HubConnectionBuilder()
      .withUrl(url: f1BaseURL)
      .withAutomaticReconnect()
      .build()

    hubConnection = connection

    try await setupEventHandlers(connection)
    // Start connection
    try await connection.start()

    // Subscribe to F1 data topics
    try await subscribeToTopics(connection)
  }

  private func setupEventHandlers(_ connection: HubConnection) async throws {
    // Handle connection closed
    await connection.onClosed { [weak self] error in
      await self?.handleConnectionClosed(error: error)
    }
    //        // Handle reconnecting
    await connection.onReconnecting { [weak self] error in
      await self?.handleReconnecting(error: error)
    }
    //        // Handle reconnected
    await connection.onReconnected { [weak self] in
      await self?.handleReconnected()
    }

    // Register handlers for each F1 data topic
    try await setupF1MessageHandlers(connection)
  }

  private func setupF1MessageHandlers(_ connection: HubConnection) async throws {
    // Register handlers for each subscription topic
    for topic in subscriptionTopics {
      await connection.on(topic) { [weak self] (data: String, timestamp: String) in
        await self?.handleMessage(topic: topic, data: data, timestamp: timestamp)
      }
    }

    // Also handle generic feed messages if they exist
    await connection.on("feed") { [weak self] (topic: String, data: String, timestamp: String) in
      await self?.handleMessage(topic: topic, data: data, timestamp: timestamp)
    }
  }

  private func subscribeToTopics(_ connection: HubConnection) async throws {
    logger.info("Subscribing to F1 data topics")

    // Use invoke method to subscribe to topics
    try await connection.invoke(method: "Subscribe", arguments: subscriptionTopics)

    logger.info("Successfully subscribed to \(subscriptionTopics.count) topics")
  }

  private func handleMessage(topic: String, data: String, timestamp: String) async {
    guard let messageHandler = messageHandler else { return }

    let rawMessage = RawMessage(
      topic: topic,
      data: Data(data.utf8),
      timestamp: Date()
    )

    await messageHandler(rawMessage)
  }

  private func handleConnectionClosed(error: (any Error)?) async {
    logger.warning("SignalR connection closed: \(error?.localizedDescription ?? "unknown reason")")

    if connectionState == .connected {
      connectionState = .disconnected
      await scheduleReconnect()
    }
  }

  private func handleReconnecting(error: (any Error)?) async {
    logger.info("SignalR connection reconnecting")
    connectionState = .reconnecting
  }

  private func handleReconnected() async {
    logger.info("SignalR connection reconnected")
    connectionState = .connected
    retryCount = 0

    // Re-subscribe to topics after reconnection
    if let connection = hubConnection {
      do {
        try await subscribeToTopics(connection)
      } catch {
        logger.error("Failed to re-subscribe after reconnection: \(error)")
      }
    }
  }

  private func scheduleReconnect() async {
    guard retryCount < maxRetries else {
      logger.error("Max retries reached, giving up")
      connectionState = .failed
      return
    }

    retryCount += 1
    let delay = min(pow(2.0, Double(retryCount)), 30.0)  // Exponential backoff, max 30s

    logger.info("Scheduling reconnect attempt \(retryCount)/\(maxRetries) in \(delay)s")

    retryTask?.cancel()
    retryTask = Task {
      try? await Task.sleep(for: .seconds(delay))

      guard !Task.isCancelled else { return }

      do {
        try await connect()
      } catch {
        logger.error("Reconnect attempt failed: \(error)")
      }
    }
  }
}

// MARK: - Simulation Support

extension SignalRClientActor {
  /// Connect in simulation mode using a log file
  func connectSimulation(logFile: URL) async throws {
    guard connectionState != .connecting && connectionState != .connected else {
      logger.warning("Already connecting or connected")
      return
    }

    connectionState = .connecting
    logger.info("Starting simulation mode with log file: \(logFile.path)")

    // Start reading from log file
    try await startSimulation(logFile: logFile)

    // Note: simulation runs in background, we don't wait for it
    connectionState = .connected
    logger.info("Simulation mode started successfully")
  }

  private func startSimulation(logFile: URL) async throws {
    let fileHandle = try FileHandle(forReadingFrom: logFile)
    defer { fileHandle.closeFile() }

    // Read file line by line
    let data = fileHandle.readDataToEndOfFile()
    let content = String(data: data, encoding: .utf8) ?? ""
    let lines = content.components(separatedBy: .newlines)

    logger.info("Loaded \(lines.count) lines from simulation file")

    // Start background task to replay messages
    simulationTask = Task { [weak self] in
      guard let self = self else { return }

      for line in lines {
        // Check cancellation before processing each line
        if Task.isCancelled {
          logger.info("Simulation task cancelled")
          break
        }

        guard !line.isEmpty else { continue }

        // Parse the SignalR message format
        guard let lineData = line.data(using: .utf8),
          let json = try? JSONSerialization.jsonObject(with: lineData) as? [String: Any]
        else {
          logger.warning("Failed to parse simulation line as JSON")
          continue
        }

        // Handle initial state messages (R field)
        if let initialData = json["R"] as? [String: Any] {
          // Send the entire initial state as one message for simulation
          let message: [String: Any] = ["R": initialData]
          if let messageData = try? JSONSerialization.data(withJSONObject: message) {
            let rawMessage = RawMessage(
              topic: "simulation",  // Special topic for full state
              data: messageData,
              timestamp: Date()
            )
            await messageHandler?(rawMessage)
          }
        }

        // Handle update messages (M field)
        if let updates = json["M"] as? [[String: Any]] {
          // Create a message in the format DataProcessingActor expects
          let message: [String: Any] = ["M": updates]
          if let messageData = try? JSONSerialization.data(withJSONObject: message) {
            let rawMessage = RawMessage(
              topic: "updates",
              data: messageData,
              timestamp: Date()
            )
            await messageHandler?(rawMessage)
          }
        }

        // Add realistic delay between messages
        do {
          try await Task.sleep(for: .milliseconds(100))
        } catch {
          // Task was cancelled during sleep
          logger.info("Simulation task cancelled during sleep")
          break
        }
      }

      logger.info("Simulation playback completed")
      await self.setConnectionState(.disconnected)
    }
  }
}
