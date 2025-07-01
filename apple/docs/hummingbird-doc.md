Directory Structure:

└── ./
    ├── Articles
    │   ├── EncodingAndDecoding.md
    │   ├── ErrorHandling.md
    │   ├── GettingStarted.md
    │   ├── LoggingMetricsAndTracing.md
    │   ├── MiddlewareGuide.md
    │   ├── MigratingToV2.md
    │   ├── PersistentData.md
    │   ├── RequestContexts.md
    │   ├── RequestDecoding.md
    │   ├── ResponseEncoding.md
    │   ├── RouterGuide.md
    │   ├── ServerProtocol.md
    │   ├── ServiceLifecycle.md
    │   └── Testing.md
    ├── Hummingbird
    │   ├── Application.md
    │   ├── ApplicationProtocol.md
    │   ├── Hummingbird.md
    │   └── RouterMiddleware.md
    ├── HummingbirdAuth
    │   ├── AuthenticatorMiddlewareGuide.md
    │   ├── HummingbirdAuth.md
    │   └── Sessions.md
    ├── HummingbirdBasicAuth
    │   └── HummingbirdBasicAuth.md
    ├── HummingbirdBcrypt
    │   └── HummingbirdBcrypt.md
    ├── HummingbirdCompression
    │   └── HummingbirdCompression.md
    ├── HummingbirdCore
    │   └── HummingbirdCore.md
    ├── HummingbirdFluent
    │   └── HummingbirdFluent.md
    ├── HummingbirdHTTP2
    │   └── HummingbirdHTTP2.md
    ├── HummingbirdLambda
    │   └── HummingbirdLambda.md
    ├── HummingbirdOTP
    │   ├── HummingbirdOTP.md
    │   └── OneTimePasswords.md
    ├── HummingbirdPostgres
    │   └── HummingbirdPostgres.md
    ├── HummingbirdRedis
    │   ├── HummingbirdRedis.md
    │   └── RedisConnectionPoolService.md
    ├── HummingbirdRouter
    │   ├── HummingbirdRouter.md
    │   └── RouterBuilderGuide.md
    ├── HummingbirdTesting
    │   └── HummingbirdTesting.md
    ├── HummingbirdTLS
    │   └── HummingbirdTLS.md
    ├── HummingbirdWebSocket
    │   ├── HummingbirdWebSocket.md
    │   └── WebSocketServerUpgrade.md
    ├── HummingbirdWSTesting
    │   └── HummingbirdWSTesting.md
    ├── Jobs
    │   ├── JobDefinition.md
    │   ├── JobQueueDriver.md
    │   ├── Jobs.md
    │   └── JobsGuide.md
    ├── JobsPostgres
    │   └── JobsPostgres.md
    ├── JobsRedis
    │   └── JobsRedis.md
    ├── Mustache
    │   ├── Mustache.md
    │   ├── MustacheFeatures.md
    │   └── MustacheSyntax.md
    ├── PostgresMigrations
    │   ├── MigrationsGuide.md
    │   └── PostgresMigrations.md
    ├── WSClient
    │   ├── WebSocketClientGuide.md
    │   └── WSClient.md
    ├── WSCompression
    │   └── WSCompression.md
    └── index.md



---
File: /Articles/EncodingAndDecoding.md
---

# Encoding and Decoding

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}


Hummingbird uses `Codable` to decode requests and encode responses. Codable is a flexible, type-safe way to encode and decode data from various formats.

Hummingbird provides a JSON-based solution out-of-the-box, but also provides support for URL-encoded form data. In addition, other Codable libraries can be used with Hummingbird by implementing the ``RequestDecoder`` and ``ResponseEncoder`` protocols.

The request context ``RequestContext`` that is provided alongside your ``/HummingbirdCore/Request`` has two member variables ``RequestContext/requestDecoder`` and ``RequestContext/responseEncoder``. These define how requests/responses are decoded/encoded. 

The `decoder` must conform to ``RequestDecoder`` which requires a ``RequestDecoder/decode(_:from:context:)`` function that decodes a `Request`.

```swift
public protocol RequestDecoder {
    func decode<T: Decodable>(_ type: T.Type, from request: Request, context: some RequestContext) throws -> T
}
```

The `encoder` must conform to ``ResponseEncoder`` which requires a ``ResponseEncoder/encode(_:from:context:)`` function that creates a `Response` from a `Codable` value and the original request that generated it.

```swift
public protocol ResponseEncoder {
    func encode<T: Encodable>(_ value: T, from request: Request, context: some RequestContext) throws -> Response
}
```

Both of these look very similar to the `Encodable` and `Decodable` protocol that come with the `Codable` system except you have additional information from the `Request` and `RequestContext` types on how you might want to decode/encode your data.

## Setting up your encoder/decoder

The default implementations of `requestDecoder` and `responseEncoder` are `Hummingbird/JSONDecoder` and `Hummingbird/JSONEncoder` respectively. They have been extended to conform to the relevant protocols so they can be used to decode requests and encode responses. 

If you don't want to use JSON you need to setup you own `requestDecoder` and `responseEncoder` in a custom request context. For instance `Hummingbird` also includes a decoder and encoder for URL encoded form data. Below you can see a custom request context setup to use ``URLEncodedFormDecoder`` for request decoding and ``URLEncodedFormEncoder`` for response encoding. The router is then initialized with this context. Read <doc:RequestContexts> to find out more about request contexts. 

```swift
struct URLEncodedRequestContext: RequestContext {
    var requestDecoder: URLEncodedFormDecoder { .init() }
    var responseEncoder: URLEncodedFormEncoder { .init() }
    ...
}
let router = Router(context: URLEncodedRequestContext.self)
```

## Decoding Requests

Once you have a decoder you can implement decoding in your routes using the ``/HummingbirdCore/Request/decode(as:context:)`` method in the following manner

```swift
struct User: Decodable {
    let email: String
    let firstName: String
    let surname: String
}
router.post("user") { request, context -> HTTPResponse.Status in
    // decode user from request
    let user = try await request.decode(as: User.self, context: context)
    // create user and if ok return `.ok` status
    try await createUser(user)
    return .ok
}
```
Like the standard `Decoder.decode` functions `Request.decode` can throw an error if decoding fails. The decode function is also async as the request body is an asynchronous sequence of `ByteBuffers`. We need to collate the request body into one buffer before we can decode it.

## Encoding Responses

To have an object encoded in the response we have to conform it to `ResponseEncodable`. This then allows you to create a route handler that returns this object and it will automatically get encoded. If we extend the `User` object from the above example we can do this

```swift
extension User: ResponseEncodable {}

router.get("user") { request, _ -> User in
    let user = User(email: "js@email.com", name: "John Smith")
    return user
}
```

## Decoding/Encoding based on Request headers

Because the full request is supplied to the `RequestDecoder`. You can make decoding decisions based on headers in the request. In the example below we are decoding using either the `JSONDecoder` or `URLEncodedFormDecoder` based on the "content-type" header.

```swift
struct MyRequestDecoder: RequestDecoder {
    func decode<T>(_ type: T.Type, from request: Request, context: some RequestContext) async throws -> T where T : Decodable {
        guard let header = request.headers[.contentType].first else { throw HTTPError(.badRequest) }
        guard let mediaType = MediaType(from: header) else { throw HTTPError(.badRequest) }
        switch mediaType {
        case .applicationJson:
            return try await JSONDecoder().decode(type, from: request, context: context)
        case .applicationUrlEncoded:
            return try await URLEncodedFormDecoder().decode(type, from: request, context: context)
        default:
            throw HTTPError(.badRequest)
        }
    }
}
```

In a similar manner you could also create a `ResponseEncoder` based on the "accepts" header in the request.

## See Also 

- ``RequestDecoder``
- ``ResponseEncoder``
- ``RequestContext``


---
File: /Articles/ErrorHandling.md
---

# Error Handling

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

How to build errors for the server to return.

## Overview

If a middleware or route handler throws an error the server needs to know how to handle this. If the server does not know how to handle the error then the only thing it can return to the client is a status code of 500 (Internal Server Error). This is not overly informative.

## HTTPError

Hummingbird uses the Error object ``Hummingbird/HTTPError`` throughout its codebase. The server recognises this and can generate a more informative response for the client from it. The error includes the status code that should be returned and a response message if needed. For example 

```swift
router.get("user") { request, context -> User in
    guard let userId = request.uri.queryParameters.get("id", as: Int.self) else {
        throw HTTPError(.badRequest, message: "Invalid user id")
    }
    ...
}
```
The `HTTPError` generated here will be recognised by the server and it will generate a status code 400 (Bad Request) with the body "Invalid user id".

## HTTPResponseError

The server knows how to respond to a `HTTPError` because it conforms to protocol ``Hummingbird/HTTPResponseError``. You can create your own `Error` object and conform it to `HTTPResponseError` and the server will know how to generate a sensible error from it. The example below is a error class that outputs an error code in the response headers.

```swift
struct MyError: HTTPResponseError {
    init(_ status: HTTPResponseStatus, errorCode: String) {
        self.status = status
        self.errorCode = errorCode
    }

    let errorCode: String

    // required by HTTPResponseError protocol
    let status: HTTPResponseStatus

    // required by HTTPResponseError protocol
    func response(from request: Request, context: some RequestContext) throws -> Response {
        .init(
            status: self.status,
            headers: ["error-code": self.errorCode]
        )
    }
}
```

## See Also

- ``HTTPError``
- ``HTTPResponseError``


---
File: /Articles/GettingStarted.md
---

# Getting Started with Hummingbird

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Create a new Hummingbird project from the project template.

## Overview

The Hummingbird project provides multiple entry points for getting started.

1. Create your own project that uses Hummingbird from a [starting template](https://github.com/hummingbird-project/template) to jump right in.
2. For a walk-through, explore and follow along the [Build a Todos Application](https://docs.hummingbird.codes/2.0/tutorials/todos) tutorial.
3. Take some time to explore the [Hummingbird Examples](https://github.com/hummingbird-project/hummingbird-examples/), individual projects that use common patterns.

### Using the project template

Clone the starting template to your local machine:

    git clone https://github.com/hummingbird-project/template

Run the configure script provided to create a new folder and project inside:

    ./template/configure.sh MyNewProject

Change into the new project directory:

    cd MyNewProject

Then run your app:

    swift run

### Next Steps

Follow our TODO's tutorial to get started with the framework: <doc:Todos> or explore the [Hummingbird Examples](https://github.com/hummingbird-project/hummingbird-examples/) for demonstrations of how to use the framework.



---
File: /Articles/LoggingMetricsAndTracing.md
---

# Logging, Metrics and Tracing

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Considered the three pillars of observability, logging, metrics and tracing provide different ways of viewing how your application is working. 

## Overview

Apple has developed packages for each of the observability systems ([swift-log](https://github.com/apple/swift-log), [swift-metrics](https://github.com/apple/swift-metrics), [swift-distributed-tracing](https://github.com/apple/swift-distributed-tracing)). They provide a consistent API while not defining how the backend is implemented. With these it is possible to add observability to your own libraries without commiting to a certain implementation of each system.

Hummingbird has middleware for each of these systems. As these are provided as middleware you can add these to your application as and when you need them.

## Logging

Logs provides a record of discrete events over time. Each event has a timestamp, description and an array of metadata. Hummingbird automatically does some logging of events. You can control the fidelity of your logging by providing your own `Logger` when creating your `Application` eg

```swift
var logger = Logger(label: "MyLogger")
logger.logLevel = .debug
let application = Application(
    router: router,
    logger: logger
)
```

If you want a record of every request to the server you can add the ``LogRequestsMiddleware`` middleware. You can control at what `logLevel` the request logging will occur and whether it includes information about each requests headers. eg

```swift
let router = Router()
router.middlewares.add(LogRequestsMiddleware(.debug, includeHeaders: false))
```

If you would like to add your own logging, or implement your own logging backend you can find out more [here](https://swiftpackageindex.com/apple/swift-log/main/documentation/logging). A complete list of logging implementations can be found [here](https://github.com/apple/swift-log#selecting-a-logging-backend-implementation-applications-only).

## Metrics

Metrics provides an overview of how your application is working over time. It allows you to create visualisations of the state of your application. 

The middleware ``MetricsMiddleware`` will record how many requests are being made to each route, how long they took and how many failed. To add recording of these metrics to your Hummingbird application you need to add this middleware and bootstrap your chosen metrics backend. Below is an example setting up recording metrics with Prometheus, using the package [SwiftPrometheus](https://github.com/swift-server-community/SwiftPrometheus).

```swift
import Metrics
import Prometheus

// Bootstrap Prometheus
let prometheus = PrometheusClient()
MetricsSystem.bootstrap(PrometheusMetricsFactory(client: prometheus))

// Add metrics middleware to router
router.middlewares.add(MetricsMiddleware())
```

If you would like to record your own metrics, or implement your own metrics backed you can find out more [here](https://swiftpackageindex.com/apple/swift-metrics/main/documentation/coremetrics). A list of metrics backend implementations can be found [here](https://github.com/apple/swift-metrics#selecting-a-metrics-backend-implementation-applications-only).

## Tracing

Tracing is used to understand how data flows through an application's various services. 

The middleware ``TracingMiddleware`` will record spans for each request made to your application and attach the relevant metadata about request and responses. To add tracing to your Hummingbird application you need to add this middleware and bootstrap your chosen tracing backend. Below is an example setting up tracing using the Open Telemetry package [swift-otel](https://github.com/slashmo/swift-otel).

```swift
import OpenTelemetry
import Tracing

// Bootstrap Open Telemetry
let otel = OTel(serviceName: "example", eventLoopGroup: .singleton)
try otel.start().wait()
InstrumentationSystem.bootstrap(otel.tracer())

// Add tracing middleware
router.middlewares.add(TracingMiddleware(recordingHeaders: ["content-type", "content-length"]))
```

If you would like to find out more about tracing, or implement your own tracing backend you can find out more [here](https://swiftpackageindex.com/apple/swift-distributed-tracing/main/documentation/tracing).

## See Also

- ``LogRequestsMiddleware``
- ``MetricsMiddleware``
- ``TracingMiddleware``


---
File: /Articles/MiddlewareGuide.md
---

# Middleware

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Processing requests and responses outside of request handlers. 

## Overview

Middleware can be used to edit requests before they are forwared to the router, edit the responses returned by the route handlers or even shortcut the router and return their own responses. Middleware is added to the application as follows.

```swift
let router = Router()
router.add(middleware: MyMiddlware())
```

In the example above the `MyMiddleware` is applied to every request that comes into the server.

### Groups

Middleware can also be applied to a specific set of routes using groups. Below is a example of applying an authentication middleware `BasicAuthenticatorMiddleware` to routes that need protected.

```swift
let router = Router()
router.put("/user", createUser)
router.group()
    .add(middleware: BasicAuthenticatorMiddleware())
    .post("/user", loginUser)
```
The first route that calls `createUser` does not have the `BasicAuthenticatorMiddleware` applied to it. But the route calling `loginUser` which is inside the group does have the middleware applied.

### Middleware result builder

You can add multiple middleware to the router using the middleware stack result builder ``MiddlewareFixedTypeBuilder``.

```swift
let router = Router()
router.add {
    LogRequestsMiddleware()
    MetricsMiddleware()
    TracingMiddleware()
}
```

This gives a slight performance boost over adding them individually.

### Writing Middleware

All middleware has to conform to the protocol ``Hummingbird/RouterMiddleware``. This requires one function `handle(_:context:next)` to be implemented. At some point in this function unless you want to shortcut the router and return your own response you should call `next(request, context)` to continue down the middleware stack and return the result, or a result processed by your middleware. 

The following is a simple logging middleware that outputs every URI being sent to the server

```swift
public struct LogRequestsMiddleware<Context: RequestContext>: RouterMiddleware {
    public func handle(_ request: Request, context: Context, next: (Request, Context) async throws -> Response) async throws -> Response {
        // log request URI
        context.logger.log(level: .debug, String(describing:request.uri.path))
        // pass request onto next middleware or the router and return response
        return try await next(request, context)
    }
}
```

## See Also

- ``RouterMiddleware``



---
File: /Articles/MigratingToV2.md
---

# Migrating to Hummingbird v2

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Migration guide for converting Hummingbird v1 applications to Hummingbird v2

## Overview

In the short lifetime of the Hummingbird server framework there have been many major changes to the Swift language. Hummingbird v2 has been designed to take advantage of all the latest changes to Swift. In addition Hummingbird v1 was our first attempt at writing a server framework and we didn't necessarily get everything right, so v2 includes some changes where we feel we made the wrong design first time around. Below we cover most of the major changes in the library and how you should deal with them.

## Symbol names

The first thing you will notice when moving to v2 are the symbol names. In Version 2 of Hummingbird we have removed the "HB" prefix from all the symbols.

## SwiftNIO and Swift Concurrency

In the time that the Hummingbird server framework has been around there has been a seismic shift in the Swift language. When it was first in development the initial pitches for Swift Concurrency were only just being posted. It wasn't for another 9 months before we actually saw a release of Swift with any concurrency features. As features have become available we have tried to support them but the internals of Hummingbird were still SwiftNIO EventLoop based and held us back from providing full support for Concurrency.

Hummingbird v2 is now exclusively Swift concurrency based. All EventLoop based APIs have been removed.

### Using EventLoop-based Libraries

If you have libraries you are calling into that still only provide EventLoop based APIs you can convert them to Swift concurrency using the `get` method from `EventLoopFuture`.

```swift
let value = try await eventLoopBasedFunction().get()
```

If you need to provide an `EventLoopGroup`, use either the one you provided to `Application.init` or `MultiThreadedEventLoopGroup.singleton`. And when you need an `EventLoop` use `EventLoopGroup.any`.

```swift
let service = MyService(eventLoopGroup: MultiThreadedEventLoopGroup.singleton)
let result = try await service.doStuff(eventLoop: MultiThreadedEventLoopGroup.singleton.any()).get()
```

Otherwise any `EventLoopFuture` based logic you had will have to be converted to Swift concurrency. The advantage of this is, it should be a lot easier to read after.

## Extending Application and Request

In Hummingbird v1 you could extend the `Application` and `Request` types to include your own custom data. This is no longer possible in version 2.

### Application

In the case of the application we decided we didn't want to make `Application` this huge mega global that held everything. We have moved to a model of explicit dependency injection.

For each route controller you supply the dependencies you need at initialization, instead of extracting them from the application when you use them. This makes it clearer what dependencies you are using in each controller.

```swift
struct UserController {
    // The user authentication routes use fluent and session storage
    init(fluent: Fluent, sessions: SessionStorage) {
        ...
    }
}
```

### Request and RequestContext

We have replaced extending of `Request` with a custom request context type that is passed along with the request. This means `Request` is just the HTTP request data (as it should be). The additional request context parameter will hold any custom data required. In situations in the past where you would use data attached to `Request`, you should now use the context.

```swift
router.get { request, context in
    // logger is attached to the context
    context.logger.info("The logger attached to the context includes the request's id.")
    // request decoder is attached to the context instead of the application
    let myObject = try await request.decode(as: MyObject.self, context: context)
}
```

The request context is a generic value. As long as it conforms to ``RequestContext`` it can hold anything you like.

```swift
/// Example request context with an additional data attached
struct MyRequestContext: RequestContext {
    // required by RequestContext
    var coreContext: CoreRequestContextStorage
    var additionalData: String?

    // required by RequestContext
    init(source: Source) {
        self.coreContext = .init(source: source)
        self.additionalData = nil
    }
}
```

When you create your router you pass in the request context type you'd like to use. If you don't pass one in it will default to using ``BasicRequestContext`` which provides enough data for the router to run but not much else.

```swift
let router = Router(context: MyRequestContext.self)
```

> Important: This feature is at the heart of Hummingbird 2, so we recommend reading our guide to <doc:RequestContexts>. 

## Router

Instead of creating an application and adding routes to it, in v2 you create a router and add routes to it and then create an application using that router. 

@Row {
    @Column {
        ### Hummingbird 1
        ```swift
        let app = Application()
        app.router.get { request in
            "hello"
        }
        ```
    }
    @Column {
        ### Hummingbird 2
        ```swift
        let router = Router()
        router.get { request, context in
            "hello"
        }
        let app = Application(router: router)
        ```
    }
}

When we are passing in the router we are actually passing in a type that can build a ``HTTPResponder`` a protocol for a type with one function that takes an HTTP request and context and returns an HTTP response. The `Application` creates the HTTP responder from the current state of the router when it is initialized. Any routes added to the router after having created your `Application` will be ignored.

### Router Builder

An alternative router is also provided in the ``HummingbirdRouter`` module. It uses a result builder to generate the router. 

```swift
let router = RouterBuilder(context: MyContext.self) {
    // add logging middleware
    LogRequestsMiddleware(.info)
    // add route to return ok
    Get("health") { _,_ -> HTTPResponse.Status in
        .ok
    }
    // for all routes starting with '/user'
    RouteGroup("user") {
        // add router supplied by UserController
        UserController(fluent: fluent).routes()
    }
}
let app = Application(router: router)
```

## Miscellaneous

Below is a list of other smaller changes that might catch you out

### Request body streaming

In Hummingbird v1 it was assumed request bodies would be collated into one ByteBuffer and if you didn't want that to happen you had to flag the route to not collate your request body. In v2 this assumption has been reversed. It is assumed that request bodies are a stream of buffers and if you want to collate them into one buffer you need to call a method to do that.

To treat the request body as a stream of buffers
```swift
router.put { request, context in
    for try await buffer in request.body {
        process(buffer)
    }
}
```

To treat the request body as a single buffer.
```swift
router.put { request, context in
    let body = try await request.body.collate(maxSize: 1_000_000)
    process(body)
}
```

### OpenAPI style URI capture parameters

In Hummingbird v1.3.0 partial path component matching and capture was introduced. For this a new syntax was introduced for parameter capture: `${parameter}` alongside the standard `:parameter` syntax. It has been decided to change the new form of the syntax to `{parameter}` to coincide with the syntax used by OpenAPI. 

### HummingbirdFoundation

HummingbirdFoundation has been merged into Hummingbird. It was felt the gains from separating out the code relying on Foundation were not enough for the awkwardness it created. Eventually we hope to limit our exposure to only the elements of Foundation that will be in FoundationEssentials module from the newly developed [Swift Foundation](https://github.com/apple/swift-foundation).

### Generic Application

``Hummingbird/Application`` is a generic type with two different type parameters. Passing around the concrete type is complex as you need to work out the type parameters. They might not be immediately obvious. Instead it is easier to pass around the opaque type `some ApplicationProtocol`.

```swift
func buildApplication() -> some ApplicationProtocol {
    ...
    let app = Application(router: router)
    return app
}
```



---
File: /Articles/PersistentData.md
---

# Persistent data

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

How to persist data between requests to your server.

## Overview

If you are looking to store data between requests then the Hummingbird `persist` framework provides a key/value store. Each key is a string and the value can be any object that conforms to `Codable`. 

## Setup

At setup you need to choose your persist driver. Below we are using the in memory storage driver. 

```swift
let persist = MemoryPersistDriver()
```

The persist drivers conform to `Service` from Swift Service Lifecycle and should either to added to the ``Application`` serivce group using ``Application/addServices(_:)`` or added to an external managed `ServiceGroup`.

```swift
var app = Application(router: myRouter)
app.addServices(persist)
```

## Usage

To create a new entry you can call `create`
```swift
try await persist.create(key: "mykey", value: MyValue)
```
If there is an entry for the key already then a `PersistError.duplicate` error will be thrown.

If you are not concerned about overwriting a previous key/value pair you can use 
```swift
try await persist.set(key: "mykey", value: MyValue)
```

Both `create` and `set` have an `expires` parameter. With this parameter you can make a key/value pair expire after a certain time period. eg
```swift
try await persist.set(key: "sessionID", value: MyValue, expires: .hours(1))
```

To access values in the `persist` key/value store you use 
```swift
let value = try await persist.get(key: "mykey", as: MyValueType.self)
```

This returns the value associated with the key or `nil` if that value doesn't exist.
If the value is not of the expected type, this will throw ``PersistError/invalidConversion``.

And finally if you want to delete a key you can use
```swift
try await persist.remove(key: "mykey")
```

## Drivers

The `persist` framework defines an API for storing key/value pairs. You also need a driver for the framework. `Hummingbird` comes with a memory based driver ``Hummingbird/MemoryPersistDriver`` which will store these values in the memory of your server. 
```swift
let persist = MemoryPersistDriver()
```
If you use the memory based driver the key/value pairs you store will be lost if your server goes down, also you will not be able to share values between server processes. 

### Redis

You can use Redis to store the `persists` key/value pairs with ``HummingbirdRedis/RedisPersistDriver`` from the `HummingbirdRedis` library. You would setup `persist` to use Redis as follows.
```swift
let redis = RedisConnectionPoolService(
    .init(hostname: redisHostname, port: 6379), 
    logger: Logger(label: "Redis")
)
let persist = RedisPersistDriver(redisConnectionPoolService: redis)
```

### Fluent

``HummingbirdFluent`` also contains a `persist` driver for the storing the key/value pairs in a database. To setup the Fluent driver you need to have setup Fluent first. The first time you run with the fluent driver you should ensure you call `fluent.migrate()` after creating the ``HummingbirdFluent/FluentPersistDriver`` call has been made.
```swift
let fluent = Fluent(logger: Logger(label: "Fluent"))
fluent.databases.use(...)
let persist = await FluentPersistDriver(fluent: fluent)
// run migrations
if shouldMigrate {
    try await fluent.migrate()
}
```

## See Also

- ``PersistDriver``
- ``MemoryPersistDriver``
- ``HummingbirdFluent/FluentPersistDriver``
- ``HummingbirdRedis/RedisPersistDriver``
- ``HummingbirdPostgres/PostgresPersistDriver``



---
File: /Articles/RequestContexts.md
---

# Request Contexts

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Controlling contextual data provided to middleware and route handlers

## Overview

All request handlers and middleware handlers have two function parameters: the request and a context. The context provides contextual data for processing your request. The context parameter is a generic value which must conform to the protocol ``RequestContext``. This requires a minimal set of values needed by Hummingbird to process your request. This includes a `Logger`, request decoder, response encoder and the resolved endpoint path.

When you create your ``Router`` you provide the request context type you want to use. If you don't provide a context it will default to using ``BasicRequestContext`` the default implementation of a request context provided by Hummingbird.

```swift
let router = Router(context: MyRequestContext.self)
```

## Creating a context type

As mentioned above your context type must conform to ``RequestContext``. This requires an `init(source:)` and a single member variable `coreContext`.

```swift
struct MyRequestContext: RequestContext {
    var coreContext: CoreRequestContextStorage

    init(source: Source) {
        self.coreContext = .init(source: source)
    }
}
```
The ``Hummingbird/CoreRequestContextStorage`` holds the base set of information needed by the Hummingbird `Router` to process a `Request`.

The `init` takes one parameter of type `Source`. `Source` is an associatedtype for the `RequestContext` protocol and provides setup data for the `RequestContext`. By default this is set to ``Hummingbird/ApplicationRequestContextSource`` which provides access to the `Channel` that created the request.

If you are using ``HummingbirdLambda`` your RequestContext will need to conform to ``HummingbirdLambda/LambdaRequestContext`` and in that case the `Source` is a ``HummingbirdLambda/LambdaRequestContextSource`` which provide access to the `Event` that triggered the lambda and the `LambdaContext` from swift-aws-lambda-runtime.

## Encoding/Decoding

By default request decoding and response encoding uses `JSONDecoder` and `JSONEncoder` respectively. You can override this by setting the `requestDecoder` and `responseEncoder` member variables in your `RequestContext`. Below we are setting the `requestDecoder` and `responseEncoder` to a decode/encode JSON with a `dateDecodingStratrgy` of seconds since 1970. The default in Hummingbird is ISO8601.

```swift
struct MyRequestContext: RequestContext {
    /// Set request decoder to be JSONDecoder with alternate dataDecodingStrategy
    var requestDecoder: MyDecoder {
        var decoder = JSONDecoder()
        decoder.dateEncodingStrategy = .secondsSince1970
        return decoder
    }
    /// Set response encoder to be JSONEncode with alternate dataDecodingStrategy
    var responseEncoder: MyEncoder {
        var encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }
}
```

You can find out more about request decoding and response encoding in <doc:RequestDecoding> and <doc:ResponseEncoding>.

## Passing data forward

The other reason for using a custom context is to pass data you have extracted in a middleware to subsequent middleware or the route handler. 

```swift
/// Example request context with an additional field
struct MyRequestContext: RequestContext {
    var coreContext: CoreRequestContextStorage
    var additionalData: String?

    init(source: Source) {
        self.coreContext = .init(source: source)
        self.additionalData = nil
    }
}

/// Middleware that sets the additional field in 
struct MyMiddleware: MiddlewareProtocol {
    func handle(
        _ request: Request, 
        context: MyRequestContext, 
        next: (Request, MyRequestContext) async throws -> Response
    ) async throws -> Response {
        var context = context
        context.additionalData = getData(request)
        return try await next(request, context)
    }
}
```

Now anything run after `MyMiddleware` can access the `additionalData` set in `MyMiddleware`. 

## Using RequestContextSource

You can also use the RequestContext to store information from the ``RequestContextSource``. If you are running a Hummingbird server then this contains the Swift NIO `Channel` that generated the request. Below is an example of extracting the remote IP from the Channel and passing it to an endpoint.

```swift
/// RequestContext that includes a copy of the Channel that created it
struct AppRequestContext: RequestContext {
    var coreContext: CoreRequestContextStorage
    let channel: Channel

    init(source: Source) {
        self.coreContext = .init(source: source)
        self.channel = source.channel
    }

    /// Extract Remote IP from Channel
    var remoteAddress: SocketAddress? { self.channel.remoteAddress }
}

let router = Router(context: AppRequestContext.self)
router.get("ip") { _, context in
    guard let ip = context.remoteAddress else { throw HTTPError(.badRequest) }
    return "Your IP is \(ip)"
}
```

## Authentication Middleware

The most obvious example of this is passing user authentication information forward. The authentication framework from ``HummingbirdAuth`` makes use of this. If you want to use the authentication and sessions middleware your context will also need to conform to ``HummingbirdAuth/AuthRequestContext``. 

```swift
public struct MyRequestContext: AuthRequestContext {
    public var coreContext: CoreRequestContextStorage
    // required by AuthRequestContext
    public var identity: User?

    public init(source: Source) {
        self.coreContext = .init(source: source)
        self.identity = nil
    }
}
```

``HummingbirdAuth`` does provide ``HummingbirdAuth/BasicAuthRequestContext``: a default implementation of ``HummingbirdAuth/AuthRequestContext``.

## See Also

- ``RequestContext``
- ``HummingbirdAuth/AuthRequestContext``
- ``BasicRequestContext``
- ``CoreRequestContextStorage``


---
File: /Articles/RequestDecoding.md
---

# Request Decoding

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Decoding of Requests with JSON content and other formats.

## Overview

Hummingbird uses `Codable` to decode requests. It defines what decoder to use via the ``RequestContext/requestDecoder`` parameter of your ``RequestContext``. By default this is set to decode JSON, using `JSONDecoder` that comes with Swift Foundation.

Requests are converted to Swift objects using the ``/HummingbirdCore/Request/decode(as:context:)`` method in the following manner.

```swift
struct User: Decodable {
    let email: String
    let firstName: String
    let surname: String
}
router.post("user") { request, context -> HTTPResponse.Status in
    // decode user from request
    let user = try await request.decode(as: User.self, context: context)
    // create user and if ok return `.ok` status
    try await createUser(user)
    return .ok
}
```
Like the standard `Codable` decode functions `Request.decode(as:context:)` can throw an error if decoding fails. The decode function is also async as the request body is an asynchronous sequence of `ByteBuffers`. We need to collate the request body into one buffer before we can decode it.

### Date decoding

As mentioned above the default is to use `JSONDecoder` for decoding `Request` bodies. This default is also set to use ISO 8601 dates in the form `YYYY-MM-DDThh:mm:ssZ`. If you are generating requests for a Hummingbird server in a Swift app using `JSONEncoder` you can output ISO 8601 dates by setting `JSONEncoder.dateEncodingStrategy` to `.iso8601`.

## Setting up a custom decoder

If you want to use a different format, a different JSON encoder or want to support multiple formats, you need to setup you own `requestDecoder` in a custom request context. Your request decoder needs to conform to the `RequestDecoder` protocol which has one requirement ``RequestDecoder/decode(_:from:context:)``. For instance `Hummingbird` also includes a decoder for URL encoded form data. Below you can see a custom request context setup to use ``URLEncodedFormDecoder`` for request decoding. The router is then initialized with this context. Read <doc:RequestContexts> to find out more about request contexts. 

```swift
struct URLEncodedRequestContext: RequestContext {
    var requestDecoder: URLEncodedFormDecoder { .init() }
    ...
}
let router = Router(context: URLEncodedRequestContext.self)
```

## Decoding based on Request headers

Because the full request is supplied to the `RequestDecoder`. You can make decoding decisions based on headers in the request. In the example below we are decoding using either the `JSONDecoder` or `URLEncodedFormDecoder` based on the "content-type" header.

```swift
struct MyRequestDecoder: RequestDecoder {
    func decode<T>(_ type: T.Type, from request: Request, context: some RequestContext) async throws -> T where T : Decodable {
        guard let header = request.headers[.contentType] else { throw HTTPError(.badRequest) }
        guard let mediaType = MediaType(from: header) else { throw HTTPError(.badRequest) }
        switch mediaType {
        case .applicationJson:
            return try await JSONDecoder().decode(type, from: request, context: context)
        case .applicationUrlEncoded:
            return try await URLEncodedFormDecoder().decode(type, from: request, context: context)
        default:
            throw HTTPError(.badRequest)
        }
    }
}
```

## See Also 

- ``RequestDecoder``
- ``RequestContext``



---
File: /Articles/ResponseEncoding.md
---

# Response Encoding

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Writing Responses using JSON and other formats.

## Overview

Hummingbird uses `Codable` to encode responses. If your router handler returns a type conforming to ``ResponseEncodable`` this will get converted to a ``HummingbirdCore/Response`` using the encoder ``RequestContext/responseEncoder`` parameter of your ``RequestContext``. By default this is set to create a JSON Response using `JSONEncoder` that comes with Swift Foundation.

```swift
struct User: ResponseEncodable {
    let email: String
    let name: String
}

router.get("user") { request, _ -> User in
    let user = User(email: "js@email.com", name: "John Smith")
    return user
}
```
 With the above code and the default JSON encoder you will get a response with header `content-type` set to `application/json; charset=utf-8` and body 
 ```jsonb
 {"email":"js@email.com","name":"John Smith"}
 ```

### Date encoding

As mentioned above the default is to use `JSONEncoder` for encoding `Response` bodies. This default is also set to use ISO 8601 dates in the form `YYYY-MM-DDThh:mm:ssZ`. If you are decoding responses from a Hummingbird server in a Swift app using `JSONDecoder` you can parse dates using ISO 8601 by setting `JSONDecoder.dateDecodingStrategy` to `.iso8601`.

## Setting up a custom encoder

If you want to use a different format, a different JSON encoder or want to support multiple formats, you need to setup you own `responseEncoder` in a custom request context. Your response encoder needs to conform to the `ResponseEncoder` protocol which has one requirement ``ResponseEncoder/encode(_:from:context:)``. For instance `Hummingbird` also includes a encoder for URL encoded form data. Below you can see a custom request context setup to use ``URLEncodedFormEncoder`` for response encoding. The router is then initialized with this context. Read <doc:RequestContexts> to find out more about request contexts. 

```swift
struct URLEncodedRequestContext: RequestContext {
    var responseEncoder: URLEncodedFormEncoder { .init() }
    ...
}
let router = Router(context: URLEncodedRequestContext.self)
```

## Encoding based on Request headers

Because the original request is supplied to the `ResponseEncoder`. You can make encoding decisions based on headers in the request. In the example below we are encoding using either the `JSONEncoder` or `URLEncodedFormEncoder` based on the "accept" header from the request.

```swift
struct MyResponsEncoder: ResponseEncoder {
    func encode(_ value: some Encodable, from request: Request, context: some RequestContext) throws -> Response {
        guard let header = request.headers[values: .accept].first else { throw HTTPError(.badRequest) }
        guard let mediaType = MediaType(from: header) else { throw HTTPError(.badRequest) }
        switch mediaType {
        case .applicationJson:
            return try JSONEncoder().encode(value, from: request, context: context)
        case .applicationUrlEncoded:
            return try URLEncodedFormEncoder().encode(value, from: request, context: context)
        default:
            throw HTTPError(.badRequest)
        }
    }
}
```

## See Also 

- ``ResponseEncoder``
- ``RequestContext``



---
File: /Articles/RouterGuide.md
---

# Router

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

The router directs requests to their handlers based on the contents of their path. 

## Overview

The default router that comes with Hummingbird uses a Trie based lookup. Routes are added using the function ``Hummingbird/Router/on(_:method:use:)``. You provide the URI path, the method and the handler function. Below is a simple route which returns "Hello" in the body of the response.

```swift
let router = Router()
router.on("/hello", method: .GET) { request, context in
    return "Hello"
}
```
If you don't provide a path then the default is for it to be "/".

### Methods

There are shortcut functions for the most common HTTP methods. The above can be written as

```swift
let router = Router()
router.get("/hello") { request, context in
    return "Hello"
}
```

There are shortcuts for `put`, `post`, `head`, `patch` and `delete` as well.

### Response generators

Route handlers are required to return a type conforming to the `ResponseGenerator` protocol. The `ResponseGenerator` protocol requires a type to be able to generate an `Response`. For example `String` has been extended to conform to `ResponseGenerator` by returning an `Response` with status `.ok`,  a content-type header of `text-plain` and a body holding the contents of the `String`. 
```swift
/// Extend String to conform to ResponseGenerator
extension String: ResponseGenerator {
    /// Generate response holding string
    public func response(from request: Request, context: some RequestContext) -> Response {
        let buffer = ByteBuffer(string: self)
        return Response(
            status: .ok,
            headers: [.contentType: "text/plain; charset=utf-8"],
            body: .init(byteBuffer: buffer)
        )
    }
}
```

In addition to `String` `ByteBuffer`, `HTTPResponseStatus` and `Optional` have also been extended to conform to `ResponseGenerator`.

It is also possible to extend `Codable` objects to generate a `Response` by conforming these objects to ``ResponseEncodable``. The object will use the response encoder attached to your context to encode these objects. If an object conforms to `ResponseEncodable` then also so do arrays and dictionaries of these objects. Read more about generating `Response`s via `Codable` in <doc:ResponseEncoding>.

### Wildcards

You can use wildcards to match sections of a path component.

A single `*` will skip one path component

```swift
router.get("/files/*") { request, context in
    return request.uri.description
}
```
Will match 
```
GET /files/test
GET /files/test2
```

A `*` at the start of a route component will match all path components with the same suffix.

```swift
router.get("/files/*.jpg") { request, context in
    return request.uri.description
}
```
Will work for 
```
GET /files/test.jpg
GET /files/test2.jpg
```

A `*` at the end of a route component will match all path components with the same prefix.

```swift
router.get("/files/image.*") { request, context in
    return request.uri.description
}
```
Will work for 
```
GET /files/image.jpg
GET /files/image.png
```

A `**` will match and capture all remaining path components.

```swift
router.get("/files/**") { request, context in
    // return catchAll captured string
    return context.parameters.getCatchAll().joined(separator: "/")
}
```
The above will match routes and respond as follows 
```
GET /files/image.jpg returns "image.jpg" in the response body
GET /files/folder/image.png returns "folder/image.png" in the response body
```

### Parameter Capture

You can extract parameters out of the URI by prefixing the path with a colon. This indicates that this path section is a parameter. The parameter name is the string following the colon. You can get access to the URI extracted parameters from the context. This example extracts an id from the URI and uses it to return a specific user. so "/user/56" will return user with id 56. 

```swift
router.get("/user/:id") { request, context in
    let id = context.parameters.get("id", as: Int.self) else { throw HTTPError(.badRequest) }
    return getUser(id: id)
}
```
In the example above if I fail to access the parameter as an `Int` then I throw an error. If you throw an ``/Hummingbird/HTTPError`` it will get converted to a valid HTTP response.

The parameter name in your route can also be of the form `{id}`, similar to OpenAPI specifications. With this form you can also extract parameter values from the URI that are prefixes or suffixes of a path component.

```swift
router.get("/files/{image}.jpg") { request, context in
    let imageName = context.parameters.get("image") else { throw HTTPError(.badRequest) }
    return getImage(image: imageName)
}
```
In the example above we match all paths that are a file with a jpg extension inside the files folder and then call a function with that image name.

### Query parameters

The `Request` url query parameters are available via a number of methods from `Request` member ``/HummingbirdCore/Request/uri``. You can get the full query string using ``/HummingbirdCore/URI/query``. You can get the query string broken up into individual parameters and percent decoded using ``/HummingbirdCore/URI/queryParameters``.

```swift
router.get("/user") { request, context in
    // extract parameter from URL of form /user?id={userId}
    let id = request.uri.queryParameters.get("id", as: Int.self) else { throw HTTPError(.badRequest) }
    return getUser(id: id)
}
```

You can also use ``/HummingbirdCore/URI/decodeQuery(as:context:)`` to convert the query parameters into a Swift object. As with `URI.queryParameters` the values will be percent decoded.

```swift
struct Coordinate: Decodable {
    let x: Double
    let y: Double
}
router.get("tile") { request, context in
    // create `Coordinate` from query parameters in URL of form /tile?x={xCoordinate}&y={yCoordinate}
    let position = request.uri.decodeQuery(as: Coordinate.self, context: context)
    return tiles.get(at: position)
}
```

### Groups

Routes can be grouped together in a ``RouterGroup``.  These allow for you to prefix a series of routes with the same path and more importantly apply middleware to only those routes. The example below is a group that includes five handlers all prefixed with the path "/todos".

```swift
let app = Application()
router.group("/todos")
    .put(use: createTodo)
    .get(use: listTodos)
    .get("{id}", getTodo)
    .patch("{id}", editTodo)
    .delete("{id}", deleteTodo)
```

### RequestContext transformation

The `RequestContext` can be transformed for the routes in a route group. The `RequestContext` you are converting to needs to conform to ``ChildRequestContext``. This requires a parent context ie the `RequestContext` you are converting from and a ``ChildRequestContext/init(context:)`` function to perform the conversion.

```swift
struct MyNewRequestContext: ChildRequestContext {
    typealias ParentContext = MyRequestContext
    init(context: ParentContext) throws {
        self.coreContext = context.coreContext
        ...
    }
}
```
Once you have defined how to perform the transform from your original `RequestContext` the conversion is added as follows

```swift
let app = Application(context: MyRequestContext.self)
router.group("/todos", context: MyNewRequestContext.self)
    .put(use: createTodo)
    .get(use: listTodos)
```

### Route Collections

A ``RouteCollection`` is a collection of routes and middleware that can be added to a `Router` in one go. It has the same API as `RouterGroup`, so can have groups internal to the collection to allow for Middleware to applied to only sub-sections of the `RouteCollection`. 

```swift
struct UserController<Context: RequestContext> {
    var routes: RouteCollection<Context> {
        let routes = RouteCollection()
        routes.post("signup", use: signUp)
        routes.group("login")
            .add(middleware: BasicAuthenticationMiddleware())
            .post(use: login)
        return routes
    }
}
```

You add the route collection to your router using ``Router/addRoutes(_:atPath:)``.

```swift
let router = Router()
router.add("users", routes: UserController().routes)
```

### Request Body

By default the request body is an AsyncSequence of ByteBuffers. You can treat it as a series of buffers or collect it into one larger buffer.

```swift
// process each buffer in the sequence separately
for try await buffer in request.body {
    process(buffer)
}
```
```swift
// collect all the buffers in the sequence into a single buffer
let buffer = try await request.body.collate(maxSize: maximumBufferSizeAllowed)
```

Once you have read the sequence of buffers you cannot read it again. If you want to read the contents of a request body in middleware before it reaches the route handler, but still have it available for the route handler you can use `Request.collectBody(upTo:)`. After this point though the request body cannot be treated as a sequence of buffers as it has already been collapsed into a single buffer.

Any errors you receive while iterating the request body should always be propagated further up the callstack. It is fine to catch the errors but you should rethrow them once you are done with them, so they can passed back to `Application` to be dealt with according.

### Writing the response body

The response body is returned back to the server as a closure that will write the body. The closure is provided with a writer type conforming to ``HummingbirdCore/ResponseBodyWriter`` and the closure uses this to write the buffers that make up the body. In most cases you don't need to know this as ``HummingbirdCore/ResponseBody`` has initializers that take a single `ByteBuffer`, a sequence of `ByteBuffers` and an `AsyncSequence` of `ByteBuffers` which covers most of the kinds of responses. 

In the situation where you need something a little more flexible you can use the closure form. Below is a `ResponseBody` that consists of 10 buffers of random data written with a one second pause between each buffer.

```swift
let responseBody = ResponseBody { writer in
    for _ in 0..<10 {
        try await Task.sleep(for: .seconds(1))
        let buffer = (0..<size).map { _ in UInt8.random(in: 0...255) }
        try await writer.write(buffer)
    }
    writer.finish(nil)
}
```
Once you have finished writing your response body you need to tell the writer you have finished by calling ``HummingbirdCore/ResponseBodyWriter/finish(_:)``. At this point you can write trailing headers by passing them to the `finish` function. NB Trailing headers are only sent if your response body is chunked and does not include a content length header.

### Editing response in handler

The standard way to provide a custom response from a route handler is to return a `Response` from that handler. This method loses a lot of the automation of encoding responses, generating the correct status code etc. 

Instead you can return what is called a `EditedResponse`. This includes a type that can generate a response on its own via the `ResponseGenerator` protocol and includes additional edits to the response.

```swift
router.post("test") { request, _ -> EditedResponse in
    return .init(
        status: .accepted,
        headers: [.contentType: "application/json"],
        response: #"{"test": "value"}"#
    )
}
```

## See Also

- ``HummingbirdCore/Request``
- ``HummingbirdCore/Response``
- ``Router``
- ``RouteCollection``
- ``RouterGroup``



---
File: /Articles/ServerProtocol.md
---

# Server protocol

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Support for TLS and HTTP2 upgrades

## Overview

By default a Hummingbird application runs with a HTTP/1.1 server. The Hummingbird comes with additional libraries that allow you to change this to use TLS, HTTP2 and WebSockets

### Setting server protocol

When you create your ``Application`` there is a parameter `server` that is used to define the server protocol and its configuration. Below we are creating a server that support HTTP1 with a idle timeout for requests set to one minutes.

```swift
let app = Application(
    router: router,
    server: .http1(idleTimeout: .seconds(60))
)
```

## HTTPS/TLS

HTTPS is pretty much a requirement for a server these days. Many people run Nginx in front of their server to implement HTTPS, but it is also possible to setup HTTPS inside your Hummingbird application. 

```swift
import HummingbirdTLS

let tlsConfiguration = TLSConfiguration.makeServerConfiguration(
    certificateChain: certificateChain,
    privateKey: privateKey
)
let app = Application(
    router: router,
    server: .tls(.http1(), tlsConfiguration: tlsConfiguration)
)
```

HTTPS is the HTTP protocol with an added encryption layer of TLS to protect the traffic. The `tls` function applies the encryption layer using the crytographic keys supplied in the `TLSConfiguration`.

## HTTP2

HTTP2 is becoming increasingly common. It allows you to service multiple HTTP requests concurrently over one connection. The HTTP2 protocol does not require you to use TLS but it is in effect only supported over TLS as there aren't any web browsers that support HTTP2 without TLS. Given this the Hummingbird implementation also requires TLS.

```swift
import HummingbirdHTTP2

let app = Application(
    router: router,
    server: .http2(
        tlsConfiguration: tlsConfiguration,
        configuration: .init(
            idleTimeout: .seconds(60),
            gracefulCloseTimeout: .seconds(15),
            maxAgeTimeout: .seconds(900),
            streamConfiguration: .init(idleTimeout: .seconds(60))
        )
    )
)
```

The HTTP2 upgrade protocol has a fair amount of configuration. It includes a number of different timeouts, 
- `idleTimeout`: How long a connection is kept open while idle
- `gracefulCloseTimeout`: The maximum amount of time to wait for the client to respond before all streams are closed after the second GOAWAY is sent
- `maxAgeTimeout`: a maximum amount of time a connection should be open.
Then each HTTP2 stream (request) has its own idle timeout as well.

## WebSockets

WebSocket upgrades are also implemented via the server protocol parameter.

```swift
import HummingbirdWebSocket

let app = Application(
    router: router,
    server: .http1WebSocketUpgrade { request, channel, logger in
        // upgrade if request URI is "/ws"
        guard request.uri == "/ws" else { return .dontUpgrade }
        // The upgrade response includes the headers to include in the response and 
        // the WebSocket handler
        return .upgrade([:]) { inbound, outbound, context in
            for try await frame in inbound {
                // send "Received" for every frame we receive
                try await outbound.write(.text("Received"))
            }
        }
    }
)
```

In a similar way you add TLS encryption to the HTTP1 connection you can also add TLS to a connection that accepts WebSocket upgrades.

```swift
let app = Application(
    router: router,
    server: .tls(
        .http1WebSocketUpgrade { request, channel, logger in
            // upgrade if request URI is "/ws"
            guard request.uri == "/ws" else { return .dontUpgrade }
            // The upgrade response includes the headers to include in the response and 
            // the WebSocket handler
            return .upgrade([:]) { inbound, outbound, context in
                try await outbound.write(.text("Hello"))
            }
        },
        tlsConfiguration: tlsConfiguration
    )    
)
```

To find out more about WebSocket upgrades and handling WebSocket connections read <doc:WebSocketServerUpgrade>.

## Topics

### Reference

- ``HummingbirdHTTP2``
- ``HummingbirdTLS``
- ``HummingbirdWebSocket``



---
File: /Articles/ServiceLifecycle.md
---

# Service Lifecycle

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Integration with Swift Service Lifecycle

## Overview

To provide a mechanism to cleanly start and shutdown a Hummingbird application we have integrated with [Swift Service Lifecycle](https://github.com/swift-server/swift-service-lifecycle). This provides lifecycle management for service startup, shutdown and shutdown triggering by signals such as SIGINT and SIGTERM.

## Service Lifecycle

To use Swift Service Lifecycle you have to conform the service you want managed to the protocol [`Service`](https://swiftpackageindex.com/swift-server/swift-service-lifecycle/main/documentation/servicelifecycle/service). Internally this needs to call `withGracefulShutdownHandler` to handle graceful shutdown when we receive a shutdown signal.

```swift
struct MyService: Service {
    func run() async throws {
        withGracefulShutdownHandler {
            // run service
        } onGracefulShutdown {
            // shutdown service
        }
    }
}
```

Once you have this setup you can then include the service in a list of services added to a service group and have its lifecycle managed.

```swift
let serviceGroup = ServiceGroup(
    configuration: .init(
        services: [MyService(), MyOtherService()],
        gracefulShutdownSignals: [.sigterm, .sigint]
        logger: logger
    )
)
try await serviceGroup.run()
```

## Hummingbird Integration

``Application`` conforms to `Service` and also provides a helper function that constructs the `ServiceGroup` including the application and then runs it.

```swift
let app = Application(router: router)
try await app.runService()
```

All of the types that Hummingbird introduces that require some form of lifecycle management conform to `Service`. ``Application`` holds an internal `ServiceGroup` and any service you want managed can be added to the internal group using ``Application/addServices(_:)``.

```swift
var app = Application(router: router)
app.addServices(postgresClient, sessionStorage)
try await app.runService()
```

## Managing server startup

In some situations you might want some services to start up before you startup your HTTP server, for instance when doing a database migration. With ``Application`` you can add processes to run before starting up the server, but while other services are running using ``Application/beforeServerStarts(perform:)``. You can call `beforeServerStarts` multiple times to add multiple processes to be run before we startup the server.

```swift
var app = Application(router: router)
app.addServices(dbClient)
app.beforeServerStarts {
    try await dbClient.migrate()
}
try await app.runService()
```

Read the Swift Service Lifecycle [documentation](https://swiftpackageindex.com/swift-server/swift-service-lifecycle/main/documentation/servicelifecycle) to find out more.

## See Also

- ``Application``



---
File: /Articles/Testing.md
---

# Testing

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Using the HummingbirdTesting framework to test your application

## Overview

Writing tests for application APIs is an important part of the development process. They ensure everything works as you expected and that you don't break functionality with future changes. Hummingbird provides a framework for testing your application as if it is a running server and you are a client connecting to it.

## Example

Lets create a simple application that says hello back to you. ie If your request is to `/hello/adam` it returns "Hello adam!".

```swift
let router = Router()
router.get("hello/{name}") { _,context in
    return try "Hello \(context.parameters.require("name"))!"
}
let app = Application(router: router)
```

## Testing

We can test the application returns the correct text as follows

```swift
func testApplicationReturnsCorrectText() async throw {
    try await app.test(.router) { client in
        try await client.execute(
            uri: "/hello/john",
            method: .get,
            headers: [:],  // default value
            body: nil      // default value
        ) { response in
            #expect(response.status == .ok)
            #expect(String(buffer: response.body) == "Hello john!")
        }
    }
}
```

### `Application.test`

The ``/Hummingbird/ApplicationProtocol/test(_:_:)`` function takes two parameters, first the test framework to use and then the closure to run with the framework client. The test framework defines how we are going to test our application. There are three possible frameworks

#### Router (.router)

The router test framework will send requests directly to the router. It does not need a running server to run tests. The main advantages of this is it is the quickest way to test your application but will not test anything outside of the router. In most cases you won't need more than this.

#### Live (.live)

The live framework uses a live server, with an HTTP client attached on a single connection.

#### AsyncHTTPClient (.ahc)

The AsyncHTTPClient framework is the same as the live framework except it uses [AsyncHTTPClient](https://github.com/swift-server/async-http-client) from swift-server as its HTTPClient. You can use this to test TLS and HTTP2 connections.

### Executing requests and testing the response

The function ``HummingbirdTesting/TestClientProtocol/execute(uri:method:headers:body:testCallback:)`` sends a request to your application and provides the response in a closure. If you return something from the closure then this is returned by `execute`. In the following example we are testing whether a session cookie works.

```swift
@Test
func testApplicationReturnsCorrectText() async throw {
    try await app.test(.router) { client in
        // test login, returns a set-cookie header and extract
        let cookie = try await client.execute(
            uri: "/user/login", 
            method: .post, 
            headers: [.authorization: "Basic blahblah"]
        ) { response in
            #expect(response.status == .ok)
            return try #require(response.headers[.setCookie])
        }
        // check session cookie works
        try await client.execute(
            uri: "/user/is-authenticated", 
            method: .get, 
            headers: [.cookie: cookie]
        ) { response in
            #expect(response.status == .ok)
        }
    }
}
```

## See Also

- ``/Hummingbird/ApplicationProtocol/test(_:_:)``
- ``/HummingbirdTesting/TestClientProtocol``


---
File: /Hummingbird/Application.md
---

# ``Hummingbird/Application``

@Metadata {
    @DocumentationExtension(mergeBehavior: override)
}
Application type bringing together all the components of Hummingbird

## Overview

`Application` is a concrete implementation of ``ApplicationProtocol``. It provides the glue between your router and the HTTP server. 

```swift
// create router
let router = Router()
router.get("hello") { _,_ in
    return "hello"
}
// create application
let app = Application(
    router: router, 
    server: .http1()    // This is the default value
)
// run application
try await app.runService()
```

## Generic Type

`Application` is a generic type, if you want to pass it around it is easier to use the opaque type `some ApplicationProtocol` than work out its exact parameters types.

```swift
func buildApplication() -> some ApplicationProtocol {
    let router = Router()
    router.get("hello") { _,_ in
        return "hello"
    }
    // create application
    let app = Application(router: router)
}
```

## Services

`Application` has its own `ServiceGroup` which is used to manage the lifecycle of all the services it creates. You can add your own services to this group to have them managed as well. 

```swift
var app = Application(router: router)
app.addServices(postgresClient, jobQueueHandler)
```

Check out [swift-service-lifecycle](https://github.com/swift-server/swift-service-lifecycle) for more details on service lifecycle management.



---
File: /Hummingbird/ApplicationProtocol.md
---

# ``Hummingbird/ApplicationProtocol``

@Metadata {
    @DocumentationExtension(mergeBehavior: override)
}
Application protocol bringing together all the components of Hummingbird

## Overview

`ApplicationProtocol` is a protocol used to define your application. It provides the glue between your router and HTTP server.

Implementing a `ApplicationProtocol` requires two member variables: `responder` and `server`.

```swift
struct MyApp: ApplicationProtocol {
    /// The responder will return an `Response` given an `Request` and a context
    var responder: some Responder<BasicRequestContext> {
        let router = Router(context: Context.self)
        router.get("hello") { _,_ in "Hello" }
        return router.buildResponder()
    }
    /// Defines your server type. This is the default value so in
    /// effect is unnecessary
    var server: HTTPChannelBuilder<some ChildChannel> { .http1() }
}
let app = MyApp()
try await app.runService()
```

If you don't want to create your own type, Hummingbird provides ``Application`` a concrete implementation of `ApplicationProtocol`.



---
File: /Hummingbird/Hummingbird.md
---

# ``Hummingbird``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Lightweight, modern, flexible server framework written in Swift.

Hummingbird is a lightweight, modern, flexible server framework designed to require the minimum number of dependencies.

It provides a router for directing different endpoints to their handlers, middleware for processing requests before they reach your handlers and processing the responses returned, custom encoding/decoding of requests/responses, TLS and HTTP2.

```swift
import Hummingbird

// create router and add a single GET /hello route
let router = Router()
router.get("hello") { request, _ -> String in
    return "Hello"
}
// create application using router
let app = Application(
    router: router,
    configuration: .init(address: .hostname("127.0.0.1", port: 8080))
)
// run hummingbird application
try await app.runService()
```

## Topics

### Application

- ``Application``
- ``ApplicationProtocol``
- ``ApplicationConfiguration``
- ``EventLoopGroupProvider``

### Router

- ``Router``
- ``RouterGroup``
- ``RouteCollection``
- ``RouterMethods``
- ``RouterOptions``
- ``HTTPResponder``
- ``HTTPResponderBuilder``
- ``CallbackResponder``
- ``RouterResponder``
- ``EndpointPath``
- ``RouterPath``
- ``RequestID``

### Request/Response

- ``/HummingbirdCore/Request``
- ``Parameters``
- ``MediaType``
- ``CacheControl``
- ``/HummingbirdCore/Response``
- ``/HummingbirdCore/ResponseBodyWriter``
- ``EditedResponse``
- ``Cookie``
- ``Cookies``

### Request context

- ``RequestContext``
- ``RequestContextSource``
- ``ApplicationRequestContextSource``
- ``BasicRequestContext``
- ``ChildRequestContext``
- ``CoreRequestContextStorage``
- ``RemoteAddressRequestContext``

### Encoding/Decoding

- ``RequestDecoder``
- ``ResponseEncoder``
- ``ResponseEncodable``
- ``ResponseGenerator``
- ``ResponseCodable``
- ``URLEncodedFormDecoder``
- ``URLEncodedFormEncoder``

### Errors

- ``HTTPError``
- ``HTTPResponseError``

### Middleware

- ``MiddlewareProtocol``
- ``MiddlewareFixedTypeBuilder``
- ``RouterMiddleware``
- ``MiddlewareGroup``
- ``CORSMiddleware``
- ``LogRequestsMiddleware``
- ``MetricsMiddleware``
- ``TracingMiddleware``

### File management/middleware

- ``FileMiddleware``
- ``FileIO``
- ``FileProvider``
- ``FileMiddlewareFileAttributes``
- ``LocalFileSystem``

### Storage

- ``PersistDriver``
- ``MemoryPersistDriver``
- ``PersistError``

### Miscellaneous

- ``Environment``
- ``InitializableFromSource``

## See Also

- ``HummingbirdRouter``
- ``HummingbirdTesting``



---
File: /Hummingbird/RouterMiddleware.md
---

# ``Hummingbird/RouterMiddleware``

@Metadata {
    @DocumentationExtension(mergeBehavior: override)
}
Version of ``MiddlewareProtocol`` whose Input is ``HummingbirdCore/Request`` and output is ``HummingbirdCore/Response``. 

## Overview

All middleware has to conform to the protocol `RouterMiddleware`. This requires one function `handle(_:context:next)` to be implemented. At some point in this function unless you want to shortcut the router and return your own response you should call `next(request, context)` to continue down the middleware stack and return the result, or a result processed by your middleware. 

The following is a simple logging middleware that outputs every URI being sent to the server

```swift
public struct LogRequestsMiddleware<Context: RequestContext>: RouterMiddleware {
    public func handle(_ request: Request, context: Context, next: (Request, Context) async throws -> Response) async throws -> Response {
        // log request URI
        context.logger.log(level: .debug, String(describing:request.uri.path))
        // pass request onto next middleware or the router and return response
        return try await next(request, context)
    }
}
```



---
File: /HummingbirdAuth/AuthenticatorMiddlewareGuide.md
---

# Authenticator Middleware

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Request authentication middleware

## Overview

Authenticators are middleware that are used to check if a request is authenticated and then pass authentication data to functions further down the callstack via the request context. Authenticators should conform to protocol ``HummingbirdAuth/AuthenticatorMiddleware``. This requires you implement the function ``HummingbirdAuth/AuthenticatorMiddleware/authenticate(request:context:)`` that returns a value conforming to `Sendable`.

To use an authenticator it is required that your request context conform to ``HummingbirdAuth/AuthRequestContext``. When you return valid authentication data from your `authenticate` function it is recorded in the ``HummingbirdAuth/AuthRequestContext/identity`` member of your request context.

## Usage

A simple username, password authenticator could be implemented as follows. If the authenticator is successful it returns a `User` struct, otherwise it returns `nil`.

```swift
struct BasicAuthenticator: AuthenticatorMiddleware {
    func authenticate<Context: AuthRequestContext>(request: Request, context: Context) async throws -> Identity? {
        // Basic authentication info in the "Authorization" header, is accessible
        // via request.headers.basic
        guard let basic = request.headers.basic else { return nil }
        // check if user exists in the database and then verify the entered password
        // against the one stored in the database. If it is correct then login in user
        let user = try await database.getUserWithUsername(basic.username)
        // did we find a user
        guard let user = user else { return nil }
        // verify password against password hash stored in database. If valid
        // return the user. HummingbirdAuth provides an implementation of Bcrypt
        // This should be run on the thread pool as it is a long process.
        return try await NIOThreadPool.singleton.runIfActive {
            if Bcrypt.verify(basic.password, hash: user.passwordHash) {
                return user
            }
            return nil
        }
    }
}
```
An authenticator is middleware so can be added to your application like any other middleware

```swift
router.add(middleware: BasicAuthenticator())
```

Then in your request handler you can access your authentication data with `context.identity`.

```swift
/// Get current logged in user
func current(_ request: Request, context: MyContext) throws -> User {
    // get authentication data for user. If it doesnt exist then throw unauthorized error
    let user = context.requireIdentity()
    return user
}
```

You can require that that authentication was successful and authentication data is available by adding the middleware ``HummingbirdAuth/IsAuthenticatedMiddleware`` after your authentication middleware

```swift
router.addMiddleware {
    BasicAuthenticator()
    IsAuthenticatedMiddleware()
}
```

## See Also

- ``HummingbirdAuth/AuthenticatorMiddleware``
- ``HummingbirdAuth/AuthRequestContext``
- ``HummingbirdAuth/IsAuthenticatedMiddleware``


---
File: /HummingbirdAuth/HummingbirdAuth.md
---

# ``HummingbirdAuth``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Authentication framework and extensions for Hummingbird.

Includes authenticator middleware setup, bearer and basic authentication extraction from your Request headers. session authentication. Additional modules are available that support ``HummingbirdBcrypt`` encryption, one time passwords (``HummingbirdOTP``) and include a Basic user/password authentication middleware (``HummingbirdBasicAuth``).

## Topics

### Request Contexts

- ``BasicAuthRequestContext``
- ``AuthRequestContext``

### Authenticators

- ``AuthenticatorMiddleware``
- ``ClosureAuthenticator``
- ``IsAuthenticatedMiddleware``

### Header Authentication

- ``BasicAuthentication``
- ``BearerAuthentication``

### Sessions

- ``SessionMiddleware``
- ``SessionRequestContext``
- ``SessionContext``
- ``SessionData``
- ``BasicSessionRequestContext``
- ``SessionStorage``
- ``SessionCookieParameters``

### Session authenticator

- ``SessionAuthenticator``
- ``UserSessionRepository``
- ``UserSessionClosureRepository``
- ``UserRepositoryContext``

## See Also

- ``HummingbirdBasicAuth``
- ``HummingbirdBcrypt``
- ``HummingbirdOTP``



---
File: /HummingbirdAuth/Sessions.md
---

# Sessions

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Session based authentication

Sessions allow you to persist state eg user authentication status between multiple requests to the server. They work by creating a temporary session object that is stored in a key/value store. The key or session id is returned in the response. Subsequent requests can then access the session object by supplying the session id in their request. This object can then be used to authenicate the user. Normally the session id is stored in a cookie.

## SessionMiddleware

The ``HummingbirdAuth/SessionMiddleware`` is used to extract and save session state from the RequestContext. To use it, your `RequestContext` must conform to ``HummingbirdAuth/SessionRequestContext``. Adding the `SessionMiddleware` to your middleware stack will mean any middleware or routes after will have read/write access to session state via the member ``HummingbirdAuth/SessionRequestContext/sessions``.

The `SessionMiddleware` needs a persist key value store to save its state. You can find out more about the persist framework here <doc:PersistentData>. In the example below we are using an in memory key value store, but ``HummingbirdFluent/FluentPersistDriver`` and ``HummingbirdRedis/RedisPersistDriver`` provide solutions that stores the session data in a database or redis database respectively.

```swift
router.add(
    middleware: SessionMiddleware(
        storage: MemoryPersistDriver()
    )
)
```

By default sessions store the session id in a `SESSION_ID` cookie and the default session expiration is 12 hours. At initialization it is possible to set these up differently. 

```swift
router.add(
    middleware: SessionMiddleware(
        storage: MemoryPersistDriver(),
        sessionCookie: "MY_SESSION_ID",
        defaultSessionExpiration: .seconds(60 * 60)
    )
)
```

## SessionRequestContext

The ``HummingbirdAuth/SessionRequestContext`` protocol requires you include a member `sessions`. This is a ``HummingbirdAuth/SessionContext`` type which holds the session data for the current request and includes a generic parameter defining what type this session data is.

```swift
struct MyRequestContext: SessionRequestContext {
    /// core context
    public var coreContext: CoreRequestContextStorage
    /// session context with UUID as the session object
    public let sessions: SessionContext<UUID>
}
```

## Saving a session

Once a user is authenticated you need to save a session for the user. 

```swift
func login(_ request: Request, context: MyRequestContext) async throws -> HTTPResponseStatus {
    // get authenticated user
    let user = try context.requireIdentity()
    // create session lasting 1 hour
    context.sessions.setSession(user.id, expiresIn: .seconds(600))
    return .ok
}
```

In this example `user.id` is saved with the session id. The data we save in `setSession` is saved to storage when we return to the `SessionMiddleware`. If your route throws an error then the session data is not updated.

## Sessions Authentication

To authenticate a user using a session id you need to add a ``HummingbirdAuth/SessionAuthenticator`` middleware to the router. This uses the session stored in the request context and converts it into the authenticated user using the closure or ``HummingbirdAuth/UserSessionRepository`` provided. The session authenticator requires your `RequestContext` conforms to both `SessionRequestContext` and `AuthRequestContext`.

```swift
router.addMiddleware {
    SessionMiddleware(storage: MemoryPersistDriver())
    SessionAuthenticator { session, context in
        try await getUser(from: session)
    }
}
router.get("session") { request, context -> HTTPResponse.Status in
    _ = try context.requireIdentity()
    return .ok
}
```

## See Also

- ``HummingbirdAuth/SessionAuthenticator``
- ``HummingbirdAuth/SessionRequestContext``


---
File: /HummingbirdBasicAuth/HummingbirdBasicAuth.md
---

# ``HummingbirdBasicAuth``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Basic user/password authentication middleware

## Topics

### Authenticator

- ``BasicAuthenticator``

### Storage

- ``UserPasswordRepository``
- ``PasswordAuthenticatable``
- ``UserPasswordClosureRepository``

### Passwords

- ``PasswordHashVerifier``
- ``BcryptPasswordVerifier``

## See Also

- ``HummingbirdAuth``
- ``HummingbirdBcrypt``
- ``Hummingbird``



---
File: /HummingbirdBcrypt/HummingbirdBcrypt.md
---

# ``HummingbirdBcrypt``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Bcrypt encryption

## Topics

### Encryption

- ``Bcrypt``

## See Also

- ``HummingbirdAuth``
- ``HummingbirdBasicAuth``
- ``Hummingbird``



---
File: /HummingbirdCompression/HummingbirdCompression.md
---

# ``HummingbirdCompression``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Middleware for decompressing requests and compressing responses

## Usage

```swift
let router = Router()
router.middlewares.add(RequestDecompressionMiddleware())
router.middlewares.add(ResponseCompressionMiddleware(minimumResponseSizeToCompress: 512))
```

Adding request decompression middleware means when a request comes in with header `content-encoding` set to `gzip` or `deflate` the server will attempt to decompress the request body. Adding response compression means when a request comes in with header `accept-encoding` set to `gzip` or `deflate` the server will compression the response body.

## Topics

### Request decompression

- ``RequestDecompressionMiddleware``

### Response compression

- ``ResponseCompressionMiddleware``



---
File: /HummingbirdCore/HummingbirdCore.md
---

# ``HummingbirdCore``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Swift NIO based HTTP server. 

## Overview

HummingbirdCore contains a Swift NIO based server. The server is setup with a type conforming `ChannelSetup` which defines how the server responds. It has two functions `initialize` defines how to setup a server channel ie should it be HTTP1, should it include TLS etc and `handle` defines how we should respond to individual messages. For example the following is an HTTP1 server that always returns a response containing the word "Hello" in the body. 

```swift
let server = Server(
    childChannelSetup: HTTP1Channel { (_, responseWriter: consuming ResponseWriter, _) in
        let responseBody = ByteBuffer(string: "Hello")
        var bodyWriter = try await responseWriter.writeHead(.init(status: .ok))
        try await bodyWriter.write(responseBody)
        try await bodyWriter.finish(nil)
    },
    configuration: .init(address: .hostname(port: 8080)),
    eventLoopGroup: eventLoopGroup,
    logger: Logger(label: "HelloServer")
)
```

> Note: In general you won't need to create a `Server` directly. You would let ``Hummingbird/Application`` do this for you. But the ability is left open to you if you want to write your own HTTP server.

## Lifecycle management

Hummingbird makes use of [Swift Service Lifecycle](https://github.com/swift-server/swift-service-lifecycle) to manage startup and shutdown. `Server` conforms to the `Service` protocol required by Swift Service Lifecycle. The following will start the above server and ensure it shuts down gracefully on a shutdown signal.

```swift
let serviceGroup = ServiceGroup(
    services: [server],
    configuration: .init(gracefulShutdownSignals: [.sigterm, .sigint]),
    logger: logger
)
try await serviceGroup.run()
```

## Topics

### Server

- ``Server``
- ``ServerConfiguration``
- ``ServerChildChannel``
- ``ServerChildChannelValue``
- ``BindAddress``
- ``AvailableConnectionsChannelHandler``
- ``AvailableConnectionsDelegate``
- ``MaximumAvailableConnections`` 

### HTTP Server

- ``HTTPServerBuilder``
- ``HTTPChannelHandler``
- ``HTTP1Channel``
- ``HTTPUserEventHandler``

### Request

- ``Request``
- ``URI``
- ``RequestBody``

### Response

- ``Response``
- ``ResponseBody``
- ``ResponseWriter``
- ``ResponseBodyWriter``

### Miscellaneous

- ``FlatDictionary``

## See Also

- ``Hummingbird``
- ``HummingbirdHTTP2``
- ``HummingbirdTLS``



---
File: /HummingbirdFluent/HummingbirdFluent.md
---

# ``HummingbirdFluent``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Integration with Vapor's Fluent ORM framework.

```swift
let fluent = Fluent()
// add sqlite database
fluent.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

// add router with one route to return a Todo type
let router = Router()
router.get("todo/{id}") { request, context in
    let id = try await context.parameters.require("id", as: UUID.self)
    return Todo.find(id, on: fluent.db())
}

var app = Application(router: router)
// add fluent as a service to manage its lifecycle
app.addServices(fluent)
try await app.runService()
```

## Storage

HummingbirdFluent provides a driver for the persist framework to store key, value pairs between requests.

```swift
let fluent = Fluent()
// add sqlite database
fluent.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
let persist = FluentPersistDriver(fluent: fluent)
if doingMigration {
    // fluent persist driver requires a migrate the first time you run
    try await fluent.migrate()
}
let router = Router()
// return value from sqlite database
router.get("{id}") { request, context -> String? in
    let id = try context.parameters.require("id")
    try await persist.get(key: id, as: String.self)
}
// set value in sqlite database
router.put("{id}") { request, context -> String? in
    let id = try context.parameters.require("id")
    let value = try request.uri.queryParameters.require("value")
    try await persist.set(key: id, value: value)
}
var app = Application(router: router)
// add fluent and persist driver as services to manage their lifecycle
app.addServices(fluent, persist)
try await app.runService()
```

For more information:
- Follow the tutorial: <doc:Fluent>
- Read the [Fluent docs](https://docs.vapor.codes/fluent/overview/)

## Topics

### Fluent

- ``Fluent``
- ``FluentMigrations``

### Storage

- ``FluentPersistDriver``



---
File: /HummingbirdHTTP2/HummingbirdHTTP2.md
---

# ``HummingbirdHTTP2``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Add HTTP2 support to Hummingbird server.

## Overview

HummingbirdHTTP2 is bundled with Hummingbird, but is not enabled by default. To enable HTTP2 support, you need to add the target dependency to your target:

```sh
swift package add-target-dependency HummingbirdHTTP2 <MyApp> --package hummingbird
```

Make sure to replace `<MyApp>` with the name of your App's target.

HummingbirdHTTP2 provides HTTP2 upgrade support via ``HTTP2UpgradeChannel``. You can add this to your application using ``HummingbirdCore/HTTPServerBuilder/http2Upgrade(tlsConfiguration:additionalChannelHandlers:)``.

```swift
// Load certificates and private key to construct server TLS configuration
let certificateChain = try NIOSSLCertificate.fromPEMFile(arguments.certificateChain)
let privateKey = try NIOSSLPrivateKey(file: arguments.privateKey, format: .pem)
let tlsConfiguration = TLSConfiguration.makeServerConfiguration(
    certificateChain: certificateChain.map { .certificate($0) },
    privateKey: .privateKey(privateKey)
)

let router = Router()
let app = Application(
    router: router,
    server: .http2Upgrade(tlsConfiguration: tlsConfiguration)
)
```

## Topics

### Server

- ``/HummingbirdCore/HTTPServerBuilder/http2Upgrade(tlsConfiguration:configuration:)``
- ``/HummingbirdCore/HTTPServerBuilder/http2Upgrade(tlsChannelConfiguration:configuration:)``
- ``/HummingbirdCore/HTTPServerBuilder/plaintextHTTP2(configuration:)``
- ``HTTP2UpgradeChannel``
- ``HTTP2Channel``

### Configuration

- ``HTTP2ChannelConfiguration``
- ``TLSChannelConfiguration``

## See Also

- ``Hummingbird``
- ``HummingbirdCore``
- ``HummingbirdTLS``



---
File: /HummingbirdLambda/HummingbirdLambda.md
---

# ``HummingbirdLambda``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Run Hummingbird inside an AWS Lambda.

## Usage

Create struct conforming to `LambdaFunction`. Setup your router in the `buildResponder` function: add routes, middleware etc and then return its responder.

```swift
@main
struct MyHandler: LambdaFunction {
    typealias Event = APIGatewayRequest
    typealias Output = APIGatewayResponse
    typealias Context = BasicLambdaRequestContext<APIGatewayRequest>

    init(context: LambdaInitializationContext) {}
    
    /// build responder that will create a response from a request
    func buildResponder() -> some Responder<Context> {
        let router = Router(context: Context.self)
        router.get("hello/{name}") { request, context in
            let name = try context.parameters.require("name")
            return "Hello \(name)"
        }
        return router.buildResponder()
    }
}
```

The `Event` and `Output` types define your input and output objects. If you are using an `APIGateway` REST interface to invoke your Lambda then set these to `APIGateway.Request` and `APIGateway.Response` respectively. If you are using an `APIGateway` HTML interface then set these to `APIGateway.V2.Request` and `APIGateway.V2.Response`. The protocols ``APIGatewayLambdaFunction`` and ``APIGatewayV2LambdaFunction`` set these up for you.

If you are using any other `In`/`Out` types you will need to implement the `request(context:application:from:)` and `output(from:)` methods yourself.

## Topics

### Lambda protocols

- ``LambdaFunction``
- ``APIGatewayLambdaFunction``
- ``APIGatewayV2LambdaFunction``

### Request context

- ``LambdaRequestContext``
- ``BasicLambdaRequestContext``
- ``LambdaRequestContextSource``

## See Also

- ``HummingbirdLambdaTesting``



---
File: /HummingbirdOTP/HummingbirdOTP.md
---

# ``HummingbirdOTP``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

One time passwords

## Topics

### OTP

- ``HOTP``
- ``TOTP``
- ``OTPHashFunction``

## See Also

- ``Hummingbird``
- ``HummingbirdAuth``



---
File: /HummingbirdOTP/OneTimePasswords.md
---

# One Time Passwords

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

A one time password (OTP) valid for only one login session. 

## Overview

OTPs avoid a number of shortcomings that are associated with traditional (static) password-based authentication. OTP generation algorithms typically make use of pseudo-randomness or randomness, making prediction of successor OTPs by an attacker difficult, and also cryptographic hash functions, which can be used to derive a value but are hard to reverse and therefore difficult for an attacker to obtain the data that was used for the hash. This is necessary because otherwise it would be easy to predict future OTPs by observing previous ones.

HummingbirdAuth provides support for both time based (``HummingbirdOTP/TOTP``) and counter based (``HummingbirdOTP/HOTP``) one time passwords.

## Usage

To setup one time password authentication you need a shared secret for each user. Store the shared secret with your user in a database. You can generate an authentication URL to supply to the user which includes a base32 encoded version of the shared secret. 

```swift
// create shared secret
let sharedSecret = "random string"
// store shared secret in database alongside user
storeSecretWithUser(secret: sharedSecret)
// create TOTP and generate authenticaion URL
let totp = TOTP(secret: sharedSecret)
let authenticationURL = totp.createAuthenticatorURL(label: "MyURL")
```

Generally this is provided to the user via a QR Code. Most phones will automatically open up an Authenticator app to store the URL when they scan the QR Code.

## Authenticating

Compute the time based one time password as follows 

```swift
let password = TOTP(secret: sharedSecret).compute()
```

Compare it with the password provided by the user to verify the user credentials.

## See Also

- ``HummingbirdOTP/TOTP``
- ``HummingbirdOTP/HOTP``


---
File: /HummingbirdPostgres/HummingbirdPostgres.md
---

# ``HummingbirdPostgres``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Working with Postgres databases.

`HummingbirdPostgres` provides a Postgres implementation of the persist framework. It uses `PostgresClient` from [PostgresNIO](https://api.vapor.codes/postgresnio/documentation/postgresnio/) as its database client.

## Topics

### Persist

- ``PostgresPersistDriver``

## See Also

- ``PostgresMigrations``
- ``JobsPostgres``




---
File: /HummingbirdRedis/HummingbirdRedis.md
---

# ``HummingbirdRedis``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Add Redis support to Hummingbird server with RediStack.

## Overview

Adds Redis support to Hummingbird via [RediStack](https://github.com/swift-server/RediStack) and manage the lifecycle of your Redis connection pool. Also provides a Redis based driver for the persist framework.

```swift
let redis = try RedisConnectionPoolService(
    .init(hostname: Self.redisHostname, port: 6379),
    logger: Logger(label: "Redis")
)
// add router with one route to return Redis info
let router = Router()
router.get("redis") { _, _ in
    try await redis.send(command: "INFO").map(\.description).get()
}
var app = Application(router: router)
// add Redis connection pool as a service to manage its lifecycle
app.addServices(redis)
try await app.runService()
```

## Storage

HummingbirdRedis provides a driver for the persist framework to store key, value pairs between requests.

```swift
let redis = try RedisConnectionPoolService(
    .init(hostname: Self.redisHostname, port: 6379),
    logger: Logger(label: "Redis")
)
let persist = RedisPersistDriver(redisConnectionPoolService: redis)
let router = Router()
// return value from redis database
router.get("{id}") { request, context -> String? in
    let id = try context.parameters.require("id")
    try await persist.get(key: id, as: String.self)
}
// set value in redis database
router.put("{id}") { request, context -> String? in
    let id = try context.parameters.require("id")
    let value = try request.uri.queryParameters.require("value")
    try await persist.set(key: id, value: value)
}
var app = Application(router: router)
// add Redis connection pool and persist driver as services to manage their lifecycle
app.addServices(redis, persist)
try await app.runService()
```


## Topics

### Connection Pool

- ``RedisConnectionPoolService``
- ``RedisConfiguration``

### Storage

- ``RedisPersistDriver``

## See Also

- ``JobsRedis``


---
File: /HummingbirdRedis/RedisConnectionPoolService.md
---

# ``HummingbirdRedis/RedisConnectionPoolService``

## Overview

`RedisConnectionPoolService` is a wrapper for a redis connection pool which also conforms to `Service` from [Swift Service Lifecycle](https://github.com/swift-server/swift-service-lifecycle).

```swift
// Create a Redis Connection Pool
let redis = try RedisConnectionPoolService(
    .init(
        hostname: Self.redisHostname, 
        port: 6379,
        pool: .init(maximumConnectionCount: 32)
    ),
    logger: Logger(label: "Redis")
)
// Call Redis function. Currently there are no async/await versions 
// of the functions so have to call `get` to await for EventLoopFuture result
try await redis.set("Test", to: "hello").get()
```

## Service Lifecycle

Given `RedisConnectionPoolService` conforms to `Service` you can have its lifecycle managed by either adding it to the Hummingbird `ServiceGroup` using ``/Hummingbird/Application/addServices(_:)`` from ``/Hummingbird/Application`` or adding it to an independently managed `ServiceGroup`.



---
File: /HummingbirdRouter/HummingbirdRouter.md
---

# ``HummingbirdRouter``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Alternative result builder based router for Hummingbird. 

## Overview

HummingbirdRouter provides an alternative to the standard trie based router that is in the Hummingbird module. ``/HummingbirdRouter/RouterBuilder`` uses a result builder to construct your router.

```swift
let router = RouterBuilder(context: BasicRouterRequestContext.self) {
    CORSMiddleware()
    Route(.get, "health") { _,_ in
        HTTPResponse.Status.ok
    }
    RouteGroup("user") {
        BasicAuthenticationMiddleware()
        Route(.post, "login") { request, context in
            ...
        }
    }
}
```

## Topics

### RouterBuilder

- ``/HummingbirdRouter/RouterBuilder``
- ``/HummingbirdRouter/RouterController``

### Request Context

- ``/HummingbirdRouter/RouterRequestContext``
- ``/HummingbirdRouter/BasicRouterRequestContext``
- ``/HummingbirdRouter/RouterBuilderContext``

### Result Builder

- ``/HummingbirdRouter/RouterBuilder``
- ``/HummingbirdRouter/RouteGroup``
- ``/HummingbirdRouter/Route``
- ``/HummingbirdRouter/Get(_:builder:)``
- ``/HummingbirdRouter/Get(_:handler:)``
- ``/HummingbirdRouter/Head(_:builder:)``
- ``/HummingbirdRouter/Head(_:handler:)``
- ``/HummingbirdRouter/Put(_:builder:)``
- ``/HummingbirdRouter/Put(_:handler:)``
- ``/HummingbirdRouter/Post(_:builder:)``
- ``/HummingbirdRouter/Post(_:handler:)``
- ``/HummingbirdRouter/Patch(_:builder:)``
- ``/HummingbirdRouter/Patch(_:handler:)``
- ``/HummingbirdRouter/Delete(_:builder:)``
- ``/HummingbirdRouter/Delete(_:handler:)``
- ``/HummingbirdRouter/Handle``

## See Also

- ``Hummingbird``



---
File: /HummingbirdRouter/RouterBuilderGuide.md
---

# Result Builder Router

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Building your router using a result builder. 

## Overview

`HummingbirdRouter` provides an alternative to the standard trie based ``Hummingbird/Router`` that is in the Hummingbird module. ``/HummingbirdRouter/RouterBuilder`` uses a result builder to construct your router.

```swift
let router = RouterBuilder(context: BasicRouterRequestContext.self) {
    CORSMiddleware()
    Route(.get, "health") { _,_ in
        HTTPResponse.Status.ok
    }
    RouteGroup("user") {
        BasicAuthenticationMiddleware()
        Route(.post, "login") { request, context in
            ...
        }
    }
}
```

## RequestContext

To be able to use the result builder router you need to provide a ``RequestContext`` that conforms to ``HummingbirdRouter/RouterRequestContext``. This contains an additional support struct ``HummingbirdRouter/RouterBuilderContext`` required by the result builder.

```swift
struct MyRequestContext: RouterRequestContext {
    public var routerContext: RouterBuilderContext
    public var coreContext: CoreRequestContextStorage

    public init(source: Source) {
        self.coreContext = .init(source: source)
        self.routerContext = .init()
    }
}
```

## Common Route Verbs

The common HTTP verbs: GET, PUT, POST, PATCH, HEAD, DELETE, have their own shortcut functions.

```swift
Route(.get, "health") { _,_ in
    HTTPResponse.Status.ok
}
```
can be written as
```swift
Get("health") { _,_ in
    HTTPResponse.Status.ok
}
```

## Route middleware

Routes can be initialised with their own result builder as long as they end with a route ``/HummingbirdRouter/Handle`` function that returns the response. This allows us to apply middleware to individual routes. 

```swift
Post("login") {
    BasicAuthenticationMiddleware()
    Handle  { request, context in
        ...
    }
}
```

If you are not adding the handler inline you can add the function reference without the ``/HummingbirdRouter/Handle``.  

```swift
@Sendable func processLogin(request: Request, context: MyContext) async throws -> Response {
    // process login
}
RouterBuilder(context: BasicRouterRequestContext.self) {
    ...
    Post("login") {
        BasicAuthenticationMiddleware()
        processLogin
    }
}
```

## RequestContext transformation

You can transform the ``/Hummingbird/RequestContext`` to a different type for a group of routes using ``/HummingbirdRouter/RouteGroup/init(_:context:builder:)``. When you define the `RequestContext` type you are converting to you need to define how you initialize it from the original `RequestContext`.

```swift
struct MyNewRequestContext: ChildRequestContext {
    typealias ParentContext = BasicRouterRequestContext
    init(context: ParentContext) {
        self.coreContext = context.coreContext
        ...
    }
}
```
Once you have defined how to perform the transform from your original `RequestContext` the conversion is added as follows

```swift
let router = RouterBuilder(context: BasicRouterRequestContext.self) {
    RouteGroup("user", context: MyNewRequestContext.self) {
        BasicAuthenticationMiddleware()
        Route(.post, "login") { request, context in
            ...
        }
    }
}
```

### Controllers

It is common practice to group routes into controller types that perform operations on a common type eg user management, CRUD operations for an asset type. By conforming your controller type to ``HummingbirdRouter/RouterController`` you can add the contained routes directly into your router eg

```swift
struct TodoController<Context: RouterRequestContext>: RouterController {
    var body: some RouterMiddleware<Context> {
        RouteGroup("todos") {
            Put(handler: self.put)
            Get(handler: self.get)
            Patch(handler: self.update)
            Delete(handler: self.delete)
        }
    }
}
let router = RouterBuilder(context: BasicRouterRequestContext.self) {
    TodoController()
}
```

### Differences from trie router

There is one subtle difference between the result builder based `RouterBuilder` and the more traditional trie based `Router` that comes with `Hummingbird` and this is related to how middleware are processed in groups. 

With the trie based `Router` a request is matched against an endpoint and then only runs the middleware applied to that endpoint. 

With the result builder a request is processed by each element of the router result builder until it hits a route that matches its URI and method. If it hits a ``/HummingbirdRouter/RouteGroup`` and this matches the current request uri path component then the request (with matched URI path components dropped) will be processed by the children of the `RouteGroup` including its middleware. The request path matching and middleware processing is done at the same time which means middleware only needs its parent `RouteGroup` paths to be matched for it to run.



---
File: /HummingbirdTesting/HummingbirdTesting.md
---

# ``HummingbirdTesting``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Test framework for Hummingbird.

## Overview

Provides methods for easy setup of unit tests using either the XCTest or Swift Testing frameworks. 

### Usage

Setup your server and run requests to the routes you want to test.

```swift
let router = Router()
router.get("test") { _ in
    return "testing"
}
let app = Application(router: router)
try await app.test(.router) { client in
    try await client.execute(uri: "test", method: .GET) { response in
        #expect(response.status == .ok)
        #expect(String(buffer: response.body) == "testing")
    }
}
```

## Topics

### Test Setup

- ``TestingSetup``
- ``TestHTTPScheme``
- ``/Hummingbird/ApplicationProtocol/test(_:_:)``

## See Also

- ``Hummingbird``





---
File: /HummingbirdTLS/HummingbirdTLS.md
---

# ``HummingbirdTLS``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Add TLS support to Hummingbird server.

## Overview

HummingbirdTLS is bundled with Hummingbird, but is not enabled by default. To enable TLS support, you need to add the target dependency to your target:

```sh
swift package add-target-dependency HummingbirdTLS <MyApp> --package hummingbird
```

Make sure to replace `<MyApp>` with the name of your App's target.

HummingbirdTLS provides TLS protocol support via ``TLSChannel``. You can add this to your application using ``HummingbirdCore/HTTPServerBuilder/tls(_:tlsConfiguration:)``.

```swift
// Load certificates and private key to construct server TLS configuration
let certificateChain = try NIOSSLCertificate.fromPEMFile(arguments.certificateChain)
let privateKey = try NIOSSLPrivateKey(file: arguments.privateKey, format: .pem)
let tlsConfiguration = TLSConfiguration.makeServerConfiguration(
    certificateChain: certificateChain.map { .certificate($0) },
    privateKey: .privateKey(privateKey)
)

let router = Router()
let app = Application(
    router: router,
    server: .tls(.http1(), tlsConfiguration: tlsConfiguration)
)
```

The function `tls` can be used to wrap another protocol. In the example above we use it to wrap HTTP1 server, and you can also wrap a WebSocket Supporting HTTP/1 server.

## Topics

### Server

- ``/HummingbirdCore/HTTPServerBuilder/tls(_:tlsConfiguration:)``
- ``/HummingbirdCore/HTTPServerBuilder/tls(_:configuration:)``
- ``TLSChannel``

## See Also

- ``Hummingbird``
- ``HummingbirdCore``
- ``HummingbirdHTTP2``
- ``HummingbirdWebSocket``



---
File: /HummingbirdWebSocket/HummingbirdWebSocket.md
---

# ``HummingbirdWebSocket``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Adds support for upgrading HTTP connections to WebSocket. 

## Overview

WebSockets is a protocol providing simultaneous two-way communication channels over a single TCP connection. Unlike HTTP where client requests are paired with a server response, WebSockets allow for communication in both directions asynchronously, for a prolonged period of time.

It is designed to work over the HTTP ports 80 and 443 via an upgrade process where an initial HTTP request is sent before the connection is upgraded to a WebSocket connection.

HummingbirdWebSocket allows you to implement an HTTP1 server with WebSocket upgrade. HummingbirdWebSocket passes all the tests in the [Autobahn test suite](https://github.com/crossbario/autobahn-testsuite), supporting both compression and TLS.

To add `HummingbirdWebSocket` to your project, run the following command in your Terminal:

```sh
# From the root directory of your project
# Where Package.swift is located

# Add the package to your dependencies
swift package add-dependency https://github.com/hummingbird-project/hummingbird-websocket.git --from 2.2.0

# Add the target dependency to your target
swift package add-target-dependency HummingbirdWebSocket <MyApp> --package hummingbird-websocket
```

Make sure to replace `<MyApp>` with the name of your App's target.

To integrate `HummingbirdWebSocket` into your project, you need to specify WebSocket support in your `Application`'s configuration:

```swift
import Hummingbird
import HummingbirdWebSocket

let app = Application(
    router: router,
    server: .http1WebSocketUpgrade { request, channel, logger in
        // upgrade if request URI is "/ws"
        guard request.uri == "/ws" else { return .dontUpgrade }
        // The upgrade response includes the headers to include in the response and 
        // the WebSocket handler
        return .upgrade([:]) { inbound, outbound, context in
            // Send "Hello" to the client
            try await outbound.write(.text("Hello"))
            // Ending this function automatically closes the connection
        }
    }
)
```

Get started with the WebSockets here: <doc:WebSocketServerUpgrade>

## Topics

### Configuration

### Server

- ``/HummingbirdCore/HTTPServerBuilder/http1WebSocketUpgrade(configuration:additionalChannelHandlers:shouldUpgrade:)-3n8zf``
- ``/HummingbirdCore/HTTPServerBuilder/http1WebSocketUpgrade(configuration:additionalChannelHandlers:shouldUpgrade:)-6siva``
- ``/HummingbirdCore/HTTPServerBuilder/http1WebSocketUpgrade(webSocketRouter:configuration:additionalChannelHandlers:)``
- ``HTTP1WebSocketUpgradeChannel``
- ``WebSocketServerConfiguration``
- ``/WSCore/AutoPingSetup``
- ``ShouldUpgradeResult``

### Handler

- ``/WSCore/WebSocketDataHandler``
- ``/WSCore/WebSocketInboundStream``
- ``/WSCore/WebSocketOutboundWriter``
- ``/WSCore/WebSocketDataFrame``
- ``/WSCore/WebSocketContext``

### Messages

- ``/WSCore/WebSocketMessage``
- ``/WSCore/WebSocketInboundMessageStream``

### Router

- ``WebSocketRequestContext``
- ``BasicWebSocketRequestContext``
- ``WebSocketRouterContext``
- ``WebSocketHandlerReference``
- ``WebSocketUpgradeMiddleware``
- ``RouterShouldUpgrade``

### Extensions

- ``/WSCore/WebSocketExtension``
- ``/WSCore/WebSocketExtensionBuilder``
- ``/WSCore/WebSocketExtensionContext``
- ``/WSCore/WebSocketExtensionHTTPParameters``
- ``/WSCore/WebSocketExtensionFactory``

## See Also

- ``/WSCompression``
- ``HummingbirdWSTesting``


---
File: /HummingbirdWebSocket/WebSocketServerUpgrade.md
---

# WebSocket Server Upgrade

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Support for upgrading HTTP1 connections to WebSocket.

## Overview

Before a HTTP connection can be upgraded to a WebSocket connection a server must process an initial upgrade request and respond with a switching protocols response. HummingbirdWebSocket provides a server child channel setup that implements this for you with entry points to decide whether the upgrade should occur and then how to handle the upgraded WebSocket connection.

## Setup

You can access this by setting the `server` parameter in `Application.init()` to ``/HummingbirdCore/HTTPServerBuilder/http1WebSocketUpgrade(configuration:additionalChannelHandlers:shouldUpgrade:)-3n8zf``. This is initialized with a closure that returns either ``/HummingbirdWebSocket/ShouldUpgradeResult/dontUpgrade`` to not perform the WebSocket upgrade or ``/HummingbirdWebSocket/ShouldUpgradeResult/upgrade(_:_:)`` along with the closure handling the WebSocket connection.

```swift
let app = Application(
    router: router,
    server: .http1WebSocketUpgrade { request, channel, logger in
        // upgrade if request URI is "/ws"
        guard request.uri == "/ws" else { return .dontUpgrade }
        // The upgrade response includes the headers to include in the response and 
        // the WebSocket handler
        return .upgrade([:]) { inbound, outbound, context in
            for try await frame in inbound {
                // send "Received" for every frame we receive
                try await outbound.write(.text("Received"))
            }
        }
    }
)
```

Alternatively you can provide a ``Hummingbird/Router`` using a ``Hummingbird/RequestContext`` that conforms to ``HummingbirdWebSocket/WebSocketRequestContext``. The router can be the same router as you use for your HTTP requests, but it is preferable to use a separate router. Using a router means you can add middleware to process the initial upgrade request before it is handled eg for authenticating the request. 

```swift
// Setup WebSocket router
let wsRouter = Router(context: BasicWebSocketRequestContext.self)
// add middleware
wsRouter.middlewares.add(LogRequestsMiddleware())
wsRouter.middlewares.add(BasicAuthenticator())
// An upgrade only occurs if a WebSocket path is matched
wsRouter.ws("/ws") { request, context in
    // allow upgrade
    .upgrade([:])
} onUpgrade: { inbound, outbound, context in
    for try await frame in inbound {
        // send "Received" for every frame we receive
        try await outbound.write(.text("Received"))
    }
}
let app = Application(
    router: router,
    server: .http1WebSocketUpgrade(webSocketRouter: wsRouter)
)
```

## WebSocket Handler

The WebSocket handle function has three parameters: an inbound sequence of WebSocket frames ( ``/WSCore/WebSocketInboundStream``), an outbound WebSocket frame writer (``/WSCore/WebSocketOutboundWriter``) and a context parameter. The WebSocket is kept open as long as you don't leave this function. PING, PONG and CLOSE frames are managed internally. As soon as you leave this function it will perform the CLOSE handshake. If you want to send a regular PING keep-alive you can control that via the WebSocket configuration. By default servers send a PING every 30 seconds. 

Below is a simple input and response style connection a frame is read from the inbound stream, processed and then a response is written back. If the connection is closed the inbound stream will end and we exit the function.

```swift
wsRouter.ws("/ws") { inbound, outbound, context in
    for try await frame in inbound {
        let response = await process(frame)
        try await outbound.write(response)
    }
}
```

If the reading and writing from your WebSocket connection are asynchronous then you can use a structured `TaskGroup`.

```swift
wsRouter.ws("/ws") { inbound, outbound, context in
    try await withThrowingTaskGroup(of: Void.self) { group in
        group.addTask {
            for try await frame in inbound {
                await process(frame)
            }
        }
        group.addTask {
            for await frame in outboundFrameSource {
                try await outbound.write(frame)
            }
        }
        try await group.next()
        // once one task has finished, cancel the other
        group.cancelAll()
    }
}
```
You should not use unstructured Tasks to manage your WebSockets. If you use an unstructured Task you increase the likelyhood of processing a WebSocket connection that has already been closed.

### Frames and messages

A WebSocket message can be split across multiple WebSocket frames. The last frame indicated by the `FIN` flag being set to true. If you want to work with messages instead of frames you can convert the inbound stream of frames to a stream of messages using ``/WSCore/WebSocketInboundStream/messages(maxSize:)``.

```swift
wsRouter.ws("/ws") { inbound, outbound, context in
    // We have set the maximum size of a message to be 1MB. If we don't set
    // a maximum size a client could keep sending us frames until we ran 
    // out of memory.
    for try await message in inbound.messages(maxSize: 1024*1024) {
        let response = await process(message)
        try await outbound.write(response)
    }
}
```

### WebSocket Context

The context that is passed to the WebSocket handler along with the inbound stream and outbound writer is different depending on how you setup your WebSocket connection. In most cases the context only holds a `Logger` for logging output. 

But if the WebSocket was setup with a router, then the context also includes the ``/HummingbirdCore/Request`` that initiated the WebSocket upgrade and the ``/Hummingbird/RequestContext`` from that same call. With this you can configure your WebSocket connection based on details from the initial request. Below we are using a query parameter to add a named WebSocket to a connection manager

```swift
wsRouter.ws("chat") { request, _ in
    // only allow upgrade if username query parameter exists
    guard request.uri.queryParameters["username"] != nil else {
        return .dontUpgrade
    }
    return .upgrade([:])
} onUpgrade: { inbound, outbound, context in
    // only allow upgrade to continue if username query parameter exists
    guard let name = context.request.uri.queryParameters["username"] else { return }
    await connectionManager.manageUser(name: String(name), inbound: inbound, outbound: outbound)
}
```

Alternatively you could use the `RequestContext` to extract authentication data to get the user's name.

## See Also

- ``/WSCore/WebSocketInboundStream``
- ``/WSCore/WebSocketOutboundWriter``



---
File: /HummingbirdWSTesting/HummingbirdWSTesting.md
---

# ``HummingbirdWSTesting``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Testing framework for WebSockets

## Overview

Integrates with the Hummingbird test framework ``HummingbirdTesting``.

```swift
let router = Router(context: BasicWebSocketRequestContext.self)
router.ws("/ws") { _, outbound, _ in
    try await outbound.write(.text("Hello"))
}
let application = Application(
    router: router,
    server: .http1WebSocketUpgrade(webSocketRouter: router)
)
_ = try await application.test(.live) { client in
    try await client.ws("/ws") { inbound, _, _ in
        var inboundIterator = inbound.messages(maxSize: .max).makeAsyncIterator()
        let msg = try await inboundIterator.next()
        XCTAssertEqual(msg, .text("Hello"))
    }
}
```

WebSocket testing requires a live server so it only works with the `.live` and `.ahc` test frameworks.

## Topics

### Testing

- ``HummingbirdTesting/TestClientProtocol/ws(_:configuration:logger:handler:)``

## See Also

- ``Hummingbird``
- ``HummingbirdWebSocket``
- ``WSClient``



---
File: /Jobs/JobDefinition.md
---

# ``/Jobs/JobDefinition``

Groups job parameters and process in one type.

```swift
struct SendEmailJobParameters: JobParameters {
    static let jobID = "SendEmail"
    let to: String
    let subject: String
    let body: String
}

let job = JobDefinition(parameters: SendEmailJobParameters.self) { parameters, context in
    try await myEmailService.sendEmail(to: parameters.to, subject: parameters.subject, body: parameters.body)
}

jobQueue.registerJob(job)
```


---
File: /Jobs/JobQueueDriver.md
---

# ``/Jobs/JobQueueDriver``

@Metadata {
    @DocumentationExtension(mergeBehavior: override)
}
Protocol for job queue driver

## Overview

Defines the requirements for job queue implementation.

## Topics

### Associated Types

- ``JobID``

### Lifecycle

- ``onInit()``
- ``stop()``
- ``shutdownGracefully()``

### Jobs

- ``push(_:options:)``
- ``finished(jobID:)``
- ``failed(jobID:error:)``

### Metadata

- ``getMetadata(_:)``
- ``setMetadata(key:value:)``

### Implementations

- ``memory``
- ``redis(_:configuration:logger:)``
- ``postgres(client:migrations:configuration:logger:)``



---
File: /Jobs/Jobs.md
---

# ``Jobs``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Offload work your server would be doing to another server. 

## Overview

A Job consists of a payload and an execute method to run the job. `Jobs` provides a framework for pushing jobs onto a queue and processing them. If the driver backing up the job queue uses persistent storage then a separate server can be used to process the jobs.

## Topics

### Jobs

- ``JobDefinition``
- ``JobParameters``
- ``JobExecutionContext``

### Queues

- ``JobQueue``
- ``JobQueueOptions``
- ``JobQueueDriver``
- ``MemoryQueue``
- ``JobOptionsProtocol``

### Scheduler

- ``JobSchedule``
- ``Schedule``

### Middleware

- ``JobMiddleware``
- ``MetricsJobMiddleware``
- ``TracingJobMiddleware``
- ``JobMiddlewareBuilder``
- ``JobQueueContext``

### Error

- ``JobQueueError``

### JobQueue Drivers

- ``AnyDecodableJob``
- ``JobInstanceProtocol``
- ``JobInstanceData``
- ``JobQueueResult``
- ``JobRegistry``
- ``JobRequest``

## See Also

- ``JobsRedis``
- ``JobsPostgres``



---
File: /Jobs/JobsGuide.md
---

# Jobs

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Offload work your server would be doing to another server. 

## Overview

A Job consists of a payload and an execute method to run the job. Swift Jobs provides a framework for pushing jobs onto a queue and processing them at a later point. If the driver backing up the job queue uses persistent storage then a separate server can be used to process the jobs. The module comes with a driver that stores jobs in local memory and uses your current server to process the jobs, but there are also implementations in ``JobsRedis`` and ``JobsPostgres`` that implement the job queue using a Redis database or Postgres database. 

### Setting up a Job queue

Before you can start adding or processing jobs you need to setup a Jobs queue to push jobs onto. Below we create a job queue stored in local memory that will process four jobs concurrently.

```swift
let jobQueue = JobQueue(.memory, numWorkers: 4, logger: logger)
```

### Creating a Job

Before you can start running jobs you need to define a job. A job definition requires an identifier for the job, the job parameters and the function that runs the job. 

We use a struct conforming to ``Jobs/JobParameters`` to define the job parameters and identifier.

```swift
struct SendEmailJobParameters: JobParameters {
    /// jobName is used to create the job identifier. It should be unique
    static let jobName = "SendEmail"
    let to: String
    let subject: String
    let body: String
}
```

Then we register the job with a job queue and also provide a closure that executes the job.

```swift
jobQueue.registerJob(parameters: SendEmailJobParameters.self) { parameters, context in
    try await myEmailService.sendEmail(to: parameters.to, subject: parameters.subject, body: parameters.body)
}
```

Now your job is ready to create. Jobs can be queued up using the function `push` on `JobQueue`.

```swift
let job = SendEmailJobParameters(
    to: "joe@email.com",
    subject: "Testing Jobs",
    message: "..."
)
jobQueue.push(job)
```

### Processing Jobs

When you create a `JobQueue` the `numWorkers` parameter indicates how many jobs you want serviced concurrently by the job queue. If you want to activate these workers you need to add the job queue to your `ServiceGroup`.

```swift
let serviceGroup = ServiceGroup(
    services: [server, jobQueue],
    configuration: .init(gracefulShutdownSignals: [.sigterm, .sigint]),
    logger: logger
)
try await serviceGroup.run()
```
Or it can be added to the array of services that `Application` manages
```swift
let app = Application(...)
app.addServices(jobQueue)
```
If you want to process jobs on a separate server you will need to use a job queue driver that saves to some external storage eg ``JobsRedis/RedisJobQueue`` or ``JobsPostgres/PostgresJobQueue``.

## Job Scheduler

The Jobs framework comes with a scheduler `Service` that allows you to schedule jobs to occur at regular times. Job schedules are defined using the ``Jobs/JobSchedule`` type.

```swift
var jobSchedule = JobSchedule()
jobSchedule.addJob(BirthdayRemindersJob(), schedule: .daily(hour: 9))
jobSchedule.addJob(CleanupStaleSessionDataJob(), schedule: .weekly(day: .sunday, hour: 4))
```

To get your `JobSchedule` to schedule jobs on a `JobQueue` you need to create the scheduler `Service` and then add it to your `Application` service list or `ServiceGroup`.

```swift
var app = Application(router: router)
app.addService(jobSchedule.scheduler(on: jobQueue, named: "MyScheduler"))
```

### Schedule types

A ``Jobs/Schedule`` can be setup in a number of ways. It includes functions to trigger once every minute, hour, day, month, week day and functions to trigger on multiple minutes, hours, etc.

```swift
jobSchedule.addJob(TestJobParameters(), schedule: .hourly(minute: 30))
jobSchedule.addJob(TestJobParameters(), schedule: .yearly(month: 4, date: 1, hour: 8))
jobSchedule.addJob(TestJobParameters(), schedule: .onMinutes([0,15,30,45]))
jobSchedule.addJob(TestJobParameters(), schedule: .onDays([.saturday, .sunday], hour: 12, minute: 45))
```

If these aren't flexible enough a `Schedule` can be setup using a five value crontab format. Most crontabs are supported but combinations setting both week day and date are not supported.

```swift
jobSchedule.addJob(TestJobParameters(), schedule: .crontab("0 12 * * *")) // daily at 12 o'clock
jobSchedule.addJob(TestJobParameters(), schedule: .crontab("0 */4 * * sat,sun")) // every four hours on Saturday and Sunday
jobSchedule.addJob(TestJobParameters(), schedule: .crontab("@daily")) // crontab default, every day at midnight 
```

### Schedule accuracy

You can setup how accurate you want your scheduler to adhere to the schedule regardless of whether the scheduler is running or not. Obviously if your scheduler is not running it cannot schedule jobs. But you can use the `accuracy` parameter of a schedule to indicate what you want your scheduler to do once it comes back online after having been down. 

Setting it to `.all` will schedule a job for every trigger point it missed eg if your scheduler was down for 6 hours and you had a hourly schedule it would push a job to the JobQueue for every one of those hours missed. Setting it to `.latest` will mean it only schedules a job for last trigger point if it was missed. If you don't set the value then it will default to `.latest`.

```swift
jobSchedule.addJob(TestJobParameters(), schedule: .hourly(minute: 30), accuracy: .all)
```

## Topics

### Reference

- ``JobsPostgres``
- ``JobsRedis``

## See Also

- ``Jobs/JobParameters``
- ``Jobs/JobQueue``
- ``Jobs/JobSchedule``



---
File: /JobsPostgres/JobsPostgres.md
---

# ``JobsPostgres``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Postgres implementation for Hummingbird jobs framework

## Overview

JobsPostgres provides a Hummingbird Jobs Queue driver using [PostgresNIO](https://api.vapor.codes/postgresnio/documentation/postgresnio/) and the ``PostgresMigrations`` library.

## Setup

The Postgres job queue driver uses `PostgresClient` from `PostgresNIO` and ``PostgresMigrations/DatabaseMigrations`` from the ``PostgresMigrations`` library to perform the database migrations needed for the driver.

The Postgres job queue configuration includes two values.
- `pollTime`: This is the amount of time between the last time the queue was empty and the next time the driver starts looking for pending jobs.
- `queueName`: Name of queue used to differentiate itself from other queues.

```swift
import JobsPostgres
import PostgresNIO
import ServiceLifecycle

let postgresClient = PostgresClient(...)
let postgresMigrations = DatabaseMigrations()
let jobQueue = JobQueue(
    .postgres(
        client: postgresClient,
        migrations: postgresMigrations,
        configuration: .init(
            pollTime: .milliseconds(50),
            queueName: "MyJobQueue"
        ),
        logger: logger
    ), 
    numWorkers: 4, 
    logger: logger
)
```

The easiest way to ensure the migrations are run is to use the ``PostgresMigrations/DatabaseMigrationService`` and add that as a `Service` to your `ServiceGroup`. The job queue service will not run until the migrations have been run in either `dryRun` mode or for real.

```swift
let migrationService = DatabaseMigrationService(
    client: postgresClient,
    migrations: postgresMigrations,
    logger: logger,
    dryRun: false
)
let serviceGroup = ServiceGroup(
    configuration: .init(
        services: [postgresClient, migrationService, jobQueue],
        gracefulShutdownSignals: [.sigterm, .sigint],
        logger: jobQueue.queue.logger
    )
)
try await serviceGroup.run()
```

## Additional Features

There are features specific to the Postgres Job Queue implementation. Some of these are available in other queues and others not.

### Push Options

When pushing a job to the queue there are a couple of options you can provide. 

#### Delaying jobs

As with all queue drivers you can add a delay before a job is processed. The job will sit in the pending queue and will not be available for processing until time has passed its delay until time.

```swift
// Add TestJob to the queue, but don't process it for 2 minutes
try await jobQueue.push(TestJob(), options: .init(delayUntil: .now + 120))
```

#### Job Priority

The postgres queue allows you to give a job a priority. Jobs with higher priorities are run before jobs with lower priorities. There are five priorities `.lowest`, `.lower`, `.normal`, `.higher` and `.highest`. 

```swift
// Add BackgroundJob to the queue. It will only get processed if there are no jobs
// with a higher priority on the queue.
try await jobQueue.push(BackgroundJob(), options: .init(priority: .lowest))
```

### Cancellation

The ``JobsPostgres/PostgresJobQueue`` conforms to protocol ``Jobs/CancellableJobQueue``. This requires support for cancelling jobs that are in the pending queue. It adds one new function ``JobsPostgres/PostgresJobQueue/cancel(jobID:)``. If you supply this function with the `JobID` returned by ``JobsPostgres/PostgresJobQueue/push(_:options:)`` it will remove it from the pending queue. 

```swift
// Add TestJob to the queue and immediately cancel it
let jobID = try await jobQueue.push(TestJob(), options: .init(delayUntil: .now + 120))
try await jobQueue.cancel(jobID: jobID)
```

### Pause and Resume

The ``JobsPostgres/PostgresJobQueue`` conforms to protocol ``Jobs/ResumableJobQueue``. This requires support for pausing and resuming jobs that are in the pending queue. It adds two new functions ``JobsPostgres/PostgresJobQueue/pause(jobID:)`` and ``JobsPostgres/PostgresJobQueue/resume(jobID:)``. If you supply these function with the `JobID` returned by ``JobsPostgres/PostgresJobQueue/push(_:options:)`` you can remove from the pending queue and add them back in at a later date.

```swift
// Add TestJob to the queue and immediately remove it and then add it back to the queue
let jobID = try await jobQueue.push(TestJob(), options: .init(delayUntil: .now + 120))
try await jobQueue.pause(jobID: jobID)
try await jobQueue.resume(jobID: jobID)
```

## Topics

### Job Queue

- ``PostgresJobQueue``

## See Also

- ``Jobs``
- ``JobsRedis``
- ``Hummingbird``
- ``HummingbirdPostgres``



---
File: /JobsRedis/JobsRedis.md
---

# ``JobsRedis``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Redis implementation for Hummingbird jobs framework

## Overview

Hummingbird Jobs Queue driver using [RediStack](https://github.com/swift-server/redistack).

### Setup

Currently `RediStack` is not setup to use `ServiceLifecycle`. So to ensure clean shutdown of `RediStack` you either need to use the ``HummingbirdRedis/RedisConnectionPoolService`` that is part of ``HummingbirdRedis`` or write your own `Service` type that will manage the shutdown of a `RedisConnectionPool`.

#### Using HummingbirdRedis

If you choose to use `HummingbirdRedis` you can setup a JobQueue using `RediStack` as follows

```swift
let redisService = try RedisConnectionPoolService(
    .init(hostname: redisHost, port: 6379),
    logger: logger
)
let jobQueue = JobQueue(
    .redis(
        redisService.pool, 
        configuration: .init(
            queueKey: "MyJobQueue", 
            pollTime: .milliseconds(50)
        )
    ),
    numWorkers: 10,
    logger: logger
)
let serviceGroup = ServiceGroup(
    configuration: .init(
        services: [redisService, jobQueue],
        gracefulShutdownSignals: [.sigterm, .sigint],
        logger: logger
    )
)
try await serviceGroup.run()
```
The Redis job queue configuration includes two values.
- `queueKey`: Prefix to all the Redis keys used to store queues.
- `pollTime`: This is the amount of time between the last time the queue was empty and the next time the driver starts looking for pending jobs.

#### Write RedisConnectionPool Service

Alternatively you can write your own `Service` to manage the lifecycle of the `RedisConnectionPool`. This basically keeps a reference to the `RedisConnectionPool` and waits for graceful shutdown. At graceful shutdown it will close the connection pool. Unfortunately `RedisConnectionPool` is not `Sendable` so we either have to add an `@unchecked Sendable` to `RedisConnectionPoolService` or import `RediStack` using `@preconcurrency`.

```swift
struct RedisConnectionPoolService: Service, @unchecked Sendable {
    let pool: RedisConnectionPool

    public func run() async throws {
        // Wait for graceful shutdown and ignore cancellation error
        try? await gracefulShutdown()
        // close connection pool
        let promise = self.pool.eventLoop.makePromise(of: Void.self)
        self.pool.close(promise: promise)
        return try await promise.futureResult.get()
    }
}
```

## Additional Features

There are features specific to the Redis Job Queue implementation.

### Push Options

When pushing a job to the queue there are a number of options you can provide. 

#### Delaying jobs

As with all queue drivers you can add a delay before a job is processed. The job will sit in the pending queue and will not be available for processing until time has passed its delay until time.

```swift
// Add TestJob to the queue, but don't process it for 2 minutes
try await jobQueue.push(TestJob(), options: .init(delayUntil: .now + 120))
```

### Cancellation

The ``JobsRedis/RedisJobQueue`` conforms to protocol ``Jobs/CancellableJobQueue``. This requires support for cancelling jobs that are in the pending queue. It adds one new function ``JobsRedis/RedisJobQueue/cancel(jobID:)``. If you supply this function with the `JobID` returned by ``JobsRedis/RedisJobQueue/push(_:options:)`` it will remove it from the pending queue. 

```swift
// Add TestJob to the queue and immediately cancel it
let jobID = try await jobQueue.push(TestJob(), options: .init(delayUntil: .now + 120))
try await jobQueue.cancel(jobID: jobID)
```

### Pause and Resume

The ``JobsRedis/RedisJobQueue`` conforms to protocol ``Jobs/ResumableJobQueue``. This requires support for pausing and resuming jobs that are in the pending queue. It adds two new functions ``JobsRedis/RedisJobQueue/pause(jobID:)`` and ``JobsRedis/RedisJobQueue/resume(jobID:)``. If you supply these function with the `JobID` returned by ``JobsRedis/RedisJobQueue/push(_:options:)`` you can remove from the pending queue and add them back in at a later date.

```swift
// Add TestJob to the queue and immediately remove it and then add it back to the queue
let jobID = try await jobQueue.push(TestJob(), options: .init(delayUntil: .now + 120))
try await jobQueue.pause(jobID: jobID)
try await jobQueue.resume(jobID: jobID)
```

## Topics

### Job Queue

- ``RedisJobQueue``

## See Also

- ``Jobs``
- ``JobsPostgres``
- ``Hummingbird``



---
File: /Mustache/Mustache.md
---

# ``Mustache``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Mustache template engine. 

## Overview

Mustache is a "logic-less" templating language commonly used in web and mobile platforms. You can find out more about Mustache [here](http://mustache.github.io/mustache.5.html).

While swift-mustache has been designed to be used with the Hummingbird server framework it has no dependencies and can be used as a standalone library.

## Usage

Load your templates from the filesystem 
```swift
let library = MustacheLibrary("folder/my/templates/are/in")
```
This will look for all the files with the extension ".mustache" in the specified folder and subfolders and attempt to load them. Each file is registed with the name of the file (with subfolder, if inside a subfolder) minus the "mustache" extension.

Render an object with a template 
```swift
let output = library.render(object, withTemplate: "myTemplate")
```
`Mustache` treats an object as a set of key/value pairs when rendering and will render both dictionaries and objects via `Mirror` reflection.

## Support

Mustache supports all standard Mustache tags and is fully compliant with the Mustache [spec](https://github.com/mustache/spec) with the exception of the Lambda support.  

## Topics

### Template Library

- ``MustacheLibrary``
- ``MustacheTemplate``

### Rendering

- ``MustacheCustomRenderable``
- ``MustacheParent``
- ``MustacheTransformable``
- ``MustacheLambda``

### Content Types

- ``MustacheContentType``
- ``MustacheContentTypes``



---
File: /Mustache/MustacheFeatures.md
---

# Mustache Features

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

An overview of the features of swift-mustache.

## Lambdas

The library provides support for mustache lambdas via the type `MustacheLambda`. 

### Rendering variables

The mustache manual section for mustache lambdas when rendered as variables states. 

> Manual: If any value found during the lookup is a callable object, such as a function or lambda, this object will be invoked with zero arguments. The value that is returned is then used instead of the callable object itself.
>
> An optional part of the specification states that if the final key in the name is a lambda that returns a string, then that string should be rendered as a Mustache template before interpolation. It will be rendered using the default delimiters (see Set Delimiter below) against the current context.

Swift Mustache supports both parts of the specification of lambdas when rendered as variables. Instead of a callable object, swift-mustache requires the type to be a `MustacheLambda` initialized with a closure that has no parameters. 

> If the lambda is rendered as a variable and you supply a closure that accepts a `String` then the supplied `String` is empty.

Below we have a couple of examples of rendering mustache lambdas as variables. One returning a tuple and one returning a `String` which is then parsed as a template. If we have the following object
```swift
let object: [String: Any] = [
    "year": 1970,
    "month": 1,
    "day": 1,
    "time": MustacheLambda {
        (hour: 0, minute: 0, second: 0)
    },
    "today": MustacheLambda { _ in
        return "{{year}}-{{month}}-{{day}}"
    },
]
```
and the following mustache template  
```swift
let mustache = """
    * {{time.hour}}
    * {{today}}
    """
let template = try MustacheTemplate(string: mustache)
```
then `template.render(object)` will output 
```
* 0
* 1970-1-1
```

In this example the first part of the template calls lambda `time` and then uses `hour` from the return object. In the second part the `today` lambda returns a string which is then parsed as mustache and renders the year.

### Rendering sections

The mustache manual section for mustache lambdas when rendered as a section states.

> Manual: When any value found during the lookup is a callable object, such as a function or lambda, the object will be invoked and passed the block of text. The text passed is the literal block, unrendered. {{tags}} will not have been expanded.
>
> An optional part of the specification states that if the final key in the name is a lambda that returns a string, then that string replaces the content of the section. It will be rendered using the same delimiters as the original section content. In this way you can implement filters or caching.

Swift Mustache does not support the part of the specification of lambdas when rendered as sections pertaining to delimiters. As with variables, instead of a callable object, swift-mustache requires the type to be a `MustacheLambda` which can be initialized with either a closure that accepts a String or nothing. When the lambda is rendered as a section the supplied `String` is the contents of the section.

If we have an object as follows
```swift
let object: [String: Any] = [
  "name": "Willy",
  "wrapped": MustacheLambda { text in
    return "<b>" + text + "</b>"
  }
]
```
and the following mustache template  
```swift
let mustache = "{{#wrapped}}{{name}} is awesome.{{/wrapped}}"
let template = try MustacheTemplate(string: mustache)
```
Then `template.render(object)` will output 
```
<b>Willy is awesome.</b>
```

Here when the `wrapped` section is rendered the text inside the section is passed to the `wrapped` lambda and the resulting text passed back is parsed as a new template.

## Template inheritance and parents

Template inheritance allows you to override elements of an included partial. It allows you to create a base page template, or parent as it is called in the mustache manual, and override elements of it with your page content. A parent that includes overriding elements is indicated with a `{{<parent}}`. Note this is different from the normal partial reference which uses `>`. This is a section tag so needs a ending tag as well. Inside the section the tagged sections to override are added using the syntax `{{$tag}}contents{{/tag}}`.

If your template is as follows
```
{{! mypage.mustache }}
{{<base}}
{{$head}}<title>My page title</title>{{/head}}
{{$body}}Hello world{{/body}}
{{/base}}
```
And you partial is as follows
```
{{! base.mustache }}
<html>
<head>
{{$head}}{{/head}}
</head>
<body>
{{$body}}Default text{{/body}}
</body>
</html>
```
You would get the following output when rendering `mypage.mustache`.
```
<html>
<head>
<title>My page title</title>
</head>
<body>
Hello world
</body>
```
Note the `{{$head}}` section in `base.mustache` is replaced with the `{{$head}}` section included inside the `{{<base}}` partial reference from `mypage.mustache`. The same occurs with the `{{$body}}` section. In that case though a default value is supplied for the situation where a `{{$body}}` section is not supplied. 

## Pragmas/Configuration variables

The syntax `{{% var: value}}` can be used to set template rendering configuration variables specific to Hummingbird Mustache. The only variable you can set at the moment is `CONTENT_TYPE`. This can be set to either to `HTML` or `TEXT` and defines how variables are escaped. A content type of `TEXT` means no variables are escaped and a content type of `HTML` will do HTML escaping of the rendered text. The content type defaults to `HTML`.

Given input object `<>`, template 
```
{{%CONTENT_TYPE: HTML}}{{.}}
```
will render as `&lt;&gt;` and 

```
{{%CONTENT_TYPE: TEXT}}{{.}}
```
 will render as `<>`.

## Transforms

Transforms are specific to this implementation of Mustache. They are similar to Lambdas but instead of generating rendered text they allow you to transform an object into another. Transforms are formatted as a function call inside a tag eg
```
{{uppercase(string)}}
```
They can be applied to variable, section and inverted section tags. If you apply them to a section or inverted section tag the transform name should be included in the end section tag as well eg
```
{{#sorted(array)}}{{.}}{{/sorted(array)}}
```
The library comes with a series of transforms for the Swift standard objects.
- String/Substring
  - capitalized: Return string with first letter capitalized
  - lowercase: Return lowercased version of string
  - uppercase: Return uppercased version of string
  - reversed: Reverse string
- Int/UInt/Int8/Int16...
  - equalzero: Returns if equal to zero
  - plusone: Add one to integer
  - minusone: Subtract one from integer
  - odd: return if integer is odd
  - even: return if integer is even
- Array
  - first: Return first element of array
  - last: Return last element of array
  - count: Return number of elements in array
  - empty: Returns if array is empty
  - reversed: Reverse array
  - sorted: If the elements of the array are comparable sort them
- Dictionary
  - count: Return number of elements in dictionary
  - empty: Returns if dictionary is empty
  - enumerated: Return dictionary as array of key, value pairs
  - sorted: If the keys are comparable return as array of key, value pairs sorted by key

If a transform is applied to an object that doesn't recognise it then `nil` is returned.

### Sequence context transforms

Sequence context transforms are transforms applied to the current position in the sequence. They are formatted as a function that takes no parameter eg
```
{{#array}}{{.}}{{^last()}}, {{/last()}}{{/array}}
```
This will render an array as a comma separated list. The inverted section of the `last()` transform ensures we don't add a comma after the last element.

The following sequence context transforms are available
- first: Is this the first element of the sequence
- last: Is this the last element of the sequence
- index: Returns the index of the element within the sequence
- odd: Returns if the index of the element is odd
- even: Returns if the index of the element is even

### Custom transforms

You can add transforms to your own objects. Conform the object to `MustacheTransformable` and provide an implementation of the function `transform`. eg 
```swift 
struct Object: MustacheTransformable {
    let either: Bool
    let or: Bool
    
    func transform(_ name: String) -> Any? {
        switch name {
        case "eitherOr":
            return either || or
        default:
            break
        }
        return nil
    }
}
```
When we render an instance of this object with `either` or `or` set to true using the following template it will render "Success".
```
{{#eitherOr(object)}}Success{{/eitherOr(object)}}
```
With this we have got around the fact it is not possible to do logical OR statements in Mustache.

## See Also

- ``Mustache/MustacheTemplate``
- ``Mustache/MustacheLibrary``



---
File: /Mustache/MustacheSyntax.md
---

# Mustache Syntax

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Overview of Mustache Syntax

## Overview

Mustache is a "logic-less" templating engine. The core language has no flow control statements. Instead it has tags that can be replaced with a value, nothing or a series of values. Below we document all the standard tags

## Context

Mustache renders a template with a context stack. A context is a list of key/value pairs. These can be represented by either a `Dictionary` or the reflection information from `Mirror`. For example the following two objects will render in the same way
```swift
let object = ["name": "John Smith", "age": 68]
```
```swift
struct Person {
    let name: String
    let age: Int
}
let object = Person(name: "John Smith", age: 68)
```

Initially the stack will consist of the root context object you want to render. When we enter a section tag we push the associated value onto the context stack and when we leave the section we pop that value back off the stack.

## Tags

All tags are surrounded by a double curly bracket `{{}}`. When a tag has a reference to a key, the key will be searched for from the context at the top of the context stack and the associated value will be output. If the key cannot be found then the next context down will be searched and so on until either a key is found or we have reached the bottom of the stack. If no key is found the output for that value is `nil`. 

A tag can be used to reference a child value from the associated value of a key by using dot notation in a similar manner to Swift. eg in `{{main.sub}}` the first context is searched for the  `main` key. If a value is found, that value is used as a context and the key `sub` is used to search within that context and so on. 

If you want to only search for values in the context at the top of the stack then prefix the variable name with a "." eg `{{.key}}`

## Tag types

- `{{key}}`: Render value associated with `key` as text. By default this is HTML escaped. A `nil` value is rendered as an empty string.
- `{{{name}}}`: Acts the same as `{{name}}` except the resultant text is not HTML escaped. You can also use `{{&name}}` to avoid HTML escaping.
- `{{#section}}`: Section render blocks either render text once or multiple times depending on the value of the key in the current context. A section begins with `{{#section}}` and end with `{{/section}}`. If the key represents a `Bool` value it will only render if it is true. If the key represents an `Optional` it will only render if the object is non-nil. If the key represents an `Array` it will then render the internals of the section multiple times, once for each element of the `Array`. Otherwise it will render with the selected value pushed onto the top of the context stack.
- `{{^section}}`: An inverted section does the opposite of a section. If the key represents a `Bool` value it will render if it is false. If the key represents an `Optional` it will render if it is `nil`. If the key represents a `Array` it will render if the `Array` is empty.
- `{{! comment }}`: This is a comment tag and is ignored.
- `{{>partial}}`: A partial tag renders another mustache file, with the current context stack. In Swift Mustache partial tags only work for templates that are a part of a library and the tag is the name of the referenced file without the ".mustache" extension.
- `{{*>dynamic}}`: Is a partial that can be dynamically loaded.
- `{{<parent}}`: A parent is similar to a partial but allows for the user to override sections of the include file. A parent tag is a section tag so needs to end with a `{{/parent}}` tag.
- `{{$}}`: A block is a section of a parent that can be overriden. If this is found inside a parent section then it is the text that will replace the overriden block. 
- `{{=<% %>=}}`: The set delimiter tag allows you to change from using the double curly brackets as tag delimiters. In the example the delimiters have been changed to `<% %>` but you can change them to whatever you like.

You can find out more about the standard Mustache tags in the [Mustache Manual](https://mustache.github.io/mustache.5.html).



---
File: /PostgresMigrations/MigrationsGuide.md
---

# Postgres Migrations

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Managing database structure changes.

## Overview

Database migrations are a controlled set of incremental changes applied to a database. You can use a migration list to transition a database from one state to a new desired state. A migration can involve creating/deleting tables, adding/removing columns, changing types and constraints. The ``PostgresMigrations`` library that comes with HummingbirdPostgres provides support for setting up your own database migrations. 

> Note: If you are using Fluent then you should use the migration support that comes with Fluent.

Each migration includs an `apply` method that applies the change and a `revert` method that reverts the change.

```swift
struct CreateMyTableMigration: DatabaseMigration {
    func apply(connection: PostgresConnection, logger: Logger) async throws {
        try await connection.query(
            """
            CREATE TABLE my_table (
                "id" text PRIMARY KEY,
                "name" text NOT NULL
            )
            """,
            logger: logger
        )
    }

    func revert(connection: PostgresConnection, logger: Logger) async throws {
        try await connection.query(
            "DROP TABLE my_table",
            logger: logger
        )
    }
}
```

As an individual migration can be dependent on the results of a previous migration the order they are applied has to be the same everytime. Migrations allow for database changes to be repeatable, shared and testable without loss of data.

### Adding migrations

You need to create a ``/PostgresMigrations/DatabaseMigrations`` object to store your migrations in. Only create one of these, otherwise you could confuse your database about what migrations need applied. Adding a migration is as simple as calling `add`.

```swift
import HummingbirdPostgres

let migrations = DatabaseMigrations()
await migrations.add(CreateMyTableMigration())
```

### Applying migrations

As you need an active `PostgresClient` to apply migrations you need to run the migrate once you have called `PostgresClient.run`. It is also preferable to have run your migrations before your server is active and accepting connections. The best way to do this is use ``Hummingbird/Application/beforeServerStarts(perform:)``.

```swift
var app = Application(router: router)
// add postgres client as a service to ensure it is active
app.addServices(postgresClient)
app.beforeServerStarts {
    try await migrations.apply(client: postgresClient, logger: logger, dryRun: true)
}
```
You will notice in the code above the parameter `dryRun` is set to true. This is because applying migrations can be a destructive process and should be a supervised. If there is a change in the migration list, with `dryRun` set to true, the `apply` function will throw an error and list the migrations it would apply or revert. At that point you can make a call on whether you want to apply those changes and run the same process again except with `dryRun` set to false.

### Reverting migrations

There are a number of situations where a migration maybe reverted. 
- The user calls ``/PostgresMigrations/DatabaseMigrations/revert(client:groups:logger:dryRun:)``. This will revert all the migrations applied to the database.
- A user removes a migration from the list. The migration still needs to be registered with the migration system as it needs to know how to revert that migration. This is done with a call to ``/PostgresMigrations/DatabaseMigrations/register(_:)``. When a migration is removed it is reverted and all subsequent migrations will be reverted and then re-applied.
- A user changes the order of migrations. This is generally a user error, but if it is intentional then the first migration affected by the order change and all subsequent migrations will be reverted and then re-applied.

### Migration groups

A migration group is a group of migrations that can be applied to a database independent of all other migrations outside that group. By default all migrations are added to the `.default` migration group. Each group is applied independently to your database. A group allows for a modular piece of code to add additional migrations without affecting the ordering of other migrations and causing deletion of data.

To create a group you need to extend `/PostgresMigrations/DatabaseMigrationsGroup` and add a new static variable for the migration group id.

```swift
extension DatabaseMigrationGroup {
    public static var myGroup: Self { .init("my_group") }
}
```

Then every migration that belongs to that group must set its group member variable

```swift
extension CreateMyTableMigration {
    var group: DatabaseMigrationGroup { .myGroup }
}
```

You should only use groups if you can guarantee the migrations inside it will always be independent of migrations outside the group. 

The persist driver that come with ``HummingbirdPostgres`` and the job queue driver from ``JobsPostgres`` both use groups to separate their migrations from any the user might add.

## See Also

- ``PostgresMigrations/DatabaseMigration``
- ``PostgresMigrations/DatabaseMigrations``



---
File: /PostgresMigrations/PostgresMigrations.md
---

# ``PostgresMigrations``

Postgres database migration service

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}
## Topics

### Migrations

- ``DatabaseMigrations``
- ``DatabaseMigration``
- ``DatabaseMigrationGroup``
- ``DatabaseMigrationError``

## See Also

- ``HummingbirdPostgres``
- ``Hummingbird``



---
File: /WSClient/WebSocketClientGuide.md
---

# WebSocket Client

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Connecting to WebSocket servers.

A WebSocket connection is only setup after an initial HTTP upgrade request has been sent. ``WSClient/WebSocketClient`` manages the process of sending the initial HTTP request and then the handling of the WebSocket once it has been upgraded.

## Setup

A WebSocket client is created with the server URL, a closure to handle the connection and optional configuration values. To connect call ``WSClient/WebSocketClient/run()``. This will exit once the WebSocket connection has closed.

```swift
let ws = WebSocketClient(url: "ws://mywebsocket/ws") { inbound, outbound, context in
    try await outbound.write(.text("Hello"))
    for try await frame in inbound {
        context.logger.info(frame)
    }
}
try await ws.run()
```

As a shortcut you can call the following which will initialize and run the WebSocket client in one function call

```swift
try await WebSocketClient.connect(url: "ws://mywebsocket/ws") { inbound, outbound, context in
    try await outbound.write(.text("Hello"))
    for try await frame in inbound {
        context.logger.info(frame)
    }
}
```

`WebSocketClient` supports unencrypted and TLS connections. These are indicated via the URL scheme: `ws` and `wss` respectively. If you provide an `NIOTSEventLoopGroup` for the `EventLoopGroup` at initialization then client will use the Network.framework to setup the WebSocket connection. 

## Handler

The handler closure works exactly like the WebSocket server handler. You are provided with a inbound sequence of frames and an outbound WebSocket frame writer. The connection will close as sooon as you exit the function. PING, PONG and CLOSE frames are all dealt with internally. If you want to send a regular PING keep-alive you can control that via the WebSocket configuration. By default clients do not send a regular PING.

More details on the WebSocket handler can be found in the <doc:WebSocketServerUpgrade#WebSocket-Handler> section of the WebSocket server upgrade guide.

## See Also

- ``/WSCore/WebSocketInboundStream``
- ``/WSCore/WebSocketOutboundWriter``



---
File: /WSClient/WSClient.md
---

# ``WSClient``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Support for connecting to WebSocket server. 

## Overview

WebSockets is a protocol providing simultaneous two-way communication channels over a single TCP connection. Unlike HTTP where client requests are paired with a server response, WebSockets allow for communication in both directions asynchronously. It is designed to work over the HTTP ports 80 and 443 via an upgrade process where an initial HTTP request is sent before the connection is upgraded to a WebSocket connection.

WSClient provides a way to connect to WebSocket servers.

## Topics

### Client

- ``WebSocketClient``
- ``WebSocketClientConfiguration``
- ``/WSCore/AutoPingSetup``
- ``/WSCore/WebSocketCloseFrame``
- ``WebSocketClientError``

### Handler

- ``/WSCore/WebSocketDataHandler``
- ``/WSCore/WebSocketInboundStream``
- ``/WSCore/WebSocketOutboundWriter``
- ``/WSCore/WebSocketDataFrame``
- ``/WSCore/WebSocketContext``

### Messages

- ``/WSCore/WebSocketMessage``
- ``/WSCore/WebSocketInboundMessageStream``

### Extensions

- ``/WSCore/WebSocketExtension``
- ``/WSCore/WebSocketExtensionBuilder``
- ``/WSCore/WebSocketExtensionHTTPParameters``
- ``/WSCore/WebSocketExtensionFactory``

## See Also

- ``WSCompression``



---
File: /WSCompression/WSCompression.md
---

# ``WSCompression``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Compression support for WebSockets

## Overview

This library provides an implementation of the WebSocket compression extension `permessage-deflate` as detailed in [RFC 7692](https://datatracker.ietf.org/doc/html/rfc7692.html). You add the extension in the configuration for either your WebSocket upgrade or WebSocket client.

```swift
let app = Application(
    router: Router(),
    server: .http1WebSocketUpgrade(
        configuration: .init(extensions: [.perMessageDeflate(minFrameSizeToCompress: 16)])
    ) { _, _, _ in
        return .upgrade([:]) { inbound, _, _ in
            var iterator = inbound.messages(maxSize: .max).makeAsyncIterator()
            let firstMessage = try await iterator.next()
            XCTAssertEqual(firstMessage, .text("Hello, testing compressed data"))
        }
    }
)
```

## Topics

### Compression extension

- ``/WSCore/WebSocketExtensionFactory/perMessageDeflate(clientMaxWindow:clientNoContextTakeover:serverMaxWindow:serverNoContextTakeover:compressionLevel:memoryLevel:maxDecompressedFrameSize:minFrameSizeToCompress:)``
- ``/WSCore/WebSocketExtensionFactory/perMessageDeflate(maxWindow:noContextTakeover:maxDecompressedFrameSize:minFrameSizeToCompress:)``

## See Also

- ``WSClient``
- ``HummingbirdWebSocket``
- ``Hummingbird``



---
File: /index.md
---

# Hummingbird Documentation

@Metadata {
    @TechnologyRoot
    @PageImage(purpose: icon, source: "logo")
}

Documentation for Hummingbird the lightweight, flexible, modern server framework.

## Hummingbird

Hummingbird is a lightweight and flexible web application framework. It provides a router for directing different endpoints to their handlers, middleware for processing requests before they reach your handlers and processing the responses returned, custom encoding/decoding of requests and responses, TLS and HTTP2.

If you're new to Hummingbird, start here: <doc:Todos>

```swift
import Hummingbird
// create router and add a single GET /hello route
let router = Router()
    .get("hello") { request, _ -> String in
        return "Hello"
    }
// create application using router
let app = Application(router: router)
// run hummingbird application
try await app.runService()
```

Below is a list of guides and tutorials to help you get started with building your own Hummingbird based web application.

## Topics

### Getting Started

- <doc:GettingStarted>
- <doc:Todos>

### Hummingbird Server

- <doc:RouterGuide>
- <doc:RequestDecoding>
- <doc:ResponseEncoding>
- <doc:RequestContexts>
- <doc:MiddlewareGuide>
- <doc:ErrorHandling>
- <doc:LoggingMetricsAndTracing>
- <doc:RouterBuilderGuide>
- <doc:ServerProtocol>
- <doc:ServiceLifecycle>
- <doc:Testing>
- <doc:PersistentData>
- <doc:MigratingToV2>

### Authentication

- <doc:AuthenticatorMiddlewareGuide>
- <doc:Sessions>
- <doc:OneTimePasswords>

### WebSockets

- <doc:WebSocketServerUpgrade>
- <doc:WebSocketClientGuide>

### Database Integration

- <doc:MigrationsGuide>
- <doc:Fluent>
- <doc:MongoKitten>

### Offloading work

- <doc:JobsGuide>

### Mustache

- <doc:MustacheSyntax>
- <doc:MustacheFeatures>

### Reference Documentation

- ``/Hummingbird``
- ``/HummingbirdCore``
- ``/HummingbirdAuth``
- ``/HummingbirdCompression``
- ``/HummingbirdFluent``
- ``/HummingbirdLambda``
- ``/HummingbirdPostgres``
- ``/HummingbirdRedis``
- ``/HummingbirdWebSocket``
- ``/Jobs``
- ``/Mustache``
- ``/WSClient``

