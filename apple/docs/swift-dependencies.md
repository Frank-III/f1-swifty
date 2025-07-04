<!--
Downloaded via https://llm.codes by @steipete on July 3, 2025 at 09:32 AM
Source URL: https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies
Total pages processed: 181
URLs filtered: Yes
Content de-duplicated: Yes
Availability strings filtered: Yes
Code blocks only: No
-->

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies

Framework

# Dependencies

A dependency management library inspired by SwiftUI’s “environment.”

## Additional Resources

- GitHub Repo

- Discussions

- Point-Free Videos

## Overview

Dependencies are the types and functions in your application that need to interact with outside systems that you do not control. Classic examples of this are API clients that make network requests to servers, but also seemingly innocuous things such as `UUID` and `Date` initializers, file access, user defaults, and even clocks and timers, can all be thought of as dependencies.

You can get really far in application development without ever thinking about dependency management (or, as some like to call it, “dependency injection”), but eventually uncontrolled dependencies can cause many problems in your code base and development cycle:

- Uncontrolled dependencies make it **difficult to write fast, deterministic tests** because you are susceptible to the vagaries of the outside world, such as file systems, network connectivity, internet speed, server uptime, and more.

- Many dependencies **do not work well in SwiftUI previews**, such as location managers and speech recognizers, and some **do not work even in simulators**, such as motion managers, and more. This prevents you from being able to easily iterate on the design of features if you make use of those frameworks.

- Dependencies that interact with 3rd party, non-Apple libraries (such as Firebase, web socket libraries, network libraries, etc.) tend to be heavyweight and take a **long time to compile**. This can slow down your development cycle.

For these reasons, and a lot more, it is highly encouraged for you to take control of your dependencies rather than letting them control you.

But, controlling a dependency is only the beginning. Once you have controlled your dependencies, you are faced with a whole set of new problems:

- How can you **propagate dependencies** throughout your entire application in a way that is more ergonomic than explicitly passing them around everywhere, but safer than having a global dependency?

- How can you **override dependencies** for just one portion of your application? This can be handy for overriding dependencies for tests and SwiftUI previews, as well as specific user flows such as onboarding experiences.

- How can you be sure you **overrode _all_ dependencies** a feature uses in tests? It would be incorrect for a test to mock out some dependencies but leave others as interacting with the outside world.

This library addresses all of the points above, and much, _much_ more.

## Topics

### Getting started

Quick start

Learn the basics of getting started with the library before diving deep into all of its features.

What are dependencies?

Learn what dependencies are, how they complicate your code, and why you want to control them.

### Essentials

Using dependencies

Learn how to use the dependencies that are registered with the library.

Registering dependencies

Learn how to register your own dependencies with the library so that they immediately become available from any part of your code base.

Learn how to provide different implementations of your dependencies for use in the live application, as well as in Xcode previews, and even in tests.

Testing

One of the main reasons to control dependencies is to allow for easier testing. Learn some tips and tricks for writing better tests with the library.

### Advanced

Designing dependencies

Learn techniques on designing your dependencies so that they are most flexible for injecting into features and overriding for tests.

Overriding dependencies

Learn how dependencies can be changed at runtime so that certain parts of your application can use different dependencies.

Dependency lifetimes

Learn about the lifetimes of dependencies, how to prolong the lifetime of a dependency, and how dependencies are inherited.

Single entry point systems

Learn about “single entry point” systems, and why they are best suited for this dependencies library, although it is possible to use the library with non-single entry point systems.

### Dependency management

`struct Dependency`

`struct DependencyValues`

A collection of dependencies that is globally available.

`protocol DependencyKey`

A key for accessing dependencies.

`enum DependencyContext`

A context for a collection of `DependencyValues`.

### Protocols

`protocol AssertionEffect`

A type for creating an assertion or precondition.

`protocol AssertionFailureEffect`

### Structures

`struct DateGenerator`

A dependency that generates a date.

`struct FireAndForget`

A type for creating unstructured tasks in production and structured tasks in tests.

`struct OpenURLEffect`

`struct UUIDGenerator`

A dependency that generates a UUID.

`struct WithRandomNumberGenerator`

A dependency that yields a random number generator to a closure.

- Dependencies
- Additional Resources
- Overview
- Topics

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/quickstart

- Dependencies
- Quick start

Article

# Quick start

Learn the basics of getting started with the library before diving deep into all of its features.

## Adding the Dependencies library as a dependency

To use this library in a SwiftPM project, add it to the dependencies of your Package.swift and specify the `Dependencies` product in any targets that need access to the library:

let package = Package(
dependencies: [\
.package(\
url: "https://github.com/pointfreeco/swift-dependencies",\
from: "1.0.0"\
),\
],
targets: [\
.target(\

dependencies: [\
.product(name: "Dependencies", package: "swift-dependencies")\
]\
)\
]
)

## Using your first dependency

The library allows you to register your own dependencies, but it also comes with many controllable dependencies out of the box (see `DependencyValues` for a full list), and there is a good chance you can immediately make use of one. If you are using `Date()`, `UUID()`, `Task.sleep`, or Combine schedulers directly in your feature’s logic, you can already start to use this library.

@Observable
final class FeatureModel {
var items: [Item] = []

@ObservationIgnored
@Dependency(\.continuousClock) var clock // Controllable way to sleep a task
@ObservationIgnored
@Dependency(\.date.now) var now // Controllable way to ask for current date
@ObservationIgnored
@Dependency(\.mainQueue) var mainQueue // Controllable scheduling on main queue
@ObservationIgnored
@Dependency(\.uuid) var uuid // Controllable UUID creation

// ...
}

Once your dependencies are declared, rather than reaching out to the `Date()`, `UUID()`, etc., directly, you can use the dependency that is defined on your feature’s model:

@Observable
final class FeatureModel {
// ...

func addButtonTapped() async throws {
try await clock.sleep(for: .seconds(1)) // 👈 Don't use 'Task.sleep'
items.append(
Item(
id: uuid(), // 👈 Don't use 'UUID()'
name: "",
createdAt: now // 👈 Don't use 'Date()'
)
)
}
}

That is all it takes to start using controllable dependencies in your features. With that little bit of upfront work done you can start to take advantage of the library’s powers.

For example, you can easily control these dependencies in tests. If you want to test the logic inside the `addButtonTapped` method, you can use the `withDependencies(_:operation:)` function to override any dependencies for the scope of one single test. It’s as easy as 1-2-3:

@Test
func add() async throws {
let model = withDependencies {
// 1️⃣ Override any dependencies that your feature uses.
$0.clock = .immediate
$0.date.now = Date(timeIntervalSinceReferenceDate: 1234567890)
$0.uuid = .incrementing
} operation: {
// 2️⃣ Construct the feature's model
FeatureModel()
}

// 3️⃣ The model now executes in a controlled environment of dependencies,
// and so we can make assertions against its behavior.
try await model.addButtonTapped()
#expect(
model.items == [\
Item(\
id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,\
name: "",\
createdAt: Date(timeIntervalSinceReferenceDate: 1234567890)\
)\
]
)
}

Here we controlled the `date` dependency to always return the same date, and we controlled the `uuid` dependency to return an auto-incrementing UUID every time it is invoked, and we even controlled the `clock` dependency using an `ImmediateClock` to squash all of time into a single instant. If we did not control these dependencies this test would be very difficult to write since there is no way to accurately predict what will be returned by `Date()` and `UUID()`, and we’d have to wait for real world time to pass, making the test slow.

But, controllable dependencies aren’t only useful for tests. They can also be used in Xcode previews. Suppose the feature above makes use of a clock to sleep for an amount of time before something happens in the view. If you don’t want to literally wait for time to pass in order to see how the view changes, you can override the clock dependency to be an “immediate” clock using `prepareDependencies(_:)`:

#Preview {
let _ = prepareDependencies { $0.continuousClock = ImmediateClock() }
// All access of '@Dependency(\.continuousClock)' in this preview will
// use an immediate clock.
FeatureView(model: FeatureModel())
}

This will make it so that the preview uses an immediate clock when run, but when running in a simulator or on device it will still use a live `ContinuousClock`. This makes it possible to override dependencies just for previews without affecting how your app will run in production.

That is the basics to getting started with using the library, but there is still a lot more you can do. You can learn more in depth about What are dependencies? as well as Using dependencies. Once comfortable with that you can learn about Registering dependencies as well as how to best leverage Live, preview, and test dependencies. And finally, there are more advanced topics to explore, such as Designing dependencies, Overriding dependencies, Dependency lifetimes and Single entry point systems.

## See Also

### Getting started

What are dependencies?

Learn what dependencies are, how they complicate your code, and why you want to control them.

- Quick start
- Adding the Dependencies library as a dependency
- Using your first dependency
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/whataredependencies

- Dependencies
- What are dependencies?

Article

# What are dependencies?

Learn what dependencies are, how they complicate your code, and why you want to control them.

## Overview

Dependencies in an application are the types and functions that need to interact with outside systems that you do not control. Classic examples of this are API clients that make network requests to servers, but also seemingly innocuous things such as the `UUID` and `Date` initializers, and even clocks and timers, can be thought of as dependencies.

By controlling the dependencies our features need to do their jobs we gain the ability to completely alter the execution context a feature runs in. This means in tests and Xcode previews you can provide a mock version of an API client that immediately returns some stubbed data rather than making a live network request to a server.

## The need for controlled dependencies

Suppose that you are building a feature that displays a message to the user after 10 seconds. This logic can be packaged up into an observable object:

@Observable
final class FeatureModel {
var message: String?

func onAppear() async {
do {
try await Task.sleep(for: .seconds(10))
message = "Welcome!"
} catch {}
}
}

And a view can make use of that model:

struct FeatureView: View {
let model: FeatureModel

var body: some View {
Form {
if let message = model.message {
Text(message)
}

// ...
}
.task { await model.onAppear() }
}
}

This code works just fine at first, but it has some problems:

First, if you want to iterate on the styling of the message in an Xcode preview you will have to wait for 10 whole seconds of real world time to pass before the message appears. This completely destroys the fast, iterative nature of previews.

Second, if you want to write a test for this feature, you will again have to wait for 10 whole seconds of real world time to pass. This slows down your test suite, making it less likely you will add new tests in the future if the whole suite takes a long time to run.

The reason this code does not play nicely with Xcode previews or tests is because it has an uncontrolled dependency on an outside system: `Task.sleep`. That API can only sleep for a real world amount of time.

## Controlling the dependency

It would be far better if we could swap out different notions of “sleeping” in our feature so that when run in the simulator or device, `Task.sleep` could be used, but in previews or tests other forms of sleeping could be used.

The tool to do this is known as the `Clock` protocol, which is a tool from the Swift standard library. Instead of reaching out to `Task.sleep` directly, we can “inject” our dependency on time-based asynchrony by holding onto a clock in the feature’s model by using the `Dependency` property wrapper and `continuousClock` dependency value:

@ObservationIgnored
@Dependency(\.continuousClock) var clock

func onAppear() async {
do {
try await clock.sleep(for: .seconds(10))
message = "Welcome!"
} catch {}
}
}

That small change makes this feature much friendlier to Xcode previews and testing.

For previews, you can use `prepareDependencies(_:)` to override the `continuousClock` dependency to be an “immediate” clock, which is a clock that does not actually sleep for any amount of time:

#Preview {
let _ = prepareDependencies { $0.continuousClock = ImmediateClock() }
FeatureView(model: FeatureModel())
}

This will cause the message to appear immediately. No need to wait 10 seconds.

Further, in tests you can also override the clock dependency to use an immediate clock, also using the `withDependencies(_:operation:)` helper:

@Test
func message() async {
let model = withDependencies {
$0.continuousClock = .immediate
} operation: {
FeatureModel()
}

#expect(model.message == nil)
await model.onAppear()
#expect(model.message == "Welcome!")
}

This test will pass quickly, and deterministically, 100% of the time. This is why it is so important to control dependencies that interact with outside systems.

## See Also

### Getting started

Quick start

Learn the basics of getting started with the library before diving deep into all of its features.

- What are dependencies?
- Overview
- The need for controlled dependencies
- Controlling the dependency
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/usingdependencies

- Dependencies
- Using dependencies

Article

# Using dependencies

Learn how to use the dependencies that are registered with the library.

## Overview

Once a dependency is registered with the library (see Registering dependencies for more info), one can access the dependency with the `Dependency` property wrapper. This is most commonly done by adding `@Dependency` properties to your feature’s model, such as an observable object, or controller, such as `UIViewController` subclass. It can be used in other scopes too, such as functions, methods and computed properties, but there are caveats to consider, and so doing that is not recommended until you are very comfortable with the library.

The library comes with many common dependencies that can be used in a controllable manner, such as date generators, clocks, random number generators, UUID generators, and more.

For example, suppose you have a feature that needs access to a date initializer, a continuous clock for time-based asynchrony, and a UUID initializer. All 3 dependencies can be added to your feature’s model:

@Observable
final class TodosModel {
@ObservationIgnored @Dependency(\.continuousClock) var clock
@ObservationIgnored @Dependency(\.date) var date
@ObservationIgnored @Dependency(\.uuid) var uuid

// ...
}

Then, all 3 dependencies can easily be overridden with deterministic versions when testing the feature:

@MainActor
@Test
func todos() async {
let model = withDependencies {
$0.continuousClock = .immediate
$0.date.now = Date(timeIntervalSinceReferenceDate: 1234567890)
$0.uuid = .incrementing
} operation: {
TodosModel()
}

// Invoke methods on `model` and make assertions...
}

All references to `continuousClock`, `date`, and `uuid` inside the `TodosModel` will now use the controlled versions.

## See Also

### Essentials

Registering dependencies

Learn how to register your own dependencies with the library so that they immediately become available from any part of your code base.

Learn how to provide different implementations of your dependencies for use in the live application, as well as in Xcode previews, and even in tests.

Testing

One of the main reasons to control dependencies is to allow for easier testing. Learn some tips and tricks for writing better tests with the library.

- Using dependencies
- Overview
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/registeringdependencies

- Dependencies
- Registering dependencies

Article

# Registering dependencies

Learn how to register your own dependencies with the library so that they immediately become available from any part of your code base.

## Overview

Although the library comes with many controllable dependencies out of the box, there are still times when you want to register your own dependencies with the library so that you can use them with the `Dependency` property wrapper. There are a couple ways to achieve this, and the process is quite similar to registering a value with the environment in SwiftUI.

First you create a `DependencyKey` protocol conformance. The minimum implementation you must provide is a `liveValue`, which is the value used when running the app in a simulator or on device, and so it’s appropriate for it to actually make network requests to an external server. It is usually convenient to conform the type of dependency directly to this protocol:

extension APIClient: DependencyKey {
static let liveValue = APIClient(/*
Construct the "live" API client that actually makes network
requests and communicates with the outside world.
*/)
}

With that done you can instantly access your API client dependency from any part of your code base:

@Observable
final class TodosModel {
@ObservationIgnored
@Dependency(APIClient.self) var apiClient
// ...
}

This will automatically use the live dependency in previews, simulators and devices, and in tests you can override the dependency to return mock data:

@MainActor
@Test
func fetchUser() async {
let model = withDependencies {
$0[APIClient.self].fetchTodos = { _ in Todo(id: 1, title: "Get milk") }
} operation: {
TodosModel()
}

await store.loadButtonTapped()
#expect(
model.todos == [Todo(id: 1, title: "Get milk")]
)
}

## Advanced techniques

### Dependency key paths

You can take one additional step to register your dependency value at a particular key path, and that is by extending `DependencyValues` with a property:

extension DependencyValues {
var apiClient: APIClient {
get { self[APIClientKey.self] }
set { self[APIClientKey.self] = newValue }
}
}

This allows you to access and override the dependency in way similar to SwiftUI environment values, as a property that is discoverable from autocomplete:

-@Dependency(APIClient.self) var apiClient
+@Dependency(\.apiClient) var apiClient

let model = withDependencies {
- $0[APIClient.self].fetchTodos = { _ in Todo(id: 1, title: "Get milk") }
+ $0.apiClient.fetchTodos = { _ in Todo(id: 1, title: "Get milk") }
} operation: {
TodosModel()
}

Another benefit of this style is the ability to scope a `@Dependency` to a specific sub-property:

// This feature only needs to access the API client's logged-in user
@Dependency(\.apiClient.currentUser) var currentUser

### Indirect dependency key conformances

It is not always appropriate to conform your dependency directly to the `DependencyKey` protocol, for example if it is a type you do not own. In such cases you can define a separate type that conforms to `DependencyKey`:

enum UserDefaultsKey: DependencyKey {
static let liveValue = UserDefaults.standard
}

You can then access and override your dependency through this key type, instead of the value’s type:

@Dependency(UserDefaultsKey.self) var userDefaults

let model = withDependencies {
let defaults = UserDefaults(suiteName: "test-defaults")
defaults.removePersistentDomain(forName: "test-defaults")
$0[UserDefaultsKey.self] = defaults
} operation: {
TodosModel()
}

If you extend dependency values with a dedicated key path, you can even make this key private:

-enum UserDefaultsKey: DependencyKey { /* ... */ }
+private enum UserDefaultsKey: DependencyKey { /* ... */ }
+
+extension DependencyValues {
+ var userDefaults: UserDefaults {
+ get { self[UserDefaultsKey.self] }
+ set { self[UserDefaultsKey.self] = newValue }
+ }
+}

## See Also

### Essentials

Using dependencies

Learn how to use the dependencies that are registered with the library.

Learn how to provide different implementations of your dependencies for use in the live application, as well as in Xcode previews, and even in tests.

Testing

One of the main reasons to control dependencies is to allow for easier testing. Learn some tips and tricks for writing better tests with the library.

- Registering dependencies
- Overview
- Advanced techniques
- Dependency key paths
- Indirect dependency key conformances
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/livepreviewtest

- Dependencies
- Live, preview, and test dependencies

API Collection

# Live, preview, and test dependencies

Learn how to provide different implementations of your dependencies for use in the live application, as well as in Xcode previews, and even in tests.

## Overview

In the previous section we showed that to conform to `DependencyKey` you must provide _at least_ a `liveValue`, which is the default version of the dependency that is used when running on a device or simulator. The `DependencyKey` protocol inherits from a base protocol, `TestDependencyKey`, which has two other optional properties that can be implemented `testValue` and `previewValue`, both of which will delegate to `liveValue` if left unimplemented.

Leveraging these alternative dependency implementations allow to run your features in safer environments for tests, previews, and more.

- Live value

- Test value

- Preview value

- Separating interface and implementation

- Cascading rules

## Live value

The `liveValue` static property from the `DependencyKey` protocol is the only truly _required_ requirement from the protocol. This is the value that is used when running your feature in the simulator or on a device. It is appropriate to use an implementation of your dependency for this value that actually interacts with the outside world. That is, it can make network requests, perform time-based asynchrony, interact with the file system, and more.

However, if you only implement `liveValue`, then it means your feature will use the live dependency when run in tests, which can be problematic. That will cause live API requests to be made, which are slow and flakey, analytics will be tracked, which will muddy your data, files will be written to disk, which will bleed into other tests, and more.

Using live dependencies in tests are so problematic that the library will cause a test failure if you ever interact with a live dependency while tests are running:

@Test
func feature() async throws {
let model = FeatureModel()

model.addButtonTapped()
// 🛑 A dependency has no test implementation, but was accessed from a
// test context:
//
// Dependency:
// APIClient
//
// Dependencies registered with the library are not allowed to use
// their default, live implementations when run from tests.
}

If you truly want to use live dependencies in tests you have to make it explicit by overriding the dependency and setting the live value:

@Test
func feature() async throws {
let model = withDependencies {
// ⚠️ Explicitly say you want to use a live dependency.
$0.apiClient = .liveValue
} operation: {
FeatureModel()
}

// ...
}

## Test value

The `testValue` static property from the `TestDependencyKey` protocol should be implemented if you want to provide a specific implementation of your dependency for all tests. At a bare minimum you should provide an implementation of your dependency that does not reach out to the real world. This means it should not make network requests, should not sleep for real-world time, should not touch the file system, etc.

This can guarantee that a whole class of bugs do not happen in your code when running tests. For example, suppose you have a dependency for tracking user events with your analytics server. If you allow this dependency to be used in an uncontrolled manner in tests you run the risk of accidentally tracking events that do not actually correspond to user actions, and therefore will result in bad, unreliable data.

Another example of a dependency you want to control during tests is access to the file system. If your feature writes a file to disk during a test, then that file will remain there for subsequent runs of other tests. This causes testing artifacts to bleed over into other tests, which can cause confusing failures.

So, providing a `testValue` can be very useful, but even better, we highly encourage users of our library to provide what is known as “unimplemented” versions of their dependencies for their `testValue`. These are implementations that cause a test failure if any of its endpoints are invoked.

You can use our Issue Reporting library to aid in this, which is immediately accessible as a transitive dependency. It comes with a function called `unimplemented` that can return a function of nearly any signature with the property that if it is invoked it will cause a test failure. For example, the hypothetical analytics dependency we considered a moment ago can be given such a `testValue` like so:

struct AnalyticsClient {

}

import Dependencies

extension AnalyticsClient: TestDependencyKey {
static let testValue = Self(
track: unimplemented("AnalyticsClient.track")
)
}

This makes it so that if your feature ever makes use of the `track` endpoint on the analytics client without you specifically overriding it, you will get a test failure. This makes it easy to be notified if you ever start tracking new events without writing a test for it, which can be incredibly powerful.

## Preview value

We’ve now seen that `liveValue` is an appropriate place to put dependency implementations that reach out to the outside world, and `testValue` is an appropriate place to put dependency implementations that refrain from interacting with the outside world. Even better if the `testValue` actually causes a test failure if any of its endpoints are accessed.

There’s a third kind of implementation that you can provide that sits somewhere between `liveValue` and `testValue`: it’s called `previewValue`. It will be used whenever your feature is run in an Xcode preview.

Xcode previews are similar to tests in that you usually do not want to interact with the outside world, such as making network requests. In fact, many of Apple’s frameworks do not work in previews, such as Core Location, and so it will be hard to interact with your feature in previews if it touches those frameworks.

However, Xcode previews are dissimilar to tests in that it’s fine for dependencies to return some mock data. There’s no need to deal with “unimplemented” clients for proving which dependencies are actually used.

For example, suppose you have an API client with some endpoints for fetching users. You do not want to make live, network requests in Swift previews because that will cause previews to run slowly. So, you can provide a `previewValue` implementation that synchronously and immediately returns some mock data:

extension APIClient: TestDependencyKey {
static let previewValue = Self(
fetchUsers: {
[\
User(id: 1, name: "Blob"),\
User(id: 2, name: "Blob Jr."),\
User(id: 3, name: "Blob Sr."),\
]
},
fetchUser: { id in
User(id: id, name: "Blob, id: \(id)")
}
)
}

Then when running a feature that uses this dependency in an Xcode preview, it will immediately get data provided to it, making it easier for you to iterate on your feature’s logic and styling.

You can also always override dependencies for the preview if you want to test out a specific configuration of data. For example, if you want to test the empty state of your feature when the API client returns an empty array, you can do so like this:

struct Feature_Previews: PreviewProvider {
static var previews: some View {
FeatureView(
model: withDependencies {
$0.apiClient.fetchUsers = { _ in [] }
} operation: {
FeatureModel()
}
)
}
}

Or if you want to preview how your feature deals with errors returned from the API:

struct Feature_Previews: PreviewProvider {
static var previews: some View {
FeatureView(
model: withDependencies {
$0.apiClient.fetchUser = { _ in
struct SomeError: Error {}
throw SomeError()
}
} operation: {
FeatureModel()
}
)
}
}

## Separating interface and implementation

It is common for the interface of an dependency to be super lightweight and compile quickly (as usually it consists of some simple data types), but for the “live” implementation to be heavyweight and take a long time to compile (usually when 3rd party libraries are involved). In such cases it is recommended to put the interface and live implementation in separate modules, and then implementation can depend on the interface.

In order to accomplish this you can conform your dependency to the `TestDependencyKey` protocol in the interface module, like this:

// Module: AnalyticsClient
struct AnalyticsClient: TestDependencyKey {
// ...

static let testValue = Self(/* ... */)
}

And then in the implementation module you can extend the dependency to further conform to the `DependencyKey` protocol and provide a live implementation:

// Module: LiveAnalyticsClient
extension AnalyticsClient: DependencyKey {
static let liveValue = Self(/* ... */)
}

## Cascading rules

Depending on which of `testValue`, `previewValue` and `liveValue` you implement, _and_ depending on which conformance to `TestDependencyKey` and `DependencyKey` is visible to the compiler, there are rules that decide which actual dependency will be used at runtime.

- A default implementation of `testValue` is provided, and it simply calls out to `previewValue`. This means that in a testing context, the preview version of the dependency will be used.

- Further, if a conformance to `DependencyKey` is provided in addition to `TestDependencyKey`, then `previewValue` has a default implementation provided, and it calls out to `liveValue`. This means that in a preview context, the live version of the dependency will be used.

Note that a consequence of the above two rules is that if only `liveValue` is implemented when conforming to `DependencyKey`, then both `testValue` and `previewValue` will call out to the `liveValue` under the hood. This means your dependency will be interacting with the outside world during tests and in previews, which may not be ideal.

There is one thing the library will do to help you catch using a live dependency in tests. If a live dependency is used in a test context, the test case will fail. This is done to make sure you understand the risks of using a live dependency in tests. To confirm that you truly want to use a live dependency you can override the dependency with `.liveValue`:

This will prevent the library from failing your test for using a live dependency in a testing context.

On the flip side, the library also helps you catch when you have not provided a `liveValue`. When running the application in the simulator or on a device, if a dependency is accessed for which a `liveValue` has not been provided, a purple, runtime warning will appear in Xcode letting you know.

There is also a way to force a dependency context in an application target or test target. When the environment variable `SWIFT_DEPENDENCIES_CONTEXT` is present, and is equal to either `live`, `preview` or `test`, that context will be used. This can be useful in UI tests since the application target runs as a separate process outside of the testing process.

In order to force the application target to run with test dependencies during a UI test, simply perform the following in your UI test case:

func testFeature() {
self.app.launchEnvironment["SWIFT_DEPENDENCIES_CONTEXT"] = "test"
self.app.launch()
…
}

## Topics

### Previews

`extension PreviewTrait`

## See Also

### Essentials

Using dependencies

Learn how to use the dependencies that are registered with the library.

Registering dependencies

Learn how to register your own dependencies with the library so that they immediately become available from any part of your code base.

Testing

One of the main reasons to control dependencies is to allow for easier testing. Learn some tips and tricks for writing better tests with the library.

- Live, preview, and test dependencies
- Overview
- Live value
- Test value
- Preview value
- Separating interface and implementation
- Cascading rules
- Topics
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/testing

- Dependencies
- Testing

Article

# Testing

One of the main reasons to control dependencies is to allow for easier testing. Learn some tips and tricks for writing better tests with the library.

## Overview

In the article Live, preview, and test dependencies you learned how to define a `testValue` when registering your dependencies, which will be automatically used during tests. In this article we cover more detailed information about how to actually write tests with overridden dependencies, as well as some tips and gotchas to keep in mind.

- Swift’s native Testing framework

- Xcode’s XCTest framework

- Changing dependencies during tests

- Testing gotchas

- Testing host application

- Statically linking your tests target to Dependencies

- Test case leakage

- Static @Dependency

- Parameterized and repeated @Test runs

## Swift’s native Testing framework

This library has full support for Swift’s native Testing framework, in addition to Xcode’s XCTest framework. It even works with in process concurrent tests without tests bleeding over to other tests.

The most direct way to override dependencies in a test is to simply wrap the entire test function in `withDependencies(_:operation:)` in order to override the dependencies for the duration of that test:

@Test func basics() {
withDependencies {
$0.uuid = .incrementing
} operation: {
let model = FeatureModel()
// Invoke methods on 'model' and make assertions
}
}

The library also ships with test traits that can help allivate the nesting incurred by `withDependencies(_:operation:)`. In order to get access to the test traits you must link the DependenciesTestSupport library to your test target, after which you can do the following:

@Test(.dependency(\.uuid, .incrementing))
func basics() {
let model = FeatureModel()
// Invoke methods on 'model' and make assertions
}

It is also possible to override dependencies for an entire `@Suite` using a suite trait:

@Suite(.dependency(\.uuid, .incrementing))
struct MySuite {
@Test func basics() {
let model = FeatureModel()
// Invoke methods on 'model' and make assertions
}
}

If you need to override multiple dependencies you can do so using the `.dependencies` test trait:

@Suite(.dependencies {
$0.date.now = Date(timeIntervalSince1970:12324567890)
$0.uuid = .incrementing
})
struct MySuite {
@Test func basics() {
let model = FeatureModel()
// Invoke methods on 'model' and make assertions
}
}

Because tests in Swift’s native Testing framework run in parallel and in process, it is possible for multiple tests running to access the same dependency. This can be troublesome if those dependencies are stateful, making it possible for one test to make changes to a dependency that another test sees. This will cause mysterious test failures and the type of test failure you get may even depend on the order the tests ran.

To properly handle this we recommend having a “base suite” that all of your tests and suites are nested inside. That will allow you to provide a fresh set of dependencies to each test, and it will not be possible for changes in one test to bleed over to another test.

To do this, simply define a `@Suite` and use the `.dependencies` trait:

@Suite(.dependencies) struct BaseSuite {}

This type does not need to have anything in its body, and the `.dependencies` trait is responsible for giving each test in the suite its own scratchpad of dependencies.

Then nest all of your `@Suite` s and `@Test` s in this type:

extension BaseSuite {
@Suite struct FeatureTests {
@Test func basics() {
// ...
}
}
}

This will allow all tests to run in parallel and in process without them affecting each other.

## Xcode’s XCTest framework

This library also works with Xcode’s testing framework, known as XCTest. Just as with Swift’s Testing framework, one can override dependencies for a test by wrapping the body of a test in `withDependencies(_:operation:)`:

func testBasics() {
withDependencies {
$0.uuid = .incrementing
} operation: {
let model = FeatureModel()
// Invoke methods on 'model' and make assertions
}
}

XCTest does not support traits, and so it is not possible to override dependencies on a per-test basis without incurring the indentation of `withDependencies(_:operation:)`. However, you can override all dependencies for an entire test case by implementing the `invokeTest` method:

class FeatureTests: XCTestCase {
override func invokeTest() {
withDependencies {
$0.uuid = .incrementing
} operation: {
super.invokeTest()
}
}

func testBasics() {
// Test has 'uuid' dependency overridden.
}
}

## Changing dependencies during tests

While it is most common to set up all dependencies at the beginning of a test and then make assertions, sometimes it is necessary to also change the dependencies in the middle of a test. This can be very handy for modeling test flows in which a dependency is in a failure state at first, but then later becomes successful. To do this one can simply use `withDependencies(_:operation:)` again inside the body of your test.

For example, suppose we have a login feature such that if you try logging in and an error is thrown causing a message to appear. But then later, if login succeeds that message goes away. We can test that entire flow, from end-to-end, but starting the API client dependency in a state where login fails, and then later change the dependency so that it succeeds using `withDependencies(_:operation:)`:

@Test(.dependency(\.apiClient.login, { _, _ in throw LoginFailure() }))
func retryFlow() async {
let model = LoginModel()
await model.loginButtonTapped()
#expect(model.errorMessage == "We could not log you in. Please try again")

withDependencies {
$0.apiClient.login = { email, password in
LoginResponse(user: User(id: 42, name: "Blob"))
}
} operation: {
await model.loginButtonTapped()
#expect(model.errorMessage == nil)
}
}

Even though the `LoginModel` was created in the context of the API client failing it still sees the updated dependency when run in the new `withDependencies` context.

## Testing gotchas

### Testing host application

This is not well known, but when an application target runs tests it actually boots up a simulator and runs your actual application entry point in the simulator. This means while tests are running, your application’s code is separately also running. This can be a huge gotcha because it means you may be unknowingly making network requests, tracking analytics, writing data to user defaults or to the disk, and more.

This usually flies under the radar and you just won’t know it’s happening, which can be problematic. But, once you start using this library to control your dependencies the problem can surface in a very visible manner. Typically, when a dependency is used in a test context without being overridden, a test failure occurs. This makes it possible for your test to pass successfully, yet for some mysterious reason the test suite fails. This happens because the code in the _app host_ is now running in a test context, and accessing dependencies will cause test failures.

This only happens when running tests in a _application target_, that is, a target that is specifically used to launch the application for a simulator or device. This does not happen when running tests for frameworks or SwiftPM libraries, which is yet another good reason to modularize your code base.

However, if you aren’t in a position to modularize your code base right now, there is a quick fix. Our Issue Reporting library, which is transitively included with this library, comes with a property you can check to see if tests are currently running. If they are, you can omit the entire entry point of your application.

For example, for a pure SwiftUI entry point you can do the following to keep your application from running during tests:

import IssueReporting
import SwiftUI

@main
struct MyApp: App {
var body: some Scene {
WindowGroup {
if !isTesting {
// Your real root view
}
}
}
}

And in an `UIApplicationDelegate`-based entry point you can do the following:

func application(
_ application: UIApplication,
didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?

guard !isTesting else { return true }
// ...
}

That will allow tests to run in the application target without your actual application code interfering.

### Statically linking your tests target to Dependencies

If you statically link the `Dependencies` module to your tests target, its implementation may clash with the implementation that is statically linked to the app itself. It then may use a different `DependencyValues` base type in the app and in tests, and you may encounter test failures where dependency overrides performed with `withDependencies` seem ineffective.

In such cases Xcode will display multiple warnings similar to:

The solution is to remove the static link to `Dependencies` from your test target, as you transitively get access to it through the app itself. In Xcode, go to “Build Phases” and remove “Dependencies” from the “Link Binary With Libraries” section. When using SwiftPM, remove the “Dependencies” entry from the `testTarget`‘s’ `dependencies` array in `Package.swift`.

### Test case leakage

Sometimes it is possible to have tests that pass successfully when run in isolation, but somehow fail when run together as a suite. This can happen when using escaping closures in tests, which creates an alternate execution flow, allowing a test’s code to continue running long after the test has finished.

This can happen in any kind of test, not just when using this dependencies library. For example, each of the following test methods passes when run in isolation, yet running the whole test suite fails:

final class SomeTest: XCTestCase {
func testA() {
Task {
try await Task.sleep(for: .seconds(0.1))
XCTFail()
}
}
func testB() async throws {
try await Task.sleep(for: .seconds(0.15))
}
}

This happens because `testA` escapes some work to be executed and then finishes immediately with no failure. Then, while `testB` is executing, the escaped work from `testA` finally gets around to executing and causes a failure.

You can also run into this issue while using this dependencies library. In particular, you may see test a failure for accessing a `testValue` of a dependency that your test is not even using. If running that test in isolation passes, then you probably have some other test accidentally leaking its code into your test. You need to check every other test in the suite to see if any of them use escaping closures causing the leakage.

### Static @Dependency

You should never use the `@Dependency` property wrapper as a static variable:

class Model {
@Dependency(\.date) static var date
// ...
}

You will not be able to override this dependency in the normal fashion. In general there is no need to ever have a static dependency, and so you should avoid this pattern.

### Parameterized and repeated @Test runs

The library comes with support for Swift’s new native Testing framework. However, as there are still still features missing from the Testing framework that XCTest has, there may be some additional steps you must take.

If you are are writing a _parameterized_ test using the `@Test` macro, you will need to surround the entire body of your test in `withDependencies` that resets the entire set of values to guarantee that a fresh set of dependencies is used per parameter:

@Test(arguments: [1, 2, 3])
func feature(_ number: Int) {
withDependencies {
$0 = DependencyValues()
} operation: {
// All test code in here...
}
}

This will guarantee that dependency state does not bleed over to each parameter of the test.

## See Also

### Essentials

Using dependencies

Learn how to use the dependencies that are registered with the library.

Registering dependencies

Learn how to register your own dependencies with the library so that they immediately become available from any part of your code base.

Learn how to provide different implementations of your dependencies for use in the live application, as well as in Xcode previews, and even in tests.

- Testing
- Overview
- Swift’s native Testing framework
- Xcode’s XCTest framework
- Changing dependencies during tests
- Testing gotchas
- Testing host application
- Statically linking your tests target to Dependencies
- Test case leakage
- Static @Dependency
- Parameterized and repeated @Test runs
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/designingdependencies

- Dependencies
- Designing dependencies

Article

# Designing dependencies

Learn techniques on designing your dependencies so that they are most flexible for injecting into features and overriding for tests.

## Overview

- Protocol-based dependencies

- Struct-based dependencies

- @DependencyClient macro

Making it possible to control your dependencies is the most important step you can take towards making your features isolatable and testable. The second most important step after that is to design your dependencies in a way that maximizes their flexibility in tests and other situations.

## Protocol-based dependencies

The most popular way to design dependencies in Swift is to use protocols. For example, if your feature needs to interact with an audio player, you might design a protocol with methods for playing, stopping, and more:

protocol AudioPlayer {
func loop(url: URL) async throws
func play(url: URL) async throws
func setVolume(_ volume: Float) async
func stop() async
}

Then you are free to make as many conformances of this protocol as you want, such as a `LiveAudioPlayer` that actually interacts with AVFoundation, or a `MockAudioPlayer` that doesn’t play any sounds, but does suspend in order to simulate that something is playing. You could even have an `UnimplementedAudioPlayer` conformance that invokes `reportIssue` when any method is invoked:

struct LiveAudioPlayer: AudioPlayer {
let audioEngine: AVAudioEngine
// ...
}
struct MockAudioPlayer: AudioPlayer {
// ...
}
struct UnimplementedAudioPlayer: AudioPlayer {
func loop(url: URL) async throws {
reportIssue("AudioPlayer.loop is unimplemented")
}
// ...
}

And all of those conformances can be used to specify the live, preview and test values for the dependency:

private enum AudioPlayerKey: DependencyKey {
static let liveValue: any AudioPlayer = LiveAudioPlayer()
static let previewValue: any AudioPlayer = MockAudioPlayer()
static let testValue: any AudioPlayer = UnimplementedAudioPlayer()
}

This style of dependencies works just fine, and if it is what you are most comfortable with then there is no need to change.

## Struct-based dependencies

However, there is a small change one can make to this dependency to unlock even more power. Rather than designing the audio player as a protocol, we can use a struct with closure properties to represent the interface:

struct AudioPlayerClient {

}

Then, rather than defining types that conform to the protocol you construct values:

extension AudioPlayerClient {
static var live: Self {
let audioEngine: AVAudioEngine
return Self(/*...*/)
}

static let mock = Self(/* ... */)

static let unimplemented = Self(
loop: { _ in reportIssue("AudioPlayerClient.loop is unimplemented") },
// ...
)
}

Then, to register this dependency you can leverage the `AudioPlayerClient` struct to conform to the `DependencyKey` protocol. There’s no need to define a new type. In fact, you can even define the live, preview and test values directly in the conformance, all at once:

extension AudioPlayerClient: DependencyKey {
static var liveValue: Self {
let audioEngine: AVAudioEngine
return Self(/* ... */)
}

static let previewValue = Self(/* ... */)

static let testValue = Self(
loop: unimplemented("AudioPlayerClient.loop"),
play: unimplemented("AudioPlayerClient.play"),
setVolume: unimplemented("AudioPlayerClient.setVolume"),
stop: unimplemented("AudioPlayerClient.stop")
)
}

extension DependencyValues {
var audioPlayer: AudioPlayerClient {
get { self[AudioPlayerClient.self] }
set { self[AudioPlayerClient.self] = newValue }
}
}

If you design your dependencies in this way you can pick which dependency endpoints you need in your feature. For example, if you have a feature that needs an audio player to do its job, but it only needs the `play` endpoint, and doesn’t need to loop, set volume or stop audio, then you can specify a dependency on just that one function:

@Observable
final class FeatureModel {
@ObservationIgnored
@Dependency(\.audioPlayer.play) var play
// ...
}

This can allow your features to better describe the minimal interface they need from dependencies, which can help a feature seem less intimidating.

You can also override the bare minimum of the dependency in tests. For example, suppose that one user flow of your feature you are testing invokes the `play` endpoint, but you don’t think any other endpoint will be called. Then you can write a test that overrides only that one single endpoint:

func testFeature() {
let isPlaying = ActorIsolated(false)

let model = withDependencies {
$0.audioPlayer.play = { _ in await isPlaying.setValue(true) }
} operation: {
FeatureModel()
}

await model.play()
XCTAssertEqual(isPlaying.value, true)
}

If this test passes you can be guaranteed that no other endpoints of the dependency are used in the user flow you are testing. If someday in the future more of the dependency is used, you will instantly get a test failure, letting you know that there is more behavior that you must assert on.

## @DependencyClient macro

The library ships with a macro that can help improve the ergonomics of struct-based dependency interfaces. The macro ships as a separate library within this package because it depends on SwiftSyntax, and that increases the build times by about 20 seconds. We did not want to force everyone using this library to incur that cost, so if you want to use the macro you will need to explicitly add the `DependenciesMacros` product to your targets.

Once that is done you can apply the `@DependencyClient` macro directly to your dependency struct:

import DependenciesMacros

@DependencyClient
struct AudioPlayerClient {

This does a few things for you. First, it automatically provides a default for each endpoint that simply throws an error and triggers an XCTest failure. This means you get an “unimplemented” client for free with no additional work. This allows you to simplify the `testValue` of your `TestDependencyKey` conformance like so:

extension AudioPlayerClient: TestDependencyKey {
- static let testValue = Self(
- loop: unimplemented("AudioPlayerClient.loop"),
- play: unimplemented("AudioPlayerClient.play"),
- setVolume: unimplemented("AudioPlayerClient.setVolume"),
- stop: unimplemented("AudioPlayerClient.stop")
- )
+ static let testValue = Self()
}

This behaves the exact same as before, but now all of the code is generated for you.

Further, when you provide argument labels to the client’s closure endpoints, the macro turns that information into methods with argument labels. This means you can invoke the `play` endpoint like so:

try await player.play(url: URL(filePath: "..."))

And finally, the macro also generates a public initializer for you with all of the client’s endpoints. One typically needs to maintain this initializer when separate the interface of the dependency from the implementation (see Separating interface and implementation for more information). But now there is no need to maintain that code as it is automatically provided for you by the macro.

## See Also

### Advanced

Overriding dependencies

Learn how dependencies can be changed at runtime so that certain parts of your application can use different dependencies.

Dependency lifetimes

Learn about the lifetimes of dependencies, how to prolong the lifetime of a dependency, and how dependencies are inherited.

Single entry point systems

Learn about “single entry point” systems, and why they are best suited for this dependencies library, although it is possible to use the library with non-single entry point systems.

- Designing dependencies
- Overview
- Overview
- Protocol-based dependencies
- Struct-based dependencies
- @DependencyClient macro
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/overridingdependencies

- Dependencies
- Overriding dependencies

Article

# Overriding dependencies

Learn how dependencies can be changed at runtime so that certain parts of your application can use different dependencies.

## Overview

It is possible to change the dependencies for a particular feature running inside your application. This can be handy when running a feature in a more controlled environment where it may not be appropriate to communicate with the outside world. The most obvious examples of this is running a feature in tests or Xcode previews, but there are other interesting examples too.

## The basics

For example, suppose you want to teach users how to use your feature through an onboarding experience. In such an experience it may not be appropriate for the user’s actions to cause data to be written to disk, or user defaults to be written, or any number of things. It would be better to use mock versions of those dependencies so that the user can interact with your feature in a fully controlled environment.

To do this you need to make use of the `withDependencies(from:operation:fileID:filePath:line:column:)` function, which allows you to inherit the dependencies from an existing object _and_ additionally override some of those dependencies:

@Observable
final class AppModel {
var onboardingTodos: TodosModel?

func tutorialButtonTapped() {
onboardingTodos = withDependencies(from: self) {
$0.apiClient = .mock
$0.fileManager = .mock
$0.userDefaults = .mock
} operation: {
TodosModel()
}
}

// ...
}

In the code above, the `TodosModel` is constructed with an environment that has all of the same dependencies as the parent, `AppModel`, and further the `apiClient`, `fileManager` and `userDefaults` have been overridden to be mocked in a controllable manner so that they do not interact with the outside world. This way you can be sure that while the user is playing around in the tutorial sandbox they are not accidentally making network requests, saving data to disk or overwriting settings in user defaults.

## Scoping dependencies

Extra care must be taken when overriding dependencies in order for the new dependencies to propagate down to child models, and grandchild models, and on and on. All child models constructed should be done so inside an invocation of `withDependencies(from:operation:fileID:filePath:line:column:)` so that the child model picks up the exact dependencies the parent is using.

For example, taking the code sample from above, suppose that the `TodosModel` could drill down to an edit screen for a particular todo. You could model that with an `EditTodoModel` and a piece of optional state that when hydrated causes the drill down:

@Observable
final class TodosModel {
var todos: [Todo] = []
var editTodo: EditTodoModel?

@ObservationIgnored
@Dependency(\.apiClient) var apiClient
@ObservationIgnored
@Dependency(\.fileManager) var fileManager
@ObservationIgnored
@Dependency(\.userDefaults) var userDefaults

func tappedTodo(_ todo: Todo) {
editTodo = EditTodoModel(todo: todo)
}

However, when constructing `EditTodoModel` inside the `tappedTodo` method, its dependencies will go that the application launches with. It will not have any of the overridden dependencies from when the `TodosModel` was created.

In order to make sure the overridden dependencies continue to propagate to the child feature, you must wrap the creation of the child model in `withDependencies(from:operation:fileID:filePath:line:column:)`:

func tappedTodo(_ todo: Todo) {
editTodo = withDependencies(from: self) {
EditTodoModel(todo: todo)
}
}

Note that we are using `withDependencies(from: self)` in the above code. That is what allows the `EditTodoModel` to be constructed with all the same dependencies as `self`, and should be used even if you are not explicitly overriding dependencies.

## Testing

To override dependencies in tests you can use `withDependencies(_:operation:)` in the same way you override dependencies in features. For example, if a model uses an API client to fetch a user when the view appears, a test for this functionality could be written by overriding the `apiClient` to return some mock data:

@Test
func onAppear() async {
let model = withDependencies {
$0.apiClient.fetchUser = { _ in User(id: 42, name: "Blob") }
} operation: {
FeatureModel()
}

#expect(model.user == nil)
await model.onAppear()
#expect(model.user == User(id: 42, name: "Blob"))
}

Sometimes there is a dependency that you want to override in a particular way for the entire test case. For example, your feature may make extensive use of the `date` dependency and it may be cumbersome to override it in every test. Instead, it can be done a single time by overriding `invokeTest` in your test case class:

final class FeatureTests: XCTestCase {
override func invokeTest() {
withDependencies {
$0.date.now = Date(timeIntervalSince1970: 1234567890)
} operation: {
super.invokeTest()
}
}

// All test functions will use the mock date generator.
}

Any dependencies overridden in `invokeTest` will be overridden for the entirety of the test case.

You can also implement a base test class for other test cases to inherit from in order to provide a base set of dependencies for many test cases to use:

class BaseTestCase: XCTestCase {
override func invokeTest() {
withDependencies {
// Mutate $0 to override dependencies for all test
// cases that inherit from BaseTestCase.
// ...
} operation: {
super.invokeTest()
}
}
}

## See Also

### Advanced

Designing dependencies

Learn techniques on designing your dependencies so that they are most flexible for injecting into features and overriding for tests.

Dependency lifetimes

Learn about the lifetimes of dependencies, how to prolong the lifetime of a dependency, and how dependencies are inherited.

Single entry point systems

Learn about “single entry point” systems, and why they are best suited for this dependencies library, although it is possible to use the library with non-single entry point systems.

- Overriding dependencies
- Overview
- The basics
- Scoping dependencies
- Testing
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/lifetimes

- Dependencies
- Dependency lifetimes

Article

# Dependency lifetimes

Learn about the lifetimes of dependencies, how to prolong the lifetime of a dependency, and how dependencies are inherited.

## Overview

When the `Dependency` property wrapper is initialized it captures the current state of the dependency at that moment. This provides a kind of “scoping” mechanism that is similar to how `@TaskLocal` values are inherited by new asynchronous tasks, but has some new caveats of its own.

- How task locals work

- How @Dependency lifetimes work

- Accessing a @Dependency from pre-structured concurrency

## How task locals work

Task locals are what power this library under the hood, and so it can be important to first understand how task locals work and how task local inheritance works.

Task locals are values that are implicitly associated with a task. They make it possible to push values deep into every part of an application without having to explicitly pass the values around. This makes task locals sound like a “global” variable, which you may have heard is bad, but task locals have 3 features that make them safe to use and easy to reason about:

- Task locals are safe to use from concurrent contexts. This means multiple tasks can access the same task local without fear of a race condition.

- Task locals can be mutated only in specific, well-defined scopes. It is not allowed to forever mutate a task local in a way that all parts of the application observe the change.

- Task locals are inherited by new tasks that are spun up from existing tasks.

For example, suppose you had the following task local:

enum Locals {
@TaskLocal static var value = 1
}

The value can only be “mutated” by using the task locals `withValue` method, which allows changing `value` only for the scope of a non-escaping closure:

print(Locals.value) // 1
Locals.$value.withValue(42) {
print(Locals.value) // 42
}
print(Locals.value) // 1

The above shows that `Locals.value` is changed only for the duration of the `withValue` closure.

This may seem very restrictive, but it is also what makes task locals safe and easy to reason about. You are not allowed to make task local changes to extend for any amount of time, such as mutating it directly:

Locals.value = 42
// 🛑 Cannot assign to property: 'value' is a get-only property

If this were possible it would make changes to `value` instantly observable from every part of the application. It could even cause two consecutive reads of `Locals.value` to report different values:

print(Locals.value) // 1
print(Locals.value) // 42

This would make code very difficult to reason about, and so is why task locals can be changed for only very specific scopes.

However, there is a tool that Swift provides that allows task locals to prolong their changes outside the scope of a non-escaping closure, and does so in a way without making it difficult to reason about. That tool is known as “task local inheritance.” Any child tasks created via `TaskGroup` or `async let`, as well as tasks created with `Task { }`, inherit the task locals at the moment they were created.

For example, the following example shows that a task local remains overridden even when accessed from a `Task` a second later, and even though that closure is escaping:

print(Locals.value) // 1
Locals.$value.withValue(42) {
print(Locals.value) // 42
Task {
try await Task.sleep(for: .seconds(1))
print(Locals.value) // 42
}
print(Locals.value) // 42
}

Even though the closure handed to `Task` is escaping, and even though the print happens long after `withValue`’s scope has ended, somehow still “42” is printed. This happens because task locals are inherited in tasks.

This gives us the ability to prolong the lifetime of a task local change, but in a well-defined and easy to reason about way.

It is important to note that task locals are not inherited in _all_ escaping contexts. It does work for `Task.init` and `TaskGroup.addTask`, which make use of escaping closures, but only because the standard library special cases those tools to inherit task locals (see `copyTaskLocals` in this code).

But generally speaking, task local overrides are lost when crossing escaping boundaries. For example, if instead of using `Task` we used `DispatchQueue.main.asyncAfter` in the above code, we will observe that the task local resets

Now that we understand how task locals work, we can begin to understand how `@Dependency` lifetimes work, and how they can be extended. Under the hood, dependencies are held as a `@TaskLocal`, and so many of the rules from task locals also apply to dependencies, _e.g._ dependencies are inherited in tasks but not generally across escaping boundaries. But there are a few additional caveats.

Just like with task locals, a dependency’s value can be changed for the scope of the trailing, non-escaping closure of `withDependencies(_:operation:)`, but the library also ships with a few tools to prolong the change in a well-defined manner.

For example, suppose you have a feature that needs access to an API client for fetching a user:

@Observable
class FeatureModel {
var user: User?

@ObservationIgnored
@Dependency(\.apiClient) var apiClient

func onAppear() async {
do {
user = try await apiClient.fetchUser()
} catch {}
}
}

Sometimes we may want to construct this model in a “controlled” environment, where we use a different implementation of `apiClient`.

Controlling dependencies isn’t only useful in tests. It can also be used directly in your feature’s logic in order to run some child feature in a controlled environment, and can even be used in Xcode previews.

Let’s first see how controlling dependencies can be used directly in a feature’s logic. Suppose we wanted to show this feature in the application as a part of an “onboarding” experience. During the onboarding experience, we want the user to be able to make use of the feature without executing real life API requests, which may cause data to be written to a remote database.

Accomplishing this can be difficult because models are created in one scope and then dependencies are used in another scope. However, as mentioned above, the library does extra work to make it so that later referencing dependencies of a model uses the dependencies captured at the moment of creating the model.

For example, if you create the features model in the following way:

let onboardingModel = withDependencies {
$0.apiClient = .mock
} operation: {
FeatureModel()
}

…then all references to the `apiClient` dependency inside `FeatureModel` will be using the mock API client. This is true even though the `FeatureModel`’s `onAppear` method will be called outside the scope of the `operation` closure.

However, care must be taken when creating a child model from a parent model. In order for the child’s dependencies to inherit from the parent’s dependencies, you must make use of `withDependencies(from:operation:fileID:filePath:line:column:)` when creating the child model:

let onboardingModel = withDependencies(from: self) {
$0.apiClient = .mock
} operation: {
FeatureModel()
}

This makes `FeatureModel`’s dependencies inherit from the parent feature, and you can further override any additional dependencies you want.

In general, if you want dependencies to be properly inherited through every layer of feature in your application, you should make sure to create any observable models inside a `withDependencies(from:operation:fileID:filePath:line:column:)` scope.

If you do this, it also allows you to run previews in a very specific environment. Dependencies already support the concept of a `previewValue`, which is an implementation of the dependency used when run in an Xcode preview (see Live, preview, and test dependencies for more info). It is most appropriate to implement the `previewValue` by immediately returning some basic, mock data.

But sometimes you want to customize dependencies for the preview so that you can see how your feature behaves in very specific states. For example, if you wanted to see how your feature reacts when the `fetchUser` endpoint throws an error, you can update the preview like so:

#Preview {
let _ = prepareDependencies {
$0.apiClient.fetchUser = { _ in throw SomeError() }
}
FeatureView(model: FeatureModel())
}

## Accessing a @Dependency from pre-structured concurrency

Because dependencies are held in a task local, they only automatically propagate within structured concurrency and in `Task` s. In order to access dependencies across escaping closures, _e.g._ in a callback or Combine operator, you must do additional work to “escape” the dependencies so that they can be passed into the closure.

For example, suppose you use `DispatchQueue.main.asyncAfter` to execute some logic after a delay, and that logic needs to make use of dependencies. In order to guarantee that dependencies used in the escaping closure of `asyncAfter` reflect the correct values, you must use `withEscapedDependencies(_:)`:

withEscapedDependencies { dependencies in
DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
dependencies.yield {
// All code in here will use dependencies at the time of calling withEscapedDependencies.
}
}
}

## See Also

### Advanced

Designing dependencies

Learn techniques on designing your dependencies so that they are most flexible for injecting into features and overriding for tests.

Overriding dependencies

Learn how dependencies can be changed at runtime so that certain parts of your application can use different dependencies.

Single entry point systems

Learn about “single entry point” systems, and why they are best suited for this dependencies library, although it is possible to use the library with non-single entry point systems.

- Dependency lifetimes
- Overview
- How task locals work
- How @Dependency lifetimes work
- Accessing a @Dependency from pre-structured concurrency
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/singleentrypointsystems

- Dependencies
- Single entry point systems

Article

# Single entry point systems

Learn about “single entry point” systems, and why they are best suited for this dependencies library, although it is possible to use the library with non-single entry point systems.

## Overview

A system is said to have a “single entry point” if there is one place to invoke all of its logic and behavior. Such systems make it easy to alter the execution context a system runs in, which can be powerful.

## Examples of single entry point systems

By far the most popular example of this in the Apple ecosystem is SwiftUI views. A view is a type conforming to the `View` protocol and exposing a single `body` property that returns the view hierarchy:

struct FeatureView: View {
var body: some View {
// All of the view is constructed in here...
}
}

There is only one way to create the actual views that SwiftUI will render to the screen, and that is by invoking the `body` property, though we never need to actually do that. SwiftUI hides all of that from us in the `@main` entry point of the application or in `UIHostingController`.

The Composable Architecture is another example of a single entry point system, but this time for implementing logic and behavior of a view. It provides a protocol that one conforms to and it has a single requirement, `reduce`, which is responsible for mutating the feature’s state and returning effects to execute:

import ComposableArchitecture

@Reducer
struct Feature {
struct State {
// ...
}
enum Action {
// ...
}

// All of the feature's logic and behavior is implemented here...
}
}

Again, there is only one way to execute this feature’s logic, and that is by invoking the `reduce` method. However, you never actually need to do that in practice. The Composable Architecture hides all of that from you, and instead you just construct a `Store` at the root of the application.

Another example of a single entry point system is a server framework. Such frameworks usually have a simple request-to-response lifecycle. It starts by the framework receiving a request from an external client. Then one uses the framework’s tools in order to interpret that request and build up a response to send

One of the most interesting aspects of single entry point systems is that they have a well-defined scope from beginning to end, and that makes it possible to easily alter their execution context.

For example, SwiftUI views have a powerful feature known as “environment values”. They allow you to propagate values deep into a view hierarchy and can be overridden for just one small subset of the view tree.

The following SwiftUI view stacks a header view on top of a footer view, and overrides the foreground color for the header:

struct ContentView: View {
var body: some View {
VStack {
HeaderView()
.foregroundColor(.red)
FooterView()
}
}
}

The `.red` foreground color will be applied to every view in `HeaderView`, including deeply nested views. And most importantly, that style is applied only to the header and not to the `FooterView`.

The `foregroundColor` view modifier is powered by environment values under the hood, as can be seen by printing the type of `ContentView`’s body:

print(ContentView.Body.self)
// VStack<
// TupleView<(
// ModifiedContent<
// HeaderView,
// _EnvironmentKeyWritingModifier<Optional<Color>>

// FooterView

The presence of `_EnvironmentKeyWritingModifier` shows that an environment key is being written.

This is an incredibly powerful feature of SwiftUI, and the only reason it works so well and is so easy to understand is specifically because SwiftUI views form a single entry point system. That makes it possible to alter the execution environment of `HeaderView` so that its foreground color is red, and that altered state does not affect the other parts of the view tree, such as `FooterView`.

The same is possible with the Composable Architecture and the dependencies of features. For example, suppose some feature’s logic and behavior was decomposed into the logic for the “header” and “footer,” and that we wanted to alter the dependencies used in the header. This can be done using the `.dependency` method on reducers, which acts similarly to the `.environment` view modifier from SwiftUI:

Header()
.dependency(\.fileManager, .mock)
.dependency(\.userDefaults, .mock)

Footer()
}
}

This will override the `fileManager` and `userDefaults` dependency to be mocks for the `Header` feature (as well as all features called to from inside `Header`), but will leave the dependencies untouched for all other features, including `Footer`.

This pattern can also be repeated for server applications. It is possible to alter the execution environment on a per-request basis, and even for just a subset of the request-to-response lifecycle.

It is incredibly powerful to be able to do this, but it all hinges on being able to express your system as a single point of entry. Without that it becomes a lot more difficult to alter the execution context of the system, or a sub-system, because there is not only one place to do so.

## Non-single entry point systems

While this library thrives when applied to “single entry point” systems, it is still possible to use with other kinds of systems. You just have to be a little more careful. In particular, you must be careful where you add dependencies to your features and how you construct features that use dependencies.

When adding a dependency to a feature modeled in an observable object, you should make use of `@Dependency` only for the object’s instance properties:

@Observable
final class FeatureModel {
@ObservationIgnored
@Dependency(\.apiClient) var apiClient
@ObservationIgnored
@Dependency(\.date) var date
// ...
}

And similarly for `UIViewController` subclasses:

final class FeatureViewController: UIViewController {
@Dependency(\.apiClient) var apiClient
@Dependency(\.date) var date
// ...
}

Then you are free to use those dependencies from anywhere within the model and controller.

Then, if you create a new model or controller from within an existing model or controller, you will need to take an extra step to make sure that the parent feature’s dependencies are propagated to the child.

For example, if your SwiftUI model holds a piece of optional state that drives a sheet, then when hydrating that state you will want to wrap it in `withDependencies(from:operation:fileID:filePath:line:column:)`:

@Observable
final class FeatureModel {
var editModel: EditModel?

@ObservationIgnored
@Dependency(\.apiClient) var apiClient
@ObservationIgnored
@Dependency(\.date) var date

func editButtonTapped() {
editModel = withDependencies(from: self) {
EditModel()
}
}
}

This makes it so that if `FeatureModel` were constructed with some of its dependencies overridden (see Overriding dependencies), then those changes will also be visible to `EditModel`.

The same principle holds for UIKit. When constructing a child view controller to be presented, be sure to wrap its construction in `withDependencies(from:operation:fileID:filePath:line:column:)`:

final class FeatureViewController: UIViewController {
@Dependency(\.apiClient) var apiClient
@Dependency(\.date) var date

func editButtonTapped() {
let controller = withDependencies(from: self) {
EditViewController()
}
present(controller, animated: true, completion: nil)
}
}

If you make sure to always use `withDependencies(from:operation:fileID:filePath:line:column:)` when constructing child models and controllers you can be sure that changes to dependencies at any layer of your application will be visible at any layer below it. See Dependency lifetimes for more information on how dependency lifetimes work.

## See Also

### Advanced

Designing dependencies

Learn techniques on designing your dependencies so that they are most flexible for injecting into features and overriding for tests.

Overriding dependencies

Learn how dependencies can be changed at runtime so that certain parts of your application can use different dependencies.

Dependency lifetimes

Learn about the lifetimes of dependencies, how to prolong the lifetime of a dependency, and how dependencies are inherited.

- Single entry point systems
- Overview
- Examples of single entry point systems
- Altered execution environments
- Non-single entry point systems
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependency

- Dependencies
- Dependency

Structure

# Dependency

@propertyWrapper

Dependency.swift

## Topics

### Using a dependency

Creates a dependency property to read the specified key path.

Creates a dependency property to read a dependency object.

### Getting the value

`var wrappedValue: Value`

The current value of the dependency property.

## Relationships

### Conforms To

- `Swift.Sendable`

## See Also

### Dependency management

`struct DependencyValues`

A collection of dependencies that is globally available.

`protocol DependencyKey`

A key for accessing dependencies.

`enum DependencyContext`

A context for a collection of `DependencyValues`.

- Dependency
- Topics
- Relationships
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues

- Dependencies
- DependencyValues

Structure

# DependencyValues

A collection of dependencies that is globally available.

struct DependencyValues

DependencyValues.swift

## Overview

To access a particular dependency from the collection you use the `Dependency` property wrapper:

@Dependency(\.date) var date
// ...
let now = date.now

To change a dependency for a well-defined scope you can use the `withDependencies(_:operation:)` method:

@Dependency(\.date) var date
let now = date.now

withDependencies {
$0.date.now = Date(timeIntervalSinceReferenceDate: 1234567890)
} operation: {
@Dependency(\.date.now) var now: Date
now.timeIntervalSinceReferenceDate // 1234567890
}

The dependencies will be changed for the lifetime of the `operation` scope, which can be synchronous or asynchronous.

To register a dependency inside `DependencyValues`, you first create a type to conform to the `DependencyKey` protocol in order to specify the `liveValue` to use for the dependency when run in simulators and on devices. It can even be private:

private enum MyValueKey: DependencyKey {
static let liveValue = 42
}

And then extend `DependencyValues` with a computed property that uses the key to read and write to `DependencyValues`:

extension DependencyValues {
var myValue: Int {
get { self[MyValueKey.self] }
set { self[MyValueKey.self] = newValue }
}
}

With those steps done you can access the dependency using the `Dependency` property wrapper:

@Dependency(\.myValue) var myValue
myValue // 42

Read the article Registering dependencies for more information.

## Topics

### Creating and accessing values

`init()`

Creates a dependency values instance.

Accesses the dependency value associated with a custom key.

### Overriding values

Updates the current dependencies for the duration of a synchronous operation.

Updates the current dependencies for the duration of a synchronous operation by taking the dependencies tied to a given object.

Prepares global dependencies for the lifetime of your application.

### Escaping contexts

Propagates the current dependencies to an escaping context.

### Dependency values

`var assert: any AssertionEffect`

A dependency for handling assertions.

`var assertionFailure: any AssertionFailureEffect`

A dependency for failing an assertion.

`var calendar: Calendar`

The current calendar that features should use when handling dates.

`var context: DependencyContext`

The current dependency context.

The current clock that features should use when a `ContinuousClock` would be appropriate.

`var date: DateGenerator`

A dependency that returns the current date.

`var fireAndForget: FireAndForget`

A dependency for firing off an unstructured task.

`var locale: Locale`

The “main” queue.

The “main” run loop.

`var openURL: OpenURLEffect`

A dependency that opens a URL.

`var precondition: any AssertionEffect`

A dependency for handling preconditions.

The current clock that features should use when a `SuspendingClock` would be appropriate.

`var timeZone: TimeZone`

The current time zone that features should use when handling dates.

`var urlSession: URLSession`

The URL session that features should use to make URL requests.

`var uuid: UUIDGenerator`

A dependency that generates UUIDs.

`var withRandomNumberGenerator: WithRandomNumberGenerator`

A dependency that yields a random number generator to a closure.

### Default contexts

`static var live: DependencyValues`

A collection of “live” dependencies.

`static var preview: DependencyValues`

A collection of “preview” dependencies.

`static var test: DependencyValues`

A collection of “test” dependencies.

### Deprecations

Review unsupported dependency values APIs and their replacements.

### Structures

`struct Continuation`

A capture of dependencies to use in an escaping context.

## Relationships

### Conforms To

- `Swift.Sendable`

## See Also

### Dependency management

`struct Dependency`

`protocol DependencyKey`

A key for accessing dependencies.

`enum DependencyContext`

A context for a collection of `DependencyValues`.

- DependencyValues
- Overview
- Topics
- Relationships
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencykey

- Dependencies
- DependencyKey

Protocol

# DependencyKey

A key for accessing dependencies.

DependencyKey.swift

## Overview

Types conform to this protocol to extend `DependencyValues` with custom dependencies. It is similar to SwiftUI’s `EnvironmentKey` protocol, which is used to add values to `EnvironmentValues`.

`DependencyKey` has one main requirement, `liveValue`, which must return a default value for your dependency that is used when the application is run in a simulator or device. If the `liveValue` is accessed while your feature runs in tests a test failure will be triggered.

To add a `UserClient` dependency that can fetch and save user values can be done like so:

// The user client dependency.
struct UserClient {

}
// Conform to DependencyKey to provide a live implementation of
// the interface.
extension UserClient: DependencyKey {
static let liveValue = Self(
fetchUser: { /* Make request to fetch user */ },
saveUser: { /* Make request to save user */ }
)
}
// Register the dependency within DependencyValues.
extension DependencyValues {
var userClient: UserClient {
get { self[UserClient.self] }
set { self[UserClient.self] = newValue }
}
}

When a dependency is first accessed its value is cached so that it will not be requested again. This means if your `liveValue` is implemented as a computed property instead of a `static let`, then it will only be called a single time:

extension UserClient: DependencyKey {
static var liveValue: Self {
// Only called once when dependency is first accessed.
return Self(/* ... */)
}
}

`DependencyKey` inherits from `TestDependencyKey`, which has two other overridable requirements: `testValue`, which should return a default value for the purpose of testing, and `previewValue`, which can return a default value suitable for Xcode previews. When left unimplemented, these endpoints will return the `liveValue`, instead.

If you plan on separating your interface from your live implementation, conform to `TestDependencyKey` in your interface module, and conform to `DependencyKey` in your implementation module.

See the Live, preview, and test dependencies article for more information.

## Topics

### Registering a dependency

`associatedtype Value = Self`

The associated type representing the type of the dependency key’s value.

**Required**

`static var liveValue: Self.Value`

The live value for the dependency key.

`static var testValue: Self.Value`

The test value for the dependency key.

**Required** Default implementation provided.

`static var previewValue: Self.Value`

The preview value for the dependency key.

### Modularizing a dependency

`protocol TestDependencyKey`

A key for accessing test dependencies.

## Relationships

### Inherits From

- `TestDependencyKey`

## See Also

### Dependency management

`struct Dependency`

`struct DependencyValues`

A collection of dependencies that is globally available.

`enum DependencyContext`

A context for a collection of `DependencyValues`.

- DependencyKey
- Overview
- Topics
- Relationships
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencycontext

- Dependencies
- DependencyContext

Enumeration

# DependencyContext

A context for a collection of `DependencyValues`.

enum DependencyContext

DependencyContext.swift

## Overview

There are three distinct contexts that dependencies can be loaded from and registered to:

- `DependencyContext.live`: The default context.

- `DependencyContext.preview`: A context for Xcode previews.

- `DependencyContext.test`: A context for tests.

## Topics

### Enumeration Cases

`case live`

The default, “live” context for dependencies.

`case preview`

A “preview” context for dependencies.

`case test`

A “test” context for dependencies.

## Relationships

### Conforms To

- `Swift.Equatable`
- `Swift.Hashable`
- `Swift.Sendable`

## See Also

### Dependency management

`struct Dependency`

`struct DependencyValues`

A collection of dependencies that is globally available.

`protocol DependencyKey`

A key for accessing dependencies.

- DependencyContext
- Overview
- Topics
- Relationships
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/assertioneffect

- Dependencies
- AssertionEffect

Protocol

# AssertionEffect

A type for creating an assertion or precondition.

protocol AssertionEffect : Sendable

Assert.swift

## Overview

See `assert` or `precondition` for more information.

## Topics

### Instance Methods

**Required** Default implementation provided.

## Relationships

### Inherits From

- `Swift.Sendable`

## See Also

### Dependency values

`protocol AssertionFailureEffect`

- AssertionEffect
- Overview
- Topics
- Relationships
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/assertionfailureeffect

- Dependencies
- AssertionFailureEffect

Protocol

# AssertionFailureEffect

protocol AssertionFailureEffect : Sendable

Assert.swift

## Topics

### Instance Methods

**Required** Default implementation provided.

## Relationships

### Inherits From

- `Swift.Sendable`

## See Also

### Dependency values

`protocol AssertionEffect`

A type for creating an assertion or precondition.

- AssertionFailureEffect
- Topics
- Relationships
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dategenerator

- Dependencies
- DateGenerator

Structure

# DateGenerator

A dependency that generates a date.

struct DateGenerator

Date.swift

## Overview

See `date` for more information.

## Topics

### Initializers

Initializes a date generator that generates a date from a closure.

### Instance Properties

`var now: Date`

The current date.

### Type Methods

A generator that returns a constant date.

## Relationships

### Conforms To

- `Swift.Sendable`

- DateGenerator
- Overview
- Topics
- Relationships

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/fireandforget

- Dependencies
- FireAndForget

Structure

# FireAndForget

A type for creating unstructured tasks in production and structured tasks in tests.

struct FireAndForget

FireAndForget.swift

## Overview

See `fireAndForget` for more information.

## Topics

## Relationships

### Conforms To

- `Swift.Sendable`

- FireAndForget
- Overview
- Topics
- Relationships

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/openurleffect

- Dependencies
- OpenURLEffect

Structure

# OpenURLEffect

struct OpenURLEffect

OpenURL.swift

## Topics

### Instance Methods

`func callAsFunction(URL) async`

## Relationships

### Conforms To

- `Swift.Sendable`

- OpenURLEffect
- Topics
- Relationships

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/uuidgenerator

- Dependencies
- UUIDGenerator

Structure

# UUIDGenerator

A dependency that generates a UUID.

struct UUIDGenerator

UUID.swift

## Overview

See `uuid` for more information.

## Topics

### Initializers

Initializes a UUID generator that generates a UUID from a closure.

### Type Properties

`static var incrementing: UUIDGenerator`

A generator that generates UUIDs in incrementing order.

### Type Methods

A generator that returns a constant UUID.

## Relationships

### Conforms To

- `Swift.Sendable`

- UUIDGenerator
- Overview
- Topics
- Relationships

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/withrandomnumbergenerator

- Dependencies
- WithRandomNumberGenerator

Structure

# WithRandomNumberGenerator

A dependency that yields a random number generator to a closure.

struct WithRandomNumberGenerator

WithRandomNumberGenerator.swift

## Overview

See `withRandomNumberGenerator` for more information.

## Topics

### Initializers

`init(some RandomNumberGenerator & Sendable)`

## Relationships

### Conforms To

- `Swift.Sendable`

- WithRandomNumberGenerator
- Overview
- Topics
- Relationships

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/quickstart)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/whataredependencies)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/usingdependencies)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/registeringdependencies)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/livepreviewtest)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/testing)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/designingdependencies)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/overridingdependencies)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/lifetimes)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/singleentrypointsystems)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependency)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencykey)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencycontext)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues).

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/assertioneffect)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/assertionfailureeffect)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dategenerator)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/fireandforget)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/openurleffect)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/uuidgenerator)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/withrandomnumbergenerator)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/continuousclock

- Dependencies
- DependencyValues
- continuousClock

Instance Property

# continuousClock

The current clock that features should use when a `ContinuousClock` would be appropriate.

Clocks.swift

## Discussion

This clock is type-erased so that it can be swapped out in previews and tests for another clock, like `ImmediateClock` and `TestClock` that come with the Clocks library (which is automatically imported and available when you import this library).

By default, a live `ContinuousClock` is supplied. When used in a testing context, an `UnimplementedClock` is provided, which generates an XCTest failure when used, unless explicitly overridden using `withDependencies(_:operation:)`:

// Provision model with overridden dependencies
let model = withDependencies {
$0.continuousClock = ImmediateClock()
} operation: {
FeatureModel()
}

// Make assertions with model...

See `suspendingClock` to override a feature’s `SuspendingClock`, instead.

## See Also

### Dependency values

`var assert: any AssertionEffect`

A dependency for handling assertions.

`var assertionFailure: any AssertionFailureEffect`

A dependency for failing an assertion.

`var calendar: Calendar`

The current calendar that features should use when handling dates.

`var context: DependencyContext`

The current dependency context.

`var date: DateGenerator`

A dependency that returns the current date.

`var fireAndForget: FireAndForget`

A dependency for firing off an unstructured task.

`var locale: Locale`

The “main” queue.

The “main” run loop.

`var openURL: OpenURLEffect`

A dependency that opens a URL.

`var precondition: any AssertionEffect`

A dependency for handling preconditions.

The current clock that features should use when a `SuspendingClock` would be appropriate.

`var timeZone: TimeZone`

The current time zone that features should use when handling dates.

`var urlSession: URLSession`

The URL session that features should use to make URL requests.

`var uuid: UUIDGenerator`

A dependency that generates UUIDs.

- continuousClock
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/preparedependencies(_:)

#app-main)

- Dependencies
- prepareDependencies(\_:)

Function

# prepareDependencies(\_:)

Prepares global dependencies for the lifetime of your application.

WithDependencies.swift

## Parameters

`updateValues`

A closure for updating the current dependency values for the lifetime of your application.

## Discussion

This can be used to set up the initial dependencies for your application in the entry point of your app, or for Xcode previews. It is best to call this as early as possible in the lifetime of your app.

For example, in a SwiftUI entry point, it is appropriate to call this in the initializer of your `App` conformance:

@main
struct MyApp: App {
init() {
prepareDependencies {
$0.defaultDatabase = try! DatabaseQueue(/* ... */)
}
}

// ...
}

Or in an app delegate entry point, you can invoke it from `didFinishLaunchingWithOptions`:

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
func application(
_ application: UIApplication,
didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?

prepareDependencies {
$0.defaultDatabase = try! DatabaseQueue(/* ... */)
}
// Override point for customization after application launch.
return true
}

You can also use `prepareDependencies(_:)` in Xcode previews, but you do have to use `let _` in order to play nicely with result builders:

#Preview {
let _ = prepareDependencies {
$0.defaultDatabase = try! DatabaseQueue(/* ... */)
}
FeatureView()
}

## See Also

### Overriding values

Updates the current dependencies for the duration of a synchronous operation.

Updates the current dependencies for the duration of a synchronous operation by taking the dependencies tied to a given object.

- prepareDependencies(\_:)
- Parameters
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/withdependencies(_:operation:)

#app-main)

- Dependencies
- withDependencies(\_:operation:)

Function

# withDependencies(\_:operation:)

Updates the current dependencies for the duration of a synchronous operation.

@discardableResult

WithDependencies.swift

## Parameters

`updateValuesForOperation`

A closure for updating the current dependency values for the duration of the operation.

`operation`

An operation to perform wherein dependencies have been overridden.

## Return Value

The result returned from `operation`.

## Discussion

Any mutations made to `DependencyValues` inside `updateValuesForOperation` will be visible to everything executed in the operation. For example, if you wanted to force the `date` dependency to be a particular date, you can do:

withDependencies {
$0.date.now = Date(timeIntervalSince1970: 1234567890)
} operation: {
// References to date in here are pinned to 1234567890.
}

## Topics

### Overloads

Updates the current dependencies for the duration of an asynchronous operation.

## See Also

### Overriding values

Updates the current dependencies for the duration of a synchronous operation by taking the dependencies tied to a given object.

Prepares global dependencies for the lifetime of your application.

- withDependencies(\_:operation:)
- Parameters
- Return Value
- Discussion
- Topics
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/continuousclock)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/preparedependencies(_:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/withdependencies(_:operation:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/withdependencies(from:operation:fileid:filepath:line:column:)

#app-main)

- Dependencies
- withDependencies(from:operation:fileID:filePath:line:column:)

Function

# withDependencies(from:operation:fileID:filePath:line:column:)

Updates the current dependencies for the duration of a synchronous operation by taking the dependencies tied to a given object.

@discardableResult

from model: Model,

fileID: StaticString = #fileID,
filePath: StaticString = #filePath,
line: UInt = #line,
column: UInt = #column

WithDependencies.swift

## Parameters

`model`

An object with dependencies. The given model should have at least one `@Dependency` property, or should have been initialized and returned from a `withDependencies` operation.

`operation`

The operation to run with the updated dependencies.

`fileID`

The source `#fileID` associated with the operation.

`filePath`

The source `#filePath` associated with the operation.

`line`

The source `#line` associated with the operation.

`column`

The source `#column` associated with the operation.

## Return Value

The result returned from `operation`.

## Topics

### Overloads

Updates the current dependencies for the duration of an asynchronous operation by taking the dependencies tied to a given object.

## See Also

### Overriding values

Updates the current dependencies for the duration of a synchronous operation.

Prepares global dependencies for the lifetime of your application.

- withDependencies(from:operation:fileID:filePath:line:column:)
- Parameters
- Return Value
- Topics
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/withdependencies(from:operation:fileid:filepath:line:column:)):

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/overridingdependencies)),

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/withdependencies(from:operation:fileid:filepath:line:column:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/testdependencykey

- Dependencies
- TestDependencyKey

Protocol

# TestDependencyKey

A key for accessing test dependencies.

DependencyKey.swift

## Overview

This protocol lives one layer below `DependencyKey` and allows you to separate a dependency’s interface from its live implementation.

`TestDependencyKey` has one main requirement, `testValue`, which must return a default value for the purposes of testing, and one optional requirement, `previewValue`, which can return a default value suitable for Xcode previews, or the `testValue`, if left unimplemented.

See `DependencyKey` to define a static, default value for the live application.

## Topics

### Registering a dependency

`associatedtype Value : Sendable = Self`

The associated type representing the type of the dependency key’s value.

**Required**

`static var testValue: Self.Value`

The test value for the dependency key.

**Required** Default implementation provided.

`static var previewValue: Self.Value`

The preview value for the dependency key.

**Required** Default implementations provided.

### Type Properties

`static var shouldReportUnimplemented: Bool`

Determines if it is appropriate to report an issue in an accessed `testValue`.

## Relationships

### Inherited By

- `DependencyKey`

- TestDependencyKey
- Overview
- Topics
- Relationships

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/testdependencykey)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencykey/livevalue

- Dependencies
- DependencyKey
- liveValue

Type Property

# liveValue

The live value for the dependency key.

static var liveValue: Self.Value { get }

DependencyKey.swift

**Required**

## Discussion

This is the value used by default when running the application in a simulator or on a device. Using a live dependency in a test context will lead to a test failure as you should mock your dependencies for tests.

To automatically supply a test dependency in a test context, consider implementing the `testValue` requirement.

## See Also

### Registering a dependency

`associatedtype Value = Self`

The associated type representing the type of the dependency key’s value.

`static var testValue: Self.Value`

The test value for the dependency key.

**Required** Default implementation provided.

`static var previewValue: Self.Value`

The preview value for the dependency key.

- liveValue
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencykey/livevalue),

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/testdependencykey/previewvalue

- Dependencies
- TestDependencyKey
- previewValue

Type Property

# previewValue

The preview value for the dependency key.

static var previewValue: Self.Value { get }

DependencyKey.swift

**Required** Default implementations provided.

## Discussion

This value is automatically used when the associated dependency value is accessed from an Xcode preview, as well as when the current `context` is set to `DependencyContext.preview`:

withDependencies {
$0.context = .preview
} operation: {
// Dependencies accessed here default to their "preview" value
}

## Default Implementations

### TestDependencyKey Implementations

`static var previewValue: Self.Value`

A default implementation that provides the `liveValue` to Xcode previews.

A default implementation that provides the `testValue` to Xcode previews.

## See Also

### Registering a dependency

`associatedtype Value : Sendable = Self`

The associated type representing the type of the dependency key’s value.

**Required**

`static var testValue: Self.Value`

The test value for the dependency key.

**Required** Default implementation provided.

- previewValue
- Discussion
- Default Implementations
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/withescapeddependencies(_:)-5xvi3

-5xvi3#app-main)

- Dependencies
- withEscapedDependencies(\_:)

Function

# withEscapedDependencies(\_:)

Propagates the current dependencies to an escaping context.

WithDependencies.swift

## Parameters

`operation`

A closure that takes a `DependencyValues.Continuation` value for propagating dependencies past an escaping closure boundary.

## Discussion

This helper takes a trailing closure that is provided an `DependencyValues.Continuation` value, which can be used to access dependencies in an escaped context. It is useful in situations where you cannot leverage structured concurrency and must use escaping closures. Dependencies do not automatically propagate across escaping boundaries like they do in structured contexts and in `Task` s.

For example, suppose you want to use `DispatchQueue.main.asyncAfter` to execute some logic after a delay, and that logic needs to make use of dependencies. In order to guarantee that dependencies used in the escaping closure of `asyncAfter` reflect the correct values, you should use `withEscapedDependencies`:

withEscapedDependencies { dependencies in
DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
dependencies.yield {
// All code in here will use dependencies at the time of calling withEscapedDependencies.
}
}
}

As a general rule, you should surround _all_ escaping code that may access dependencies with this helper, and you should use `yield(_:)` _immediately_ inside the escaping closure. Otherwise you run the risk of the escaped code using the wrong dependencies. But, you should also try your hardest to keep your code in the structured world using Swift’s tools of structured concurrency, and should avoid using escaping closures.

If you need to further override dependencies in the escaped closure, do so inside the `yield(_:)` and not outside:

withEscapedDependencies { dependencies in
DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
dependencies.yield {
withDependencies {
$0.apiClient = .mock
} operation: {
// All code in here will use dependencies at the time of calling
// withEscapedDependencies except the API client will be mocked.
}
}
}
}

## Topics

### Yielding escaped dependencies

`struct Continuation`

A capture of dependencies to use in an escaping context.

### Overloads

- withEscapedDependencies(\_:)
- Parameters
- Discussion
- Topics

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/withdependencies(_:operation:)),

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/testdependencykey/previewvalue),

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/testdependencykey/previewvalue)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/withescapeddependencies(_:)-5xvi3):

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/testdependencykey/testvalue

- Dependencies
- TestDependencyKey
- testValue

Type Property

# testValue

The test value for the dependency key.

static var testValue: Self.Value { get }

DependencyKey.swift

**Required** Default implementation provided.

## Discussion

This value is automatically used when the associated dependency value is accessed from an XCTest run, as well as when the current `context` is set to `DependencyContext.test`:

withDependencies {
$0.context = .test
} operation: {
// Dependencies accessed here default to their "test" value
}

## Default Implementations

### DependencyKey Implementations

`static var testValue: Self.Value`

A default implementation that provides the `previewValue` to test runs (or `liveValue`, if no preview value is implemented), but will trigger a test failure when accessed.

## See Also

### Registering a dependency

`associatedtype Value : Sendable = Self`

The associated type representing the type of the dependency key’s value.

**Required**

`static var previewValue: Self.Value`

The preview value for the dependency key.

**Required** Default implementations provided.

- testValue
- Discussion
- Default Implementations
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/testdependencykey/testvalue)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/withdependencies(_:operation:)).

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/withdependencies(_:operation:)):

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/preparedependencies(_:)):

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/usingdependencies).

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/livepreviewtest).

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/designingdependencies),

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/overridingdependencies),

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/singleentrypointsystems).

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/developertoolssupport/previewtrait

- Dependencies
- DeveloperToolsSupport
- PreviewTrait

Extended Structure

# PreviewTrait

DependenciesDeveloperToolsSupport

extension PreviewTrait

## Topics

### Type Methods

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/testdependencykey),

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencykey/livevalue)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/testdependencykey/testvalue).

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/testdependencykey/testvalue):

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/testdependencykey/previewvalue).

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/testdependencykey/testvalue),

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencykey/livevalue).

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencykey),

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/developertoolssupport/previewtrait)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/date

- Dependencies
- DependencyValues
- date

Instance Property

# date

A dependency that returns the current date.

var date: DateGenerator { get set }

Date.swift

## Discussion

By default, a “live” generator is supplied, which returns the current system date when called by invoking `Date.init` under the hood. When used in tests, an “unimplemented” generator that additionally reports test failures is supplied, unless explicitly overridden.

You can access the current date from a feature by introducing a `Dependency` property wrapper to the generator’s `now` property:

@Observable
final class FeatureModel {
@ObservationIgnored
@Dependency(\.date.now) var now
// ...
}

To override the current date in tests, you can override the generator using `withDependencies(_:operation:)`:

// Provision model with overridden dependencies
let model = withDependencies {
$0.date.now = Date(timeIntervalSince1970: 1234567890)
} operation: {
FeatureModel()
}

// Make assertions with model...

## Topics

### Dependency value

`struct DateGenerator`

A dependency that generates a date.

## See Also

### Dependency values

`var assert: any AssertionEffect`

A dependency for handling assertions.

`var assertionFailure: any AssertionFailureEffect`

A dependency for failing an assertion.

`var calendar: Calendar`

The current calendar that features should use when handling dates.

`var context: DependencyContext`

The current dependency context.

The current clock that features should use when a `ContinuousClock` would be appropriate.

`var fireAndForget: FireAndForget`

A dependency for firing off an unstructured task.

`var locale: Locale`

The “main” queue.

The “main” run loop.

`var openURL: OpenURLEffect`

A dependency that opens a URL.

`var precondition: any AssertionEffect`

A dependency for handling preconditions.

The current clock that features should use when a `SuspendingClock` would be appropriate.

`var timeZone: TimeZone`

The current time zone that features should use when handling dates.

`var urlSession: URLSession`

The URL session that features should use to make URL requests.

`var uuid: UUIDGenerator`

A dependency that generates UUIDs.

- date
- Discussion
- Topics
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/date)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/openurleffect/init(handler:)

#app-main)

- Dependencies
- OpenURLEffect
- init(handler:)

Initializer

# init(handler:)

OpenURL.swift

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/openurleffect/callasfunction(_:)-6otyi

-6otyi#app-main)

- Dependencies
- OpenURLEffect
- callAsFunction(\_:)

Instance Method

# callAsFunction(\_:)

@discardableResult

OpenURL.swift

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/openurleffect/callasfunction(_:)-79lpx

-79lpx#app-main)

- Dependencies
- OpenURLEffect
- callAsFunction(\_:)

Instance Method

# callAsFunction(\_:)

func callAsFunction(_ url: URL) async

OpenURL.swift

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/openurleffect/init(handler:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/openurleffect/callasfunction(_:)-6otyi)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/openurleffect/callasfunction(_:)-79lpx)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dategenerator/init(_:)

#app-main)

- Dependencies
- DateGenerator
- init(\_:)

Initializer

# init(\_:)

Initializes a date generator that generates a date from a closure.

Date.swift

## Parameters

`generate`

A closure that returns the current date when called.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dategenerator/now

- Dependencies
- DateGenerator
- now

Instance Property

# now

The current date.

var now: Date { get set }

Date.swift

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dategenerator/callasfunction()

#app-main)

- Dependencies
- DateGenerator
- callAsFunction()

Instance Method

# callAsFunction()

Date.swift

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dategenerator/constant(_:)

#app-main)

- Dependencies
- DateGenerator
- constant(\_:)

Type Method

# constant(\_:)

A generator that returns a constant date.

Date.swift

## Parameters

`now`

A date to return.

## Return Value

A generator that always returns the given date.

- constant(\_:)
- Parameters
- Return Value

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dategenerator/init(_:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dategenerator/now)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dategenerator/callasfunction())

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dategenerator/constant(_:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencycontext/live

- Dependencies
- DependencyContext
- DependencyContext.live

Case

# DependencyContext.live

The default, “live” context for dependencies.

case live

DependencyContext.swift

## Discussion

This context is the default when a `DependencyContext.preview` or `DependencyContext.test` context is not detected.

Dependencies accessed from a live context will use `liveValue` to request a default value.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencycontext/preview

- Dependencies
- DependencyContext
- DependencyContext.preview

Case

# DependencyContext.preview

A “preview” context for dependencies.

case preview

DependencyContext.swift

## Discussion

This context is automatically inferred when running code from an Xcode preview.

Dependencies accessed from a preview context will use `previewValue` to request a default value.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencycontext/test

- Dependencies
- DependencyContext
- DependencyContext.test

Case

# DependencyContext.test

A “test” context for dependencies.

case test

DependencyContext.swift

## Discussion

This context is automatically inferred when running code from an XCTestCase.

Dependencies accessed from a test context will use `testValue` to request a default value.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencycontext/equatable-implementations

- Dependencies
- DependencyContext
- Equatable Implementations

API Collection

# Equatable Implementations

## Topics

### Operators

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencycontext/live):

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencycontext/preview):

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencycontext/test):

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencycontext/live)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencycontext/preview)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencycontext/test)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencycontext/equatable-implementations)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/fireandforget

- Dependencies
- DependencyValues
- fireAndForget

Instance Property

# fireAndForget

A dependency for firing off an unstructured task.

var fireAndForget: FireAndForget { get }

FireAndForget.swift

## Discussion

Useful as a controllable and testable substitute for a `Task { }` that performs some work off into the void. In tests, the operation becomes structured, and the async context that kicks off the work will wait for it to complete before resuming.

For example, suppose you are building a server application that has an endpoint for updating a user’s email address. To accomplish that you will first make a database request to update the user’s email, and then if that succeeds you will send an email to the new address to let the user know their email has been updated.

However, there is no need to tie up the server in order to send the email. That request doesn’t return any data of interest, and we just want to fire it off and then forget about it. One way to do this is to use an unstructured `Task` like so:

try await self.database.updateUser(id: userID, email: newEmailAddress)
Task {
try await self.sendEmail(
email: newEmailAddress,
subject: "Your email has been updated"
)
}

However, this kind of code can be problematic for testing. In a test we would like to verify that an email is sent, but the code inside the `Task` is executed at some later time. We would need to add `Task.sleep` or `Task.yield` to the test to give the task enough time to start and finish, which can be flakey and error prone.

So, instead, you can use the `fireAndForget` dependency, which creates an unstructured task when run in production, but creates a _structured_ task in tests:

try await self.database.updateUser(id: userID, email: newEmailAddress)
await self.fireAndForget {
try await self.sendEmail(
email: newEmailAddress,
subject: "You email has been updated"
)
}

Now this is easy to test. We just have to `await` for the code to finish, and once it does we can verify that the email was sent.

## Topics

### Dependency value

`struct FireAndForget`

A type for creating unstructured tasks in production and structured tasks in tests.

## See Also

### Dependency values

`var assert: any AssertionEffect`

A dependency for handling assertions.

`var assertionFailure: any AssertionFailureEffect`

A dependency for failing an assertion.

`var calendar: Calendar`

The current calendar that features should use when handling dates.

`var context: DependencyContext`

The current dependency context.

The current clock that features should use when a `ContinuousClock` would be appropriate.

`var date: DateGenerator`

A dependency that returns the current date.

`var locale: Locale`

The “main” queue.

The “main” run loop.

`var openURL: OpenURLEffect`

A dependency that opens a URL.

`var precondition: any AssertionEffect`

A dependency for handling preconditions.

The current clock that features should use when a `SuspendingClock` would be appropriate.

`var timeZone: TimeZone`

The current time zone that features should use when handling dates.

`var urlSession: URLSession`

The URL session that features should use to make URL requests.

`var uuid: UUIDGenerator`

A dependency that generates UUIDs.

- fireAndForget
- Discussion
- Topics
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/fireandforget/operation

- Dependencies
- FireAndForget
- operation

Instance Property

# operation

FireAndForget.swift

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/fireandforget/callasfunction(priority:_:)

#app-main)

- Dependencies
- FireAndForget
- callAsFunction(priority:\_:)

Instance Method

# callAsFunction(priority:\_:)

func callAsFunction(
priority: TaskPriority? = nil,

) async

FireAndForget.swift

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/fireandforget)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/fireandforget/operation)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/fireandforget/callasfunction(priority:_:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencykey/value

- Dependencies
- DependencyKey
- Value

Associated Type

# Value

The associated type representing the type of the dependency key’s value.

associatedtype Value = Self

DependencyKey.swift

**Required**

## See Also

### Registering a dependency

`static var liveValue: Self.Value`

The live value for the dependency key.

`static var testValue: Self.Value`

The test value for the dependency key.

**Required** Default implementation provided.

`static var previewValue: Self.Value`

The preview value for the dependency key.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencykey/testvalue

- Dependencies
- DependencyKey
- testValue

Type Property

# testValue

The test value for the dependency key.

override static var testValue: Self.Value { get }

DependencyKey.swift

**Required** Default implementation provided.

## Discussion

This value is automatically used when the associated dependency value is accessed from an XCTest run, as well as when the current `context` is set to `DependencyContext.test`:

withDependencies {
$0.context = .test
} operation: {
// Dependencies accessed here default to their "test" value
}

## Default Implementations

### DependencyKey Implementations

`static var testValue: Self.Value`

A default implementation that provides the `previewValue` to test runs (or `liveValue`, if no preview value is implemented), but will trigger a test failure when accessed.

## See Also

### Registering a dependency

`associatedtype Value = Self`

The associated type representing the type of the dependency key’s value.

**Required**

`static var liveValue: Self.Value`

The live value for the dependency key.

`static var previewValue: Self.Value`

The preview value for the dependency key.

- testValue
- Discussion
- Default Implementations
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencykey/previewvalue

- Dependencies
- DependencyKey
- previewValue

Type Property

# previewValue

The preview value for the dependency key.

override static var previewValue: Self.Value { get }

DependencyKey.swift

**Required** Default implementation provided.

## Discussion

This value is automatically used when the associated dependency value is accessed from an Xcode preview, as well as when the current `context` is set to `DependencyContext.preview`:

withDependencies {
$0.context = .preview
} operation: {
// Dependencies accessed here default to their "preview" value
}

## Default Implementations

### TestDependencyKey Implementations

`static var previewValue: Self.Value`

A default implementation that provides the `liveValue` to Xcode previews.

## See Also

### Registering a dependency

`associatedtype Value = Self`

The associated type representing the type of the dependency key’s value.

**Required**

`static var liveValue: Self.Value`

The live value for the dependency key.

`static var testValue: Self.Value`

The test value for the dependency key.

- previewValue
- Discussion
- Default Implementations
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencykey/value)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencykey/testvalue)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencykey/previewvalue)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/assertionfailureeffect/callasfunction(_:file:line:)

#app-main)

- Dependencies
- AssertionFailureEffect
- callAsFunction(\_:file:line:)

Instance Method

# callAsFunction(\_:file:line:)

func callAsFunction(

file: StaticString,
line: UInt
)

Assert.swift

**Required** Default implementation provided.

## Default Implementations

### AssertionFailureEffect Implementations

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/assertionfailureeffect/callasfunction(_:file:line:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependency/init(_:fileid:filepath:line:column:)-1f0mh

-1f0mh#app-main)

- Dependencies
- Dependency
- init(\_:fileID:filePath:line:column:)

Initializer

# init(\_:fileID:filePath:line:column:)

Creates a dependency property to read the specified key path.

init(

fileID: StaticString = #fileID,
filePath: StaticString = #filePath,
line: UInt = #line,
column: UInt = #column
)

Dependency.swift

## Discussion

Don’t call this initializer directly. Instead, declare a property with the `Dependency` property wrapper, and provide the key path of the dependency value that the property should reflect:

@Observable
final class FeatureModel {
@ObservationIgnored
@Dependency(\.date) var date

// ...
}

- Parameters

- keyPath: A key path to a specific resulting value.

- fileID: The source `#fileID` associated with the dependency.

- filePath: The source `#filePath` associated with the dependency.

- line: The source `#line` associated with the dependency.

- column: The source `#column` associated with the dependency.

## See Also

### Using a dependency

Creates a dependency property to read a dependency object.

- init(\_:fileID:filePath:line:column:)
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependency/init(_:fileid:filepath:line:column:)-1ytea

-1ytea#app-main)

- Dependencies
- Dependency
- init(\_:fileID:filePath:line:column:)

Initializer

# init(\_:fileID:filePath:line:column:)

Creates a dependency property to read a dependency object.

_ key: Key.Type,
fileID: StaticString = #fileID,
filePath: StaticString = #filePath,
line: UInt = #line,
column: UInt = #column
) where Value == Key.Value, Key : TestDependencyKey

Dependency.swift

## Discussion

Don’t call this initializer directly. Instead, declare a property with the `Dependency` property wrapper, and provide the dependency key of the value that the property should reflect.

For example, given a dependency key:

final class Settings: DependencyKey {
static let liveValue = Settings()

// ...
}

One can access the dependency using this property wrapper:

@Observable
final class FeatureModel {
@ObservationIgnored
@Dependency(Settings.self) var settings

- Parameters

- key: A dependency key to a specific resulting value.

- fileID: The source `#fileID` associated with the dependency.

- filePath: The source `#filePath` associated with the dependency.

- line: The source `#line` associated with the dependency.

- column: The source `#column` associated with the dependency.

## See Also

### Using a dependency

Creates a dependency property to read the specified key path.

- init(\_:fileID:filePath:line:column:)
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependency/wrappedvalue

- Dependencies
- Dependency
- wrappedValue

Instance Property

# wrappedValue

The current value of the dependency property.

var wrappedValue: Value { get }

Dependency.swift

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependency/init(_:fileid:filepath:line:column:)-1f0mh)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependency/init(_:fileid:filepath:line:column:)-1ytea)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependency/wrappedvalue)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/init()

#app-main)

- Dependencies
- DependencyValues
- init()

Initializer

# init()

Creates a dependency values instance.

init()

DependencyValues.swift

## Discussion

You don’t typically create an instance of `DependencyValues` directly. Doing so would provide access only to default values. Instead, you rely on the dependency values’ instance that the library manages for you when you use the `Dependency` property wrapper.

## See Also

### Creating and accessing values

Accesses the dependency value associated with a custom key.

- init()
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/subscript(_:fileid:filepath:line:column:function:)

#app-main)

- Dependencies
- DependencyValues
- subscript(\_:fileID:filePath:line:column:function:)

Instance Subscript

# subscript(\_:fileID:filePath:line:column:function:)

Accesses the dependency value associated with a custom key.

key: Key.Type,
fileID fileID: StaticString = #fileID,
filePath filePath: StaticString = #filePath,
line line: UInt = #line,
column column: UInt = #column,
function function: StaticString = #function

DependencyValues.swift

## Overview

This subscript is typically only used when adding a computed property to `DependencyValues` for registering custom dependencies:

private struct MyDependencyKey: DependencyKey {
static let testValue = "Default value"
}

extension DependencyValues {
var myCustomValue: String {
get { self[MyDependencyKey.self] }
set { self[MyDependencyKey.self] = newValue }
}
}

You use custom dependency values the same way you use system-provided values, setting a value with `withDependencies(_:operation:)`, and reading values with the `Dependency` property wrapper.

## See Also

### Creating and accessing values

`init()`

Creates a dependency values instance.

- subscript(\_:fileID:filePath:line:column:function:)
- Overview
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/subscript(_:)

#app-main)

- Dependencies
- DependencyValues
- subscript(\_:)

Instance Subscript

# subscript(\_:)

DependencyValues.swift

## See Also

### Creating and accessing values

`init()`

Creates a dependency values instance.

Accesses the dependency value associated with a custom key.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/assert

- Dependencies
- DependencyValues
- assert

Instance Property

# assert

A dependency for handling assertions.

var assert: any AssertionEffect { get }

Assert.swift

## Discussion

Useful as a controllable and testable substitute for Swift’s `assert` function that calls `reportIssue` in tests instead of terminating the executable.

func operate(_ n: Int) {
@Dependency(\.assert) var assert

// ...
}

Tests can assert against this precondition using `XCTExpectFailure`:

XCTExpectFailure {
operate(n)
} issueMatcher: {
$0.compactDescription = "Number must be greater than zero"
}

## Topics

### Dependency values

`protocol AssertionEffect`

A type for creating an assertion or precondition.

`protocol AssertionFailureEffect`

## See Also

### Dependency values

`var assertionFailure: any AssertionFailureEffect`

A dependency for failing an assertion.

`var calendar: Calendar`

The current calendar that features should use when handling dates.

`var context: DependencyContext`

The current dependency context.

The current clock that features should use when a `ContinuousClock` would be appropriate.

`var date: DateGenerator`

A dependency that returns the current date.

`var fireAndForget: FireAndForget`

A dependency for firing off an unstructured task.

`var locale: Locale`

The “main” queue.

The “main” run loop.

`var openURL: OpenURLEffect`

A dependency that opens a URL.

`var precondition: any AssertionEffect`

A dependency for handling preconditions.

The current clock that features should use when a `SuspendingClock` would be appropriate.

`var timeZone: TimeZone`

The current time zone that features should use when handling dates.

`var urlSession: URLSession`

The URL session that features should use to make URL requests.

`var uuid: UUIDGenerator`

A dependency that generates UUIDs.

- assert
- Discussion
- Topics
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/assertionfailure

- Dependencies
- DependencyValues
- assertionFailure

Instance Property

# assertionFailure

A dependency for failing an assertion.

var assertionFailure: any AssertionFailureEffect { get }

Assert.swift

## Discussion

Equivalent to passing a `false` condition to `assert`.

## See Also

### Dependency values

`var assert: any AssertionEffect`

A dependency for handling assertions.

`var calendar: Calendar`

The current calendar that features should use when handling dates.

`var context: DependencyContext`

The current dependency context.

The current clock that features should use when a `ContinuousClock` would be appropriate.

`var date: DateGenerator`

A dependency that returns the current date.

`var fireAndForget: FireAndForget`

A dependency for firing off an unstructured task.

`var locale: Locale`

The “main” queue.

The “main” run loop.

`var openURL: OpenURLEffect`

A dependency that opens a URL.

`var precondition: any AssertionEffect`

A dependency for handling preconditions.

The current clock that features should use when a `SuspendingClock` would be appropriate.

`var timeZone: TimeZone`

The current time zone that features should use when handling dates.

`var urlSession: URLSession`

The URL session that features should use to make URL requests.

`var uuid: UUIDGenerator`

A dependency that generates UUIDs.

- assertionFailure
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/calendar

- Dependencies
- DependencyValues
- calendar

Instance Property

# calendar

The current calendar that features should use when handling dates.

var calendar: Calendar { get set }

Calendar.swift

## Discussion

By default, the calendar returned from `Calendar.autoupdatingCurrent` is supplied. When used in a testing context, access will call to `reportIssue` when invoked, unless explicitly overridden using `withDependencies(_:operation:)`:

// Provision model with overridden dependencies
let model = withDependencies {
$0.calendar = Calendar(identifier: .gregorian)
} operation: {
FeatureModel()
}

// Make assertions with model...

## See Also

### Dependency values

`var assert: any AssertionEffect`

A dependency for handling assertions.

`var assertionFailure: any AssertionFailureEffect`

A dependency for failing an assertion.

`var context: DependencyContext`

The current dependency context.

The current clock that features should use when a `ContinuousClock` would be appropriate.

`var date: DateGenerator`

A dependency that returns the current date.

`var fireAndForget: FireAndForget`

A dependency for firing off an unstructured task.

`var locale: Locale`

The “main” queue.

The “main” run loop.

`var openURL: OpenURLEffect`

A dependency that opens a URL.

`var precondition: any AssertionEffect`

A dependency for handling preconditions.

The current clock that features should use when a `SuspendingClock` would be appropriate.

`var timeZone: TimeZone`

The current time zone that features should use when handling dates.

`var urlSession: URLSession`

The URL session that features should use to make URL requests.

`var uuid: UUIDGenerator`

A dependency that generates UUIDs.

- calendar
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/context

- Dependencies
- DependencyValues
- context

Instance Property

# context

The current dependency context.

var context: DependencyContext { get set }

Context.swift

## Discussion

The current `DependencyContext` can be used to determine how dependencies are loaded by the current runtime.

It can also be overridden, for example via `withDependencies(_:operation:)`, to control how dependencies will be loaded by the runtime for the duration of the override.

withDependencies {
$0.context = .preview
} operation: {
// Dependencies accessed here default to their "preview" value
}

## Topics

### Dependency context

`enum DependencyContext`

A context for a collection of `DependencyValues`.

## See Also

### Dependency values

`var assert: any AssertionEffect`

A dependency for handling assertions.

`var assertionFailure: any AssertionFailureEffect`

A dependency for failing an assertion.

`var calendar: Calendar`

The current calendar that features should use when handling dates.

The current clock that features should use when a `ContinuousClock` would be appropriate.

`var date: DateGenerator`

A dependency that returns the current date.

`var fireAndForget: FireAndForget`

A dependency for firing off an unstructured task.

`var locale: Locale`

The “main” queue.

The “main” run loop.

`var openURL: OpenURLEffect`

A dependency that opens a URL.

`var precondition: any AssertionEffect`

A dependency for handling preconditions.

The current clock that features should use when a `SuspendingClock` would be appropriate.

`var timeZone: TimeZone`

The current time zone that features should use when handling dates.

`var urlSession: URLSession`

The URL session that features should use to make URL requests.

`var uuid: UUIDGenerator`

A dependency that generates UUIDs.

- context
- Discussion
- Topics
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/locale

- Dependencies
- DependencyValues
- locale

Instance Property

# locale

var locale: Locale { get set }

Locale.swift

## Discussion

// Provision model with overridden dependencies
let model = withDependencies {
$0.locale = Locale(identifier: "en_US")
} operation: {
FeatureModel()
}

// Make assertions with model...

## See Also

### Dependency values

`var assert: any AssertionEffect`

A dependency for handling assertions.

`var assertionFailure: any AssertionFailureEffect`

A dependency for failing an assertion.

`var calendar: Calendar`

The current calendar that features should use when handling dates.

`var context: DependencyContext`

The current dependency context.

The current clock that features should use when a `ContinuousClock` would be appropriate.

`var date: DateGenerator`

A dependency that returns the current date.

`var fireAndForget: FireAndForget`

A dependency for firing off an unstructured task.

The “main” queue.

The “main” run loop.

`var openURL: OpenURLEffect`

A dependency that opens a URL.

`var precondition: any AssertionEffect`

A dependency for handling preconditions.

The current clock that features should use when a `SuspendingClock` would be appropriate.

`var timeZone: TimeZone`

The current time zone that features should use when handling dates.

`var urlSession: URLSession`

The URL session that features should use to make URL requests.

`var uuid: UUIDGenerator`

A dependency that generates UUIDs.

- locale
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/mainqueue

- Dependencies
- DependencyValues
- mainQueue

Instance Property

# mainQueue

The “main” queue.

MainQueue.swift

## Discussion

Introduce controllable timing to your features by using the `Dependency` property wrapper with a key path to this property. The wrapped value is a Combine scheduler with the time type and options of a dispatch queue. By default, `DispatchQueue.main` will be provided, with the exception of XCTest cases, in which an “unimplemented” scheduler will be provided.

For example, you could introduce controllable timing to an observable object model that counts the number of seconds it’s onscreen:

@Observable
final class TimerModel {
var elapsed = 0

@ObservationIgnored
@Dependency(\.mainQueue) var mainQueue

@MainActor
func onAppear() async {
for await _ in mainQueue.timer(interval: .seconds(1)) {
elapsed += 1
}
}
}

And you could test this model by overriding its main queue with a test scheduler:

@Test
func feature() {
let mainQueue = DispatchQueue.test
let model = withDependencies {
$0.mainQueue = mainQueue.eraseToAnyScheduler()
} operation: {
TimerModel()
}

Task { await model.onAppear() }

await mainQueue.advance(by: .seconds(1))
XCTAssertEqual(model.elapsed, 1)

await mainQueue.advance(by: .seconds(4))
XCTAssertEqual(model.elapsed, 5)
}

## See Also

### Dependency values

`var assert: any AssertionEffect`

A dependency for handling assertions.

`var assertionFailure: any AssertionFailureEffect`

A dependency for failing an assertion.

`var calendar: Calendar`

The current calendar that features should use when handling dates.

`var context: DependencyContext`

The current dependency context.

The current clock that features should use when a `ContinuousClock` would be appropriate.

`var date: DateGenerator`

A dependency that returns the current date.

`var fireAndForget: FireAndForget`

A dependency for firing off an unstructured task.

`var locale: Locale`

The “main” run loop.

`var openURL: OpenURLEffect`

A dependency that opens a URL.

`var precondition: any AssertionEffect`

A dependency for handling preconditions.

The current clock that features should use when a `SuspendingClock` would be appropriate.

`var timeZone: TimeZone`

The current time zone that features should use when handling dates.

`var urlSession: URLSession`

The URL session that features should use to make URL requests.

`var uuid: UUIDGenerator`

A dependency that generates UUIDs.

- mainQueue
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/mainrunloop

- Dependencies
- DependencyValues
- mainRunLoop

Instance Property

# mainRunLoop

The “main” run loop.

MainRunLoop.swift

## Discussion

Introduce controllable timing to your features by using the `Dependency` property wrapper with a key path to this property. The wrapped value is a Combine scheduler with the time type and options of a run loop. By default, `RunLoop.main` will be provided, with the exception of XCTest cases, in which an “unimplemented” scheduler will be provided.

For example, you could introduce controllable timing to an observable object model that counts the number of seconds it’s onscreen:

@Observable
struct TimerModel {
var elapsed = 0

@ObservationIgnored
@Dependency(\.mainRunLoop) var mainRunLoop

@MainActor
func onAppear() async {
for await _ in mainRunLoop.timer(interval: .seconds(1)) {
elapsed += 1
}
}
}

And you could test this model by overriding its main run loop with a test scheduler:

@Test
func feature() {
let mainRunLoop = RunLoop.test
let model = withDependencies {
$0.mainRunLoop = mainRunLoop.eraseToAnyScheduler()
} operation: {
TimerModel()
}

Task { await model.onAppear() }

await mainRunLoop.advance(by: .seconds(1))
XCTAssertEqual(model.elapsed, 1)

await mainRunLoop.advance(by: .seconds(4))
XCTAssertEqual(model.elapsed, 5)
}

## See Also

### Dependency values

`var assert: any AssertionEffect`

A dependency for handling assertions.

`var assertionFailure: any AssertionFailureEffect`

A dependency for failing an assertion.

`var calendar: Calendar`

The current calendar that features should use when handling dates.

`var context: DependencyContext`

The current dependency context.

The current clock that features should use when a `ContinuousClock` would be appropriate.

`var date: DateGenerator`

A dependency that returns the current date.

`var fireAndForget: FireAndForget`

A dependency for firing off an unstructured task.

`var locale: Locale`

The “main” queue.

`var openURL: OpenURLEffect`

A dependency that opens a URL.

`var precondition: any AssertionEffect`

A dependency for handling preconditions.

The current clock that features should use when a `SuspendingClock` would be appropriate.

`var timeZone: TimeZone`

The current time zone that features should use when handling dates.

`var urlSession: URLSession`

The URL session that features should use to make URL requests.

`var uuid: UUIDGenerator`

A dependency that generates UUIDs.

- mainRunLoop
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/openurl

- Dependencies
- DependencyValues
- openURL

Instance Property

# openURL

A dependency that opens a URL.

var openURL: OpenURLEffect { get set }

OpenURL.swift

## Topics

### Dependency value

`struct OpenURLEffect`

## See Also

### Dependency values

`var assert: any AssertionEffect`

A dependency for handling assertions.

`var assertionFailure: any AssertionFailureEffect`

A dependency for failing an assertion.

`var calendar: Calendar`

The current calendar that features should use when handling dates.

`var context: DependencyContext`

The current dependency context.

The current clock that features should use when a `ContinuousClock` would be appropriate.

`var date: DateGenerator`

A dependency that returns the current date.

`var fireAndForget: FireAndForget`

A dependency for firing off an unstructured task.

`var locale: Locale`

The “main” queue.

The “main” run loop.

`var precondition: any AssertionEffect`

A dependency for handling preconditions.

The current clock that features should use when a `SuspendingClock` would be appropriate.

`var timeZone: TimeZone`

The current time zone that features should use when handling dates.

`var urlSession: URLSession`

The URL session that features should use to make URL requests.

`var uuid: UUIDGenerator`

A dependency that generates UUIDs.

- openURL
- Topics
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/precondition

- Dependencies
- DependencyValues
- precondition

Instance Property

# precondition

A dependency for handling preconditions.

var precondition: any AssertionEffect { get }

Assert.swift

## Discussion

Useful as a controllable and testable substitute for Swift’s `precondition` function that calls `reportIssue` in tests instead of terminating the executable.

func operate(_ n: Int) {
@Dependency(\.precondition) var precondition

// ...
}

Tests can assert against this precondition using `XCTExpectFailure`:

XCTExpectFailure {
operate(n)
} issueMatcher: {
$0.compactDescription = "Number must be greater than zero"
}

## See Also

### Dependency values

`var assert: any AssertionEffect`

A dependency for handling assertions.

`var assertionFailure: any AssertionFailureEffect`

A dependency for failing an assertion.

`var calendar: Calendar`

The current calendar that features should use when handling dates.

`var context: DependencyContext`

The current dependency context.

The current clock that features should use when a `ContinuousClock` would be appropriate.

`var date: DateGenerator`

A dependency that returns the current date.

`var fireAndForget: FireAndForget`

A dependency for firing off an unstructured task.

`var locale: Locale`

The “main” queue.

The “main” run loop.

`var openURL: OpenURLEffect`

A dependency that opens a URL.

The current clock that features should use when a `SuspendingClock` would be appropriate.

`var timeZone: TimeZone`

The current time zone that features should use when handling dates.

`var urlSession: URLSession`

The URL session that features should use to make URL requests.

`var uuid: UUIDGenerator`

A dependency that generates UUIDs.

- precondition
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/suspendingclock

- Dependencies
- DependencyValues
- suspendingClock

Instance Property

# suspendingClock

The current clock that features should use when a `SuspendingClock` would be appropriate.

Clocks.swift

## Discussion

This clock is type-erased so that it can be swapped out in previews and tests for another clock, like `ImmediateClock` and `TestClock` that come with the Clocks library (which is automatically imported and available when you import this library).

By default, a live `SuspendingClock` is supplied. When used in a testing context, an `UnimplementedClock` is provided, which generates an XCTest failure when used, unless explicitly overridden using `withDependencies(_:operation:)`:

// Provision model with overridden dependencies
let model = withDependencies {
$0.suspendingClock = ImmediateClock()
} operation: {
FeatureModel()
}

// Make assertions with model...

See `continuousClock` to override a feature’s `ContinuousClock`, instead.

## See Also

### Dependency values

`var assert: any AssertionEffect`

A dependency for handling assertions.

`var assertionFailure: any AssertionFailureEffect`

A dependency for failing an assertion.

`var calendar: Calendar`

The current calendar that features should use when handling dates.

`var context: DependencyContext`

The current dependency context.

The current clock that features should use when a `ContinuousClock` would be appropriate.

`var date: DateGenerator`

A dependency that returns the current date.

`var fireAndForget: FireAndForget`

A dependency for firing off an unstructured task.

`var locale: Locale`

The “main” queue.

The “main” run loop.

`var openURL: OpenURLEffect`

A dependency that opens a URL.

`var precondition: any AssertionEffect`

A dependency for handling preconditions.

`var timeZone: TimeZone`

The current time zone that features should use when handling dates.

`var urlSession: URLSession`

The URL session that features should use to make URL requests.

`var uuid: UUIDGenerator`

A dependency that generates UUIDs.

- suspendingClock
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/timezone

- Dependencies
- DependencyValues
- timeZone

Instance Property

# timeZone

The current time zone that features should use when handling dates.

var timeZone: TimeZone { get set }

TimeZone.swift

## Discussion

By default, the time zone returned from `TimeZone.autoupdatingCurrent` is supplied. When used in tests, access will call to `reportIssue` when invoked, unless explicitly overridden:

// Provision model with overridden dependencies
let model = withDependencies {
$0.timeZone = TimeZone(secondsFromGMT: 0)
} operation: {
FeatureModel()
}

// Make assertions with model...

## See Also

### Dependency values

`var assert: any AssertionEffect`

A dependency for handling assertions.

`var assertionFailure: any AssertionFailureEffect`

A dependency for failing an assertion.

`var calendar: Calendar`

The current calendar that features should use when handling dates.

`var context: DependencyContext`

The current dependency context.

The current clock that features should use when a `ContinuousClock` would be appropriate.

`var date: DateGenerator`

A dependency that returns the current date.

`var fireAndForget: FireAndForget`

A dependency for firing off an unstructured task.

`var locale: Locale`

The “main” queue.

The “main” run loop.

`var openURL: OpenURLEffect`

A dependency that opens a URL.

`var precondition: any AssertionEffect`

A dependency for handling preconditions.

The current clock that features should use when a `SuspendingClock` would be appropriate.

`var urlSession: URLSession`

The URL session that features should use to make URL requests.

`var uuid: UUIDGenerator`

A dependency that generates UUIDs.

- timeZone
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/urlsession

- Dependencies
- DependencyValues
- urlSession

Instance Property

# urlSession

The URL session that features should use to make URL requests.

var urlSession: URLSession { get set }

URLSession.swift

## Discussion

By default, the session returned from `URLSession.shared` is supplied. When used in tests, access will call to `reportIssue` when invoked, unless explicitly overridden:

// Provision model with overridden dependencies
let model = withDependencies {
let mockConfiguration = URLSessionConfiguration.ephemeral
mockConfiguration.protocolClasses = [MyMockURLProtocol.self]
$0.urlSession = URLSession(configuration: mockConfiguration)
} operation: {
FeatureModel()
}

// Make assertions with model...

### API client dependencies

While it is possible to use this dependency value from more complex dependencies, like API clients, we generally advise against _designing_ a dependency around a URL session. Mocking a URL session’s responses is a complex process that requires a lot of work that can be avoided.

For example, instead of defining your dependency in a way that holds directly onto a URL session in order to invoke it from a concrete implementation:

struct APIClient {
let urlSession: URLSession

// Use URL session to make request
}

// ...
}

Define your dependency as a lightweight _interface_ that holds onto endpoints that can be individually overridden in a lightweight fashion:

struct APIClient {

Then, you can extend this type with a live implementation that uses a URL session under the hood:

extension APIClient: DependencyKey {
static var liveValue: APIClient {
@Dependency(\.urlSession) var urlSession

return Self(
fetchProfile: {
// Use URL session to make request
}
fetchTimeline: { /* ... */ },
// ...
)
}
}

## See Also

### Dependency values

`var assert: any AssertionEffect`

A dependency for handling assertions.

`var assertionFailure: any AssertionFailureEffect`

A dependency for failing an assertion.

`var calendar: Calendar`

The current calendar that features should use when handling dates.

`var context: DependencyContext`

The current dependency context.

The current clock that features should use when a `ContinuousClock` would be appropriate.

`var date: DateGenerator`

A dependency that returns the current date.

`var fireAndForget: FireAndForget`

A dependency for firing off an unstructured task.

`var locale: Locale`

The “main” queue.

The “main” run loop.

`var openURL: OpenURLEffect`

A dependency that opens a URL.

`var precondition: any AssertionEffect`

A dependency for handling preconditions.

The current clock that features should use when a `SuspendingClock` would be appropriate.

`var timeZone: TimeZone`

The current time zone that features should use when handling dates.

`var uuid: UUIDGenerator`

A dependency that generates UUIDs.

- urlSession
- Discussion
- API client dependencies
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/uuid

- Dependencies
- DependencyValues
- uuid

Instance Property

# uuid

A dependency that generates UUIDs.

var uuid: UUIDGenerator { get set }

UUID.swift

## Discussion

Introduce controllable UUID generation to your features by using the `Dependency` property wrapper with a key path to this property. The wrapped value is an instance of `UUIDGenerator`, which can be called with a closure to create UUIDs. (It can be called directly because it defines `callAsFunction()`, which is called when you invoke the instance as you would invoke a function.)

For example, you could introduce controllable UUID generation to an observable object model that creates to-dos with unique identifiers:

@Observable
final class TodosModel {
var todos: [Todo] = []

@ObservationIgnored
@Dependency(\.uuid) var uuid

func addButtonTapped() {
todos.append(Todo(id: uuid()))
}
}

By default, a “live” generator is supplied, which returns a random UUID when called by invoking `UUID.init` under the hood. When used in tests, an “unimplemented” generator that additionally reports test failures if invoked, unless explicitly overridden.

To test a feature that depends on UUID generation, you can override its generator using `withDependencies(_:operation:)` to override the underlying `UUIDGenerator`:

- `incrementing` for reproducible UUIDs that count up from `00000000-0000-0000-0000-000000000000`.

- `constant(_:)` for a generator that always returns the given UUID.

For example, you could test the to-do-creating model by supplying an `incrementing` generator as a dependency:

@Test
func feature() {
let model = withDependencies {
$0.uuid = .incrementing
} operation: {
TodosModel()
}

model.addButtonTapped()
#expect(
model.todos == [\
Todo(id: UUID(0))\
]
)
}

## Topics

### Dependency value

`struct UUIDGenerator`

A dependency that generates a UUID.

### Helpers

`extension UUID`

## See Also

### Dependency values

`var assert: any AssertionEffect`

A dependency for handling assertions.

`var assertionFailure: any AssertionFailureEffect`

A dependency for failing an assertion.

`var calendar: Calendar`

The current calendar that features should use when handling dates.

`var context: DependencyContext`

The current dependency context.

The current clock that features should use when a `ContinuousClock` would be appropriate.

`var date: DateGenerator`

A dependency that returns the current date.

`var fireAndForget: FireAndForget`

A dependency for firing off an unstructured task.

`var locale: Locale`

The “main” queue.

The “main” run loop.

`var openURL: OpenURLEffect`

A dependency that opens a URL.

`var precondition: any AssertionEffect`

A dependency for handling preconditions.

The current clock that features should use when a `SuspendingClock` would be appropriate.

`var timeZone: TimeZone`

The current time zone that features should use when handling dates.

`var urlSession: URLSession`

The URL session that features should use to make URL requests.

- uuid
- Discussion
- Topics
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/withrandomnumbergenerator

- Dependencies
- DependencyValues
- withRandomNumberGenerator

Instance Property

# withRandomNumberGenerator

A dependency that yields a random number generator to a closure.

var withRandomNumberGenerator: WithRandomNumberGenerator { get set }

WithRandomNumberGenerator.swift

## Discussion

Introduce controllable randomness to your features by using the `Dependency` property wrapper with a key path to this property. The wrapped value is an instance of `WithRandomNumberGenerator`, which can be called with a closure to yield a random number generator. (It can be called directly because it defines `callAsFunction(_:)`, which is called when you invoke the instance as you would invoke a function.)

For example, you could introduce controllable randomness to an observable object model that handles rolling a couple dice:

@Observable
final class GameModel {
var dice = (1, 1)

@ObservationIgnored
@Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator

func rollDice() {
dice = withRandomNumberGenerator { generator in
(
.random(in: 1...6, using: &generator),
.random(in: 1...6, using: &generator)
)
}
}
}

By default, a `SystemRandomNumberGenerator` will be provided to the closure, with the exception of when run in tests, in which an unimplemented dependency will be provided that calls `reportIssue`.

To test a feature that depends on randomness, you can override its random number generator. Inject a dependency by calling `init(_:)` with a random number generator that offers predictable randomness. For example, you could test the dice-rolling of a game’s model by supplying a seeded random number generator as a dependency:

@Test
func roll() {
let model = withDependencies {
$0.withRandomNumberGenerator = WithRandomNumberGenerator(LCRNG(seed: 0))
} operation: {
GameModel()
}

model.rollDice()
XCTAssert(model.dice == (1, 3))
}

## Topics

### Dependency value

`struct WithRandomNumberGenerator`

## See Also

### Dependency values

`var assert: any AssertionEffect`

A dependency for handling assertions.

`var assertionFailure: any AssertionFailureEffect`

A dependency for failing an assertion.

`var calendar: Calendar`

The current calendar that features should use when handling dates.

`var context: DependencyContext`

The current dependency context.

The current clock that features should use when a `ContinuousClock` would be appropriate.

`var date: DateGenerator`

A dependency that returns the current date.

`var fireAndForget: FireAndForget`

A dependency for firing off an unstructured task.

`var locale: Locale`

The “main” queue.

The “main” run loop.

`var openURL: OpenURLEffect`

A dependency that opens a URL.

`var precondition: any AssertionEffect`

A dependency for handling preconditions.

The current clock that features should use when a `SuspendingClock` would be appropriate.

`var timeZone: TimeZone`

The current time zone that features should use when handling dates.

`var urlSession: URLSession`

The URL session that features should use to make URL requests.

- withRandomNumberGenerator
- Discussion
- Topics
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/live

- Dependencies
- DependencyValues
- live

Type Property

# live

A collection of “live” dependencies.

static var live: DependencyValues { get }

DependencyValues.swift

## Discussion

A useful starting point for working with live dependencies.

For example, if you want to write a test that exercises your application’s live dependencies (rather than its test dependencies, which is the default), you can override the test’s dependencies with a live value:

func testLiveDependencies() {
withDependencies { $0 = .live } operation: {
// Make assertions using live dependencies...
}
}

## See Also

### Default contexts

`static var preview: DependencyValues`

A collection of “preview” dependencies.

`static var test: DependencyValues`

A collection of “test” dependencies.

- live
- Discussion
- See Also

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/preview

- Dependencies
- DependencyValues
- preview

Type Property

# preview

A collection of “preview” dependencies.

static var preview: DependencyValues { get }

DependencyValues.swift

## See Also

### Default contexts

`static var live: DependencyValues`

A collection of “live” dependencies.

`static var test: DependencyValues`

A collection of “test” dependencies.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/test

- Dependencies
- DependencyValues
- test

Type Property

# test

A collection of “test” dependencies.

static var test: DependencyValues { get }

DependencyValues.swift

## See Also

### Default contexts

`static var live: DependencyValues`

A collection of “live” dependencies.

`static var preview: DependencyValues`

A collection of “preview” dependencies.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvaluesdeprecations

- Dependencies
- DependencyValues
- Deprecations

API Collection

# Deprecations

Review unsupported dependency values APIs and their replacements.

## Overview

Avoid using deprecated APIs in your app. Select a method to see the replacement that you should use instead.

## Topics

### Overriding values

- Deprecations
- Overview
- Topics

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/continuation

- Dependencies
- DependencyValues
- DependencyValues.Continuation

Structure

# DependencyValues.Continuation

A capture of dependencies to use in an escaping context.

struct Continuation

WithDependencies.swift

## Overview

See the docs of `withEscapedDependencies(_:)` for more information.

## Topics

### Instance Methods

Access the propagated dependencies in an escaping context.

## Relationships

### Conforms To

- `Swift.Sendable`

- DependencyValues.Continuation
- Overview
- Topics
- Relationships

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/$_current

- Dependencies
- DependencyValues
- $\_current

Type Property

# $\_current

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues),

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues):

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/init())

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/subscript(_:fileid:filepath:line:column:function:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/subscript(_:))

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/withescapeddependencies(_:)-5xvi3)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/assert)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/assertionfailure)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/calendar)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/context)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/locale)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/mainqueue)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/mainrunloop)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/openurl)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/precondition)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/suspendingclock)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/timezone)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/urlsession)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/uuid)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/withrandomnumbergenerator)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/live)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/preview)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/test)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvaluesdeprecations)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/continuation)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

# https://swiftpackageindex.com/pointfreeco/swift-dependencies/main/documentation/dependencies/dependencyvalues/$_current)

Has it really been five years since Swift Package Index launched? Read our anniversary blog post!

#### 404 - Not Found

If you were expecting to find a page here, please raise an issue.

From here, you'll want to go to the home page or search for a package.

|
|

---

