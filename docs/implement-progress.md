# Implementation Progress

This document tracks the feature parity between the functionality described in the project's documentation (`docs/f1-dash-server.md` and `docs/f1-dash-client.md`) and the current implementation in the `Sources` directory.

There is a notable architectural difference:
-   **Documentation:** Describes a Rust-based backend and a web-based (Next.js) frontend.
-   **Implementation:** Consists of a native Swift stack, including a Hummingbird-based server (`F1DashServer`) and a native SwiftUI client for macOS/iOS (`F1DashApp`).

This report maps the features from the documented architecture to their corresponding implementations in the Swift codebase.

---

### F1-Dash Server Implementation Status

The `F1DashServer` target in Swift largely mirrors the functionality of the Rust server described in `docs/f1-dash-server.md`.

| Feature | Documented (Rust) | Implemented (Swift) | File Path(s) | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Live Data Connection** | `crates/client` | `SignalRClientActor` | `Sources/F1DashServer/Actors/SignalRClientActor.swift` | ✅ Implemented | Connects to the F1 SignalR feed and subscribes to topics. |
| **Data Simulation** | `crates/simulator` | `SignalRClientActor.connectSimulation` | `Sources/F1DashServer/Actors/SignalRClientActor.swift` | ✅ Implemented | Can replay data from a log file instead of connecting to the live feed. |
| **Data Processing** | `crates/data` | `DataProcessingActor` | `Sources/F1DashServer/Actors/DataProcessingActor.swift` | ✅ Implemented | Handles message parsing, decompression of `.z` topics, and key transformation. |
| **State Management** | `crates/client/consumers.rs` | `SessionStateCache` | `Sources/F1DashServer/Actors/SessionStateCache.swift` | ✅ Implemented | Maintains the canonical `F1State` and handles subscriptions. |
| **WebSocket Server** | `services/live` | `WebSocketManager`, `ConnectionManager` | `Sources/F1DashServer/Services/WebSocketManager.swift`, `Sources/F1DashServer/Services/ConnectionManager.swift`, `Application+build.swift` | ✅ Implemented | Broadcasts state updates to connected clients via WebSockets. |
| **REST API** | `services/api` | `APIRouter` | `Sources/F1DashServer/Services/APIRouter.swift` | ✅ Implemented | Provides `/health`, `/schedule`, `/state`, and `/stats` endpoints. |
| **Data Persistence** | `crates/timescale`, `services/importer` | Not Implemented | N/A | ❌ Missing | The Swift server is in-memory only. There is no database persistence (TimescaleDB) or data importer service. |
| **Analytics Service** | `services/analytics` | Not Implemented | N/A | ❌ Missing | No analytics endpoints (e.g., for historical lap times/gaps) are implemented. |
| **Data Recorder** | `crates/saver` | `F1DashSaver` | `Sources/F1DashSaver/F1DashSaver.swift` | ✅ Implemented | A separate command-line utility to record live data, analogous to the Rust `saver` crate. |

---

### F1-Dash Client Implementation Status

The `F1DashApp` target is a native SwiftUI application for macOS and iOS. It implements many, but not all, of the features described for the web client in `docs/f1-dash-client.md`.

| Feature Category | Feature | Documented (Web) | Implemented (SwiftUI) | File Path(s) | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Core App** | Main App Structure | `app/layout.tsx` | `F1DashApp.swift` | `Sources/F1DashApp/F1DashApp.swift` | ✅ Implemented | Defines the main app, scenes, windows, and menu bar extra. |
| | State Management | `stores/useDataStore.ts` | `LiveSessionState` | `Sources/F1DashApp/State/LiveSessionState.swift` | ✅ Implemented | Manages all live session data. |
| | Central Coordinator | N/A | `AppEnvironment` | `Sources/F1DashApp/App/AppEnvironment.swift` | ✅ Implemented | Coordinates services and state. |
| **Data Handling** | WebSocket Client | `hooks/useSocket.ts` | `WebSocketClient` | `Sources/F1DashApp/Services/WebSocketClient.swift` | ✅ Implemented | Connects to the local `F1DashServer`. |
| | Data Delay/Buffer | `hooks/useBuffer.ts` | `DataBufferActor` | `Sources/F1DashApp/Services/DataBufferActor.swift` | ✅ Implemented | Manages a time-delay buffer for syncing with broadcasts. |
| **Dashboard** | Main View / Layout | `app/dashboard/page.tsx` | `DashboardView` | `Sources/F1DashApp/Features/Dashboard/DashboardView.swift` | ✅ Implemented | Tabbed interface for different data views. |
| | Leaderboard | `components/dashboard/LeaderBoard.tsx` | `DriverListView` | `Sources/F1DashApp/Features/Dashboard/DriverListView.swift` | ✅ Implemented | Shows driver list with position, name, gap, and last lap. |
| | Track Map | `components/dashboard/Map.tsx` | `TrackMapView` | `Sources/F1DashApp/Features/TrackMap/TrackMapView.swift` | ✅ Implemented | 2D map with live driver positions. |
| | Race Control | `components/dashboard/RaceControl.tsx` | `RaceControlView` | `Sources/F1DashApp/Features/Dashboard/RaceControlView.swift` | ✅ Implemented | Displays messages from race control. |
| | Team Radio | `components/dashboard/TeamRadios.tsx` | `TeamRadioView` | `Sources/F1DashApp/Features/Dashboard/TeamRadioView.swift` | ⚠️ Partial | UI is present, but audio playback is not implemented. |
| | Session Info | `components/SessionInfo.tsx` | `SessionInfoView` | `Sources/F1DashApp/Features/Dashboard/SessionInfoView.swift` | ✅ Implemented | Shows meeting, location, and session details. |
| | Track Status | `components/TrackInfo.tsx` | `TrackStatusView` | `Sources/F1DashApp/Features/Dashboard/TrackStatusView.swift` | ✅ Implemented | Displays current track flag (Green, Yellow, SC, Red). |
| | Weather Info | `components/WeatherInfo.tsx` | `WeatherView` | `Sources/F1DashApp/Features/Dashboard/WeatherView.swift` | ✅ Implemented | Shows temps, wind, humidity, etc. |
| | Standings | `app/dashboard/standings/page.tsx` | Not Implemented | N/A | ❌ Missing | Live championship standings prediction view is not implemented. |
| | Track Violations | `components/dashboard/TrackViolations.tsx` | Not Implemented | N/A | ❌ Missing | No specific view for track limit violations. |
| **Driver Details** | Detailed View | `app/dashboard/driver/[nr]/page.tsx` | `LapTimeDetailView` | `Sources/F1DashApp/Features/Dashboard/LapTimeDetailView.swift` | ✅ Implemented | A popover showing detailed lap/sector times. |
| | Tire Info | `components/driver/DriverTire.tsx` | Not directly visible | `F1DashModels/TimingAppData.swift` | ⚠️ Partial | Tire data (`Stint`) is modeled but not explicitly displayed in a dedicated component like the web version. |
| | Car Metrics (Pedals, RPM) | `components/driver/DriverPedals.tsx` | Not Implemented | N/A | ❌ Missing | Live car telemetry (throttle, brake, RPM, gear) is not displayed. |
| **Weather** | Weather Map | `app/dashboard/weather/map.tsx` | Not Implemented | N/A | ❌ Missing | The detailed weather radar map with timeline is not implemented. The track map is for car positions only. |
| **Settings** | Settings View | `app/dashboard/settings/page.tsx` | `SettingsView` | `Sources/F1DashApp/Features/Settings/SettingsView.swift` | ✅ Implemented | Provides UI for General, Driver, and Data settings. |
| | Favorite Drivers | `components/settings/FavoriteDrivers.tsx` | `DriversSettingsView` | `Sources/F1DashApp/Features/Settings/SettingsView.swift` | ✅ Implemented | Allows selecting and highlighting favorite drivers. |
| | Data Delay | `components/DelayInput.tsx` | `DataSettingsView` | `Sources/F1DashApp/Features/Settings/SettingsView.swift` | ✅ Implemented | UI for setting a data delay. |
| **Other** | Schedule View | `app/(nav)/schedule/page.tsx` | Not Implemented | N/A | ❌ Missing | A dedicated schedule view is not implemented. The server has a schedule API, but the client doesn't use it. |
| | Notifications | N/A | `NotificationManager` | `Sources/F1DashApp/Services/NotificationManager.swift` | ✅ Implemented | Sends user notifications for key events (Red Flag, SC, New Leader, etc.). This is a native-only feature. |
| | Popover View | N/A | `PopoverDashboardView` | `Sources/F1DashApp/Features/Dashboard/DashboardView.swift` | ✅ Implemented | A compact dashboard for the macOS menu bar. This is a native-only feature. |

---

### Summary & Areas for Improvement

**Server (`F1DashServer`)**
-   **Strengths:** The Swift server successfully implements the core real-time data pipeline: connecting to the F1 feed, processing data, and broadcasting it to clients via WebSockets. It also includes a simulation mode and a basic REST API.
-   **Gaps:** The most significant missing piece is data persistence. The Rust server's design includes integration with TimescaleDB for storing and later analyzing historical data. This entire `importer`/`analytics` functionality is absent in the Swift version.

**Client (`F1DashApp`)**
-   **Strengths:** The native SwiftUI client provides a robust and feature-rich dashboard experience for macOS, including a unique menu bar popover. It covers most of the critical real-time views: leaderboard, track map, race control, weather, and session status. It also has a comprehensive settings system.
-   **Gaps:**
    1.  **Deeper Data Visualization:** Features requiring more detailed data visualization, like the weather radar map and live car telemetry (pedals, RPM), are not implemented.
    2.  **Historical/Static Data:** Views for non-real-time data, such as the full race schedule and live championship standings, are missing.
    3.  **Tire Data:** While the data models exist, there isn't a clear, dedicated UI component for visualizing stint history and tire compound details for each driver as shown in the web client docs.
