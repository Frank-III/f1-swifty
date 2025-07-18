import Foundation

/// Root container for all F1 session state
public struct F1State: Sendable, Codable {
  public var driverList: [String: Driver]?
  public var timingData: TimingData?
  public var timingAppData: TimingAppData?
  public var positionData: PositionData?
  public var carData: CarData?
  public var trackStatus: TrackStatus?
  public var sessionInfo: SessionInfo?
  public var sessionData: SessionData?
  public var lapCount: LapCount?
  public var weatherData: WeatherData?
  public var timingStats: TimingStats?
  public var raceControlMessages: RaceControlMessages?
  public var teamRadio: TeamRadio?
  public var championshipPrediction: ChampionshipPrediction?
  public var heartbeat: Heartbeat?
  public var extrapolatedClock: ExtrapolatedClock?
  public var topThree: TopThree?

  public init(
    driverList: [String: Driver]? = nil,
    timingData: TimingData? = nil,
    timingAppData: TimingAppData? = nil,
    positionData: PositionData? = nil,
    carData: CarData? = nil,
    trackStatus: TrackStatus? = nil,
    sessionInfo: SessionInfo? = nil,
    sessionData: SessionData? = nil,
    lapCount: LapCount? = nil,
    weatherData: WeatherData? = nil,
    timingStats: TimingStats? = nil,
    raceControlMessages: RaceControlMessages? = nil,
    teamRadio: TeamRadio? = nil,
    championshipPrediction: ChampionshipPrediction? = nil,
    heartbeat: Heartbeat? = nil,
    extrapolatedClock: ExtrapolatedClock? = nil,
    topThree: TopThree? = nil
  ) {
    self.driverList = driverList
    self.timingData = timingData
    self.timingAppData = timingAppData
    self.positionData = positionData
    self.carData = carData
    self.trackStatus = trackStatus
    self.sessionInfo = sessionInfo
    self.sessionData = sessionData
    self.lapCount = lapCount
    self.weatherData = weatherData
    self.timingStats = timingStats
    self.raceControlMessages = raceControlMessages
    self.teamRadio = teamRadio
    self.championshipPrediction = championshipPrediction
    self.heartbeat = heartbeat
    self.extrapolatedClock = extrapolatedClock
    self.topThree = topThree
  }
}

/// Message types for WebSocket communication
public enum WebSocketMessage: Sendable, Codable {
  case fullState(F1State)
  case stateUpdate(SendableJSON)
  case connectionStatus(ConnectionStatus)

  private enum CodingKeys: String, CodingKey {
    case type, data
  }

  private enum MessageType: String, Codable {
    case fullState = "full_state"
    case stateUpdate = "state_update"
    case connectionStatus = "connection_status"
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(MessageType.self, forKey: .type)

    switch type {
    case .fullState:
      let state = try container.decode(F1State.self, forKey: .data)
      self = .fullState(state)
    case .stateUpdate:
      let update = try container.decode(SendableJSON.self, forKey: .data)
      self = .stateUpdate(update)
    case .connectionStatus:
      let status = try container.decode(ConnectionStatus.self, forKey: .data)
      self = .connectionStatus(status)
    }
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .fullState(let state):
      try container.encode(MessageType.fullState, forKey: .type)
      try container.encode(state, forKey: .data)
    case .stateUpdate(let update):
      try container.encode(MessageType.stateUpdate, forKey: .type)
      try container.encode(update, forKey: .data)
    case .connectionStatus(let status):
      try container.encode(MessageType.connectionStatus, forKey: .type)
      try container.encode(status, forKey: .data)
    }
  }
}

/// Connection status for client communication
public enum ConnectionStatus: String, Sendable, Codable {
  case connected
  case disconnected
  case reconnecting
  case error
}

/// Raw message from SignalR feed
public struct RawMessage: Sendable, Codable {
  public let topic: String
  public let data: Data
  public let timestamp: Date

  public init(topic: String, data: Data, timestamp: Date = Date()) {
    self.topic = topic
    self.data = data
    self.timestamp = timestamp
  }
}

/// Processed message after transformation
public struct ProcessedMessage: Sendable, Codable {
  public let topic: String
  public let content: JSONValue
  public let timestamp: Date

  public init(topic: String, content: [String: Any], timestamp: Date = Date()) {
    self.topic = topic
    self.content = JSONValue(from: content)
    self.timestamp = timestamp
  }

  public init(topic: String, content: JSONValue, timestamp: Date = Date()) {
    self.topic = topic
    self.content = content
    self.timestamp = timestamp
  }
}

/// State update for incremental changes
public struct StateUpdate: Sendable, Codable {
  public let updates: JSONValue
  public let timestamp: Date

  public init(updates: [String: Any], timestamp: Date = Date()) {
    self.updates = JSONValue(from: updates)
    self.timestamp = timestamp
  }

  public init(updates: JSONValue, timestamp: Date = Date()) {
    self.updates = updates
    self.timestamp = timestamp
  }
}

/// Sendable wrapper for JSON data
public struct SendableJSON: Sendable, Codable {
  public let value: JSONValue

  public init(_ dictionary: [String: Any]) {
    self.value = JSONValue(from: dictionary)
  }

  public init(_ value: JSONValue) {
    self.value = value
  }

  public init(from decoder: any Decoder) throws {
    self.value = try JSONValue(from: decoder)
  }

  public func encode(to encoder: any Encoder) throws {
    try value.encode(to: encoder)
  }

  /// Get the underlying dictionary
  public var dictionary: [String: Any] {
    switch value {
    case .object(let dict):
      return dict.untypedDictionary
    default:
      return [:]
    }
  }
}
