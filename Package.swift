// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "F1DashSwift",
    platforms: [
        .macOS(.v15),
        .iOS(.v18)
    ],
    products: [
        // F1DashModels - Shared data models library
        .library(
            name: "F1DashModels",
            targets: ["F1DashModels"]
        ),
        // F1DashPersistence - Database persistence library
        .library(
            name: "F1DashPersistence",
            targets: ["F1DashPersistence"]
        ),
        // F1DashServer - Main server executable
        .executable(
            name: "F1DashServer",
            targets: ["F1DashServer"]
        ),
        // F1DashSaver - Data recording utility
        .executable(
            name: "F1DashSaver",
            targets: ["F1DashSaver"]
        ),
        // F1DashApp - Client application executable
        .executable(
            name: "F1DashApp",
            targets: ["F1DashApp"]
        ),
    ],
    dependencies: [
        // Hummingbird web framework
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.0.0"),
        // Hummingbird WebSocket support
        .package(url: "https://github.com/hummingbird-project/hummingbird-websocket", from: "2.0.0"),
        // SignalR client for Swift
        .package(url: "https://github.com/dotnet/signalr-client-swift", from: "1.0.0-preview.4"),
        // Swift Distributed Tracing for observability
        .package(url: "https://github.com/apple/swift-distributed-tracing", from: "1.0.0"),
        // Swift Log for structured logging
        .package(url: "https://github.com/apple/swift-log", from: "1.6.1"),
        // Swift Argument Parser for CLI
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        // Swift Sharing for client app settings
        .package(url: "https://github.com/pointfreeco/swift-sharing", from: "1.0.0"),
        // PostgreSQL driver for data persistence
        .package(url: "https://github.com/vapor/postgres-nio", from: "1.26.0"),
    ],
    targets: [
        // MARK: - Shared Models Library
        .target(
            name: "F1DashModels",
            dependencies: [
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        
        // MARK: - Persistence Library
        .target(
            name: "F1DashPersistence",
            dependencies: [
                "F1DashModels",
                .product(name: "PostgresNIO", package: "postgres-nio"),
                .product(name: "Logging", package: "swift-log"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        
        // MARK: - Server Executable
        .executableTarget(
            name: "F1DashServer",
            dependencies: [
                "F1DashModels",
                "F1DashPersistence",
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "HummingbirdWebSocket", package: "hummingbird-websocket"),
                .product(name: "HummingbirdWSCompression", package: "hummingbird-websocket"),
                .product(name: "SignalRClient", package: "signalr-client-swift"),
                .product(name: "Tracing", package: "swift-distributed-tracing"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        
        // MARK: - Data Saver Utility
        .executableTarget(
            name: "F1DashSaver",
            dependencies: [
                "F1DashModels",
                .product(name: "SignalRClient", package: "signalr-client-swift"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        
        // MARK: - Tests
        .testTarget(
            name: "F1DashModelsTests",
            dependencies: ["F1DashModels"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        .testTarget(
            name: "F1DashServerTests",
            dependencies: ["F1DashServer"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        .testTarget(
            name: "F1DashAppTests",
            dependencies: ["F1DashApp"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        
        // MARK: - Client Application
        .executableTarget(
            name: "F1DashApp",
            dependencies: [
                "F1DashModels",
                .product(name: "Sharing", package: "swift-sharing"),
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
    ]
)
