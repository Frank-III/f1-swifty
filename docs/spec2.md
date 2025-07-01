This would be a pure swift implementation so refer to [Some Swift Best Practice](../apple/docs/index.md) for the latest framework and the source code of F1-Dash is splitted into two parts already: [server](./f1-dash-server.md) and [client](./f1-dash-client.md).
---

## Software Specification: F1-Dash (Swift Edition)

**Version:** 2.0
**Date:** June 11, 2024

**Changes from V1.0:**
*   Added a detailed section on **Project Scaffolding**, recommending a Swift Package Manager monorepo and clarifying the relationship between server and client projects.
*   Introduced a **Development & Testing** section detailing a built-in simulation mode for the server and a data-saving utility.
*   Analyzed the database usage in the original project and made a strategic decision to **defer database integration** from this version, defining it as a future scope.
*   Refined the file organization diagram to be more explicit and comprehensive.

**1. Overview & Purpose**

F1-Dash (Swift Edition) is a complete rewrite of the original F1-Dash project, transitioning from a Rust/Next.js stack to a pure Swift ecosystem. The project is composed of two primary components:

1.  **F1-Dash Server:** A backend service built with the [Hummingbird](https://hummingbird-project.github.io/hummingbird/) web framework. Its primary responsibility is to connect to the official Formula 1 SignalR live timing feed, process the high-frequency data stream, and serve a simplified, real-time feed to the macOS client via WebSockets.
2.  **F1-Dash.app:** A native macOS menu bar application. It provides at-a-glance F1 session information, focusing on a core, high-fidelity visualization: a live track map displaying car positions, track status, and a compact list of driver timings.

The primary goal of this version is to establish a solid, modern Swift foundation for both the server and client, prioritizing real-time data flow and a core, polished user experience in the menu bar.

**2. Target Platform**

*   **Server:**
    *   **OS:** macOS / Linux
    *   **Swift Version:** Swift 6.0+
    *   **Framework:** Hummingbird 2.0+
*   **Client (F1-Dash.app):**
    *   **Operating System:** macOS 15.0+ (Sequoia)
    *   **Architecture:** Universal Binary (Apple Silicon & Intel)
    *   **Swift Version:** Swift 6.0+ with strict concurrency checking
    *   **UI Framework:** SwiftUI

**3. Architecture & Core Components**

**3.1. Server Architecture (Hummingbird)**

The server acts as a robust, stateful proxy and processor for the F1 data feed.

*   **Key Architectural Patterns:**
    *   **Actor Model:** Swift Concurrency is used extensively to manage state and handle concurrent connections safely.
    *   **Proxy Pattern:** The server abstracts the complexity of the SignalR feed from the client.
    *   **Publisher/Subscriber:** A central broadcast mechanism distributes processed data to all connected clients.

*   **Core Server Components:**
    1.  **`SignalRManager` (Actor):** Manages the connection to the F1 SignalR feed, including negotiation, heartbeats, and reconnection.
    2.  **`DataProcessingActor` (Actor):** Inflates compressed data and transforms raw JSON into strongly-typed Swift models.
    3.  **`SessionStateCache` (Actor):** Maintains the canonical, in-memory state of the live F1 session.
    4.  **`WebSocketManager`:** Manages WebSocket connections from clients, broadcasting state updates.
    5.  **`APIRouter`:** Provides a REST endpoint for the cached F1 race schedule.

**3.2. Client Architecture (macOS App)**

The client is a modern SwiftUI application focused on efficient rendering and state management.

*   **Key Architectural Patterns:**
    *   **Use V-VM(View-ViewModel):** .
    *   **Observable State:** Utilizes Swift's `@Observable` macro for reactive UI.
    *   **Actor Model:** Isolates networking and data processing from the main thread.

*   **Core Client Components:**
    1.  **`AppOrchestrator` (@MainActor @Observable):** Central coordinator for the application's services.
    2.  **`StatusBarController`:** Manages the `NSStatusItem` and its popover.
    3.  **`WebSocketClient` (Actor):** Connects to the F1-Dash Server's WebSocket endpoint.
    4.  **`DataManager` (@MainActor @Observable):** Holds the live F1 session state for the UI.
    5.  **`TrackMapViewModel` (@MainActor @Observable):** Contains rendering logic for the track map.
    6.  **`DriverListViewModel` (@MainActor @Observable):** Manages state for the driver timing list.

**3.3. Ancillary Services (Future Scope)**

The original Rust project includes services for data persistence and historical analysis (`importer`, `analytics`).

*   **Database:** The original system uses **PostgreSQL with the TimescaleDB extension**.
*   **Purpose:** The `importer` service persists timing data, and the `analytics` service queries it.
*   **Decision for this Version:** Database integration and these related services are **DEFERRED** to a future version.
    *   **Reasoning:** The priority is to perfect the *live* data pipeline. Introducing a database adds significant upfront complexity. This functionality will be added as a distinct feature in a later release.

**4. Data Models (Shared Swift Package)**

A shared Swift package will define the data structures used for communication between the server and client, directly translated from the original project's TypeScript types.

*   **`F1State`:** The root object containing all other state slices.
*   **`Driver`:** Information about a driver (name, number, team color, etc.).
*   **`TimingDataDriver`:** Live timing information for a driver.
*   **`PositionData`:** Live X, Y, Z coordinates for all cars.
*   **`TrackStatus`:** Current flag status of the track.
*   **`SessionInfo`:** Details about the current session.

**5. Detailed Feature Specifications**

**5.1. Server**
*   **Data Ingestion:** Connect to `livetiming.formula1.com/signalr` and subscribe to all necessary data topics.
*   **Data Broadcast:** Expose a single WebSocket endpoint (`/v1/live`). On connect, sends a `fullState` message, followed by `stateUpdate` messages.
*   **Schedule API:** Expose a REST endpoint (`/api/schedule`) that returns a cached JSON array of race rounds for the current year.

**5.2. Client**
*   **Menu Bar Icon (`NSStatusItem`):** An icon (e.g., F1 car silhouette) whose color reflects the track status (Green, Yellow, Red, Grey, Chequered Flag).
*   **Popover Window (`NSPopover`):** Presents the main `ContentView` with a non-scrollable track map at the top and a scrollable driver list below.
*   **Track Map View (`Canvas`):** Renders the circuit layout, colored marshal sectors, and animating car positions with TLA labels.
*   **Driver List View:** A scrollable list of drivers sorted by position, showing position, driver tag, last/best lap times, and interval, with appropriate color-coding for fastest times.
*   **Settings Window:** A separate window to manage settings like "Launch at Login" and "Favorite Drivers" (for UI highlighting).

**6. Data Storage & Persistence**

*   **Server:** No database persistence. All state is in-memory. The schedule API uses an in-memory cache.
*   **Client:** `UserDefaults` will be used to store user settings (`launchAtLoginEnabled`, `favoriteDriverIDs`).

**7. Error Handling & Resilience**

*   **Server:** Implements exponential backoff for SignalR reconnections. Data processing errors are logged without crashing the service.
*   **Client:** Implements a WebSocket reconnection strategy. The UI will clearly display a "Disconnected" state.

**8. Development & Testing**

To facilitate client development without a live F1 session, we will implement a data recorder and a server simulation mode.

**8.1. Data Recording Utility (`F1DashSaver`)**
*   A separate command-line executable target within the Swift Package.
*   **Functionality:** Connects to the real F1 SignalR feed and writes every raw text message as a new line to a specified log file.
*   **Invocation:** `swift run F1DashSaver --output session.log`

**8.2. Server Simulation Mode**
*   The main server executable will support a simulation mode activated by a command-line argument.
*   **Functionality:** Instead of connecting to the live feed, the server will read a log file and replay messages at a realistic pace to the `DataProcessingActor`, exercising the entire server data pipeline.
*   **Invocation:** `swift run F1DashServer --simulate <path-to-session.log>`

**9. Project Scaffolding & Structure**

The project will be a **Swift Package Manager (SPM) monorepo** to facilitate code sharing between distinct server and client products.

*   **`Package.swift` Definition:**
    *   **`F1DashModels`:** A `.library` target, shared between server and client.
    *   **`F1DashServer`:** An `.executable` target for the Hummingbird server.
    *   **`F1DashSaver`:** An `.executable` target for the data recorder.
*   **Xcode Integration:** The `F1-Dash.app` will be a separate Xcode project that links against the `F1DashModels` library from the local SPM package.

**10. File Organization**

```
/F1-Dash-Swift
├── Package.swift             # Defines all targets and their dependencies.
├── Sources/
│   ├── F1DashServer/           # Server Application Target
│   │   ├── F1DashServer.swift  # Main entry point (live/simulate mode).
│   │   ├── App.swift           # Hummingbird application setup.
│   │   ├── Actors/
│   │   │   ├── SignalRManager.swift
│   │   │   ├── SimulationReplayer.swift
│   │   │   ├── DataProcessingActor.swift
│   │   │   └── SessionStateCache.swift
│   │   └── Services/
│   │       ├── WebSocketManager.swift
│   │       └── APIRouter.swift
│   │
│   ├── F1DashSaver/            # Data Recorder Target
│   │   └── F1DashSaver.swift   # Main entry point.
│   │
│   └── F1DashModels/           # Shared Data Models Library
│       ├── F1State.swift
│       └── ... (all other models)
│
└── F1-Dash.app/                # Xcode Project for the macOS App
    ├── F1-Dash.xcodeproj
    └── F1-Dash/
        ├── App/
        │   └── F1DashApp.swift
        ├── Core/
        │   ├── AppOrchestrator.swift
        │   ├── WebSocketClient.swift
        │   └── DataManager.swift
        ├── UI/
        │   ├── Views/
        │   │   ├── ContentView.swift
        │   │   ├── TrackMapView.swift
        │   │   └── DriverListView.swift
        │   ├── ViewModels/
        │   │   ├── TrackMapViewModel.swift
        │   │   └── DriverListViewModel.swift
        │   └── Components/
        └── Resources/
            └── Assets.xcassets
```

**11. Technical Implementation Details**

*   **Concurrency:** Full adoption of Swift 6's strict concurrency model using Actors for state management and I/O.
*   **Data Inflation:** The server will use `libCompression` or a similar Swift-native Zlib/Deflate implementation.
*   **Drawing:** The client will use SwiftUI's `Canvas` API for track map rendering.
*   **Networking:** The server uses Hummingbird's WebSocket support. The client uses `URLSession`'s async WebSocket API.

**12. Dependencies**

*   **Server:**
    *   `hummingbird`: Core web framework.
    *   `hummingbird-websocket`: WebSocket support.
    *   `swift-log`: For structured logging.
    *   `[SignalR-Client-Swift]`: A suitable SignalR client library (technical dependency to be investigated/developed).
*   **Client:**
    *   No external dependencies planned.

**13. Future Extensibility (Post-V2.0)**

*   **Data Persistence:** Integrate a database (e.g., PostgreSQL with TimescaleDB) on the server to store historical timing data for analysis.
*   **Enhanced Analytics:** Add client-side views for driver lap time comparisons, gap analysis over time, and tire history.
*   **Full Feature Parity:** Gradually implement remaining features from the web dashboard, such as the weather map, team radio playback, and live championship standings.
*   **Platform Expansion:** Develop companion apps for iOS and iPadOS.
