# Apple Platform Development — Documentation Index

Below is a map of the Markdown references contained in this folder.  Each entry links to the source file and gives a terse description so you (or an LLM) can jump straight to the most relevant resource.

## Swift Language & Concurrency

- **[swift-concurrency.md](swift-concurrency.md)** – A 1-stop, 1 600-line guide to Swift 6's strict concurrency model: actors, `Sendable`, data-race safety, migration steps, compiler flags, and code recipes.

## SwiftUI

- **[swiftui.md](swiftui.md)** – Full offline mirror of Apple's official SwiftUI framework documentation (all APIs, guides, and sample links).
- **[swiftui-updates.md](swiftui-updates.md)** – Official changelog of SwiftUI framework updates, detailing new features and APIs from recent WWDC sessions (iOS/iPadOS/macOS26).
- **[ios26.md](ios26.md)** – A summary of new SwiftUI APIs introduced in the iOS 26 SDK, including Liquid Glass effects, enhanced scrolling, and more.
- **[modern-swift.md](modern-swift.md)** – Best-practice handbook for writing idiomatic, modern SwiftUI apps: native state management, async/await patterns, and file/folder organization.
- **[swiftui-in-2025-forget-mvvm.md](swiftui-in-2025-forget-mvvm.md)** – Opinionated essay (2025) arguing why MVVM is unnecessary in SwiftUI; demonstrates environment-driven architecture with real-world code snippets.

## Data Persistence

- **[modern-persistent.md](modern-persistent.md)** – End-to-end sample project showcasing [Sharing-GRDB](https://github.com/pointfreeco/sharing-grdb) & [Swift-Structure-Queries](https://github.com/pointfreeco/swift-structured-queries), including full source files for reminder lists, schema generation, queries, and SwiftUI integration.
- **[swift-sharing-doc.md](swift-sharing-doc.md)** – Offline copy of Point-Free's Sharing library reference (v2.5.2) covering `@Shared`, persistence strategies (`appStorage`, `fileStorage`, `inMemory`), testing, and advanced usage.
- **[swift-sharing-example.md](swift-sharing-example.md)** – Comprehensive example app showcasing Sharing case studies: global router, persistence strategies, SwiftUI bindings, UIKit integration, and more.
- **[swifty-json-doc.md](swifty-json-doc.md)** – Documentation for the SwiftyJSON library, a popular tool for handling JSON data in Swift.

## Dependency Management

- **[swift-dependencies.md](swift-dependencies.md)** – Offline documentation for Point-Free's Dependencies library, covering dependency management, registration, testing, and advanced usage.

## Testing

- **[swift-testing-playbook.md](swift-testing-playbook.md)** – WWDC 2024-style playbook for migrating from XCTest to the new Swift Testing framework; covers `#expect`, `#require`, suite lifecycle, and parallel execution.

## Server-Side Swift

- **[hummingbird-doc.md](hummingbird-doc.md)** – Snapshot of the Hummingbird 2.0 docs: lightweight Swift server framework with routing, middleware, TLS, HTTP/2, and request/response abstractions.

## Sample Projects

- **[iOS:macOS26-demo.txt](iOS:macOS26-demo.txt)** – Directory structure and file listing for the 'Landmarks' demo app, showcasing iOS 26 APIs.
