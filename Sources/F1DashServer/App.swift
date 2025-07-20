import ArgumentParser
import Hummingbird

/// Arguments for F1-Dash Server application
protocol AppArguments {
  var host: String { get }
  var port: Int { get }
  var simulate: String? { get }
  var development: Bool { get }
  var logLevel: String { get }
  var persistence: Bool { get }
}

@main
struct F1DashServerApp: AsyncParsableCommand, AppArguments {
  @Option(name: .shortAndLong, help: "Server host to bind to")
  var host: String = "0.0.0.0"

  @Option(name: .shortAndLong, help: "Server port to bind to")
  var port: Int = 3000

  @Option(name: .long, help: "Simulation log file path (for simulation mode)")
  var simulate: String?

  @Flag(name: .long, help: "Enable development mode with additional logging")
  var development: Bool = false

  @Option(name: .long, help: "Log level (trace, debug, info, warning, error, critical)")
  var logLevel: String = "info"

  @Flag(name: .long, help: "Enable database persistence for historical data")
  var persistence: Bool = false

  func run() async throws {
    let app = try await buildApplication(self)
    try await app.runService()
  }
}
