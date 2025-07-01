# F1-Dash Server Architecture Design

**Version:** 1.0  
**Date:** June 27, 2025  
**Author:** Claude Code Assistant  

## Overview

This document details the architecture design for the F1-Dash Swift server, a complete rewrite of the original Rust implementation using Swift 6 with strict concurrency and the Hummingbird web framework.

## Core Architectural Principles

### 1. Swift 6 Strict Concurrency
- **Actor Isolation**: All stateful components are implemented as actors to ensure data-race safety
- **Sendable Compliance**: All data structures shared between actors conform to `Sendable`
- **Structured Concurrency**: Uses async/await and task groups for coordinated operations
- **Memory Safety**: Leverages Swift's memory safety guarantees for crash-resistant operation

### 2. Actor-Based Component Design
Each major component is designed as an isolated actor with clearly defined responsibilities:

```swift
actor SignalRClientActor {
    // Manages F1 SignalR connection lifecycle
}

actor DataProcessingActor {
    // Handles data decompression and transformation
}

actor SessionStateCache {
    // Maintains canonical F1 session state
}
```

### 3. Data Flow Architecture

```
F1 SignalR Feed → SignalRClientActor → DataProcessingActor → SessionStateCache → WebSocketManager → Clients
                                                                     ↓
                                                              APIRouter (REST)
```

## Component Specifications

### SignalRClientActor

**Responsibilities:**
- Establish and maintain connection to `livetiming.formula1.com/signalr`
- Handle SignalR negotiation protocol
- Subscribe to F1 data topics (`CarData.z`, `Position.z`, `TimingData`, etc.)
- Implement reconnection logic with exponential backoff
- Forward raw messages to DataProcessingActor

**Key Methods:**
```swift
func connect() async throws
func subscribe(to topics: [String]) async throws
func handleMessage(_ message: String) async
func reconnect() async
```

**State Management:**
- Connection status
- Retry count and backoff timing
- Subscription state

### DataProcessingActor

**Responsibilities:**
- Decompress compressed data streams (`.z` suffix topics)
- Parse JSON into strongly-typed Swift models
- Transform camelCase conversion (matching original Rust transformer logic)
- Apply data merging logic for incremental updates
- Forward processed data to SessionStateCache

**Key Methods:**
```swift
func processMessage(_ message: RawMessage) async throws -> ProcessedMessage?
func decompressData(_ compressedData: Data) throws -> Data
func transformKeys(_ json: [String: Any]) -> [String: Any]
```

**Dependencies:**
- Foundation's `Compression` framework for zlib inflation
- Custom JSON transformation utilities

### SessionStateCache

**Responsibilities:**
- Maintain the canonical, in-memory F1 session state
- Apply incremental updates from DataProcessingActor
- Provide current state snapshots for new WebSocket clients
- Broadcast state changes to WebSocketManager
- Handle session transitions (new session detection)

**Key Methods:**
```swift
func updateState(with update: StateUpdate) async
func getCurrentState() async -> F1State
func subscribeToUpdates() -> AsyncStream<StateUpdate>
```

**State Structure:**
```swift
struct F1State: Sendable, Codable {
    var driverList: [String: Driver]?
    var timingData: TimingData?
    var positionData: PositionData?
    var trackStatus: TrackStatus?
    var sessionInfo: SessionInfo?
    // ... other state slices
}
```

### WebSocketManager

**Responsibilities:**
- Accept WebSocket connections from clients
- Send full state on connection
- Broadcast incremental updates to all connected clients
- Handle client disconnections gracefully
- Maintain connection health

**Implementation:**
- Uses Hummingbird's WebSocket support
- Maintains list of active connections
- Implements fan-out messaging pattern

### APIRouter

**Responsibilities:**
- Serve F1 race schedule via REST endpoint `/api/schedule`
- Cache schedule data in memory
- Handle CORS for web clients

**Endpoints:**
- `GET /api/schedule` - Current year race schedule
- `GET /api/health` - Health check endpoint

## Data Models (F1DashModels)

### Core Model Hierarchy

```swift
// Root state container
struct F1State: Sendable, Codable {
    var driverList: [String: Driver]?
    var timingData: TimingData?
    var positionData: PositionData?
    var trackStatus: TrackStatus?
    var sessionInfo: SessionInfo?
    var lapCount: LapCount?
    var weatherData: WeatherData?
    // ... additional state slices
}

// Driver information
struct Driver: Sendable, Codable {
    let racingNumber: String
    let broadcastName: String
    let fullName: String
    let tla: String
    let teamName: String
    let teamColour: String
    let line: Int
    // ... additional fields
}

// Live timing data
struct TimingData: Sendable, Codable {
    let lines: [String: TimingDataDriver]
    let withheld: Bool
    let sessionPart: Int?
    // ... additional fields
}
```

### Message Types

```swift
enum WebSocketMessage: Sendable, Codable {
    case fullState(F1State)
    case stateUpdate([String: Any])
    case connectionStatus(ConnectionStatus)
}

enum ConnectionStatus: Sendable, Codable {
    case connected
    case disconnected
    case reconnecting
}
```

## Error Handling Strategy

### Connection Resilience
- **Exponential Backoff**: Reconnection delays: 1s, 2s, 4s, 8s, 16s, max 30s
- **Circuit Breaker**: Temporary suspension after repeated failures
- **Graceful Degradation**: Continue serving cached data during outages

### Data Processing Errors
- **Parsing Failures**: Log and skip malformed messages
- **Compression Errors**: Attempt recovery, fallback to raw data
- **State Corruption**: Reset to last known good state

### WebSocket Client Handling
- **Timeout Management**: Ping/pong for connection health
- **Buffer Overflow Protection**: Drop oldest messages if client can't keep up
- **Clean Disconnection**: Proper resource cleanup

## Performance Considerations

### Memory Management
- **Bounded State Size**: Limit historical data retention
- **Efficient Updates**: Use diff-based state updates
- **Connection Pooling**: Reuse WebSocket connections

### Concurrency Optimization
- **Actor Batching**: Process multiple messages per actor call
- **Async Streams**: Use for efficient data flow between actors
- **Task Groups**: Parallel processing where safe

## Security Considerations

### Input Validation
- **Message Size Limits**: Prevent memory exhaustion
- **Rate Limiting**: Protect against DoS attacks
- **Content Validation**: Verify message structure

### Network Security
- **TLS Termination**: HTTPS for API endpoints
- **CORS Configuration**: Controlled cross-origin access
- **Authentication**: Ready for future auth requirements

## Monitoring and Observability

### Logging Strategy
- **Structured Logging**: JSON format for easy parsing
- **Log Levels**: Debug, Info, Warning, Error, Critical
- **Context Propagation**: Trace requests across actors

### Metrics Collection
- **Connection Counts**: Active WebSocket clients
- **Message Rates**: Throughput monitoring
- **Error Rates**: Failure tracking
- **Latency Metrics**: End-to-end timing

### Health Checks
- **SignalR Connection**: Feed availability
- **Internal State**: Actor health status
- **Resource Usage**: Memory and CPU monitoring

## Development and Testing

### Simulation Mode
- **Data Replay**: Use saved session files for development
- **Deterministic Testing**: Reproducible scenarios
- **Performance Testing**: Load testing with simulated data

### Unit Testing Strategy
- **Actor Testing**: Isolated component testing
- **Mock Services**: Test doubles for external dependencies
- **Property Testing**: Validate state consistency

### Integration Testing
- **End-to-End**: Full pipeline testing
- **WebSocket Clients**: Multi-client scenarios
- **Failure Scenarios**: Chaos engineering principles

## Future Extensibility

### Database Integration
- **TimescaleDB**: Time-series data storage
- **Query Interface**: Historical data API
- **Data Retention**: Configurable archival policies

### Additional Features
- **Authentication**: User management
- **Rate Limiting**: Per-client throttling
- **Caching Layers**: Redis for high-frequency data
- **Horizontal Scaling**: Multi-instance deployment

## Deployment Architecture

### Single Instance (Initial)
- **All-in-One**: Single server process
- **Local State**: In-memory storage only
- **Direct Connection**: Single SignalR feed connection

### Future Scaling
- **Load Balancer**: Multiple server instances
- **Shared State**: External state store (Redis)
- **Message Queue**: Decoupled data processing

This architecture provides a solid foundation for the F1-Dash Swift server, ensuring type safety, concurrency correctness, and maintainable code structure while delivering real-time F1 data to clients efficiently.