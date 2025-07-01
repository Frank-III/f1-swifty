import Compression
import F1DashModels
import Foundation
import Logging

/// Actor responsible for processing raw F1 data messages
actor DataProcessingActor {

  // MARK: - State

  private let logger = Logger(label: "DataProcessingActor")
  private var stateUpdateHandler: ((StateUpdate) async -> Void)?

  // MARK: - Public Interface

  /// Set the handler for processed state updates
  func setStateUpdateHandler(_ handler: @escaping (StateUpdate) async -> Void) {
    stateUpdateHandler = handler
  }

  /// Process a raw message from SignalR
  func processMessage(_ rawMessage: RawMessage) async {
    do {
      guard let processedMessage = try await parseMessage(rawMessage) else {
        return
      }
      
      let updateDict = processedMessage.content.dictionary
      let topicKeys = updateDict.keys.joined(separator: ", ")
      logger.info("Processing message with topics: \(topicKeys)")

      let stateUpdate = StateUpdate(
        updates: processedMessage.content.dictionary,
        timestamp: processedMessage.timestamp
      )

      await stateUpdateHandler?(stateUpdate)

    } catch {
      logger.error("Failed to process message for topic '\(rawMessage.topic)': \(error)")
    }
  }

  // MARK: - Private Implementation

  private func parseMessage(_ rawMessage: RawMessage) async throws -> ProcessedMessage? {
    let messageString = String(data: rawMessage.data, encoding: .utf8) ?? ""

    guard let jsonData = messageString.data(using: .utf8),
      let messageJson = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
    else {
      logger.warning("Failed to parse JSON for topic: \(rawMessage.topic)")
      return nil
    }

    // Handle initial state messages (R field)
    if let initialData = messageJson["R"] {
      return try await processInitialMessage(
        topic: rawMessage.topic,
        data: initialData,
        timestamp: rawMessage.timestamp
      )
    }

    // Handle update messages (M field)
    if let updatesArray = messageJson["M"] as? [[String: Any]] {
      return try await processUpdateMessages(
        updates: updatesArray,
        timestamp: rawMessage.timestamp
      )
    }

    return nil
  }

  private func processInitialMessage(
    topic: String,
    data: Any,
    timestamp: Date
  ) async throws -> ProcessedMessage? {

    // For simulation mode, the initial data might be the entire state
    if topic == "updates" || topic == "simulation" {
      // This is likely a full state update from simulation
      if let fullStateDict = data as? [String: Any] {
        // Transform all keys in the state
        var transformedState: [String: Any] = [:]
        for (key, value) in fullStateDict {
          if key == "_kf" { continue }  // Skip metadata
          
          // Handle compressed topics in full state
          if key.hasSuffix(".z") {
            let baseTopic = String(key.dropLast(2))  // Remove .z suffix
            let transformedKey = DataTransformation.toCamelCase(baseTopic)
            
            if let compressedString = value as? String {
              do {
                let decompressedData = try await decompressData(compressedString)
                transformedState[transformedKey] = decompressedData
              } catch {
                logger.error("Failed to decompress data for topic \(key): \(error)")
                continue
              }
            }
          } else {
            let transformedKey = DataTransformation.toCamelCase(key)
            if var valueDict = value as? [String: Any] {
              valueDict = DataTransformation.transformKeys(valueDict)
              transformedState[transformedKey] = valueDict
            } else {
              transformedState[transformedKey] = value
            }
          }
        }

        return ProcessedMessage(
          topic: "initial",
          content: transformedState,
          timestamp: timestamp
        )
      }
    }

    // Handle compressed single topic
    if topic.hasSuffix(".z") {
      let baseTopic = String(topic.dropLast(2))  // Remove .z suffix
      let transformedTopic = DataTransformation.toCamelCase(baseTopic)
      
      guard let compressedString = data as? String else {
        logger.warning("Compressed topic \(topic) data is not a string: \(data)")
        return nil
      }
      
      do {
        let decompressedData = try await decompressData(compressedString)
        let content = [transformedTopic: decompressedData]
        
        return ProcessedMessage(
          topic: "initial",
          content: content,
          timestamp: timestamp
        )
      } catch {
        logger.error("Failed to decompress data for topic \(topic): \(error)")
        return nil
      }
    }

    // Single topic initial message (uncompressed)
    guard var dataDict = data as? [String: Any] else {
      logger.warning("Initial message data is not a dictionary for topic: \(topic), data: \(data)")
      return nil
    }

    // Transform keys from snake_case to camelCase
    dataDict = DataTransformation.transformKeys(dataDict)

    // Wrap single topic data
    let content = [DataTransformation.toCamelCase(topic): dataDict]

    return ProcessedMessage(
      topic: "initial",
      content: content,
      timestamp: timestamp
    )
  }

  private func processUpdateMessages(
    updates: [[String: Any]],
    timestamp: Date
  ) async throws -> ProcessedMessage? {

    var processedUpdates: [String: Any] = [:]

    for update in updates {
      guard let argumentsArray = update["A"] as? [Any],
        argumentsArray.count >= 2,
        let topic = argumentsArray[0] as? String
      else {
        continue
      }

      let rawData = argumentsArray[1]
      let transformedTopic = DataTransformation.toCamelCase(topic)

      // Handle compressed data (topics ending with .z)
      if topic.hasSuffix(".z") {
        let baseTopic = String(topic.dropLast(2))  // Remove .z suffix
        let transformedBaseTopic = DataTransformation.toCamelCase(baseTopic)

        if let compressedString = rawData as? String {
          do {
            let decompressedData = try await decompressData(compressedString)
            processedUpdates[transformedBaseTopic] = decompressedData
          } catch {
            logger.error("Failed to decompress data for topic \(topic): \(error)")
            continue
          }
        }
      } else {
        // Handle uncompressed data
        if var dataDict = rawData as? [String: Any] {
          dataDict = DataTransformation.transformKeys(dataDict)
          processedUpdates[transformedTopic] = dataDict
        } else {
          processedUpdates[transformedTopic] = rawData
        }
      }
    }

    guard !processedUpdates.isEmpty else {
      return nil
    }

    return ProcessedMessage(
      topic: "updates",
      content: processedUpdates,
      timestamp: timestamp
    )
  }

  private func decompressData(_ compressedString: String) async throws -> [String: Any] {
    // Decode base64
    guard let compressedData = Data(base64Encoded: compressedString) else {
      throw ProcessingError.invalidBase64
    }

    // Decompress using zlib
    let decompressedData = try compressedData.withUnsafeBytes { bytes in
      let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024 * 1024)  // 1MB buffer
      defer { buffer.deallocate() }

      let decompressedSize = compression_decode_buffer(
        buffer, 1024 * 1024,
        bytes.bindMemory(to: UInt8.self).baseAddress!, compressedData.count,
        nil, COMPRESSION_ZLIB
      )

      guard decompressedSize > 0 else {
        throw ProcessingError.decompressionFailed
      }

      return Data(bytes: buffer, count: decompressedSize)
    }

    // Parse JSON
    guard
      let jsonObject = try JSONSerialization.jsonObject(with: decompressedData) as? [String: Any]
    else {
      throw ProcessingError.invalidJSON
    }

    // Transform keys
    return DataTransformation.transformKeys(jsonObject)
  }
}

// MARK: - Error Types

extension DataProcessingActor {

  enum ProcessingError: Error, LocalizedError {
    case invalidBase64
    case decompressionFailed
    case invalidJSON
    case missingData

    var errorDescription: String? {
      switch self {
      case .invalidBase64:
        return "Invalid base64 encoding"
      case .decompressionFailed:
        return "Failed to decompress data"
      case .invalidJSON:
        return "Invalid JSON format"
      case .missingData:
        return "Missing required data"
      }
    }
  }
}
