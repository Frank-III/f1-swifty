// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "F1DashModels",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "F1DashModels",
            targets: ["F1DashModels"]
        )
    ],
    targets: [
        .target(
            name: "F1DashModels",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny")
            ]
        )
    ]
)