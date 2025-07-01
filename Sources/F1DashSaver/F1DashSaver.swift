import Foundation
import ArgumentParser
import SignalRClient
import Logging
import F1DashModels

/// F1-Dash Saver - Utility to record live F1 timing data to log files
@main
struct F1DashSaver: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "F1DashSaver",
        abstract: "Record F1 live timing data to log files",
        discussion: """
        The F1-Dash Saver connects to the official Formula 1 SignalR live timing feed
        and saves all raw messages to a log file for later replay during development.
        
        This is essential for developing and testing the F1-Dash server and client
        applications when live F1 sessions are not available.
        """
    )
    
    // MARK: - Command Line Arguments
    
    @Option(name: .shortAndLong, help: "Output log file path")
    var output: String
    
    @Option(name: .long, help: "Log level (trace, debug, info, warning, error, critical)")
    var logLevel: String = "info"
    
    @Flag(name: .long, help: "Overwrite existing output file")
    var overwrite: Bool = false
    
    @Option(name: .long, help: "Maximum recording duration in seconds")
    var maxDuration: Int?
    
    @Option(name: .long, help: "Buffer size for file writing")
    var bufferSize: Int = 8192
    
    // MARK: - State
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
        "ChampionshipPrediction"
    ]
    
    // MARK: - Main Entry Point
    
    func run() async throws {
        // Configure logging
        setupLogging()
        
        let logger = Logger(label: "F1DashSaver")
        logger.info("Starting F1-Dash Saver v1.0.0")
        
        // Create saver state
        let saverState = SaverState()
        
        // Validate and create output file
        try await setupOutputFile(saverState: saverState)
        
        defer {
            Task {
                await saverState.closeFile()
            }
        }
        
        // Create SignalR connection 
        logger.info("Connecting to F1 live timing feed...")
        
        let connection = HubConnectionBuilder()
            .withUrl(url: f1BaseURL)
            .withAutomaticReconnect()
            .build()
        
        // Set up message handler
        await connection.on("feed") { (topic: String, data: String, timestamp: String) in
            let rawMessage = RawMessage(
                topic: topic,
                data: Data(data.utf8),
                timestamp: Date()
            )
              await F1DashSaver.saveMessage(rawMessage, saverState: saverState)
        }
        
        // Handle connection events
//        connection.onClose { error in
//            if let error = error {
//                logger.error("Connection closed with error: \(error)")
//            } else {
//                logger.info("Connection closed")
//            }
//        }
        
        await connection.onReconnecting { error in
            logger.info("Reconnecting...")
        }
        
        await connection.onReconnected {
            logger.info("Reconnected successfully")
        }
        
        // Start connection
        try await connection.start()
        logger.info("Connected to F1 live timing!")
        
        // Subscribe to topics
        try await connection.invoke(method: "Subscribe", arguments: subscriptionTopics)
        logger.info("Subscribed to \(subscriptionTopics.count) topics")
        
        logger.info("Recording started. Press Ctrl+C to stop.")
        await saverState.setRecordingStartTime(Date())
        
        // Set up signal handlers for graceful shutdown
        let signalSource = DispatchSource.makeSignalSource(signal: SIGINT)
        signalSource.setEventHandler {
            logger.info("Received shutdown signal, stopping recording...")
            Task {
                await connection.stop()
                await printStatistics(saverState: saverState)
                Foundation.exit(0)
            }
        }
        signalSource.resume()
        
        // Keep running until max duration or signal
        if let maxDuration = maxDuration {
            logger.info("Will record for maximum \(maxDuration) seconds")
            try await Task.sleep(for: .seconds(maxDuration))
            logger.info("Maximum duration reached, stopping recording")
        } else {
            // Run indefinitely until signal
            try await Task.sleep(for: .seconds(Double.greatestFiniteMagnitude))
        }
        
        await connection.stop()
        await printStatistics(saverState: saverState)
    }
    
    // MARK: - Setup Methods
    
    private func setupLogging() {
        let level: Logging.Logger.Level = switch logLevel.lowercased() {
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
    }
    
    private func setupOutputFile(saverState: SaverState) async throws {
        let outputURL = URL(fileURLWithPath: output)
        let logger = Logger(label: "F1DashSaver")
        
        // Check if file exists
        if FileManager.default.fileExists(atPath: output) {
            if !overwrite {
                throw SaverError.fileExists(output)
            } else {
                logger.warning("Overwriting existing file: \(output)")
                try FileManager.default.removeItem(at: outputURL)
            }
        }
        
        // Ensure parent directory exists
        let parentDirectory = outputURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: parentDirectory,
            withIntermediateDirectories: true
        )
        
        // Create and open file
        guard FileManager.default.createFile(atPath: output, contents: nil) else {
            throw SaverError.cannotCreateFile(output)
        }
        
        let fileHandle = try FileHandle(forWritingTo: outputURL)
        await saverState.setFileHandle(fileHandle)
        logger.info("Created output file: \(output)")
    }
    
    // MARK: - Message Handling
    
    private static func saveMessage(_ rawMessage: RawMessage, saverState: SaverState) async {
        let logger = Logger(label: "F1DashSaver")
        
        do {
            // Convert message to JSON line
            let messageData = try F1DashSaver.createLogEntry(rawMessage)
            
            // Write to file
            await saverState.writeMessage(messageData)
            
            let messageCount = await saverState.incrementMessageCount()
            
            // Log progress periodically
            if messageCount % 100 == 0 {
                let elapsed = await saverState.getElapsedTime()
                logger.info("Recorded \(messageCount) messages in \(Int(elapsed))s")
            }
            
        } catch {
            logger.error("Failed to save message: \(error)")
        }
    }
    
    private static func createLogEntry(_ rawMessage: RawMessage) throws -> Data {
        // Create a log entry with timestamp and message data
        let logEntry = LogEntry(
            timestamp: rawMessage.timestamp,
            topic: rawMessage.topic,
            data: String(data: rawMessage.data, encoding: .utf8) ?? ""
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        var data = try encoder.encode(logEntry)
        data.append("\n".data(using: .utf8)!) // Add newline for line-by-line reading
        
        return data
    }
    
    // MARK: - Statistics
    
    private func printStatistics(saverState: SaverState) async {
        let logger = Logger(label: "F1DashSaver")
        
        let duration = await saverState.getElapsedTime()
        guard duration > 0 else { return }
        
        let messageCount = await saverState.getMessageCount()
        let messagesPerSecond = Double(messageCount) / duration
        
        logger.info("""
            Recording Statistics:
            - Duration: \(String(format: "%.1f", duration))s
            - Messages recorded: \(messageCount)
            - Average rate: \(String(format: "%.1f", messagesPerSecond)) msg/s
            - Output file: \(output)
            """)
        
        // Get file size
        await saverState.synchronizeFile()
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: output)
            if let fileSize = attributes[.size] as? Int64 {
                let fileSizeMB = Double(fileSize) / (1024 * 1024)
                logger.info("File size: \(String(format: "%.2f", fileSizeMB)) MB")
            }
        } catch {
            logger.error("Could not get file size: \(error)")
        }
    }
}

// MARK: - Supporting Types

/// Log entry structure for saved messages
struct LogEntry: Codable {
    let timestamp: Date
    let topic: String
    let data: String
    
    init(timestamp: Date, topic: String, data: String) {
        self.timestamp = timestamp
        self.topic = topic
        self.data = data
    }
}

/// Errors specific to the saver utility
enum SaverError: Error, LocalizedError {
    case fileExists(String)
    case cannotCreateFile(String)
    case writeFailed
    
    var errorDescription: String? {
        switch self {
        case .fileExists(let path):
            return "File already exists at path: \(path). Use --overwrite to replace it."
        case .cannotCreateFile(let path):
            return "Cannot create file at path: \(path)"
        case .writeFailed:
            return "Failed to write data to file"
        }
    }
}

/// Actor for managing mutable saver state
actor SaverState {
    private var fileHandle: FileHandle?
    private var recordingStartTime: Date?
    private var messageCount: Int = 0
    
    func setFileHandle(_ handle: FileHandle) {
        self.fileHandle = handle
    }
    
    func setRecordingStartTime(_ time: Date) {
        self.recordingStartTime = time
    }
    
    func writeMessage(_ data: Data) {
        fileHandle?.write(data)
    }
    
    func incrementMessageCount() -> Int {
        messageCount += 1
        return messageCount
    }
    
    func getMessageCount() -> Int {
        return messageCount
    }
    
    func getElapsedTime() -> TimeInterval {
        guard let startTime = recordingStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    
    func synchronizeFile() {
        fileHandle?.synchronizeFile()
    }
    
    func closeFile() {
        fileHandle?.closeFile()
        fileHandle = nil
    }
}
