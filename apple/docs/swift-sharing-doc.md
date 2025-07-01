<!--
Downloaded via https://llm.codes by @steipete on June 26, 2025 at 07:44 PM
Source URL: https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing
Total pages processed: 192
URLs filtered: Yes
Content de-duplicated: Yes
Availability strings filtered: Yes
Code blocks only: No
-->

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing

Framework

# Sharing

Instantly share state among your app’s features and external persistence layers, including user defaults, the file system, and more.

## Additional Resources

- GitHub Repo

- Discussions

## Overview

This library comes with a few tools that allow one to share state with multiple parts of your application, as well as external store systems such as user defaults, the file system, and more. The tool works in a variety of contexts, such as SwiftUI views, `@Observable` models, and UIKit view controllers, and it is completely unit testable.

As a simple example, you can have two different obsevable models hold onto a collection of data that is also synchronized to the file system:

// MeetingsList.swift
@Observable
class MeetingsListModel {
@ObservationIgnored
@Shared(.fileStorage(.meetingsURL)) var meetings: [Meeting] = []
}

// ArchivedMeetings.swift
@Observable
class ArchivedMeetingsModel {
@ObservationIgnored
@Shared(.fileStorage(.meetingsURL)) var meetings: [Meeting] = []
}

If either model makes a change to `meetings`, the other model will instantly see those changes. And further, if the file on disk changes from an external write, both instances of `@Shared` will also update to hold the freshest data.

## Automatic persistence

The `@Shared` property wrapper gives you a succinct and consistent way to persist any kind of data in your application. The library comes with 3 strategies: `appStorage`, `fileStorage`, and `inMemory`.

The `appStorage` strategy is useful for store small pieces of simple data in user defaults, such as settings:

@Shared(.appStorage("soundsOn")) var soundsOn = true
@Shared(.appStorage("hapticsOn")) var hapticsOn = true
@Shared(.appStorage("userSort")) var userSort = UserSort.name

The `fileStorage` strategy is useful for persisting more complex data types to the file system by serializing the data to bytes:

@Shared(.fileStorage(.meetingsURL)) var meetings: [Meeting] = []

And the `inMemory` strategy is useful for sharing any kind of data globably with the entire app, but it will be reset the next time the app is relaunched:

@Shared(.inMemory("events")) var events: [String] = []

See Persistence strategies for more information on leveraging the persistence strategies that come with the library, as well as creating your own strategies.

## Use anywhere

It is possible to use `@Shared` state essentially anywhere, including observable models, SwiftUI views, UIKit view controllers, and more. For example, if you have a simple view that needs access to some shared state but does not need the full power of an observable model, then you can use `@Shared` directly in the view:

struct DebugMeetingsView: View {
@Shared(.fileStorage(.meetingsURL)) var meetings: [Meeting] = []
var body: some View {
ForEach(meetings) { meeting in
Text(meeting.title)
}
}
}

Similarly, if you need to use UIKit for a particular feature or have a legacy feature that can’t use SwiftUI yet, then you can use `@Shared` directly in a view controller:

final class DebugMeetingsViewController: UIViewController {
@Shared(.fileStorage(.meetingsURL)) var meetings: [Meeting] = []
// ...
}

And to observe changes to `meetings` so that you can update the UI you can either use the `publisher` property or the `observe` tool from our Swift Navigation library. See Observing changes to shared state for more information.

## Testing shared state

Features using the `@Shared` property wrapper remain testable even though they interact with outside storage systems, such as user defaults and the file system. This is possible because each test gets a fresh storage system that is quarantined to only that test, and so any changes made to it will only be seen by that test.

See Testing for more information on how to test your features when using `@Shared`.

## Demos

The Sharing repo comes with _lots_ of examples to demonstrate how to solve common and complex problems with `@Shared`. Check out this directory to see them all, including:

- Case Studies: A number of case studies demonstrating the built-in features of the library.

- FirebaseDemo: A demo showing how shared state can be powered by a remote Firebase config.

- GRDBDemo: A demo showing how shared state can be powered by SQLite in much the same way a view can be powered by SwiftData’s `@Query` property wrapper using GRDB..

- WasmDemo: A SwiftWasm application that uses this library to share state with your web browser’s local storage.

- SyncUps: We also rebuilt Apple’s Scrumdinger demo application using modern, best practices for SwiftUI development, including using this library to share state and persist it to the file system.

## Topics

### Essentials

`struct Shared`

A property wrapper type that shares a value with other parts of the application and/or external systems.

`struct SharedReader`

A property wrapper type that shares a read-only value with multiple parts of an application.

Persistence strategies

Learn about the various persistence strategies that ship with the library, as well as how to create your own custom strategies.

Mutating shared state

Learn how to mutate shared state in a safe manner in order to prevent race conditions and data loss.

Observing changes to shared state

Learn how to observe changes to shared state in order to update your UI or react to changes.

Dynamic Keys

Learn how to dynamically change the key that powers your shared state.

Deriving shared state

Learn how to derive shared state to sub-parts of a larger piece of shared state.

Reusable, type-safe keys

Learn how to define keys for your shared state that allow you to reference your data in a statically checked and type-safe manner.

Initialization rules

Learn the various ways to initialize shared state, both when using a persistence strategy and when not.

Testing

Learn how to test features that use shared state, even when persistence strategies are involved.

Gotchas of @Shared

Learn about a few gotchas to be aware of when using shared state in your application.

### Persistence

`struct AppStorageKey`

A type defining a user defaults persistence strategy.

`class FileStorageKey`

A type defining a file persistence strategy

`struct InMemoryKey`

A type defining an in-memory persistence strategy

`typealias Default`

Provides a default value to a shared key.

### Custom persistence

`protocol SharedKey`

A type that can persist shared state to an external storage.

`protocol SharedReaderKey`

A type that can load and subscribe to state in an external system.

### Migration guides

Learn how to upgrade your application to the newest version of Sharing.

### Articles

Review unsupported shared reader APIs and their replacements.

### Extended Modules

Foundation

SwiftUICore

- Sharing
- Additional Resources
- Overview
- Automatic persistence
- Use anywhere
- Testing shared state
- Demos
- Topics

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared

- Sharing
- Shared

Structure

# Shared

A property wrapper type that shares a value with other parts of the application and/or external systems.

@dynamicMemberLookup @propertyWrapper

Shared.swift

## Overview

Use shared state to allow for multiple parts of your application to hold onto the same piece of mutable data. For example, you can have two different obsevable models hold onto a collection of data that is also synchronized to the file system:

// MeetingsList.swift
@Observable
class MeetingsListModel {
@ObservationIgnored
@Shared(.fileStorage(.meetingsURL)) var meetings: [Meeting] = []
}

// ArchivedMeetings.swift
@Observable
class ArchivedMeetingsModel {
@ObservationIgnored
@Shared(.fileStorage(.meetingsURL)) var meetings: [Meeting] = []
}

If either model makes a change to `meetings`, the other model will instantly see those changes. And further, if the file on disk changes from an external write, both instances of `@Shared` will also update to hold the freshest data.

## Automatic persistence

The `@Shared` property wrapper gives you a succinct and consistent way to persist any kind of data in your application. The library comes with 3 strategies: `appStorage`, `fileStorage`, and `inMemory`.

The `appStorage` strategy is useful for store small pieces of simple data in user defaults, such as settings:

@Shared(.appStorage("soundsOn")) var soundsOn = true
@Shared(.appStorage("hapticsOn")) var hapticsOn = true
@Shared(.appStorage("userSort")) var userSort = UserSort.name

The `fileStorage` strategy is useful for persisting more complex data types to the file system by serializing the data to bytes:

@Shared(.fileStorage(.meetingsURL)) var meetings: [Meeting] = []

And the `inMemory` strategy is useful for sharing any kind of data globably with the entire app, but it will be reset the next time the app is relaunched:

@Shared(.inMemory("events")) var events: [String] = []

See Persistence strategies for more information on leveraging the persistence strategies that come with the library, as well as creating your own strategies.

## Use anywhere

It is possible to use `@Shared` state essentially anywhere, including observable models, SwiftUI views, UIKit view controllers, and more. For example, if you have a simple view that needs access to some shared state but does not need the full power of an observable model, then you can use `@Shared` directly in the view:

struct DebugMeetingsView: View {
@Shared(.fileStorage(.meetingsURL)) var meetings: [Meeting] = []
var body: some View {
ForEach(meetings) { meeting in
Text(meeting.title)
}
}
}

Similarly, if you need to use UIKit for a particular feature or have a legacy feature that can’t use SwiftUI yet, then you can use `@Shared` directly in a view controller:

final class DebugMeetingsViewController: UIViewController {
@Shared(.fileStorage(.meetingsURL)) var meetings: [Meeting] = []
// ...
}

And to observe changes to `meetings` so that you can update the UI you can either use the `publisher` property or the `observe` tool from our Swift Navigation library. See Observing changes to shared state for more information.

## Testing

Features using the `@Shared` property wrapper remain testable even though they interact with outside storage systems, such as user defaults and the file system. This is possible because each test gets a fresh storage system that is quarantined to only that test, and so any changes made to it will only be seen by that test.

See Testing for more information on how to test your features when using `@Shared`.

## Topics

### Creating a persisted value

Creates a shared reference to a value using a shared key.

### Creating a shared value

`init(value: sending Value)`

Creates a shared reference from another shared reference.

### Transforming a shared value

Returns a shared reference to the resulting value of a given key path.

Returns a read-only shared reference to the resulting value of a given key path.

Unwraps a shared reference to an optional value.

### Accessing the value

`var wrappedValue: Value`

A projection of the shared value that returns a shared reference.

### Isolating the value

Perform an operation on shared state with isolated access to the underlying value.

### Loading and saving the value

`var isLoading: Bool`

Whether or not an associated shared key is loading data from an external source.

`func load() async throws`

Requests an up-to-date value from an external source.

Replaces a shared reference’s key and attempts to load its value.

Creates a shared reference to a value using a shared key by loading it from its external source.

`func save() async throws`

Requests the underlying value be persisted to an external source.

### Error handling

`var loadError: (any Error)?`

An error encountered during the most recent attempt to load data.

`var saveError: (any Error)?`

An error encountered during the most recent attempt to save data.

### SwiftUI integration

`extension RangeReplaceableCollection`

`extension Binding`

### Combine integration

Returns a publisher that emits events when the underlying value changes.

### Initializers

Creates a shared reference to an optional value using a shared key.

Creates a shared reference to a value using a shared key with a default value.

Creates a shared reference to a value using a shared key by overriding its default value.

### Instance Methods

Returns a read-only shared reference to the resulting value of a given closure.

## Relationships

### Conforms To

- `CustomDump.CustomDumpRepresentable`
- `Observation.Observable`
- `PerceptionCore.Perceptible`
- `Swift.Copyable`
- `Swift.CustomStringConvertible`
- `Swift.Equatable`
- `Swift.Identifiable`
- `Swift.Sendable`
- `SwiftUICore.DynamicProperty`

## See Also

### Essentials

`struct SharedReader`

A property wrapper type that shares a read-only value with multiple parts of an application.

Persistence strategies

Learn about the various persistence strategies that ship with the library, as well as how to create your own custom strategies.

Mutating shared state

Learn how to mutate shared state in a safe manner in order to prevent race conditions and data loss.

Observing changes to shared state

Learn how to observe changes to shared state in order to update your UI or react to changes.

Dynamic Keys

Learn how to dynamically change the key that powers your shared state.

Deriving shared state

Learn how to derive shared state to sub-parts of a larger piece of shared state.

Reusable, type-safe keys

Learn how to define keys for your shared state that allow you to reference your data in a statically checked and type-safe manner.

Initialization rules

Learn the various ways to initialize shared state, both when using a persistence strategy and when not.

Testing

Learn how to test features that use shared state, even when persistence strategies are involved.

Gotchas of @Shared

Learn about a few gotchas to be aware of when using shared state in your application.

- Shared
- Overview
- Automatic persistence
- Use anywhere
- Testing
- Topics
- Relationships
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/appstorage(_:store:)-45ltk



---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/filestorage(_:decoder:encoder:)

#app-main)

- Sharing
- SharedReaderKey
- fileStorage(\_:decoder:encoder:)

Type Method

# fileStorage(\_:decoder:encoder:)

Creates a shared key that can read and write to a `Codable` value in the file system.

_ url: URL,
decoder: JSONDecoder? = nil,
encoder: JSONEncoder? = nil

FileStorageKey.swift

## Parameters

`url`

The file URL from which to read and write the value.

`decoder`

The JSONDecoder to use for decoding the value.

`encoder`

The JSONEncoder to use for encoding the value.

## Return Value

A file shared key.

## Discussion

For example:

struct Settings: Codable {
var hapticsEnabled = true
// ...
}

@Shared(.fileStorage(.documentsDirectory.appending(component: "settings.json"))
var settings = Settings()

## See Also

### Storing a value

Creates a shared key that can read and write to a value in the file system.

- fileStorage(\_:decoder:encoder:)
- Parameters
- Return Value
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/inmemory(_:)

#app-main)

- Sharing
- SharedReaderKey
- inMemory(\_:)

Type Method

# inMemory(\_:)

Creates a shared key for sharing data in-memory for the lifetime of an application.

InMemoryKey.swift

## Parameters

`key`

A string key identifying a value to share in memory.

## Return Value

An in-memory shared key.

## Discussion

For example, one could initialize a key with the date and time at which the application was most recently launched, and access this date from anywhere using the `Shared` property wrapper:

@main
struct MyApp: App {
init() {
@Shared(.inMemory("appLaunchedAt")) var appLaunchedAt = Date()
}
// ...
}

- inMemory(\_:)
- Parameters
- Return Value
- Discussion

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/persistencestrategies

- Sharing
- Persistence strategies

Article

# Persistence strategies

Learn about the various persistence strategies that ship with the library, as well as how to create your own custom strategies.

## Overview

When using `@Shared` you can supply an optional persistence strategy to represent that the state you are holding onto is being shared with an external system. The library ships with 3 kinds of strategies: `appStorage`, `fileStorage`, and `inMemory`. These strategies are defined as conformances to the `SharedKey` protocol, and it is possible for you to provide your own conformances for sharing state with other systems, such as remote servers, SQLite, or really anything!

### In-memory

This is the simplest persistence strategy in that it doesn’t actually persist at all. It keeps the data in memory and makes it available globally to every part of the application, but when the app is relaunched the data will be reset ) to the `@Shared` property wrapper. For example, suppose you want to share an integer count value with the entire application so that any feature can read from and write to the integer. This can be done like so:

@Obsrevable
class FeatureModel {
@ObservationIgnored
@Shared(.inMemory("count")) var count = 0
// ...
}

Now any part of the application can read from and write to this state, and features will never get out of sync.

### User defaults

If you would like to persist your shared value across application launches, then you can use the `appStorage(_:store:)` strategy with `@Shared` in order to automatically persist any changes to the value to user defaults. It works similarly to in-memory sharing discussed above. It requires a key to store the value in user defaults, as well as a default value that will be used when there is no value in the user defaults:

@Shared(.appStorage("count")) var count = 0

That small change will guarantee that all changes to `count` are persisted and will be automatically loaded the next time the application launches.

This form of persistence only works for simple data types because that is what works best with `UserDefaults`. This includes strings, booleans, integers, doubles, URLs, data, and more. If you need to store more complex data, such as custom data types serialized to bytes, then you will want to use the `.fileStorage` strategy or a custom persistence strategy.

### File system

If you would like to persist your shared value across application launches, and your value is complex (such as a custom data type), then you can use the `fileStorage(_:decoder:encoder:)` strategy with `@Shared`. It automatically persists any changes to the file system.

It works similarly to the in-memory sharing discussed above, but it requires a URL to store the data on disk, as well as a default value that will be used when there is no data in the file system:

@Shared(.fileStorage(/* URL */) var users: [User] = []

This strategy works by serializing your value to JSON to save to disk, and then deserializing JSON when loading from disk. For this reason the value held in `@Shared(.fileStorage(…))` must conform to `Codable`.

#### Custom persistence

It is possible to define all new persistence strategies for the times that user defaults or JSON files are not sufficient. To do so, define a type that conforms to the `SharedKey` protocol:

public final class CustomSharedKey: SharedKey {
// ...
}

In order to conform to `Shared` you will need to provide 4 main requirements:

- A `load(context:continuation:)` method for loading a value from the external system.

- A `subscribe(context:subscriber:)` method for subscribing to changes in the external system in order to play ) method for saving a value to the external system.

- And finally, an `id` that uniquely identifies the state held in the external storage system.

Once that is done it is customary to also define a static function helper on the `SharedKey` protocol for providing a simple API to use your new persistence strategy with `@Shared`:

extension SharedKey {

CustomSharedKey(/* ... */)
}
}

With those steps done you can make use of the strategy in the same way one does for `appStorage` and `fileStorage`:

@Shared(.custom(/* ... */)) var myValue: Value

The `SharedKey` protocol represents loading from _and_ saving to some external storage, such as the file system or user defaults. Sometimes saving is not a valid operation for the external system, such as if your server holds onto a remote configuration file that your app uses to customize its appearance or behavior, but the client cannot write to directly. In those situations you can conform to the `SharedReaderKey` protocol, instead.

## See Also

### Essentials

`struct Shared`

A property wrapper type that shares a value with other parts of the application and/or external systems.

`struct SharedReader`

A property wrapper type that shares a read-only value with multiple parts of an application.

Mutating shared state

Learn how to mutate shared state in a safe manner in order to prevent race conditions and data loss.

Observing changes to shared state

Learn how to observe changes to shared state in order to update your UI or react to changes.

Dynamic Keys

Learn how to dynamically change the key that powers your shared state.

Deriving shared state

Learn how to derive shared state to sub-parts of a larger piece of shared state.

Reusable, type-safe keys

Learn how to define keys for your shared state that allow you to reference your data in a statically checked and type-safe manner.

Initialization rules

Learn the various ways to initialize shared state, both when using a persistence strategy and when not.

Testing

Learn how to test features that use shared state, even when persistence strategies are involved.

Gotchas of @Shared

Learn about a few gotchas to be aware of when using shared state in your application.

- Persistence strategies
- Overview
- In-memory
- User defaults
- File system
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/publisher



---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/observingchanges

- Sharing
- Observing changes to shared state

Article

# Observing changes to shared state

Learn how to observe changes to shared state in order to update your UI or react to changes.

## Overview

Typically one does not have to worry about observing changes to shared state because it often happens automatically for you. However, there are certain situations you should be aware of.

## SwiftUI

In SwiftUI observation is handled for you automatically. You can simply access shared state directly in a view, and that will cause the view to subscribe to changes to that state. This is true if you hold onto the shared state directly in the view:

struct CounterView: View {
@Shared(.appStorage("count")) var count = 0
var body: some View {
Form {
Text("\(count)")
Button("Increment") { count += 1 }
}
}
}

…or if you hold onto shared state in observable model:

@Observable class CounterModel {
@ObservationIgnored
@Shared(.appStorage("count")) var count = 0
}
struct CounterView: View {
@State var model = CounterModel()
var body: some View {
Form {
Text("\(model.count)")
Button("Increment") { model.count += 1 }
}
}
}

In each of these cases the view will automatically re-compute its body when the shared state changes.

## Publisher of values

It is possible to get a Combine publisher of changes in a piece of shared state. Every `Shared` value has a `publisher` property, which emits the value every time the shared state changes:

class Model {
@Shared(.appStorage("count")) var count = 0

func startObservation() {
$count.publisher.sink { count in
print("count is now", count)
}
.store(in: &cancellables)
}
}

## UIKit

UIKit does not get the same affordances as SwiftUI, but it is still possible to observe changes to shared state in order to update the UI. You can use the `publisher` property described above to listen for changes in `viewDidLoad` of you controller, and update your UI:

final class CounterViewController: UIViewController {
@Shared(.appStorage("count")) var count = 0

func viewDidLoad() {
super.viewDidLoad()

let counterLabel = UILabel()
// Set up constraints and add label to screen...

$count.publisher.sink { count in
counterLabel.text = "\(count)"
}
.store(in: &cancellables)
}
}

If you are willing to further depend on our Swift Navigation library, then you can make use of its `observe(_:)` method to simplify this quite a bit:

observe { [weak self] in
guard let self else { return }

counterLabel.text = "\(count)"
}
}
}

Any state accessed in the trailing closure of `observe` will be automatically observed, causing the closure to be evaluated when the state changes.

## See Also

### Essentials

`struct Shared`

A property wrapper type that shares a value with other parts of the application and/or external systems.

`struct SharedReader`

A property wrapper type that shares a read-only value with multiple parts of an application.

Persistence strategies

Learn about the various persistence strategies that ship with the library, as well as how to create your own custom strategies.

Mutating shared state

Learn how to mutate shared state in a safe manner in order to prevent race conditions and data loss.

Dynamic Keys

Learn how to dynamically change the key that powers your shared state.

Deriving shared state

Learn how to derive shared state to sub-parts of a larger piece of shared state.

Reusable, type-safe keys

Learn how to define keys for your shared state that allow you to reference your data in a statically checked and type-safe manner.

Initialization rules

Learn the various ways to initialize shared state, both when using a persistence strategy and when not.

Testing

Learn how to test features that use shared state, even when persistence strategies are involved.

Gotchas of @Shared

Learn about a few gotchas to be aware of when using shared state in your application.

- Observing changes to shared state
- Overview
- SwiftUI
- Publisher of values
- UIKit
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/testing

- Sharing
- Testing

Article

# Testing

Learn how to test features that use shared state, even when persistence strategies are involved.

## Overview

Introducing shared state to an application has the potential to complicate unit testing one’s features. This is because shared state naturally behaves like a reference type, in that it can be read and modified from anywhere in the app. And further, `@Shared` properties are often backed by external storages, such as user defaults and the file system, which can cause multiple tests to trample over each other.

Luckily the tools in this library were built with testing in mind, and you can usually test your features as if you were holding onto regular, non-shared state. For example, if you have a model that holds onto an integer that is stored in `appStorage` like so:

@Observable
class CounterModel {
@ObservationIgnored
@Shared(.appStorage("count")) var count = 0
func incrementButtonTapped() {
$count.withLock { $0 += 1 }
}
}

Then a simple test can be written for this in the exact same way as if you were not using `@Shared` at all:

@Test func increment() {
let model = CounterModel()
model.incrementButtonTapped()
#expect(model.count == 1)
}

This test will pass deterministically, 100% of the time, even when run in parallel with other tests and when run repeatedly. This is true even though technically `appStorage` interfaces with user defaults behind the scenes, which is a global, mutable store of data.

However, during tests the `appStorage` strategy will provision a unique and temporary user defaults for each test case. That allows each test to make any changes it wants to the user defaults without affecting other tests.

The same holds true for the `fileStorage` and `inMemory` strategies. Even though those strategies do interact with a global store of data, they do so in a way that is quarantined from other tests.

### Testing when using custom persistence strategies

When creating your own custom persistence strategies you must be careful to do so in a style that is amenable to testing. For example, the `appStorage(_:store:)` persistence strategy that comes with the library uses a `defaultAppStorage` dependency so that one can inject a custom `UserDefaults` in order to execute in a controlled environment. When your app runs in the simulator or on device, `defaultAppStorage` uses the standard user defaults so that data is persisted. But when your app runs in a testing or preview context, `defaultAppStorage` uses a unique and temporary user defaults so that each run of the test or preview starts with an empty storage.

Similarly the `fileStorage(_:decoder:encoder:)` persistence strategy uses an internal dependency for changing how files are written to the disk and loaded from disk. In tests the dependency will forgo any interaction with the file system and instead write data to an internal `[URL: Data]` dictionary, and load data from that dictionary. That emulates how the file system works, but without persisting any data to the global file system, which can bleed over into other tests.

### Overriding shared state in tests

When testing features that use `@Shared` with a persistence strategy you may want to set the initial value of that state for the test. Typically this can be done by declaring the shared state at the beginning of the test so that its default value can be specified:

@Test
func basics() {
@Shared(.appStorage("count")) var count = 42

// Shared state will be 42 for all features using it.
let model = FeatureModel()
// ...
}

However, if your test suite is a part of an app target, then the entry point of the app will execute and potentially cause an early access of `@Shared`, thus capturing a different default value than what is specified above. This is a quirk of app test targets in Xcode, and can cause lots of subtle problems.

The most robust workaround to this issue is to simply not execute your app’s entry point when tests are running. This makes it so that you are not accidentally executing network requests, tracking analytics, _etc._, while running tests.

You can do this by checking if tests are running in your entry point using the global `isTesting` value provided by the library:

@main
struct EntryPoint: App {
var body: some Scene {
if !isTesting {
WindowGroup {
// ...
}
}
}
}

#### UI Testing

When UI testing your app you must take extra care so that shared state is not persisted across app runs because that can cause one test to bleed over into another test, making it difficult to write deterministic tests that always pass. To fix this, you can set an environment value from your UI test target, such as `UI_TESTING`, and then if that value is present in the app target you can override the `defaultAppStorage` and `defaultFileStorage` dependencies so that they use in-memory storage, _i.e._ they do not persist, ever:

@main
struct EntryPoint: App {
init() {
if ProcessInfo.processInfo.environment["UI_TESTING"] != nil {
prepareDependencies {
$0.defaultAppStorage = .inMemory
$0.defaultFileStorage = .inMemory
}
}
}
}

## See Also

### Essentials

`struct Shared`

A property wrapper type that shares a value with other parts of the application and/or external systems.

`struct SharedReader`

A property wrapper type that shares a read-only value with multiple parts of an application.

Persistence strategies

Learn about the various persistence strategies that ship with the library, as well as how to create your own custom strategies.

Mutating shared state

Learn how to mutate shared state in a safe manner in order to prevent race conditions and data loss.

Observing changes to shared state

Learn how to observe changes to shared state in order to update your UI or react to changes.

Dynamic Keys

Learn how to dynamically change the key that powers your shared state.

Deriving shared state

Learn how to derive shared state to sub-parts of a larger piece of shared state.

Reusable, type-safe keys

Learn how to define keys for your shared state that allow you to reference your data in a statically checked and type-safe manner.

Initialization rules

Learn the various ways to initialize shared state, both when using a persistence strategy and when not.

Gotchas of @Shared

Learn about a few gotchas to be aware of when using shared state in your application.

- Testing
- Overview
- Testing when using custom persistence strategies
- Overriding shared state in tests
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader

- Sharing
- SharedReader

Structure

# SharedReader

A property wrapper type that shares a read-only value with multiple parts of an application.

@dynamicMemberLookup @propertyWrapper

SharedReader.swift

## Overview

The `@Shared` property wrapper gives you access to a piece of shared state that is both readable and writable. That is by far the most common use case when it comes to shared state, but there are times when one wants to express access to shared state for which you are not allowed to write to it, or possibly it doesn’t even make sense to write to it.

For those times there is the `@SharedReader` property wrapper. It represents a reference to some piece of state shared with multiple parts of the application, but you are not allowed to write to it. For example, a feature that needs access to a user setting controlling the sound effects of the app can do so in a read-only manner:

struct FeatureView: View {
@SharedReader(.appStorage("soundsOn")) var soundsOn = true

var body: some View {
Button("Tap") {
if soundsOn {
SoundEffects.shared.tap()
}
}
}
}

This makes it clear that this view only needs access to the “soundsOn” on state, but does not need to change it.

It is also possible to make custom persistence strategies that only have the notion of loading and subscribing, but cannot write. To do this you will conform only to the `SharedReaderKey` protocol instead of the full `SharedKey` protocol.

For example, you could create a `.remoteConfig` strategy that loads (and subscribes to) a remote configuration file held on your server so that it is kept automatically in sync:

@SharedReader(.remoteConfig) var remoteConfig

This will allow you to read data from the remove config:

if remoteConfig.isToggleEnabled {
Toggle(/* ... */)
.toggleStyle(
remoteConfig.useToggleSwitch
? .switch
: .automatic
)
}

## Topics

### Creating a persisted reader

Creates a shared reference to a read-only value using a shared key.

### Creating a shared reader

`init(value: sending Value)`

Creates a read-only shared reference from another read-only shared reference.

### Transforming a shared value

Returns a read-only shared reference to the resulting value of a given key path.

Creates a read-only shared reference from a shared reference.

Unwraps a read-only shared reference to an optional value.

### Reading the value

`var wrappedValue: Value`

The underlying value referenced by the shared variable.

A projection of the read-only shared value that returns a shared reference.

### Loading the value

`var isLoading: Bool`

Whether or not an associated shared key is loading data from an external source.

`func load() async throws`

Requests an up-to-date value from an external source.

Replaces a shared reference’s key and attempts to load its value.

Creates a shared reference to a read-only value using a shared key by loading it from its external source.

### Error handling

`var loadError: (any Error)?`

An error encountered during the most recent attempt to load data.

### SwiftUI integration

`extension RangeReplaceableCollection`

### Combine integration

Returns a publisher that emits events when the underlying value changes.

### Initializers

Creates a shared reference to a read-only value using a shared key with a default value.

Creates a shared reference to an optional, read-only value using a shared key.

Creates a shared reference to a read-only value using a shared key by overriding its default value.

### Instance Methods

Returns a read-only shared reference to the resulting value of a given closure.

## Relationships

### Conforms To

- `CustomDump.CustomDumpRepresentable`
- `Observation.Observable`
- `PerceptionCore.Perceptible`
- `Swift.Copyable`
- `Swift.CustomStringConvertible`
- `Swift.Equatable`
- `Swift.Identifiable`
- `Swift.Sendable`
- `SwiftUICore.DynamicProperty`

## See Also

### Essentials

`struct Shared`

A property wrapper type that shares a value with other parts of the application and/or external systems.

Persistence strategies

Learn about the various persistence strategies that ship with the library, as well as how to create your own custom strategies.

Mutating shared state

Learn how to mutate shared state in a safe manner in order to prevent race conditions and data loss.

Observing changes to shared state

Learn how to observe changes to shared state in order to update your UI or react to changes.

Dynamic Keys

Learn how to dynamically change the key that powers your shared state.

Deriving shared state

Learn how to derive shared state to sub-parts of a larger piece of shared state.

Reusable, type-safe keys

Learn how to define keys for your shared state that allow you to reference your data in a statically checked and type-safe manner.

Initialization rules

Learn the various ways to initialize shared state, both when using a persistence strategy and when not.

Testing

Learn how to test features that use shared state, even when persistence strategies are involved.

Gotchas of @Shared

Learn about a few gotchas to be aware of when using shared state in your application.

- SharedReader
- Overview
- Topics
- Relationships
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/mutatingsharedstate



---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/dynamickeys

- Sharing
- Dynamic Keys

Article

# Dynamic Keys

Learn how to dynamically change the key that powers your shared state.

## Overview

Sharing uses the `SharedKey` protocol to express the functionality of loading, saving and subscribing to changes of an external storage system, such as user defaults, the file system and more. Often one needs to dynamically update the key so that the shared state can load different data. A common example of this is using `@SharedReader` to load data from a SQLite database, and needing to update the query with info specified by the user, such as a search string.

Learn about the techniques to do this below.

### Loading a new key

There are two ways to load a new key into `@Shared` and `@SharedReader`. If the change is due to the user changing something, such as a search string, you can use `load(_:)`:

.task(id: searchText) {
do {
try await $items.load(.search(searchText))
} catch {
// Handle error
}
}

If the change is not due to user action, such as the first appearance of the view, then you can re-assign the projected value of the shared state directly:

init() {
$items = SharedReader(.search(searchText))
}

### SwiftUI views

There is one nuance to be aware of when using `@Shared` and `@SharedReader` directly in a SwiftUI view. When the view is recreated (which can happen many times and is an intentional design of SwiftUI), the corresponding `@Shared` and `@SharedReader` wrappers can also be created.

If you dynamically change the key of the property wrapper in the view, for example like this:

$value.load(.newKey)
// or...
$value = Shared(.newKey)

…then this key may be reset when the view is recreated. In order to prevent this you can use the version of `Shared` and `SharedReader` that works like `@State` in views:

@State.Shared(.key) var value

See `State.Shared` and `State.SharedReader` for more info.

## See Also

### Essentials

`struct Shared`

A property wrapper type that shares a value with other parts of the application and/or external systems.

`struct SharedReader`

A property wrapper type that shares a read-only value with multiple parts of an application.

Persistence strategies

Learn about the various persistence strategies that ship with the library, as well as how to create your own custom strategies.

Mutating shared state

Learn how to mutate shared state in a safe manner in order to prevent race conditions and data loss.

Observing changes to shared state

Learn how to observe changes to shared state in order to update your UI or react to changes.

Deriving shared state

Learn how to derive shared state to sub-parts of a larger piece of shared state.

Reusable, type-safe keys

Learn how to define keys for your shared state that allow you to reference your data in a statically checked and type-safe manner.

Initialization rules

Learn the various ways to initialize shared state, both when using a persistence strategy and when not.

Testing

Learn how to test features that use shared state, even when persistence strategies are involved.

Gotchas of @Shared

Learn about a few gotchas to be aware of when using shared state in your application.

- Dynamic Keys
- Overview
- Loading a new key
- SwiftUI views
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/derivingsharedstate

- Sharing
- Deriving shared state

Article

# Deriving shared state

Learn how to derive shared state to sub-parts of a larger piece of shared state.

## Overview

@Observable
class PhoneNumberModel {
@ObservationIgnored
@Shared var phoneNumber: String
// ...
}

func nextButtonTapped() {
path.append(
PhoneNumberModel(phoneNumber: $signUpData.phoneNumber)
)
}

It can be instructive to think of `@Shared` as an analogue of SwiftUI’s `@Binding` that can be used anywhere. You use it to express that the actual “source of truth” of the value lies elsewhere, but you want to be able to read its most current value and write to it.

This also works for persistence strategies. If a parent feature holds onto a `@Shared` piece of state with a persistence strategy:

@Observable
class ParentModel {
@ObservationIgnored
@Shared(.fileStorage(.currentUser)) var currentUser
// ...
}

…and a child feature wants access to just a shared _piece_ of `currentUser`, such as their name, then they can do so by holding onto a simple, unadorned `@Shared`:

@Observable
class EditNameModel {
@ObservationIgnored
@Shared var currentUserName: String
// ...
}

And then the parent can pass along `$currentUser.name` to the child feature when constructing its state:

func editNameButtonTapped() {
destination = .editName(
EditNameModel(currentUserName: $currentUser.name)
)
}

Any changes the child feature makes to its shared `name` will be automatically made to the parent’s shared `currentUser`, and further those changes will be automatically persisted thanks to the `.fileStorage` persistence strategy used. This means the child feature gets to describe that it needs access to shared state without describing the persistence strategy, and the parent can be responsible for persisting and deriving shared state to pass to the child.

### Optional shared state

If your shared state is optional, it is possible to unwrap it as a non-optional shared value via `init(_:)`.

@Shared var currentUser: User?

if let loggedInUser = Shared($currentUser) {

### Collections of shared state

If your shared state is a collection, in particular an `IdentifiedArray`, then we have another tool for deriving shared state to a particular element of the array. You can pass the shared collection to a `RangeReplaceableCollection`’s `init(_:)` to create a collection of shared elements:

// ...
}

You can also subscript into a `Shared` collection with the `IdentifiedArray[id:]` subscript. This will give a piece of shared optional state, which you can then unwrap with the `init(_:)` initializer:

guard let todo = Shared($todos[id: todoID])
else { return }

### Read-only shared state

Any `@Shared` value can be made read-only via `init(_:)`:

// Parent feature needs read-write access to the option
@Shared(.appStorage("isHapticsEnabled")) var isHapticsEnabled = true

// Child feature only needs to observe changes to the option
Child(isHapticsEnabled: SharedReader($isHapticsEnabled))

## See Also

### Essentials

`struct Shared`

A property wrapper type that shares a value with other parts of the application and/or external systems.

`struct SharedReader`

A property wrapper type that shares a read-only value with multiple parts of an application.

Persistence strategies

Learn about the various persistence strategies that ship with the library, as well as how to create your own custom strategies.

Mutating shared state

Learn how to mutate shared state in a safe manner in order to prevent race conditions and data loss.

Observing changes to shared state

Learn how to observe changes to shared state in order to update your UI or react to changes.

Dynamic Keys

Learn how to dynamically change the key that powers your shared state.

Reusable, type-safe keys

Learn how to define keys for your shared state that allow you to reference your data in a statically checked and type-safe manner.

Initialization rules

Learn the various ways to initialize shared state, both when using a persistence strategy and when not.

Testing

Learn how to test features that use shared state, even when persistence strategies are involved.

Gotchas of @Shared

Learn about a few gotchas to be aware of when using shared state in your application.

- Deriving shared state
- Overview
- Optional shared state
- Collections of shared state
- Read-only shared state
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/typesafekeys

- Sharing
- Reusable, type-safe keys

Article

# Reusable, type-safe keys

Learn how to define keys for your shared state that allow you to reference your data in a statically checked and type-safe manner.

## Overview

Due to the nature of persisting data to external systems, you lose some type safety when shuffling data from your app to the persistence storage and back. For example, if you are using the `fileStorage` strategy to save an array of users to disk you might do so like this:

@Shared(
.fileStorage(.documentsDirectory.appending(component: "users.json"))
)
var users: [User] = []

Not only is this a cumbersome line of code to write, but it is also not very safe. Say you have used this file storage in multiple places throughout your application. But then, someday in the future you may decide to refactor this data to be an identified array instead of a plain array:

// Somewhere else in the application

But if you forget to convert _all_ shared user arrays to the new identified array your application will still compile, but it will be broken. The two types of storage will not share state.

To add some type-safety and reusability to this process you can extend the `SharedKey` protocol to add a static variable for describing the details of your persistence:

extension SharedKey
where Self == FileStorageKey<IdentifiedArrayOf<User>> {
static var users: Self {
fileStorage(/* ... */)
}
}

Then when using `@Shared` you can specify this key directly without `.fileStorage`:

And now that the type is baked into the key you cannot accidentally use the wrong type because you will get an immediate compiler error:

@Shared(.users) var users: [User] = []

This technique works for all types of persistence strategies. For example, a type-safe `.inMemory` key can be constructed like so:

extension SharedReaderKey
where Self == InMemoryKey<IdentifiedArrayOf<User>> {
static var users: Self {
inMemory("users")
}
}

And a type-safe `.appStorage` key can be constructed like so:

static var count: Self {
appStorage("count")
}
}

And this technique also works on custom persistence strategies that you may define in your own codebase.

Further, you can use the `SharedReaderKey.Default` type to pair a default value that with a persistence strategy. For example, to use a default value of `[]` with the `.users` strategy described above, we can do the following:

extension SharedReaderKey
where Self == FileStorageKey<IdentifiedArrayOf<User>>.Default {
static var users: Self {
Self[.fileStorage(URL(/* ... */)), default: []]
}
}

And now any time you reference the shared users state you can leave off the default value, and you can even leave off the type annotation:

@Shared(.users) var users

## See Also

### Essentials

`struct Shared`

A property wrapper type that shares a value with other parts of the application and/or external systems.

`struct SharedReader`

A property wrapper type that shares a read-only value with multiple parts of an application.

Persistence strategies

Learn about the various persistence strategies that ship with the library, as well as how to create your own custom strategies.

Mutating shared state

Learn how to mutate shared state in a safe manner in order to prevent race conditions and data loss.

Observing changes to shared state

Learn how to observe changes to shared state in order to update your UI or react to changes.

Dynamic Keys

Learn how to dynamically change the key that powers your shared state.

Deriving shared state

Learn how to derive shared state to sub-parts of a larger piece of shared state.

Initialization rules

Learn the various ways to initialize shared state, both when using a persistence strategy and when not.

Testing

Learn how to test features that use shared state, even when persistence strategies are involved.

Gotchas of @Shared

Learn about a few gotchas to be aware of when using shared state in your application.

- Reusable, type-safe keys
- Overview
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/initializationrules

- Sharing
- Initialization rules

Article

# Initialization rules

Learn the various ways to initialize shared state, both when using a persistence strategy and when not.

## Overview

Because Sharing utilizes property wrappers there are special rules that must be followed when writing custom initializers for your types. These rules apply to _any_ kind of property wrapper, including those that ship with vanilla SwiftUI (e.g. `@State`, `@StateObject`, _etc._), but the rules can be quite confusing and so below we describe the various ways to initialize shared state.

It is common to need to provide a custom initializer to your feature’s types, especially when working with classes or when modularizing. This can become complicated when your types hold onto `@Shared` properties. Depending on your exact situation you can do one of the following:

- Persisted @Shared state

- Non-persisted @Shared state owned by feature

- Non-persisted @Shared state owned by other feature

### Persisted @Shared state

If you are using a persistence strategy with shared state ( _e.g._ `appStorage`, `fileStorage`, _etc._), then the initializer should take a plain, non- `Shared` value and you will construct the `Shared` value in the initializer using `init(wrappedValue:_:)` which takes a `SharedKey` as the second argument:

class FeatureModel {
// A piece of shared state that is persisted to an external system.
@Shared public var count: Int
// Other fields...

public init(count: Int, /* Other fields... */) {
_count = Shared(wrappedValue: count, .appStorage("count"))
// Other assignments...
}
}

Note that the declaration of `count` as a property of the class can use `@Shared` without an argument because the persistence strategy is specified in the initializer.

### Non-persisted @Shared state owned by feature

If you are using non-persisted shared state ( _i.e._ no shared key argument is passed to `@Shared`), and the “source of truth” of the state lives within the feature you are initializing, then the initializer should take a plain, non- `Shared` value and you will construct the `Shared` value directly in the initializer:

class FeatureModel {
// A piece of shared state that this feature will own.
@Shared public var count: Int
// Other fields...

public init(count: Int, /* Other fields... */) {
_count = Shared(value: count)
// Other assignments...
}
}

By constructing a `Shared` value directly in the initializer we can guarantee that this feature owns the state.

### Non-persisted @Shared state owned by other feature

If you are using non-persisted shared state ( _i.e._ no shared key argument is passed to `@Shared`), and the “source of truth” of the state lives in a parent feature, then the initializer should take a `@Shared` value that you will assign directly through the underscored property:

class FeatureModel {
// A piece of shared state that will be provided by whoever constructs this model.
@Shared public var count: Int
// Other fields...

_count = count
// Other assignments...
}
}

This will make it so that `FeatureModel`’s `count` stays in sync with whatever parent feature holds onto the shared state.

## See Also

### Essentials

`struct Shared`

A property wrapper type that shares a value with other parts of the application and/or external systems.

`struct SharedReader`

A property wrapper type that shares a read-only value with multiple parts of an application.

Persistence strategies

Learn about the various persistence strategies that ship with the library, as well as how to create your own custom strategies.

Mutating shared state

Learn how to mutate shared state in a safe manner in order to prevent race conditions and data loss.

Observing changes to shared state

Learn how to observe changes to shared state in order to update your UI or react to changes.

Dynamic Keys

Learn how to dynamically change the key that powers your shared state.

Deriving shared state

Learn how to derive shared state to sub-parts of a larger piece of shared state.

Reusable, type-safe keys

Learn how to define keys for your shared state that allow you to reference your data in a statically checked and type-safe manner.

Testing

Learn how to test features that use shared state, even when persistence strategies are involved.

Gotchas of @Shared

Learn about a few gotchas to be aware of when using shared state in your application.

- Initialization rules
- Overview
- Persisted @Shared state
- Non-persisted @Shared state owned by feature
- Non-persisted @Shared state owned by other feature
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/gotchas

- Sharing
- Gotchas of @Shared

Article

# Gotchas of @Shared

Learn about a few gotchas to be aware of when using shared state in your application.

#### Hashability

Because the `@Shared` type is equatable based on its wrapped value, and because the value is held in a reference that can change over time, it cannot be hashable. This also means that types containing `@Shared` properties should not compute their hashes from their shared values.

#### Codability

The `@Shared` type is not conditionally encodable or decodable because the source of truth of the wrapped value is rarely local: it might be derived from some other shared value, or it might rely on loading the value from a backing persistence strategy.

When introducing shared state to a data type that is encodable or decodable, you must explicitly declare its non-shared coding keys in order to synthesize conformances:

struct TodosFeature {
@Shared(.appStorage("launchCount")) var launchCount = 0
var todos: [String] = []
}

extension TodosFeature: Codable {
enum CodingKeys: String, CodingKey {
// Omit 'launchCount'
case todos
}
}

Or you must provide your own implementations of `encode(to:)` and `init(from:)` that do the appropriate thing.

For example, if the data type is sharing state with a persistence strategy, you can _decode_ by delegating to the memberwise initializer that implicitly loads the shared value from the property wrapper’s persistence strategy, or you can explicitly initialize a shared value via `init(wrappedValue:_:)`. And you can _encode_ by skipping the shared value:

extension TodosFeature: Codable {
enum CodingKeys: String, CodingKey {
case todos
}

init(from decoder: any Decoder) throws {
let container = try decoder.container(keyedBy: CodingKeys.self)

// Do not decode 'launchCount'
self._launchCount = Shared(wrappedValue: 0, .appStorage("launchCount"))
self.todos = try container.decode([String].self, forKey: .todos)
}

func encode(to encoder: any Encoder) throws {
var container = encoder.container(keyedBy: CodingKeys.self)
try container.encode(self.todos, forKey: .todos)
// Do not encode 'launchCount'
}
}

#### SwiftUI Views

There is one nuance to be aware of when using `@Shared` and `@SharedReader` directly in a SwiftUI view. When the view is recreated (which can happen many times and is an intentional design of SwiftUI), the corresponding `@Shared` and `@SharedReader` wrappers can also be created.

If you dynamically change the key of the property wrapper in the view, for example like this:

$value.load(.newKey)
// or…
$value = Shared(.newKey)

…then this key may be reset when the view is recreated. In order to prevent this you can use the version of `Shared` and `SharedReader` that works like `@State` in views:

@State.Shared(.key) var value

See `State.Shared` and `State.SharedReader` for more info, as well as the article Dynamic Keys.

## See Also

### Essentials

`struct Shared`

A property wrapper type that shares a value with other parts of the application and/or external systems.

`struct SharedReader`

A property wrapper type that shares a read-only value with multiple parts of an application.

Persistence strategies

Learn about the various persistence strategies that ship with the library, as well as how to create your own custom strategies.

Mutating shared state

Learn how to mutate shared state in a safe manner in order to prevent race conditions and data loss.

Observing changes to shared state

Learn how to observe changes to shared state in order to update your UI or react to changes.

Dynamic Keys

Learn how to dynamically change the key that powers your shared state.

Deriving shared state

Learn how to derive shared state to sub-parts of a larger piece of shared state.

Reusable, type-safe keys

Learn how to define keys for your shared state that allow you to reference your data in a statically checked and type-safe manner.

Initialization rules

Learn the various ways to initialize shared state, both when using a persistence strategy and when not.

Testing

Learn how to test features that use shared state, even when persistence strategies are involved.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/appstoragekey

- Sharing
- AppStorageKey

Structure

# AppStorageKey

A type defining a user defaults persistence strategy.

AppStorageKey.swift

## Overview

A `SharedKey` conformance that persists simple pieces of data to user defaults, such as numbers, strings, booleans and URLs. It can be used with `Shared` by providing the `appStorage(_:store:)` value and specifying a default value:

@Shared(.appStorage("isOn")) var isOn = true

Any changes made to this value will be synchronized to user defaults. Further, any change made to the “isOn” key in user defaults will be immediately played

When running your app in a simulator or device, `appStorage` will use the `standard` user defaults for persisting your state. If you want to use a different user defaults, you can invoke the `prepareDependencies` function in the entry point of your application:

@main struct EntryPoint: App {
init() {
prepareDependencies {
$0.defaultAppStorage = UserDefaults(suiteName: "co.pointfree.suite")!
}
}
// ...
}

That will make it so that all `@Shared(.appStorage)` instances use your custom user defaults.

In previews `@Shared` will use a temporary, ephemeral user defaults so that each run of the preview gets a clean slate. This makes it so that previews do not mutate each other’s storage and allows you to fully control how your previews behave. If you want to use the `standard` user defaults in previews you can use `prepareDependencies`:

#Preview {
let _ = prepareDependencies { $0.defaultAppStorage = .standard }
// ...
}

And finally, in tests `@Shared` will also use a temporary, ephemeral user defaults. This makes it so that each test runs in a sandboxed environment that does not interfere with other tests or the simulator. A benefit of this is that your tests can pass deterministically and tests can be run in parallel. If you want to use the `standard` user defaults in tests you can use the `dependency` test trait:

@Test(.dependency(\.defaultAppStorage, .standard))
func basics() {
// ...
}

### Special characters in keys

The `appStorage` persistence strategy can change its behavior depending on the characters its key contains. If the key does not contain periods (”.”) or at-symbols (”@”), then `appStorage` can use KVO to observe changes to the key. This has a number of benefits: it can observe changes to only the key instead of all of user defaults, it can deliver changes to `@Shared` synchronously, and changes can be animated.

If the key does contain periods or at-symbols, then `appStorage` must use `NotificationCenter` to listen for changes since those symbols have special meaning in KVO. This has a number of downsides: `appStorage` must listen to the firehose of _all_ changes in `UserDefaults`, it must perform extra work to de-duplicate changes, it must perform a thread hop before it updates the `@Shared` state, and state changes cannot be animated.

When your key contains a period or at-symbol `appStorage` will emit a runtime warning letting you know of its behavior. If you still wish to use periods or at-symbols you can disable this warning by running the following in the entry point of your app:

prepareDependencies {
$0.appStorageKeyFormatWarningEnabled = false
}

## Topics

### Storing a value

Creates a shared key that can read and write to a boolean user default.

Creates a shared key that can read and write to a user default as data.

Creates a shared key that can read and write to a date user default.

Creates a shared key that can read and write to a double user default.

Creates a shared key that can read and write to an integer user default.

Creates a shared key that can read and write to a string user default.

Creates a shared key that can read and write to a URL user default.

Creates a shared key that can read and write to an integer user default, transforming that to a `RawRepresentable` data type.

Creates a shared key that can read and write to a string user default, transforming that to a `RawRepresentable` data type.

### Storing an optional value

Creates a shared key that can read and write to an optional boolean user default.

Creates a shared key that can read and write to a user default as optional data.

Creates a shared key that can read and write to an optional date user default.

Creates a shared key that can read and write to an optional double user default.

Creates a shared key that can read and write to an optional integer user default.

Creates a shared key that can read and write to an optional string user default.

Creates a shared key that can read and write to an optional URL user default.

Creates a shared key that can read and write to an optional integer user default, transforming that to a `RawRepresentable` data type.

Creates a shared key that can read and write to an optional string user default, transforming that to a `RawRepresentable` data type.

### Overriding app storage

`var defaultAppStorage: UserDefaults`

Default file storage used by `SharedReaderKey/appStorage(_:)`.

`var appStorageKeyFormatWarningEnabled: Bool`

### Identifying storage

`struct AppStorageKeyID`

### Instance Properties

`var id: AppStorageKeyID`

### Instance Methods

`func save(Value, context: SaveContext, continuation: SaveContinuation)`

## Relationships

### Conforms To

- `SharedKey`
- `SharedReaderKey`
- `Swift.Copyable`
- `Swift.CustomStringConvertible`
- `Swift.Sendable`

## See Also

### Persistence

`class FileStorageKey`

A type defining a file persistence strategy

`struct InMemoryKey`

A type defining an in-memory persistence strategy

`typealias Default`

Provides a default value to a shared key.

- AppStorageKey
- Overview
- Default app storage
- Special characters in keys
- Topics
- Relationships
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/filestoragekey

- Sharing
- FileStorageKey

Class

# FileStorageKey

A type defining a file persistence strategy

FileStorageKey.swift

## Overview

Use `fileStorage(_:decoder:encoder:)` to create values of this type.

A `SharedKey` conformance that persists complex pieces of data to the file system. It works with any kind of type that can be serialized to bytes, including all `Codable` types. It can be used with `Shared` by providing the `fileStorage(_:decoder:encoder:)` value and specifying a default:

extension URL {
static let users = URL(/* ... */)
}
@Shared(.fileStorage(.users)) var users: [User] = []

Any changes made to this value will be automatically synchronized to the URL on disk provided. Further, any change made to the file stored at the URL will also be immediately played

When running your app in a simulator or device, `fileStorage` will use the actual file system for saving and loading data. However, in tests and previews `fileStorage` uses an in-memory, virtual file system. This makes it possible for previews and tests to operate in their own sandboxed environment so that changes made to files do not spill over to other previews or tests, or the simulator. It also allows your tests to pass deterministically and for tests to be run in parallel.

If you really do want to use the live file system in your previews, you can use `prepareDependencies`:

#Preview {
let _ = prepareDependencies { $0.defaultFileStorage = .fileSystem }
// ...
}

And if you want to use the live file system in your tests you can use the `dependency` test trait:

@Test(.dependency(\.defaultFileStorage, .fileSystem))
func basics() {
// ...
}

* * *

## Topics

### Storing a value

Creates a shared key that can read and write to a `Codable` value in the file system.

Creates a shared key that can read and write to a value in the file system.

### Overriding storage

`var defaultFileStorage: FileStorage`

Default file storage used by `fileStorage(_:decoder:encoder:)`.

`struct FileStorage`

A type that encapsulates saving and loading data from disk.

### Identifying storage

`struct FileStorageKeyID`

### Instance Properties

`var id: FileStorageKeyID`

### Instance Methods

`func save(Value, context: SaveContext, continuation: SaveContinuation)`

## Relationships

### Conforms To

- `SharedKey`
- `SharedReaderKey`
- `Swift.Copyable`
- `Swift.CustomStringConvertible`
- `Swift.Sendable`

## See Also

### Persistence

`struct AppStorageKey`

A type defining a user defaults persistence strategy.

`struct InMemoryKey`

A type defining an in-memory persistence strategy

`typealias Default`

Provides a default value to a shared key.

- FileStorageKey
- Overview
- Default file storage
- Topics
- Relationships
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/inmemorykey

- Sharing
- InMemoryKey

Structure

# InMemoryKey

A type defining an in-memory persistence strategy

InMemoryKey.swift

## Overview

See `inMemory(_:)` to create values of this type.

## Topics

### Storing a value

Creates a shared key for sharing data in-memory for the lifetime of an application.

### Overriding storage

`var defaultInMemoryStorage: InMemoryStorage`

`struct InMemoryStorage`

### Identifying storage

`struct InMemoryKeyID`

### Instance Properties

`var id: InMemoryKeyID`

### Instance Methods

`func save(Value, context: SaveContext, continuation: SaveContinuation)`

## Relationships

### Conforms To

- `SharedKey`
- `SharedReaderKey`
- `Swift.Copyable`
- `Swift.CustomStringConvertible`
- `Swift.Sendable`

## See Also

### Persistence

`struct AppStorageKey`

A type defining a user defaults persistence strategy.

`class FileStorageKey`

A type defining a file persistence strategy

`typealias Default`

Provides a default value to a shared key.

- InMemoryKey
- Overview
- Topics
- Relationships
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/default



---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedkey



---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey

- Sharing
- SharedReaderKey

Protocol

# SharedReaderKey

A type that can load and subscribe to state in an external system.

SharedReaderKey.swift

## Overview

Conform to this protocol to express loading state from an external system, and subscribing to state changes in the external system. It is only necessary to conform to this protocol if the `AppStorageKey`, `FileStorageKey`, or `InMemoryKey` strategies are not sufficient for your use case.

See the article Custom persistence for more information.

## Topics

### Associated data

`associatedtype Value : Sendable`

A type that can be loaded or subscribed to in an external system.

**Required**

### Loading from a data source

Loads the freshest value from storage.

`enum LoadContext`

The context in which a value is loaded by a `SharedReaderKey`.

`struct LoadContinuation`

A mechanism to communicate with a shared key’s external system, synchronously or asynchronously.

### Subscribing to a data source

Subscribes to external updates.

`struct SharedSubscriber`

A mechanism to synchronize with a shared key’s external system.

`struct SharedSubscription`

A subscription to a `SharedReaderKey`’s updates.

### Key hashability

`associatedtype ID : Hashable = Self`

A type representing the hashable identity of a shared key.

`var id: Self.ID`

The hashable identity of a shared key.

**Required** Default implementation provided.

### Type Aliases

`typealias Default`

Provides a default value to a shared key.

### Type Methods

Creates a shared key that can read and write to a user default as optional data.

Creates a shared key that can read and write to an optional string user default, transforming that to a `RawRepresentable` data type.

Creates a shared key that can read and write to an integer user default, transforming that to a `RawRepresentable` data type.

Creates a shared key that can read and write to an optional integer user default, transforming that to a `RawRepresentable` data type.

Creates a shared key that can read and write to a date user default.

Creates a shared key that can read and write to a boolean user default.

Creates a shared key that can read and write to an optional string user default.

Creates a shared key that can read and write to a string user default.

Creates a shared key that can read and write to a URL user default.

Creates a shared key that can read and write to a double user default.

Creates a shared key that can read and write to an optional URL user default.

Creates a shared key that can read and write to an optional integer user default.

Creates a shared key that can read and write to an optional date user default.

Creates a shared key that can read and write to an optional double user default.

Creates a shared key that can read and write to an optional boolean user default.

Creates a shared key that can read and write to a string user default, transforming that to a `RawRepresentable` data type.

Creates a shared key that can read and write to an integer user default.

Creates a shared key that can read and write to a user default as data.

Creates a shared key that can read and write to a value in the file system.

Creates a shared key that can read and write to a `Codable` value in the file system.

Creates a shared key for sharing data in-memory for the lifetime of an application.

## Relationships

### Inherits From

- `Swift.Sendable`

### Inherited By

- `SharedKey`

### Conforming Types

- `AppStorageKey`
- `FileStorageKey`
- `InMemoryKey`

## See Also

### Custom persistence

`protocol SharedKey`

A type that can persist shared state to an external storage.

- SharedReaderKey
- Overview
- Topics
- Relationships
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/migrationguides

- Sharing
- Migration guides

# Migration guides

Learn how to upgrade your application to the newest version of Sharing.

## Overview

Swift Sharing is under constant development, and we are always looking for ways to simplify the library, and make it more powerful. As such, we often need to deprecate certain APIs in favor of newer ones. We recommend people update their code as quickly as possible to the newest APIs, and these guides contain tips to do so.

## Topics

Migrating to 2.0

Sharing 2.0 introduces better support for error handling and concurrency.

Migrating to 1.0

In the official 1.0 release of Sharing we have removed some deprecated APIs and tweaked the behavior of certain tools.

- Migration guides
- Overview
- Topics

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderdeprecations

- Sharing
- Deprecations

# Deprecations

Review unsupported shared reader APIs and their replacements.

## Overview

Avoid using deprecated APIs in your app. Select a method to see the replacement that you should use instead.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/foundation

- Sharing
- Foundation

Extended Module

# Foundation

## Topics

### Extended Classes

`extension UserDefaults`

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/swiftuicore

- Sharing
- SwiftUICore

Extended Module

# SwiftUICore

## Topics

### Extended Structures

`extension Binding`

`extension State`

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/appstorage(_:store:)-45ltk),

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/filestorage(_:decoder:encoder:)),

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/inmemory(_:)).

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/appstorage(_:store:)-45ltk)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/filestorage(_:decoder:encoder:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/inmemory(_:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/persistencestrategies)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/publisher)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/observingchanges)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/testing)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/mutatingsharedstate)



---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/dynamickeys)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/derivingsharedstate)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/typesafekeys)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/initializationrules)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/gotchas)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/appstoragekey)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/filestoragekey)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/inmemorykey)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/default)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedkey)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/migrationguides)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderdeprecations)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/foundation)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/swiftuicore)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/load(context:continuation:)

#app-main)

- Sharing
- SharedReaderKey
- load(context:continuation:)

Instance Method

# load(context:continuation:)

Loads the freshest value from storage.

func load(

SharedReaderKey.swift

**Required**

## Discussion

- Parameters

- context: The context of loading a value.

- continuation: A continuation that can be fed the result of loading a value from an external system.

## See Also

### Loading from a data source

`enum LoadContext`

The context in which a value is loaded by a `SharedReaderKey`.

`struct LoadContinuation`

A mechanism to communicate with a shared key’s external system, synchronously or asynchronously.

- load(context:continuation:)
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/subscribe(context:subscriber:)

#app-main)

- Sharing
- SharedReaderKey
- subscribe(context:subscriber:)

Instance Method

# subscribe(context:subscriber:)

Subscribes to external updates.

func subscribe(

SharedReaderKey.swift

**Required**

## Parameters

`context`

The context of subscribing to updates.

`subscriber`

A continuation that can be fed new results from an external system, or the initial value if the external system no longer holds a value.

## Return Value

A subscription to updates from an external system. If it is cancelled or deinitialized, `subscriber` will no longer receive updates from the external system.

## See Also

### Subscribing to a data source

`struct SharedSubscriber`

A mechanism to synchronize with a shared key’s external system.

`struct SharedSubscription`

A subscription to a `SharedReaderKey`’s updates.

- subscribe(context:subscriber:)
- Parameters
- Return Value
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedkey/save(_:context:continuation:)

#app-main)

- Sharing
- SharedKey
- save(\_:context:continuation:)

Instance Method

# save(\_:context:continuation:)

Saves a value to storage.

func save(
_ value: Self.Value,
context: SaveContext,
continuation: SaveContinuation
)

SharedKey.swift

**Required**

## Parameters

`value`

The value to save.

`context`

The context of saving a value.

`continuation`

A continuation that should be notified upon the completion of saving a shared value.

## See Also

### Updating data sources

`enum SaveContext`

The context in which a value is saved by a `SharedKey`.

`struct SaveContinuation`

A mechanism to communicate with a shared key’s external system, synchronously or asynchronously.

- save(\_:context:continuation:)
- Parameters
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/id-42vln

- Sharing
- SharedReaderKey
- id

Instance Property

# id

The hashable identity of a shared key.

var id: Self.ID { get }

SharedReaderKey.swift

**Required** Default implementation provided.

## Discussion

Used to look up existing shared references associated with this shared key. For example, the `AppStorageKey` uses the string key and `UserDefaults` instance to define its ID.

## Default Implementations

### SharedReaderKey Implementations

`var id: Self`

## See Also

### Key hashability

`associatedtype ID : Hashable = Self`

A type representing the hashable identity of a shared key.

**Required**

- id
- Discussion
- Default Implementations
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/load(context:continuation:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/subscribe(context:subscriber:))



---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedkey/save(_:context:continuation:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/id-42vln)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/init(wrappedvalue:_:)-5xce4

-5xce4#app-main)

- Sharing
- Shared
- init(wrappedValue:\_:)

Initializer

# init(wrappedValue:\_:)

Creates a shared reference to a value using a shared key.

init(

SharedKey.swift

## Parameters

`wrappedValue`

A default value that is used when no value can be returned from the shared key.

`key`

A shared key associated with the shared reference. It is responsible for loading and saving the shared reference’s value from some external source.

## Topics

### Overloads

Creates a shared reference to a value using a shared key by overriding its default value.

Creates a shared reference to an optional value using a shared key.

Creates a shared reference to a value using a shared key with a default value.

- init(wrappedValue:\_:)
- Parameters
- Topics

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/init(value:)



---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/init(projectedvalue:)

#app-main)

- Sharing
- Shared
- init(projectedValue:)

Initializer

# init(projectedValue:)

Creates a shared reference from another shared reference.

Shared.swift

## Parameters

`projectedValue`

A shared reference.

## Discussion

You don’t call this initializer directly. Instead, Swift calls it for you when you use a property-wrapper attribute on a shared closure parameter.

## See Also

### Creating a shared value

`init(value: sending Value)`

- init(projectedValue:)
- Parameters
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/subscript(dynamicmember:)-68021

-68021#app-main)

- Sharing
- Shared
- subscript(dynamicMember:)

Instance Subscript

# subscript(dynamicMember:)

Returns a shared reference to the resulting value of a given key path.

Shared.swift

## Parameters

`keyPath`

A key path to a specific resulting value.

## Return Value

A new shared reference.

## Overview

You don’t call this subscript directly. Instead, Swift calls it for you when you access a property of the underlying value. In the following example, the property access `$signUpData.topics` returns the value of invoking this subscript with `\SignUpData.topics`:

@Shared var signUpData: SignUpData

$signUpData.topics // Shared<Set<Topic>>

## See Also

### Transforming a shared value

Returns a read-only shared reference to the resulting value of a given key path.

Unwraps a shared reference to an optional value.

- subscript(dynamicMember:)
- Parameters
- Return Value
- Overview
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/subscript(dynamicmember:)-318vw



---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/init(_:)-2z7om

-2z7om#app-main)

- Sharing
- Shared
- init(\_:)

Initializer

# init(\_:)

Unwraps a shared reference to an optional value.

Shared.swift

## Parameters

`base`

A shared reference to an optional value.

## Discussion

@Shared(.currentUser) var currentUser: User?

if let sharedUnwrappedUser = Shared($currentUser) {

## See Also

### Transforming a shared value

Returns a shared reference to the resulting value of a given key path.

Returns a read-only shared reference to the resulting value of a given key path.

- init(\_:)
- Parameters
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/wrappedvalue

- Sharing
- Shared
- wrappedValue

Instance Property

# wrappedValue

var wrappedValue: Value { get nonmutating set }

Shared.swift

## See Also

### Accessing the value

A projection of the shared value that returns a shared reference.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/projectedvalue

- Sharing
- Shared
- projectedValue

Instance Property

# projectedValue

A projection of the shared value that returns a shared reference.

Shared.swift

## Discussion

Use the projected value to pass a shared value down to another feature. This is most commonly done to share a value from one feature to another:

struct SignUpView: View {
@Shared var signUpData: SignUpData

var body: some View {
// ...
PersonalInfoView(
signUpData: $signUpData
)
}
}

struct PersonalInfoView: View {
@Shared var signUpData: SignUpData
// ...
}

Further you can use dot-chaining syntax to derive a smaller piece of shared state to hand to another feature:

var body: some View {
// ...
PhoneNumberView(
signUpData: $signUpData.phoneNumber
)
}
}

PhoneNumberView(
phoneNumber: $signUpData.phoneNumber
)

See Deriving shared state for more details.

## See Also

### Accessing the value

`var wrappedValue: Value`

- projectedValue
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/withlock(_:fileid:filepath:line:column:)

#app-main)

- Sharing
- Shared
- withLock(\_:fileID:filePath:line:column:)

Instance Method

# withLock(\_:fileID:filePath:line:column:)

Perform an operation on shared state with isolated access to the underlying value.

fileID: StaticString = #fileID,
filePath: StaticString = #filePath,
line: UInt = #line,
column: UInt = #column

Shared.swift

## Return Value

The value returned from `operation`.

## Discussion

See Mutating shared state for more information.

- Parameters

- operation: An operation given mutable, isolated access to the underlying shared value.

- fileID: The source `#fileID` associated with the lock.

- filePath: The source `#filePath` associated with the lock.

- line: The source `#line` associated with the lock.

- column: The source `#column` associated with the lock.

- withLock(\_:fileID:filePath:line:column:)
- Return Value
- Discussion

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/isloading

- Sharing
- Shared
- isLoading

Instance Property

# isLoading

Whether or not an associated shared key is loading data from an external source.

var isLoading: Bool { get }

Shared.swift

## See Also

### Loading and saving the value

`func load() async throws`

Requests an up-to-date value from an external source.

Replaces a shared reference’s key and attempts to load its value.

Creates a shared reference to a value using a shared key by loading it from its external source.

`func save() async throws`

Requests the underlying value be persisted to an external source.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/load()

#app-main)

- Sharing
- Shared
- load()

Instance Method

# load()

Requests an up-to-date value from an external source.

func load() async throws

Shared.swift

## Discussion

When a shared reference is powered by a `SharedReaderKey`, this method will tell it to reload its value from the associated external source.

Most of the time it is not necessary to call this method, as persistence strategies will often subscribe directly to the external source and automatically keep the shared reference synchronized. Some persistence strategies, however, may not have the ability to subscribe to their external source. In these cases, you should call this method whenever you need the most up-to-date value.

## See Also

### Loading and saving the value

`var isLoading: Bool`

Whether or not an associated shared key is loading data from an external source.

Replaces a shared reference’s key and attempts to load its value.

Creates a shared reference to a value using a shared key by loading it from its external source.

`func save() async throws`

Requests the underlying value be persisted to an external source.

- load()
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/load(_:)

#app-main)

- Sharing
- Shared
- load(\_:)

Instance Method

# load(\_:)

Replaces a shared reference’s key and attempts to load its value.

SharedKey.swift

## Parameters

`key`

A shared key associated with the shared reference. It is responsible for loading and saving the shared reference’s value from some external source.

## See Also

### Loading and saving the value

`var isLoading: Bool`

Whether or not an associated shared key is loading data from an external source.

`func load() async throws`

Requests an up-to-date value from an external source.

Creates a shared reference to a value using a shared key by loading it from its external source.

`func save() async throws`

Requests the underlying value be persisted to an external source.

- load(\_:)
- Parameters
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/init(require:)

#app-main)

- Sharing
- Shared
- init(require:)

Initializer

# init(require:)

Creates a shared reference to a value using a shared key by loading it from its external source.

SharedKey.swift

## Parameters

`key`

A shared key associated with the shared reference. It is responsible for loading and saving the shared reference’s value from some external source.

## Discussion

If the given shared key cannot load a value, an error is thrown. For a non-throwing, synchronous version of this initializer, see `init(wrappedValue:_:)`.

This initializer should only be used to create a brand new shared reference from a key. To replace the key of an existing shared reference, use `load(_:)`, instead.

## See Also

### Loading and saving the value

`var isLoading: Bool`

Whether or not an associated shared key is loading data from an external source.

`func load() async throws`

Requests an up-to-date value from an external source.

Replaces a shared reference’s key and attempts to load its value.

`func save() async throws`

Requests the underlying value be persisted to an external source.

- init(require:)
- Parameters
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/save()

#app-main)

- Sharing
- Shared
- save()

Instance Method

# save()

Requests the underlying value be persisted to an external source.

func save() async throws

Shared.swift

## Discussion

When a shared reference is powered by a `SharedKey`, this method will tell it to save its value to the associated external source.

Most of the time it is not necessary to call this method, as persistence strategies will often save to the external source immediately upon modification. Some persistence strategies, however, may choose to debounce this work, in which case it may be desirable to tell the strategy to save more eagerly.

## See Also

### Loading and saving the value

`var isLoading: Bool`

Whether or not an associated shared key is loading data from an external source.

`func load() async throws`

Requests an up-to-date value from an external source.

Replaces a shared reference’s key and attempts to load its value.

Creates a shared reference to a value using a shared key by loading it from its external source.

- save()
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/loaderror

- Sharing
- Shared
- loadError

Instance Property

# loadError

An error encountered during the most recent attempt to load data.

var loadError: (any Error)? { get }

Shared.swift

## Discussion

This value is `nil` unless a load attempt failed. It contains the latest error from the underlying `SharedReaderKey`. Access it from `@Shared`’s projected value:

@Shared(.fileStorage(.users)) var users: [User] = []

var body: some View {
if let loadError = $users.loadError {
ContentUnavailableView {
Label("Failed to load users", systemImage: "xmark.circle")
} description: {
Text(loadError.localizedDescription)
}
} else {
ForEach(users) { user in /* ... */ }
}
}

## See Also

### Error handling

`var saveError: (any Error)?`

An error encountered during the most recent attempt to save data.

- loadError
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/saveerror

- Sharing
- Shared
- saveError

Instance Property

# saveError

An error encountered during the most recent attempt to save data.

var saveError: (any Error)? { get }

Shared.swift

## Discussion

This value is `nil` unless a save attempt failed. It contains the latest error from the underlying `SharedKey`.

## See Also

### Error handling

`var loadError: (any Error)?`

An error encountered during the most recent attempt to load data.

- saveError
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/swift/rangereplaceablecollection

- Sharing
- Swift
- RangeReplaceableCollection

Extended Protocol

# RangeReplaceableCollection

SharingSwift

extension RangeReplaceableCollection

## See Also

### SwiftUI integration

`extension Binding`

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/swiftuicore/binding

- Sharing
- SwiftUICore
- Binding

Extended Structure

# Binding

SharingSwiftUICore

extension Binding

## Topics

### Initializers

Creates a binding from a shared reference.

## See Also

### SwiftUI integration

`extension RangeReplaceableCollection`

- Binding
- Topics
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/init(_:)-3us99

-3us99#app-main)

- Sharing
- Shared
- init(\_:)

Initializer

# init(\_:)

Creates a shared reference to an optional value using a shared key.

SharedKey.swift

## Parameters

`key`

A shared key associated with the shared reference. It is responsible for loading and saving the shared reference’s value from some external source.

## See Also

### Overloads

Creates a shared reference to a value using a shared key by overriding its default value.

Creates a shared reference to a value using a shared key with a default value.

- init(\_:)
- Parameters
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/init(_:)-8tyne

-8tyne#app-main)

- Sharing
- Shared
- init(\_:)

Initializer

# init(\_:)

Creates a shared reference to a value using a shared key with a default value.

SharedKey.swift

## Parameters

`key`

A shared key associated with the shared reference. It is responsible for loading and saving the shared reference’s value from some external source.

## See Also

### Overloads

Creates a shared reference to a value using a shared key by overriding its default value.

Creates a shared reference to an optional value using a shared key.

- init(\_:)
- Parameters
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/init(wrappedvalue:_:)-40vag

-40vag#app-main)

- Sharing
- Shared
- init(wrappedValue:\_:)

Initializer

# init(wrappedValue:\_:)

Creates a shared reference to a value using a shared key by overriding its default value.

init(

)

SharedKey.swift

## Parameters

`wrappedValue`

A default value that is used when no value can be returned from the shared key.

`key`

A shared key associated with the shared reference. It is responsible for loading and saving the shared reference’s value from some external source.

## See Also

### Overloads

Creates a shared reference to an optional value using a shared key.

Creates a shared reference to a value using a shared key with a default value.

- init(wrappedValue:\_:)
- Parameters
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/read(_:)-1whsd

-1whsd#app-main)

- Sharing
- Shared
- read(\_:) Deprecated

Instance Method

# read(\_:)

Shared.swift

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/read(_:)-4i0iy

-4i0iy#app-main)

- Sharing
- Shared
- read(\_:)

Instance Method

# read(\_:)

Returns a read-only shared reference to the resulting value of a given closure.

Shared.swift

## Return Value

A new read-only shared reference.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/customdumprepresentable-implementations

- Sharing
- Shared
- CustomDumpRepresentable Implementations

API Collection

# CustomDumpRepresentable Implementations

## Topics

### Instance Properties

`var customDumpValue: Any`

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/customstringconvertible-implementations

- Sharing
- Shared
- CustomStringConvertible Implementations

API Collection

# CustomStringConvertible Implementations

## Topics

### Instance Properties

`var description: String`

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/dynamicproperty-implementations

- Sharing
- Shared
- DynamicProperty Implementations

API Collection

# DynamicProperty Implementations

## Topics

### Instance Methods

`func update()`

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/equatable-implementations

- Sharing
- Shared
- Equatable Implementations

API Collection

# Equatable Implementations

## Topics

### Operators

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/identifiable-implementations

- Sharing
- Shared
- Identifiable Implementations

API Collection

# Identifiable Implementations

## Topics

### Instance Properties

`var id: Value.ID`

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/init(wrappedvalue:_:)-5xce4)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/init(value:))



---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/init(projectedvalue:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/subscript(dynamicmember:)-68021)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/subscript(dynamicmember:)-318vw)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/init(_:)-2z7om)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/wrappedvalue)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/projectedvalue)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/withlock(_:fileid:filepath:line:column:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/isloading)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/load())

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/load(_:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/init(require:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/save())

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/loaderror)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/saveerror)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/swift/rangereplaceablecollection)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/swiftuicore/binding)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/init(_:)-3us99)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/init(_:)-8tyne)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/init(wrappedvalue:_:)-40vag)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/read(_:)-1whsd)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/read(_:)-4i0iy)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/customdumprepresentable-implementations)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/customstringconvertible-implementations)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/dynamicproperty-implementations)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/equatable-implementations)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/shared/identifiable-implementations)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(wrappedvalue:_:)-56tir

-56tir#app-main)

- Sharing
- SharedReader
- init(wrappedValue:\_:)

Initializer

# init(wrappedValue:\_:)

Creates a shared reference to a read-only value using a shared key.

init(

SharedReaderKey.swift

## Parameters

`wrappedValue`

A default value that is used when no value can be returned from the shared key.

`key`

A shared key associated with the shared reference. It is responsible for loading the shared reference’s value from some external source.

## Topics

### Overloads

Creates a shared reference to a read-only value using a shared key by overriding its default value.

Creates a shared reference to an optional, read-only value using a shared key.

Creates a shared reference to a read-only value using a shared key with a default value.

- init(wrappedValue:\_:)
- Parameters
- Topics

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(value:)



---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(projectedvalue:)

#app-main)

- Sharing
- SharedReader
- init(projectedValue:)

Initializer

# init(projectedValue:)

Creates a read-only shared reference from another read-only shared reference.

SharedReader.swift

## Parameters

`projectedValue`

A read-only shared reference.

## Discussion

You don’t call this initializer directly. Instead, Swift calls it for you when you use a property-wrapper attribute on a shared reader closure parameter.

## See Also

### Creating a shared reader

`init(value: sending Value)`

- init(projectedValue:)
- Parameters
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/subscript(dynamicmember:)

#app-main)

- Sharing
- SharedReader
- subscript(dynamicMember:)

Instance Subscript

# subscript(dynamicMember:)

Returns a read-only shared reference to the resulting value of a given key path.

SharedReader.swift

## Parameters

`keyPath`

A key path to a specific resulting value.

## Return Value

A new shared reader.

## Overview

You don’t call this subscript directly. Instead, Swift calls it for you when you access a property of the underlying value.

## See Also

### Transforming a shared value

Creates a read-only shared reference from a shared reference.

Unwraps a read-only shared reference to an optional value.

- subscript(dynamicMember:)
- Parameters
- Return Value
- Overview
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(_:)-9wqv4



---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(_:)-9ka0y

-9ka0y#app-main)

- Sharing
- SharedReader
- init(\_:)

Initializer

# init(\_:)

Unwraps a read-only shared reference to an optional value.

SharedReader.swift

## Parameters

`base`

A read-only shared reference to an optional value.

## Discussion

@SharedReader(.currentUser) var currentUser: User?

if let sharedUnwrappedUser = SharedReader($currentUser) {

## See Also

### Transforming a shared value

Returns a read-only shared reference to the resulting value of a given key path.

Creates a read-only shared reference from a shared reference.

- init(\_:)
- Parameters
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(_:)-498ca

-498ca#app-main)

- Sharing
- SharedReader
- init(\_:)

Initializer

# init(\_:)

Unwraps a read-only shared reference to an optional value.

SharedReader.swift

## Parameters

`base`

A read-only shared reference to an optional value.

## Discussion

@SharedReader(.currentUser) var currentUser: User?

if let sharedUnwrappedUser = SharedReader($currentUser) {

## See Also

### Transforming a shared value

Returns a read-only shared reference to the resulting value of a given key path.

Creates a read-only shared reference from a shared reference.

- init(\_:)
- Parameters
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/wrappedvalue



---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/projectedvalue

- Sharing
- SharedReader
- projectedValue

Instance Property

# projectedValue

A projection of the read-only shared value that returns a shared reference.

SharedReader.swift

## See Also

### Reading the value

`var wrappedValue: Value`

The underlying value referenced by the shared variable.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/isloading

- Sharing
- SharedReader
- isLoading

Instance Property

# isLoading

Whether or not an associated shared key is loading data from an external source.

var isLoading: Bool { get }

SharedReader.swift

## See Also

### Loading the value

`func load() async throws`

Requests an up-to-date value from an external source.

Replaces a shared reference’s key and attempts to load its value.

Creates a shared reference to a read-only value using a shared key by loading it from its external source.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/load()

#app-main)

- Sharing
- SharedReader
- load()

Instance Method

# load()

Requests an up-to-date value from an external source.

func load() async throws

SharedReader.swift

## Discussion

When a shared reference is powered by a `SharedReaderKey`, this method will tell it to reload its value from the associated external source.

Most of the time it is not necessary to call this method, as persistence strategies will often subscribe directly to the external source and automatically keep the shared reference synchronized. Some persistence strategies, however, may not have the ability to subscribe to their external source. In these cases, you should call this method whenever you need the most up-to-date value.

## See Also

### Loading the value

`var isLoading: Bool`

Whether or not an associated shared key is loading data from an external source.

Replaces a shared reference’s key and attempts to load its value.

Creates a shared reference to a read-only value using a shared key by loading it from its external source.

- load()
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/load(_:)

#app-main)

- Sharing
- SharedReader
- load(\_:)

Instance Method

# load(\_:)

Replaces a shared reference’s key and attempts to load its value.

SharedReaderKey.swift

## Parameters

`key`

A shared key associated with the shared reference. It is responsible for loading the shared reference’s value from some external source.

## See Also

### Loading the value

`var isLoading: Bool`

Whether or not an associated shared key is loading data from an external source.

`func load() async throws`

Requests an up-to-date value from an external source.

Creates a shared reference to a read-only value using a shared key by loading it from its external source.

- load(\_:)
- Parameters
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(require:)



---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/loaderror

- Sharing
- SharedReader
- loadError

Instance Property

# loadError

An error encountered during the most recent attempt to load data.

var loadError: (any Error)? { get }

SharedReader.swift

## Discussion

This value is `nil` unless a load attempt failed. It contains the latest error from the underlying `SharedReaderKey`. Access it from `@Shared`’s projected value:

@SharedReader(.fileStorage(.users)) var users: [User] = []

var body: some View {
if let loadError = $users.loadError {
ContentUnavailableView {
Label("Failed to load users", systemImage: "xmark.circle")
} description: {
Text(loadError.localizedDescription)
}
} else {
ForEach(users) { user in /* ... */ }
}
}

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/publisher

- Sharing
- SharedReader
- publisher

Instance Property

# publisher

Returns a publisher that emits events when the underlying value changes.

SharedPublisher.swift

## Discussion

Useful when a feature needs to execute logic when a shared reference is updated outside of the feature itself.

@SharedReader var hapticsEnabled: Bool

for await hapticsEnabled in $hapticsEnabled.publisher.values {
// Handle haptics settings change
}

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(_:)-4w2l7

-4w2l7#app-main)

- Sharing
- SharedReader
- init(\_:)

Initializer

# init(\_:)

Creates a shared reference to a read-only value using a shared key with a default value.

SharedReaderKey.swift

## Parameters

`key`

A shared key associated with the shared reference. It is responsible for loading the shared reference’s value from some external source.

## See Also

### Overloads

Creates a shared reference to a read-only value using a shared key by overriding its default value.

Creates a shared reference to an optional, read-only value using a shared key.

- init(\_:)
- Parameters
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(_:)-7s3vb

-7s3vb#app-main)

- Sharing
- SharedReader
- init(\_:)

Initializer

# init(\_:)

Creates a shared reference to an optional, read-only value using a shared key.

SharedReaderKey.swift

## Parameters

`key`

A shared key associated with the shared reference. It is responsible for loading the shared reference’s value from some external source.

## See Also

### Overloads

Creates a shared reference to a read-only value using a shared key by overriding its default value.

Creates a shared reference to a read-only value using a shared key with a default value.

- init(\_:)
- Parameters
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(wrappedvalue:_:)-3i7ys

-3i7ys#app-main)

- Sharing
- SharedReader
- init(wrappedValue:\_:)

Initializer

# init(wrappedValue:\_:)

Creates a shared reference to a read-only value using a shared key by overriding its default value.

init(

)

SharedReaderKey.swift

## Parameters

`wrappedValue`

A default value that is used when no value can be returned from the shared key.

`key`

A shared key associated with the shared reference. It is responsible for loading the shared reference’s value from some external source.

## See Also

### Overloads

Creates a shared reference to an optional, read-only value using a shared key.

Creates a shared reference to a read-only value using a shared key with a default value.

- init(wrappedValue:\_:)
- Parameters
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/read(_:)-3mhrn

-3mhrn#app-main)

- Sharing
- SharedReader
- read(\_:)

Instance Method

# read(\_:)

Returns a read-only shared reference to the resulting value of a given closure.

SharedReader.swift

## Return Value

A new shared reader.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/read(_:)-97sr1

-97sr1#app-main)

- Sharing
- SharedReader
- read(\_:) Deprecated

Instance Method

# read(\_:)

SharedReader.swift

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/constant(_:)

#app-main)

- Sharing
- SharedReader
- constant(\_:) Deprecated

Type Method

# constant(\_:)

Deprecations.swift

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/customdumprepresentable-implementations

- Sharing
- SharedReader
- CustomDumpRepresentable Implementations

API Collection

# CustomDumpRepresentable Implementations

## Topics

### Instance Properties

`var customDumpValue: Any`

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/customstringconvertible-implementations

- Sharing
- SharedReader
- CustomStringConvertible Implementations

API Collection

# CustomStringConvertible Implementations

## Topics

### Instance Properties

`var description: String`

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/dynamicproperty-implementations

- Sharing
- SharedReader
- DynamicProperty Implementations

API Collection

# DynamicProperty Implementations

## Topics

### Instance Methods

`func update()`

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/equatable-implementations

- Sharing
- SharedReader
- Equatable Implementations

API Collection

# Equatable Implementations

## Topics

### Operators

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/identifiable-implementations

- Sharing
- SharedReader
- Identifiable Implementations

API Collection

# Identifiable Implementations

## Topics

### Instance Properties

`var id: Value.ID`

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(wrappedvalue:_:)-56tir)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(value:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(projectedvalue:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/subscript(dynamicmember:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(_:)-9wqv4)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(_:)-9ka0y)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(_:)-498ca)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/wrappedvalue)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/projectedvalue)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/isloading)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/load())

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/load(_:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(require:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/loaderror)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/publisher)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(_:)-4w2l7)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(_:)-7s3vb)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/init(wrappedvalue:_:)-3i7ys)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/read(_:)-3mhrn)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/read(_:)-97sr1)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/constant(_:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/customdumprepresentable-implementations)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/customstringconvertible-implementations)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/dynamicproperty-implementations)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/equatable-implementations)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreader/identifiable-implementations)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/filestorage(_:decode:encode:)

#app-main)

- Sharing
- SharedReaderKey
- fileStorage(\_:decode:encode:)

Type Method

# fileStorage(\_:decode:encode:)

Creates a shared key that can read and write to a value in the file system.

_ url: URL,

FileStorageKey.swift

## Parameters

`url`

The file URL from which to read and write the value.

`decode`

The closure to use for decoding the value.

`encode`

The closure to use for encoding the value.

## Return Value

A file shared key.

## See Also

### Storing a value

Creates a shared key that can read and write to a `Codable` value in the file system.

- fileStorage(\_:decode:encode:)
- Parameters
- Return Value
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/filestorage(_:decode:encode:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/savecontext

- Sharing
- SaveContext

Enumeration

# SaveContext

The context in which a value is saved by a `SharedKey`.

enum SaveContext

SharedKey.swift

## Overview

A key may use this context to determine the behavior of the save. For example, an external system that may be expensive to write to very frequently ( _i.e._ network or file IO) could choose to debounce saves when the value is simply updated in memory (via `withLock(_:fileID:filePath:line:column:)`), but forgo debouncing with an immediate write when the value is saved explicitly (via `save()`).

## Topics

### Enumeration Cases

`case didSet`

The value is being saved implicitly (after a mutation via `withLock(_:fileID:filePath:line:column:)`).

`case userInitiated`

The value is being saved explicitly (via `save()`).

## Relationships

### Conforms To

- `Swift.Equatable`
- `Swift.Hashable`
- `Swift.Sendable`

## See Also

### Updating data sources

`func save(Self.Value, context: SaveContext, continuation: SaveContinuation)`

Saves a value to storage.

**Required**

`struct SaveContinuation`

A mechanism to communicate with a shared key’s external system, synchronously or asynchronously.

- SaveContext
- Overview
- Topics
- Relationships
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/savecontinuation

- Sharing
- SaveContinuation

Structure

# SaveContinuation

A mechanism to communicate with a shared key’s external system, synchronously or asynchronously.

struct SaveContinuation

SharedContinuations.swift

## Overview

A continuation is passed to `save(_:context:continuation:)` so that state can be shared to an external system.

## Topics

### Instance Methods

`func resume()`

Resume the task awaiting the continuation by having it return normally from its suspension point.

`func resume(throwing: any Error)`

Resume the task awaiting the continuation by having it throw an error from its suspension point.

Resume the task awaiting the continuation by having it either return normally or throw an error based on the state of the given `Result` value.

## Relationships

### Conforms To

- `Swift.Sendable`

## See Also

### Updating data sources

`func save(Self.Value, context: SaveContext, continuation: SaveContinuation)`

Saves a value to storage.

**Required**

`enum SaveContext`

The context in which a value is saved by a `SharedKey`.

- SaveContinuation
- Overview
- Topics
- Relationships
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/savecontext)



---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedkey).

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/savecontinuation)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/loadcontext

- Sharing
- LoadContext

Enumeration

# LoadContext

The context in which a value is loaded by a `SharedReaderKey`.

SharedReaderKey.swift

## Topics

### Enumeration Cases

`case initialValue(Value)`

The value is being loaded implicitly at the initialization of a `@Shared` or `@SharedReader` property (via `init(wrappedValue:_:)`).

`case userInitiated`

The value is being loaded explicitly (via `load()`, `load(_:)`, or `init(require:)`).

### Instance Properties

`var initialValue: Value?`

The value associated with `LoadContext.initialValue(_:)`.

## Relationships

### Conforms To

- `Swift.Copyable`
- `Swift.Equatable`
- `Swift.Hashable`
- `Swift.Sendable`

## See Also

### Loading from a data source

Loads the freshest value from storage.

**Required**

`struct LoadContinuation`

A mechanism to communicate with a shared key’s external system, synchronously or asynchronously.

- LoadContext
- Topics
- Relationships
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/loadcontinuation

- Sharing
- LoadContinuation

Structure

# LoadContinuation

A mechanism to communicate with a shared key’s external system, synchronously or asynchronously.

SharedContinuations.swift

## Overview

A continuation is passed to `load(context:continuation:)` so that state can be shared from an external system.

## Topics

### Instance Methods

`func resume(returning: Value)`

Resume the task awaiting the continuation by having it return normally from its suspension point.

`func resume(throwing: any Error)`

Resume the task awaiting the continuation by having it throw an error from its suspension point.

Resume the task awaiting the continuation by having it either return normally or throw an error based on the state of the given `Result` value.

`func resumeReturningInitialValue()`

Resume the task awaiting the continuation by having it return the initial value from its suspension point.

## Relationships

### Conforms To

- `Swift.Sendable`

## See Also

### Loading from a data source

Loads the freshest value from storage.

**Required**

`enum LoadContext`

The context in which a value is loaded by a `SharedReaderKey`.

- LoadContinuation
- Overview
- Topics
- Relationships
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/loadcontext)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey).

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/loadcontinuation)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/id-55bus



---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/id-swift.associatedtype

- Sharing
- SharedReaderKey
- ID

Associated Type

# ID

A type representing the hashable identity of a shared key.

associatedtype ID : Hashable = Self

SharedReaderKey.swift

**Required**

## See Also

### Key hashability

`var id: Self.ID`

The hashable identity of a shared key.

**Required** Default implementation provided.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/id-55bus)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey/id-swift.associatedtype)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedsubscriber

- Sharing
- SharedSubscriber

Structure

# SharedSubscriber

A mechanism to synchronize with a shared key’s external system.

SharedContinuations.swift

## Overview

A subscriber is passed to `subscribe(context:subscriber:)` so that updates to an external system can be shared.

## Topics

### Instance Methods

`func yield(Value)`

Yield an updated value from an external source.

`func yield(throwing: any Error)`

Yield an error from an external source.

Yield a result of an updated value or error from an external source.

`func yieldLoading(Bool)`

Yield a loading state from an external source.

`func yieldReturningInitialValue()`

Yield the initial value provided to the property wrapper when none exists in the external source.

## Relationships

### Conforms To

- `Swift.Sendable`

## See Also

### Subscribing to a data source

Subscribes to external updates.

**Required**

`struct SharedSubscription`

A subscription to a `SharedReaderKey`’s updates.

- SharedSubscriber
- Overview
- Topics
- Relationships
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedsubscription

- Sharing
- SharedSubscription

Structure

# SharedSubscription

A subscription to a `SharedReaderKey`’s updates.

struct SharedSubscription

SharedContinuations.swift

## Overview

This object is returned from `subscribe(context:subscriber:)`, which will feed updates from an external system for its lifetime, or till `cancel()` is called.

## Topics

### Initializers

Initializes the subscription with the given cancel closure.

### Instance Methods

`func cancel()`

Cancels the subscription.

## Relationships

### Conforms To

- `Swift.Sendable`

## See Also

### Subscribing to a data source

Subscribes to external updates.

**Required**

`struct SharedSubscriber`

A mechanism to synchronize with a shared key’s external system.

- SharedSubscription
- Overview
- Topics
- Relationships
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedsubscriber)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedsubscription)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-sharing/2.5.2/documentation/sharing/sharedreaderkey)%E2%80%99s

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

