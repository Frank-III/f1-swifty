import F1DashModels
import F1DashPersistence
import Foundation
import Hummingbird
import HummingbirdWSCompression
import HummingbirdWebSocket
import Logging
import ServiceLifecycle

/// Build and configure the Hummingbird application for F1-Dash Server
func buildApplication(_ arguments: some AppArguments) async throws -> some ApplicationProtocol {
  // MARK: Logging
  let level: Logger.Level =
    switch arguments.logLevel.lowercased() {
    case "trace": .trace
    case "debug": .debug
    case "info": .info
    case "warning": .warning
    case "error": .error
    case "critical": .critical
    default: .info
    }
  LoggingSystem.bootstrap { label in
    var handler = StreamLogHandler.standardOutput(label: label)
    handler.logLevel = level
    return handler
  }
  let logger = Logger(label: "F1DashServer")
  logger.info("Starting F1-Dash Server v1.0.0")
  logger.info("Host: \(arguments.host), Port: \(arguments.port)")
  if let sim = arguments.simulate {
    logger.info("Simulation mode with file: \(sim)")
  } else {
    logger.info("Live mode")
  }
  if arguments.development {
    logger.info("Development mode enabled")
  }
  if arguments.persistence {
    logger.info("Database persistence enabled")
  }

  // MARK: - Core Services
  let sessionStateCache = SessionStateCache(enablePersistence: arguments.persistence)
  let dataProcessor = DataProcessingActor()
  let signalRClient = SignalRClientActor()
  let connectionManager = ConnectionManager()

  // Wire up data pipeline
  await setupDataPipeline(
    signalRClient: signalRClient,
    dataProcessor: dataProcessor,
    sessionStateCache: sessionStateCache,
    connectionManager: connectionManager
  )

  // Start data connection
  if let sim = arguments.simulate {
    let fileURL = URL(fileURLWithPath: sim)
    try await signalRClient.connectSimulation(logFile: fileURL)
  } else {
    try await signalRClient.connect()
  }

  // MARK: - HTTP & WebSocket Routing
  let router = Router(context: BasicRequestContext.self)
  router.addMiddleware {
    // CORS
    CORSMiddleware(
      allowOrigin: .originBased,
      allowHeaders: [.accept, .authorization, .contentType, .origin],
      allowMethods: [.get, .post, .options]
    )
    // Request logging
    LogRequestsMiddleware(.info)
    // Error handling
    //        ErrorMiddleware()
  }
  // REST API
  APIRouter.addRoutes(to: router, sessionStateCache: sessionStateCache)
  // WebSocket endpoint for live F1 data
  let wsRouter = Router(context: BasicWebSocketRequestContext.self)
  wsRouter.add(middleware: LogRequestsMiddleware(.debug))

  wsRouter.addWebSocketRoute(sessionStateCache: sessionStateCache)

  // MARK: - Application & Services
  var app = Application(
    router: router,
    server: .http1WebSocketUpgrade(
      webSocketRouter: wsRouter, configuration: .init(extensions: [.perMessageDeflate()])),
    configuration: .init(
      address: .hostname(arguments.host, port: arguments.port),
      serverName: "F1DashServer/1.0.0"
    ),
    logger: logger
  )
  app.addServices(connectionManager)
  if arguments.persistence {
    app.addServices(DatabaseManager.shared)
  }
  return app
}

// MARK: - Helper Functions

/// Connect SignalRClientActor → DataProcessingActor → SessionStateCache → ConnectionManager
private func setupDataPipeline(
  signalRClient: SignalRClientActor,
  dataProcessor: DataProcessingActor,
  sessionStateCache: SessionStateCache,
  connectionManager: ConnectionManager
) async {
  await dataProcessor.setStateUpdateHandler { stateUpdate in
    await sessionStateCache.applyUpdate(stateUpdate)
  }
  await signalRClient.setMessageHandler { rawMessage in
    // Process for state
    await dataProcessor.processMessage(rawMessage)
    // Broadcast raw to WS clients
    await connectionManager.broadcastRawMessage(rawMessage)
  }
}
