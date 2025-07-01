## Software Specification: F1-Dash (Swift Edition)

**Version:** 2.2 (Iterated)
**Date:** June 26, 2024

**Changes from V2.1:**
*   **Client Scope Clarification:** The client application is now explicitly defined as a **macOS Menu Bar App** and a separate, **fully-featured iOS & iPadOS App**.
*   **Platform-Specific UI:** The client architecture now specifies `MenuBarExtra` for the macOS target and a `WindowGroup` with a `TabView` for the iOS/iPadOS target.
*   **Feature Set Definition:** The feature set for the macOS menu bar app is defined as a focused, core experience (track map, compact driver list), while the iOS/iPadOS app is specified to have full feature parity with the original web UI.
*   **File Organization:** The client's file structure has been refined to better accommodate platform-specific root views while maximizing shared component and service code.

**1. Overview & Purpose**

F1-Dash (Swift Edition) is a complete rewrite of the original F1-Dash project, transitioning from a Rust/Next.js stack to a pure Swift ecosystem. The project is composed of two primary components:

1.  **F1-Dash Server:** A backend service built with the **Hummingbird** web framework. Its primary responsibility is to connect to the official Formula 1 SignalR live timing feed, process the high-frequency data stream, and serve a simplified, real-time feed via WebSockets.
2.  **F1-Dash Client:** A multi-platform Swift application with tailored experiences for each OS:
    *   **macOS:** A native **menu bar application** (`MenuBarExtra`) providing at-a-glance F1 session information in a compact popover.
    *   **iOS & iPadOS:** A **fully-featured application** offering a comprehensive dashboard with detailed views for all live timing data, weather, standings, and more.

The primary goal is to establish a solid Swift foundation, delivering a focused, real-time utility on macOS and a rich, deep-dive experience on iOS/iPadOS.

**2. Target Platform**

*   **Server:**
    *   **OS:** macOS / Linux
    *   **Swift Version:** Swift 6.0+
    *   **Framework:** Hummingbird 2.0+
*   **Client (F1-Dash):**
    *   **Operating Systems:** macOS 15.0+, iOS 18.0+, iPadOS 18.0+
    *   **Architecture:** Universal Binary
    *   **Swift Version:** Swift 6.0+ with **Strict Concurrency Checking (`-strict-concurrency=complete`)**
    *   **UI Framework:** SwiftUI

**3. Architecture & Core Components**

**3.1. Server Architecture (Hummingbird)**
*(Unchanged from v2.1)* The server acts as a robust, stateful proxy and processor for the F1 data feed, using the Swift Actor Model for concurrency.

**3.2. Client Architecture (Multi-platform SwiftUI)**

The client is a modern, Environment-Driven SwiftUI application that shares a common core but presents a different top-level UI on macOS versus iOS/iPadOS.

*   **Key Architectural Patterns:**
    *   **Environment-Driven:** A central, observable `AppEnvironment` object is injected at the root, holding references to core services (`WebSocketClient`, `DataBufferActor`, etc.).
    *   **Observable State:** `@Observable` is used for all UI-driving state models.
    *   **Actor Model:** Networking and data buffering are isolated in Actors.

*   **Core Client Components:**
    1.  **`AppEnvironment` (@MainActor @Observable):** Central app coordinator.
    2.  **`WebSocketClient` (Actor):** Manages the WebSocket connection.
    3.  **`DataBufferActor` (Actor):** Manages the time-delay buffer for the data stream.
    4.  **`LiveSessionState` (@MainActor @Observable):** The source of truth for all live UI data.
    5.  **`SettingsStore` (@MainActor @Observable):** Manages user settings via **`swift-sharing`**.

**4. Data Models (Shared Swift Package: `F1DashModels`)**
*(Unchanged from v2.1)* A shared package defines `Codable` & `Sendable` models for type-safe communication.

**5. Detailed Feature Specifications**

**5.1. Server**
*(Unchanged from v2.1)* Connect to SignalR, process data, and broadcast via a `/v1/live` WebSocket endpoint. Expose a `/api/schedule` REST endpoint.

**5.2. Client (Platform-Specific)**

**A. macOS Target (Menu Bar App)**
*   **Primary UI:** An `MenuBarExtra` scene.
*   **Status Item:** The menu bar icon's color will reflect the live track status (Green, Yellow, Red, etc.).
*   **Popover UI:** Clicking the status item presents a popover containing a compact, non-scrollable `ContentView`. This view will feature:
    *   A primary **Track Map View** (`Canvas`).
    *   A compact, scrollable **Driver List View** below the map.
*   **Settings:** Accessible via a menu item in the popover, opening a standard `Settings` window.

**B. iOS & iPadOS Target (Fully-Featured App)**
*   **Primary UI:** A `WindowGroup` scene whose root view is a `TabView`.
*   **Navigation:** The `TabView` will use the `.sidebarAdaptable` style to automatically present as a tab bar on iPhone and a `NavigationSplitView` (sidebar) on iPad.
*   **Feature-Complete Views:** The app will contain distinct tabs/sections for all features present in the original web UI:
    *   **Dashboard:** The main leaderboard, track map, and other widgets.
    *   **Standings:** Live championship standings view.
    *   **Weather:** Detailed weather information, including the rain radar map.
    *   **Driver Detail:** A navigable view to see detailed telemetry for a single driver (lap times, gaps, pedal inputs, etc.).
    *   **Settings:** A comprehensive in-app settings screen.

**6. Data Storage & Persistence (Client)**
*(Unchanged from v2.1)* All user settings (`launchAtLogin`, `favoriteDriverIDs`, `dataDelay`) will be managed via the **`swift-sharing`** library for a robust, testable persistence layer.

**7. Error Handling & Resilience**
*(Unchanged from v2.1)* Both server and client will implement robust reconnection logic. The client UI will clearly indicate connection status.

**8. Development & Testing**
*(Unchanged from v2.1)* The `F1DashSaver` utility and the server's `--simulate` mode are critical for client development and remain as specified.

**9. Project Scaffolding & Structure**
*(Unchanged from v2.1)* The project will remain a Swift Package Manager (SPM) monorepo. The client Xcode project will link the shared `F1DashModels` library.

**10. File Organization (Revised for Multi-platform UI)**

```
/F1-Dash-Swift
├── Package.swift
├── Sources/
│   ├── F1DashServer/
│   ├── F1DashSaver/
│   └── F1DashModels/
│
└── F1-Dash.app/                # Xcode Project for the macOS, iOS, iPadOS App
    ├── F1-Dash.xcodeproj
    └── F1-Dash/
        ├── App/
        │   ├── F1DashApp.swift         // App entry point with #if os(macOS) logic
        │   ├── AppEnvironment.swift    // Shared @Observable coordinator
        │   └── SettingsScene.swift     // Shared Settings() scene
        │
        ├── Services/                   // Shared Services
        │   ├── WebSocketClient.swift
        │   └── DataBufferActor.swift
        │
        ├── State/                      // Shared State
        │   └── LiveSessionState.swift
        │
        ├── Features/                   // Shared Features
        │   ├── Dashboard/
        │   ├── TrackMap/
        │   ├── Standings/
        │   ├── Weather/
        │   └── Settings/
        │
        ├── Platform/                   // Platform-specific root views
        │   ├── macOS/
        │   │   └── PopoverContentView.swift // The view for the MenuBarExtra
        │   └── iOS/
        │       └── MainTabView.swift        // The TabView for iOS/iPadOS
        │
        └── Shared/
            ├── Components/             // Reusable views (DriverTag, Flag, etc.)
            └── Models/                 // View-specific models
```

**11. Technical Implementation Details**
*(Unchanged from v2.1)*

**12. Dependencies**
*(Unchanged from v2.1)*

---
This revised specification now accurately reflects your goal: a lightweight macOS utility and a full-featured iOS/iPadOS application, both built on a shared Swift core. This is a powerful and efficient way to structure a modern Apple-platform project.
