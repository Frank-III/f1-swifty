# Unimplemented Features Tracking

This document provides a starting point for implementing features that are currently missing or incomplete in the Swift version of F1-Dash, based on the project's documentation.

---

## 1. Server: Data Persistence & Analytics

-   **Status:** ❌ Missing
-   **Summary:** The Swift server is currently in-memory only. The documented Rust version includes services for persisting data to a TimescaleDB database (`importer`) and querying it for analytics (`analytics`).

### Document References

-   **`docs/f1-dash-server.md`**:
    -   The entire `crates/timescale` directory, which defines the database schema and queries.
    -   The `services/importer` crate, responsible for listening to live data and writing it to the database.
    -   The `services/analytics` crate, which exposes API endpoints to query historical data (e.g., `/api/laptime/{driver_nr}`).

    ```
    /crates/timescale/src/lib.rs
    /crates/timescale/src/timing.rs
    /services/importer/src/main.rs
    /services/analytics/src/main.rs
    ```

### Proposed Implementation in Swift

-   **Location:**
    -   Create a new target/directory: `Sources/F1DashPersistence`.
    -   Add a dependency to a PostgreSQL/TimescaleDB driver, such as `vapor/postgres-nio`.
-   **Implementation Plan:**
    1.  **Database Manager:** Create a `DatabaseManager.swift` class within the new target to handle the database connection pool.
    2.  **Importer Logic:** In `F1DashServer/Application+build.swift`, after a `stateUpdate` is applied to `SessionStateCache`, add a new step to asynchronously write the relevant models (`TimingData`, `TimingAppData`, etc.) to the database. This mirrors the logic in `services/importer/src/main.rs`.
    3.  **Analytics API:** Extend `APIRouter.swift` to include new endpoints like `/api/analytics/laptimes/{driver_nr}`. These endpoints would use the `DatabaseManager` to query the database and return historical data, similar to `services/analytics/src/server/laptime.rs`.

---

## 2. Client: Team Radio Audio Playback

-   **Status:** ✅ Completed
-   **Summary:** Full audio playback functionality implemented using AVFoundation with modern @Observable state management.

### Document References

-   **`docs/f1-dash-client.md`**:
    -   The `components/dashboard/TeamRadios.tsx` component shows a list of radio messages with play buttons.

### Implementation Details

-   **Location:** `Sources/F1DashApp/Features/Dashboard/TeamRadioView.swift`
-   **Implementation:**
    1.  **AudioPlayerManager:** Created an `@Observable` class using modern Swift concurrency patterns.
    2.  **AVFoundation Integration:** Uses `AVPlayer` for audio playback with proper lifecycle management.
    3.  **UI State Management:** Play/pause button dynamically updates based on current audio state.
    4.  **Audio Session Handling:** Proper cleanup and notification observers for audio completion.

---

## 3. Client: Live Championship Standings

-   **Status:** ✅ Completed
-   **Summary:** Full championship standings view implemented with drivers and constructors predictions.

### Document References

-   **`docs/f1-dash-client.md`**:
    -   The `app/dashboard/standings/page.tsx` file defines the UI for showing live driver and team championship standings, including changes in position and points.

### Implementation Details

-   **Location:**
    -   `Sources/F1DashApp/Features/Dashboard/StandingsView.swift`
    -   `Sources/F1DashApp/Features/Dashboard/DashboardView.swift`
-   **Implementation:**
    1.  **Dashboard Integration:** Added "Standings" tab with trophy icon to the main dashboard.
    2.  **StandingsView:** Comprehensive view showing both drivers and constructors championships.
    3.  **Position Tracking:** Displays current vs. predicted positions with visual indicators for changes.
    4.  **Points Delta:** Color-coded point changes (green for gains, red for losses).
    5.  **Driver Integration:** Links championship data with driver info including team colors and TLA.

---

## 4. Client: Car Metrics (RPM, Throttle, etc.)

-   **Status:** ✅ Completed
-   **Summary:** Comprehensive car telemetry visualization implemented with gauges, bars, and indicators.

### Document References

-   **`docs/f1-dash-client.md`**:
    -   The `components/driver/DriverPedals.tsx` and `components/driver/DriverCarMetrics.tsx` components are designed to visualize this data.

### Implementation Details

-   **Location:**
    -   `Sources/F1DashApp/Features/Dashboard/CarMetricsView.swift`
    -   `Sources/F1DashApp/Features/Dashboard/LapTimeDetailView.swift`
-   **Implementation:**
    1.  **RPM Gauge:** Circular progress indicator with color-coded zones (green/yellow/red based on RPM ranges).
    2.  **Speed Display:** Digital readout with km/h units in a circular background.
    3.  **Throttle/Brake Bars:** Vertical bar gauges showing percentage input with appropriate colors.
    4.  **Gear Indicator:** Digital display supporting forward gears, neutral (N), and reverse (R).
    5.  **DRS Indicator:** Visual indicator showing DRS activation status.
    6.  **Integration:** Added to driver detail popover for comprehensive telemetry viewing.

---

## 5. Client: Detailed Tire Information

-   **Status:** ✅ Completed
-   **Summary:** Comprehensive tire strategy visualization implemented in both compact and detailed views.

### Document References

-   **`docs/f1-dash-client.md`**:
    -   The `components/driver/DriverTire.tsx` component shows the current tire compound, its age in laps, and the number of pit stops.

### Implementation Details

-   **Location:**
    -   `Sources/F1DashApp/Features/Dashboard/TireInfoView.swift`
    -   `Sources/F1DashApp/Features/Dashboard/DriverListView.swift`
    -   `Sources/F1DashApp/Features/Dashboard/LapTimeDetailView.swift`
-   **Implementation:**
    1.  **Compact View:** Shows current tire compound with color-coded circles, lap count, and new tire indicators in driver list.
    2.  **Stint History:** Displays previous compounds as small colored circles for quick reference.
    3.  **Detailed View:** Comprehensive stint table in driver detail popover showing all stint information.
    4.  **Tire Compound Colors:** Accurate F1 tire colors (red/soft, yellow/medium, white/hard, green/intermediate, blue/wet).
    5.  **Condition Indicators:** Shows "New" and "Current" stint status with appropriate styling.

---

## 6. Client: Weather Radar Map

-   **Status:** ❌ Missing
-   **Summary:** The app lacks a dedicated weather map with a timeline for viewing rain radar overlays.

### Document References

-   **`docs/f1-dash-client.md`**:
    -   `app/dashboard/weather/map.tsx` and `map-timeline.tsx` describe a map view that fetches data from Rainviewer and displays it with a playable timeline.

### Proposed Implementation in Swift

-   **Location:**
    -   Create a new file: `Sources/F1DashApp/Features/Weather/WeatherMapView.swift`.
    -   Modify `Sources/F1DashApp/Features/Dashboard/DashboardView.swift`.
-   **Implementation Plan:**
    1.  **Networking:** Create a simple networking service to fetch data from the Rainviewer API (`https://api.rainviewer.com/public/weather-maps.json`).
    2.  **Map Integration:** Use Apple's `MapKit`. You will need to create a custom `MKTileOverlay` to render the radar image tiles from the URLs provided by the Rainviewer API.
    3.  **Timeline UI:** Create a custom slider or control that represents the timeline of available radar frames (`map-timeline.tsx`).
    4.  **View:** Create `WeatherMapView.swift` to contain the map and the timeline control. Add a new "Weather Map" tab to `DashboardView` to display it.

---

## 7. Client: Race Schedule View

-   **Status:** ❌ Missing
-   **Summary:** The client does not have a view to display the F1 race schedule for the season.

### Document References

-   **`docs/f1-dash-client.md`**:
    -   The `app/(nav)/schedule/page.tsx` file and `components/schedule` directory describe a feature that fetches and displays the full F1 schedule.

### Proposed Implementation in Swift

-   **Location:**
    -   Create a new directory: `Sources/F1DashApp/Features/Schedule`.
    -   Create a new file: `Sources/F1DashApp/Features/Schedule/ScheduleView.swift`.
-   **Implementation Plan:**
    1.  **Networking:** Create a simple networking service to make a `GET` request to the `/api/schedule` endpoint on the `F1DashServer`.
    2.  **Data Model:** The `RaceRound` and `RaceSession` models are already defined in `F1DashServer/Services/APIRouter.swift`. You may need to move these to `F1DashModels` to share them with the client.
    3.  **Create View:** Implement `ScheduleView.swift`. This view will perform the network request, decode the JSON response into the shared models, and display the schedule in a `List`.
    4.  **Integrate:** Add a button or tab in the main app interface to present the `ScheduleView`.
