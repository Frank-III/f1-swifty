//import Compression
//import F1DashModels
//import Foundation
//import Logging
//import SwiftyJSON
//
///// Actor responsible for processing raw F1 data messages (SwiftyJSON version)
//actor DataProcessingActorSwiftyJSON {
//
//  // MARK: - State
//
//  private let logger = Logger(label: "DataProcessingActor")
//  private var stateUpdateHandler: ((StateUpdate) async -> Void)?
//
//  // MARK: - Public Interface
//
//  /// Set the handler for processed state updates
//  func setStateUpdateHandler(_ handler: @escaping (StateUpdate) async -> Void) {
//    stateUpdateHandler = handler
//  }
//
//  /// Process a raw message from SignalR
//  func processMessage(_ rawMessage: RawMessage) async {
//    do {
//      guard let processedMessage = try await parseMessage(rawMessage) else {
//        return
//      }
//
//      let stateUpdate = StateUpdate(
//        updates: processedMessage.content.dictionary,
//        timestamp: processedMessage.timestamp
//      )
//
//      await stateUpdateHandler?(stateUpdate)
//
//    } catch {
//      logger.error("Failed to process message for topic '\(rawMessage.topic)': \(error)")
//    }
//  }
//
//  // MARK: - Private Implementation
//
//  private func parseMessage(_ rawMessage: RawMessage) async throws -> ProcessedMessage? {
//    // Parse JSON using SwiftyJSON
//    let json = JSON(rawMessage.data)
//    
//    guard json != JSON.null else {
//      logger.warning("Failed to parse JSON for topic: \(rawMessage.topic)")
//      return nil
//    }
//
//    // Handle initial state messages (R field)
//    if json["R"].exists() {
//      return try await processInitialMessage(
//        topic: rawMessage.topic,
//        data: json["R"],
//        timestamp: rawMessage.timestamp
//      )
//    }
//
//    // Handle update messages (M field)
//    if let updatesArray = json["M"].array {
//      return try await processUpdateMessages(
//        updates: updatesArray,
//        timestamp: rawMessage.timestamp
//      )
//    }
//
//    return nil
//  }
//
//  private func processInitialMessage(
//    topic: String,
//    data: JSON,
//    timestamp: Date
//  ) async throws -> ProcessedMessage? {
//
//    // For simulation mode, the initial data might be the entire state
//    if topic == "updates" || topic == "simulation" {
//      // This is likely a full state update from simulation
//      var transformedState: [String: Any] = [:]
//      
//      // Transform all keys in the state using SwiftyJSON's cleaner iteration
//      for (key, value) in data.dictionaryValue {
//        if key == "_kf" { continue }  // Skip metadata
//        
//        let transformedKey = DataTransformation.toCamelCase(key)
//        
//        // Recursively transform nested dictionaries
//        if let valueDict = value.dictionaryObject {
//          transformedState[transformedKey] = DataTransformation.transformKeys(valueDict)
//        } else {
//          transformedState[transformedKey] = value.object
//        }
//      }
//
//      return ProcessedMessage(
//        topic: "initial",
//        content: transformedState,
//        timestamp: timestamp
//      )
//    }
//
//    // Single topic initial message
//    guard let dataDict = data.dictionaryObject else {
//      logger.warning("Initial message data is not a dictionary for topic: \(topic)")
//      return nil
//    }
//
//    // Transform keys from snake_case to camelCase
//    let transformedDict = DataTransformation.transformKeys(dataDict)
//
//    // Wrap single topic data
//    let content = [DataTransformation.toCamelCase(topic): transformedDict]
//
//    return ProcessedMessage(
//      topic: "initial",
//      content: content,
//      timestamp: timestamp
//    )
//  }
//
//  private func processUpdateMessages(
//    updates: [JSON],
//    timestamp: Date
//  ) async throws -> ProcessedMessage? {
//
//    var processedUpdates: [String: Any] = [:]
//
//    for update in updates {
//      // SwiftyJSON makes this much cleaner
//      guard update["A"].exists(),
//            let argumentsArray = update["A"].array,
//            argumentsArray.count >= 2,
//            let topic = argumentsArray[0].string
//      else {
//        continue
//      }
//
//      let rawData = argumentsArray[1]
//      let transformedTopic = DataTransformation.toCamelCase(topic)
//
//      // Handle compressed data (topics ending with .z)
//      if topic.hasSuffix(".z") {
//        let baseTopic = String(topic.dropLast(2))  // Remove .z suffix
//        let transformedBaseTopic = DataTransformation.toCamelCase(baseTopic)
//
//        if let compressedString = rawData.string {
//          do {
//            let decompressedData = try await decompressData(compressedString)
//            processedUpdates[transformedBaseTopic] = decompressedData
//          } catch {
//            logger.error("Failed to decompress data for topic \(topic): \(error)")
//            continue
//          }
//        }
//      } else {
//        // Handle uncompressed data
//        if let dataDict = rawData.dictionaryObject {
//          processedUpdates[transformedTopic] = DataTransformation.transformKeys(dataDict)
//        } else {
//          processedUpdates[transformedTopic] = rawData.object
//        }
//      }
//    }
//
//    guard !processedUpdates.isEmpty else {
//      return nil
//    }
//
//    return ProcessedMessage(
//      topic: "updates",
//      content: processedUpdates,
//      timestamp: timestamp
//    )
//  }
//
//  private func decompressData(_ compressedString: String) async throws -> [String: Any] {
//    // Decode base64
//    guard let compressedData = Data(base64Encoded: compressedString) else {
//      throw ProcessingError.invalidBase64
//    }
//
//    // Decompress using zlib
//    let decompressedData = try compressedData.withUnsafeBytes { bytes in
//      let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024 * 1024)  // 1MB buffer
//      defer { buffer.deallocate() }
//
//      let decompressedSize = compression_decode_buffer(
//        buffer, 1024 * 1024,
//        bytes.bindMemory(to: UInt8.self).baseAddress!, compressedData.count,
//        nil, COMPRESSION_ZLIB
//      )
//
//      guard decompressedSize > 0 else {
//        throw ProcessingError.decompressionFailed
//      }
//
//      return Data(bytes: buffer, count: decompressedSize)
//    }
//
//    // Parse JSON using SwiftyJSON
//    let json = JSON(decompressedData)
//    
//    guard json != JSON.null else {
//      throw ProcessingError.invalidJSON
//    }
//
//    // Transform keys and return dictionary
//    return DataTransformation.transformKeys(json.dictionaryObject ?? [:])
//  }
//}
//
//// MARK: - Error Types
//
//extension DataProcessingActorSwiftyJSON {
//
//  enum ProcessingError: Error, LocalizedError {
//    case invalidBase64
//    case decompressionFailed
//    case invalidJSON
//    case missingData
//
//    var errorDescription: String? {
//      switch self {
//      case .invalidBase64:
//        return "Invalid base64 encoding"
//      case .decompressionFailed:
//        return "Failed to decompress data"
//      case .invalidJSON:
//        return "Invalid JSON format"
//      case .missingData:
//        return "Missing required data"
//      }
//    }
//  }
//}
