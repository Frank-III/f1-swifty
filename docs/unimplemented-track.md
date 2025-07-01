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

-   **Status:** ⚠️ Partial
-   **Summary:** The UI for team radio exists, but the audio playback functionality is not implemented.

### Document References

-   **`docs/f1-dash-client.md`**:
    -   The `components/dashboard/TeamRadios.tsx` component shows a list of radio messages with play buttons.

### Proposed Implementation in Swift

-   **Location:** `Sources/F1DashApp/Features/Dashboard/TeamRadioView.swift`
-   **Implementation Plan:**
    1.  **Locate the To-Do:** In `TeamRadioRow`, find the comment `// TODO: Implement audio playback`.
    2.  **Use AVFoundation:** Import the `AVFoundation` framework.
    3.  **Implement Playback:** Create an instance of `AVPlayer` within the `TeamRadioRow`. When the play button is tapped, use the `capture.audioURL` property to create an `AVPlayerItem` and play the audio. You will need to manage the player's state to update the UI (e.g., show a pause icon while playing).

---

## 3. Client: Live Championship Standings

-   **Status:** ❌ Missing
-   **Summary:** A view to display the predicted championship standings during a race is not implemented.

### Document References

-   **`docs/f1-dash-client.md`**:
    -   The `app/dashboard/standings/page.tsx` file defines the UI for showing live driver and team championship standings, including changes in position and points.

### Proposed Implementation in Swift

-   **Location:**
    -   Create a new file: `Sources/F1DashApp/Features/Dashboard/StandingsView.swift`.
    -   Modify `Sources/F1DashApp/Features/Dashboard/DashboardView.swift`.
-   **Implementation Plan:**
    1.  **Add Tab:** Add a new `case standings = "Standings"` to the `DashboardTab` enum in `DashboardView.swift`.
    2.  **Create View:** Implement `StandingsView.swift`. This view should use `@Environment(AppEnvironment.self)` to access `appEnvironment.liveSessionState.championshipPrediction`.
    3.  **Display Data:** If the data is available, iterate through the `drivers` and `teams` dictionaries in the `championshipPrediction` object to display the standings, including current vs. predicted positions and points.

---

## 4. Client: Car Metrics (RPM, Throttle, etc.)

-   **Status:** ❌ Missing
-   **Summary:** The client does not display detailed, live car telemetry like RPM, speed, throttle, and brake input.

### Document References

-   **`docs/f1-dash-client.md`**:
    -   The `components/driver/DriverPedals.tsx` and `components/driver/DriverCarMetrics.tsx` components are designed to visualize this data.

### Proposed Implementation in Swift

-   **Location:**
    -   Create a new file: `Sources/F1DashApp/Features/Dashboard/CarMetricsView.swift`.
    -   Modify `Sources/F1DashApp/State/LiveSessionState.swift` and `LapTimeDetailView.swift`.
-   **Implementation Plan:**
    1.  **Update State:** Ensure that `CarData` from the `F1State` is being correctly decoded and stored in `LiveSessionState`. The `CarData` model already exists in `F1DashModels`.
    2.  **Create Component:** Build `CarMetricsView.swift`. This view will take `CarDataChannels` as an input.
    3.  **Visualize Data:** Inside `CarMetricsView`, use SwiftUI `ProgressView` or custom-drawn shapes to create gauges for RPM, speed, throttle, and brake.
    4.  **Integrate:** Add the `CarMetricsView` to the `LapTimeDetailView` popover to show live telemetry for the selected driver.

---

## 5. Client: Detailed Tire Information

-   **Status:** ⚠️ Partial
-   **Summary:** Tire data is modeled but not clearly visualized in the UI.

### Document References

-   **`docs/f1-dash-client.md`**:
    -   The `components/driver/DriverTire.tsx` component shows the current tire compound, its age in laps, and the number of pit stops.

### Proposed Implementation in Swift

-   **Location:**
    -   Create a new file: `Sources/F1DashApp/Features/Dashboard/TireInfoView.swift`.
    -   Modify `Sources/F1DashApp/Features/Dashboard/DriverRowView.swift`.
-   **Implementation Plan:**
    1.  **Create Component:** Build `TireInfoView.swift`. It should accept a `[Stint]` array.
    2.  **Display Logic:** The view should display the *last* stint from the array. It should show an icon for the `compound` (you can create a helper to map `TireCompound` enum to a system Image or custom asset) and display the `totalLaps`.
    3.  **Integrate:** Add an instance of `TireInfoView` to the `DriverRowView` to show the current tire for each driver in the main list.

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
