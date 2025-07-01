# F1 Dash Swift

A native macOS client for F1 live timing data, built with Swift and SwiftUI.

## Overview

F1 Dash Swift is a complete rewrite of the original TypeScript/React F1 Dash client in pure Swift. It provides real-time Formula 1 timing data in a native macOS menu bar application.

### Features

- **Menu Bar App**: Lives in your macOS menu bar for quick access
- **Live Timing Data**: Real-time driver positions, lap times, and sector information
- **Track Map Visualization**: Visual representation of driver positions on track
- **Weather Information**: Current track and weather conditions
- **Race Control Messages**: Official race control communications
- **Team Radio**: Team radio message notifications
- **Notifications**: Configurable notifications for important events
- **Favorite Drivers**: Highlight and track your favorite drivers
- **Data Delay**: Configurable delay to sync with TV broadcasts

## Architecture

The project consists of several components:

### F1DashModels
Shared data models used across all components.

### F1DashServer
A Hummingbird-based server that:
- Connects to the official F1 SignalR feed
- Processes and transforms the data
- Serves data to clients via WebSocket

### F1DashApp
The SwiftUI-based macOS client application featuring:
- Menu bar integration
- Real-time data visualization
- Settings and preferences
- Track map visualization

### F1DashSaver
A utility for recording F1 session data to disk for later analysis.

## Building and Running

### Requirements

- macOS 15.0+
- Xcode 16.0+
- Swift 6.0+

### Build Instructions

1. Clone the repository:
```bash
git clone https://github.com/yourusername/f1-dash-swift.git
cd f1-dash-swift
```

2. Build the server:
```bash
swift build --product F1DashServer
```

3. Build the macOS app:
```bash
swift build --product F1DashMacApp
```

### Running

1. Start the server:
```bash
.build/debug/F1DashServer serve
```

2. Run the macOS app:
```bash
.build/debug/F1DashMacApp
```

The app will appear in your menu bar with a checkered flag icon.

## Development

### Project Structure

```
f1-dash-swift/
├── Sources/
│   ├── F1DashModels/       # Shared data models
│   ├── F1DashServer/       # Server implementation
│   ├── F1DashApp/          # Client app implementation
│   │   ├── App/            # App lifecycle and environment
│   │   ├── Features/       # Feature modules
│   │   ├── Services/       # Business logic and networking
│   │   ├── State/          # State management
│   │   └── Resources/      # Assets and configuration
│   ├── F1DashSaver/        # Data recording utility
│   └── F1DashMacApp/       # macOS app entry point
├── Tests/                  # Unit tests
└── Package.swift           # Swift package manifest
```

### Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **Swift Concurrency**: Async/await and actors for thread-safe operations
- **Observation**: Swift's new observation framework for reactive UI
- **Hummingbird**: Lightweight web framework for the server
- **SignalR**: Real-time communication with F1 data feed
- **WebSocket**: Client-server communication

## Configuration

The app stores its settings in `~/Library/Preferences/com.f1dash.app.plist`.

### Available Settings

- **Launch at Login**: Start F1 Dash when macOS starts
- **Show Notifications**: Enable/disable system notifications
- **Compact Mode**: Use a more condensed UI
- **Track Map Zoom**: Adjust the zoom level of the track map
- **Favorite Drivers**: Select drivers to highlight
- **Data Delay**: Add delay to sync with broadcasts

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Original F1 Dash project for the inspiration
- Formula 1 for providing the live timing data feed
- The Swift community for excellent tools and frameworks
