## Software Specification: F1-Dash (Swift Edition)

**Version:** 2.1 (Iterated)
**Date:** June 26, 2024

**Changes from V2.0:**
*   **Architecture:** Replaced the client's V-VM pattern with a modern, Environment-Driven SwiftUI architecture, inspired by the "Forget MVVM" philosophy.
*   **Client Scope:** Expanded the client specification from a menu bar utility to a full, multi-window macOS application using `NavigationSplitView`.
*   **State Management:** Replaced `UserDefaults` with Point-Free's **`swift-sharing`** library for more robust, testable, and modern client-side settings persistence.
*   **Component & Service Refinement:** Provided a more detailed breakdown of server and client components, their responsibilities, and their interactions, aligning with Swift's structured concurrency and actor model.
*   **File Organization:** Updated the proposed file structure to reflect the new architecture, organizing by feature rather than by type.

**1. Overview & Purpose**

F1-Dash (Swift Edition) is a complete rewrite of the original F1-Dash project, transitioning from a Rust/Next.js stack to a pure Swift ecosystem. The project is composed of two primary components:

1.  **F1-Dash Server:** A backend service built with the **Hummingbird** web framework. Its primary responsibility is to connect to the official Formula 1 SignalR live timing feed, process the high-frequency data stream, and serve a simplified, real-time feed to macOS clients via WebSockets.
2.  **F1-Dash.app:** A native, fully-featured macOS application built with **SwiftUI**. It provides a rich, at-a-glance F1 session interface, including a live track map, detailed driver timings, race control messages, and historical analysis (in future versions).

The primary goal of this version is to establish a solid, modern Swift foundation for both the server and client, prioritizing a high-fidelity, real-time data pipeline and a polished, feature-rich user experience on macOS.

**2. Target Platform**

*   **Server:**
    *   **OS:** macOS / Linux
    *   **Swift Version:** Swift 6.0+
    *   **Framework:** Hummingbird 2.0+
*   **Client (F1-Dash.app):**
    *   **Operating System:** macOS 15.0+ (Sequoia)
    *   **Architecture:** Universal Binary (Apple Silicon & Intel)
    *   **Swift Version:** Swift 6.0+ with **Strict Concurrency Checking (`-strict-concurrency=complete`)**
    *   **UI Framework:** SwiftUI

**3. Architecture & Core Components**

**3.1. Server Architecture (Hummingbird)**

The server acts as a robust, stateful proxy and processor for the F1 data feed.

*   **Key Architectural Patterns:**
    *   **Actor Model:** Swift Concurrency is used extensively to manage state and handle concurrent connections safely.
    *   **Proxy Pattern:** The server abstracts the complexity of the SignalR feed from the client.
    *   **Publisher/Subscriber:** A central broadcast mechanism distributes processed data to all connected WebSocket clients.

*   **Core Server Components:**
    1.  **`SignalRClientActor` (Actor):** Manages the connection to the F1 SignalR feed, including negotiation, subscription to topics (`CarData.z`, `Position.z`, etc.), heartbeats, and reconnection logic with exponential backoff.
    2.  **`DataProcessingActor` (Actor):** Receives raw, compressed data chunks from the `SignalRClientActor`. It is responsible for Zlib inflation (using `libCompression`) and transforming the raw JSON into the strongly-typed `F1State` models.
    3.  **`SessionStateCache` (Actor):** Maintains the canonical, in-memory state of the live F1 session. It receives processed data from the `DataProcessingActor` and merges it into the current state.
    4.  **`WebSocketManager`:** Manages WebSocket connections from clients using Hummingbird's WebSocket support. On a new connection, it sends the full, current state from `SessionStateCache`. Subsequently, it subscribes to state updates and broadcasts them to all connected clients.
    5.  **`APIRouter`:** A Hummingbird `Router` that exposes a REST endpoint (`/api/schedule`) serving a cached JSON array of the F1 race schedule.

**3.2. Client Architecture (macOS App)**

The client is a modern, Environment-Driven SwiftUI application. It avoids traditional MVVM in favor of a lean architecture that leverages SwiftUI's native capabilities.

*   **Key Architectural Patterns:**
    *   **Environment-Driven:** A central, observable `AppEnvironment` object will be injected into the root of the view hierarchy. This object will hold references to core services.
    *   **Observable State:** Utilizes Swift's `@Observable` macro for all stateful models that drive the UI.
    *   **Actor Model:** Isolates all networking (`WebSocketClient`) and complex data processing (`DataBufferActor`) from the main thread.

*   **Core Client Components:**
    1.  **`AppEnvironment` (@MainActor @Observable):** The central observable object for the app. It instantiates and holds references to the `LiveSessionState` and other services. It is passed into the root view via `.environment()`.
    2.  **`WebSocketClient` (Actor):** Connects to the F1-Dash Server's WebSocket endpoint (`/v1/live`). It handles connection management, message decoding, and delegates incoming data to the `DataBufferActor`.
    3.  **`DataBufferActor` (Actor):** Replicates the logic from the original client's `useBuffer` hooks. It maintains a time-ordered buffer of incoming state updates to allow for user-configurable delay, crucial for syncing with TV broadcasts.
    4.  **`LiveSessionState` (@MainActor @Observable):** The source of truth for the UI. It receives delayed state updates from the `DataBufferActor` and publishes changes. Views will observe this object directly.
    5.  **`SettingsStore` (@MainActor @Observable):** Manages user settings using the **`swift-sharing`** library, providing properties like `@Shared(.appStorage("launchAtLogin")) var launchAtLogin`.

**3.3. Ancillary Services (Future Scope)**

Database integration and related services (`importer`, `analytics`) are **DEFERRED** to a future version to focus on perfecting the live data pipeline first.

**4. Data Models (Shared Swift Package: `F1DashModels`)**

A shared Swift package will define `Codable` and `Sendable` data structures used for communication between the server and client. This ensures type safety across the entire stack.

*   `F1State`, `Driver`, `TimingDataDriver`, `PositionData`, `TrackStatus`, `SessionInfo`, etc.

**5. Detailed Feature Specifications**

**5.1. Server**
*   **Data Ingestion:** Connect to `livetiming.formula1.com/signalr`, subscribe to all data topics, and handle compressed (`.z`) messages.
*   **Data Broadcast:** Expose a single WebSocket endpoint (`/v1/live`). On connect, it sends a `fullState` message, followed by a stream of `stateUpdate` messages.
*   **Schedule API:** Expose a REST endpoint (`/api/schedule`) that returns a cached JSON array of race rounds for the current year.

**5.2. Client**
*   **Main Window (`NavigationSplitView`):** The primary app interface.
    *   **Sidebar:** Lists the main dashboard sections: Dashboard, Track Map, Standings, Weather, Settings.
    *   **Detail View:** Displays the content for the selected sidebar item.
*   **Dashboard View:** A composite view showing the `LeaderBoard`, `Map`, `RaceControl`, `TeamRadios`, and `TrackViolations` components.
*   **Track Map View (`Canvas`):** Renders the circuit layout from GeoJSON/SVG data, colored marshal sectors, and animating car positions with TLA labels. Car dots will be color-coded by team.
*   **Leaderboard View (`Table` or `List`):** A scrollable, sortable list of drivers showing position, driver tag (with team color), last/best lap times, intervals, and tire information. It must efficiently handle high-frequency updates.
*   **Settings Window:** A separate window (`Settings` scene) for managing app preferences.
    *   Launch at Login
    *   Favorite Drivers (for highlighting in the UI)
    *   Data Delay Control
    *   Visual Toggles (e.g., show/hide car metrics).

**6. Data Storage & Persistence**

*   **Server:** No database persistence. All state is in-memory.
*   **Client:** Uses the **`swift-sharing`** library for all user settings.
    *   `@Shared(.appStorage("launchAtLogin")) var launchAtLogin: Bool`
    *   `@Shared(.appStorage("favoriteDriverIDs")) var favoriteDriverIDs: [String]`
    *   This provides a robust, testable, and modern persistence layer.

**7. Error Handling & Resilience**

*   **Server:** Implements exponential backoff for SignalR reconnections. Data processing errors are logged without crashing the service.
*   **Client:** The `WebSocketClient` actor implements a robust reconnection strategy. The UI will clearly display a "Disconnected" or "Reconnecting" state.

**8. Development & Testing**

This remains a key feature, as specified in V2.0.

**8.1. Data Recording Utility (`F1DashSaver`)**
*   An `.executable` target within the Swift Package to connect to the live F1 feed and save all raw messages to a log file.
*   Invocation: `swift run F1DashSaver --output session.log`

**8.2. Server Simulation Mode**
*   The `F1DashServer` executable will support a `--simulate` flag to read a log file and replay messages, exercising the entire server data pipeline for client development without a live session.
*   Invocation: `swift run F1DashServer --simulate <path-to-session.log>`

**9. Project Scaffolding & Structure**

The project will be a **Swift Package Manager (SPM) monorepo**.

*   **`Package.swift` Definition:**
    *   **`F1DashModels`:** A `.library` target, shared between server and client.
    *   **`F1DashServer`:** An `.executable` target for the Hummingbird server.
    *   **`F1DashSaver`:** An `.executable` target for the data recorder.
*   **Xcode Integration:** The `F1-Dash.app` will be a separate Xcode project that adds the local SPM package as a dependency to access `F1DashModels`.

**10. File Organization (Revised)**

```
/F1-Dash-Swift
├── Package.swift
├── Sources/
│   ├── F1DashServer/
│   │   ├── F1DashServer.swift      // Main entry point
│   │   ├── Application+Setup.swift // Hummingbird App config
│   │   ├── Actors/
│   │   │   ├── SignalRClientActor.swift
│   │   │   ├── DataProcessingActor.swift
│   │   │   └── SessionStateCache.swift
│   │   └── Services/
│   │       ├── WebSocketManager.swift
│   │       └── APIRouter.swift
│   │
│   ├── F1DashSaver/
│   │   └── F1DashSaver.swift
│   │
│   └── F1DashModels/
│       ├── F1State.swift
│       └── ... (all other Codable, Sendable models)
│
└── F1-Dash.app/                # Xcode Project for the macOS App
    ├── F1-Dash.xcodeproj
    └── F1-Dash/
        ├── App/
        │   ├── F1DashApp.swift         // App entry point, main WindowGroup
        │   ├── AppEnvironment.swift    // @Observable class holding services
        │   └── SettingsScene.swift     // The Settings() scene
        │
        ├── Services/
        │   ├── WebSocketClient.swift   // Actor
        │   └── DataBufferActor.swift   // Actor for handling data delay
        │
        ├── State/
        │   └── LiveSessionState.swift  // @Observable class for UI state
        │
        └── Features/
            ├── Dashboard/
            │   ├── DashboardView.swift
            │   ├── LeaderboardView.swift
            │   └── RaceControlView.swift
            ├── TrackMap/
            │   └── TrackMapView.swift
            ├── Standings/
            │   └── StandingsView.swift
            ├── Settings/
            │   ├── SettingsView.swift
            │   └── SettingsStore.swift     // Observable object using swift-sharing
            └── Shared/
                ├── Components/             // Reusable small views (e.g., DriverTag)
                └── Models/                 // View-specific models
```

**11. Technical Implementation Details**

*   **Concurrency:** Full adoption of Swift 6 strict concurrency (`-strict-concurrency=complete`).
*   **Data Inflation:** The server will use `libCompression`.
*   **UI:** The client will be 100% SwiftUI, using `NavigationSplitView` for top-level layout and `Canvas` for the track map.
*   **Networking:** The server uses Hummingbird's WebSocket support. The client uses `URLSession.webSocketTask` within its `WebSocketClient` actor.

**12. Dependencies**

*   **Server:**
    *   `hummingbird`
    *   `hummingbird-websocket`
    <!-- *   `swift-log`(maybe not?) -->
    *   `https://github.com/moozzyk/SignalR-Client-Swift`
    *   tracing: `https://github.com/apple/swift-distributed-tracing`
*   **Client:**
    *   `pointfreeco/swift-sharing`: For user settings persistence.

***

### Rationale and Key Decisions

*   **Full macOS App vs. Menubar App:** Your new requirement for a "fully-fledged" app is a significant and positive change. A `NavigationSplitView` is the standard, modern paradigm for this kind of information-dense application on macOS and iPadOS, providing a much richer user experience than a simple popover.

*   **Architecture ("Forget MVVM"):** The provided article "SwiftUI in 2025: Forget MVVM" is a clear signal to avoid boilerplate and embrace SwiftUI's native patterns.
    *   The proposed **Environment-Driven Architecture** directly reflects this. A single `@Observable AppEnvironment` object, created at the app's root and injected into the environment, will hold services like the `WebSocketClient`.
    *   Views will observe a central `LiveSessionState` object (also `@Observable`) for their data. This keeps views simple and reactive. There is no need for a separate `ViewModel` for every single view.
    *   This approach is lightweight, highly testable, and scales well, aligning perfectly with Apple's modern guidance.

*   **State Persistence (`swift-sharing`):** The `swift-sharing-example.md` you provided showcases a library that is a perfect fit for this project.
    *   Instead of raw `UserDefaults` or `@AppStorage`, using `@Shared(.appStorage(...))` provides a more powerful, type-safe, and testable way to manage settings.
    *   It decouples the views from the persistence mechanism and works seamlessly within `@Observable` classes, which is exactly what our new `SettingsStore` will be. This is a significant architectural improvement over the initial spec.

*   **Client-Side Data Buffering:** The analysis of the original TypeScript client's `useBuffer.ts` hook reveals a critical feature: the ability to delay the data stream. My iterated spec explicitly calls for this to be replicated in a `DataBufferActor`. This actor will receive live data from the `WebSocketClient` but only pass it to the main `LiveSessionState` after applying the user-configured delay, ensuring this key feature is not lost in the rewrite.

This iterated spec provides a robust, modern, and scalable foundation for F1-Dash (Swift Edition), aligning with the latest best practices from Apple and the broader Swift community.
