Directory Structure:
fix based on the sample and source code
└── ./
    ├── Sample
    │   ├── AIStream
    │   │   └── AIStreaming
    │   │       └── AIStreaming
    │   │           ├── AIStreamingApp.swift
    │   │           ├── ContentView.swift
    │   │           └── ViewModel.swift
    │   ├── AzureSignalRConsoleApp
    │   │   ├── Sources
    │   │   │   └── Sample
    │   │   │       └── main.swift
    │   │   └── Package.swift
    │   ├── ChatRoom
    │   │   └── ChatRoom
    │   │       ├── ChatRoomApp.swift
    │   │       ├── ChatViewModel.swift
    │   │       └── ContentView.swift
    │   └── ConsoleApp
    │       ├── Sources
    │       │   └── Sample
    │       │       └── main.swift
    │       └── Package.swift
    ├── Sources
    │   └── SignalRClient
    │       ├── Protocols
    │       │   ├── Msgpack
    │       │   │   ├── MsgpackCommon.swift
    │       │   │   ├── MsgpackDecoder.swift
    │       │   │   └── MsgpackEncoder.swift
    │       │   ├── BinaryMessageFormat.swift
    │       │   ├── HubMessage.swift
    │       │   ├── HubProtocol.swift
    │       │   ├── JsonHubProtocol.swift
    │       │   ├── MessagePackHubProtocol.swift
    │       │   ├── MessageType.swift
    │       │   └── TextMessageFormat.swift
    │       ├── Transport
    │       │   ├── EventSource.swift
    │       │   ├── LongPollingTransport.swift
    │       │   ├── ServerSentEventTransport.swift
    │       │   ├── Transport.swift
    │       │   └── WebSocketTransport.swift
    │       ├── AsyncLock.swift
    │       ├── AtomicState.swift
    │       ├── ConnectionProtocol.swift
    │       ├── HandshakeProtocol.swift
    │       ├── HttpClient.swift
    │       ├── HttpConnection.swift
    │       ├── HubConnection.swift
    │       ├── HubConnection+On.swift
    │       ├── HubConnection+OnResult.swift
    │       ├── HubConnectionBuilder.swift
    │       ├── InvocationBinder.swift
    │       ├── Logger.swift
    │       ├── MessageBuffer.swift
    │       ├── RetryPolicy.swift
    │       ├── SignalRError.swift
    │       ├── StatefulReconnectOptions.swift
    │       ├── StreamResult.swift
    │       ├── TaskCompletionSource.swift
    │       ├── TimeScheduler.swift
    │       ├── TransferFormat.swift
    │       ├── Utils.swift
    │       └── Version.swift
    ├── Tests
    │   ├── SignalRClientIntegrationTests
    │   │   └── IntegrationTests.swift
    │   └── SignalRClientTests
    │       ├── Msgpack
    │       │   ├── MsgpackDecoderTests.swift
    │       │   └── MsgpackEncoderTests.swift
    │       ├── AsyncLockTest.swift
    │       ├── EventSourceTests.swift
    │       ├── HandshakeProtocolTests.swift
    │       ├── HubConnection+OnTests.swift
    │       ├── HubConnectionTests.swift
    │       ├── JsonHubProtocolTests.swift
    │       ├── LoggerTests.swift
    │       ├── LongPollingTransportTests.swift
    │       ├── MessageBufferTests.swift
    │       ├── MessagePackHubProtocolTests.swift
    │       ├── ServerSentEventTransportTests.swift
    │       ├── TaskCompletionSourceTests.swift
    │       ├── TimeSchedulerTests.swift
    │       └── WebSocketTransportTests.swift
    └── Package.swift



---
File: /Sample/AIStream/AIStreaming/AIStreaming/AIStreamingApp.swift
---

//
//  AIStreamingApp.swift
//  AIStreaming
//
//  Created by Chenyang Liu on 2025/3/19.
//

import SwiftUI

@main
struct AIStreamingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}



---
File: /Sample/AIStream/AIStreaming/AIStreaming/ContentView.swift
---

import SwiftUI

struct ContentView: View {
    var body: some View {
        ChatView(viewModel: ViewModel())
    }
}

struct ChatView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var inputText: String = ""
    @State private var isShowingEntrySheet: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Group: \(viewModel.group)")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
            
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.messages) { message in
                            MessageView(message: message, selfUser: viewModel.username)
                        }
                    }
                    .padding()
                }
                .background(Color.platformBackground)
                .onChange(of: viewModel.messages) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
            }
            
            Divider()
            
            // Input Field and Send Button
            HStack {
                TextField("Type your message here... Use @gpt to invoke in a LLM model", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(8)
                
                Button("Send") {
                    sendMessage()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .padding(8)
            }
            .padding()
        }
        .sheet(isPresented: $isShowingEntrySheet) {
            UserEntryView(isPresented: $isShowingEntrySheet, viewModel: viewModel)
        }
        .frame(minWidth: 400, minHeight: 500)
    }
    
    // Scroll to the latest message
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = self.viewModel.messages.last {
            DispatchQueue.main.async {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        Task {
            viewModel.addMessage(id: UUID().uuidString, sender: viewModel.username, content: inputText)
            try await viewModel.sendMessage(message: inputText)
            inputText = ""
        }
    }
}

struct MessageView: View {
    let message: Message
    let selfUser: String
    
    var body: some View {
        HStack {
            let isSelf = message.sender == selfUser
            if isSelf {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(message.sender)
                        .font(.caption)
                        .bold()
                        .foregroundColor(.green)
                    Text(message.content)
                        .padding(8)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                }
                .frame(maxWidth: 250, alignment: .trailing)
            } else {
                VStack(alignment: .leading) {
                    Text(message.sender)
                        .font(.caption)
                        .bold()
                        .foregroundColor(.blue)
                    Text(message.content)
                        .padding(8)
                        .background(Color.platformBackground)
                        .cornerRadius(8)
                }
                .frame(maxWidth: 250, alignment: .leading)
                Spacer()
            }
        }
    }
}

struct UserEntryView: View {
    @State var username: String = ""
    @State var group: String = ""
    @Binding var isPresented: Bool
    var viewModel: ViewModel
    
    var body: some View {
            VStack {
                Text("Enter your username")
                    .font(.headline)
                    .padding()
     
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Create or Join Group", text: $group)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
     
                Button(action: {
                    if !username.isEmpty && !group.isEmpty {
                        isPresented = false
                        viewModel.username = username
                        viewModel.group = group
     
                        Task {
                            try await viewModel.setupConnection()
                        }
                    }
                }) {
                    Text("Enter")
                }
                .keyboardShortcut(.defaultAction)
                .controlSize(.regular)
                .buttonStyle(.borderedProminent)
                .frame(width: 120)
            }
            .padding()
        }
}

#Preview {
    ContentView()
}

extension Color {
    static var platformBackground : Color {
#if os(macOS)
        return Color(NSColor.windowBackgroundColor)
#else
        return Color(UIColor.systemBackground)
#endif
    }
}



---
File: /Sample/AIStream/AIStreaming/AIStreaming/ViewModel.swift
---


import SwiftUI
import SignalRClient

struct Message: Identifiable, Equatable {
    let id: String?
    let sender: String
    var content: String
}

@MainActor
class ViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isConnected: Bool = false
    var username: String = ""
    var group: String = ""
    private var connection: HubConnection?
    
    func setupConnection() async throws {
        guard connection == nil else {
            return
        }
        
        connection = HubConnectionBuilder()
            .withUrl(url: "http://localhost:8080/groupChat")
            .withAutomaticReconnect()
            .build()
        
        await connection!.on("NewMessage") { (user: String, message: String) in
            self.addMessage(id: UUID().uuidString, sender: user, content: message)
        }
        
        await connection!.on("newMessageWithId") { (user: String, id: String, chunk: String) in
            self.addOrUpdateMessage(id: id, sender: user, chunk: chunk)
        }
        
        await connection!.onReconnected { [weak self] in
            guard let self = self else { return }
            do {
                try await self.joinGroup()
            } catch {
                print(error)
            }
        }
        
        try await connection!.start()
        try await joinGroup()
        isConnected = true
    }
    
    func sendMessage(message: String) async throws {
        try await connection?.send(method: "Chat", arguments: self.username, message)
    }
    
    func joinGroup() async throws {
        try await connection?.invoke(method: "JoinGroup", arguments: self.group)
    }
    
    func addMessage(id: String?, sender: String, content: String) {
        DispatchQueue.main.async {
            self.messages.append(Message(id: id, sender: sender, content: content))
        }
    }
    
    func addOrUpdateMessage(id: String, sender: String, chunk: String) {
        DispatchQueue.main.async {
            if let index = self.messages.firstIndex(where: {$0.id == id}) {
                self.messages[index].content = chunk
            } else {
                self.messages.append(Message(id: id, sender: sender, content: chunk))
            }
        }
    }
}



---
File: /Sample/AzureSignalRConsoleApp/Sources/Sample/main.swift
---

import SignalRClient
import Foundation

let client = HubConnectionBuilder()
    .withUrl(url: String("http://localhost:8080/chat"))
    .withAutomaticReconnect()
    .build()

await client.on("ReceiveMessage") { (message: String) in
    print("Received message: \(message)")
}

try await client.start()

try await client.invoke(method: "Echo", arguments: "Hello")



---
File: /Sample/AzureSignalRConsoleApp/Package.swift
---

// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Sample",
    platforms: [
        .macOS(.v11)
    ],
    dependencies: [
        .package(url: "https://github.com/dotnet/signalr-client-swift", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "Sample",
            dependencies: [.product(name: "SignalRClient", package: "signalr-client-swift")]
        )
    ]
)



---
File: /Sample/ChatRoom/ChatRoom/ChatRoomApp.swift
---

import SwiftUI

@main
struct ChatRoomApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}



---
File: /Sample/ChatRoom/ChatRoom/ChatViewModel.swift
---

import SwiftUI
import SignalRClient

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [String] = []
    @Published var isConnected: Bool = false
    var username: String = ""
    private var connection: HubConnection?
 
    func setupConnection() async throws {
        guard connection == nil else {
            return
        }
        
        connection = HubConnectionBuilder()
            .withUrl(url: "http://localhost:8080/chat")
            .withAutomaticReconnect()
            .build()

        await connection!.on("message") { (user: String, message: String) in
            DispatchQueue.main.async {
                self.messages.append("\(user): \(message)")
            }
        }
 
        try await connection!.start()
        isConnected = true
    }
 
    func sendMessage(user: String, message: String) async throws {
        try await connection?.invoke(method: "Broadcast", arguments: username, message)
    }
}



---
File: /Sample/ChatRoom/ChatRoom/ContentView.swift
---

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText: String = ""
    @State private var username: String = ""
    @State private var isShowingUsernameSheet: Bool = true

    var body: some View {
        VStack {
            Text(viewModel.isConnected ? "Connected" : "Disconnected")
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(5)
                .background(viewModel.isConnected ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                .foregroundColor(.white)

            Text("User: \(username)")
                .font(.headline)
                .frame(minHeight: 15)
                .padding()

            List(viewModel.messages, id: \.self) { message in
                Text(message)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }

            HStack {
                TextField("Type your message here...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 15)
                    .padding()

                Button(action: {
                    Task {
                        try await viewModel.sendMessage(user: "user", message: messageText)
                        messageText = ""
                    }
                }) {
                    Text("Send")
                }
                .keyboardShortcut(.defaultAction)
                .controlSize(.regular)
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .padding()
        }
        .sheet(isPresented: $isShowingUsernameSheet) {
            UsernameEntryView(username: $username, isPresented: $isShowingUsernameSheet, viewModel: viewModel)
                .frame(width: 300, height: 200) 
        }
    }
}

struct UsernameEntryView: View {
    @Binding var username: String
    @Binding var isPresented: Bool
    var viewModel: ChatViewModel

    var body: some View {
        VStack {
            Text("Enter your username")
                .font(.headline)
                .padding()

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                if !username.isEmpty {
                    isPresented = false
                    viewModel.username = username

                    Task {
                        try await viewModel.setupConnection()
                    }
                }
            }) {
                Text("Enter")
            }
            .keyboardShortcut(.defaultAction)
            .controlSize(.regular)
            .buttonStyle(.borderedProminent)
            .frame(width: 120)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}



---
File: /Sample/ConsoleApp/Sources/Sample/main.swift
---

import SignalRClient
import Foundation

let client = HubConnectionBuilder()
    .withUrl(url: String("http://localhost:8080/chat"))
    .withAutomaticReconnect()
    .build()

await client.on("ReceiveMessage") { (message: String) in
    print("Received message: \(message)")
}

try await client.start()

try await client.invoke(method: "Echo", arguments: "Hello")



---
File: /Sample/ConsoleApp/Package.swift
---

// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Sample",
    platforms: [
        .macOS(.v11)
    ],
    dependencies: [
        .package(url: "https://github.com/dotnet/signalr-client-swift", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "Sample",
            dependencies: [.product(name: "SignalRClient", package: "signalr-client-swift")]
        )
    ]
)



---
File: /Sources/SignalRClient/Protocols/Msgpack/MsgpackCommon.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

// Messagepack protocol: https://github.com/msgpack/msgpack/blob/master/spec.md

// MARK: Public
// Predefined Timestamp Extension
public struct MsgpackTimestamp: Equatable {
    public var seconds: Int64
    public var nanoseconds: UInt32

    public init(seconds: Int64, nanoseconds: UInt32) {
        self.seconds = seconds
        self.nanoseconds = nanoseconds
    }
}

// Those encoding extension methods are rarely used unless you want to encode to messagepack extension type
extension Encoder {
    public func isMsgpackEncoder() -> Bool {
        return self is MsgpackEncoder
    }

    // This method should be used with MsgpackEncoder otherwise it panics. Use isMsgpackEncoder to check.
    public func encodeMsgpackExt(extType: Int8, extData: Data) throws {
        let msgpackEncoder = self as! MsgpackEncoder
        try msgpackEncoder.encodeMsgpackExt(extType: extType, extData: extData)
    }
}

// Those decoding extension methods are rarely used unless you want to decode from messagepack extension type
extension Decoder {
    public func isMsgpackDecoder() -> Bool {
        return self is MsgpackDecoder
    }

    // This method should be used with MsgpackDecoder otherwise it panics. Use isMsgpackDecoder to check.
    public func getMsgpackExtType() throws -> Int8 {
        let msgpackDecoder = self as! MsgpackDecoder
        return try msgpackDecoder.getMsgpackExtType()
    }

    // This method should be used with MsgpackDecoder otherwise it panics. Use isMsgpackDecoder to check.
    public func getMsgpackExtData() throws -> Data {
        let msgpackDecoder = self as! MsgpackDecoder
        return try msgpackDecoder.getMsgpackExtData()
    }
}

// MARK: Internal
enum MsgpackElement: Equatable {
    case int(Int64)
    case uint(UInt64)
    case float32(Float32)
    case float64(Float64)
    case string(String)
    case bin(Data)
    case bool(Bool)
    case map([String: MsgpackElement])
    case array([MsgpackElement])
    case null
    case ext(Int8, Data)

    var typeDescription: String {
        switch self {
        case .bool:
            return "Bool"
        case .int, .uint:
            return "Integer"
        case .float32, .float64:
            return "Float"
        case .string:
            return "String"
        case .bin:
            return "Binary"
        case .map:
            return "Map"
        case .array:
            return "Array"
        case .null:
            return "Null"
        case .ext(let type, _):
            return "Extension(type:\(type))"
        }
    }
}

struct MsgpackCodingKey: CodingKey, Equatable {
    var stringValue: String
    var intValue: Int?

    init(stringValue: String) {
        self.stringValue = stringValue
    }

    init(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String("Index \(intValue)")
    }
}



---
File: /Sources/SignalRClient/Protocols/Msgpack/MsgpackDecoder.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

// MARK: Swift Decodable implementation. Decoder, KeyedContainer, UnkeyedContainer, SingleValueContainer
class MsgpackDecoder: Decoder, MsgpackElementLoader {
    var codingPath: [any CodingKey]
    var messagepackType: MsgpackElement?
    var userInfo: [CodingUserInfoKey: Any]

    init(
        codingPath: [any CodingKey] = [],
        userInfo: [CodingUserInfoKey: Any] = [:]
    ) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    func getMsgpackExtType() throws -> Int8 {
        guard let msgpackElement = self.messagepackType else {
            throw MsgpackDecodingError.decoderNotInitialized
        }
        guard case let MsgpackElement.ext(extType, _) = msgpackElement else {
            throw DecodingError.typeMismatch(
                Decoder.self,
                .init(
                    codingPath: codingPath,
                    debugDescription:
                    "\(msgpackElement.typeDescription) is not extension type"
                )
            )
        }
        return extType
    }

    func getMsgpackExtData() throws -> Data {
        guard let msgpackElement = self.messagepackType else {
            throw MsgpackDecodingError.decoderNotInitialized
        }
        guard case let MsgpackElement.ext(_, data) = msgpackElement else {
            throw DecodingError.typeMismatch(
                Decoder.self,
                .init(
                    codingPath: codingPath,
                    debugDescription:
                    "\(msgpackElement.typeDescription) is not extension type"
                )
            )
        }
        return data
    }

    func loadMsgpackElement(from data: MsgpackElement) throws {
        messagepackType = data
    }

    func container<Key>(keyedBy type: Key.Type) throws
    -> KeyedDecodingContainer<Key> where Key: CodingKey {
        guard let messagepackType = messagepackType else {
            throw MsgpackDecodingError.decoderNotInitialized
        }
        let container = try MsgpackKeyedDecodingContainer<Key>(
            codingPath: codingPath, userInfo: userInfo,
            msgpackValue: messagepackType
        )
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
        guard let messagepackType = messagepackType else {
            throw MsgpackDecodingError.decoderNotInitialized
        }
        let container = try MsgpackUnkeyedDecodingContainer(
            codingPath: codingPath, userInfo: userInfo,
            msgpackValue: messagepackType
        )
        return container
    }

    func singleValueContainer() throws -> any SingleValueDecodingContainer {
        guard let messagepackType = messagepackType else {
            throw MsgpackDecodingError.decoderNotInitialized
        }
        let container = try MsgpackSingleValueDecodingContainer(
            codingPath: codingPath, userInfo: userInfo,
            msgpackValue: messagepackType
        )
        return container
    }

    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let (msgpackElement, remaining) = try MsgpackElement.parse(data: data)
        if !remaining.isEmpty {
            throw MsgpackDecodingError.corruptMessage
        }
        try loadMsgpackElement(from: msgpackElement)
        let result = try msgpackElement.decode(type: type, codingPath: codingPath)
        guard let result = result else {
            return try type.init(from: self)
        }
        return result
    }
}

class MsgpackKeyedDecodingContainer<Key: CodingKey>:
KeyedDecodingContainerProtocol, MsgpackElementLoader {
    private var holder: [String: MsgpackElement] = [:]
    var codingPath: [any CodingKey]
    var userInfo: [CodingUserInfoKey: Any]

    init(
        codingPath: [any CodingKey], userInfo: [CodingUserInfoKey: Any],
        msgpackValue: MsgpackElement
    ) throws {
        self.codingPath = codingPath
        self.userInfo = userInfo
        try loadMsgpackElement(from: msgpackValue)
    }

    func loadMsgpackElement(from data: MsgpackElement) throws {
        switch data {
        case .map(let m):
            self.holder = m
        default:
            throw DecodingError.typeMismatch(
                [String: Any].self,
                .init(
                    codingPath: codingPath,
                    debugDescription:
                    "Expected to decode \([String: Any].self) but found \(data.typeDescription) instead."
                )
            )

        }
    }

    var allKeys: [Key] { holder.keys.compactMap { k in Key(stringValue: k) } }

    func contains(_ key: Key) -> Bool {
        return holder[key.stringValue] != nil
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        let v = try getMsgpackElement(key)
        return v.isNil()
    }

    func decode<T>(_ value: T.Type, forKey key: Key) throws -> T
    where T: Decodable {
        let v = try getMsgpackElement(key)
        let result = try v.decode(
            type: value, codingPath: subCodingPath(key: key)
        )
        guard let result = result else {
            let decoder = try initDecoder(key: key, value: v)
            return try T.init(from: decoder)
        }
        return result
    }

    func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type, forKey key: Key
    ) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        let v = try getMsgpackElement(key)
        let decoder = try initDecoder(key: key, value: v)
        let container = try decoder.container(keyedBy: keyType)
        return container
    }

    func nestedUnkeyedContainer(forKey key: Key) throws
    -> any UnkeyedDecodingContainer {
        let v = try getMsgpackElement(key)
        let decoder = try initDecoder(key: key, value: v)
        let container = try decoder.unkeyedContainer()
        return container
    }

    func superDecoder() throws -> any Decoder {
        let key = MsgpackCodingKey(stringValue: "super")
        let v = try getMsgpackElement(key)
        let decoder = try initDecoder(key: key, value: v)
        return decoder
    }

    func superDecoder(forKey key: Key) throws -> any Decoder {
        let v = try getMsgpackElement(key)
        let decoder = try initDecoder(key: key, value: v)
        return decoder
    }

    private func getMsgpackElement(_ key: CodingKey) throws -> MsgpackElement {
        let v = holder[key.stringValue]
        guard let v = v else {
            throw DecodingError.keyNotFound(
                key,
                .init(
                    codingPath: subCodingPath(key: key),
                    debugDescription: "No value associated with key \(key)."
                )
            )
        }
        return v
    }

    private func initDecoder(key: CodingKey, value: MsgpackElement) throws
    -> MsgpackDecoder {
        let decoder = MsgpackDecoder(
            codingPath: subCodingPath(key: key), userInfo: self.userInfo
        )
        try decoder.loadMsgpackElement(from: value)
        return decoder
    }

    private func subCodingPath(key: CodingKey) -> [CodingKey] {
        var codingPath = self.codingPath
        codingPath.append(key)
        return codingPath
    }

}

class MsgpackUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    private var holder: [MsgpackElement] = []
    var codingPath: [any CodingKey]
    var userInfo: [CodingUserInfoKey: Any]

    var count: Int? { holder.count }
    var isAtEnd: Bool { currentIndex >= holder.count }
    var currentIndex: Int

    init(
        codingPath: [any CodingKey], userInfo: [CodingUserInfoKey: Any],
        msgpackValue: MsgpackElement
    ) throws {
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.currentIndex = 0
        try loadMsgpackElement(from: msgpackValue)
    }

    func loadMsgpackElement(from data: MsgpackElement) throws {
        switch data {
        case .array(let m):
            self.holder = m
        default:
            throw DecodingError.typeMismatch(
                [Any].self,
                .init(
                    codingPath: codingPath,
                    debugDescription:
                    "Expected to decode \([Any].self) but found \(data.typeDescription) instead."
                )
            )
        }
    }

    func decodeNil() throws -> Bool {
        let msgpackElement = try getMsgpackElement(Never.self)
        let isNil = msgpackElement.isNil()
        currentIndex += isNil ? 1 : 0
        return isNil
    }

    func decode<T>(_ value: T.Type) throws -> T where T: Decodable {
        let msgpackElement = try getMsgpackElement(T.self)
        guard
            let result = try msgpackElement.decode(
                type: value, codingPath: subCodingPath()
            )
        else {
            let decoder = try initDecoder(value: msgpackElement)
            currentIndex += 1
            return try value.init(from: decoder)
        }
        currentIndex += 1
        return result
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) throws
    -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        let msgpackElement = try getMsgpackElement(
            KeyedDecodingContainer<NestedKey>.self)
        let decoder = try initDecoder(value: msgpackElement)
        currentIndex += 1
        return try decoder.container(keyedBy: keyType)
    }

    func nestedUnkeyedContainer() throws -> any UnkeyedDecodingContainer {
        let msgpackElement = try getMsgpackElement(UnkeyedDecodingContainer.self)
        let decoder = try initDecoder(value: msgpackElement)
        currentIndex += 1
        return try decoder.unkeyedContainer()
    }

    func superDecoder() throws -> any Decoder {
        let msgpackElement = try getMsgpackElement(Decoder.self)
        let decoder = try initDecoder(value: msgpackElement)
        currentIndex += 1
        return decoder
    }

    private func getMsgpackElement(_ targetType: Any.Type) throws -> MsgpackElement {
        guard currentIndex < holder.count else {
            throw DecodingError.valueNotFound(
                targetType,
                .init(
                    codingPath: subCodingPath(),
                    debugDescription: "Unkeyed container is at end."
                )
            )
        }
        return holder[currentIndex]
    }

    private func initDecoder(value: MsgpackElement) throws -> MsgpackDecoder {
        let decoder = MsgpackDecoder(
            codingPath: subCodingPath(), userInfo: self.userInfo
        )
        try decoder.loadMsgpackElement(from: value)
        return decoder
    }

    private func subCodingPath() -> [CodingKey] {
        var codingPath = self.codingPath
        codingPath.append(MsgpackCodingKey(intValue: currentIndex))
        return codingPath
    }
}

class MsgpackSingleValueDecodingContainer: SingleValueDecodingContainer,
MsgpackElementLoader {
    private var holder: MsgpackElement = .null
    var codingPath: [any CodingKey]
    var userInfo: [CodingUserInfoKey: Any]

    init(
        codingPath: [any CodingKey], userInfo: [CodingUserInfoKey: Any],
        msgpackValue: MsgpackElement
    ) throws {
        self.codingPath = codingPath
        self.userInfo = userInfo
        try loadMsgpackElement(from: msgpackValue)
    }

    func loadMsgpackElement(from data: MsgpackElement) throws {
        self.holder = data
    }

    func decodeNil() -> Bool {
        return holder.isNil()
    }

    func decode<T>(_ value: T.Type) throws -> T where T: Decodable {
        guard
            let result = try holder.decode(type: value, codingPath: codingPath)
        else {
            let decoder = try initDecoder(value: holder)
            return try value.init(from: decoder)
        }
        return result
    }

    private func initDecoder(value: MsgpackElement) throws -> MsgpackDecoder {
        let decoder = MsgpackDecoder(
            codingPath: codingPath, userInfo: self.userInfo
        )
        try decoder.loadMsgpackElement(from: value)
        return decoder
    }
}

private protocol MsgpackElementLoader {
    func loadMsgpackElement(from data: MsgpackElement) throws
}

// MARK: (Decoding Part) Intermediate type which implements messagepack protocol. Similar to JSonObject
extension MsgpackElement {
    // MARK: Convert from Data to MsgpackElement
    static func parse(data: Data) throws -> (MsgpackElement, Data) {
        try assertLength(data: data, length: 1)
        let first = data[0]
        if first <= 0x7f || first >= 0xe0 || (first >= 0xcc && first <= 0xd3) {
            return try parseNumber(data: data)
        }
        if (first >= 0xa0 && first <= 0xbf) || (first >= 0xd9 && first <= 0xdb) {
            return try parseString(data: data)
        }
        if (first >= 0x80 && first <= 0x8f) || (first >= 0xde && first <= 0xdf) {
            return try parseMap(data: data)
        }
        if (first >= 0x90 && first <= 0x9f) || (first >= 0xdc && first <= 0xdd) {
            return try parseArray(data: data)
        }
        if first >= 0xc4 && first <= 0xc6 {
            return try parseBinary(data: data)
        }
        if first >= 0xd4 && first <= 0xde || first >= 0xc7 && first <= 0xc9 {
            return try parseExtension(data: data)
        }
        switch first {
        case 0xca:
            return try parseFloat32(data: data.subdata(in: 1 ..< data.count))
        case 0xcb:
            return try parseFloat64(data: data.subdata(in: 1 ..< data.count))
        case 0xc2:
            return (MsgpackElement.bool(false), data.subdata(in: 1 ..< data.count))
        case 0xc3:
            return (MsgpackElement.bool(true), data.subdata(in: 1 ..< data.count))
        case 0xc0:
            return (MsgpackElement.null, data.subdata(in: 1 ..< data.count))
        default:
            throw MsgpackDecodingError.decdoeWithUnexpectedMsgpackElement(first)
        }
    }

    private static func parseNumber(data: Data) throws -> (MsgpackElement, Data) {
        try assertLength(data: data, length: 1)
        let first = data[0]
        let remaining = data.subdata(in: 1 ..< data.count)
        // Fixed positive int
        if first >= 0x00 && first <= 0x7f {
            let uint8 = UInt8(first)
            return (MsgpackElement.uint(UInt64(uint8)), remaining)
        }
        // Fixed negative int
        if first >= 0xe0 && first <= 0xff {
            let int8Data = data[..<1]
            let int8: Int8 = int8Data.withUnsafeBytes { pointer in
                return pointer.load(as: Int8.self)
            }
            return (MsgpackElement.int(Int64(int8)), remaining)
        }

        switch first {
        case 0xcc: // UInt8
            let (uint8, remaining) = try parseRawUInt8(data: remaining)
            return (MsgpackElement.uint(UInt64(uint8)), remaining)
        case 0xcd: // UInt16
            let (uint16, remaining) = try parseRawUInt16(data: remaining)
            return (MsgpackElement.uint(UInt64(uint16)), remaining)
        case 0xce: // UInt32
            let (uint32, remaining) = try parseRawUInt32(data: remaining)
            return (MsgpackElement.uint(UInt64(uint32)), remaining)
        case 0xcf: // UInt64
            let (uint64, remaining) = try parseRawUInt64(data: remaining)
            return (MsgpackElement.uint(uint64), remaining)
        case 0xd0: // Int8
            let (int8, remaining) = try parseRawInt8(data: remaining)
            return (MsgpackElement.int(Int64(int8)), remaining)
        case 0xd1: // Int16
            let (int16, remaining) = try parseRawInt16(data: remaining)
            return (MsgpackElement.int(Int64(int16)), remaining)
        case 0xd2: // Int32
            let (int32, remaining) = try parseRawInt32(data: remaining)
            return (MsgpackElement.int(Int64(int32)), remaining)
        case 0xd3: // Int64
            let (int64, remaining) = try parseRawInt64(data: remaining)
            return (MsgpackElement.int(int64), remaining)
        default:
            throw MsgpackDecodingError.decdoeWithUnexpectedMsgpackElement(first)
        }
    }

    private static func parseFloat32(data: Data) throws -> (MsgpackElement, Data) {
        // float32 memory edianness is undefined. Use uint32 bits to init.
        let (uint32, remaining) = try parseRawUInt32(data: data)
        let float32 = Float32(bitPattern: uint32)
        return (MsgpackElement.float32(float32), remaining)
    }

    private static func parseFloat64(data: Data) throws -> (MsgpackElement, Data) {
        // float64 memory edianness is undefined. Use uint64 bits to init.
        let (uint64, remaining) = try parseRawUInt64(data: data)
        let float64 = Float64(bitPattern: uint64)
        return (MsgpackElement.float64(float64), remaining)
    }

    private static func parseString(data: Data) throws -> (MsgpackElement, Data) {
        try assertLength(data: data, length: 1)
        var length: Int = 0
        let first = data[0]
        var remaining = data.subdata(in: 1 ..< data.count)
        if first >= 0xa0 && first <= 0xbf {
            length = Int(first & 0x1f)
        } else {
            switch first {
            case 0xd9: // Str8
                var uint8: UInt8
                (uint8, remaining) = try parseRawUInt8(data: remaining)
                length = Int(uint8)
            case 0xda: // str16
                var uint16: UInt16
                (uint16, remaining) = try parseRawUInt16(data: remaining)
                length = Int(uint16)
            case 0xdb: // str32
                var uint32: UInt32
                (uint32, remaining) = try parseRawUInt32(data: remaining)
                guard uint32 <= Int.max else {
                    throw MsgpackDecodingError.decodeStringTooLarge(uint32)
                }
                length = Int(uint32)
            default:
                throw MsgpackDecodingError.decdoeWithUnexpectedMsgpackElement(
                    first)
            }
        }
        try assertLength(data: remaining, length: length)
        guard let str = String(data: remaining[..<length], encoding: .utf8)
        else {
            throw MsgpackDecodingError.decodeStringError
        }
        return (
            MsgpackElement.string(str),
            remaining.subdata(in: length ..< remaining.count)
        )
    }

    private static func parseBinary(data: Data) throws -> (MsgpackElement, Data) {
        try assertLength(data: data, length: 1)
        var length: Int = 0
        let first = data[0]
        var remaining = data.subdata(in: 1 ..< data.count)
        switch first {
        case 0xc4: // bin8
            var uint8: UInt8
            (uint8, remaining) = try parseRawUInt8(data: remaining)
            length = Int(uint8)
        case 0xc5: // bin16
            var uint16: UInt16
            (uint16, remaining) = try parseRawUInt16(data: remaining)
            length = Int(uint16)
        case 0xc6: // bin32
            var uint32: UInt32
            (uint32, remaining) = try parseRawUInt32(data: remaining)
            guard uint32 <= Int.max else {
                throw MsgpackDecodingError.decodeBinaryTooLarge(uint32)
            }
            length = Int(uint32)
        default:
            throw MsgpackDecodingError.decdoeWithUnexpectedMsgpackElement(first)
        }
        try assertLength(data: remaining, length: length)
        let binary = remaining.subdata(in: 0 ..< length)
        return (
            MsgpackElement.bin(binary),
            remaining.subdata(in: length ..< remaining.count)
        )
    }

    private static func parseMap(data: Data) throws -> (MsgpackElement, Data) {
        try assertLength(data: data, length: 1)
        var length: Int = 0
        let first = data[0]
        var remaining = data.subdata(in: 1 ..< data.count)
        if first >= 0x80 && first <= 0x8f {
            length = Int(first & 0x0f)
        } else {
            switch first {
            case 0xde: // map16
                var uint16: UInt16
                (uint16, remaining) = try parseRawUInt16(data: remaining)
                length = Int(uint16)
            case 0xdf: // map32
                var uint32: UInt32
                (uint32, remaining) = try parseRawUInt32(data: remaining)
                guard uint32 <= Int.max else {
                    throw MsgpackDecodingError.decodeMapTooLarge(uint32)
                }
                length = Int(uint32)
            default:
                throw MsgpackDecodingError.decdoeWithUnexpectedMsgpackElement(
                    first)
            }
        }

        var map: [String: MsgpackElement] = [:]
        for _ in 0 ..< length {
            var wrappedKey: MsgpackElement
            (wrappedKey, remaining) = try parseString(data: remaining)
            guard case .string(let key) = wrappedKey else {
                throw MsgpackDecodingError.decodeMapKeyNotString
            }
            var value: MsgpackElement
            (value, remaining) = try parse(data: remaining)
            map[key] = value
        }
        return (MsgpackElement.map(map), remaining)
    }

    private static func parseArray(data: Data) throws -> (MsgpackElement, Data) {
        try assertLength(data: data, length: 1)
        var length: Int = 0
        let first = data[0]
        var remaining = data.subdata(in: 1 ..< data.count)
        if first >= 0x90 && first <= 0x9f {
            length = Int(first & 0x0f)
        } else {
            switch first {
            case 0xdc: // array16
                var uint16: UInt16
                (uint16, remaining) = try parseRawUInt16(data: remaining)
                length = Int(uint16)
            case 0xdd: // array32
                var uint32: UInt32
                (uint32, remaining) = try parseRawUInt32(data: remaining)
                guard uint32 <= Int.max else {
                    throw MsgpackDecodingError.decodeArrayTooLarge(uint32)
                }
                length = Int(uint32)
            default:
                throw MsgpackDecodingError.decdoeWithUnexpectedMsgpackElement(
                    first)
            }
        }

        var array: [MsgpackElement] = []
        array.reserveCapacity(length)
        for _ in 0 ..< length {
            var value: MsgpackElement
            (value, remaining) = try parse(data: remaining)
            array.append(value)
        }
        return (MsgpackElement.array(array), remaining)
    }

    private static func parseExtension(data: Data) throws -> (MsgpackElement, Data) {
        try assertLength(data: data, length: 1)
        let first = data[0]
        var remaining = data.subdata(in: 1 ..< data.count)
        var extType: Int8
        var extLength: Int
        switch first {
        case 0xd4:
            extLength = 1
        case 0xd5:
            extLength = 2
        case 0xd6:
            extLength = 4
        case 0xd7:
            extLength = 8
        case 0xd8:
            extLength = 16
        case 0xc7:
            var uint8: UInt8
            (uint8, remaining) = try Self.parseRawUInt8(data: remaining)
            extLength = Int(uint8)
        case 0xc8:
            var uint16: UInt16
            (uint16, remaining) = try Self.parseRawUInt16(data: remaining)
            extLength = Int(uint16)
        case 0xc9:
            var uint32: UInt32
            (uint32, remaining) = try Self.parseRawUInt32(data: remaining)
            guard UInt64(uint32) <= UInt64(Int.max) else {
                throw MsgpackDecodingError.decodeExtensionTooLarge(uint32)
            }
            extLength = Int(uint32)
        default:
            throw MsgpackDecodingError.decdoeWithUnexpectedMsgpackElement(first)
        }

        (extType, remaining) = try Self.parseRawInt8(data: remaining)
        try assertLength(data: remaining, length: extLength)
        let extData = remaining.subdata(in: 0 ..< extLength)
        remaining = remaining.subdata(in: extLength ..< remaining.count)

        return (MsgpackElement.ext(extType, extData), remaining)
    }

    fileprivate static func assertLength(data: Data, length: Int) throws {
        guard data.count >= length else {
            throw MsgpackDecodingError.corruptMessage
        }
    }

    // MARK: Convert from MsgpackElement to basic Swift type
    func decode<T>(type: T.Type, codingPath: [CodingKey] = []) throws -> T?
    where T: Decodable {
        do {
            switch type {
            case is UInt.Type:
                return try UInt(getUInt(max: UInt64(UInt.max))) as? T
            case is UInt8.Type:
                return try UInt8(getUInt(max: UInt64(UInt8.max))) as? T
            case is UInt16.Type:
                return try UInt16(getUInt(max: UInt64(UInt16.max))) as? T
            case is UInt32.Type:
                return try UInt32(getUInt(max: UInt64(UInt32.max))) as? T
            case is UInt64.Type:
                return try getUInt(max: UInt64.max) as? T

            // Signed integers
            case is Int.Type:
                return try Int(getInt(min: Int64(Int.min), max: Int64(Int.max)))
                    as? T
            case is Int8.Type:
                return try Int8(
                    getInt(min: Int64(Int8.min), max: Int64(Int8.max))) as? T
            case is Int16.Type:
                return try Int16(
                    getInt(min: Int64(Int16.min), max: Int64(Int16.max))) as? T
            case is Int32.Type:
                return try Int32(
                    getInt(min: Int64(Int32.min), max: Int64(Int32.max))) as? T
            case is Int64.Type:
                return try getInt(min: Int64.min, max: Int64.max) as? T

            // Float (Float16's decodable is implemented as Float32)
            case is Float32.Type:
                return Float32(try getFloat()) as? T
            case is Float64.Type:
                return try getFloat() as? T

            // Bool
            case is Bool.Type:
                guard case let .bool(bool) = self else {
                    throw MsgpackDecodingError.decodeTypeNotMatch
                }
                return bool as? T
            // Data
            case is Data.Type:
                guard case let .bin(data) = self else {
                    throw MsgpackDecodingError.decodeTypeNotMatch
                }
                return data as? T
            // String
            case is String.Type:
                guard case let .string(string) = self else {
                    throw MsgpackDecodingError.decodeTypeNotMatch
                }
                return string as? T
            default:
                return nil
            }
        } catch MsgpackDecodingError.decodeNumberWithInvalideRange(let number) {
            throw DecodingError.typeMismatch(
                T.self,
                .init(
                    codingPath: codingPath,
                    debugDescription: "Can't convert \(number) to \(T.self)"
                )
            )
        } catch MsgpackDecodingError.decodeTypeNotMatch {
            throw DecodingError.typeMismatch(
                T.self,
                .init(
                    codingPath: codingPath,
                    debugDescription:
                    "Can't convert \(self.typeDescription) to \(T.self)"
                )
            )
        }
    }

    func getUInt(max: UInt64) throws -> UInt64 {
        switch self {
        case let .uint(uint64):
            guard uint64 <= max else {
                throw MsgpackDecodingError.decodeNumberWithInvalideRange(
                    "\(uint64)")
            }
            return uint64
        case let .int(int64):
            guard int64 >= 0 && int64 <= max else {
                throw MsgpackDecodingError.decodeNumberWithInvalideRange(
                    "\(int64)")
            }
            return UInt64(int64)
        default:
            throw MsgpackDecodingError.decodeTypeNotMatch
        }
    }

    func getInt(min: Int64, max: Int64) throws -> Int64 {
        switch self {
        case let .uint(uint64):
            guard uint64 <= max else {
                throw MsgpackDecodingError.decodeNumberWithInvalideRange(
                    "\(uint64)")
            }
            return Int64(uint64)
        case let .int(int64):
            guard int64 >= min && int64 <= max else {
                throw MsgpackDecodingError.decodeNumberWithInvalideRange(
                    "\(int64)")
            }
            return Int64(int64)
        default:
            throw MsgpackDecodingError.decodeTypeNotMatch
        }
    }

    func getFloat() throws -> Float64 {
        switch self {
        case let .float32(float32):
            return Float64(float32)
        case let .float64(Float64):
            return Float64
        default:
            throw MsgpackDecodingError.decodeTypeNotMatch
        }
    }

    fileprivate func isNil() -> Bool {
        switch self {
        case .null:
            return true
        default:
            return false
        }
    }

    // Utils methods
    fileprivate static func parseRawUInt8(data: Data) throws -> (UInt8, Data) {
        try MsgpackElement.assertLength(data: data, length: 1)
        let uint8Data = data[..<1]
        let uint8 = uint8Data.withUnsafeBytes { pointer in
            return pointer.load(as: UInt8.self)
        }
        let remaining = data.subdata(in: 1 ..< data.count)
        return (uint8, remaining)
    }

    fileprivate static func parseRawUInt16(data: Data) throws -> (UInt16, Data) {
        try MsgpackElement.assertLength(data: data, length: 2)
        let uint16Data = data[..<2]
        let uint16 = uint16Data.withUnsafeBytes { pointer in
            return pointer.loadUnaligned(as: UInt16.self)
        }.bigEndian
        let remaining = data.subdata(in: 2 ..< data.count)
        return (uint16, remaining)
    }

    fileprivate static func parseRawUInt32(data: Data) throws -> (UInt32, Data) {
        try MsgpackElement.assertLength(data: data, length: 4)
        let uint32Data = data[..<4]
        let uint32 = uint32Data.withUnsafeBytes { pointer in
            return pointer.loadUnaligned(as: UInt32.self)
        }.bigEndian
        let remaining = data.subdata(in: 4 ..< data.count)
        return (uint32, remaining)
    }

    fileprivate static func parseRawUInt64(data: Data) throws -> (UInt64, Data) {
        try MsgpackElement.assertLength(data: data, length: 8)
        let uint64Data = data[..<8]
        let uint64 = uint64Data.withUnsafeBytes { pointer in
            return pointer.loadUnaligned(as: UInt64.self)
        }.bigEndian
        let remaining = data.subdata(in: 8 ..< data.count)
        return (uint64, remaining)
    }

    fileprivate static func parseRawInt8(data: Data) throws -> (Int8, Data) {
        try MsgpackElement.assertLength(data: data, length: 1)
        let int8Data = data[..<1]
        let int8 = int8Data.withUnsafeBytes { pointer in
            return pointer.loadUnaligned(as: Int8.self)
        }.bigEndian
        let remaining = data.subdata(in: 1 ..< data.count)
        return (int8, remaining)
    }

    fileprivate static func parseRawInt16(data: Data) throws -> (Int16, Data) {
        try MsgpackElement.assertLength(data: data, length: 2)
        let int16Data = data[..<2]
        let int16 = int16Data.withUnsafeBytes { pointer in
            return pointer.loadUnaligned(as: Int16.self)
        }.bigEndian
        let remaining = data.subdata(in: 2 ..< data.count)
        return (int16, remaining)
    }

    fileprivate static func parseRawInt32(data: Data) throws -> (Int32, Data) {
        try MsgpackElement.assertLength(data: data, length: 4)
        let int32Data = data[..<4]
        let int32 = int32Data.withUnsafeBytes { pointer in
            return pointer.loadUnaligned(as: Int32.self)
        }.bigEndian
        let remaining = data.subdata(in: 4 ..< data.count)
        return (int32, remaining)
    }

    fileprivate static func parseRawInt64(data: Data) throws -> (Int64, Data) {
        try MsgpackElement.assertLength(data: data, length: 8)
        let int64Data = data[..<8]
        let int64 = int64Data.withUnsafeBytes { pointer in
            return pointer.loadUnaligned(as: Int64.self)
        }.bigEndian
        let remaining = data.subdata(in: 8 ..< data.count)
        return (int64, remaining)
    }
}

// Decode Msgpacktimestamp from extension type -1
extension MsgpackTimestamp: Decodable {
    public init(from decoder: any Decoder) throws {
        let extType = try decoder.getMsgpackExtType()
        guard extType == -1 else {
            throw DecodingError.typeMismatch(
                MsgpackTimestamp.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription:
                    "The extension type is not -1 when decoding \(MsgpackTimestamp.self)"
                )
            )
        }
        let extData = try decoder.getMsgpackExtData()
        switch extData.count {
        case 4:
            let (uint32, _) = try MsgpackElement.parseRawUInt32(data: extData)
            self.seconds = Int64(uint32)
            self.nanoseconds = 0
        case 8:
            let (uint64, _) = try MsgpackElement.parseRawUInt64(data: extData)
            self.nanoseconds = UInt32(uint64 >> 34)
            self.seconds = Int64(uint64 & 0x0f_ffff_ffff)
        case 12:
            let (uint32, secondsData) = try MsgpackElement.parseRawUInt32(
                data: extData)
            self.nanoseconds = uint32
            let (int64, _) = try MsgpackElement.parseRawInt64(data: secondsData)
            self.seconds = int64
        default:
            throw MsgpackDecodingError.invalidTimeStamp
        }
    }
}

// MARK: Decoding error handling
enum MsgpackDecodingError: Error, CustomStringConvertible {
    // exposed error
    case decdoeWithUnexpectedMsgpackElement(UInt8)
    case decodeMapKeyNotString
    case corruptMessage
    case decodeStringError
    case decodeStringTooLarge(UInt32)
    case decodeBinaryTooLarge(UInt32)
    case decodeMapTooLarge(UInt32)
    case decodeArrayTooLarge(UInt32)
    case decodeExtensionTooLarge(UInt32)
    case invalidTimeStamp

    //  exception wrapped with context
    case decodeNumberWithInvalideRange(String)
    case decodeTypeNotMatch

    // internal error
    case decoderNotInitialized

    var description: String {
        switch self {
        case .invalidTimeStamp:
            return "The timestamp is not in correct format"
        case .decdoeWithUnexpectedMsgpackElement(let messageType):
            return "\(messageType) is not valid messagepack type"
        case .decodeMapKeyNotString:
            return "The key must be String when decoding Map in Swift"
        case .decodeStringError:
            return "The given string is not in utf-8 format"
        case .corruptMessage:
            return "The given data was not valid messagepack message"
        case .decodeStringTooLarge(let length):
            return
                "Reveived string with length \(length) which is larger than the supported max: \(Int.max)"
        case .decodeBinaryTooLarge(let length):
            return
                "Reveived binary with length \(length) which is larger than the supported max: \(Int.max)"
        case .decodeMapTooLarge(let count):
            return
                "Reveived map with \(count) keys which is larger than the supported max: \(Int.max)"
        case .decodeArrayTooLarge(let count):
            return
                "Reveived array with \(count) elements which is larger than the supported max: \(Int.max)"
        case .decodeExtensionTooLarge(let length):
            return
                "Reveived extension with length \(length) which is larger than the supported max: \(Int.max)"
        default:
            return ""
        }
    }
}



---
File: /Sources/SignalRClient/Protocols/Msgpack/MsgpackEncoder.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

// MARK: Swift Encodable implementation. Encoder, KeyedContainer, UnkeyedContainer, SingleValueContainer
class MsgpackEncoder: Encoder, MsgpackElementConvertable {
    var codingPath: [any CodingKey]
    var userInfo: [CodingUserInfoKey: Any]
    var msgpack: MsgpackElementConvertable?

    init(
        codingPath: [any CodingKey] = [],
        userInfo: [CodingUserInfoKey: Any] = [:]
    ) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    func encodeMsgpackExt(extType: Int8, extData: Data) throws {
        self.msgpack = MsgpackElement.ext(extType, extData)
    }

    func container<Key>(keyedBy key: Key.Type) -> KeyedEncodingContainer<Key>
    where Key: CodingKey {
        guard let container = self.msgpack else {
            let container = MsgpackKeyedEncodingContainer<Key>(
                codingPath: codingPath, userInfo: userInfo
            )
            self.msgpack = container
            return KeyedEncodingContainer(container)
        }
        // Assert. Panic if the container is of diffrent type
        _ = container as! any KeyedEncodingContainerProtocol
        let newContainer = (container as! MsgpackSwitchKeyProtocol).switchKey(
            newKey: Key.self)
        self.msgpack = newContainer
        return KeyedEncodingContainer(newContainer)
    }

    func unkeyedContainer() -> any UnkeyedEncodingContainer {
        guard let container = self.msgpack else {
            let container = MsgpackUnkeyedEncodingContainer(
                codingPath: codingPath, userInfo: userInfo
            )
            self.msgpack = container
            return container
        }
        // panic if the container is of diffrent type
        return container as! UnkeyedEncodingContainer

    }

    func singleValueContainer() -> any SingleValueEncodingContainer {
        guard let container = self.msgpack else {
            let container = MsgpackSingleValueEncodingContainer(
                codingPath: codingPath, userInfo: userInfo
            )
            self.msgpack = container
            return container
        }
        // panic if the container is of diffrent type
        return container as! SingleValueEncodingContainer
    }

    func encode<T>(_ v: T) throws -> Data where T: Encodable {
        var msgpackElement = MsgpackElement(v)
        if msgpackElement == nil {
            try v.encode(to: self)
            msgpackElement = try? convertToMsgpackElement()
        }
        guard let msgpackElement = msgpackElement else {
            throw EncodingError.invalidValue(
                type(of: v),
                .init(
                    codingPath: codingPath,
                    debugDescription:
                    "Top-level \(String(describing: T.self)) did not encode any values."
                )
            )
        }
        self.msgpack = msgpackElement
        return try msgpackElement.marshall()
    }

    func convertToMsgpackElement() throws -> MsgpackElement {
        guard let msgpack = msgpack else {
            throw MsgpackEncodingError.encoderNotIntilized
        }
        return try msgpack.convertToMsgpackElement()
    }
}

class MsgpackKeyedEncodingContainer<Key: CodingKey>:
    KeyedEncodingContainerProtocol, MsgpackElementConvertable,
    MsgpackSwitchKeyProtocol {
    private var holder: [String: MsgpackElementConvertable] = [:]
    private var userInfo: [CodingUserInfoKey: Any]
    var codingPath: [any CodingKey]

    init(codingPath: [any CodingKey], userInfo: [CodingUserInfoKey: Any]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    func convertToMsgpackElement() throws -> MsgpackElement {
        return .map(try holder.mapValues { v in try v.convertToMsgpackElement() })
    }

    func switchKey<NewKey: CodingKey>(newKey: NewKey.Type)
    -> MsgpackKeyedEncodingContainer<NewKey> {
        let container = MsgpackKeyedEncodingContainer<NewKey>(
            codingPath: codingPath, userInfo: userInfo
        )
        container.holder = self.holder
        return container
    }

    func encodeNil(forKey key: Key) throws {
        holder[key.stringValue] = MsgpackElement.null
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
        guard let msgpackElement = MsgpackElement(value) else {
            let encoder = initEncoder(key: key)
            try value.encode(to: encoder)
            return
        }
        holder[key.stringValue] = msgpackElement
    }

    func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type, forKey key: Key
    ) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let encoder = initEncoder(key: key)
        return encoder.container(keyedBy: keyType)
    }

    func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
        let encoder = initEncoder(key: key)
        return encoder.unkeyedContainer()
    }

    func superEncoder() -> any Encoder {
        return initEncoder(key: MsgpackCodingKey(stringValue: "super"))
    }

    func superEncoder(forKey key: Key) -> any Encoder {
        return initEncoder(key: key)
    }

    private func initEncoder(key: CodingKey) -> MsgpackEncoder {
        var codingPath = self.codingPath
        codingPath.append(key)
        let encoder = MsgpackEncoder(
            codingPath: codingPath, userInfo: self.userInfo
        )
        holder[key.stringValue] = encoder
        return encoder
    }
}

class MsgpackUnkeyedEncodingContainer: UnkeyedEncodingContainer,
MsgpackElementConvertable {
    private var holder: [MsgpackElementConvertable] = []
    private var userInfo: [CodingUserInfoKey: Any]
    var codingPath: [any CodingKey]
    var count: Int { holder.count }

    init(codingPath: [any CodingKey], userInfo: [CodingUserInfoKey: Any]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    func convertToMsgpackElement() throws -> MsgpackElement {
        return .array(try holder.map { e in try e.convertToMsgpackElement() })
    }

    func encodeNil() throws {
        holder.append(MsgpackElement.null)
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        guard let msgpackElement = MsgpackElement(value) else {
            let encoder = initEncoder()
            try value.encode(to: encoder)
            return
        }
        self.holder.append(msgpackElement)
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type)
    -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let encoder = initEncoder()
        return KeyedEncodingContainer(encoder.container(keyedBy: keyType))
    }

    func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
        let encoder = initEncoder()
        return encoder.unkeyedContainer()
    }

    func superEncoder() -> any Encoder {
        return initEncoder()
    }

    private func initEncoder() -> MsgpackEncoder {
        var codingPath = self.codingPath
        codingPath.append(MsgpackCodingKey(intValue: holder.count))
        let encoder = MsgpackEncoder(
            codingPath: codingPath, userInfo: self.userInfo
        )
        holder.append(encoder)
        return encoder
    }
}

class MsgpackSingleValueEncodingContainer: SingleValueEncodingContainer,
MsgpackElementConvertable {
    private var holder: MsgpackElementConvertable?
    private var userInfo: [CodingUserInfoKey: Any]
    var codingPath: [any CodingKey]

    init(codingPath: [any CodingKey], userInfo: [CodingUserInfoKey: Any]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    func encodeNil() throws {
        holder = MsgpackElement.null
    }

    func convertToMsgpackElement() throws -> MsgpackElement {
        guard let holder = holder else {
            return MsgpackElement.null
        }
        return try holder.convertToMsgpackElement()
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        guard let msgpackElement = MsgpackElement(value) else {
            let encoder = MsgpackEncoder(
                codingPath: codingPath, userInfo: self.userInfo
            )
            try value.encode(to: encoder)
            self.holder = encoder
            return
        }
        self.holder = msgpackElement
    }
}

// MARK: internal protocols
private protocol MsgpackSwitchKeyProtocol {
    func switchKey<NewKey: CodingKey>(newKey: NewKey.Type)
        -> MsgpackKeyedEncodingContainer<NewKey>
}

protocol MsgpackElementConvertable {
    func convertToMsgpackElement() throws -> MsgpackElement
}

// MARK: (Encoding Part) Intermediate type which implements messagepack protocol. Similar to JSonObject
extension MsgpackElement: MsgpackElementConvertable {
    // MARK: Convert basic Swift type to MsgpackElement
    init?<T>(_ value: T) where T: Encodable {
        switch value {
        case let number as Int:
            self = .int(Int64(number))
        case let number as Int8:
            self = .int(Int64(number))
        case let number as Int16:
            self = .int(Int64(number))
        case let number as Int32:
            self = .int(Int64(number))
        case let number as Int64:
            self = .int(number)
        case let number as UInt8:
            self = .uint(UInt64(number))
        case let number as UInt16:
            self = .uint(UInt64(number))
        case let number as UInt32:
            self = .uint(UInt64(number))
        case let number as UInt64:
            self = .uint(number)
        case let string as String:
            self = .string(string)
        case let data as Data:
            self = .bin(data)
        case let bool as Bool:
            self = .bool(bool)
        case let float32 as Float32:
            self = .float32(float32)
        case let float64 as Float64:
            self = .float64(float64)
        default:
            // Leave other encodable types to Encodable protocol
            return nil
        }
    }

    func convertToMsgpackElement() throws -> MsgpackElement {
        return self
    }

    // MARK: Convert MsgpackElement to Data
    func marshall() throws -> Data {
        switch self {
        case .int(let number):
            return Self.encodeInt64(number)
        case .uint(let number):
            return Self.encodeUInt64(number)
        case .float32(let float32):
            return Self.encodeFloat32(float32)
        case .float64(let float64):
            return Self.encodeFloat64(float64)
        case .bool(let bool):
            return Self.encodeBool(bool)
        case .string(let s):
            return try Self.encodeString(s)
        case .null:
            return Self.encodeNil()
        case .bin(let data):
            return try Self.encodeData(data)
        case .map(let m):
            return try Self.encodeMap(m)
        case .array(let a):
            return try Self.encodeArray(a)
        case .ext(let type, let data):
            return try Self.encodeExt(type: type, data: data)
        }
    }

    private static func encodeUInt64(_ v: UInt64) -> Data {
        if v <= Int8.max {
            var uint8 = UInt8(v)
            return Data(bytes: &uint8, count: MemoryLayout<UInt8>.size)
        }
        if v <= UInt8.max {
            var uint8 = UInt8(v)
            return [0xcc] + Data(bytes: &uint8, count: MemoryLayout<UInt8>.size)
        }
        if v <= UInt16.max {
            var uint16 = UInt16(v).bigEndian
            return [0xcd]
                + Data(bytes: &uint16, count: MemoryLayout<UInt16>.size)
        }
        if v <= UInt32.max {
            var uint32 = UInt32(v).bigEndian
            return [0xce]
                + Data(bytes: &uint32, count: MemoryLayout<UInt32>.size)
        }
        var uint64 = v.bigEndian
        return [0xcf] + Data(bytes: &uint64, count: MemoryLayout<UInt64>.size)
    }

    private static func encodeInt64(_ v: Int64) -> Data {
        guard v < 0 else {
            return Self.encodeUInt64(UInt64(v))
        }
        if v >= -(1 << 5) {
            var int8 = Int8(v)
            return Data(bytes: &int8, count: MemoryLayout<Int8>.size)
        }
        if v >= Int8.min {
            var int8 = Int8(v)
            return [0xd0] + Data(bytes: &int8, count: MemoryLayout<Int8>.size)
        }
        if v >= Int16.min {
            var int16 = Int16(v).bigEndian
            return [0xd1] + Data(bytes: &int16, count: MemoryLayout<Int16>.size)
        }
        if v >= Int32.min {
            var int32 = Int32(v).bigEndian
            return [0xd2] + Data(bytes: &int32, count: MemoryLayout<Int32>.size)
        }
        var int64 = v.bigEndian
        return [0xd3] + Data(bytes: &int64, count: MemoryLayout<Int64>.size)
    }

    private static func encodeFloat32(_ v: Float32) -> Data {
        var float32BigEdianbits = v.bitPattern.bigEndian
        return [0xca]
            + Data(
                bytes: &float32BigEdianbits, count: MemoryLayout<Float32>.size
            )
    }

    private static func encodeFloat64(_ v: Float64) -> Data {
        var float64BigEdianbits = v.bitPattern.bigEndian
        return [0xcb]
            + Data(
                bytes: &float64BigEdianbits, count: MemoryLayout<Float64>.size
            )
    }

    private static func encodeString(_ v: String) throws -> Data {
        let length = v.count
        let content = v.data(using: .utf8)!
        if length < 1 << 5 {
            return [0xa0 | UInt8(length)] + content
        }
        if length <= UInt8.max {
            return [0xd9, UInt8(length)] + content
        }
        if length <= UInt16.max {
            var uint16 = UInt16(length).bigEndian
            return [0xda]
                + Data(bytes: &uint16, count: MemoryLayout<UInt16>.size)
                + content
        }
        if length <= UInt32.max {
            var uint32 = UInt32(length).bigEndian
            return [0xdb]
                + Data(bytes: &uint32, count: MemoryLayout<UInt32>.size)
                + content
        }
        throw MsgpackEncodingError.stringTooLarge
    }

    private static func encodeBool(_ v: Bool) -> Data {
        return v ? Data([0xc3]) : Data([0xc2])
    }

    private static func encodeNil() -> Data {
        return Data([0xc0])
    }

    private static func encodeData(_ v: Data) throws -> Data {
        let length = v.count
        var lengthPrefix: Data
        if length <= UInt8.max {
            var uint8 = UInt8(length)
            lengthPrefix =
                [0xc4] + Data(bytes: &uint8, count: MemoryLayout<UInt8>.size)
        } else if length <= UInt16.max {
            var uint16 = UInt16(length).bigEndian
            lengthPrefix =
                [0xc5] + Data(bytes: &uint16, count: MemoryLayout<UInt16>.size)
        } else if length <= UInt32.max {
            var uint32 = UInt32(length).bigEndian
            lengthPrefix =
                [0xc6] + Data(bytes: &uint32, count: MemoryLayout<UInt32>.size)
        } else {
            throw MsgpackEncodingError.dataTooLarge
        }
        return lengthPrefix + v
    }

    private static func encodeMap(_ v: [String: MsgpackElement]) throws -> Data {
        let length = v.count
        var mapPrefix: Data
        if length < 1 << 4 {
            mapPrefix = Data([0x80 | UInt8(length)])
        } else if length <= UInt16.max {
            var uint16 = UInt16(length).bigEndian
            mapPrefix =
                [0xde] + Data(bytes: &uint16, count: MemoryLayout<UInt16>.size)
        } else if length <= UInt32.max {
            var uint32 = UInt32(length).bigEndian
            mapPrefix =
                [0xdf] + Data(bytes: &uint32, count: MemoryLayout<UInt32>.size)
        } else {
            throw MsgpackEncodingError.mapTooManyElements
        }
        var list: [Data] = []
        var totalLength = mapPrefix.count
        for (k, v) in v {
            let kData = try Self.encodeString(k)
            totalLength += kData.count
            list.append(kData)
            let vData = try v.marshall()
            totalLength += vData.count
            list.append(vData)
        }
        var result = Data(capacity: totalLength)
        result.append(mapPrefix)
        for v in list {
            result.append(v)
        }
        return result
    }

    private static func encodeArray(_ v: [MsgpackElement]) throws -> Data {
        let length = v.count
        var arrayPrefix: Data
        if length < 1 << 4 {
            arrayPrefix = Data([0x90 | UInt8(length)])
        } else if length <= UInt16.max {
            var uint16 = UInt16(length).bigEndian
            arrayPrefix =
                [0xdc] + Data(bytes: &uint16, count: MemoryLayout<UInt16>.size)
        } else if length <= UInt32.max {
            var uint32 = UInt32(length).bigEndian
            arrayPrefix =
                [0xdd] + Data(bytes: &uint32, count: MemoryLayout<UInt32>.size)
        } else {
            throw MsgpackEncodingError.arrayTooManyElements
        }
        var list: [Data] = []
        var totalLength = arrayPrefix.count
        for v in v {
            let vData = try v.marshall()
            totalLength += vData.count
            list.append(vData)
        }
        var result = Data(capacity: totalLength)
        result.append(arrayPrefix)
        for v in list {
            result.append(v)
        }
        return result
    }

    private static func encodeExt(type: Int8, data: Data) throws -> Data {
        let length = data.count
        var int8 = Int8(type)
        let typeData = Data(bytes: &int8, count: MemoryLayout<Int8>.size)
        if length == 1 {
            return [0xd4] + typeData + data
        }
        if length == 2 {
            return [0xd5] + typeData + data
        }
        if length == 4 {
            return [0xd6] + typeData + data
        }
        if length == 8 {
            return [0xd7] + typeData + data
        }
        if length == 16 {
            return [0xd8] + typeData + data
        }
        if length <= UInt8.max {
            return [0xc7, UInt8(length)] + typeData + data
        }
        if length <= UInt16.max {
            var uint16 = UInt16(length).bigEndian
            let uint16Data = Data(
                bytes: &uint16, count: MemoryLayout<UInt16>.size
            )
            return [0xc8] + uint16Data + typeData + data
        }
        if length <= UInt32.max {
            var uint32 = UInt32(length).bigEndian
            let uint32Data = Data(
                bytes: &uint32, count: MemoryLayout<UInt32>.size
            )
            return [0xc9] + uint32Data + typeData + data
        }
        throw MsgpackEncodingError.extensionTooLarge
    }
}

// Encode Msgpacktimestamp to extension type -1
extension MsgpackTimestamp: Encodable {
    public func encode(to encoder: any Encoder) throws {
        let nanoseconds = self.nanoseconds
        let seconds = self.seconds
        var data: Data
        if nanoseconds == 0 && seconds >= 0 && seconds <= UInt32.max {
            var secondsUInt32 = UInt32(seconds).bigEndian
            data = Data(bytes: &secondsUInt32, count: MemoryLayout<UInt32>.size)
        } else if seconds >= 0 && seconds < (UInt64(1)) << 34 {
            let secondsUInt64 = UInt64(seconds).bigEndian
            let nanoSecondsUInt64 = (UInt64(nanoseconds) << 34).bigEndian
            var time = nanoSecondsUInt64 | secondsUInt64
            data = Data(bytes: &time, count: MemoryLayout<UInt64>.size)
        } else {
            var secondsInt64 = seconds.bigEndian
            var nanoSecondsUInt32 = UInt32(nanoseconds).bigEndian
            data =
                Data(
                    bytes: &nanoSecondsUInt32, count: MemoryLayout<UInt32>.size
                )
                + Data(bytes: &secondsInt64, count: MemoryLayout<Int64>.size)
        }
        return try encoder.encodeMsgpackExt(extType: -1, extData: data)
    }
}

// MARK: Encoding error handling
enum MsgpackEncodingError: Error, CustomStringConvertible {
    // exposed exception
    case dataTooLarge
    case mapTooManyElements
    case arrayTooManyElements
    case stringTooLarge
    case extensionTooLarge

    // internal exception
    case encoderNotIntilized

    var description: String {
        switch self {
        case .dataTooLarge:
            return "Messagpack can't encode binary larger than 4GB"
        case .mapTooManyElements:
            return "Messagpack can't encode map with more than 4G keys"
        case .arrayTooManyElements:
            return "Messagpack can't encode array with more than 4G elements"
        case .stringTooLarge:
            return "Messagpack can't encode string larger than 4GB"
        case .extensionTooLarge:
            return "Messagpack can't encode extension larger than 4GB"
        default:
            return ""
        }
    }
}



---
File: /Sources/SignalRClient/Protocols/BinaryMessageFormat.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

// TODO: Move messagepack to a separate package
class BinaryMessageFormat {
    private static let MessageSize2GB: Int = 1 << 31

    static func parse(_ data: Data) throws -> [Data] {
        var messages: [Data] = []
        var index = 0

        while index < data.count {
            var number: UInt64 = 0
            var numberBytes = 0
            while numberBytes <= 5 {
                guard index < data.count else {
                    throw SignalRError.incompleteMessage
                }
                let byte: UInt64 = UInt64(data[index])
                number = number | (byte & 0x7f) << (7 * numberBytes)
                numberBytes += 1
                index += 1
                if byte & 0x80 == 0 {
                    break
                }
            }
            guard numberBytes <= 5 else {
                throw SignalRError.invalidData("Invalid message size")
            }
            guard number <= MessageSize2GB else {
                throw SignalRError.messageBiggerThan2GB
            }
            guard number > 0 else {
                continue
            }
            if index + Int(number) > data.count {
                throw SignalRError.incompleteMessage
            }
            let message = data.subdata(in: index ..< (index + Int(number)))
            messages.append(message)
            index += Int(number)
        }
        return messages
    }

    static func write(_ data: Data) throws -> Data {
        var number = data.count
        guard number <= MessageSize2GB else {
            throw SignalRError.messageBiggerThan2GB
        }
        var bytes: [UInt8] = []
        repeat {
            var byte = (UInt8)(number & 0x7f)
            number >>= 7
            if number > 0 {
                byte |= 0x80
            }
            bytes.append(byte)
        } while number > 0
        return Data(bytes) + data
    }
}



---
File: /Sources/SignalRClient/Protocols/HubMessage.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/// Defines properties common to all Hub messages.
protocol HubMessage: Encodable {
    /// A value indicating the type of this message.
    var type: MessageType { get }
}

/// Defines properties common to all Hub messages relating to a specific invocation.
protocol HubInvocationMessage: HubMessage {
    /// A dictionary containing headers attached to the message.
    var headers: [String: String]? { get }
    /// The ID of the invocation relating to this message.
    var invocationId: String? { get }
}

/// A hub message representing a non-streaming invocation.
struct InvocationMessage: HubInvocationMessage {
    /// The type of this message.
    let type: MessageType = .invocation
    /// The target method name.
    let target: String
    /// The target method arguments.
    let arguments: AnyEncodableArray
    /// The target methods stream IDs.
    let streamIds: [String]?
    /// Headers attached to the message.
    let headers: [String: String]?
    /// The ID of the invocation relating to this message.
    let invocationId: String?
}

/// A hub message representing a streaming invocation.
struct StreamInvocationMessage: HubInvocationMessage {
    /// The type of this message.
    let type: MessageType = .streamInvocation
    /// The invocation ID.
    let invocationId: String?
    /// The target method name.
    let target: String
    /// The target method arguments.
    let arguments: AnyEncodableArray
    /// The target methods stream IDs.
    let streamIds: [String]?
    /// Headers attached to the message.
    let headers: [String: String]?
}

/// A hub message representing a single item produced as part of a result stream.
struct StreamItemMessage: HubInvocationMessage {
    /// The type of this message.
    let type: MessageType = .streamItem
    /// The invocation ID.
    let invocationId: String?
    /// The item produced by the server.
    let item: AnyEncodable
    /// Headers attached to the message.
    let headers: [String: String]?
}

/// A hub message representing the result of an invocation.
struct CompletionMessage: HubInvocationMessage {
    /// The type of this message.
    let type: MessageType = .completion
    /// The invocation ID.
    let invocationId: String?
    /// The error produced by the invocation, if any.
    let error: String?
    /// The result produced by the invocation, if any.
    let result: AnyEncodable
    /// Headers attached to the message.
    let headers: [String: String]?
}

/// A hub message indicating that the sender is still active.
struct PingMessage: HubMessage {
    /// The type of this message.
    let type: MessageType = .ping
}

/// A hub message indicating that the sender is closing the connection.
struct CloseMessage: HubMessage {
    /// The type of this message.
    let type: MessageType = .close
    /// The error that triggered the close, if any.
    let error: String?
    /// If true, clients with automatic reconnects enabled should attempt to reconnect after receiving the CloseMessage.
    let allowReconnect: Bool?
}

/// A hub message sent to request that a streaming invocation be canceled.
struct CancelInvocationMessage: HubInvocationMessage {
    /// The type of this message.
    let type: MessageType = .cancelInvocation
    /// The invocation ID.
    let invocationId: String?
    /// Headers attached to the message.
    let headers: [String: String]?
}

/// A hub message representing an acknowledgment.
struct AckMessage: HubMessage {
    /// The type of this message.
    let type: MessageType = .ack
    /// The sequence ID.
    let sequenceId: Int64
}

/// A hub message representing a sequence.
struct SequenceMessage: HubMessage {
    /// The type of this message.
    let type: MessageType = .sequence
    /// The sequence ID.
    let sequenceId: Int64
}

/// A type-erased Codable value.
struct AnyEncodable: Encodable {
    public let value: Any?

    init(_ value: Any?) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        // Null
        guard let value = value else {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
            return
        }

        // Primitives and Encodable custom class
        if let encodable = value as? Encodable {
            try encodable.encode(to: encoder)
            return
        }

        // Array
        if let array = value as? [Any] {
            try AnyEncodableArray(array).encode(to: encoder)
            return
        }

        // Dictionary
        if let dictionary = value as? [String: Any] {
            try AnyEncodableDictionary(dictionary).encode(to: encoder)
            return
        }

        // Unsupported type
        throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
    }
}

struct AnyEncodableArray: Encodable {
    public let value: [Any?]?

    init(_ array: [Any?]?) {
        self.value = array
    }

    func encode(to encoder: Encoder) throws {
        guard let value = value else {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
            return
        }

        var container = encoder.unkeyedContainer()
        for value in value {
            try AnyEncodable(value).encode(to: container.superEncoder())
        }
    }
}

struct AnyEncodableDictionary: Encodable {
    public let value: [String: Any]?

    init(_ dictionary: [String: Any]?) {
        self.value = dictionary
    }

    func encode(to encoder: Encoder) throws {
        guard let value = value else {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
            return
        }

        var container = encoder.container(keyedBy: AnyEncodableCodingKey.self)
        for (key, value) in value {
            let codingKey = AnyEncodableCodingKey(stringValue: key)!
            try AnyEncodable(value).encode(to: container.superEncoder(forKey: codingKey))
        }
    }
}

struct AnyEncodableCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}



---
File: /Sources/SignalRClient/Protocols/HubProtocol.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

protocol HubProtocol: Sendable {
    /// The name of the protocol. This is used by SignalR to resolve the protocol between the client and server.
    var name: String { get }
    /// The version of the protocol.
    var version: Int { get }
    /// The transfer format of the protocol.
    var transferFormat: TransferFormat { get }

    /**
     Creates an array of `HubMessage` objects from the specified serialized representation.

     If `transferFormat` is 'Text', the `input` parameter must be a String, otherwise it must be Data.

     - Parameters:
       - input: A Data containing the serialized representation.
     - Returns: An array of `HubMessage` objects.
     */
    func parseMessages(input: StringOrData, binder: InvocationBinder) throws -> [HubMessage]

    /**
     Writes the specified `HubMessage` to a String or Data and returns it.

     If `transferFormat` is 'Text', the result of this method will be a String, otherwise it will be Data.

     - Parameter message: The message to write.
     - Returns: A Data containing the serialized representation of the message.
     */
    func writeMessage(message: HubMessage) throws -> StringOrData
}

public enum StringOrData: Sendable, Equatable {
    case string(String)
    case data(Data)
}



---
File: /Sources/SignalRClient/Protocols/JsonHubProtocol.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

struct JsonHubProtocol: HubProtocol {
    let name = "json"
    let version = 1
    let transferFormat: TransferFormat = .text

    func parseMessages(input: StringOrData, binder: InvocationBinder) throws -> [HubMessage] {
        let inputString: String
        switch input {
        case .string(let str):
            inputString = str
        case .data:
            throw SignalRError.invalidData("Invalid input for JSON hub protocol. Expected a string.")
        }

        if inputString.isEmpty {
            return []
        }

        let messages = try TextMessageFormat.parse(inputString)
        var hubMessages = [HubMessage]()

        for message in messages {
            guard let data = message.data(using: .utf8) else {
                throw SignalRError.invalidData("Failed to convert message to data.")
            }
            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let type = jsonObject["type"] as? Int {
                switch type {
                case 1:
                    let result = try DecodeInvocationMessage(jsonObject, binder: binder)
                    hubMessages.append(result)
                case 2:
                    let result = try DecodeStreamItemMessage(jsonObject, binder: binder)
                    hubMessages.append(result)
                case 3:
                    let result = try DecodeCompletionMessage(jsonObject, binder: binder)
                    hubMessages.append(result)
                case 4:
                    let result = try DecodeStreamInvocationMessage(jsonObject, binder: binder)
                    hubMessages.append(result)
                case 5:
                    let result = try DecodeCancelInvocationMessage(jsonObject)
                    hubMessages.append(result)
                case 6:
                    let result = try DecodePingMessage(jsonObject)
                    hubMessages.append(result)
                case 7:
                    let result = try DecodeCloseMessage(jsonObject)
                    hubMessages.append(result)
                case 8:
                    let result = try DecodeAckMessage(jsonObject)
                    hubMessages.append(result)
                case 9:
                    let result = try DecodeSequenceMessage(jsonObject)
                    hubMessages.append(result)
                default:
                    // Unknown message type
                    break
                }
            }
        }

        return hubMessages
    }

    func writeMessage(message: HubMessage) throws -> StringOrData {
        let jsonData = try JSONEncoder().encode(message)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw SignalRError.invalidData("Failed to convert JSON data to string.")
        }
        return .string(TextMessageFormat.write(jsonString))
    }

    private func DecodeInvocationMessage(_ jsonObject: [String: Any], binder: InvocationBinder) throws -> InvocationMessage {
        guard let target = jsonObject["target"] as? String else {
            throw SignalRError.invalidData("'target' not found in JSON object for InvocationMessage.")
        }

        let streamIds = jsonObject["streamIds"] as? [String]
        let headers = jsonObject["headers"] as? [String: String]
        let invocationId = jsonObject["invocationId"] as? String
        let typedArguments = try DecodeArguments(jsonObject, types: binder.getParameterTypes(methodName: target))

        return InvocationMessage(target: target, arguments: typedArguments, streamIds: streamIds, headers: headers, invocationId: invocationId)
    }

    private func DecodeStreamInvocationMessage(_ jsonObject: [String: Any], binder: InvocationBinder) throws -> StreamInvocationMessage {
        guard let target = jsonObject["target"] as? String else {
            throw SignalRError.invalidData("'target' not found in JSON object for StreamInvocationMessage.")
        }

        let streamIds = jsonObject["streamIds"] as? [String]
        let headers = jsonObject["headers"] as? [String: String]
        let invocationId = jsonObject["invocationId"] as? String
        let typedArguments = try DecodeArguments(jsonObject, types: binder.getParameterTypes(methodName: target))

        return StreamInvocationMessage(invocationId: invocationId, target: target, arguments: typedArguments, streamIds: streamIds, headers: headers)
    }

    private func DecodeStreamItemMessage(_ jsonObject: [String: Any], binder: InvocationBinder) throws -> StreamItemMessage {
        guard let invocationId = jsonObject["invocationId"] as? String else {
            throw SignalRError.invalidData("'invocationId' not found in JSON object for StreamItemMessage.")
        }

        let headers = jsonObject["headers"] as? [String: String]
        let typedItem = try DecodeStreamItem(jsonObject, type: binder.getStreamItemType(streamId: invocationId))

        return StreamItemMessage(invocationId: invocationId, item: typedItem, headers: headers)
    }

    private func DecodeCompletionMessage(_ jsonObject: [String: Any], binder: InvocationBinder) throws -> CompletionMessage {
        guard let invocationId = jsonObject["invocationId"] as? String else {
            throw SignalRError.invalidData("'invocationId' not found in JSON object for CompletionMessage.")
        }

        let headers = jsonObject["headers"] as? [String: String]
        let error = jsonObject["error"] as? String
        let result = try DecodeCompletionResult(jsonObject, type: binder.getReturnType(invocationId: invocationId))

        return CompletionMessage(invocationId: invocationId, error: error, result: result, headers: headers)
    }

    private func DecodeCancelInvocationMessage(_ jsonObject: [String: Any]) throws -> CancelInvocationMessage {
        guard let invocationId = jsonObject["invocationId"] as? String else {
            throw SignalRError.invalidData("'invocationId' not found in JSON object for CancelInvocationMessage.")
        }

        let headers = jsonObject["headers"] as? [String: String]
        return CancelInvocationMessage(invocationId: invocationId, headers: headers)
    }

    private func DecodePingMessage(_ jsonObject: [String: Any]) throws -> PingMessage {
        return PingMessage()
    }

    private func DecodeCloseMessage(_ jsonObject: [String: Any]) throws -> CloseMessage {
        let error = jsonObject["error"] as? String
        let allowReconnect = jsonObject["allowReconnect"] as? Bool

        return CloseMessage(error: error, allowReconnect: allowReconnect)
    }

    private func DecodeAckMessage(_ jsonObject: [String: Any]) throws -> AckMessage {
        guard let sequenceId = jsonObject["sequenceId"] as? Int64 else {
            throw SignalRError.invalidData("'sequenceId' not found in JSON object for AckMessage.")
        }

        return AckMessage(sequenceId: sequenceId)
    }

    private func DecodeSequenceMessage(_ jsonObject: [String: Any]) throws -> SequenceMessage {
        guard let sequenceId = jsonObject["sequenceId"] as? Int64 else {
            throw SignalRError.invalidData("'sequenceId' not found in JSON object for SequenceMessage.")
        }

        return SequenceMessage(sequenceId: sequenceId)
    }

    private func DecodeArguments(_ jsonObject: [String: Any], types: [Any.Type]) throws -> AnyEncodableArray {
        let arguments = jsonObject["arguments"] as? [Any] ?? []
        guard arguments.count == types.count else {
            throw SignalRError.invalidData("Invocation provides \(arguments.count) argument(s) but target expects \(types.count).")
        }

        return AnyEncodableArray(try zip(arguments, types).map { (arg, type) in
            return try convertToType(arg, as: type)
        })
    }

    private func DecodeStreamItem(_ jsonObject: [String: Any], type: Any.Type?) throws -> AnyEncodable {
        let item = jsonObject["item"]
        if isNil(item) {
            return AnyEncodable(nil)
        }

        guard type != nil else {
            throw SignalRError.invalidData("No item type found in binder.")
        }

        return try AnyEncodable(convertToType(item!, as: type!))
    }

    private func DecodeCompletionResult(_ jsonObject: [String: Any], type: Any.Type?) throws -> AnyEncodable {
        let result = jsonObject["result"]
        if isNil(result) || type == nil {
            return AnyEncodable(nil)
        }

        return try AnyEncodable(convertToType(result!, as: type!))
    }

    private func convertToType(_ anyObject: Any, as targetType: Any.Type) throws -> Any {
        guard let decodableType = targetType as? Decodable.Type else {
            throw SignalRError.invalidData("Provided type \(targetType) does not conform to Decodable.")
        }

        // Convert dictionary / array to JSON data
        if (JSONSerialization.isValidJSONObject(anyObject)) {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: anyObject) else {
                throw SignalRError.invalidData("Failed to serialize to JSON data.")
            }

            let decoder = JSONDecoder()
            let decodedObject = try decoder.decode(decodableType, from: jsonData)
            return decodedObject
        }

        // primay elements
        return anyObject
    }

    private func isNil(_ obj: Any?) -> Bool {
        if obj == nil || obj is NSNull {
            return true
        }
        return false
    }
}



---
File: /Sources/SignalRClient/Protocols/MessagePackHubProtocol.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

final class MessagePackHubProtocol: HubProtocol {
    let name = "messagepack"
    let version = 1
    let transferFormat: TransferFormat = .binary

    func parseMessages(input: StringOrData, binder: any InvocationBinder) throws
    -> [any HubMessage] {
        var data: Data
        switch input {
        case .string(_):
            throw SignalRError.invalidData(
                "Invalid input for MessagePack hub protocol. Expected Data.")
        case .data(let d):
            data = d
            break
        }
        var hubMessages: [HubMessage] = []
        let messages = try BinaryMessageFormat.parse(data)
        for message in messages {
            guard
                let hubMessage = try parseMessage(
                    message: message, binder: binder
                )
            else {
                continue
            }
            hubMessages.append(hubMessage)
        }

        return hubMessages
    }

    func writeMessage(message: any HubMessage) throws -> StringOrData {
        var arr: [Any?]
        switch message {
        case let message as InvocationMessage:
            arr = [
                message.type, message.headers ?? [:], message.invocationId,
                message.target, message.arguments,
            ]
            if message.streamIds != nil {
                arr.append(message.streamIds)
            }
        case let message as StreamInvocationMessage:
            arr = [
                message.type, message.headers ?? [:], message.invocationId,
                message.target, message.arguments,
            ]
            if message.streamIds != nil {
                arr.append(message.streamIds)
            }
        case let message as PingMessage:
            arr = [message.type]
        case let message as CloseMessage:
            arr =
                [message.type, message.error]
        case let message as CancelInvocationMessage:
            arr = [
                message.type, message.headers ?? [:], message.invocationId,
            ]
        case let message as StreamItemMessage:
            arr = [
                message.type, message.headers ?? [:], message.invocationId,
                message.item,
            ]
        case let message as SequenceMessage:
            arr = [message.type, message.sequenceId]
        case let message as AckMessage:
            arr = [message.type, message.sequenceId]
        case let message as CompletionMessage:
            if message.error != nil {
                arr = [
                    message.type, message.headers ?? [:], message.invocationId,
                    1,
                    message.error,
                ]
                // Set ResultKind = 2 will trigger a server side issue
//            } else if message.result.value == nil {
//                arr = [
//                    message.type, message.headers ?? [:], message.invocationId,
//                    2
//                ]
            } else {
                arr = [
                    message.type, message.headers ?? [:], message.invocationId,
                    3,
                    message.result.value,
                ]
            }
        default:
            throw SignalRError.unexpectedMessageType("\(type(of: message))")
        }
        let messageData = try MsgpackEncoder().encode(
            AnyEncodableArray(arr))
        return try .data(BinaryMessageFormat.write(messageData))
    }

    func parseMessage(message: Data, binder: any InvocationBinder)
    throws -> HubMessage? {
        let (msgpackElement, _) = try MsgpackElement.parse(data: message)
        let decoder = MsgpackDecoder()
        try decoder.loadMsgpackElement(from: msgpackElement)
        var container = try decoder.unkeyedContainer()
        guard
            let messageType = MessageType(
                rawValue: try container.decode(Int.self))
        else {
            // TODO: log new type
            return nil
        }
        switch messageType {
        case MessageType.invocation:
            guard container.count! >= 4 else {
                throw SignalRError.invalidData(
                    "Invalid payload for Invocation message."
                )
            }
            let headers = try container.decode([String: String]?.self)
            let invocationId = try container.decode(String?.self)
            let target = try container.decode(String.self)
            let argumentTypes = binder.getParameterTypes(methodName: target)
            var subContainer = try container.nestedUnkeyedContainer()
            var arguments: [Any] = []
            for t in argumentTypes {
                guard let argumentType = t as? Decodable.Type else {
                    throw SignalRError.invalidData(
                        "Provided type \(t) does not conform to Decodable.")
                }
                let argument = try subContainer.decode(argumentType)
                arguments.append(argument)
            }
            return
                InvocationMessage(
                    target: target, arguments: AnyEncodableArray(arguments),
                    streamIds: [],
                    headers: headers, invocationId: invocationId
                )

        case MessageType.streamItem:
            guard container.count! >= 4 else {
                throw SignalRError.invalidData(
                    "Invalid payload for StreamItem message.")
            }
            let headers = try container.decode([String: String]?.self)
            let invocationId = try container.decode(String.self)
            guard
                let streamItemType = binder.getStreamItemType(
                    streamId: invocationId) as? Decodable.Type
            else {
                throw SignalRError.invalidData("No item type found in binder.")
            }
            let item = try container.decode(streamItemType)
            return StreamItemMessage(
                invocationId: invocationId, item: AnyEncodable(item),
                headers: headers
            )

        case MessageType.completion:
            guard container.count! >= 4 else {
                throw SignalRError.invalidData(
                    "Invalid payload for Completion message.")
            }
            let headers = try container.decode([String: String]?.self)
            let invocationId = try container.decode(String.self)
            let resultKind = try container.decode(Int8.self)
            guard resultKind == 2 || container.count! >= 5 else {
                throw SignalRError.invalidData(
                    "Invalid payload for Completion message.")
            }
            var error: String? = nil
            var result: Any? = nil
            switch resultKind {
            case 1:
                error = try container.decode(String?.self)
            case 2:
                break
            case 3:
                guard
                    let returnType = binder.getReturnType(
                        invocationId: invocationId)
                else {
                    break
                }
                guard
                    let returnType = returnType as? Decodable.Type
                else {
                    throw SignalRError.invalidData(
                        "Provided type \(returnType) does not conform to Decodable.")
                }
                result = try container.decode(returnType)
            default:
                // new result type. Ignore
                break
            }
            return CompletionMessage(
                invocationId: invocationId, error: error,
                result: AnyEncodable(result), headers: headers
            )

        case MessageType.cancelInvocation:
            guard container.count! >= 3 else {
                throw SignalRError.invalidData(
                    "Invalid payload for CancelInvocation message.")
            }
            let headers = try container.decode([String: String]?.self)
            let invocationId = try container.decode(String?.self)
            return CancelInvocationMessage(
                invocationId: invocationId,
                headers: headers
            )

        case MessageType.ping:
            return PingMessage()

        case MessageType.close:
            guard container.count! >= 2 else {
                throw SignalRError.invalidData(
                    "Invalid payload for Close message.")
            }
            let err = try container.decode(String?.self)
            let allowReconnect =
                container.isAtEnd ? nil : try container.decode(Bool?.self)
            return CloseMessage(error: err, allowReconnect: allowReconnect)

        case MessageType.ack:
            guard container.count! >= 2 else {
                throw SignalRError.invalidData(
                    "Invalid payload for Ack message.")
            }
            let sequenceId = try container.decode(Int64.self)
            return AckMessage(sequenceId: sequenceId)

        case MessageType.sequence:
            guard container.count! >= 2 else {
                throw SignalRError.invalidData(
                    "Invalid payload for Sequence message.")
            }
            let sequenceId = try container.decode(Int64.self)
            return SequenceMessage(sequenceId: sequenceId)

        default:
            // StreamInvocation is not supported at client side
            return nil
        }
    }
}



---
File: /Sources/SignalRClient/Protocols/MessageType.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/// Defines the type of a Hub Message.
public enum MessageType: Int, Codable {
    /// Indicates the message is an Invocation message.
    case invocation = 1
    /// Indicates the message is a StreamItem message.
    case streamItem = 2
    /// Indicates the message is a Completion message.
    case completion = 3
    /// Indicates the message is a Stream Invocation message.
    case streamInvocation = 4
    /// Indicates the message is a Cancel Invocation message.
    case cancelInvocation = 5
    /// Indicates the message is a Ping message.
    case ping = 6
    /// Indicates the message is a Close message.
    case close = 7
    /// Indicates the message is an Acknowledgment message.
    case ack = 8
    /// Indicates the message is a Sequence message.
    case sequence = 9
}


---
File: /Sources/SignalRClient/Protocols/TextMessageFormat.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

class TextMessageFormat {
    static let recordSeparatorCode: UInt8 = 0x1e
    static let recordSeparator = String(UnicodeScalar(recordSeparatorCode))

    static func write(_ output: String) -> String {
        return "\(output)\(recordSeparator)"
    }

    static func parse(_ input: String) throws -> [String] {
        guard input.last == Character(recordSeparator) else {
            throw SignalRError.incompleteMessage
        }

        var messages = input.split(separator: Character(recordSeparator)).map { String($0) }
        if let last = messages.last, last.isEmpty {
            messages.removeLast()
        }
        return messages
    }
}


---
File: /Sources/SignalRClient/Transport/EventSource.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

// A SSE client implementation compatible with SignalR server.
// Assumptions:
//   1. No BOM charactor.
//   2. Connect is only called once
// Below features are not implemented as SignalR doesn't rely on them:
//  1. Reconnect, last Id
//  2. event name, event handlers
class EventSource: NSObject, URLSessionDataDelegate {
    private let url: URL
    private let headers: [String: String]
    private let parser: EventParser
    private var openHandler: (() -> Void)?
    private var completeHandler: ((Int?, Error?) -> Void)?
    private var messageHandler: ((String) -> Void)?
    private var urlSession: URLSession?

    init(url: URL, headers: [String: String]?) {
        self.url = url
        var headers = headers ?? [:]
        headers["Accept"] = "text/event-stream"
        headers["Cache-Control"] = "no-cache"
        self.headers = headers
        self.parser = EventParser()
    }

    func connect() {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = self.headers
        config.timeoutIntervalForRequest = TimeInterval.infinity
        config.timeoutIntervalForResource = TimeInterval.infinity
        self.urlSession = URLSession(
            configuration: config, delegate: self, delegateQueue: nil
        )
        self.urlSession!.dataTask(with: url).resume()
    }

    func disconnect() {
        self.urlSession?.invalidateAndCancel()
    }

    func onOpen(openHandler: @escaping (() -> Void)) {
        self.openHandler = openHandler
    }

    func onComplete(
        completionHandler: @escaping (Int?, Error?) -> Void
    ) {
        self.completeHandler = completionHandler
    }

    func onMessage(messageHandler: @escaping (String) -> Void) {
        self.messageHandler = messageHandler
    }

    // MARK: redirect
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        var newRequest = request
        self.headers.forEach { key, value in
            newRequest.setValue(value, forHTTPHeaderField: key)
        }
        completionHandler(newRequest)
    }

    // MARK: open
    public func urlSession(
        _ session: URLSession, dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping @Sendable (URLSession.ResponseDisposition)
            -> Void
    ) {
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        if statusCode == 200 {
            self.openHandler?()
        }
        // forward anyway
        completionHandler(URLSession.ResponseDisposition.allow)
    }

    // MARK: data
    public func urlSession(
        _ session: URLSession, dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        parser.Parse(data: data).forEach { event in
            self.messageHandler?(event)
        }
    }

    // MARK: complete
    public func urlSession(
        _ session: URLSession, task: URLSessionTask,
        didCompleteWithError error: (any Error)?
    ) {
        let statusCode = (task.response as? HTTPURLResponse)?.statusCode
        self.completeHandler?(statusCode, error)
    }
}

// The parser supports both "\n" and "\r\n" as field separator. "\r" is rarely used practically thus not supported for simplicity.
// Comments and fields other than "data" are silently dropped.
class EventParser {
    static let cr = Character("\r").asciiValue!
    static let ln = Character("\n").asciiValue!
    static let dot = Character(":").asciiValue!
    static let space = Character(" ").asciiValue!
    static let data = "data".data(using: .utf8)!

    private var lines: [String]
    private var buffer: Data

    init() {
        self.lines = []
        self.buffer = Data()
    }

    func Parse(data: Data) -> [String] {
        var events: [String] = []
        var data = data
        while let index = data.firstIndex(of: EventParser.ln) {
            var segment = data[..<index]
            data = data[(index + 1)...]

            if segment.last == EventParser.cr {
                segment = segment.dropLast()
            }
            buffer.append(segment)

            var line = buffer
            buffer = Data()

            if line.isEmpty {
                if lines.count > 0 {
                    events.append(lines.joined(separator: "\n"))
                    lines = []
                }
            } else {
                guard line.starts(with: EventParser.data) else {
                    continue
                }
                line = line[EventParser.data.count...]
                guard !line.isEmpty else {
                    lines.append("")
                    continue
                }
                guard line.first == EventParser.dot else {
                    continue
                }
                line = line.dropFirst()
                if line.first == EventParser.space {
                    line = line.dropFirst()
                }
                guard let line = String(data: line, encoding: .utf8) else {
                    continue
                }
                lines.append(line)
            }
        }
        buffer.append(data)

        return events
    }
}



---
File: /Sources/SignalRClient/Transport/LongPollingTransport.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

actor LongPollingTransport: Transport {
    let httpClient: HttpClient
    let logger: Logger
    var options: HttpConnectionOptions

    var url: String?
    var running: Bool
    var closeError: Error?
    var receiving: Task<Void, Never>?
    var onReceiveHandler: OnReceiveHandler?
    var onCloseHandler: OnCloseHander?

    init(
        httpClient: HttpClient, logger: Logger, options: HttpConnectionOptions
    ) {
        self.httpClient = httpClient
        self.options = options
        self.running = false
        self.logger = logger
    }

    func connect(url: String, transferFormat: TransferFormat) async throws {
        // MARK: Here's an assumption that the connect won't be called twice
        self.url = url
        logger.log(
            level: .debug, message: "(LongPolling transport) Connecting."
        )

        var pollRequest = HttpRequest(
            method: .GET, url: url, responseType: transferFormat,
            options: options
        )
        pollRequest.appendDateInUrl()
        logger.log(
            level: .debug,
            message: "(LongPolling transport) polling: \(pollRequest.url)."
        )

        let (_, response) = try await httpClient.send(request: pollRequest)

        if response.statusCode != 200 {
            logger.log(
                level: .error,
                message:
                "(LongPolling transport) Unexpected response code: \(response.statusCode)."
            )
            self.closeError = SignalRError.unexpectedResponseCode(
                response.statusCode)
            self.running = false
        } else {
            self.running = true
        }

        self.receiving = Task {
            await poll(pollRequest: pollRequest)
        }
    }

    func poll(pollRequest: HttpRequest) async {
        var pollRequest = pollRequest
        while running {
            do {
                pollRequest.appendDateInUrl()
                logger.log(
                    level: .debug,
                    message:
                    "(LongPolling transport) polling: \(pollRequest.url)."
                )

                let (message, response) = try await httpClient.send(
                    request: pollRequest)

                if response.statusCode == 204 {
                    logger.log(
                        level: .information,
                        message:
                        "(LongPolling transport) Poll terminated by server."
                    )
                    self.running = false
                } else if response.statusCode != 200 {
                    logger.log(
                        level: .error,
                        message:
                        "(LongPolling transport) Unexpected response code: \(response.statusCode)."
                    )
                    self.closeError = SignalRError.unexpectedResponseCode(
                        response.statusCode)
                } else {
                    if !message.isEmpty() {
                        logger.log(
                            level: .debug,
                            message:
                            "(LongPolling transport) data received. \(message.getDataDetail(includeContent: options.logMessageContent ?? false))"
                        )
                        await self.onReceiveHandler?(message)
                    } else {
                        logger.log(
                            level: .debug,
                            message:
                            "(LongPolling transport) Poll timed out, reissuing."
                        )
                    }
                }
            } catch {
                if !self.running {
                    // Log but disregard errors that occur after stopping
                    logger.log(
                        level: .debug,
                        message:
                        "(LongPolling transport) Poll errored after shutdown: \(error)"
                    )
                } else {
                    if let err = error as? SignalRError,
                       err == SignalRError.httpTimeoutError {
                        // Ignore timeouts and reissue the poll.
                        logger.log(
                            level: .debug,
                            message:
                            "(LongPolling transport) Poll timed out, reissuing."
                        )
                    } else {
                        // Close the connection with the error as the result.
                        self.closeError = error
                        self.running = false
                    }
                }
            }
        }

        logger.log(
            level: .debug, message: "(LongPolling transport) Polling complete."
        )
        if !Task.isCancelled {
            await raiseClose()
        }

    }

    func send(_ requestData: StringOrData) async throws {
        guard self.running else {
            throw SignalRError.cannotSentUntilTransportConnected
        }
        logger.log(
            level: .debug,
            message:
            "(LongPolling transport) sending data. \(requestData.getDataDetail(includeContent: options.logMessageContent ?? false))"
        )
        let request = HttpRequest(
            method: .POST, url: self.url!, content: requestData,
            options: options
        )
        let (_, response) = try await httpClient.send(request: request)
        logger.log(
            level: .debug,
            message:
            "(LongPolling transport) request complete. Response status: \(response.statusCode)."
        )
        if !response.ok() {
            throw SignalRError.unexpectedResponseCode(response.statusCode)
        }
    }

    func stop(error: (any Error)?) async throws {
        logger.log(
            level: .debug, message: "(LongPolling transport) Stopping polling."
        )
        let triggerClose = self.running
        self.running = false
        self.receiving?.cancel()

        await self.receiving?.value

        logger.log(
            level: .debug,
            message:
            "(LongPolling transport) sending DELETE request to \(String(describing: self.url))"
        )

        do {
            let deleteRequest = HttpRequest(
                method: .DELETE, url: self.url!, options: options
            )
            let (_, response) = try await httpClient.send(
                request: deleteRequest)
            if response.statusCode == 404 {
                logger.log(
                    level: .debug,
                    message:
                    "(LongPolling transport) A 404 response was returned from sending a DELETE request."
                )
            } else if response.ok() {
                logger.log(
                    level: .debug,
                    message: "(LongPolling transport) DELETE request accepted."
                )
            } else {
                logger.log(
                    level: .debug,
                    message:
                    "(LongPolling transport) Unexpected response code sending a DELETE request: \(response.statusCode)"
                )
            }
        } catch {
            logger.log(
                level: .debug,
                message:
                "(LongPolling transport) Error sending a DELETE request: \(error)"
            )
        }
        logger.log(
            level: .debug, message: "(LongPolling transport) Stop finished."
        )

        if (triggerClose) {
            await raiseClose()
        }
    }

    func onReceive(_ handler: OnReceiveHandler?) {
        self.onReceiveHandler = handler
    }

    func onClose(_ handler: OnCloseHander?) {
        self.onCloseHandler = handler
    }

    private func raiseClose() async {
        guard let onCloseHandler = self.onCloseHandler else {
            return
        }
        self.onCloseHandler = nil
        logger.log(
            level: .debug,
            message:
            "(LongPolling transport) Firing onclose event.\(closeError == nil ? "" : " Error: \(closeError!)")"
        )
        await onCloseHandler(self.closeError)
    }
}

extension HttpRequest {
    mutating func appendDateInUrl() {
        if self.url.last != Character("&") {
            self.url.append("&")
        }
        self.url = self.url.components(separatedBy: "_=").first!.appending(
            "_=\(Int64((Date().timeIntervalSince1970 * 1000)))")
    }
}



---
File: /Sources/SignalRClient/Transport/ServerSentEventTransport.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

actor ServerSentEventTransport: Transport {
    let httpClient: HttpClient
    let logger: Logger
    let accessToken: String?
    var options: HttpConnectionOptions

    var url: String?
    var closeError: Error?
    var receiving: Task<Void, Never>?
    var receiveHandler: OnReceiveHandler?
    var closeHandler: OnCloseHander?
    var eventSource: EventSourceAdaptor?

    init(
        httpClient: HttpClient, accessToken: String?, logger: Logger,
        options: HttpConnectionOptions
    ) {
        self.httpClient = httpClient
        self.options = options
        self.accessToken = accessToken
        self.logger = logger
    }

    func connect(url: String, transferFormat: TransferFormat) async throws {
        // MARK: Here's an assumption that the connect won't be called twice
        guard transferFormat == .text else {
            throw SignalRError.eventSourceInvalidTransferFormat
        }

        logger.log(
            level: .debug, message: "(SSE transport) Connecting."
        )

        self.url = url
        var url = url
        if let accessToken = self.accessToken {
            url =
                "\(url)\(url.contains("?") ? "&" : "?")access_token=\(accessToken.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }

        let eventSource = options.eventSource ?? DefaultEventSourceAdaptor(logger: logger)

        await eventSource.onClose(closeHandler: self.close)

        await eventSource.onMessage { data in
            let message = StringOrData.string(data)
            self.logger.log(
                level: .debug,
                message:
                "(SSE) data received. \(message.getDataDetail(includeContent: self.options.logMessageContent ?? false))"
            )
            await self.receiveHandler?(message)
        }

        try await eventSource.start(url: url, options: options)

        self.eventSource = eventSource
        logger.log(
            level: .information, message: "SSE connected to \(self.url!)"
        )
    }

    func send(_ requestData: StringOrData) async throws {
        guard self.eventSource != nil else {
            throw SignalRError.cannotSentUntilTransportConnected
        }
        logger.log(
            level: .debug,
            message:
            "(SSE transport) sending data. \(requestData.getDataDetail(includeContent: options.logMessageContent ?? false))"
        )
        let request = HttpRequest(
            method: .POST, url: self.url!, content: requestData,
            options: options
        )
        let (_, response) = try await httpClient.send(request: request)
        logger.log(
            level: .debug,
            message:
            "(SSE transport) request complete. Response status: \(response.statusCode)."
        )
    }

    func stop(error: (any Error)?) async throws {
        await self.close(err: error)
    }

    func onReceive(_ handler: OnReceiveHandler?) {
        self.receiveHandler = handler
    }

    func onClose(_ handler: OnCloseHander?) {
        self.closeHandler = handler
    }

    private func close(err: Error?) async {
        guard let eventSource = self.eventSource else {
            return
        }
        self.eventSource = nil
        await eventSource.stop(err: err)
        await closeHandler?(err)
    }
}

final class DefaultEventSourceAdaptor: EventSourceAdaptor, @unchecked Sendable {
    private let logger: Logger
    private var closeHandler: ((Error?) async -> Void)?
    private var messageHandler: ((String) async -> Void)?

    private var eventSource: EventSource?
    private var dispatchQueue: DispatchQueue
    private var messageTask: Task<Void, Never>?
    private var messageStream: AsyncStream<String>?

    init(logger: Logger) {
        self.logger = logger
        self.dispatchQueue = DispatchQueue(label: "DefaultEventSourceAdaptor")
    }

    func start(url: String, headers: [String: String]) async throws {
        guard let url = URL(string: url) else {
            throw SignalRError.invalidUrl(url)
        }
        let eventSource = EventSource(url: url, headers: headers)
        let openTcs = TaskCompletionSource<Void>()

        eventSource.onOpen {
            Task {
                _ = await openTcs.trySetResult(.success(()))
                self.eventSource = eventSource
            }
        }

        messageStream = AsyncStream { continuation in
            eventSource.onComplete { statusCode, err in
                Task {
                    let connectFail = await openTcs.trySetResult(
                        .failure(SignalRError.eventSourceFailedToConnect))
                    self.logger.log(
                        level: .debug,
                        message:
                        "(Event Source) \(connectFail ? "Failed to open." : "Disconnected.").\(statusCode == nil ? "" : " StatusCode: \(statusCode!).") \(err == nil ? "" : " Error: \(err!).")"
                    )
                    continuation.finish()
                    await self.close(err: err)
                }
            }

            eventSource.onMessage { data in
                continuation.yield(data)
            }
        }

        eventSource.connect()
        try await openTcs.task()

        messageTask = Task {
            for await message in messageStream! {
                await self.messageHandler?(message)
            }
        }
    }

    func stop(err: Error?) async {
        await self.close(err: err)
    }

    func onClose(closeHandler: @escaping (Error?) async -> Void) async {
        self.closeHandler = closeHandler
    }

    func onMessage(messageHandler: @escaping (String) async -> Void) async {
        self.messageHandler = messageHandler
    }

    private func close(err: Error?) async {
        var eventSource: EventSource?
        dispatchQueue.sync {
            eventSource = self.eventSource
            self.eventSource = nil
        }
        guard let eventSource = eventSource else {
            return
        }
        eventSource.disconnect()
        await messageTask?.value
        await self.closeHandler?(err)
    }
}

extension EventSourceAdaptor {
    fileprivate func start(
        url: String, headers: [String: String] = [:],
        options: HttpConnectionOptions,
        includeUserAgent: Bool = true
    ) async throws {
        var headers = headers
        if includeUserAgent {
            headers["User-Agent"] = Utils.getUserAgent()
        }
        if let optionHeaders = options.headers {
            headers = headers.merging(optionHeaders) { (_, new) in new }
        }
        try await start(url: url, headers: headers)
    }
}

protocol EventSourceAdaptor: Sendable {
    func start(url: String, headers: [String: String]) async throws
    func stop(err: Error?) async
    func onClose(closeHandler: @escaping (Error?) async -> Void) async
    func onMessage(messageHandler: @escaping (String) async -> Void) async
}



---
File: /Sources/SignalRClient/Transport/Transport.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/// An abstraction over the behavior of transports.
/// This is designed to support the framework and not intended for use by applications.
protocol Transport: Sendable {
    /// Connects to the specified URL with the given transfer format.
    /// - Parameters:
    ///   - url: The URL to connect to.
    ///   - transferFormat: The transfer format to use.
    func connect(url: String, transferFormat: TransferFormat) async throws

    /// Sends data over the transport.
    /// - Parameter data: The data to send.
    func send(_ data: StringOrData) async throws

    /// Stops the transport.
    func stop(error: Error?) async throws

    /// A closure that is called when data is received.
    func onReceive(_ handler: OnReceiveHandler?) async

    /// A closure that is called when the transport is closed.
    func onClose(_ handler: OnCloseHander?) async

    typealias OnReceiveHandler = @Sendable (StringOrData) async -> Void

    typealias OnCloseHander = @Sendable (Error?) async -> Void
}



---
File: /Sources/SignalRClient/Transport/WebSocketTransport.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

actor WebSocketTransport: Transport {
    private let logger: Logger
    private let accessTokenFactory: (@Sendable () async throws -> String?)?
    private let headers: [String: String]
    private let webSocketConnection: WebSocketConnection

    private var transferFormat: TransferFormat = .text

    init(accessTokenFactory: (@Sendable () async throws -> String?)?,
         logger: Logger,
         headers: [String: String],
         websocket: WebSocketConnection? = nil) {
        self.accessTokenFactory = accessTokenFactory
        self.logger = logger
        self.headers = headers
        self.webSocketConnection = websocket ?? DefaultWebSocketConnection(logger: logger)
    }

    func onReceive(_ handler: OnReceiveHandler?) async {
        await self.webSocketConnection.onReceive(handler)
    }

    func onClose(_ handler: OnCloseHander?) async {
        await self.webSocketConnection.onClose(handler)
    }

    func connect(url: String, transferFormat: TransferFormat) async throws {
        self.logger.log(level: .debug, message: "(WebSockets transport) Connecting.")

        self.transferFormat = transferFormat
        var urlComponents = URLComponents(url: URL(string: url)!, resolvingAgainstBaseURL: false)!
        if urlComponents.scheme == "http" {
            urlComponents.scheme = "ws"
        } else if urlComponents.scheme == "https" {
            urlComponents.scheme = "wss"
        }

        var request = URLRequest(url: urlComponents.url!)

        // Add headeres
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }

        // Add token to header
        if let factory = accessTokenFactory, let token = try await factory() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add user-agent
        request.addValue(Utils.getUserAgent(), forHTTPHeaderField: "User-Agent")

        try await webSocketConnection.connect(request: request, transferFormat: transferFormat)
    }

    func send(_ data: StringOrData) async throws {
        try await webSocketConnection.send(data)
    }

    func stop(error: Error?) async throws {
        try await webSocketConnection.stop(error: error)
    }

    protocol WebSocketConnection {
        func connect(request: URLRequest, transferFormat: TransferFormat) async throws
        func send(_ data: StringOrData) async throws
        func stop(error: Error?) async throws
        func onReceive(_ handler: OnReceiveHandler?) async
        func onClose(_ handler: OnCloseHander?) async
    }

    #if os(Linux)
        private actor DefaultWebSocketConnection: WebSocketConnection {
            func connect(request: URLRequest, transferFormat: TransferFormat) async throws {
                throw SignalRError.unsupportedTransport("WebSockets transport is not supported on Linux")
            }

            func send(_ data: StringOrData) async throws {
                throw SignalRError.unsupportedTransport("WebSockets transport is not supported on Linux")
            }

            func stop(error: (any Error)?) async throws {
                throw SignalRError.unsupportedTransport("WebSockets transport is not supported on Linux")
            }

            func onReceive(_ handler: WebSocketTransport.OnReceiveHandler?) async {
            }

            func onClose(_ handler: WebSocketTransport.OnCloseHander?) async {
            }

            init(logger: Logger) {
            }
        }
    #else
        private actor DefaultWebSocketConnection: NSObject, WebSocketConnection, URLSessionWebSocketDelegate {
            private let logger: Logger
            private let openTcs: TaskCompletionSource<Void> = TaskCompletionSource()

            private var urlSession: URLSession?
            private var websocket: URLSessionWebSocketTask?
            private var receiveTask: Task<Void, Never>?
            private var onReceive: OnReceiveHandler?
            private var onClose: OnCloseHander?

            private var closed: Bool = false

            init(logger: Logger) {
                self.logger = logger
            }

            func connect(request: URLRequest, transferFormat: TransferFormat) async throws {
                urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
                websocket = urlSession!.webSocketTask(with: request)

                guard websocket != nil else {
                    throw SignalRError.failedToStartConnection("(WebSockets transport) WebSocket is nil")
                }

                websocket!.resume() // connect but it won't throw even failure

                receiveTask = Task { [weak self] in
                    guard let self = self else { return }
                    await receiveMessage()
                }

                // wait for startTcs to be completed before returning from connect
                // this is to ensure that the connection is truely established
                try await openTcs.task()
            }

            func send(_ data: StringOrData) async throws {
                guard let ws = self.websocket, ws.state == .running else {
                    throw SignalRError.invalidOperation("(WebSockets transport) Cannot send until the transport is connected")
                }

                switch data {
                case .string(let str):
                    try await ws.send(URLSessionWebSocketTask.Message.string(str))
                case .data(let data):
                    try await ws.send(URLSessionWebSocketTask.Message.data(data))
                }
            }

            func stop(error: Error?) async {
                if closed {
                    return
                }
                closed = true

                urlSession?.finishTasksAndInvalidate() // Prevent new task from being created
                websocket?.cancel() // Close the current connection

                if await openTcs.trySetResult(.failure(error ?? SignalRError.connectionAborted)) == true {
                    receiveTask?.cancel() // Cancel the receive task
                } else {
                    await receiveTask?.value // Wait for the receive task to complete
                    await onClose?(error) // Call the close handler
                }
            }

            func onReceive(_ handler: OnReceiveHandler?) async {
                onReceive = handler
            }

            func onClose(_ handler: OnCloseHander?) async {
                onClose = handler
            }

            nonisolated func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
                logger.log(level: .debug, message: "(WebSockets transport) URLSession didCompleteWithError: \(String(describing: error))")

                Task {
                    await stop(error: error)
                }
            }

            // When receive websocket close message?
            nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
                logger.log(level: .debug, message: "(WebSockets transport) URLSession didCloseWith: \(closeCode)")

                Task {
                    await stop(error: nil)
                }
            }

            nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
                logger.log(level: .debug, message: "(WebSockets transport) urlSession didOpenWithProtocol invoked. WebSocket open")

                Task {
                    if await openTcs.trySetResult(.success(())) == true {
                        logger.log(level: .debug, message: "(WebSockets transport) WebSocket connected")
                    }
                }
            }

            private func receiveMessage() async {
                guard let websocket: URLSessionWebSocketTask = websocket else {
                    logger.log(level: .error, message: "(WebSockets transport) WebSocket is nil")
                    return 
                }

                do {
                    while !Task.isCancelled {
                        let message = try await websocket.receive()

                        switch message {
                        case .string(let text):
                            logger.log(level: .debug, message: "(WebSockets transport) Received message: \(text)")
                            await onReceive?(.string(text))
                        case .data(let data):
                            await onReceive?(.data(data))
                        }
                    }
                } catch {
                    logger.log(level: .debug, message: "Websocket receive error : \(error)")
                }
            }
        }
    #endif
}



---
File: /Sources/SignalRClient/AsyncLock.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

class AsyncLock {
    let lock = DispatchSemaphore(value: 1)
    private var isLocked = false
    private var waitQueue: [CheckedContinuation<Void, Never>] = []

    func wait() async {
        lock.wait()

        if !isLocked {
            defer {
                lock.signal()
            }

            isLocked = true
            return
        }

        await withCheckedContinuation { continuation in
            defer { lock.signal() }
            waitQueue.append(continuation)
        }
    }

    func release() {
        lock.wait()
        defer {
            lock.signal()
        }

        if let continuation = waitQueue.first {
            waitQueue.removeFirst()
            continuation.resume() 
        } else {
            isLocked = false
        }
    }
}



---
File: /Sources/SignalRClient/AtomicState.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

actor AtomicState<T: Equatable> {
    init(initialState: T) {
        self.state = initialState
    }
    private var state: T

    func compareExchange(expected: T, desired: T) -> T {
        let origin = state 
        if (expected == state) {
            state = desired
        }
        return origin
    }
}


---
File: /Sources/SignalRClient/ConnectionProtocol.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

protocol ConnectionProtocol: AnyObject, Sendable {
    func onReceive(_ handler: @escaping Transport.OnReceiveHandler) async
    func onClose(_ handler: @escaping Transport.OnCloseHander) async
    func start(transferFormat: TransferFormat) async throws
    func send(_ data: StringOrData) async throws
    func stop(error: Error?) async
    var inherentKeepAlive: Bool { get async }
}


---
File: /Sources/SignalRClient/HandshakeProtocol.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

struct HandshakeRequestMessage: Codable {
    let `protocol`: String
    let version: Int
}

struct HandshakeResponseMessage: Codable {
    let error: String?
    let minorVersion: Int?
}

// Implement the HandshakeProtocol class
class HandshakeProtocol {
    // Handshake request is always JSON
    static func writeHandshakeRequest(handshakeRequest: HandshakeRequestMessage) throws -> String {
        let encoder = JSONEncoder()
        let data = try encoder.encode(handshakeRequest)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw SignalRError.failedToEncodeHandshakeRequest
        }
        return TextMessageFormat.write(jsonString)
    }

    static func parseHandshakeResponse(data: StringOrData) throws -> (StringOrData?, HandshakeResponseMessage) {
        var messageData: String
        var remainingData: StringOrData?

        switch data {
        case .string(let textData):
            if let separatorIndex = textData.firstIndex(of: Character(TextMessageFormat.recordSeparator)) {
                let responseLength = textData.distance(from: textData.startIndex, to: separatorIndex) + 1
                let messageRange = textData.startIndex ..< textData.index(textData.startIndex, offsetBy: responseLength)
                messageData = String(textData[messageRange])
                remainingData = (textData.count > responseLength) ? .string(String(textData[textData.index(textData.startIndex, offsetBy: responseLength)...])) : nil
            } else {
                throw SignalRError.incompleteMessage
            }
        case .data(let binaryData):
            if let separatorIndex = binaryData.firstIndex(of: TextMessageFormat.recordSeparatorCode) {
                let responseLength = separatorIndex + 1
                let responseData = binaryData.subdata(in: 0 ..< responseLength)
                guard let responseString = String(data: responseData, encoding: .utf8) else {
                    throw SignalRError.failedToDecodeResponseData
                }
                messageData = responseString
                remainingData = (binaryData.count > responseLength) ? .data(binaryData.subdata(in: responseLength ..< binaryData.count)) : nil
            } else {
                throw SignalRError.incompleteMessage
            }
        }

        // At this point we should have just the single handshake message
        let messages = try TextMessageFormat.parse(messageData)
        guard let firstMessage = messages.first else {
            throw SignalRError.noHandshakeMessageReceived
        }

        // Parse JSON and check for unexpected "type" field
        guard let jsonData = firstMessage.data(using: .utf8) else {
            throw SignalRError.failedToDecodeResponseData
        }

        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
        if let jsonObject = jsonObject, jsonObject["type"] != nil { // contains type means a normal message
            throw SignalRError.expectedHandshakeResponse
        }

        // Decode the handshake response message
        let decoder = JSONDecoder()
        let responseMessage = try decoder.decode(HandshakeResponseMessage.self, from: jsonData)

        // Return the remaining data and the response message
        return (remainingData, responseMessage)
    }
}


---
File: /Sources/SignalRClient/HttpClient.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

// MARK: - HttpRequest and HttpResponse

public enum HttpMethod: String, Sendable {
    case GET, PUT, PATCH, POST, DELETE
}

public struct HttpRequest: Sendable {
    var method: HttpMethod
    var url: String
    var content: StringOrData?
    var headers: [String: String]
    var timeout: TimeInterval
    var responseType: TransferFormat

    public init(
        method: HttpMethod, url: String, content: StringOrData? = nil,
        responseType: TransferFormat? = nil,
        headers: [String: String]? = nil, timeout: TimeInterval? = nil
    ) {
        self.method = method
        self.url = url
        self.content = content
        self.headers = headers ?? [:]
        self.timeout = timeout ?? 100
        if responseType != nil {
            self.responseType = responseType!
        } else {
            switch content {
            case .data(_):
                self.responseType = TransferFormat.binary
            default:
                self.responseType = TransferFormat.text
            }
        }
    }
}

public struct HttpResponse {
    public let statusCode: Int
}

// MARK: - HttpClient Protocol

public protocol HttpClient: Sendable {
    // Don't throw if the http call returns a status code out of [200, 299]
    func send(request: HttpRequest) async throws -> (StringOrData, HttpResponse)
}

actor DefaultHttpClient: HttpClient {
    private let logger: Logger
    private let session: URLSession

    init(logger: Logger) {
        self.logger = logger
        self.session = URLSession(configuration: URLSessionConfiguration.default)
    }

    public func send(request: HttpRequest) async throws -> (
        StringOrData, HttpResponse
    ) {
        do {
            let urlRequest = try request.buildURLRequest()
            let (data, response) = try await self.session.data(
                for: urlRequest)
            guard let httpURLResponse = response as? HTTPURLResponse else {
                throw SignalRError.invalidResponseType
            }
            let httpResponse = HttpResponse(
                statusCode: httpURLResponse.statusCode)
            let message = try data.convertToStringOrData(
                transferFormat: request.responseType)
            return (message, httpResponse)
        } catch {
            if let urlError = error as? URLError,
               urlError.code == URLError.timedOut {
                logger.log(
                    level: .warning, message: "Timeout from HTTP request."
                )
                throw SignalRError.httpTimeoutError
            }
            logger.log(
                level: .warning, message: "Error from HTTP request: \(error)"
            )
            throw error
        }
    }
}

typealias AccessTokenFactory = () async throws -> String?

actor AccessTokenHttpClient: HttpClient {
    var accessTokenFactory: AccessTokenFactory?
    var accessToken: String?
    private let innerClient: HttpClient

    public init(
        innerClient: HttpClient,
        accessTokenFactory: AccessTokenFactory?
    ) {
        self.innerClient = innerClient
        self.accessTokenFactory = accessTokenFactory
    }

    public func setAccessTokenFactory(factory: AccessTokenFactory?) {
        self.accessTokenFactory = factory
    }

    public func send(request: HttpRequest) async throws -> (
        StringOrData, HttpResponse
    ) {
        var mutableRequest = request
        var allowRetry = true

        if let factory = accessTokenFactory,
           accessToken == nil || (request.url.contains("/negotiate?")) {
            // Don't retry if the request is a negotiate or if we just got a potentially new token from the access token factory
            allowRetry = false
            accessToken = try await factory()
        }

        setAuthorizationHeader(request: &mutableRequest)

        var (data, httpResponse) = try await innerClient.send(
            request: mutableRequest)

        if allowRetry && httpResponse.statusCode == 401,
           let factory = accessTokenFactory {
            accessToken = try await factory()
            setAuthorizationHeader(request: &mutableRequest)
            (data, httpResponse) = try await innerClient.send(
                request: mutableRequest)

            return (data, httpResponse)
        }

        return (data, httpResponse)
    }

    private func setAuthorizationHeader(request: inout HttpRequest) {
        if let token = accessToken {
            request.headers["Authorization"] = "Bearer \(token)"
        } else if accessTokenFactory != nil {
            request.headers.removeValue(forKey: "Authorization")
        }
    }
}

extension HttpRequest {
    fileprivate func buildURLRequest() throws -> URLRequest {
        guard let url = URL(string: self.url) else {
            throw SignalRError.invalidUrl(self.url)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = timeout
        for (key, value) in headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        switch content {
        case .data(let data):
            urlRequest.httpBody = data
            urlRequest.setValue(
                "application/octet-stream", forHTTPHeaderField: "Content-Type"
            )
        case .string(let strData):
            urlRequest.httpBody = strData.data(using: .utf8)
            urlRequest.setValue(
                "text/plain;charset=UTF-8", forHTTPHeaderField: "Content-Type"
            )
        case nil:
            break
        }
        return urlRequest
    }
}

extension HttpResponse {
    func ok() -> Bool {
        return statusCode >= 200 && statusCode < 300
    }
}



---
File: /Sources/SignalRClient/HttpConnection.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

// MARK: - Enums and Protocols

private enum ConnectionState: String {
    case connecting = "Connecting"
    case connected = "Connected"
    case disconnected = "Disconnected"
    case disconnecting = "Disconnecting"
}

public struct HttpConnectionOptions {
    public var logHandler: LogHandler?
    public var logLevel: LogLevel = .information
    public var accessTokenFactory: (@Sendable () async throws -> String?)?
    public var httpClient: HttpClient?
    public var transport: HttpTransportType?
    public var skipNegotiation: Bool = false
    public var headers: [String: String]?
    public var timeout: TimeInterval?
    public var logMessageContent: Bool?
    var webSocket: AnyObject? // Placeholder for WebSocket type
    var eventSource: EventSourceAdaptor?
    var useStatefulReconnect: Bool? // Not supported yet
    
    public init() {}
}

// MARK: - Models

struct NegotiateResponse: Decodable {
    var connectionId: String?
    var connectionToken: String?
    var negotiateVersion: Int?
    var availableTransports: [AvailableTransport]?
    var url: String?
    var accessToken: String?
    var error: String?
    var useStatefulReconnect: Bool?

    enum CodingKeys: String, CodingKey {
        case connectionId
        case connectionToken
        case negotiateVersion
        case availableTransports
        case url
        case accessToken
        case error
        case useStatefulReconnect
    }
}

struct AvailableTransport: Decodable {
    var transport: String
    var transferFormats: [String]

    enum CodingKeys: String, CodingKey {
        case transport
        case transferFormats
    }
}

// MARK: - HttpConnection Class

actor HttpConnection: ConnectionProtocol {
    // MARK: - Properties
    private let negotiationRedirectionLimit = 100

    private var connectionState: ConnectionState = .disconnected
    private var connectionStartedSuccessfully: Bool = false
    private let httpClient: AccessTokenHttpClient
    private let logger: Logger
    private var options: HttpConnectionOptions
    private var transport: Transport?
    private var startInternalTask: Task<Void, Error>?
    private var stopTask: Task<Void, Never>?
    private var stopError: Error?
    private var accessTokenFactory: (@Sendable () async throws -> String?)?
    private var inherentKeepAlivePrivate: Bool = false

    public var features: [String: Any] = [:]
    public var baseUrl: String
    public var connectionId: String?
    public var inherentKeepAlive: Bool { 
        get async {
            return inherentKeepAlivePrivate
        }
    }

    private var onReceive: Transport.OnReceiveHandler?
    private var onClose: Transport.OnCloseHander?
    private let negotiateVersion = 1
    private var closeDuringStartError: Error? = nil

    // MARK: - Initialization

    init(url: String, options: HttpConnectionOptions = HttpConnectionOptions()) {
        precondition(!url.isEmpty, "url is required")

        self.logger = Logger(logLevel: options.logLevel, logHandler: options.logHandler ?? DefaultLogHandler())
        self.baseUrl = HttpConnection.resolveUrl(url)
        self.options = options

        self.options.logMessageContent = options.logMessageContent ?? false
        self.options.timeout = options.timeout ?? 100

        self.accessTokenFactory = options.accessTokenFactory
        self.httpClient = AccessTokenHttpClient(innerClient: options.httpClient ?? DefaultHttpClient(logger: logger), accessTokenFactory: options.accessTokenFactory)
    }

    // MARK: - Public Methods

    func onReceive(_ handler: @escaping Transport.OnReceiveHandler) async {
        onReceive = handler
    }

    func onClose(_ handler: @escaping Transport.OnCloseHander) async {
        onClose = handler
    }

    func start(transferFormat: TransferFormat = .binary) async throws {
        logger.log(level: .debug, message: "Starting connection with transfer format '\(transferFormat)'.")

        // startInternalTask make this easy:
        // - If startInternalTask is nil, start will directly stop
        // - If startInternalTask is not nil, wait it finish and then call the stop
        guard connectionState == .disconnected else {
            throw SignalRError.invalidOperation("Cannot start an HttpConnection that is not in the 'Disconnected' state. Currently it's \(connectionState)")
        }

        connectionState = .connecting

        startInternalTask = Task {
            do {
                try await self.startInternal(transferFormat: transferFormat)
                connectionStartedSuccessfully = true
            } catch {
                connectionState = .disconnected
                throw error
            }
        }

        try await startInternalTask?.value
    }

    func send(_ data: StringOrData) async throws {
        guard connectionState == .connected else {
            throw SignalRError.invalidOperation("Cannot send data if the connection is not in the 'Connected' State. Currently it's \(connectionState)")
        }

        try await transport?.send(data)
    }

    func stop(error: Error? = nil) async {
        if connectionState == .disconnected {
            logger.log(level: .debug, message: "Call to HttpConnection.stop(\(String(describing: error))) ignored because the connection is already in the disconnected state.")
            return
        }

        if connectionState == .disconnecting {
            logger.log(level: .debug, message: "Call to HttpConnection.stop(\(String(describing: error))) ignored because the connection is already in the disconnecting state.")
            await stopTask?.value
            return
        }

        connectionState = .disconnecting

        stopTask = Task {
            await self.stopInternal(error: error)
        }

        await stopTask?.value
    }

    // MARK: - Private Methods

    private func startInternal(transferFormat: TransferFormat) async throws {
        guard connectionState == .connecting else {
            throw SignalRError.connectionAborted
        }
        closeDuringStartError = nil
        
        var url = baseUrl
        await httpClient.setAccessTokenFactory(factory: accessTokenFactory)

        do {
            if options.skipNegotiation {
                if options.transport == .webSockets {
                    transport = try await constructTransport(transport: .webSockets)
                    try await startTransport(url: url, transferFormat: transferFormat)
                } else {
                    throw SignalRError.negotiationError("Negotiation can only be skipped when using the WebSocket transport directly.")
                }
            } else {
                var negotiateResponse: NegotiateResponse?
                var redirects = 0
                repeat {
                    negotiateResponse = try await getNegotiationResponse(url: url)
                    logger.log(level: .debug, message: "Negotiation response received.")

                    if connectionState == .disconnecting || connectionState == .disconnected {
                        throw SignalRError.negotiationError("The connection was stopped during negotiation.")
                    }
                    if let error = negotiateResponse?.error {
                        throw SignalRError.negotiationError(error)
                    }
                    if negotiateResponse?.url != nil {
                        url = negotiateResponse?.url ?? url
                    }
                    if let accessToken = negotiateResponse?.accessToken {
                        // Replace the current access token factory with one that uses
                        // the returned access token
                        accessTokenFactory = { return accessToken }
                        await httpClient.setAccessTokenFactory(factory: accessTokenFactory)
                    }
                    redirects += 1
                } while negotiateResponse?.url != nil && redirects < negotiationRedirectionLimit

                if redirects == negotiationRedirectionLimit && negotiateResponse?.url != nil {
                    throw SignalRError.negotiationError("Negotiate redirection limit exceeded: \(negotiationRedirectionLimit).")
                }

                logger.log(level: .debug, message: "Successfully finish the negotiation. \(String(describing: negotiateResponse))")
                try await createTransport(url: url, requestedTransport: options.transport, negotiateResponse: negotiateResponse, requestedTransferFormat: transferFormat)
            }

            if (transport is LongPollingTransport) {
                inherentKeepAlivePrivate = true
            }

            guard closeDuringStartError == nil else {
                throw closeDuringStartError!
            }

            // IMPORTANT: There should be no async code start from here. Otherwise, we may lost the control of the connection lifecycle

            connectionState = .connected
            logger.log(level: .debug, message: "The HttpConnection connected successfully.")
        } catch {
            logger.log(level: .error, message: "Failed to start the connection: \(error)")
            connectionState = .disconnected
            transport = nil
            throw error
        }
    }

    private func stopInternal(error: Error?) async {
        guard connectionState != .disconnected else {
            return
        }

        stopError = error
        closeDuringStartError = error ?? SignalRError.connectionAborted

        do {
            // startInternalTask may have several cases:
            // 1. Already finished. Just return immediately
            // 2. Still in progress. Caused by closeDuringStartError, it will throw and set transport to nil
            try await startInternalTask?.value
        } catch {
            // Ignore errors from startInternal
        }

        if transport != nil {
            do {
                try await transport?.stop(error: nil)
            } catch {
                logger.log(level: .error, message: "HttpConnection.transport.stop() threw error '\(error)'.")
                await handleConnectionClose(error: error)
            }
        } else {
            logger.log(level: .debug, message: "HttpConnection.transport is undefined in HttpConnection.stop() because start() failed.")
        }
    }

    private func getNegotiationResponse(url: String) async throws -> NegotiateResponse {
        let negotiateUrl = resolveNegotiateUrl(url: url)
        logger.log(level: .debug, message: "Sending negotiation request: \(negotiateUrl)")
        do {
            let request = HttpRequest(method: .POST, url: negotiateUrl, options: options)

            let (message, response) = try await httpClient.send(request: request)

            if response.statusCode != 200 {
                var exceptionMsg = "Unexpected status code returned from negotiate '\(response.statusCode)'"
                if response.statusCode == 404 {
                    exceptionMsg += " Either this is not a SignalR endpoint or there is a proxy blocking the connection."
                }
                throw SignalRError.negotiationError(exceptionMsg)
            }

            let decoder = JSONDecoder()
            var negotiateResponse = try decoder.decode(NegotiateResponse.self, from: message.converToData())

            if negotiateResponse.negotiateVersion == nil || negotiateResponse.negotiateVersion! < 1 {
                negotiateResponse.connectionToken = negotiateResponse.connectionId
            }

            if negotiateResponse.useStatefulReconnect == true && options.useStatefulReconnect != true {
                throw SignalRError.negotiationError("Client didn't negotiate Stateful Reconnect but the server did.")
            }

            return negotiateResponse
        } catch {
            let errorMessage = "Failed to complete negotiation with the server: \(error)"
            logger.log(level: .error, message: "\(errorMessage)")
            throw SignalRError.negotiationError(errorMessage)
        }
    }

    private func createTransport(url: String, requestedTransport: HttpTransportType?, negotiateResponse: NegotiateResponse?, requestedTransferFormat: TransferFormat) async throws {
        var connectUrl = createConnectUrl(url: url, connectionToken: negotiateResponse?.connectionToken)

        var transportExceptions: [Error] = []
        let transports = negotiateResponse?.availableTransports ?? []
        var negotiate = negotiateResponse

        for endpoint in transports {
            let transportOrError = await resolveTransportOrError(endpoint: endpoint, requestedTransport: requestedTransport, requestedTransferFormat: requestedTransferFormat, useStatefulReconnect: negotiate?.useStatefulReconnect ?? false)
            if let error = transportOrError as? Error {
                transportExceptions.append(error)
            } else if let transportInstance = transportOrError as? Transport {
                transport = transportInstance
                if negotiate == nil {
                    negotiate = try await getNegotiationResponse(url: url)
                    connectUrl = createConnectUrl(url: url, connectionToken: negotiate?.connectionToken)
                }
                do {
                    try await startTransport(url: connectUrl, transferFormat: requestedTransferFormat)
                    connectionId = negotiate?.connectionId
                    logger.log(level: .debug, message: "Using the \(endpoint.transport) transport successfully.")
                    return
                } catch {
                    logger.log(level: .error, message: "Failed to start the transport '\(endpoint.transport)': \(error)")
                    negotiate = nil
                    transportExceptions.append(error)
                    if connectionState != .connecting {
                        let message = "Failed to select transport before stop() was called."
                        logger.log(level: .debug, message: "\(message)")
                        throw SignalRError.failedToStartConnection(message)
                    }
                }
            }
        }

        if !transportExceptions.isEmpty {
            let errorsDescription = transportExceptions.map { "\($0)" }.joined(separator: " ")
            throw SignalRError.failedToStartConnection("Unable to connect to the server with any of the available transports. \(errorsDescription)")
        }

        throw SignalRError.failedToStartConnection("None of the transports supported by the client are supported by the server.")
    }

    private func startTransport(url: String, transferFormat: TransferFormat) async throws {
        await transport!.onReceive(self.onReceive)
        await transport!.onClose { [weak self] error in
            guard let self = self else { return }
            await self.handleConnectionClose(error: error)
        }

        do {
            try await transport!.connect(url: url, transferFormat: transferFormat)
        } catch {
            await transport!.onReceive(nil)
            await transport!.onClose(nil)
            throw error
        }
    }

    private func handleConnectionClose(error: Error?) async {
        logger.log(level: .debug, message: "HttpConnection.stopConnection(\(String(describing: error))) called while in state \(connectionState).")

        transport = nil

        let finalError = stopError ?? error
        stopError = nil
        closeDuringStartError = finalError ?? SignalRError.connectionAborted

        if connectionState == .disconnected {
            logger.log(level: .debug, message: "Call to HttpConnection.stopConnection(\(String(describing: finalError))) was ignored because the connection is already in the disconnected state.")
            return
        }

        if (connectionState == .connecting) {
            // connecting means start still control the lifetime. As we set closeDuringStartError, it throws there.
            logger.log(level: .debug, message: "Call to HttpConnection.stopConnection(\(String(describing: finalError))) was ignored because the connection is already in the connecting state.")
            return
        }

        if let error = finalError {
            logger.log(level: .error, message: "Connection disconnected with error '\(error)'.")
        } else {
            logger.log(level: .information, message: "Connection disconnected.")
        }

        connectionId = nil
        await completeConnectionClose(error: finalError)
    }

    // Should be called whenever connection is started (start() doesn't throw and connection is closed)
    private func completeConnectionClose(error: Error?) async {
        connectionState = .disconnected

        // There's a chance that we call close() and status changed to disconnecting and startinteral throws.
        // We should not call onclose again
        if connectionStartedSuccessfully {
            connectionStartedSuccessfully = false
                await self.onClose?(error)
        }
    }

    // MARK: - Helper Methods

    private static func resolveUrl(_ url: String) -> String {
        // Implement URL resolution logic if necessary
        return url
    }

    private func resolveNegotiateUrl(url: String) -> String {
        var negotiateUrlComponents = URLComponents(string: url)!
        if !negotiateUrlComponents.path.hasSuffix("/") {
            negotiateUrlComponents.path += "/"
        }
        negotiateUrlComponents.path += "negotiate"
        var queryItems = negotiateUrlComponents.queryItems ?? []
        if !queryItems.contains(where: { $0.name == "negotiateVersion" }) {
            queryItems.append(URLQueryItem(name: "negotiateVersion", value: "\(negotiateVersion)"))
        }
        if let useStatefulReconnect = options.useStatefulReconnect, useStatefulReconnect {
            queryItems.append(URLQueryItem(name: "useStatefulReconnect", value: "true"))
        }
        negotiateUrlComponents.queryItems = queryItems
        return negotiateUrlComponents.url!.absoluteString
    }

    private func createConnectUrl(url: String, connectionToken: String?) -> String {
        guard let token = connectionToken else { return url }
        var urlComponents = URLComponents(string: url)!
        var queryItems = urlComponents.queryItems ?? []
        queryItems.append(URLQueryItem(name: "id", value: token))
        urlComponents.queryItems = queryItems
        return urlComponents.url!.absoluteString
    }

    private func constructTransport(transport: HttpTransportType) async throws -> Transport {
        switch transport {
        case .webSockets:
            return WebSocketTransport(
                accessTokenFactory: accessTokenFactory,
                logger: logger,
                headers: options.headers ?? [:]
            )
        case .serverSentEvents:
            let accessToken = await self.httpClient.accessToken
            return ServerSentEventTransport(httpClient: self.httpClient, accessToken: accessToken, logger: logger, options: options)
        case .longPolling:
            return LongPollingTransport(httpClient: httpClient, logger: logger, options: options)
        default:
            throw SignalRError.unsupportedTransport("Unkonwn transport type '\(transport)'.")
        }
    }

    private func resolveTransportOrError(endpoint: AvailableTransport, requestedTransport: HttpTransportType?, requestedTransferFormat: TransferFormat, useStatefulReconnect: Bool) async -> Any {
        guard let transportType = HttpTransportType.from(endpoint.transport) else {
            logger.log(level: .debug, message: "Skipping transport '\(endpoint.transport)' because it is not supported by this client.")
            return SignalRError.unsupportedTransport("Skipping transport '\(endpoint.transport)' because it is not supported by this client.")
        }

        if transportMatches(requestedTransport: requestedTransport, actualTransport: transportType) {
            let transferFormats = endpoint.transferFormats.compactMap { TransferFormat($0) }
            if transferFormats.contains(requestedTransferFormat) {
                do {
                    features["reconnect"] = (transportType == .webSockets && useStatefulReconnect) ? true : nil
                    let constructedTransport = try await constructTransport(transport: transportType)
                    return constructedTransport
                } catch {
                    return error
                }
            } else {
                logger.log(level: .debug, message: "Skipping transport '\(transportType)' because it does not support the requested transfer format '\(requestedTransferFormat)'.")
                return SignalRError.unsupportedTransport("'\(transportType)' does not support \(requestedTransferFormat).")
            }
        } else {
            logger.log(level: .debug, message: "Skipping transport '\(transportType)' because it was disabled by the client.")
            return SignalRError.unsupportedTransport("'\(transportType)' is disabled by the client.")
        }
    }

    private func transportMatches(requestedTransport: HttpTransportType?, actualTransport: HttpTransportType) -> Bool {
        guard let requestedTransport = requestedTransport else { return true } // Allow any the transport if options is not set
        return requestedTransport.contains(actualTransport)
    }

    private func buildURLRequest(url: String, method: String?, content: Data?, headers: [String: String]?, timeout: TimeInterval?) -> URLRequest {
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = method ?? "GET"
        urlRequest.httpBody = content
        if let headers = headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        if let timeout = timeout {
            urlRequest.timeoutInterval = timeout
        }
        return urlRequest
    }
}



---
File: /Sources/SignalRClient/HubConnection.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

public actor HubConnection {
    private static let defaultTimeout: TimeInterval = 30
    private static let defaultPingInterval: TimeInterval = 15
    private static let defaultStatefulReconnectBufferSize: Int = 100_000_000 // bytes of messages

    private var invocationBinder: DefaultInvocationBinder
    private var invocationHandler: InvocationHandler

    private let serverTimeout: TimeInterval
    private let keepAliveInterval: TimeInterval
    private let logger: Logger
    private let hubProtocol: HubProtocol
    private let connection: ConnectionProtocol
    private let retryPolicy: RetryPolicy
    private let keepAliveScheduler: TimeScheduler
    private let serverTimeoutScheduler: TimeScheduler
    private let statefulReconnectBufferSize: Int

    private var connectionStarted: Bool = false
    private var receivedHandshakeResponse: Bool = false
    private var invocationId: Int = 0
    private var connectionStatus: HubConnectionState = .Stopped
    private var stopping: Bool = false
    private var stopDuringStartError: Error?
    private nonisolated(unsafe) var handshakeResolver: ((HandshakeResponseMessage) -> Void)?
    private nonisolated(unsafe) var handshakeRejector: ((Error) -> Void)?
    private var closedHandlers: [(Error?) async -> Void] = []
    private var reconnectingHandlers: [(Error?) async -> Void] = []
    private var reconnectedHandlers: [() async -> Void] = []

    private var stopTask: Task<Void, Never>?
    private var startTask: Task<Void, Error>?
    private var startSuccessfully = false

    internal init(connection: ConnectionProtocol,
                  logger: Logger,
                  hubProtocol: HubProtocol,
                  retryPolicy: RetryPolicy,
                  serverTimeout: TimeInterval?,
                  keepAliveInterval: TimeInterval?,
                  statefulReconnectBufferSize: Int?) {
        self.serverTimeout = serverTimeout ?? HubConnection.defaultTimeout
        self.keepAliveInterval = keepAliveInterval ?? HubConnection.defaultPingInterval
        self.statefulReconnectBufferSize = statefulReconnectBufferSize ?? HubConnection.defaultStatefulReconnectBufferSize

        self.logger = logger
        self.retryPolicy = retryPolicy

        self.connection = connection
        self.hubProtocol = hubProtocol

        self.invocationBinder = DefaultInvocationBinder()
        self.invocationHandler = InvocationHandler()
        self.keepAliveScheduler = TimeScheduler(initialInterval: self.keepAliveInterval)
        self.serverTimeoutScheduler = TimeScheduler(initialInterval: self.serverTimeout)
    }

    public func start() async throws {
        if (connectionStatus != .Stopped) {
            throw SignalRError.invalidOperation("Start client while not in a stopped state.")
        }

        connectionStatus = .Connecting

        startTask = Task {
            do {
                await self.connection.onClose(handleConnectionClose)
                await self.connection.onReceive(processIncomingData)

                try await startInternal()
                logger.log(level: .debug, message: "HubConnection started")
                startSuccessfully = true
            } catch {
                connectionStatus = .Stopped
                stopping = false
                await keepAliveScheduler.stop()
                await serverTimeoutScheduler.stop()
                logger.log(level: .debug, message: "HubConnection start failed \(error)")
                throw error
            }
        }

        try await startTask!.value
    }

    public func stop() async {
        // 1. Before the start, it should be Stopped. Just return
        if (connectionStatus == .Stopped) {
            logger.log(level: .debug, message: "Connection is already stopped")
            return
        }

        // 2. Another stop is running, just wait for it
        if (stopping) {
            logger.log(level: .debug, message: "Connection is already stopping")
            await stopTask?.value
            return
        }

        stopping = true

        // In this step, there's no other start running
        stopTask = Task {
            await stopInternal()
        }

        await stopTask!.value
    }

    public func send(method: String, arguments: Any...) async throws {
        let (nonstreamArguments, streamArguments) = splitStreamArguments(arguments: arguments)
        let streamIds = await invocationHandler.createClientStreamIds(count: streamArguments.count)
        let invocationMessage = InvocationMessage(target: method, arguments: AnyEncodableArray(nonstreamArguments), streamIds: streamIds, headers: nil, invocationId: nil)
        let data = try hubProtocol.writeMessage(message: invocationMessage)
        logger.log(level: .debug, message: "Sending message to target: \(method)")
        try await sendMessageInternal(data)
        launchStreams(streamIds: streamIds, clientStreams: streamArguments)
    }
    
    private func splitStreamArguments(arguments: Any...) -> ([Any], [any AsyncSequence]) {
        var nonstreamArguments: [Any] = []
        var streamArguments: [any AsyncSequence] = []
        for argument in arguments {
            if let stream = argument as? (any AsyncSequence) {
                streamArguments.append(stream)
            } else {
                nonstreamArguments.append(argument)
            }
        }
        return (nonstreamArguments, streamArguments)
    }

    private func launchStreams(streamIds: [String], clientStreams: [any AsyncSequence]) {
        for i in 0 ..< streamIds.count {
            Task {
                let stream = clientStreams[i]
                var err: String? = nil
                do {
                    for try await item in stream {
                        let streamItem = StreamItemMessage(invocationId: streamIds[i], item: AnyEncodable(item), headers: nil)
                        let data = try hubProtocol.writeMessage(message: streamItem)
                        try await sendMessageInternal(data)
                    }
                } catch {
                    err = "\(error)"
                    logger.log(level: .error, message: "Fail to send client stream message :\(error)")
                }
                do {
                    let completionMessage = CompletionMessage(invocationId: streamIds[i], error: err, result: AnyEncodable(nil), headers: nil)
                    let data = try hubProtocol.writeMessage(message: completionMessage)
                    try await sendMessageInternal(data)
                } catch {
                    logger.log(level: .error, message: "Fail to send client stream complete message :\(error)")
                }
            }
        }
    }
    
    public func invoke(method: String, arguments: Any...) async throws -> Void {
        let (nonstreamArguments, streamArguments) = splitStreamArguments(arguments: arguments)
        let streamIds = await invocationHandler.createClientStreamIds(count: streamArguments.count)
        let (invocationId, tcs) = await invocationHandler.create()
        let invocationMessage = InvocationMessage(target: method, arguments: AnyEncodableArray(nonstreamArguments), streamIds: streamIds, headers: nil, invocationId: invocationId)
        let data = try hubProtocol.writeMessage(message: invocationMessage)
        logger.log(level: .debug, message: "Invoke message to target: \(method), invocationId: \(invocationId)")
        try await sendMessageInternal(data)
        launchStreams(streamIds: streamIds, clientStreams: streamArguments)
        _ = try await tcs.task()
    }

    public func invoke<TReturn>(method: String, arguments: Any...) async throws -> TReturn {
        let (nonstreamArguments, streamArguments) = splitStreamArguments(arguments: arguments)
        let streamIds = await invocationHandler.createClientStreamIds(count: streamArguments.count)
        let (invocationId, tcs) = await invocationHandler.create()
        invocationBinder.registerReturnValueType(invocationId: invocationId, types: TReturn.self)
        let invocationMessage = InvocationMessage(target: method, arguments: AnyEncodableArray(nonstreamArguments), streamIds: streamIds, headers: nil, invocationId: invocationId)
        do {
            let data = try hubProtocol.writeMessage(message: invocationMessage)
            logger.log(level: .debug, message: "Invoke message to target: \(method), invocationId: \(invocationId)")
            try await sendMessageInternal(data)
            launchStreams(streamIds: streamIds, clientStreams: streamArguments)
        } catch {
            await invocationHandler.cancel(invocationId: invocationId, error: error)
            invocationBinder.removeReturnValueType(invocationId: invocationId)
            throw error
        }

        if let returnVal = (try await tcs.task()) as? TReturn {
            return returnVal
        } else {
            throw SignalRError.invalidOperation("Cannot convert the result of the invocation to the specified type.")
        }
    }

    public func stream<Element>(method: String, arguments: Any...) async throws -> any StreamResult<Element> {
        let (nonstreamArguments, streamArguments) = splitStreamArguments(arguments: arguments)
        let streamIds = await invocationHandler.createClientStreamIds(count: streamArguments.count)
        let (invocationId, stream) = await invocationHandler.createStream()
        invocationBinder.registerReturnValueType(invocationId: invocationId, types: Element.self)
        let StreamInvocationMessage = StreamInvocationMessage(invocationId: invocationId, target: method, arguments: AnyEncodableArray(nonstreamArguments), streamIds: streamIds, headers: nil)
        do {
            let data = try hubProtocol.writeMessage(message: StreamInvocationMessage)
            logger.log(level: .debug, message: "Stream message to target: \(method), invocationId: \(invocationId)")
            try await sendMessageInternal(data)
            launchStreams(streamIds: streamIds, clientStreams: streamArguments)
        } catch {
            await invocationHandler.cancel(invocationId: invocationId, error: error)
            invocationBinder.removeReturnValueType(invocationId: invocationId)
            throw error
        }

        let typedStream = AsyncThrowingStream<Element, Error> { continuation in
            Task {
                do {
                    for try await item in stream {
                        if let returnVal = item as? Element {
                            continuation.yield(returnVal)
                        } else {
                            throw SignalRError.invalidOperation("Cannot convert the result of the invocation to the specified type.")
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
        let streamResult = DefaultStreamResult(stream: typedStream)
        streamResult.onCancel = {
            do {
                let cancelInvocation = CancelInvocationMessage(invocationId: invocationId, headers: nil)
                let data = try self.hubProtocol.writeMessage(message: cancelInvocation)
                await self.invocationHandler.cancel(invocationId: invocationId, error: SignalRError.streamCancelled)
                try await self.sendMessageInternal(data)
            } catch {}
        }

        return streamResult
    }

    internal func on(method: String, types: [Any.Type], handler: @escaping ([Any]) async throws -> Void) {
        invocationBinder.registerSubscription(methodName: method, types: types, handler: handler)
    }

    internal func on(method: String, types: [Any.Type], handler: @escaping ([Any]) async throws -> Any) {
        invocationBinder.registerSubscription(methodName: method, types: types, handler: handler)
    }

    public func off(method: String) {
        invocationBinder.removeSubscrioption(methodName: method)
    }

    public func onClosed(handler: @escaping (Error?) async -> Void) {
        closedHandlers.append(handler)
    }

    private func triggerClosedHandlers(error: Error?) async {
        for handler in closedHandlers {
            await handler(error)
        }
    }

    public func onReconnecting(handler: @escaping (Error?) async -> Void) {
        reconnectingHandlers.append(handler)
    }

    private func triggerReconnectingHandlers(error: Error?) async {
        for handler in reconnectingHandlers {
            await handler(error)
        }
    }

    public func onReconnected(handler: @escaping () async -> Void) {
        reconnectedHandlers.append(handler)
    }

    private func triggerReconnectedHandlers() async {
        for handler in reconnectedHandlers {
            await handler()
        }
    }

    public func state() -> HubConnectionState {
        return connectionStatus
    }

    private func stopInternal() async {
        if (connectionStatus == .Stopped) {
            return
        }

        let startTask = self.startTask

        stopDuringStartError = SignalRError.connectionAborted
        if (handshakeRejector != nil) {
            handshakeRejector!(SignalRError.connectionAborted)
        }

        await connection.stop(error: nil)

        do {
            try await startTask?.value
        } catch {
            // If start failed, already in stopped state
        }
    }

    @Sendable internal func handleConnectionClose(error: Error?) async {
        logger.log(level: .information, message: "Connection closed")
        stopDuringStartError = error ?? SignalRError.connectionAborted

        // Should not happen? It should either changed to stopped in another complete (which has called close handler) or in start() via throw
        if (connectionStatus == .Stopped) {
            logger.log(level: .warning, message: "Connection is stopped during connection close. It won't trigger close handlers.")
            return
        }

        stopDuringStartError = SignalRError.connectionAborted
        if (handshakeResolver != nil) {
            handshakeRejector!(SignalRError.connectionAborted)
        }

        if (stopping) {
            await completeClose(error: error)
            return
        }

        // Several status possible
        // 1. Connecting: In this case, we're still in the control of start(), don't reconnect here but let start() fail (throw error in startInternal())
        // 2. Connected: In this case, we should reconnect
        // 3. Reconnecting: In this case, we're in the control of previous reconnect(), let that function handle the reconnection

        if (connectionStatus == .Connected) {
            do {
                try await reconnect(error: error)
            } catch {
                logger.log(level: .warning, message: "Connection reconnect failed: \(error)")
            }
        }
    }

    internal func reconnect(error: Error?) async throws {
        var retryCount = 0
        let startTime = DispatchTime.now()
        var elapsed: TimeInterval = 0.0
        var lastError: Error? = error

        // reconnect
        while let interval = retryPolicy.nextRetryInterval(retryContext: RetryContext(
            retryCount: retryCount,
            elapsed: elapsed,
            retryReason: lastError
        )) {
            try Task.checkCancellation()
            if (stopping) {
                break
            }

            logger.log(level: .debug, message: "Connection reconnecting")
            connectionStatus = .Reconnecting
            await triggerReconnectingHandlers(error: lastError)
            if (connectionStatus != .Reconnecting) {
                logger.log(level: .debug, message: "Connection left the reconnecting state in onreconnecting callback. Done reconnecting.")
                break
            }

            do {
                try await startInternal()

                // ConnectionState updated inside
                await triggerReconnectedHandlers()
                return
            } catch {
                lastError = error
                logger.log(level: .warning, message: "Connection reconnect failed: \(error)")
            }

            if (stopping) {
                break
            }

            do {
                try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000)) // interval in seconds to ns
            } catch {
                break
            }

            retryCount += 1
            elapsed = Double(DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
        }

        logger.log(level: .warning, message: "Connection reconnect exceeded retry policy")
        await completeClose(error: lastError)
    }

    // Internal for testing
    @Sendable internal func processIncomingData(_ prehandledData: StringOrData) async {
        var data: StringOrData? = prehandledData
        if (!receivedHandshakeResponse) {
            do {
                data = try processHandshakeResponse(prehandledData)
                receivedHandshakeResponse = true
            } catch {
                // close connection
            }
        }

        if (data == nil) {
            return
        }

        // show the data now
        if case .string(let str) = data {
            logger.log(level: .debug, message: "Received data: \(str)")
        } else if case .data(let data) = data {
            logger.log(level: .debug, message: "Received data: \(data)")
        }

        do {
            let hubMessage = try hubProtocol.parseMessages(input: data!, binder: invocationBinder)
            for message in hubMessage {
                await dispatchMessage(message)
            }
        } catch {
            logger.log(level: .error, message: "Error parsing messages: \(error)")
        }
    }

    func dispatchMessage(_ message: HubMessage) async {
        await serverTimeoutScheduler.refreshSchduler()

        switch message {
        case let message as InvocationMessage:
            // Invoke a method
            logger.log(level: .debug, message: "Invocation message received for method: \(message.target)")
            do {
                try await invokeClientMethod(message: message)
            } catch {
                logger.log(level: .error, message: "Error invoking method: \(error)")
            }
            break
        case let message as StreamItemMessage:
            logger.log(level: .debug, message: "Stream item message received for invocation: \(message.invocationId!)")
            await invocationHandler.setStreamItem(message: message)
            break
        case let message as CompletionMessage:
            logger.log(level: .debug, message: "Completion message received for invocation: \(message.invocationId!), error: \(message.error ?? "nil"), result: \(message.result.value ?? "nil")")
            await invocationHandler.setResult(message: message)
            invocationBinder.removeReturnValueType(invocationId: message.invocationId!)
            break
        case _ as PingMessage:
            // Don't care about the content of ping
            break
        case _ as CloseMessage:
            // Close
            break
        case _ as AckMessage:
            // TODO: In stateful reconnect
            break
        case _ as SequenceMessage:
            // TODO: In stateful reconnect
            break
        default:
            logger.log(level: .warning, message: "Unknown message type: \(message)")
        }
    }

    private func invokeClientMethod(message: InvocationMessage) async throws {
        guard let handler = invocationBinder.getHandler(methodName: message.target) else {
            logger.log(level: .warning, message: "No handler registered for method: \(message.target)")
            if let invocationId = message.invocationId {
                logger.log(level: .warning, message: "No result given for method: \(message.target), and invocationId: \(invocationId)")
                let completionMessage = CompletionMessage(invocationId: invocationId, error: "No handler registered for method: \(message.target)", result: AnyEncodable(nil), headers: nil)
                let data = try hubProtocol.writeMessage(message: completionMessage)
                try await sendMessageInternal(data)
            }
            return            
        }

        let expectResponse = message.invocationId != nil
        if (expectResponse) {
            var result: Any? = try await handler(message.arguments.value ?? [])
            if (result is Void) {
                // Void is not encodeable
                result = nil
            }
            let completionMessage = CompletionMessage(invocationId: message.invocationId!, error: nil, result: AnyEncodable(result), headers: nil)
            let data = try hubProtocol.writeMessage(message: completionMessage)
            try await sendMessageInternal(data)
        } else {
            _ = try await handler(message.arguments.value ?? [])
        }
    }

    private func completeClose(error: Error?) async {
        connectionStatus = .Stopped
        stopping = false
        await keepAliveScheduler.stop()
        await serverTimeoutScheduler.stop()

        // Either throw from start(), either call close handlers
        if (startSuccessfully) {
            startSuccessfully = false
            await triggerClosedHandlers(error: error)
        }
    }

    private func startInternal() async throws {
        try Task.checkCancellation()

        guard stopping == false else {
            throw SignalRError.invalidOperation("Stopping is called")
        }

        logger.log(level: .debug, message: "Starting HubConnection")

        stopDuringStartError = nil
        await keepAliveScheduler.stop() // make sure to stop the keepalive scheduler
        await serverTimeoutScheduler.stop() // make sure to stop the server timeout scheduler

        try await connection.start(transferFormat: hubProtocol.transferFormat)

        // After connection open, perform handshake
        let version = hubProtocol.version
        // As we only support 1 now
        guard version == 1 else {
            logger.log(level: .error, message: "Unsupported handshake version: \(version)")
            throw SignalRError.unsupportedHandshakeVersion
        }

        receivedHandshakeResponse = false
        let handshakeRequest = HandshakeRequestMessage(protocol: hubProtocol.name, version: version)

        logger.log(level: .debug, message: "Sending handshake request message.")

        do {
            _ = try await withUnsafeThrowingContinuation { continuation in 
                var hanshakeFinished: Bool = false
                handshakeResolver = { message in
                    if (hanshakeFinished) {
                        return
                    }
                    hanshakeFinished = true
                    continuation.resume(returning: message)
                }
                handshakeRejector = { error in
                    if (hanshakeFinished) {
                        return
                    }
                    hanshakeFinished = true
                    continuation.resume(throwing: error)
                }

                // Send handshake request
                Task {
                    do {
                        try await self.sendMessageInternal(.string(HandshakeProtocol.writeHandshakeRequest(handshakeRequest: handshakeRequest)))
                        logger.log(level: .debug, message: "Sent handshake request message with version: \(version), protocol: \(hubProtocol.name)")
                    } catch {
                        self.handshakeRejector!(error)
                    }
                }
            }

            let inherentKeepAlive = await connection.inherentKeepAlive
            if (!inherentKeepAlive) {
                await keepAliveScheduler.start {
                    do {
                        let state = self.state()
                        if (state == .Connected) {
                            try await self.sendPing()
                        }
                    } catch {
                        self.logger.log(level: .debug, message: "Error sending ping: \(error)") // We don't care about this error
                    }
                }
            }
            await serverTimeoutScheduler.start {
                self.logger.log(level: .warning, message: "Server timeout")
                await self.connection.stop(error: SignalRError.serverTimeout(self.serverTimeout))
            }

            guard stopDuringStartError == nil else {
                throw stopDuringStartError!
            }

            // IMPORTANT: There should be no async code start from here. Otherwise, we may lost the control of the connection lifecycle
            // Either the error throw by stopDuringStartError, either it's connected status so `handleConnectionClose` can call reconnect there.

            connectionStatus = .Connected

            logger.log(level: .debug, message: "Handshake completed")
        } catch {
            logger.log(level: .error, message: "Handshake failed: \(error)")
            throw error
        }
    }

    private func sendMessageInternal(_ content: StringOrData) async throws {
        await resetKeepAlive()
        try await connection.send(content)
    }

    private func processHandshakeResponse(_ content: StringOrData) throws -> StringOrData? {
        var remainingData: StringOrData?
        var handshakeResponse: HandshakeResponseMessage

        do {
            (remainingData, handshakeResponse) = try HandshakeProtocol.parseHandshakeResponse(data: content)
        } catch {
            logger.log(level: .error, message: "Error parsing handshake response: \(error)")
            handshakeRejector!(error)
            throw error
        }

        if (handshakeResponse.error != nil) {
            logger.log(level: .error, message: "Server returned handshake error: \(handshakeResponse.error!)") 
            let error = SignalRError.handshakeError(handshakeResponse.error!)
            handshakeRejector!(error)
            throw error
        } else {
            logger.log(level: .debug, message: "Handshake compeleted")
        }

        handshakeResolver!(handshakeResponse)
        return remainingData
    }

    private func resetKeepAlive() async {
        let inherentKeepAlive = await connection.inherentKeepAlive
        if (inherentKeepAlive) {
            await keepAliveScheduler.stop()
            return
        }

        await keepAliveScheduler.refreshSchduler()
    }

    private func sendPing() async throws {
        let pingMessage = PingMessage()
        let data = try hubProtocol.writeMessage(message: pingMessage)
        try await sendMessageInternal(data)
    }

    private class SubscriptionEntity {
        public let types: [Any.Type]
        public let callback: ([Any]) async throws -> Any

        init(types: [Any.Type], callback: @escaping ([Any]) async throws -> Any) {
            self.types = types
            self.callback = callback
        }
    }

    private struct DefaultInvocationBinder: InvocationBinder, @unchecked Sendable {
        private let lock = DispatchSemaphore(value: 1)
        private var subscriptionHandlers: [String: SubscriptionEntity] = [:]
        private var returnValueHandler: [String: Any.Type] = [:]

        mutating func registerSubscription(methodName: String, types: [Any.Type], handler: @escaping ([Any]) async throws -> Any) {
            lock.wait()
            defer { lock.signal() }
            subscriptionHandlers[methodName] = SubscriptionEntity(types: types, callback: handler)
        }

        mutating func removeSubscrioption(methodName: String) {
            lock.wait()
            defer { lock.signal() }
            subscriptionHandlers[methodName] = nil
        }

        mutating func registerReturnValueType(invocationId: String, types: Any.Type) {
            lock.wait()
            defer { lock.signal() }
            returnValueHandler[invocationId] = types
        }

        mutating func removeReturnValueType(invocationId: String) {
            lock.wait()
            defer { lock.signal() }
            returnValueHandler[invocationId] = nil
        }

        func getHandler(methodName: String) -> (([Any]) async throws -> Any)? {
            lock.wait()
            defer { lock.signal() }
            return subscriptionHandlers[methodName]?.callback
        }

        func getReturnType(invocationId: String) -> (any Any.Type)? {
            lock.wait()
            defer { lock.signal() }
            return returnValueHandler[invocationId]
        }

        func getParameterTypes(methodName: String) -> [any Any.Type] {
            lock.wait()
            defer { lock.signal() }
            return subscriptionHandlers[methodName]?.types ?? []
        }

        func getStreamItemType(streamId: String) -> (any Any.Type)? {
            lock.wait()
            defer { lock.signal() }
            return returnValueHandler[streamId] 
        }   
    }

    private actor InvocationHandler {
        private var invocations: [String: InvocationType] = [:]
        private var id = 0

        func create() async -> (String, TaskCompletionSource<Any?>) {
            let id = nextId()
            let tcs = TaskCompletionSource<Any?>()
            invocations[id] = .Invocation(tcs)
            return (id, tcs)
        }

        func createStream() async -> (String, AsyncThrowingStream<Any, Error>) {
            let id = nextId()
            let stream = AsyncThrowingStream<Any, Error> { continuation in
                invocations[id] = .Stream(continuation)
            }
            return (id, stream)
        }
        
        func createClientStreamIds(count: Int) -> [String] {
            var streamIds: [String] = []
            for _ in 0 ..< count {
                streamIds.append(nextId())
            }
            return streamIds
        }

        func setResult(message: CompletionMessage) async {
            if let invocation = invocations[message.invocationId!] {
                invocations[message.invocationId!] = nil

                if case .Invocation(let tcs) = invocation {
                    if (message.error != nil) {
                        _ = await tcs.trySetResult(.failure(SignalRError.invocationError(message.error!)))
                    } else {
                        _ = await tcs.trySetResult(.success(message.result.value))
                    }
                } else if case .Stream(let continuation) = invocation {
                    if (message.error != nil) {
                        continuation.finish(throwing: SignalRError.invocationError(message.error!))
                    } else {
                        if (message.result.value != nil) {
                            continuation.yield(message.result.value!)
                        }
                        continuation.finish()
                    }
                }
            }
        }

        func setStreamItem(message: StreamItemMessage) async {
            if let invocation = invocations[message.invocationId!] {
                if case .Stream(let continuation) = invocation {
                    continuation.yield(message.item.value!)
                }
            }
        }

        func cancel(invocationId: String, error: Error) async {
            if let invocation = invocations[invocationId] {
                invocations[invocationId] = nil
                if case .Invocation(let tcs) = invocation {
                    _ = await tcs.trySetResult(.failure(error))
                } else if case .Stream(let continuation) = invocation {
                    continuation.finish(throwing: error)
                }
            } 
        }

        private func nextId() -> String {
            id = id + 1
            return String(id)
        }

        private enum InvocationType {
            case Invocation(TaskCompletionSource<Any?>)
            case Stream(AsyncThrowingStream<Any, Error>.Continuation)
        }
    }

    private class DefaultStreamResult<Element>: StreamResult {
        internal var onCancel: (() async -> Void)?
        public var stream: AsyncThrowingStream<Element, Error>

        init(stream: AsyncThrowingStream<Element, Error>) {
            self.stream = stream
        }

        func cancel() async {
            await onCancel?()
        }
    }
}

public enum HubConnectionState {
    // The connection is stopped. Start can only be called if the connection is in this state.
    case Stopped
    case Connecting
    case Connected
    case Reconnecting
}



---
File: /Sources/SignalRClient/HubConnection+On.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

extension HubConnection {
    public func on(_ methodName: String, handler: @escaping () async -> Void) {
        self.on(method: methodName, types: [], handler: { _ in
            await handler()
        })
    }

    public func on<T>(_ methodName: String, handler: @escaping (T) async -> Void) {
        self.on(method: methodName, types: [T.self], handler: { args in
            guard let arg = args.first as? T else {
                throw SignalRError.invalidOperation("Failed to convert arguments to type \(T.self)")
            }
            await handler(arg)
        })
    }

    public func on<T1, T2>(_ methodName: String, handler: @escaping (T1, T2) async -> Void) {
        self.on(method: methodName, types: [T1.self, T2.self], handler: { args in
            guard let arg1 = args.first as? T1 else {
                throw SignalRError.invalidOperation("Failed to convert first argument to type \(T1.self)")
            }
            guard let arg2 = args.last as? T2 else {
                throw SignalRError.invalidOperation("Failed to convert second argument to type \(T2.self)")
            }
            await handler(arg1, arg2)
        })
    }

    public func on<T1, T2, T3>(_ methodName: String, handler: @escaping (T1, T2, T3) async -> Void) {
        self.on(method: methodName, types: [T1.self, T2.self, T3.self], handler: { args in
            guard let arg1 = args[0] as? T1 else {
                throw SignalRError.invalidOperation("Failed to convert first argument to type \(T1.self)")
            }
            guard let arg2 = args[1] as? T2 else {
                throw SignalRError.invalidOperation("Failed to convert second argument to type \(T2.self)")
            }
            guard let arg3 = args[2] as? T3 else {
                throw SignalRError.invalidOperation("Failed to convert third argument to type \(T3.self)")
            }
            await handler(arg1, arg2, arg3)
        })
    }

    public func on<T1, T2, T3, T4>(_ methodName: String, handler: @escaping (T1, T2, T3, T4) async -> Void) {
        self.on(method: methodName, types: [T1.self, T2.self, T3.self, T4.self], handler: { args in
            guard let arg1 = args[0] as? T1 else {
                throw SignalRError.invalidOperation("Failed to convert first argument to type \(T1.self)")
            }
            guard let arg2 = args[1] as? T2 else {
                throw SignalRError.invalidOperation("Failed to convert second argument to type \(T2.self)")
            }
            guard let arg3 = args[2] as? T3 else {
                throw SignalRError.invalidOperation("Failed to convert third argument to type \(T3.self)")
            }
            guard let arg4 = args[3] as? T4 else {
                throw SignalRError.invalidOperation("Failed to convert fourth argument to type \(T4.self)")
            }
            await handler(arg1, arg2, arg3, arg4)
        })
    }

    public func on<T1, T2, T3, T4, T5>(_ methodName: String, handler: @escaping (T1, T2, T3, T4, T5) async -> Void) {
        self.on(method: methodName, types: [T1.self, T2.self, T3.self, T4.self, T5.self], handler: { args in
            guard let arg1 = args[0] as? T1 else {
                throw SignalRError.invalidOperation("Failed to convert first argument to type \(T1.self)")
            }
            guard let arg2 = args[1] as? T2 else {
                throw SignalRError.invalidOperation("Failed to convert second argument to type \(T2.self)")
            }
            guard let arg3 = args[2] as? T3 else {
                throw SignalRError.invalidOperation("Failed to convert third argument to type \(T3.self)")
            }
            guard let arg4 = args[3] as? T4 else {
                throw SignalRError.invalidOperation("Failed to convert fourth argument to type \(T4.self)")
            }
            guard let arg5 = args[4] as? T5 else {
                throw SignalRError.invalidOperation("Failed to convert fifth argument to type \(T5.self)")
            }
            await handler(arg1, arg2, arg3, arg4, arg5)
        })
    }

    public func on<T1, T2, T3, T4, T5, T6>(_ methodName: String, handler: @escaping (T1, T2, T3, T4, T5, T6) async -> Void) {
        self.on(method: methodName, types: [T1.self, T2.self, T3.self, T4.self, T5.self, T6.self], handler: { args in
            guard let arg1 = args[0] as? T1 else {
                throw SignalRError.invalidOperation("Failed to convert first argument to type \(T1.self)")
            }
            guard let arg2 = args[1] as? T2 else {
                throw SignalRError.invalidOperation("Failed to convert second argument to type \(T2.self)")
            }
            guard let arg3 = args[2] as? T3 else {
                throw SignalRError.invalidOperation("Failed to convert third argument to type \(T3.self)")
            }
            guard let arg4 = args[3] as? T4 else {
                throw SignalRError.invalidOperation("Failed to convert fourth argument to type \(T4.self)")
            }
            guard let arg5 = args[4] as? T5 else {
                throw SignalRError.invalidOperation("Failed to convert fifth argument to type \(T5.self)")
            }
            guard let arg6 = args[5] as? T6 else {
                throw SignalRError.invalidOperation("Failed to convert sixth argument to type \(T6.self)")
            }
            await handler(arg1, arg2, arg3, arg4, arg5, arg6)
        })
    }

    public func on<T1, T2, T3, T4, T5, T6, T7>(_ methodName: String, handler: @escaping (T1, T2, T3, T4, T5, T6, T7) async -> Void) {
        self.on(method: methodName, types: [T1.self, T2.self, T3.self, T4.self, T5.self, T6.self, T7.self], handler: { args in
            guard let arg1 = args[0] as? T1 else {
                throw SignalRError.invalidOperation("Failed to convert first argument to type \(T1.self)")
            }
            guard let arg2 = args[1] as? T2 else {
                throw SignalRError.invalidOperation("Failed to convert second argument to type \(T2.self)")
            }
            guard let arg3 = args[2] as? T3 else {
                throw SignalRError.invalidOperation("Failed to convert third argument to type \(T3.self)")
            }
            guard let arg4 = args[3] as? T4 else {
                throw SignalRError.invalidOperation("Failed to convert fourth argument to type \(T4.self)")
            }
            guard let arg5 = args[4] as? T5 else {
                throw SignalRError.invalidOperation("Failed to convert fifth argument to type \(T5.self)")
            }
            guard let arg6 = args[5] as? T6 else {
                throw SignalRError.invalidOperation("Failed to convert sixth argument to type \(T6.self)")
            }
            guard let arg7 = args[6] as? T7 else {
                throw SignalRError.invalidOperation("Failed to convert seventh argument to type \(T7.self)")
            }
            await handler(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
        })
    }

    public func on<T1, T2, T3, T4, T5, T6, T7, T8>(_ methodName: String, handler: @escaping (T1, T2, T3, T4, T5, T6, T7, T8) async -> Void) {
        self.on(method: methodName, types: [T1.self, T2.self, T3.self, T4.self, T5.self, T6.self, T7.self, T8.self], handler: { args in
            guard let arg1 = args[0] as? T1 else {
                throw SignalRError.invalidOperation("Failed to convert first argument to type \(T1.self)")
            }
            guard let arg2 = args[1] as? T2 else {
                throw SignalRError.invalidOperation("Failed to convert second argument to type \(T2.self)")
            }
            guard let arg3 = args[2] as? T3 else {
                throw SignalRError.invalidOperation("Failed to convert third argument to type \(T3.self)")
            }
            guard let arg4 = args[3] as? T4 else {
                throw SignalRError.invalidOperation("Failed to convert fourth argument to type \(T4.self)")
            }
            guard let arg5 = args[4] as? T5 else {
                throw SignalRError.invalidOperation("Failed to convert fifth argument to type \(T5.self)")
            }
            guard let arg6 = args[5] as? T6 else {
                throw SignalRError.invalidOperation("Failed to convert sixth argument to type \(T6.self)")
            }
            guard let arg7 = args[6] as? T7 else {
                throw SignalRError.invalidOperation("Failed to convert seventh argument to type \(T7.self)")
            }
            guard let arg8 = args[7] as? T8 else {
                throw SignalRError.invalidOperation("Failed to convert eighth argument to type \(T8.self)")
            }
            await handler(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
        })
    }

    public func on<T1, T2, T3, T4, T5, T6, T7, T8, T9>(_ methodName: String, handler: @escaping (T1, T2, T3, T4, T5, T6, T7, T8, T9) async -> Void) {
        self.on(method: methodName, types: [T1.self, T2.self, T3.self, T4.self, T5.self, T6.self, T7.self, T8.self, T9.self], handler: { args in
            guard let arg1 = args[0] as? T1 else {
                throw SignalRError.invalidOperation("Failed to convert first argument to type \(T1.self)")
            }
            guard let arg2 = args[1] as? T2 else {
                throw SignalRError.invalidOperation("Failed to convert second argument to type \(T2.self)")
            }
            guard let arg3 = args[2] as? T3 else {
                throw SignalRError.invalidOperation("Failed to convert third argument to type \(T3.self)")
            }
            guard let arg4 = args[3] as? T4 else {
                throw SignalRError.invalidOperation("Failed to convert fourth argument to type \(T4.self)")
            }
            guard let arg5 = args[4] as? T5 else {
                throw SignalRError.invalidOperation("Failed to convert fifth argument to type \(T5.self)")
            }
            guard let arg6 = args[5] as? T6 else {
                throw SignalRError.invalidOperation("Failed to convert sixth argument to type \(T6.self)")
            }
            guard let arg7 = args[6] as? T7 else {
                throw SignalRError.invalidOperation("Failed to convert seventh argument to type \(T7.self)")
            }
            guard let arg8 = args[7] as? T8 else {
                throw SignalRError.invalidOperation("Failed to convert eighth argument to type \(T8.self)")
            }
            guard let arg9 = args[8] as? T9 else {
                throw SignalRError.invalidOperation("Failed to convert ninth argument to type \(T9.self)")
            }
            await handler(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
        })
    }
}


---
File: /Sources/SignalRClient/HubConnection+OnResult.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

extension HubConnection {
    public func on<Result>(_ methodName: String, handler: @escaping () async -> Result) {
        self.on(method: methodName, types: [], handler: { _ in
            return await handler()
        })
    }

    public func on<T, Result>(_ methodName: String, handler: @escaping (T) async -> Result) {
        self.on(method: methodName, types: [T.self], handler: { args in
            guard let arg = args.first as? T else {
                throw SignalRError.invalidOperation("Failed to convert arguments to type \(T.self)")
            }
            return await handler(arg)
        })
    }

    public func on<T1, T2, Result>(_ methodName: String, handler: @escaping (T1, T2) async -> Result) {
        self.on(method: methodName, types: [T1.self, T2.self], handler: { args in
            guard let arg1 = args.first as? T1 else {
                throw SignalRError.invalidOperation("Failed to convert first argument to type \(T1.self)")
            }
            guard let arg2 = args.last as? T2 else {
                throw SignalRError.invalidOperation("Failed to convert second argument to type \(T2.self)")
            }
            return await handler(arg1, arg2)
        })
    }

    public func on<T1, T2, T3, Result>(_ methodName: String, handler: @escaping (T1, T2, T3) async -> Result) {
        self.on(method: methodName, types: [T1.self, T2.self, T3.self], handler: { args in
            guard let arg1 = args[0] as? T1 else {
                throw SignalRError.invalidOperation("Failed to convert first argument to type \(T1.self)")
            }
            guard let arg2 = args[1] as? T2 else {
                throw SignalRError.invalidOperation("Failed to convert second argument to type \(T2.self)")
            }
            guard let arg3 = args[2] as? T3 else {
                throw SignalRError.invalidOperation("Failed to convert third argument to type \(T3.self)")
            }
            return await handler(arg1, arg2, arg3)
        })
    }

    public func on<T1, T2, T3, T4, Result>(_ methodName: String, handler: @escaping (T1, T2, T3, T4) async -> Result) {
        self.on(method: methodName, types: [T1.self, T2.self, T3.self, T4.self], handler: { args in
            guard let arg1 = args[0] as? T1 else {
                throw SignalRError.invalidOperation("Failed to convert first argument to type \(T1.self)")
            }
            guard let arg2 = args[1] as? T2 else {
                throw SignalRError.invalidOperation("Failed to convert second argument to type \(T2.self)")
            }
            guard let arg3 = args[2] as? T3 else {
                throw SignalRError.invalidOperation("Failed to convert third argument to type \(T3.self)")
            }
            guard let arg4 = args[3] as? T4 else {
                throw SignalRError.invalidOperation("Failed to convert fourth argument to type \(T4.self)")
            }
            return await handler(arg1, arg2, arg3, arg4)
        })
    }

    public func on<T1, T2, T3, T4, T5, Result>(_ methodName: String, handler: @escaping (T1, T2, T3, T4, T5) async -> Result) {
        self.on(method: methodName, types: [T1.self, T2.self, T3.self, T4.self, T5.self], handler: { args in
            guard let arg1 = args[0] as? T1 else {
                throw SignalRError.invalidOperation("Failed to convert first argument to type \(T1.self)")
            }
            guard let arg2 = args[1] as? T2 else {
                throw SignalRError.invalidOperation("Failed to convert second argument to type \(T2.self)")
            }
            guard let arg3 = args[2] as? T3 else {
                throw SignalRError.invalidOperation("Failed to convert third argument to type \(T3.self)")
            }
            guard let arg4 = args[3] as? T4 else {
                throw SignalRError.invalidOperation("Failed to convert fourth argument to type \(T4.self)")
            }
            guard let arg5 = args[4] as? T5 else {
                throw SignalRError.invalidOperation("Failed to convert fifth argument to type \(T5.self)")
            }
            return await handler(arg1, arg2, arg3, arg4, arg5)
        })
    }

    public func on<T1, T2, T3, T4, T5, T6, Result>(_ methodName: String, handler: @escaping (T1, T2, T3, T4, T5, T6) async -> Result) {
        self.on(method: methodName, types: [T1.self, T2.self, T3.self, T4.self, T5.self, T6.self], handler: { args in
            guard let arg1 = args[0] as? T1 else {
                throw SignalRError.invalidOperation("Failed to convert first argument to type \(T1.self)")
            }
            guard let arg2 = args[1] as? T2 else {
                throw SignalRError.invalidOperation("Failed to convert second argument to type \(T2.self)")
            }
            guard let arg3 = args[2] as? T3 else {
                throw SignalRError.invalidOperation("Failed to convert third argument to type \(T3.self)")
            }
            guard let arg4 = args[3] as? T4 else {
                throw SignalRError.invalidOperation("Failed to convert fourth argument to type \(T4.self)")
            }
            guard let arg5 = args[4] as? T5 else {
                throw SignalRError.invalidOperation("Failed to convert fifth argument to type \(T5.self)")
            }
            guard let arg6 = args[5] as? T6 else {
                throw SignalRError.invalidOperation("Failed to convert sixth argument to type \(T6.self)")
            }
            return await handler(arg1, arg2, arg3, arg4, arg5, arg6)
        })
    }

    public func on<T1, T2, T3, T4, T5, T6, T7, Result>(_ methodName: String, handler: @escaping (T1, T2, T3, T4, T5, T6, T7) async -> Result) {
        self.on(method: methodName, types: [T1.self, T2.self, T3.self, T4.self, T5.self, T6.self, T7.self], handler: { args in
            guard let arg1 = args[0] as? T1 else {
                throw SignalRError.invalidOperation("Failed to convert first argument to type \(T1.self)")
            }
            guard let arg2 = args[1] as? T2 else {
                throw SignalRError.invalidOperation("Failed to convert second argument to type \(T2.self)")
            }
            guard let arg3 = args[2] as? T3 else {
                throw SignalRError.invalidOperation("Failed to convert third argument to type \(T3.self)")
            }
            guard let arg4 = args[3] as? T4 else {
                throw SignalRError.invalidOperation("Failed to convert fourth argument to type \(T4.self)")
            }
            guard let arg5 = args[4] as? T5 else {
                throw SignalRError.invalidOperation("Failed to convert fifth argument to type \(T5.self)")
            }
            guard let arg6 = args[5] as? T6 else {
                throw SignalRError.invalidOperation("Failed to convert sixth argument to type \(T6.self)")
            }
            guard let arg7 = args[6] as? T7 else {
                throw SignalRError.invalidOperation("Failed to convert seventh argument to type \(T7.self)")
            }
            return await handler(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
        })
    }

    public func on<T1, T2, T3, T4, T5, T6, T7, T8, Result>(_ methodName: String, handler: @escaping (T1, T2, T3, T4, T5, T6, T7, T8) async -> Result) {
        self.on(method: methodName, types: [T1.self, T2.self, T3.self, T4.self, T5.self, T6.self, T7.self, T8.self], handler: { args in
            guard let arg1 = args[0] as? T1 else {
                throw SignalRError.invalidOperation("Failed to convert first argument to type \(T1.self)")
            }
            guard let arg2 = args[1] as? T2 else {
                throw SignalRError.invalidOperation("Failed to convert second argument to type \(T2.self)")
            }
            guard let arg3 = args[2] as? T3 else {
                throw SignalRError.invalidOperation("Failed to convert third argument to type \(T3.self)")
            }
            guard let arg4 = args[3] as? T4 else {
                throw SignalRError.invalidOperation("Failed to convert fourth argument to type \(T4.self)")
            }
            guard let arg5 = args[4] as? T5 else {
                throw SignalRError.invalidOperation("Failed to convert fifth argument to type \(T5.self)")
            }
            guard let arg6 = args[5] as? T6 else {
                throw SignalRError.invalidOperation("Failed to convert sixth argument to type \(T6.self)")
            }
            guard let arg7 = args[6] as? T7 else {
                throw SignalRError.invalidOperation("Failed to convert seventh argument to type \(T7.self)")
            }
            guard let arg8 = args[7] as? T8 else {
                throw SignalRError.invalidOperation("Failed to convert eighth argument to type \(T8.self)")
            }
            return await handler(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
        })
    }

    public func on<T1, T2, T3, T4, T5, T6, T7, T8, T9, Result>(_ methodName: String, handler: @escaping (T1, T2, T3, T4, T5, T6, T7, T8, T9) async -> Result) {
        self.on(method: methodName, types: [T1.self, T2.self, T3.self, T4.self, T5.self, T6.self, T7.self, T8.self, T9.self], handler: { args in
            guard let arg1 = args[0] as? T1 else {
                throw SignalRError.invalidOperation("Failed to convert first argument to type \(T1.self)")
            }
            guard let arg2 = args[1] as? T2 else {
                throw SignalRError.invalidOperation("Failed to convert second argument to type \(T2.self)")
            }
            guard let arg3 = args[2] as? T3 else {
                throw SignalRError.invalidOperation("Failed to convert third argument to type \(T3.self)")
            }
            guard let arg4 = args[3] as? T4 else {
                throw SignalRError.invalidOperation("Failed to convert fourth argument to type \(T4.self)")
            }
            guard let arg5 = args[4] as? T5 else {
                throw SignalRError.invalidOperation("Failed to convert fifth argument to type \(T5.self)")
            }
            guard let arg6 = args[5] as? T6 else {
                throw SignalRError.invalidOperation("Failed to convert sixth argument to type \(T6.self)")
            }
            guard let arg7 = args[6] as? T7 else {
                throw SignalRError.invalidOperation("Failed to convert seventh argument to type \(T7.self)")
            }
            guard let arg8 = args[7] as? T8 else {
                throw SignalRError.invalidOperation("Failed to convert eighth argument to type \(T8.self)")
            }
            guard let arg9 = args[8] as? T9 else {
                throw SignalRError.invalidOperation("Failed to convert ninth argument to type \(T9.self)")
            }
            return await handler(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
        })
    }
}


---
File: /Sources/SignalRClient/HubConnectionBuilder.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

public class HubConnectionBuilder {
    private var connection: HttpConnection?
    private var logHandler: LogHandler?
    private var logLevel: LogLevel?
    private var hubProtocol: HubProtocol?
    private var serverTimeout: TimeInterval?
    private var keepAliveInterval: TimeInterval?
    private var url: String?
    private var retryPolicy: RetryPolicy?
    private var statefulReconnectBufferSize: Int?
    private var httpConnectionOptions: HttpConnectionOptions = HttpConnectionOptions()

    public init() {}

    public func withLogLevel(logLevel: LogLevel) -> HubConnectionBuilder {
        self.logLevel = logLevel
        self.httpConnectionOptions.logLevel = logLevel
        return self
    }

    public func withLogHandler(logHandler: LogHandler) -> HubConnectionBuilder {
        self.logHandler = logHandler
        return self
    }

    public func withHubProtocol(hubProtocol: HubProtocolType) -> HubConnectionBuilder {
        switch hubProtocol {
        case .json:
            self.hubProtocol = JsonHubProtocol()
        case .messagePack:
            self.hubProtocol = MessagePackHubProtocol()
        }
        return self
    }

    public func withServerTimeout(serverTimeout: TimeInterval) -> HubConnectionBuilder {
        self.serverTimeout = serverTimeout
        return self
    }

    public func withKeepAliveInterval(keepAliveInterval: TimeInterval) -> HubConnectionBuilder {
        self.keepAliveInterval = keepAliveInterval
        return self
    }

    public func withUrl(url: String) -> HubConnectionBuilder {
        self.url = url
        return self
    }

    public func withUrl(url: String, transport: HttpTransportType) -> HubConnectionBuilder {
        self.url = url
        self.httpConnectionOptions.transport = transport
        return self
    }
    
    public func withUrl(url: String, options: HttpConnectionOptions) -> HubConnectionBuilder {
        self.url = url
        self.httpConnectionOptions = options
        return self
    }

    public func withAutomaticReconnect() -> HubConnectionBuilder {
        self.retryPolicy = DefaultRetryPolicy(retryDelays: [0, 2, 10, 30])
        return self
    }

    public func withAutomaticReconnect(retryPolicy: RetryPolicy) -> HubConnectionBuilder {
        self.retryPolicy = retryPolicy
        return self
    }

    public func withAutomaticReconnect(retryDelays: [TimeInterval]) -> HubConnectionBuilder {
        self.retryPolicy = DefaultRetryPolicy(retryDelays: retryDelays)
        return self
    }

//    public func withStatefulReconnect() -> HubConnectionBuilder {
//        return withStatefulReconnect(options: StatefulReconnectOptions())
//    }
//
//    public func withStatefulReconnect(options: StatefulReconnectOptions) -> HubConnectionBuilder {
//        self.statefulReconnectBufferSize = options.bufferSize
//        self.httpConnectionOptions.useStatefulReconnect = true
//        return self
//    }

    public func build() -> HubConnection {
        guard let url = url else {
            fatalError("url must be set with .withUrl(String:)")
        }

        let connection = connection ?? HttpConnection(url: url, options: httpConnectionOptions)
        let logger = Logger(logLevel: logLevel, logHandler: logHandler ?? DefaultLogHandler())
        let hubProtocol = hubProtocol ?? JsonHubProtocol()
        let retryPolicy = retryPolicy ?? DefaultRetryPolicy(retryDelays: []) // No retry by default

        return HubConnection(connection: connection,
                             logger: logger,
                             hubProtocol: hubProtocol,
                             retryPolicy: retryPolicy,
                             serverTimeout: serverTimeout,
                             keepAliveInterval: keepAliveInterval,
                             statefulReconnectBufferSize: statefulReconnectBufferSize)
    }
}

public enum HubProtocolType {
    case json
    case messagePack
}



---
File: /Sources/SignalRClient/InvocationBinder.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

protocol InvocationBinder: Sendable {
    func getReturnType(invocationId: String) -> Any.Type?
    func getParameterTypes(methodName: String) -> [Any.Type]
    func getStreamItemType(streamId: String) -> Any.Type?
}



---
File: /Sources/SignalRClient/Logger.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation
#if canImport(os)
    import os
#endif

public enum LogLevel: Int, Sendable {
    case debug, information, warning, error
}

public protocol LogHandler: Sendable {
    func log(
        logLevel: LogLevel, message: LogMessage, file: String, function: String,
        line: UInt
    )
}

// The current functionality is similar to String. It could be extended in the future.
public struct LogMessage: ExpressibleByStringInterpolation,
CustomStringConvertible {
    private var value: String

    public init(stringLiteral value: String) {
        self.value = value
    }

    public var description: String {
        return self.value
    }
}

struct Logger: Sendable {
    private var logHandler: LogHandler
    private let logLevel: LogLevel?

    init(logLevel: LogLevel?, logHandler: LogHandler) {
        self.logLevel = logLevel
        self.logHandler = logHandler
    }

    public func log(
        level: LogLevel, message: LogMessage, file: String = #fileID,
        function: String = #function, line: UInt = #line
    ) {
        guard let minLevel = self.logLevel, level.rawValue >= minLevel.rawValue
        else {
            return
        }
        logHandler.log(
            logLevel: level, message: message, file: file,
            function: function, line: line
        )
    }
}

#if canImport(os)
    struct DefaultLogHandler: LogHandler {
        var logger: os.Logger
        init() {
            self.logger = os.Logger(
                subsystem: "com.microsoft.signalr.client", category: ""
            )
        }

        public func log(
            logLevel: LogLevel, message: LogMessage, file: String, function: String,
            line: UInt
        ) {
            logger.log(
                level: logLevel.toOSLogType(),
                "[\(Date().description(with: Locale.current), privacy: .public)] [\(String(describing: logLevel), privacy: .public)] [\(file.fileNameWithoutPathAndSuffix(), privacy: .public):\(function, privacy: .public):\(line, privacy: .public)] - \(message, privacy: .public)"
            )
        }
    }

    extension LogLevel {
        fileprivate func toOSLogType() -> OSLogType {
            switch self {
            case .debug:
                return .debug
            case .information:
                return .info
            case .warning:
                // OSLog has no warning type
                return .info
            case .error:
                return .error
            }
        }
    }
#else
    struct DefaultLogHandler: LogHandler {
        public func log(
            logLevel: LogLevel, message: LogMessage, file: String, function: String,
            line: UInt
        ) {
            print(
                "[\(Date().description(with: Locale.current))] [\(String(describing: logLevel))] [\(file.fileNameWithoutPathAndSuffix()):\(function):\(line)] - \(message)"
            )
        }
    }
#endif

extension String {
    fileprivate func fileNameWithoutPathAndSuffix() -> String {
        return self.components(separatedBy: "/").last!.components(
            separatedBy: "."
        ).first!
    }
}



---
File: /Sources/SignalRClient/MessageBuffer.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

actor MessageBuffer {
    private var maxBufferSize: Int
    private var messages: [BufferedItem] = []
    private var bufferedByteCount: Int = 0
    private var totalMessageCount: Int = 0
    private var lastSendSequenceId: Int = 0
    private var nextSendIdx = 0
    private var dequeueContinuations: [CheckedContinuation<Bool, Never>] = []
    private var closed: Bool = false

    init(bufferSize: Int) {
        self.maxBufferSize = bufferSize
    }

    public func enqueue(content: StringOrData) async throws -> Void {
        if closed {
            throw SignalRError.invalidOperation("Message buffer has closed")
        }

        var size: Int
        switch content {
        case .string(let str):
            size = str.lengthOfBytes(using: .utf8)
        case .data(let data):
            size = data.count
        }

        bufferedByteCount = bufferedByteCount + size
        totalMessageCount = totalMessageCount + 1

        return await withCheckedContinuation{ continuation in
            if (bufferedByteCount > maxBufferSize) {
                // If buffer is full, we're tring to backpressure the sending
                // id start from 1
                messages.append(BufferedItem(content: content, size: size, id: totalMessageCount, continuation: continuation))
            } else {            
                messages.append(BufferedItem(content: content, size: size, id: totalMessageCount, continuation: nil))
                continuation.resume()
            }

            while !dequeueContinuations.isEmpty {
                let continuation = dequeueContinuations.removeFirst()
                continuation.resume(returning: true)
            }
        }
    }

    public func ack(sequenceId: Int) throws -> Bool {
        // It might be wrong ack or the ack of previous connection
        if (sequenceId <= 0 || sequenceId > lastSendSequenceId) {
            return false
        }

        var ackedCount: Int = 0
        for item in messages {
            if (item.id <= sequenceId) {
                ackedCount = ackedCount + 1
                bufferedByteCount = bufferedByteCount - item.size
                if let ctu = item.continuation {
                    ctu.resume()
                }
            } else if (bufferedByteCount <= maxBufferSize) {
                if let ctu = item.continuation {
                    ctu.resume()
                }
            } else {
                break
            }
        }

        messages = Array(messages.dropFirst(ackedCount))
        // sending idx will change because we changes the array
        nextSendIdx = nextSendIdx - ackedCount
        return true
    }

    public func WaitToDequeue() async throws -> Bool {
        if (nextSendIdx < messages.count) {
            return true
        }

        return await withCheckedContinuation { continuation in
            dequeueContinuations.append(continuation)
        }
    }

    public func TryDequeue() throws -> StringOrData? {
        if (nextSendIdx < messages.count) {
            let item =  messages[nextSendIdx]
            nextSendIdx = nextSendIdx + 1
            lastSendSequenceId = item.id
            return item.content
        }
        return nil
    }

    public func ResetDequeue() async throws -> Void {
        nextSendIdx = 0
        lastSendSequenceId = messages.count > 0 ? messages[0].id : 0
        while !dequeueContinuations.isEmpty {
            let continuation = dequeueContinuations.removeFirst()
            continuation.resume(returning: true)
        }
    }

    public func close() {
        closed = true
        while !dequeueContinuations.isEmpty {
            let continuation = dequeueContinuations.removeFirst()
            continuation.resume(returning: false)
        }
    }

    private func isInvocationMessage(message: HubMessage) -> Bool {
        switch (message.type) {
            case .invocation, .streamItem, .completion, .streamInvocation, .cancelInvocation:
            return true
            case .close, .sequence, .ping, .ack:
            return false
        }
    }
}

private class BufferedItem {
    let content: StringOrData
    let size: Int
    let id: Int
    let continuation: CheckedContinuation<Void, Never>?

    init(content: StringOrData,
         size: Int,
         id: Int,
         continuation: CheckedContinuation<Void, Never>?) {
        self.content = content
        self.size = size
        self.id = id
        self.continuation = continuation
    }
}


---
File: /Sources/SignalRClient/RetryPolicy.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

public protocol RetryPolicy: Sendable {
    // Return TimeInterval in seconds, and Nil means no more retry
    func nextRetryInterval(retryContext: RetryContext) -> TimeInterval?
}

public struct RetryContext {
    public let retryCount: Int
    public let elapsed: TimeInterval
    public let retryReason: Error?
}

final class DefaultRetryPolicy: RetryPolicy, @unchecked Sendable {
    private let retryDelays: [TimeInterval]
    private var currentRetryCount = 0

    init(retryDelays: [TimeInterval]) {
        self.retryDelays = retryDelays
    }

    func nextRetryInterval(retryContext: RetryContext) -> TimeInterval? {
        if retryContext.retryCount < retryDelays.count {
            return retryDelays[retryContext.retryCount]
        }

        return nil
    }
}


---
File: /Sources/SignalRClient/SignalRError.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

// Define error types for better error handling
public enum SignalRError: Error, Equatable, CustomStringConvertible {
    case incompleteMessage
    case invalidDataType
    case failedToEncodeHandshakeRequest
    case failedToDecodeResponseData
    case expectedHandshakeResponse
    case noHandshakeMessageReceived
    case unsupportedHandshakeVersion
    case handshakeError(String)
    case connectionAborted
    case negotiationError(String)
    case failedToStartConnection(String)
    case invalidOperation(String)
    case unexpectedResponseCode(Int)
    case invalidTextMessageEncoding
    case httpTimeoutError
    case invalidResponseType
    case cannotSentUntilTransportConnected
    case invalidData(String)
    case eventSourceFailedToConnect
    case eventSourceInvalidTransferFormat
    case invalidUrl(String)
    case invocationError(String)
    case unsupportedTransport(String)
    case messageBiggerThan2GB
    case unexpectedMessageType(String)
    case streamCancelled
    case serverTimeout(TimeInterval)

    public var description: String {
        switch self {
        case .incompleteMessage:
            return "Message is incomplete."
        case .invalidDataType:
            return "Invalid data type."
        case .failedToEncodeHandshakeRequest:
            return "Failed to encode handshake request to JSON string."
        case .failedToDecodeResponseData:
            return "Failed to decode response data."
        case .expectedHandshakeResponse:
            return "Expected a handshake response from the server."
        case .noHandshakeMessageReceived:
            return "No handshake message received."
        case .unsupportedHandshakeVersion:
            return "Unsupported handshake version"
        case .handshakeError(let message):
            return "Handshake error: \(message)"
        case .connectionAborted:
            return "Connection aborted."
        case .negotiationError(let message):
            return "Negotiation error: \(message)"
        case .failedToStartConnection(let message):
            return "Failed to start connection: \(message)"
        case .invalidOperation(let message):
            return "Invalid operation: \(message)"
        case .unexpectedResponseCode(let responseCode):
            return "Unexpected response code:\(responseCode)"
        case .invalidTextMessageEncoding:
            return "Invalide text messagge"
        case .httpTimeoutError:
            return "Http timeout"
        case .invalidResponseType:
            return "Invalid response type"
        case .cannotSentUntilTransportConnected:
            return "Cannot send until the transport is connected"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .eventSourceFailedToConnect:
            return """
            EventSource failed to connect. The connection could not be found on the server,
            either the connection ID is not present on the server, or a proxy is refusing/buffering the connection.
            If you have multiple servers check that sticky sessions are enabled.
            """
        case .eventSourceInvalidTransferFormat:
            return "The Server-Sent Events transport only supports the 'Text' transfer format"
        case .invalidUrl(let url):
            return "Invalid url: \(url)"
        case .invocationError(let errorMessage):
            return "Invocation error: \(errorMessage)"
        case .unsupportedTransport(let message):
            return "The transport is not supported: \(message)"
        case .messageBiggerThan2GB:
            return "Messages bigger than 2GB are not supported."
        case .unexpectedMessageType(let messageType):
            return "Unexpected message type: \(messageType)."
        case .streamCancelled:
            return "Stream cancelled."
        case .serverTimeout(let timeout):
            return "Server timeout. Did not receive a message for \(timeout) seconds."
        }
    }
}



---
File: /Sources/SignalRClient/StatefulReconnectOptions.swift
---

public struct StatefulReconnectOptions {
    public var bufferSize: Int?
}


---
File: /Sources/SignalRClient/StreamResult.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

public protocol StreamResult<Element> {
    associatedtype Element
    var stream: AsyncThrowingStream<Element, Error> { get }
    func cancel() async
}


---
File: /Sources/SignalRClient/TaskCompletionSource.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

actor TaskCompletionSource<T> {
    private var continuation: CheckedContinuation<(), Never>?
    private var result: Result<T, Error>?

    func task() async throws -> T {
        if result == nil {
            await withCheckedContinuation { continuation in
                self.continuation = continuation
            }
        }
        return try result!.get()
    }

    func trySetResult(_ result: Result<T, Error>) -> Bool {
        if self.result == nil {
            self.result = result
            continuation?.resume()
            return true
        }
        return false
    }
}



---
File: /Sources/SignalRClient/TimeScheduler.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

actor TimeScheduler {
    private let queue = DispatchQueue(label: "com.schduler.timer")
    private var timer: DispatchSourceTimer?
    private var interval: TimeInterval
    
    init(initialInterval: TimeInterval) {
        self.interval = initialInterval
    }
    
    func start(sendAction: @escaping () async -> Void) {
        stop()
        timer = DispatchSource.makeTimerSource(queue: queue)
        guard let timer = timer else { return }
        
        timer.schedule(deadline: .now() + interval, repeating: .infinity) // trigger only once here
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }

            Task {
                await sendAction()
                await self.refreshSchduler()
            }
        }
        timer.resume()
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
    }
    
    func updateInterval(to newInterval: TimeInterval) {
        interval = newInterval
        refreshSchduler()
    }
    
    func refreshSchduler() {
        guard let timer = timer else { return }
        timer.schedule(deadline: .now() + interval, repeating: .infinity)
    }
}


---
File: /Sources/SignalRClient/TransferFormat.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

/// Specifies a specific HTTP transport type.
public struct HttpTransportType: OptionSet {
    public let rawValue: Int

    public static let none = HttpTransportType([])
    public static let webSockets = HttpTransportType(rawValue: 1 << 0)
    public static let serverSentEvents = HttpTransportType(rawValue: 1 << 1)
    public static let longPolling = HttpTransportType(rawValue: 1 << 2)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static func from(_ transportString: String) -> HttpTransportType? {
        switch transportString.lowercased() {
        case "websockets":
            return .webSockets
        case "serversentevents":
            return .serverSentEvents
        case "longpolling":
            return .longPolling
        default:
            return nil
        }
    }
}

/// Specifies the transfer format for a connection.
public enum TransferFormat: Int, Codable, Sendable {
    /// Specifies that only text data will be transmitted over the connection.
    case text = 1
    /// Specifies that binary data will be transmitted over the connection.
    case binary = 2

    init?(_ transferFormatString: String) {
        switch transferFormatString.lowercased() {
        case "text":
            self = .text
        case "binary":
            self = .binary
        default:
            return nil
        }
    }
}



---
File: /Sources/SignalRClient/Utils.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation

class Utils {
    static func getUserAgent() -> String {
        return
            "Microsoft SignalR Client/Swift \(PackageVersion); \(currentOSVersion())"
    }

    static func currentOSVersion() -> String {
        #if os(macOS)
            let osName = "macOS"
        #elseif os(iOS)
            #if targetEnvironment(macCatalyst)
                let osName = "Mac Catalyst"
            #else
                let osName = "iOS"
            #endif
        #elseif os(tvOS)
            let osName = "tvOS"
        #elseif os(watchOS)
            let osName = "watchOS"
        #elseif os(Windows)
            return "Windows"
        #elseif os(Linux)
            return "Linux"
        #else
            return "Unknown OS"
        #endif

        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            let version = ProcessInfo.processInfo.operatingSystemVersion
            let versionString =
                "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
            return "\(osName) \(versionString)"
        #endif
    }
}

extension HttpRequest {
    init(
        method: HttpMethod, url: String, content: StringOrData? = nil,
        responseType: TransferFormat? = nil,
        headers: [String: String]? = nil, timeout: TimeInterval? = nil,
        options: HttpConnectionOptions, includeUserAgent: Bool = true
    ) {
        self.init(
            method: method, url: url, content: content,
            responseType: responseType, headers: headers,
            timeout: timeout
        )
        if includeUserAgent {
            self.headers["User-Agent"] = Utils.getUserAgent()
        }
        if let headers = options.headers {
            self.headers = self.headers.merging(headers) { (_, new) in new }
        }
        if let timeout = options.timeout {
            self.timeout = timeout
        }
    }
}

extension Data {
    func convertToStringOrData(transferFormat: TransferFormat) throws
    -> StringOrData {
        switch transferFormat {
        case .text:
            guard
                let message = String(
                    data: self, encoding: .utf8
                )
            else {
                throw SignalRError.invalidTextMessageEncoding
            }
            return .string(message)
        case .binary:
            return .data(self)
        }
    }
}

extension StringOrData {
    func getDataDetail(includeContent: Bool) -> String {
        switch self {
        case .string(let str):
            return
                "String data of length \(str.count)\(includeContent ? ". Content: \(str)" : "")"
        case .data(let data):
            // TODO: data format?
            return
                "Binary data of length \(data.count)\(includeContent ? ". Content: \(data)" : "")"
        }
    }

    func isEmpty() -> Bool {
        switch self {
        case .string(let str):
            return str.count == 0
        case .data(let data):
            return data.isEmpty
        }
    }

    func convertToString() -> String? {
        switch self {
        case .string(let str):
            return str
        case .data(let data):
            return String(data: data, encoding: .utf8)
        }
    }

    func converToData() -> Data {
        switch self {
        case .string(let str):
            return str.data(using: .utf8)!
        case .data(let data):
            return data
        }
    }
}



---
File: /Sources/SignalRClient/Version.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

let PackageVersion = "1.0.0-preview.4"



---
File: /Tests/SignalRClientIntegrationTests/IntegrationTests.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.


import XCTest
@testable import SignalRClient

class IntegrationTests: XCTestCase {
    private var url: String?
    private let logLevel: LogLevel = .debug
    #if os(Linux)
        private let testCombinations: [(transport: HttpTransportType, hubProtocol: HubProtocolType)] = [
            (.longPolling, .messagePack),
            (.longPolling, .json),
        ]
    #else
        private let testCombinations: [(transport: HttpTransportType, hubProtocol: HubProtocolType)] = [
            (.webSockets, .json),
            (.serverSentEvents, .json),
            (.longPolling, .json),
            (.webSockets, .messagePack),
            (.longPolling, .messagePack),
        ]
    #endif

    override func setUpWithError() throws {
        guard let url = ProcessInfo.processInfo.environment["SIGNALR_INTEGRATION_TEST_URL"] else {
            throw XCTSkip("Skipping integration tests because SIGNALR_INTEGRATION_TEST_URL is not set.")
        }
        self.url = url
    }

    func testConnect() async throws {
        for (transport, hubProtocol) in testCombinations {
            do {
                try await whenTaskTimeout({ try await self.testConnectCore(transport: transport, hubProtocol: hubProtocol) }, timeout: 1)
            } catch {
                XCTFail("Failed to connect with transport: \(transport) and hubProtocol: \(hubProtocol)")
            }
        }
    }

    private func testConnectCore(transport: HttpTransportType, hubProtocol: HubProtocolType) async throws {
        print("testConnectCore with transport: \(transport) and hubProtocol: \(hubProtocol)")
        let connection = HubConnectionBuilder()
            .withUrl(url: url!, transport: transport)
            .withHubProtocol(hubProtocol: hubProtocol)
            .withLogLevel(logLevel: logLevel)
            .build()

        try await run() {
            try await connection.start()
        } defer: {
            await connection.stop()
        }
    }

    func testMultipleConnectection() async throws {
        for (transport, hubProtocol) in testCombinations {
            let count = 10 // DefaultUrlSession has 5 connections
            var connections: [HubConnection] = []
            do {
                for _ in 0 ..< count {
                    let connection = HubConnectionBuilder()
                        .withUrl(url: url!, transport: transport)
                        .withHubProtocol(hubProtocol: hubProtocol)
                        .withLogLevel(logLevel: logLevel)
                        .build()
                    try await whenTaskTimeout(connection.start, timeout: 1)
                    connections.append(connection)
                }
            } catch {
                XCTFail("Failed to establish multible connection with transport: \(transport) and hubProtocol: \(hubProtocol)")
            }
            for connection in connections {
                await connection.stop()
            }
        }
    }

    func testSendAndOn() async throws {
        for (transport, hubProtocol) in testCombinations {
            try await whenTaskTimeout({ try await self.testSendAndOnCore(transport: transport, hubProtocol: hubProtocol, item: "hello") }, timeout: 1)
            try await whenTaskTimeout({ try await self.testSendAndOnCore(transport: transport, hubProtocol: hubProtocol, item: 1) }, timeout: 1)
            try await whenTaskTimeout({ try await self.testSendAndOnCore(transport: transport, hubProtocol: hubProtocol, item: 1.2) }, timeout: 1)
            try await whenTaskTimeout({ try await self.testSendAndOnCore(transport: transport, hubProtocol: hubProtocol, item: true) }, timeout: 1)
            try await whenTaskTimeout({ try await self.testSendAndOnCore(transport: transport, hubProtocol: hubProtocol, item: [1, 2, 3]) }, timeout: 1)
            try await whenTaskTimeout({ try await self.testSendAndOnCore(transport: transport, hubProtocol: hubProtocol, item: ["key": "value"]) }, timeout: 1)
            try await whenTaskTimeout({ try await self.testSendAndOnCore(transport: transport, hubProtocol: hubProtocol, item: CustomClass(str: "Hello, World!", arr: [1, 2, 3])) }, timeout: 1)
        }
    }

    func testSendAndOnCore<T: Equatable>(transport: HttpTransportType, hubProtocol: HubProtocolType, item: T) async throws {
        let connection = HubConnectionBuilder()
            .withUrl(url: url!, transport: transport)
            .withHubProtocol(hubProtocol: hubProtocol)
            .withLogLevel(logLevel: logLevel)
            .build()

        let expectation = expectation(description: "Message received")
        let message1 = "Hello, World!"

        await connection.on("EchoBack") { (arg1: String, arg2: T) in
            XCTAssertEqual(arg1, message1)
            XCTAssertEqual(arg2, item)
            expectation.fulfill()
        }

        try await connection.start()
        try await run() {
            do {
                try await connection.send(method: "Echo", arguments: message1, item)
            } catch {
                XCTFail("Failed to send and receive messages with transport: \(transport) and hubProtocol: \(hubProtocol)")
            }

            await fulfillment(of: [expectation], timeout: 1)
        } defer: {
            await connection.stop()
        }
    }

    func testInvoke() async throws {
        for (transport, hubProtocol) in testCombinations {
            try await whenTaskTimeout({ try await self.testInvokeCore(transport: transport, hubProtocol: hubProtocol, item: "hello") }, timeout: 1)
            try await whenTaskTimeout({ try await self.testInvokeCore(transport: transport, hubProtocol: hubProtocol, item: 1) }, timeout: 1)
            try await whenTaskTimeout({ try await self.testInvokeCore(transport: transport, hubProtocol: hubProtocol, item: 1.2) }, timeout: 1)
            try await whenTaskTimeout({ try await self.testInvokeCore(transport: transport, hubProtocol: hubProtocol, item: true) }, timeout: 1)
            try await whenTaskTimeout({ try await self.testInvokeCore(transport: transport, hubProtocol: hubProtocol, item: [1, 2, 3]) }, timeout: 1)
            try await whenTaskTimeout({ try await self.testInvokeCore(transport: transport, hubProtocol: hubProtocol, item: ["key": "value"]) }, timeout: 1)
            try await whenTaskTimeout({ try await self.testInvokeCore(transport: transport, hubProtocol: hubProtocol, item: CustomClass(str: "Hello, World!", arr: [1, 2, 3])) }, timeout: 1)
        }
    }

    private func testInvokeCore<T: Equatable>(transport: HttpTransportType, hubProtocol: HubProtocolType, item: T) async throws {
        let connection = HubConnectionBuilder()
            .withUrl(url: url!, transport: transport)
            .withHubProtocol(hubProtocol: hubProtocol)
            .withLogLevel(logLevel: logLevel)
            .build()

        try await connection.start()

        try await run() {
            let message1 = "Hello, World!"
            let result: T = try await connection.invoke(method: "Invoke", arguments: message1, item)
            XCTAssertEqual(result, item)
        } defer: {
            await connection.stop()
        }
    }

    func testInvokeWithoutReturn() async throws {
        for (transport, hubProtocol) in testCombinations {
            try await whenTaskTimeout({ try await self.testInvokeWithoutReturnCore(transport: transport, hubProtocol: hubProtocol) }, timeout: 1)
        }
    }

    private func testInvokeWithoutReturnCore(transport: HttpTransportType, hubProtocol: HubProtocolType) async throws {
        let connection = HubConnectionBuilder()
            .withUrl(url: url!, transport: transport)
            .withHubProtocol(hubProtocol: hubProtocol)
            .withLogLevel(logLevel: logLevel)
            .build()

        try await connection.start()

        try await run() {
            let message1 = "Hello, World!"
            try await connection.invoke(method: "InvokeWithoutReturn", arguments: message1)
        } defer: {
            await connection.stop()
        }
    }

    func testStream() async throws {
        for (transport, hubProtocol) in testCombinations {
            try await whenTaskTimeout({ try await self.testStreamCore(transport: transport, hubProtocol: hubProtocol) }, timeout: 1)
        }
    }

    private func testStreamCore(transport: HttpTransportType, hubProtocol: HubProtocolType) async throws {
        let connection = HubConnectionBuilder()
            .withUrl(url: url!, transport: transport)
            .withHubProtocol(hubProtocol: hubProtocol)
            .withLogLevel(logLevel: logLevel)
            .build()

        try await connection.start()

        try await run() {
            let messages: [String] = ["a", "b", "c"]
            let stream: any StreamResult<String> = try await connection.stream(method: "Stream")
            var i = 0
            for try await item in stream.stream {
                XCTAssertEqual(item, messages[i])
                i = i + 1
            }
        } defer: {
            await connection.stop()
        }
    }

    func testClientResult() async throws {
        for (transport, hubProtocol) in testCombinations {
            try await whenTaskTimeout({ try await self.testClientResultCore(transport: transport, hubProtocol: hubProtocol) }, timeout: 1)
        }
    }
    
    func testClientToServerStream() async throws {
        for (transport, hubProtocol) in testCombinations {
            try await whenTaskTimeout({ try await self.testClientToServerStreamCore(transport: transport, hubProtocol: hubProtocol) }, timeout: 5)
        }
    }

    private func testClientToServerStreamCore(transport: HttpTransportType, hubProtocol: HubProtocolType) async throws {
        let connection = HubConnectionBuilder()
            .withUrl(url: url!, transport: transport)
            .withHubProtocol(hubProtocol: hubProtocol)
            .withLogLevel(logLevel: logLevel)
            .build()

        try await connection.start()
        
        func createClientStream() -> AsyncStream<Int> {
            let (stream, continuation) = AsyncStream.makeStream(of: Int.self)
            Task {
                for value in 0 ... 5 {
                    try? await Task.sleep(nanoseconds: 10_000_000)
                    continuation.yield(value)
                }
                continuation.finish()
            }
            return stream
        }

        try await run(){
            try await connection.send(method: "AddNumbers", arguments: 10, createClientStream())
            try await connection.invoke(method: "AddNumbers", arguments: 10, createClientStream())
            let result: Int = try await connection.invoke(method: "AddNumbers", arguments: 10, createClientStream())
            XCTAssertEqual(result, 25)
            let streamResult: any StreamResult<Int> = try await connection.stream(method: "Count", arguments: 10, createClientStream())
            var counterTarget = 10
            for try await counter in streamResult.stream {
                counterTarget += 1
                XCTAssertEqual(counter, counterTarget)
            }
        } defer: {
            await connection.stop()
        }
    }
     
    private func testClientResultCore(transport: HttpTransportType, hubProtocol: HubProtocolType) async throws {
        let connection = HubConnectionBuilder()
            .withUrl(url: url!, transport: transport)
            .withHubProtocol(hubProtocol: hubProtocol)
            .withLogLevel(logLevel: logLevel)
            .build()

        try await connection.start()

        try await run() {
            let expectMessage = "Hello, World!"
            let expectation = XCTestExpectation(description: "ClientResult received")
            await connection.on("EchoBack") { (message: String) in
                XCTAssertEqual(expectMessage, message)
                expectation.fulfill()
            }
            await connection.on("ClientResult") { (message: String) in
                XCTAssertEqual(expectMessage, message)
                return expectMessage
            }
            try await connection.invoke(method: "InvokeWithClientResult", arguments: expectMessage)
            await fulfillment(of: [expectation], timeout: 1.0)
        } defer: {
            await connection.stop()
        }
    }

    func testClientResultWithNull() async throws {
        for (transport, hubProtocol) in testCombinations {
            try await whenTaskTimeout({ try await self.testClientResultWithNullCore(transport: transport, hubProtocol: hubProtocol) }, timeout: 1)
        }
    }

    private func testClientResultWithNullCore(transport: HttpTransportType, hubProtocol: HubProtocolType) async throws {
        let connection = HubConnectionBuilder()
            .withUrl(url: url!, transport: transport)
            .withHubProtocol(hubProtocol: hubProtocol)
            .withLogLevel(logLevel: logLevel)
            .build()

        try await connection.start()

        try await run() {
            let expectMessage = "Hello, World!"
            let expectation = XCTestExpectation(description: "ClientResult received")
            await connection.on("EchoBack") { (message: String) in
                XCTAssertEqual("received", message)
                expectation.fulfill()
            }
            await connection.on("ClientResult") { (message: String) in
                XCTAssertEqual(expectMessage, message)
                return
            }

            try await connection.invoke(method: "invokeWithEmptyClientResult", arguments: expectMessage)
            await fulfillment(of: [expectation], timeout: 1.0)
        } defer: {
            await connection.stop()
        }
    }

    class CustomClass: Codable, Equatable {
        static func == (lhs: IntegrationTests.CustomClass, rhs: IntegrationTests.CustomClass) -> Bool {
            return lhs.str == rhs.str && lhs.arr == rhs.arr
        }

        var str: String
        var arr: [Int]

        init(str: String, arr: [Int]) {
            self.str = str
            self.arr = arr
        }
    }

    func whenTaskTimeout(_ task: @escaping () async throws -> Void, timeout: TimeInterval) async throws -> Void {
        let expectation = XCTestExpectation(description: "Task should finish")
        let wrappedTask = Task {
            try await task()
            expectation.fulfill()
        }
        defer { wrappedTask.cancel() }

        await fulfillment(of: [expectation], timeout: timeout)
    }

    func run<T>(_ operation: () async throws -> T,
                defer deferredOperation: () async throws -> Void,
                line: UInt = #line) async throws -> T {
        do {
            let result = try await operation()
            try await deferredOperation()
            return result
        } catch {
            try await deferredOperation()
            XCTFail(String(describing: error), file: #file, line: line)
            throw error
        }
    }
}



---
File: /Tests/SignalRClientTests/Msgpack/MsgpackDecoderTests.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import XCTest

@testable import SignalRClient

class MsgpackDecoderTests: XCTestCase {
    // MARK: Convert Data to MsgpackElement
    func testParseUInt() throws {
        let data: [UInt64] = [
            0, 0x7f, 0x80, 0xff, 0x100, 0xffff, 0x10000, 0xffff_ffff,
            0x1_0000_0000,
        ]
        for i in data {
            let msgpackElement = MsgpackElement.uint(i)
            let binary = try msgpackElement.marshall()
            let (decodeddType, remaining) = try MsgpackElement.parse(data: binary)
            XCTAssertEqual(remaining.count, 0)
            XCTAssertEqual(decodeddType, msgpackElement)
        }
    }

    func testParseNegativeInt() throws {
        let data: [Int64] = [
            -0x20, -0x21, -0x80, -0x81, -0x8000, -0x8000, -0x10000, -0x8000,
        ]
        for i in data {
            let msgpackElement = MsgpackElement.int(i)
            let binary = try msgpackElement.marshall()
            let (decodeddType, remaining) = try MsgpackElement.parse(data: binary)
            XCTAssertEqual(remaining.count, 0)
            XCTAssertEqual(decodeddType, msgpackElement)
        }
    }

    func testParseIntNotNegative() throws {
        var data: [Int64: Data] = [:]
        data[0] = Data([0xd0, 0x00])
        data[1 << 7 - 1] = Data([0xd0, 0x7f])
        data[1 << 7] = Data([0xd1, 0x00, 0x80])
        data[1 << 15 - 1] = Data([0xd1, 0x7f, 0xff])
        data[1 << 15] = Data([0xd2, 0x00, 0x00, 0x80, 0x00])
        data[1 << 31 - 1] = Data([0xd2, 0x7f, 0xff, 0xff, 0xff])
        data[1 << 31] = Data([
            0xd3, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00,
        ])
        for (k, v) in data {
            let (decodeddType, remaining) = try MsgpackElement.parse(data: v)
            XCTAssertEqual(remaining.count, 0)
            let msgpackElement = MsgpackElement.int(k)
            XCTAssertEqual(decodeddType, msgpackElement)
        }
    }

    func testParseFloat32() throws {
        let data: [Float32] = [0.0, 1.1 - 0.9]
        for i in data {
            let msgpackElement = MsgpackElement.float32(i)
            let binary = try msgpackElement.marshall()
            let (decodeddType, remaining) = try MsgpackElement.parse(data: binary)
            XCTAssertEqual(remaining.count, 0)
            XCTAssertEqual(decodeddType, msgpackElement)
        }
    }

    func testParseFloat64() throws {
        let data: [Float64] = [0.0, 1.1 - 0.9]
        for i in data {
            let msgpackElement = MsgpackElement.float64(i)
            let binary = try msgpackElement.marshall()
            let (decodeddType, remaining) = try MsgpackElement.parse(data: binary)
            XCTAssertEqual(remaining.count, 0)
            XCTAssertEqual(decodeddType, msgpackElement)
        }
    }

    func testParseString() throws {
        let data: [Int] = [
            0, 1 << 5 - 1, 1 << 5, 1 << 8 - 1, 1 << 8, 1 << 16 - 1, 1 << 16,
        ]
        for length in data {
            let msgpackElement = MsgpackElement.string(
                String(repeating: Character("a"), count: length))
            let binary = try msgpackElement.marshall()
            let (decodedType, remaining) = try MsgpackElement.parse(data: binary)
            XCTAssertEqual(remaining.count, 0)
            XCTAssertEqual(decodedType, msgpackElement)
        }
    }

    func testParseNil() throws {
        let msgpackElement = MsgpackElement.null
        let binary = try msgpackElement.marshall()
        let (decodedType, remaining) = try MsgpackElement.parse(data: binary)
        XCTAssertEqual(remaining.count, 0)
        XCTAssertEqual(decodedType, msgpackElement)
    }

    func testParseBool() throws {
        let data: [Bool] = [true, false]
        for b in data {
            let msgpackElement = MsgpackElement.bool(b)
            let binary = try msgpackElement.marshall()
            let (decodedType, remaining) = try MsgpackElement.parse(data: binary)
            XCTAssertEqual(remaining.count, 0)
            XCTAssertEqual(decodedType, msgpackElement)
        }
    }

    func testParseData() throws {
        let data = [0, 1 << 8 - 1, 1 << 8, 1 << 16 - 1, 1 << 16]
        for length in data {
            let msgpackElement = MsgpackElement.bin(
                Data(repeating: UInt8(2), count: length))
            let binary = try msgpackElement.marshall()
            let (decodedType, remaining) = try MsgpackElement.parse(data: binary)
            XCTAssertEqual(remaining.count, 0)
            XCTAssertEqual(decodedType, msgpackElement)
        }
    }

    func testParseMap() throws {
        let data = [0, 1 << 4 - 1, 1 << 4, 1 << 16 - 1, 1 << 16]
        for i in data {
            var map: [String: MsgpackElement] = [:]
            for i in 0 ..< i {
                map[String(i)] = MsgpackElement.bool(true)
            }
            let msgpackElement = MsgpackElement.map(map)
            let content = try msgpackElement.marshall()
            let (decoded, remaining) = try MsgpackElement.parse(data: content)
            XCTAssertEqual(remaining.count, 0)
            XCTAssertEqual(decoded, msgpackElement)
        }
    }

    func testParseArray() throws {
        let data = [0, 1 << 4 - 1, 1 << 4, 1 << 16 - 1, 1 << 16]
        for i in data {
            var array: [MsgpackElement] = []
            array.reserveCapacity(i)
            for _ in 0 ..< i {
                array.append(MsgpackElement.bool(true))
            }
            let msgpackElement = MsgpackElement.array(array)
            let content = try msgpackElement.marshall()
            let (decoded, remaining) = try MsgpackElement.parse(data: content)
            XCTAssertEqual(remaining.count, 0)
            XCTAssertEqual(decoded, msgpackElement)
        }
    }

    func testDecodeExt() throws {
        let data: [Int] = [
            1, 2, 4, 8, 16, 0, 1 << 8 - 1, 1 << 8, 1 << 16 - 1, 1 << 16,
            Int(Int32.max),
        ]
        for len in data {
            let extData = Data(repeating: 1, count: len)
            let msgpackElement = MsgpackElement.ext(-1, extData)
            let content = try msgpackElement.marshall()
            let (decoded, remaining) = try MsgpackElement.parse(data: content)
            XCTAssertEqual(remaining.count, 0)
            XCTAssertEqual(decoded, msgpackElement)
        }
    }

    // MARK: Convert MsgpackElement to basic Swift types
    func testDecodeUInt8() throws {
        XCTAssertEqual(
            try MsgpackElement.int(Int64(UInt8.min)).decode(type: UInt8.self),
            UInt8.min
        )
        XCTAssertEqual(
            try MsgpackElement.int(Int64(UInt8.max)).decode(type: UInt8.self),
            UInt8.max
        )
        XCTAssertThrowsError(
            try MsgpackElement.int(Int64(UInt8.max) + 1).decode(type: UInt8.self))
        XCTAssertThrowsError(
            try MsgpackElement.int(Int64(-1)).decode(type: UInt8.self))

        XCTAssertEqual(
            try MsgpackElement.uint(UInt64(UInt8.min)).decode(type: UInt8.self),
            UInt8.min
        )
        XCTAssertEqual(
            try MsgpackElement.uint(UInt64(UInt8.max)).decode(type: UInt8.self),
            UInt8.max
        )
        XCTAssertThrowsError(
            try MsgpackElement.uint(UInt64(UInt8.max) + 1).decode(type: UInt8.self)
        )
    }

    func testDecodeUInt16() throws {
        XCTAssertEqual(
            try MsgpackElement.int(Int64(UInt16.min)).decode(type: UInt16.self),
            UInt16.min
        )
        XCTAssertEqual(
            try MsgpackElement.int(Int64(UInt16.max)).decode(type: UInt16.self),
            UInt16.max
        )
        XCTAssertThrowsError(
            try MsgpackElement.int(Int64(UInt16.max) + 1).decode(type: UInt16.self)
        )
        XCTAssertThrowsError(
            try MsgpackElement.int(Int64(-1)).decode(type: UInt16.self))

        XCTAssertEqual(
            try MsgpackElement.uint(UInt64(UInt16.min)).decode(type: UInt16.self),
            UInt16.min
        )
        XCTAssertEqual(
            try MsgpackElement.uint(UInt64(UInt16.max)).decode(type: UInt16.self),
            UInt16.max
        )
        XCTAssertThrowsError(
            try MsgpackElement.uint(UInt64(UInt16.max) + 1).decode(
                type: UInt16.self))
    }

    func testDecodeUInt32() throws {
        XCTAssertEqual(
            try MsgpackElement.int(Int64(UInt32.min)).decode(type: UInt32.self),
            UInt32.min
        )
        XCTAssertEqual(
            try MsgpackElement.int(Int64(UInt32.max)).decode(type: UInt32.self),
            UInt32.max
        )
        XCTAssertThrowsError(
            try MsgpackElement.int(Int64(UInt32.max) + 1).decode(type: UInt32.self)
        )
        XCTAssertThrowsError(
            try MsgpackElement.int(Int64(-1)).decode(type: UInt32.self))

        XCTAssertEqual(
            try MsgpackElement.uint(UInt64(UInt32.min)).decode(type: UInt32.self),
            UInt32.min
        )
        XCTAssertEqual(
            try MsgpackElement.uint(UInt64(UInt32.max)).decode(type: UInt32.self),
            UInt32.max
        )
        XCTAssertThrowsError(
            try MsgpackElement.uint(UInt64(UInt32.max) + 1).decode(
                type: UInt32.self))
    }

    func testDecodeUInt64() throws {
        XCTAssertEqual(
            try MsgpackElement.int(Int64(UInt64.min)).decode(type: UInt64.self),
            UInt64.min
        )
        XCTAssertEqual(
            try MsgpackElement.int(Int64(Int64.max)).decode(type: UInt64.self),
            UInt64(Int64.max)
        )
        XCTAssertThrowsError(
            try MsgpackElement.int(Int64(-1)).decode(type: UInt64.self))

        XCTAssertEqual(
            try MsgpackElement.uint(UInt64(UInt64.min)).decode(type: UInt64.self),
            UInt64.min
        )
        XCTAssertEqual(
            try MsgpackElement.uint(UInt64(UInt64.max)).decode(type: UInt64.self),
            UInt64.max
        )
    }

    func testDecodeInt8() throws {
        XCTAssertEqual(
            try MsgpackElement.int(Int64(Int8.min)).decode(type: Int8.self),
            Int8.min
        )
        XCTAssertEqual(
            try MsgpackElement.int(Int64(Int8.max)).decode(type: Int8.self),
            Int8.max
        )
        XCTAssertThrowsError(
            try MsgpackElement.int(Int64(Int8.max) + 1).decode(type: Int8.self))
        XCTAssertThrowsError(
            try MsgpackElement.int(Int64(Int8.min) - 1).decode(type: Int8.self))

        XCTAssertEqual(
            try MsgpackElement.uint(UInt64(Int8.max)).decode(type: Int8.self),
            Int8.max
        )
        XCTAssertEqual(
            try MsgpackElement.uint(UInt64(0)).decode(type: Int8.self), 0
        )
        XCTAssertThrowsError(
            try MsgpackElement.uint(UInt64(Int8.max) + 1).decode(type: Int8.self))
    }

    func testDecodeInt16() throws {
        XCTAssertEqual(
            try MsgpackElement.int(Int64(Int16.min)).decode(type: Int16.self),
            Int16.min
        )
        XCTAssertEqual(
            try MsgpackElement.int(Int64(Int16.max)).decode(type: Int16.self),
            Int16.max
        )
        XCTAssertThrowsError(
            try MsgpackElement.int(Int64(Int16.max) + 1).decode(type: Int16.self))
        XCTAssertThrowsError(
            try MsgpackElement.int(Int64(Int16.min) - 1).decode(type: Int16.self))

        XCTAssertEqual(
            try MsgpackElement.uint(UInt64(0)).decode(type: Int16.self), 0
        )
        XCTAssertEqual(
            try MsgpackElement.uint(UInt64(Int16.max)).decode(type: Int16.self),
            Int16.max
        )
        XCTAssertThrowsError(
            try MsgpackElement.uint(UInt64(Int16.max) + 1).decode(type: Int16.self)
        )
    }

    func testDecodeInt32() throws {
        XCTAssertEqual(
            try MsgpackElement.int(Int64(Int32.min)).decode(type: Int32.self),
            Int32.min
        )
        XCTAssertEqual(
            try MsgpackElement.int(Int64(Int32.max)).decode(type: Int32.self),
            Int32.max
        )
        XCTAssertThrowsError(
            try MsgpackElement.int(Int64(Int32.max) + 1).decode(type: Int32.self))
        XCTAssertThrowsError(
            try MsgpackElement.int(Int64(Int32.min) - 1).decode(type: Int32.self))

        XCTAssertEqual(
            try MsgpackElement.uint(UInt64(0)).decode(type: Int32.self), 0
        )
        XCTAssertEqual(
            try MsgpackElement.uint(UInt64(Int32.max)).decode(type: Int32.self),
            Int32.max
        )
        XCTAssertThrowsError(
            try MsgpackElement.uint(UInt64(Int32.max) + 1).decode(type: Int32.self)
        )
    }

    func testDecodeInt64() throws {
        XCTAssertEqual(
            try MsgpackElement.int(Int64(Int64.min)).decode(type: Int64.self),
            Int64.min
        )
        XCTAssertEqual(
            try MsgpackElement.int(Int64(Int64.max)).decode(type: Int64.self),
            Int64.max
        )

        XCTAssertEqual(
            try MsgpackElement.uint(UInt64(0)).decode(type: Int64.self), 0
        )
        XCTAssertEqual(
            try MsgpackElement.uint(UInt64(Int64.max)).decode(type: Int64.self),
            Int64.max
        )
        XCTAssertThrowsError(
            try MsgpackElement.uint(UInt64(Int64.max) + 1).decode(type: Int64.self)
        )
    }

    func testDecodeBool() throws {
        XCTAssertEqual(try MsgpackElement.bool(true).decode(type: Bool.self), true)
        XCTAssertEqual(
            try MsgpackElement.bool(false).decode(type: Bool.self), false
        )
        XCTAssertThrowsError(
            try MsgpackElement.uint(UInt64(Int64.max)).decode(type: Bool.self))
    }

    func testDecodeString() throws {
        XCTAssertEqual(
            try MsgpackElement.string("abc").decode(type: String.self), "abc"
        )
        XCTAssertEqual(try MsgpackElement.string("").decode(type: String.self), "")
        XCTAssertThrowsError(
            try MsgpackElement.uint(UInt64(Int64.max)).decode(type: String.self))
    }

    func testDecodeData() throws {
        XCTAssertEqual(
            try MsgpackElement.bin(Data([0x81])).decode(type: Data.self),
            Data([0x81])
        )
        XCTAssertEqual(
            try MsgpackElement.bin(Data()).decode(type: Data.self), Data()
        )
        XCTAssertThrowsError(
            try MsgpackElement.uint(UInt64(Int64.max)).decode(type: Data.self))
    }

    func testDecodeFloat16() throws {
        let decoder = MsgpackDecoder()
        var msgpackElement = MsgpackElement.float32(Float32(1.0))
        try decoder.loadMsgpackElement(from: msgpackElement)
        var float16 = try Float16.init(from: decoder)
        XCTAssertEqual(float16, Float16(1.0))
        msgpackElement = MsgpackElement.float64(Float64(1.0))
        try decoder.loadMsgpackElement(from: msgpackElement)
        float16 = try Float16.init(from: decoder)
        XCTAssertEqual(float16, Float16(1.0))

        msgpackElement = MsgpackElement.uint(UInt64(Int64.max))
        try decoder.loadMsgpackElement(from: msgpackElement)
        XCTAssertThrowsError(try Float16.init(from: decoder))
    }

    func testDecodeFloat32() throws {
        XCTAssertEqual(
            try MsgpackElement.float32(Float32(1.0)).decode(type: Float32.self),
            Float32(1.0)
        )
        XCTAssertEqual(
            try MsgpackElement.float64(Float64(1.0)).decode(type: Float32.self),
            Float32(1.0)
        )
        XCTAssertEqual(
            try MsgpackElement.float64(Float64(1.1)).decode(type: Float32.self),
            Float32(1.1)
        )
        XCTAssertThrowsError(
            try MsgpackElement.uint(UInt64(Int64.max)).decode(type: Float32.self))
    }

    func testDecodeFloat64() throws {
        XCTAssertEqual(
            try MsgpackElement.float32(Float32(1.0)).decode(type: Float64.self),
            Float64(1.0)
        )
        // Lose precision. But it should not throw
        XCTAssertNotEqual(
            try MsgpackElement.float32(Float32(1.1)).decode(type: Float64.self),
            Float64(1.1)
        )

        XCTAssertEqual(
            try MsgpackElement.float64(Float64(1.0)).decode(type: Float64.self),
            Float64(1.0)
        )
        XCTAssertThrowsError(
            try MsgpackElement.uint(UInt64(Int64.max)).decode(type: Float64.self))
    }

    // MARK: MsgpackDecoder
    private struct Example1: Codable, Equatable {
        var int: Int
        var intNil: Int?
        var bool: Bool
        var boolNil: Bool?
        var string: String
        var data: Data
        var float32: Float32
        var float64: Float64
        var map1: [String: String]
        var map2: [String: Bool]
        var map3: [String: [String: Bool]]
        var array1: [Int?]
        var array2: [[Int?]]
        var date: Date
        init() {
            self.int = 2
            self.boolNil = true
            self.bool = true
            self.string = "123"
            self.data = Data([0x90])
            self.float32 = 1.1
            self.float64 = 1.1
            self.map1 = [:]
            self.map2 = ["a": true]
            self.map3 = ["b": map2]
            self.array1 = [1, 2, nil, 4]
            self.array2 = [self.array1]
            self.date = Date(timeIntervalSince1970: 100.1)
        }
    }

    func testDecode1() throws {
        let encoder = MsgpackEncoder()
        let example = Example1()
        let encodedData = try encoder.encode(example)
        let msgpackElement = try encoder.convertToMsgpackElement()

        let decoder = MsgpackDecoder()
        try decoder.loadMsgpackElement(from: msgpackElement)
        let decodedExample1 = try Example1.init(from: decoder)

        XCTAssertEqual(example, decodedExample1)

        let decodedExample2 = try decoder.decode(
            Example1.self, from: encodedData
        )
        XCTAssertEqual(example, decodedExample2)
    }

    private struct Example2: Decodable {
        var Key1: Int
        var Key2: [String: String]
        var Key3: [Data]
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: Keys.self)
            self.Key1 = try container.decode(Int.self, forKey: Keys.Key1)
            self.Key2 = try container.decode(
                [String: String].self, forKey: .Key2
            )
            self.Key3 = try container.decode([Data].self, forKey: .Key3)
        }

        enum Keys: CodingKey {
            case Key1
            case Key2
            case Key3

            case nestedKey1
        }
    }

    func testDecode2() throws {
        var map: [String: MsgpackElement] = [:]
        map["Key1"] = MsgpackElement.int(Int64(123))
        var nestedMap: [String: MsgpackElement] = [:]
        nestedMap["nestedKey"] = MsgpackElement.string("abc")
        map["Key2"] = MsgpackElement.map(nestedMap)
        let array: [MsgpackElement] = [MsgpackElement.bin(Data([0xab]))]
        map["Key3"] = MsgpackElement.array(array)
        map["Key4"] = MsgpackElement.null

        let msgpackElement = MsgpackElement.map(map)
        let decoder = MsgpackDecoder()
        try decoder.loadMsgpackElement(from: msgpackElement)
        let decodedExample = try Example2.init(from: decoder)
        XCTAssertEqual(decodedExample.Key1, 123)
        let expectedMap: [String: String] = ["nestedKey": "abc"]
        XCTAssertEqual(decodedExample.Key2, expectedMap)
        XCTAssertEqual(decodedExample.Key3, [Data([0xab])])
    }

    private class BaseClassExample: Codable {
        var parent: String = "123"
    }

    private class InherienceWithSameContainerExample: BaseClassExample {
        var child: String = "456"

        override init() {
            super.init()
        }

        override func encode(to encoder: any Encoder) throws {
            try super.encode(to: encoder)
            // Switching to a KeyedContainer with different key type
            var container = encoder.container(keyedBy: Keys.self)
            try container.encode(child, forKey: .child)
        }

        required init(from decoder: any Decoder) throws {
            try super.init(from: decoder)
            let container = try decoder.container(keyedBy: Keys.self)
            self.child = try container.decode(String.self, forKey: .child)
        }

        enum Keys: CodingKey {
            case child
        }
    }

    func testInherienceUsingSameTopContainer() throws { // Undocumented behavior. Keep aligh with the jsonEncoder
        let encoder = MsgpackEncoder()
        let example = InherienceWithSameContainerExample()
        example.parent = "abc"
        example.child = "def"
        let data = try encoder.encode(example)
        let msgpackElement = try encoder.convertToMsgpackElement()
        let decoder = MsgpackDecoder()
        try decoder.loadMsgpackElement(from: msgpackElement)
        let decodedExample = try InherienceWithSameContainerExample.init(
            from: decoder)
        XCTAssertEqual(decodedExample.parent, "abc")
        XCTAssertEqual(decodedExample.child, "def")
        let decodedExample2 = try decoder.decode(
            InherienceWithSameContainerExample.self, from: data
        )
        XCTAssertEqual(decodedExample2.parent, "abc")
        XCTAssertEqual(decodedExample2.child, "def")
    }

    private class KeyedSuperExample: BaseClassExample {
        var child: String = ""

        override init() {
            super.init()
        }
        override func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: Keys.self)
            try container.encode(child, forKey: .child)
            let encoder = container.superEncoder()
            try super.encode(to: encoder)
        }

        required init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: Keys.self)
            self.child = try container.decode(String.self, forKey: .child)
            let superDecoder = try container.superDecoder()
            try super.init(from: superDecoder)
        }

        enum Keys: CodingKey {
            case child
        }
    }

    func testKeyedInherience() throws {
        let encoder = MsgpackEncoder()
        let example = KeyedSuperExample()
        example.parent = "abc"
        example.child = "def"
        let data = try encoder.encode(example)
        let msgpackElement = try encoder.convertToMsgpackElement()
        let decoder = MsgpackDecoder()
        try decoder.loadMsgpackElement(from: msgpackElement)
        let decodedExample = try KeyedSuperExample.init(from: decoder)
        XCTAssertEqual(decodedExample.parent, "abc")
        XCTAssertEqual(decodedExample.child, "def")
        let decodedExample2 = try decoder.decode(
            KeyedSuperExample.self, from: data
        )
        XCTAssertEqual(decodedExample2.parent, "abc")
        XCTAssertEqual(decodedExample2.child, "def")
    }

    // MARK: Extension
    func testDecodeTimestamp() throws {
        let data: [Double] = [
            0, -0.5, -1.5, 1.5, Double(UInt32.max), Double(UInt32.max) + 1,
            Double(UInt64(1) << 34 - 1), Double(UInt64(1) << 34),
        ]
        for time in data {
            let seconds = Int64(time.rounded(FloatingPointRoundingRule.down))
            let nanoseconds = UInt32(
                ((time - Double(seconds)) * 1_000_000_000).rounded(
                    FloatingPointRoundingRule.down))
            let timestamp = MsgpackTimestamp(
                seconds: seconds, nanoseconds: nanoseconds
            )
            let encoder = MsgpackEncoder()
            let content = try encoder.encode(timestamp)
            let decoder = MsgpackDecoder()
            let timestamp2 = try decoder.decode(
                MsgpackTimestamp.self, from: content
            )
            XCTAssertEqual(timestamp, timestamp2)
        }
    }

    // MARK: User Info
    struct UserInfoExample: Codable {
        init() {
        }

        func encode(to encoder: any Encoder) throws {
            var container1 = encoder.container(keyedBy: Keys.self)
            let superEncoder = container1.superEncoder()
            _ = superEncoder.singleValueContainer()
            let superEncoder2 = container1.superEncoder(forKey: .Key1)
            var container3 = superEncoder2.unkeyedContainer()
            let superEncoder3 = container3.superEncoder()
            _ = superEncoder3.singleValueContainer()
        }

        init(from decoder: any Decoder) throws {
            AsserUserInfo(decoder.userInfo)
            let container1 = try decoder.container(keyedBy: Keys.self)
            let superDecoder = try container1.superDecoder()
            AsserUserInfo(superDecoder.userInfo)
            _ = try superDecoder.singleValueContainer()
            let superDecoder2 = try container1.superDecoder(forKey: .Key1)
            AsserUserInfo(superDecoder2.userInfo)
            var container3 = try superDecoder2.unkeyedContainer()
            let superDecoder3 = try container3.superDecoder()
            AsserUserInfo(superDecoder3.userInfo)
            _ = try superDecoder3.singleValueContainer()
        }

        enum Keys: CodingKey {
            case Key1
        }

        func AsserUserInfo(_ userInfo: [CodingUserInfoKey: Any]) {
            XCTAssertEqual(userInfo.count, 1)
            let key = CodingUserInfoKey(rawValue: "key")!
            XCTAssertEqual(userInfo[key] as! String, "value")
        }
    }

    func testUserInfo() throws {
        var userInfo: [CodingUserInfoKey: Any] = [:]
        let key = CodingUserInfoKey(rawValue: "key")!
        userInfo[key] = "value"
        let encoder = MsgpackEncoder(userInfo: userInfo)
        let example = UserInfoExample()
        let data = try encoder.encode(example)
        let decoder = MsgpackDecoder(userInfo: userInfo)
        _ = try decoder.decode(UserInfoExample.self, from: data)
    }

    struct CodingKeyExample: Codable {
        init() {
        }

        func encode(to encoder: any Encoder) throws {
            var container1 = encoder.container(keyedBy: Keys.self)
            let superEncoder = container1.superEncoder()
            _ = superEncoder.singleValueContainer()
            let superEncoder2 = container1.superEncoder(forKey: .superKey)
            _ = superEncoder2.singleValueContainer()
            var container2 = container1.nestedContainer(
                keyedBy: Keys.self, forKey: .Key1
            )
            var container3 = container2.nestedUnkeyedContainer(forKey: .Key2)
            _ = container3.nestedUnkeyedContainer()
        }

        init(from decoder: any Decoder) throws {
            XCTAssertEqual(decoder.codingPath.count, 0)
            let container1 = try decoder.container(keyedBy: Keys.self)
            XCTAssertEqual(container1.codingPath.count, 0)

            let superDecoder = try container1.superDecoder()
            XCTAssertEqual(superDecoder.codingPath.count, 1)
            XCTAssertEqual(
                superDecoder.codingPath[0] as! MsgpackCodingKey,
                MsgpackCodingKey(stringValue: "super")
            )

            let superSingleValueContainer =
                try superDecoder.singleValueContainer()
            XCTAssertEqual(superSingleValueContainer.codingPath.count, 1)
            XCTAssertEqual(
                superSingleValueContainer.codingPath[0] as! MsgpackCodingKey,
                MsgpackCodingKey(stringValue: "super")
            )

            let superDecoder2 = try container1.superDecoder(forKey: .superKey)
            XCTAssertEqual(superDecoder2.codingPath.count, 1)
            XCTAssertEqual(superDecoder2.codingPath[0] as! Keys, Keys.superKey)

            let superSingleValueContainer2 =
                try superDecoder2.singleValueContainer()
            XCTAssertEqual(superSingleValueContainer2.codingPath.count, 1)
            XCTAssertEqual(
                superSingleValueContainer2.codingPath[0] as! Keys, Keys.superKey
            )

            let container2 = try container1.nestedContainer(
                keyedBy: Keys.self, forKey: .Key1
            )
            XCTAssertEqual(container2.codingPath.count, 1)
            XCTAssertEqual(container2.codingPath[0] as! Keys, Keys.Key1)

            var container3 = try container2.nestedUnkeyedContainer(
                forKey: .Key2)
            XCTAssertEqual(container3.codingPath.count, 2)
            XCTAssertEqual(container3.codingPath[0] as! Keys, Keys.Key1)
            XCTAssertEqual(container3.codingPath[1] as! Keys, Keys.Key2)

            let container4 = try container3.nestedUnkeyedContainer()
            XCTAssertEqual(container4.codingPath.count, 3)
            XCTAssertEqual(container4.codingPath[0] as! Keys, Keys.Key1)
            XCTAssertEqual(container4.codingPath[1] as! Keys, Keys.Key2)
            XCTAssertEqual(
                container4.codingPath[2] as! MsgpackCodingKey,
                MsgpackCodingKey(intValue: 0)
            )
        }

        enum Keys: CodingKey {
            case Key1, Key2, superKey
        }
    }

    func testCodingKey() throws {
        let example = CodingKeyExample()
        let encoder = MsgpackEncoder()
        let data = try encoder.encode(example)

        let decoder = MsgpackDecoder()
        _ = try decoder.decode(CodingKeyExample.self, from: data)
    }

    // MARK: Container properties
    struct UnkeyedContainerCountExample: Codable {
        init() {
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.unkeyedContainer()
            try container.encode(true)
            _ = container.superEncoder().singleValueContainer()
        }
        init(from decoder: any Decoder) throws {
            var container = try decoder.unkeyedContainer()
            XCTAssertEqual(container.count, 2)
            XCTAssertEqual(container.currentIndex, 0)
            XCTAssertEqual(container.isAtEnd, false)
            XCTAssertEqual(try container.decodeNil(), false)
            XCTAssertEqual(container.count, 2)
            XCTAssertEqual(container.currentIndex, 0)
            XCTAssertEqual(container.isAtEnd, false)
            let bool = try container.decode(Bool.self)
            XCTAssertEqual(bool, true)
            XCTAssertEqual(container.count, 2)
            XCTAssertEqual(container.currentIndex, 1)
            XCTAssertEqual(container.isAtEnd, false)
            _ = try container.superDecoder().singleValueContainer()
            XCTAssertEqual(container.count, 2)
            XCTAssertEqual(container.currentIndex, 2)
            XCTAssertEqual(container.isAtEnd, true)
        }
    }

    func testUnkeyedContainerCount() throws {
        let example = UnkeyedContainerCountExample()
        let encoder = MsgpackEncoder()
        let data = try encoder.encode(example)

        let decoder = MsgpackDecoder()
        _ = try decoder.decode(UnkeyedContainerCountExample.self, from: data)
    }

    struct KeyedContainerExample: Codable {
        init() {
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: Keys.self)
            try container.encode(true, forKey: .Key1)
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: Keys.self)
            XCTAssertEqual(container.contains(.Key1), true)
            XCTAssertEqual(container.contains(.Key2), false)
            XCTAssertEqual(container.allKeys.count, 1)
            XCTAssertEqual(container.allKeys[0], .Key1)
        }

        enum Keys: CodingKey {
            case Key1, Key2
        }
    }

    func testKeyedContainerKeys() throws {
        let encoder = MsgpackEncoder()
        let example = KeyedContainerExample()
        let data = try encoder.encode(example)
        let decoder = MsgpackDecoder()
        _ = try decoder.decode(KeyedContainerExample.self, from: data)
    }
}



---
File: /Tests/SignalRClientTests/Msgpack/MsgpackEncoderTests.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation
import XCTest

@testable import SignalRClient

class MsgpackEncoderTests: XCTestCase {
    // MARK: Convert MsgpackElement to Data
    func testEncodeUInt() throws {
        var data: [UInt64: Data] = [:]
        data[0x00] = Data([0x00])
        data[0x7f] = Data([0x7f])
        data[0x80] = Data([0xcc, 0x80])
        data[0xff] = Data([0xcc, 0xff])
        data[0x100] = Data([0xcd, 0x01, 0x00])
        data[0xffff] = Data([0xcd, 0xff, 0xff])
        data[0x10000] = Data([0xce, 0x00, 0x01, 0x00, 0x00])
        data[0xffff_ffff] = Data([0xce, 0xff, 0xff, 0xff, 0xff])
        data[0x1_0000_0000] = Data([
            0xcf, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,
        ])
        for (uint64, expected) in data {
            let result = try MsgpackElement.uint(uint64).marshall()
            XCTAssertEqual(result, expected)
        }
    }

    func testEncodeInt() throws {
        var data: [Int64: Data] = [:]
        data[-0x20] = Data([0xe0])
        data[-0x21] = Data([0xd0, 0xdf])
        data[-0x80] = Data([0xd0, 0x80])
        data[-0x81] = Data([0xd1, 0xff, 0x7f])
        data[-0x8000] = Data([0xd1, 0x80, 0x00])
        data[-0x8001] = Data([0xd2, 0xff, 0xff, 0x7f, 0xff])
        data[-0x8000_0000] = Data([0xd2, 0x80, 0x00, 0x00, 0x00])
        data[-0x8000_0001] = Data([
            0xd3, 0xff, 0xff, 0xff, 0xff, 0x7f, 0xff, 0xff, 0xff,
        ])
        data[0x00] = Data([0x00])
        data[0x7f] = Data([0x7f])
        for (int64, expected) in data {
            let result = try MsgpackElement.int(int64).marshall()
            XCTAssertEqual(result, expected)
        }
    }

    func testEncodeFloat32() throws {
        var data: [Float32: Data] = [:]
        data[0.0] = Data([0xca, 0x00, 0x00, 0x00, 0x00])
        data[1.1] = Data([0xca, 0x3f, 0x8c, 0xcc, 0xcd])
        data[-0.9] = Data([0xca, 0xbf, 0x66, 0x66, 0x66])
        for (float32, expected) in data {
            let result = try MsgpackElement.float32(float32).marshall()
            XCTAssertEqual(result, expected)
        }
    }

    func testEncodeFloat64() throws {
        var data: [Float64: Data] = [:]
        data[0.0] = Data([0xcb, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        data[1.1] = Data([0xcb, 0x3f, 0xf1, 0x99, 0x99, 0x99, 0x99, 0x99, 0x9a])
        data[-0.9] = Data([
            0xcb, 0xbf, 0xec, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcd,
        ])
        for (float64, expected) in data {
            let result = try MsgpackElement.float64(float64).marshall()
            XCTAssertEqual(result, expected)
        }
    }

    func testEncodeString() throws {
        var data: [Int: Data] = [:]
        data[0] = Data([0xa0])
        data[1 << 5 - 1] = [0xbf] + Data(repeating: 0x61, count: 1 << 5 - 1)
        data[1 << 5] = [0xd9, 0x20] + Data(repeating: 0x61, count: 1 << 5)
        data[1 << 8 - 1] =
            [0xd9, 0xff] + Data(repeating: 0x61, count: 1 << 8 - 1)
        data[1 << 8] =
            [0xda, 0x01, 0x00] + Data(repeating: 0x61, count: 1 << 8)
        data[1 << 16 - 1] =
            [0xda, 0xff, 0xff] + Data(repeating: 0x61, count: 1 << 16 - 1)
        data[1 << 16] =
            [0xdb, 0x00, 0x01, 0x00, 0x00]
                + Data(repeating: 0x61, count: 1 << 16)
        for (length, expected) in data {
            let string = String(repeating: Character("a"), count: length)
            let result = try MsgpackElement.string(string).marshall()
            XCTAssertEqual(result, expected)
        }
    }

    func testEncodeBool() throws {
        var data: [Bool: Data] = [:]
        data[true] = Data([0xc3])
        data[false] = Data([0xc2])
        for (bool, expected) in data {
            let result = try MsgpackElement.bool(bool).marshall()
            XCTAssertEqual(result, expected)
        }
    }

    func testEncodeNil() throws {
        let expected = Data([0xc0])
        let result = try MsgpackElement.null.marshall()
        XCTAssertEqual(result, expected)
    }

    func testEncodeData() throws {
        var data: [Int: Data] = [:]
        data[0] = Data([0xc4, 0x00])
        data[1 << 8 - 1] =
            [0xc4, 0xff] + Data(repeating: UInt8(1), count: 1 << 8 - 1)
        data[1 << 8] =
            [0xc5, 0x01, 0x00] + Data(repeating: UInt8(1), count: 1 << 8)
        data[1 << 16 - 1] =
            [0xc5, 0xff, 0xff] + Data(repeating: UInt8(1), count: 1 << 16 - 1)
        data[1 << 16] =
            [0xc6, 0x00, 0x01, 0x00, 0x00]
                + Data(repeating: UInt8(1), count: 1 << 16)
        for (length, expected) in data {
            let data = Data(repeating: UInt8(1), count: length)
            let result = try MsgpackElement.bin(data).marshall()
            XCTAssertEqual(result, expected)
        }
    }

    func testEncodeMap() throws {
        var map: [String: MsgpackElement] = [:]
        var result = try MsgpackElement.map(map).marshall()
        XCTAssertEqual(result, Data([0x80]))
        for i in 0 ..< 1 << 4 - 1 {
            map[String(i)] = MsgpackElement.bool(true)
        }
        result = try MsgpackElement.map(map).marshall()
        XCTAssertEqual(result.count, 51)
        XCTAssertEqual(result[0], 0x8f)

        map.removeAll()
        for i in 0 ..< 1 << 4 {
            map[String(i)] = MsgpackElement.bool(true)
        }
        result = try MsgpackElement.map(map).marshall()
        XCTAssertEqual(result.count, 57)
        XCTAssertEqual(result[0 ... 2], Data([0xde, 0x00, 0x10]))

        map.removeAll()
        for i in 0 ..< 1 << 16 - 1 {
            map[String(i)] = MsgpackElement.bool(true)
        }
        result = try MsgpackElement.map(map).marshall()
        XCTAssertEqual(result.count, 447_638)
        XCTAssertEqual(result[0 ... 2], Data([0xde, 0xff, 0xff]))

        map.removeAll()
        for i in 0 ..< 1 << 16 {
            map[String(i)] = MsgpackElement.bool(true)
        }
        result = try MsgpackElement.map(map).marshall()
        XCTAssertEqual(result.count, 447_647)
        XCTAssertEqual(result[0 ... 4], Data([0xdf, 0x00, 0x01, 0x00, 0x00]))
    }

    func testEncodeArray() throws {
        var data: [MsgpackElement] = []
        var result = try MsgpackElement.array(data).marshall()
        XCTAssertEqual(result, Data([0x90]))

        data = [MsgpackElement](repeating: .bool(true), count: 1 << 4 - 1)
        result = try MsgpackElement.array(data).marshall()
        XCTAssertEqual(
            result, [0x9f] + Data(repeating: 0xc3, count: 1 << 4 - 1)
        )

        data = [MsgpackElement](repeating: .bool(true), count: 1 << 4)
        result = try MsgpackElement.array(data).marshall()
        XCTAssertEqual(
            result, [0xdc, 0x00, 0x10] + Data(repeating: 0xc3, count: 1 << 4)
        )

        data = [MsgpackElement](repeating: .bool(true), count: 1 << 16 - 1)
        result = try MsgpackElement.array(data).marshall()
        XCTAssertEqual(
            result,
            [0xdc, 0xff, 0xff] + Data(repeating: 0xc3, count: 1 << 16 - 1)
        )

        data = [MsgpackElement](repeating: .bool(true), count: 1 << 16)
        result = try MsgpackElement.array(data).marshall()
        XCTAssertEqual(
            result,
            [0xdd, 0x00, 0x01, 0x00, 0x00]
                + Data(repeating: 0xc3, count: 1 << 16)
        )
    }

    func testEncodeExtension() throws {
        var data: [Int: Data] = [:]
        data[1] = Data([0xd4, 0xff])
        data[2] = Data([0xd5, 0xff])
        data[4] = Data([0xd6, 0xff])
        data[8] = Data([0xd7, 0xff])
        data[16] = Data([0xd8, 0xff])
        data[0] = Data([0xc7, 0x00, 0xff])
        data[1 << 8 - 1] = Data([0xc7, 0xff, 0xff])
        data[1 << 8] = Data([0xc8, 0x01, 0x00, 0xff])
        data[1 << 16 - 1] = Data([0xc8, 0xff, 0xff, 0xff])
        data[1 << 16] = Data([0xc9, 0x00, 0x01, 0x00, 0x00, 0xff])
        data[Int(UInt32.max)] = Data([0xc9, 0xff, 0xff, 0xff, 0xff, 0xff])
        for (len, extPrefix) in data {
            let extData = Data(repeating: 1, count: len)
            let msgpackElement = MsgpackElement.ext(-1, extData)
            let result = try msgpackElement.marshall()
            let expected = extPrefix + extData
            XCTAssertEqual(result, expected)
        }
    }

    // Used for debugging
    func testAgainstExpected(v: Encodable, expected: Data, result: Data) throws {
        if expected != result {
            print(expected.hexEncodedString())
            print(result.hexEncodedString())
            XCTFail("encoded result for \(v) not equal to expected")
        }
    }

    // MARK: Convert from basic Swift type to MsgpackElement
    func testInitInt() throws {
        XCTAssertEqual(MsgpackElement(Int8(-1)), MsgpackElement.int(Int64(-1)))
        XCTAssertEqual(MsgpackElement(Int16(-1)), MsgpackElement.int(Int64(-1)))
        XCTAssertEqual(MsgpackElement(Int32(-1)), MsgpackElement.int(Int64(-1)))
        XCTAssertEqual(MsgpackElement(Int64(-1)), MsgpackElement.int(Int64(-1)))
    }

    func testInitUInt() throws {
        XCTAssertEqual(MsgpackElement(UInt8(1)), MsgpackElement.uint(UInt64(1)))
        XCTAssertEqual(MsgpackElement(UInt16(1)), MsgpackElement.uint(UInt64(1)))
        XCTAssertEqual(MsgpackElement(UInt32(1)), MsgpackElement.uint(UInt64(1)))
        XCTAssertEqual(MsgpackElement(UInt64(1)), MsgpackElement.uint(UInt64(1)))
    }

    // The compiler implement its encodable as Float32
    func testFloat16() throws {
        let encoder = MsgpackEncoder()
        _ = try encoder.encode(Float16(1))
        let msgpackElement = try encoder.msgpack?.convertToMsgpackElement()
        XCTAssertEqual(msgpackElement, MsgpackElement.float32(Float32(1)))
    }

    func testInitFloat32() throws {
        XCTAssertEqual(MsgpackElement(Float32(1)), MsgpackElement.float32(Float32(1)))
    }

    func testInitFloat64() throws {
        XCTAssertEqual(MsgpackElement(Float64(1)), MsgpackElement.float64(Float64(1)))
    }

    func testInitBool() throws {
        XCTAssertEqual(MsgpackElement(true), MsgpackElement.bool(true))
        XCTAssertEqual(MsgpackElement(false), MsgpackElement.bool(false))
    }

    func testInitString() throws {
        XCTAssertEqual(MsgpackElement("abc"), MsgpackElement.string("abc"))
    }

    func testInitData() throws {
        XCTAssertEqual(MsgpackElement(Data([123])), MsgpackElement.bin(Data([123])))
    }

    func testMapArrayNotInited() throws {
        XCTAssertEqual(MsgpackElement([String: String]()), nil)
        XCTAssertEqual(MsgpackElement([String]()), nil)
    }

    // MARK: MsgpackEncoder encode
    private class DefaultEncodeExample: Encodable {
        var int: Int
        var intNil: Int?
        var bool: Bool
        var boolNil: Bool?
        var string: String
        var data: Data
        var float32: Float32
        var float64: Float64
        var map1: [String: String]
        var map2: [String: Bool]
        var map3: [String: [String: Bool]]
        var array1: [Int?]
        var array2: [[Int?]]
        var date: Date

        init() {
            self.int = 2
            self.boolNil = true
            self.bool = true
            self.string = "123"
            self.data = Data([0x90])
            self.float32 = 1.1
            self.float64 = 1.1
            self.map1 = [:]
            self.map2 = ["a": true]
            self.map3 = ["b": map2]
            self.array1 = [1, 2, nil, 4]
            self.array2 = [self.array1]
            self.date = Date(timeIntervalSince1970: 100.1)
        }
    }

    func testDefaultEncode() throws {
        let encoder = MsgpackEncoder()
        let example = DefaultEncodeExample()
        _ = try encoder.encode(example)
        let msgpackElement = try encoder.convertToMsgpackElement()
        guard case let MsgpackElement.map(m) = msgpackElement else {
            XCTFail("Decoded to unexpected msgpack type:\(msgpackElement)")
            return
        }
        XCTAssertEqual(m.count, 13)
        XCTAssertEqual(m["int"], MsgpackElement.int(Int64(2)))
        XCTAssertEqual(m["intNil"], nil)
        XCTAssertEqual(m["bool"], MsgpackElement.bool(true))
        XCTAssertEqual(m["boolNil"], MsgpackElement.bool(true))
        XCTAssertEqual(m["string"], MsgpackElement.string("123"))
        XCTAssertEqual(m["data"], MsgpackElement.bin(Data([0x90])))
        XCTAssertEqual(m["float32"], MsgpackElement.float32(Float32(1.1)))
        XCTAssertEqual(m["float64"], MsgpackElement.float64(Float64(1.1)))
        XCTAssertEqual(m["map1"], MsgpackElement.map([String: MsgpackElement]()))
        var map2: [String: MsgpackElement] = [:]
        map2["a"] = MsgpackElement.bool(true)
        XCTAssertEqual(m["map2"], MsgpackElement.map(map2))
        var map3: [String: MsgpackElement] = [:]
        map3["b"] = MsgpackElement.map(map2)
        XCTAssertEqual(m["map3"], MsgpackElement.map(map3))
        let array1 = [
            MsgpackElement.int(1), MsgpackElement.int(2), MsgpackElement.null,
            MsgpackElement.int(4),
        ]
        XCTAssertEqual(m["array1"], MsgpackElement.array(array1))
        var array2: [MsgpackElement] = []
        array2.append(MsgpackElement.array(array1))
        XCTAssertEqual(m["array2"], MsgpackElement.array(array2))
    }

    private class ManualEncodeExample: Encodable {
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: Keys.self)
            try container.encode(123, forKey: .Key1)
            var nestedKeyedContainer1 = container.nestedContainer(
                keyedBy: Keys.self, forKey: Keys.Key2
            )
            try nestedKeyedContainer1.encode("123", forKey: Keys.nestedKey1)
            var nestedUnkeyedContainer = container.nestedUnkeyedContainer(
                forKey: Keys.Key3)
            try nestedUnkeyedContainer.encode(Data([0x12]))
        }

        enum Keys: CodingKey {
            case Key1
            case Key2
            case Key3

            case nestedKey1
        }
    }

    func testManualEncode() throws {
        let example2 = ManualEncodeExample()
        let encoder = MsgpackEncoder()
        _ = try encoder.encode(example2)
        let msgpackElement = try encoder.convertToMsgpackElement()

        var map: [String: MsgpackElement] = [:]
        map["Key1"] = MsgpackElement.int(123)
        var nestedMap: [String: MsgpackElement] = [:]
        nestedMap["nestedKey1"] = MsgpackElement.string("123")
        map["Key2"] = MsgpackElement.map(nestedMap)
        var nestedArray: [MsgpackElement] = []
        nestedArray.append(MsgpackElement.bin(Data([0x12])))
        map["Key3"] = MsgpackElement.array(nestedArray)
        let expected = MsgpackElement.map(map)
        XCTAssertEqual(msgpackElement, expected)
    }

    private class BaseClassExample: Encodable {
        var parent: Bool = true
    }

    private class InherienceWithSameContainerExample: BaseClassExample {
        var child: Bool = true

        override func encode(to encoder: any Encoder) throws {
            try super.encode(to: encoder)
            // Switching to a KeyedContainer with different key type
            var container = encoder.container(keyedBy: Keys.self)
            try container.encode(child, forKey: .child)
        }

        enum Keys: CodingKey {
            case child
        }
    }

    func testInherienceUsingSameTopContainer() throws { // Undocumented behavior. Keep aligh with the jsonEncoder
        let encoder = MsgpackEncoder()
        let example = InherienceWithSameContainerExample()
        _ = try encoder.encode(example)
        let msgpackElement = try encoder.convertToMsgpackElement()
        guard case let MsgpackElement.map(m) = msgpackElement else {
            XCTFail("The msgpackElement should be map")
            return
        }
        XCTAssertEqual(m.count, 2)
        XCTAssertEqual(m["parent"], MsgpackElement.bool(true))
        XCTAssertEqual(m["child"], MsgpackElement.bool(true))
        print(msgpackElement)
    }

    private class KeyedSuperExample: BaseClassExample {
        var child: Bool = true
        override func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: Keys.self)
            try container.encode(child, forKey: .child)
            let superencoder = container.superEncoder()
            try super.encode(to: superencoder)
            let superencoder2 = container.superEncoder(forKey: Keys.super2)
            try super.encode(to: superencoder2)
        }
        enum Keys: CodingKey {
            case child
            case super2
        }
    }

    func testKeyedInherience() throws {
        let encoder = MsgpackEncoder()
        let example = KeyedSuperExample()
        _ = try encoder.encode(example)
        let msgpackElement = try encoder.convertToMsgpackElement()
        guard case let MsgpackElement.map(m) = msgpackElement else {
            XCTFail("The msgpackElement should be map")
            return
        }

        XCTAssertEqual(m.count, 3)
        var parent: [String: MsgpackElement] = [:]
        parent["parent"] = MsgpackElement.bool(true)
        let parentMsgpackElement = MsgpackElement.map(parent)
        XCTAssertEqual(m["super"], parentMsgpackElement)
        XCTAssertEqual(m["super2"], parentMsgpackElement)
        XCTAssertEqual(m["child"], MsgpackElement.bool(true))
    }

    private class UnkeyedSuperExample: BaseClassExample {
        override func encode(to encoder: any Encoder) throws {
            var container = encoder.unkeyedContainer()
            try container.encode(true)
            let encoder = container.superEncoder()
            try super.encode(to: encoder)
        }
    }

    func testUnkeyedInherience() throws {
        let encoder = MsgpackEncoder()
        let example = UnkeyedSuperExample()
        _ = try encoder.encode(example)
        let msgpackElement = try encoder.convertToMsgpackElement()
        guard case let MsgpackElement.array(array) = msgpackElement else {
            XCTFail("The msgpackElement should be array")
            return
        }

        _ = try JSONEncoder().encode(example)
        XCTAssertEqual(array.count, 2)
        var parent: [String: MsgpackElement] = [:]
        parent["parent"] = MsgpackElement.bool(true)
        let parentMsgpackElement = MsgpackElement.map(parent)
        XCTAssertEqual(array[0], MsgpackElement.bool(true))
        XCTAssertEqual(array[1], parentMsgpackElement)
    }

    // MARK: Extension
    func testEncodeTimestamp() throws {
        var data: [Double: Data] = [:]
        data[0] = Data([0x0, 0x0, 0x0, 0x0])
        data[-0.5] = Data([
            0x1d, 0xcd, 0x65, 0x0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff,
        ])
        data[-1.5] = Data([
            0x1d, 0xcd, 0x65, 0x0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xfe,
        ])
        data[1.5] = Data([0x77, 0x35, 0x94, 0x0, 0x0, 0x0, 0x0, 0x1])
        data[Double(UInt32.max)] = Data([0xff, 0xff, 0xff, 0xff])
        data[Double(UInt32.max) + 1] = Data([
            0x0, 0x0, 0x0, 0x1, 0x0, 0x0, 0x0, 0x0,
        ])
        data[Double(UInt64(1) << 34 - 1)] = Data([
            0x0, 0x0, 0x0, 0x3, 0xff, 0xff, 0xff, 0xff,
        ])
        data[Double(UInt64(1) << 34)] = Data([
            0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x4, 0x0, 0x0, 0x0, 0x0,
        ])

        for (time, expected) in data {
            let seconds = Int64(time.rounded(FloatingPointRoundingRule.down))
            let nanoseconds = UInt32(
                ((time - Double(seconds)) * 1_000_000_000).rounded(
                    FloatingPointRoundingRule.down))
            let timestamp = MsgpackTimestamp(
                seconds: seconds, nanoseconds: nanoseconds
            )
            let encoder = MsgpackEncoder()
            _ = try encoder.encode(timestamp)
            let msgpackElement = try encoder.convertToMsgpackElement()
            guard case let MsgpackElement.ext(extType, extData) = msgpackElement
            else {
                XCTFail("Encoder should produce extension type")
                return
            }
            XCTAssertEqual(extType, -1)
            XCTAssertEqual(extData, expected)
        }
    }

    // MARK: User Info
    struct UserInfoExample: Encodable {
        func encode(to encoder: any Encoder) throws {
            let userInfo = encoder.userInfo
            AsserUserInfo(userInfo)
            var container1 = encoder.container(keyedBy: Keys.self)
            let superEncoder = container1.superEncoder()
            AsserUserInfo(superEncoder.userInfo)
            _ = superEncoder.singleValueContainer()
            let superEncoder2 = container1.superEncoder(forKey: .Key1)
            AsserUserInfo(superEncoder2.userInfo)
            var container3 = superEncoder2.unkeyedContainer()
            let superEncoder3 = container3.superEncoder()
            _ = superEncoder3.singleValueContainer()
            AsserUserInfo(superEncoder3.userInfo)
        }

        enum Keys: CodingKey {
            case Key1
        }

        func AsserUserInfo(_ userInfo: [CodingUserInfoKey: Any]) {
            XCTAssertEqual(userInfo.count, 1)
            let key = CodingUserInfoKey(rawValue: "key")!
            XCTAssertEqual(userInfo[key] as! String, "value")
        }
    }

    func testUserInfo() throws {
        var userInfo: [CodingUserInfoKey: Any] = [:]
        let key = CodingUserInfoKey(rawValue: "key")!
        userInfo[key] = "value"
        let encoder = JSONEncoder()
        encoder.userInfo[key] = "value"
        let example = UserInfoExample()
        _ = try encoder.encode(example)
    }

    // MARK: CodingKey
    struct CodingKeyExample: Encodable {
        func encode(to encoder: any Encoder) throws {
            XCTAssertEqual(encoder.codingPath.count, 0)
            var container1 = encoder.container(keyedBy: Keys.self)
            XCTAssertEqual(container1.codingPath.count, 0)

            let superEncoder = container1.superEncoder()
            XCTAssertEqual(superEncoder.codingPath.count, 1)
            XCTAssertEqual(
                superEncoder.codingPath[0] as! MsgpackCodingKey,
                MsgpackCodingKey(stringValue: "super")
            )
            let superSingleValueContainer = superEncoder.singleValueContainer()
            XCTAssertEqual(superSingleValueContainer.codingPath.count, 1)
            XCTAssertEqual(
                superSingleValueContainer.codingPath[0] as! MsgpackCodingKey,
                MsgpackCodingKey(stringValue: "super")
            )

            let superEncoder2 = container1.superEncoder(forKey: .superKey)
            XCTAssertEqual(superEncoder2.codingPath.count, 1)
            XCTAssertEqual(superEncoder2.codingPath[0] as! Keys, Keys.superKey)
            let superSingleValueContainer2 =
                superEncoder2.singleValueContainer()
            XCTAssertEqual(superSingleValueContainer2.codingPath.count, 1)
            XCTAssertEqual(
                superSingleValueContainer2.codingPath[0] as! Keys, Keys.superKey
            )

            XCTAssertEqual(container1.codingPath.count, 0)
            var container2 = container1.nestedContainer(
                keyedBy: Keys.self, forKey: .Key1
            )
            XCTAssertEqual(container2.codingPath.count, 1)
            XCTAssertEqual(container2.codingPath[0] as! Keys, Keys.Key1)

            var container3 = container2.nestedUnkeyedContainer(forKey: .Key2)
            XCTAssertEqual(container3.codingPath.count, 2)
            XCTAssertEqual(container3.codingPath[0] as! Keys, Keys.Key1)
            XCTAssertEqual(container3.codingPath[1] as! Keys, Keys.Key2)

            let container4 = container3.nestedUnkeyedContainer()
            XCTAssertEqual(container4.codingPath.count, 3)
            XCTAssertEqual(container4.codingPath[0] as! Keys, Keys.Key1)
            XCTAssertEqual(container4.codingPath[1] as! Keys, Keys.Key2)
            XCTAssertEqual(
                container4.codingPath[2] as! MsgpackCodingKey,
                MsgpackCodingKey(intValue: 0)
            )
        }

        enum Keys: CodingKey {
            case Key1, Key2, superKey
        }
    }

    func testCodingKey() throws {
        let example = CodingKeyExample()
        let encoder = MsgpackEncoder()
        _ = try encoder.encode(example)
    }

    // MARK: Container properties
    struct UnkeyedContainerCountExample: Encodable {
        func encode(to encoder: any Encoder) throws {
            var container = encoder.unkeyedContainer()
            XCTAssertEqual(container.count, 0)
            try container.encode(true)
            XCTAssertEqual(container.count, 1)
            _ = container.superEncoder().singleValueContainer()
            XCTAssertEqual(container.count, 2)
        }
    }

    func testUnkeyedContainerCount() throws {
        let example = UnkeyedContainerCountExample()
        let encoder = MsgpackEncoder()
        _ = try encoder.encode(example)
    }
}

// Used for debugging
extension Data {
    fileprivate func hexEncodedString() -> String {
        return self.map { v in String(format: "%02hhx", v) }.joined()
    }
    fileprivate func hexEncodedArray() -> String {
        return self.map { v in String(format: "0x%02hhx", v) }.joined(
            separator: ",")
    }
}



---
File: /Tests/SignalRClientTests/AsyncLockTest.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import XCTest
@testable import SignalRClient

class AsyncLockTests: XCTestCase {
    func testLock_WhenNotLocked_Succeeds() async {
        let asyncLock = AsyncLock()
        await asyncLock.wait()
        asyncLock.release()
    }

    func testLock_SecondLock_Waits() async throws {
        let expectation = XCTestExpectation(description: "wait() should be called")
        let asyncLock = AsyncLock()
        await asyncLock.wait()
        let t = Task {
            await asyncLock.wait()
            defer {
                asyncLock.release()
            }
            expectation.fulfill()
        }

        asyncLock.release()
        await fulfillment(of: [expectation], timeout: 2.0)
        t.cancel()
    }
}


---
File: /Tests/SignalRClientTests/EventSourceTests.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation
import XCTest

@testable import SignalRClient

class EventSourceTests: XCTestCase {
    func testEventParser() async throws {
        let parser = EventParser()

        var content = "data:hello\n\n".data(using: .utf8)!
        var events = parser.Parse(data: content)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0], "hello")

        content = "data: hello\n\n".data(using: .utf8)!
        events = parser.Parse(data: content)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0], "hello")

        content = "data: hello\r\n\r\n".data(using: .utf8)!
        events = parser.Parse(data: content)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0], "hello")

        content = "data: hello\r\n\n".data(using: .utf8)!
        events = parser.Parse(data: content)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0], "hello")

        content = "data:  hello\n\n".data(using: .utf8)!
        events = parser.Parse(data: content)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0], " hello")

        content = "data:\n\n".data(using: .utf8)!
        events = parser.Parse(data: content)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0], "")

        content = "data\n\n".data(using: .utf8)!
        events = parser.Parse(data: content)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0], "")

        content = "data\ndata\n\n".data(using: .utf8)!
        events = parser.Parse(data: content)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0], "\n")

        content = "data:\ndata\n\n".data(using: .utf8)!
        events = parser.Parse(data: content)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0], "\n")

        content = "dat".data(using: .utf8)!
        events = parser.Parse(data: content)
        XCTAssertEqual(events.count, 0)

        content = "a:e\n\n".data(using: .utf8)!
        events = parser.Parse(data: content)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0], "e")

        content = ":\n\n".data(using: .utf8)!
        events = parser.Parse(data: content)
        XCTAssertEqual(events.count, 0)

        content = "retry:abc\n\n".data(using: .utf8)!
        events = parser.Parse(data: content)
        XCTAssertEqual(events.count, 0)

        content = "dataa:abc\n\n".data(using: .utf8)!
        events = parser.Parse(data: content)
        XCTAssertEqual(events.count, 0)

        content = "Data:abc\n\n".data(using: .utf8)!
        events = parser.Parse(data: content)
        XCTAssertEqual(events.count, 0)

        content = "data:abc \ndata\n\n".data(using: .utf8)!
        events = parser.Parse(data: content)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0], "abc \n")

        content = "data:abc \ndata:efg\n\n".data(using: .utf8)!
        events = parser.Parse(data: content)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0], "abc \nefg")

        content = "data:abc \ndata:efg\n\nretry\ndata:h\n\n".data(using: .utf8)!
        events = parser.Parse(data: content)
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0], "abc \nefg")
        XCTAssertEqual(events[1], "h")
    }
}



---
File: /Tests/SignalRClientTests/HandshakeProtocolTests.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import XCTest
@testable import SignalRClient

class HandshakeProtocolTests: XCTestCase {

    func testWriteHandshakeRequest() throws {
        let handshakeRequest = HandshakeRequestMessage(protocol: "json", version: 1)
        let result: String = try HandshakeProtocol.writeHandshakeRequest(handshakeRequest: handshakeRequest)

        XCTAssertTrue(result.hasSuffix("\u{1e}"))

        let resultWithoutPrefix = result.dropLast()

        let resultJson = try JSONSerialization.jsonObject(with: resultWithoutPrefix.data(using: .utf8)!, options: []) as? [String: Any]
        XCTAssertEqual("json", resultJson?["protocol"] as? String)
        XCTAssertEqual(1, resultJson?["version"] as? Int)
    }

    func testParseHandshakeResponseWithValidString() throws {
        let responseString = "{\"error\":null,\"minorVersion\":1}\u{1e}"
        let data = StringOrData.string(responseString)
        let (remainingData, responseMessage) = try HandshakeProtocol.parseHandshakeResponse(data: data)

        XCTAssertNil(remainingData)
        XCTAssertNil(responseMessage.error)
        XCTAssertEqual(responseMessage.minorVersion, 1)
    }

    func testParseHandshakeResponseWithValidString2() throws {
        let responseString = "{}\u{1e}"
        let data = StringOrData.string(responseString)
        let (remainingData, responseMessage) = try HandshakeProtocol.parseHandshakeResponse(data: data)

        XCTAssertNil(remainingData)
        XCTAssertNil(responseMessage.error)
        XCTAssertNil(responseMessage.minorVersion)
    }

    func testParseHandshakeResponseWithValidData() throws {
        let responseString = "{\"error\":null,\"minorVersion\":1}\u{1e}"
        let responseData = responseString.data(using: .utf8)!
        let data = StringOrData.data(responseData)
        let (remainingData, responseMessage) = try HandshakeProtocol.parseHandshakeResponse(data: data)

        XCTAssertNil(remainingData)
        XCTAssertNil(responseMessage.error)
        XCTAssertEqual(responseMessage.minorVersion, 1)
    }

    func testParseHandshakeResponseWithRemainingStringData() throws {
        let responseString = "{\"error\":null,\"minorVersion\":1}\u{1e}remaining"
        let data = StringOrData.string(responseString)
        let (remainingData, responseMessage) = try HandshakeProtocol.parseHandshakeResponse(data: data)

        if case let .string(remainingData) = remainingData {
            XCTAssertEqual(remainingData, "remaining")
        } else {
            XCTFail("Remaining data should be string")
        }
        XCTAssertNil(responseMessage.error)
        XCTAssertEqual(responseMessage.minorVersion, 1)
    }

    func testParseHandshakeResponseWithRemainingBinaryData() throws {
        let responseString = "{\"error\":null,\"minorVersion\":1}\u{1e}remaining"
        let responseData = responseString.data(using: .utf8)!
        let data = StringOrData.data(responseData)
        let (remainingData, responseMessage) = try HandshakeProtocol.parseHandshakeResponse(data: data)

        if case let .data(remainingData) = remainingData {
            XCTAssertEqual(remainingData, "remaining".data(using: .utf8)!)
        } else {
            XCTFail("Remaining data should be data")
        }
        XCTAssertNil(responseMessage.error)
        XCTAssertEqual(responseMessage.minorVersion, 1)
    }

    func testParseHandshakeResponseWithError() throws {
        let responseString = "{\"error\":\"Some error\",\"minorVersion\":null}\u{1e}"
        let data = StringOrData.string(responseString)
        let (remainingData, responseMessage) = try HandshakeProtocol.parseHandshakeResponse(data: data)

        XCTAssertNil(remainingData)
        XCTAssertEqual(responseMessage.error, "Some error")
        XCTAssertNil(responseMessage.minorVersion)
    }

    func testParseHandshakeResponseWithIncompleteMessage() {
        let responseString = "{\"error\":null,\"minorVersion\":1}"
        let data = StringOrData.string(responseString)

        XCTAssertThrowsError(try HandshakeProtocol.parseHandshakeResponse(data: data)) { error in
            XCTAssertEqual(error as? SignalRError, SignalRError.incompleteMessage)
        }
    }

    func testParseHandshakeResponseWithNormalMessage() {
        let responseString = "{\"type\":1,\"target\":\"Send\",\"arguments\":[]}\u{1e}"
        let data = StringOrData.string(responseString)

        XCTAssertThrowsError(try HandshakeProtocol.parseHandshakeResponse(data: data)) { error in
            XCTAssertEqual(error as? SignalRError, SignalRError.expectedHandshakeResponse)
        }
    }
}


---
File: /Tests/SignalRClientTests/HubConnection+OnTests.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import XCTest
@testable import SignalRClient

final class HubConnectionOnTests: XCTestCase {
    let successHandshakeResponse = """
        {}\u{1e}
    """
    let errorHandshakeResponse = """
        {"error": "Sample error"}\u{1e}
    """

    var mockConnection: MockConnection!
    var logHandler: LogHandler!
    var hubProtocol: HubProtocol!
    var hubConnection: HubConnection!

    override func setUp() async throws {
        mockConnection = MockConnection()
        logHandler = MockLogHandler()
        hubProtocol = JsonHubProtocol()
        hubConnection = HubConnection(
            connection: mockConnection,
            logger: Logger(logLevel: .debug, logHandler: logHandler),
            hubProtocol: hubProtocol,
            retryPolicy: DefaultRetryPolicy(retryDelays: []), // No retry
            serverTimeout: nil,
            keepAliveInterval: nil,
            statefulReconnectBufferSize: nil
        )

        mockConnection.onSend = { data in
            Task { 
                guard let hubConnection = self.hubConnection else { return }
                await hubConnection.processIncomingData(.string(self.successHandshakeResponse)) 
            } // only success the first time
        }

        try await hubConnection.start()
    }

    override func tearDown() {
        hubConnection = nil
        super.tearDown()
    }

    func testOnNoArgs() async throws {
        let expectation = self.expectation(description: "Handler called")
        await hubConnection.on("testMethod") {
            expectation.fulfill()
        }

        await hubConnection.dispatchMessage(InvocationMessage(target: "testMethod", arguments: AnyEncodableArray([]), streamIds: nil, headers: nil, invocationId: nil))
        await fulfillment(of: [expectation], timeout: 1)
    }

    func testOnAndOff() async throws {
        let expectation = self.expectation(description: "Handler called")
        expectation.isInverted = true
        await hubConnection.on("testMethod") {
            expectation.fulfill()
        }
        await hubConnection.off(method: "testMethod")

        await hubConnection.dispatchMessage(InvocationMessage(target: "testMethod", arguments: AnyEncodableArray([]), streamIds: nil, headers: nil, invocationId: nil))
        await fulfillment(of: [expectation], timeout: 1)
    }

    func testOnOneArg() async throws {
        let expectation = self.expectation(description: "Handler called")
        await hubConnection.on("testMethod") { (arg: Int) in
            XCTAssertEqual(arg, 42)
            expectation.fulfill()
        }
        await hubConnection.dispatchMessage(InvocationMessage(target: "testMethod", arguments: AnyEncodableArray([42]), streamIds: nil, headers: nil, invocationId: nil))
        await fulfillment(of: [expectation], timeout: 1)
    }

    func testOnOneArg_WrongType() async throws {
        let expectation = self.expectation(description: "Handler called")
        expectation.isInverted = true
        await hubConnection.on("testMethod") { (arg: Int) in
            XCTAssertEqual(arg, 42)
            expectation.fulfill()
        }
        await hubConnection.dispatchMessage(InvocationMessage(target: "testMethod", arguments: AnyEncodableArray(["42"]), streamIds: nil, headers: nil, invocationId: nil))

        await fulfillment(of: [expectation], timeout: 1)
    }

    func testOnTwoArgs() async throws {
        let expectation = self.expectation(description: "Handler called")
        await hubConnection.on("testMethod") { (arg1: Int, arg2: String) in
            XCTAssertEqual(arg1, 42)
            XCTAssertEqual(arg2, "test")
            expectation.fulfill()
        }
        await hubConnection.dispatchMessage(InvocationMessage(target: "testMethod", arguments: AnyEncodableArray([42, "test"]), streamIds: nil, headers: nil, invocationId: nil))
        await fulfillment(of: [expectation], timeout: 1)
    }

    func testOnThreeArgs() async throws {
        let expectation = self.expectation(description: "Handler called")
        await hubConnection.on("testMethod") { (arg1: Int, arg2: String, arg3: Bool) in
            XCTAssertEqual(arg1, 42)
            XCTAssertEqual(arg2, "test")
            XCTAssertEqual(arg3, true)
            expectation.fulfill()
        }
        await hubConnection.dispatchMessage(InvocationMessage(target: "testMethod", arguments: AnyEncodableArray([42, "test", true]), streamIds: nil, headers: nil, invocationId: nil))
        await fulfillment(of: [expectation], timeout: 1)
    }

    func testOnFourArgs() async throws {
        let expectation = self.expectation(description: "Handler called")
        await hubConnection.on("testMethod") { (arg1: Int, arg2: String, arg3: Bool, arg4: Double) in
            XCTAssertEqual(arg1, 42)
            XCTAssertEqual(arg2, "test")
            XCTAssertEqual(arg3, true)
            XCTAssertEqual(arg4, 3.14)
            expectation.fulfill()
        }
        await hubConnection.dispatchMessage(InvocationMessage(target: "testMethod", arguments: AnyEncodableArray([42, "test", true, 3.14]), streamIds: nil, headers: nil, invocationId: nil))
        await fulfillment(of: [expectation], timeout: 1)
    }

    func testOnFiveArgs() async throws {
        let expectation = self.expectation(description: "Handler called")
        await hubConnection.on("testMethod") { (arg1: Int, arg2: String, arg3: Bool, arg4: Double, arg5: Double) in
            XCTAssertEqual(arg1, 42)
            XCTAssertEqual(arg2, "test")
            XCTAssertEqual(arg3, true)
            XCTAssertEqual(arg4, 3.14)
            XCTAssertEqual(arg5, 2.71)
            expectation.fulfill()
        }
        await hubConnection.dispatchMessage(InvocationMessage(target: "testMethod", arguments: AnyEncodableArray([42, "test", true, 3.14, 2.71]), streamIds: nil, headers: nil, invocationId: nil))
        await fulfillment(of: [expectation], timeout: 1)
    }

    func testOnSixArgs() async throws {
        let expectation = self.expectation(description: "Handler called")
        await hubConnection.on("testMethod") { (arg1: Int, arg2: String, arg3: Bool, arg4: Double, arg5: Double, arg6: Int) in
            XCTAssertEqual(arg1, 42)
            XCTAssertEqual(arg2, "test")
            XCTAssertEqual(arg3, true)
            XCTAssertEqual(arg4, 3.14)
            XCTAssertEqual(arg5, 2.71)
            XCTAssertEqual(arg6, 99)
            expectation.fulfill()
        }
        await hubConnection.dispatchMessage(InvocationMessage(target: "testMethod", arguments: AnyEncodableArray([42, "test", true, 3.14, 2.71, 99]), streamIds: nil, headers: nil, invocationId: nil))
        await fulfillment(of: [expectation], timeout: 1)
    }

    func testOnSevenArgs() async throws {
        let expectation = self.expectation(description: "Handler called")
        await hubConnection.on("testMethod") { (arg1: Int, arg2: String, arg3: Bool, arg4: Double, arg5: Double, arg6: Int, arg7: String) in
            XCTAssertEqual(arg1, 42)
            XCTAssertEqual(arg2, "test")
            XCTAssertEqual(arg3, true)
            XCTAssertEqual(arg4, 3.14)
            XCTAssertEqual(arg5, 2.71)
            XCTAssertEqual(arg6, 99)
            XCTAssertEqual(arg7, "end")
            expectation.fulfill()
        }
        await hubConnection.dispatchMessage(InvocationMessage(target: "testMethod", arguments: AnyEncodableArray([42, "test", true, 3.14, 2.71, 99, "end"]), streamIds: nil, headers: nil, invocationId: nil))
        await fulfillment(of: [expectation], timeout: 1)
    }

    func testOnEightArgs() async throws {
        let expectation = self.expectation(description: "Handler called")
        await hubConnection.on("testMethod") { (arg1: Int, arg2: String, arg3: Bool, arg4: Double, arg5: Double, arg6: Int, arg7: String, arg8: Bool) in
            XCTAssertEqual(arg1, 42)
            XCTAssertEqual(arg2, "test")
            XCTAssertEqual(arg3, true)
            XCTAssertEqual(arg4, 3.14)
            XCTAssertEqual(arg5, 2.71)
            XCTAssertEqual(arg6, 99)
            XCTAssertEqual(arg7, "end")
            XCTAssertEqual(arg8, false)
            expectation.fulfill()
        }
        await hubConnection.dispatchMessage(InvocationMessage(target: "testMethod", arguments: AnyEncodableArray([42, "test", true, 3.14, 2.71, 99, "end", false]), streamIds: nil, headers: nil, invocationId: nil))
        await fulfillment(of: [expectation], timeout: 1)
    }

    func testOnNineArgs() async throws {
        let expectation = self.expectation(description: "Handler called")
        await hubConnection.on("testMethod") { (arg1: Int, arg2: String, arg3: Bool, arg4: Double, arg5: Double, arg6: Int, arg7: String, arg8: Bool, arg9: Int) in
            XCTAssertEqual(arg1, 42)
            XCTAssertEqual(arg2, "test")
            XCTAssertEqual(arg3, true)
            XCTAssertEqual(arg4, 3.14)
            XCTAssertEqual(arg5, 2.71)
            XCTAssertEqual(arg6, 99)
            XCTAssertEqual(arg7, "end")
            XCTAssertEqual(arg8, false)
            XCTAssertEqual(arg9, 100)
            expectation.fulfill()
        }
        await hubConnection.dispatchMessage(InvocationMessage(target: "testMethod", arguments: AnyEncodableArray([42, "test", true, 3.14, 2.71, 99, "end", false, 100]), streamIds: nil, headers: nil, invocationId: nil))
        await fulfillment(of: [expectation], timeout: 1)
    }
}


---
File: /Tests/SignalRClientTests/HubConnectionTests.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation
import XCTest
@testable import SignalRClient

class MockConnection: ConnectionProtocol, @unchecked Sendable {
    var inherentKeepAlive: Bool = false

    var onReceive: Transport.OnReceiveHandler?
    var onClose: Transport.OnCloseHander?
    var onSend: ((StringOrData) -> Void)?
    var onStart: (() -> Void)?
    var onStop: ((Error?) -> Void)?

    private(set) var startCalled = false
    private(set) var sendCalled = false
    private(set) var stopCalled = false
    private(set) var sentData: StringOrData?

    func start(transferFormat: TransferFormat) async throws {
        startCalled = true
        onStart?()
    }

    func send(_ data: StringOrData) async throws {
        sendCalled = true
        sentData = data
        onSend?(data)
    }

    func stop(error: Error?) async {
        stopCalled = true
        onStop?(error)
    }

    func onReceive(_ handler: @escaping @Sendable (SignalRClient.StringOrData) async -> Void) async {
        onReceive = handler
    }

    func onClose(_ handler: @escaping @Sendable ((any Error)?) async -> Void) async {
        onClose = handler
    }
}

final class HubConnectionTests: XCTestCase {
    let successHandshakeResponse = """
        {}\u{1e}
    """
    let errorHandshakeResponse = """
        {"error": "Sample error"}\u{1e}
    """

    var mockConnection: MockConnection!
    var logHandler: LogHandler!
    var hubProtocol: HubProtocol!
    var hubConnection: HubConnection!

    override func setUp() async throws {
        mockConnection = MockConnection()
        logHandler = MockLogHandler()
        hubProtocol = JsonHubProtocol()
        hubConnection = HubConnection(
            connection: mockConnection,
            logger: Logger(logLevel: .debug, logHandler: logHandler),
            hubProtocol: hubProtocol,
            retryPolicy: DefaultRetryPolicy(retryDelays: []), // No retry
            serverTimeout: nil,
            keepAliveInterval: nil,
            statefulReconnectBufferSize: nil
        )
    }

    func testStart_CallsStartOnConnection() async throws {
        // Act
        let expectation = XCTestExpectation(description: "send() should be called")

        mockConnection.onSend = { data in
            expectation.fulfill()
        }

        let task = Task {
            try await hubConnection.start()
        }

        // HubConnect start handshake
        await fulfillment(of: [expectation], timeout: 1.0)

        // Response a handshake response
        await hubConnection.processIncomingData(.string(successHandshakeResponse))

        await whenTaskWithTimeout({ try await task.value }, timeout: 1.0) 
        // Assert
        let state = await hubConnection.state()
        XCTAssertEqual(HubConnectionState.Connected, state)
    }

    func testStart_FailedHandshake() async throws {
        // Act
        let expectation = XCTestExpectation(description: "send() should be called")

        mockConnection.onSend = { data in
            expectation.fulfill()
        }

        let task = Task {
            try await hubConnection.start()
        }

        // HubConnect start handshake
        await fulfillment(of: [expectation], timeout: 1.0)

        // Response a handshake response
        await hubConnection.processIncomingData(.string(errorHandshakeResponse))

        _ = await whenTaskThrowsTimeout({ try await task.value }, timeout: 1.0) 
        // Assert
        let state = await hubConnection.state()
        XCTAssertEqual(HubConnectionState.Stopped, state)
    }

    func testStart_ConnectionCloseRightAfterHandshake() async throws {
        // Act
        let expectation = XCTestExpectation(description: "send() should be called")

        mockConnection.onSend = { data in
            expectation.fulfill()
        }

        let task = Task {
            try await hubConnection.start()
        }

        // HubConnect start handshake
        await fulfillment(of: [expectation], timeout: 1.0)

        // Close connection first
        await mockConnection.onClose?(nil)
        // Response a handshake response
        await hubConnection.processIncomingData(.string(successHandshakeResponse))

        let err = await whenTaskThrowsTimeout({ try await task.value }, timeout: 1.0)

        // Assert
        XCTAssertEqual(SignalRError.connectionAborted, err as? SignalRError)
        let state = await hubConnection.state()
        XCTAssertEqual(HubConnectionState.Stopped, state)
    }

    func testStart_DuplicateStart() async throws {
        // Act
        let expectation = XCTestExpectation(description: "send() should be called")

        mockConnection.onSend = { data in
            expectation.fulfill()
        }

        let task = Task {
            try await hubConnection.start()
        }

        defer { task.cancel() }

        // HubConnect start handshake
        await fulfillment(of: [expectation], timeout: 1.0)

        let err = await whenTaskThrowsTimeout({
            try await self.hubConnection.start()
        }, timeout: 1.0)

        XCTAssertEqual(SignalRError.invalidOperation("Start client while not in a stopped state."), err as? SignalRError)
    }

    func testStop_CallsStopDuringConnect() async throws {
        hubConnection = HubConnection(
            connection: mockConnection,
            logger: Logger(logLevel: .debug, logHandler: logHandler),
            hubProtocol: hubProtocol,
            retryPolicy: DefaultRetryPolicy(retryDelays: [1, 2, 3]), // Add some retry, but in this case, it shouldn't have effect
            serverTimeout: nil,
            keepAliveInterval: nil,
            statefulReconnectBufferSize: nil
        )

        let expectation = XCTestExpectation(description: "send() should be called")
        mockConnection.onSend = { data in
            expectation.fulfill()
        }

        let startTask = Task { try await hubConnection.start() }
        defer { startTask.cancel() }

        // HubConnect start handshake
        await fulfillment(of: [expectation], timeout: 1.0)

        // The moment start is waiting for handshake response but it should throw 
        await hubConnection.stop()

        let err = await whenTaskThrowsTimeout(startTask, timeout: 1.0)
        XCTAssertEqual(SignalRError.connectionAborted, err as? SignalRError)
    }

    func testStop_CallsStopDuringConnectAndAfterHandshakeResponse() async throws {
        hubConnection = HubConnection(
            connection: mockConnection,
            logger: Logger(logLevel: .debug, logHandler: logHandler),
            hubProtocol: hubProtocol,
            retryPolicy: DefaultRetryPolicy(retryDelays: []),
            serverTimeout: nil,
            keepAliveInterval: nil,
            statefulReconnectBufferSize: nil
        )

        let sendExpectation = XCTestExpectation(description: "send() should be called")
        let closeExpectation = XCTestExpectation(description: "close() should be called")
        mockConnection.onSend = { data in
            sendExpectation.fulfill()
        }

        mockConnection.onStop = { error in
            closeExpectation.fulfill()
        }

        let startTask = Task { try await hubConnection.start() }
        defer { startTask.cancel() }

        // HubConnect start handshake
        await fulfillment(of: [sendExpectation], timeout: 1.0)

        // Response a handshake response
        await hubConnection.processIncomingData(.string(successHandshakeResponse))
        await hubConnection.stop()

        // Two possible
        // 1. startTask throws
        // 2. connection.stop called
        do {
            try await startTask.value
            await fulfillment(of: [closeExpectation], timeout: 1.0)    
        } catch {
            XCTAssertEqual(SignalRError.connectionAborted, error as? SignalRError)
        }
    }

    func testReconnect_ExceedRetry() async throws {
        hubConnection = HubConnection(
            connection: mockConnection,
            logger: Logger(logLevel: .debug, logHandler: logHandler),
            hubProtocol: hubProtocol,
            retryPolicy: DefaultRetryPolicy(retryDelays: [0.1, 0.2, 0.3]), // Add some retry
            serverTimeout: nil,
            keepAliveInterval: nil,
            statefulReconnectBufferSize: nil
        )

        let sendExpectation = XCTestExpectation(description: "send() should be called")
        let openExpectations = [
            XCTestExpectation(description: "onOpen should be called 1"),
            XCTestExpectation(description: "onOpen should be called 2"),
            XCTestExpectation(description: "onOpen should be called 3"),
            XCTestExpectation(description: "onOpen should be called 4"),
        ]
        let closeEcpectation = XCTestExpectation(description: "close() should be called")
        var sendCount = 0
        mockConnection.onSend = { data in
            if (sendCount == 0) {
                sendCount += 1
                Task { await self.hubConnection.processIncomingData(.string(self.successHandshakeResponse)) } // only success the first time
            } else {
                Task { await self.hubConnection.processIncomingData(.string(self.errorHandshakeResponse)) } // for reconnect, it always fails
            }

            sendExpectation.fulfill()
        }

        var openCount = 0
        mockConnection.onStart = {
            openCount += 1
            if (openCount <= 4) {
                openExpectations[openCount - 1].fulfill()
            }
        }

        mockConnection.onClose = { error in
            closeEcpectation.fulfill()
        }

        let startTask = Task { try await hubConnection.start() }
        defer { startTask.cancel() }

        // HubConnect start handshake
        await fulfillment(of: [sendExpectation], timeout: 1.0)

        // Response a handshake response
        await whenTaskWithTimeout(startTask, timeout: 1.0)

        // Simulate connection close
        let handleCloseTask = Task { await hubConnection.handleConnectionClose(error: nil) }

        // retry will work and start will be called again
        await fulfillment(of: [openExpectations[1]], timeout: 1.0)

        await fulfillment(of: [openExpectations[2]], timeout: 1.0)

        await fulfillment(of: [openExpectations[3]], timeout: 1.0)

        // Retry failed
        await handleCloseTask.value
        let state = await hubConnection.state()
        XCTAssertEqual(state, HubConnectionState.Stopped)
    }

    func testReconnect_Success() async throws {
        hubConnection = HubConnection(
            connection: mockConnection,
            logger: Logger(logLevel: .debug, logHandler: logHandler),
            hubProtocol: hubProtocol,
            retryPolicy: DefaultRetryPolicy(retryDelays: [0.1, 0.2]), // Limited retries
            serverTimeout: nil,
            keepAliveInterval: nil,
            statefulReconnectBufferSize: nil
        )

        let sendExpectation = XCTestExpectation(description: "send() should be called")
        let openExpectations = [
            XCTestExpectation(description: "onOpen should be called 1"),
            XCTestExpectation(description: "onOpen should be called 2"),
            XCTestExpectation(description: "onOpen should be called 3"),
        ]
        var sendCount = 0
        mockConnection.onSend = { data in
            if (sendCount == 0) {
                Task { await self.hubConnection.processIncomingData(.string(self.successHandshakeResponse)) } // only success the first time
            } else if (sendCount == 1) {
                Task { await self.hubConnection.processIncomingData(.string(self.errorHandshakeResponse)) } // for the first reconnect, it fails
            } else {
                Task { await self.hubConnection.processIncomingData(.string(self.successHandshakeResponse)) } // for the second reconnect, it success
            }
            sendCount += 1
            sendExpectation.fulfill()
        }

        var openCount = 0
        mockConnection.onStart = {
            openCount += 1
            if (openCount <= 3) {
                openExpectations[openCount - 1].fulfill()
            }
        }

        let reconnectedExpectation = XCTestExpectation(description: "onReconnected() should be called")
        await hubConnection.onReconnected {
            reconnectedExpectation.fulfill()
        }

        let startTask = Task { try await hubConnection.start() }
        defer { startTask.cancel() }

        // HubConnect start handshake
        await fulfillment(of: [sendExpectation], timeout: 1.0)

        // Response a handshake response
        await whenTaskWithTimeout(startTask, timeout: 1.0)

        // Simulate connection close
        let handleCloseTask = Task { await hubConnection.handleConnectionClose(error: nil) }

        // retry will work and start will be called again
        await fulfillment(of: [openExpectations[1]], timeout: 1.0)

        await fulfillment(of: [openExpectations[2]], timeout: 1.0)

        // Retry success
        await handleCloseTask.value
        let state = await hubConnection.state()
        XCTAssertEqual(state, HubConnectionState.Connected)
        await fulfillment(of: [reconnectedExpectation], timeout: 1.0)
    }

    func testReconnect_CustomPolicy() async throws {
        class CustomRetryPolicy: RetryPolicy, @unchecked Sendable {
            func nextRetryInterval(retryContext: SignalRClient.RetryContext) -> TimeInterval? {
                return onRetry?(retryContext)
            }

            var onRetry: ((RetryContext) -> TimeInterval?)?
        }

        class CustomError: Error, @unchecked Sendable {}
        let retryPolicy = CustomRetryPolicy()

        hubConnection = HubConnection(
            connection: mockConnection,
            logger: Logger(logLevel: .debug, logHandler: logHandler),
            hubProtocol: hubProtocol,
            retryPolicy: retryPolicy, // Limited retries
            serverTimeout: nil,
            keepAliveInterval: nil,
            statefulReconnectBufferSize: nil
        )

        let sendExpectation = XCTestExpectation(description: "send() should be called")
        var sendCount = 0
        mockConnection.onSend = { data in
            if (sendCount == 0) {
                Task { await self.hubConnection.processIncomingData(.string(self.successHandshakeResponse)) } // only success the first time
            } else {
                Task { await self.hubConnection.processIncomingData(.string(self.errorHandshakeResponse)) } // for the first reconnect, it fails
            }
            sendCount += 1
            sendExpectation.fulfill()
        }

        let startTask = Task { try await hubConnection.start() }
        defer { startTask.cancel() }

        // HubConnect start handshake
        await fulfillment(of: [sendExpectation], timeout: 1.0)

        // Response a handshake response
        await whenTaskWithTimeout(startTask, timeout: 1.0)

        let retryExpectations = [
            XCTestExpectation(description: "retry should be called 1"),
            XCTestExpectation(description: "retry should be called 2"),
            XCTestExpectation(description: "retry should be called 3"),
        ]
        var retryCount = 0
        var previousElaped: TimeInterval = 0
        retryPolicy.onRetry = { retryContext in
            if (retryCount == 0) {
                XCTAssert(retryContext.retryReason is CustomError)
                XCTAssertEqual(retryContext.elapsed, 0)
                XCTAssertEqual(retryContext.retryCount, 0)
            } else {
                XCTAssertEqual(retryContext.retryCount, retryCount)
                XCTAssert(previousElaped < retryContext.elapsed)
                XCTAssert(retryContext.retryReason is SignalRError)
            }
            if (retryCount < 3) {
                retryExpectations[retryCount].fulfill()
            }
            retryCount += 1
            previousElaped = retryContext.elapsed
            return 0.1
        }

        let reconnectingExpectations = [
            XCTestExpectation(description: "reconnecting should be called 1"),
            XCTestExpectation(description: "reconnecting should be called 2"),
            XCTestExpectation(description: "reconnecting should be called 3"),
        ]
        var reconnectingCount = 0
        await hubConnection.onReconnecting { error in
            if (reconnectingCount < 3) {
                reconnectingExpectations[reconnectingCount].fulfill()
            }
            reconnectingCount += 1
        }

        // Simulate connection close
        let handleCloseTask = Task { await hubConnection.handleConnectionClose(error: CustomError()) }

        // retry will work and start will be called again
        await fulfillment(of: [retryExpectations[0]], timeout: 1.0)
        await fulfillment(of: [reconnectingExpectations[0]], timeout: 1.0)
        await fulfillment(of: [retryExpectations[1]], timeout: 1.0)
        await fulfillment(of: [reconnectingExpectations[1]], timeout: 1.0)
        await fulfillment(of: [retryExpectations[2]], timeout: 1.0)
        await fulfillment(of: [reconnectingExpectations[2]], timeout: 1.0)

        await hubConnection.stop()

        // Retry success
        await handleCloseTask.value
        let state = await hubConnection.state()
        XCTAssertEqual(state, HubConnectionState.Stopped)
    }

    func testKeepAlive() async throws {
        let keepAliveInterval: TimeInterval = 0.1
        hubConnection = HubConnection(
            connection: mockConnection,
            logger: Logger(logLevel: .debug, logHandler: logHandler),
            hubProtocol: hubProtocol,
            retryPolicy: DefaultRetryPolicy(retryDelays: []), // No retry
            serverTimeout: nil,
            keepAliveInterval: keepAliveInterval,
            statefulReconnectBufferSize: nil
        )

        let handshakeExpectation = XCTestExpectation(description: "handshake should be called")
        let pingExpectations = [
            XCTestExpectation(description: "ping should be called"),
            XCTestExpectation(description: "ping should be called"),
            XCTestExpectation(description: "ping should be called")
        ]
        var sendCount = 0
        mockConnection.onSend = { data in
            do {
                let messages = try self.hubProtocol.parseMessages(input: data, binder: TestInvocationBinder(binderTypes: []))
                for message in messages {
                    if let pingMessage = message as? PingMessage {
                        if sendCount < pingExpectations.count {
                            pingExpectations[sendCount].fulfill()
                        }
                        sendCount += 1
                        return
                    }
                }
                handshakeExpectation.fulfill()
                Task { await self.hubConnection.processIncomingData(.string(self.successHandshakeResponse)) } // only success the first time
            } catch {
                XCTFail("Unexpected error: \(error)")
            }

        }

        let startTask = Task { try await hubConnection.start() }
        defer { startTask.cancel() }

        // HubConnect start handshake
        await fulfillment(of: [handshakeExpectation], timeout: 1.0)

        // Response a handshake response
        await whenTaskWithTimeout(startTask, timeout: 1.0)

        // Send keepalive after connect
        await fulfillment(of: [pingExpectations[0], pingExpectations[1], pingExpectations[2]], timeout: 1.0)
    }

    func serverTimeoutTest() async throws {
        hubConnection = HubConnection(
            connection: mockConnection,
            logger: Logger(logLevel: .debug, logHandler: logHandler),
            hubProtocol: hubProtocol,
            retryPolicy: DefaultRetryPolicy(retryDelays: []), // No retry
            serverTimeout: 0.1,
            keepAliveInterval: 99,
            statefulReconnectBufferSize: nil
        )

        let handshakeExpectation = XCTestExpectation(description: "handshake should be called")
        let closeExpectation = XCTestExpectation(description: "close should be called")
        mockConnection.onSend = { data in
            handshakeExpectation.fulfill()
            Task { await self.hubConnection.processIncomingData(.string(self.successHandshakeResponse)) } // only success the first time
        }

        mockConnection.onClose = { error in
            closeExpectation.fulfill()
            XCTAssert(error as! SignalRError == SignalRError.serverTimeout(0.1))
        }

        let startTask = Task { try await hubConnection.start() }
        defer { startTask.cancel() }

        // HubConnect start handshake
        await fulfillment(of: [handshakeExpectation], timeout: 1.0)

        // Response a handshake response
        await whenTaskWithTimeout(startTask, timeout: 1.0)

        // Send keepalive after connect
        await fulfillment(of: [closeExpectation], timeout: 1.0)
    }

    func testSend() async throws {
        // Arrange
        let expectation = XCTestExpectation(description: "send() should be called")
        mockConnection.onSend = { data in
            expectation.fulfill()
        }

        let task = Task {
            try await hubConnection.start()
        }

        // HubConnect start handshake
        await fulfillment(of: [expectation], timeout: 1.0)

        // Response a handshake response
        await hubConnection.processIncomingData(.string(successHandshakeResponse))

        await whenTaskWithTimeout({ try await task.value }, timeout: 1.0)

        // Act
        let sendExpectation = XCTestExpectation(description: "send() should be called")
        mockConnection.onSend = { data in
            sendExpectation.fulfill()
        }
        let (clientStream, continuation)  = AsyncStream.makeStream(of: Int.self)
       
        let sendTask = Task {
            try await hubConnection.send(method: "testMethod", arguments: "arg1", "arg2", clientStream)
        }

        await fulfillment(of: [sendExpectation], timeout: 1.0)

        // Assert
        await whenTaskWithTimeout(sendTask, timeout: 1.0)
        
        var count = 0
        let streamExpectation = XCTestExpectation(description: "clientStream should trigger send 10 times")
        mockConnection.onSend = { data in
            count += 1
            if count == 10 {
                streamExpectation.fulfill()
            } 
        }

        for i in 0 ..< 9 {
            continuation.yield(i)
        }
        continuation.finish()
        // Assert
        await fulfillment(of: [streamExpectation], timeout: 1.0)
        mockConnection.onSend = nil
    }

    func testInvoke_Success() async throws {
        // Arrange
        let expectation = XCTestExpectation(description: "send() should be called")
        let expectedResult = "result"
        mockConnection.onSend = { data in
            expectation.fulfill()
        }

        let task = Task {
            try await hubConnection.start()
        }

        // HubConnect start handshake
        await fulfillment(of: [expectation], timeout: 1.0)

        // Response a handshake response
        await hubConnection.processIncomingData(.string(successHandshakeResponse))

        await whenTaskWithTimeout({ try await task.value }, timeout: 1.0)

        // Act
        let invokeExpectation = XCTestExpectation(description: "invoke() should be called")
        mockConnection.onSend = { data in
            invokeExpectation.fulfill()
        }

        let invokeTask = Task {
            let result: String = try await hubConnection.invoke(method: "testMethod", arguments: "arg1", "arg2")
            XCTAssertEqual(result, expectedResult)
        }

        await fulfillment(of: [invokeExpectation], timeout: 1.0)

        // Simulate server response
        let invocationId = "1"
        let completionMessage = CompletionMessage(invocationId: invocationId, error: nil, result: AnyEncodable(expectedResult), headers: nil)
        await hubConnection.processIncomingData(try hubProtocol.writeMessage(message: completionMessage))

        // Assert
        await whenTaskWithTimeout(invokeTask, timeout: 1.0)
    }

    func testInvoke_Success_Void() async throws {
        // Arrange
        let expectation = XCTestExpectation(description: "send() should be called")
        mockConnection.onSend = { data in
            expectation.fulfill()
        }

        let task = Task {
            try await hubConnection.start()
        }

        // HubConnect start handshake
        await fulfillment(of: [expectation], timeout: 1.0)

        // Response a handshake response
        await hubConnection.processIncomingData(.string(successHandshakeResponse))

        await whenTaskWithTimeout({ try await task.value }, timeout: 1.0)

        // Act
        let invokeExpectation = XCTestExpectation(description: "invoke() should be called")
        mockConnection.onSend = { data in
            invokeExpectation.fulfill()
        }

        let invokeTask = Task {
            try await hubConnection.invoke(method: "testMethod", arguments: "arg1", "arg2")
        }

        await fulfillment(of: [invokeExpectation], timeout: 1.0)

        // Simulate server response
        let invocationId = "1"
        let completionMessage = CompletionMessage(invocationId: invocationId, error: nil, result: AnyEncodable(nil), headers: nil)
        await hubConnection.processIncomingData(try hubProtocol.writeMessage(message: completionMessage))

        // Assert
        await whenTaskWithTimeout(invokeTask, timeout: 1.0)
    }

    func testInvokeWithWrongReturnType() async throws {
        let expectation = XCTestExpectation(description: "send() should be called")
        let expectedResult = "result"
        mockConnection.onSend = { data in
            expectation.fulfill()
        }

        let task = Task {
            try await hubConnection.start()
        }

        // HubConnect start handshake
        await fulfillment(of: [expectation], timeout: 1.0)

        // Response a handshake response
        await hubConnection.processIncomingData(.string(successHandshakeResponse))

        await whenTaskWithTimeout({ try await task.value }, timeout: 1.0)

        // Act
        let invokeExpectation = XCTestExpectation(description: "invoke() should be called")
        mockConnection.onSend = { data in
            invokeExpectation.fulfill()
        }

        let invokeTask = Task {
            let s: Int = try await self.hubConnection.invoke(method: "testMethod", arguments: "arg1", "arg2")
        }

        await fulfillment(of: [invokeExpectation], timeout: 1.0)

        // Simulate server response
        let invocationId = "1"
        let completionMessage = CompletionMessage(invocationId: invocationId, error: nil, result: AnyEncodable(expectedResult), headers: nil)
        await hubConnection.processIncomingData(try hubProtocol.writeMessage(message: completionMessage))

        // Assert
        let error = await whenTaskThrowsTimeout(invokeTask, timeout: 1.0)
        XCTAssertEqual(error as? SignalRError, SignalRError.invalidOperation("Cannot convert the result of the invocation to the specified type."))
    }

    func testInvoke_Failure() async throws {
        // Arrange
        let expectation = XCTestExpectation(description: "send() should be called")
        let expectedError = SignalRError.invocationError("Sample error")
        mockConnection.onSend = { data in
            expectation.fulfill()
        }

        let task = Task {
            try await hubConnection.start()
        }

        // HubConnect start handshake
        await fulfillment(of: [expectation], timeout: 1.0)

        // Response a handshake response
        await hubConnection.processIncomingData(.string(successHandshakeResponse))

        await whenTaskWithTimeout({ try await task.value }, timeout: 1.0)

        // Act
        let invokeExpectation = XCTestExpectation(description: "invoke() should be called")
        mockConnection.onSend = { data in
            invokeExpectation.fulfill()
        }

        let invokeTask = Task {
            do {
                let _: String = try await hubConnection.invoke(method: "testMethod", arguments: "arg1", "arg2")
                XCTFail("Expected error not thrown")
            } catch {
                XCTAssertEqual(error as? SignalRError, expectedError)
            }
        }

        await fulfillment(of: [invokeExpectation], timeout: 1.0)
        // Simulate server response
        let invocationId = "1"
        let completionMessage = CompletionMessage(invocationId: invocationId, error: "Sample error", result: AnyEncodable(nil), headers: nil)
        await hubConnection.processIncomingData(try hubProtocol.writeMessage(message: completionMessage))

        // Assert
        await whenTaskWithTimeout(invokeTask, timeout: 1.0)
    }

    func testStream_Success() async throws {
        // Arrange
        let expectation = XCTestExpectation(description: "send() should be called")
        let expectedResults = ["result1", "result2", "result3", "result4"]
        mockConnection.onSend = { data in
            expectation.fulfill()
        }

        let task = Task {
            try await hubConnection.start()
        }

        // HubConnect start handshake
        await fulfillment(of: [expectation], timeout: 1.0)

        // Response a handshake response
        await hubConnection.processIncomingData(.string(successHandshakeResponse))

        await whenTaskWithTimeout({ try await task.value }, timeout: 1.0)

        // Act
        let invokeExpectation = XCTestExpectation(description: "stream() should be called")
        mockConnection.onSend = { data in
            invokeExpectation.fulfill()
        }

        let invokeTask = Task {
            let stream: any StreamResult<String> = try await hubConnection.stream(method: "testMethod", arguments: "arg1", "arg2")
            var i = 0
            for try await element in stream.stream {
                XCTAssertEqual(element, expectedResults[i])
                i += 1
            }
        }

        await fulfillment(of: [invokeExpectation], timeout: 1.0)

        // Simulate server stream back
        let invocationId = "1"
        let streamItemMessage1 = StreamItemMessage(invocationId: invocationId, item: AnyEncodable("result1"), headers: nil)
        await hubConnection.processIncomingData(try hubProtocol.writeMessage(message: streamItemMessage1))
        let streamItemMessage2 = StreamItemMessage(invocationId: invocationId, item: AnyEncodable("result2"), headers: nil)
        await hubConnection.processIncomingData(try hubProtocol.writeMessage(message: streamItemMessage2))
        let streamItemMessage3 = StreamItemMessage(invocationId: invocationId, item: AnyEncodable("result3"), headers: nil)
        await hubConnection.processIncomingData(try hubProtocol.writeMessage(message: streamItemMessage3))
        let completionMessage = CompletionMessage(invocationId: invocationId, error: nil, result: AnyEncodable("result4"), headers: nil)
        await hubConnection.processIncomingData(try hubProtocol.writeMessage(message: completionMessage))

        // Assert
        await whenTaskWithTimeout(invokeTask, timeout: 1.0)
    }

    func testStream_Failed_WrongType() async throws {
        // Arrange
        let expectation = XCTestExpectation(description: "send() should be called")
        mockConnection.onSend = { data in
            expectation.fulfill()
        }

        let task = Task {
            try await hubConnection.start()
        }

        // HubConnect start handshake
        await fulfillment(of: [expectation], timeout: 1.0)

        // Response a handshake response
        await hubConnection.processIncomingData(.string(successHandshakeResponse))

        await whenTaskWithTimeout({ try await task.value }, timeout: 1.0)

        // Act
        let invokeExpectation = XCTestExpectation(description: "stream() should be called")
        mockConnection.onSend = { data in
            invokeExpectation.fulfill()
        }

        let invokeTask = Task {
            let stream: any StreamResult<String> = try await hubConnection.stream(method: "testMethod", arguments: "arg1", "arg2")
            for try await _ in stream.stream {
            }
        }

        await fulfillment(of: [invokeExpectation], timeout: 1.0)

        // Simulate server stream back
        let invocationId = "1"
        let streamItemMessage1 = StreamItemMessage(invocationId: invocationId, item: AnyEncodable(123), headers: nil)
        await hubConnection.processIncomingData(try hubProtocol.writeMessage(message: streamItemMessage1))

        // Assert
        let error = await whenTaskThrowsTimeout(invokeTask, timeout: 1.0)
        XCTAssertEqual(error as? SignalRError, SignalRError.invalidOperation("Cannot convert the result of the invocation to the specified type."))
    }

    func testStream_Cancel() async throws {
        // Arrange
        let expectation = XCTestExpectation(description: "send() should be called")
        mockConnection.onSend = { data in
            expectation.fulfill()
        }

        let task = Task {
            try await hubConnection.start()
        }

        // HubConnect start handshake
        await fulfillment(of: [expectation], timeout: 1.0)

        // Response a handshake response
        await hubConnection.processIncomingData(.string(successHandshakeResponse))

        await whenTaskWithTimeout({ try await task.value }, timeout: 1.0)

        // Act
        let invokeExpectation = XCTestExpectation(description: "stream() should be called")
        mockConnection.onSend = { data in
            invokeExpectation.fulfill()
        }

        let stream: any StreamResult<String> = try await hubConnection.stream(method: "testMethod", arguments: "arg1", "arg2")
        await fulfillment(of: [invokeExpectation], timeout: 1.0)

        let cancelExpectation = XCTestExpectation(description: "send() should be called to send cancel")
        mockConnection.onSend = { data in
            cancelExpectation.fulfill()
        }

        await stream.cancel()
        await fulfillment(of: [cancelExpectation], timeout: 1.0)

        // After cancel, more data to the stream should be ignored
        let invocationId = "1"
        let streamItemMessage1 = StreamItemMessage(invocationId: invocationId, item: AnyEncodable(123), headers: nil)
        await hubConnection.processIncomingData(try hubProtocol.writeMessage(message: streamItemMessage1))
    }

    func whenTaskWithTimeout(_ task: Task<Void, Error>, timeout: TimeInterval) async -> Void {
        return await whenTaskWithTimeout({ try await task.value }, timeout: timeout)
    }

    func whenTaskWithTimeout(_ task: Task<Void, Never>, timeout: TimeInterval) async -> Void {
        return await whenTaskWithTimeout({ await task.value }, timeout: timeout)
    }

    func whenTaskWithTimeout(_ task: @escaping () async throws -> Void, timeout: TimeInterval) async -> Void {
        let expectation = XCTestExpectation(description: "Task should complete")
        let wrappedTask = Task {
            _ = try await task()
            expectation.fulfill()
        }
        defer { wrappedTask.cancel() }

        await fulfillment(of: [expectation], timeout: timeout)
    }

    func whenTaskThrowsTimeout(_ task: Task<Void, Error>, timeout: TimeInterval) async -> Error? {
        return await whenTaskThrowsTimeout({ try await task.value }, timeout: timeout)
    }

    func whenTaskThrowsTimeout(_ task: @escaping () async throws -> Void, timeout: TimeInterval) async -> Error? {
        let returnErr: ValueContainer<Error> = ValueContainer()
        let expectation = XCTestExpectation(description: "Task should throw")
        let wrappedTask = Task {
            do {
                _ = try await task()
            } catch {
                await returnErr.update(error)
                expectation.fulfill()
            }
        }
        defer { wrappedTask.cancel() }

        await fulfillment(of: [expectation], timeout: timeout)

        return await returnErr.get()
    }

    private actor ValueContainer<T> {
        private var value: T?

        func update(_ newValue: T?) {
            value = newValue
        }

        func get() -> T? {
            return value
        }
    }
}



---
File: /Tests/SignalRClientTests/JsonHubProtocolTests.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import XCTest
@testable import SignalRClient

final class JsonHubProtocolTests: XCTestCase {
    let emptyBinder: InvocationBinder = TestInvocationBinder(binderTypes: [])
    var jsonHubProtocol: JsonHubProtocol!

    override func setUp() {
        super.setUp()
        jsonHubProtocol = JsonHubProtocol()
    }

    override func tearDown() {
        jsonHubProtocol = nil
        super.tearDown()
    }

    func testParseInvocationMessage() throws {
        let input = "{\"type\": 1, \"target\": \"testTarget\", \"arguments\": [\"arg1\", 123]}\(TextMessageFormat.recordSeparator)" // JSON format for InvocationMessage
        let binder = TestInvocationBinder(binderTypes: [String.self, Int.self])
        let messages = try jsonHubProtocol.parseMessages(input: .string(input), binder: binder)

        XCTAssertEqual(messages.count, 1)
        XCTAssertTrue(messages[0] is InvocationMessage)
        let msg = messages[0] as! InvocationMessage
        XCTAssertEqual("testTarget", msg.target)
        XCTAssertEqual(2, msg.arguments.value!.count)
        XCTAssertEqual("arg1", msg.arguments.value![0] as! String)
        XCTAssertEqual(123, msg.arguments.value![1] as! Int)
        XCTAssertNil(msg.invocationId)
        XCTAssertNil(msg.streamIds)
    }

    func testParseInvocationMessageWithCustomizedClass() throws {
        let input = "{\"type\": 1, \"target\": \"testTarget\", \"arguments\": [123, {\"stringVal\": \"str\", \"intVal\": 12345, \"boolVal\": true, \"doubleVal\": 3.14, \"arrayVal\": [\"str2\"], \"dictVal\": {\"key2\": \"str3\"}}]}\(TextMessageFormat.recordSeparator)" // JSON format for InvocationMessage
        let binder = TestInvocationBinder(binderTypes: [Int.self, CustomizedClass.self])
        let messages = try jsonHubProtocol.parseMessages(input: .string(input), binder: binder)

        XCTAssertEqual(messages.count, 1)
        XCTAssertTrue(messages[0] is InvocationMessage)
        let msg = messages[0] as! InvocationMessage
        XCTAssertEqual("testTarget", msg.target)
        XCTAssertEqual(2, msg.arguments.value!.count)
        XCTAssertEqual(123, msg.arguments.value![0] as! Int)
        guard let customizedClass = msg.arguments.value![1] as? CustomizedClass else {
            XCTFail("Expected CustomizedClass")
            return
        }
        XCTAssertEqual("str", customizedClass.stringVal)
        XCTAssertEqual(12345, customizedClass.intVal)
        XCTAssertEqual(true, customizedClass.boolVal)
        XCTAssertEqual(3.14, customizedClass.doubleVal)
        XCTAssertEqual(1, customizedClass.arrayVal!.count)
        XCTAssertEqual("str2", customizedClass.arrayVal![0])
        XCTAssertEqual("str3", customizedClass.dictVal!["key2"])
        XCTAssertNil(msg.invocationId)
        XCTAssertNil(msg.streamIds)
    }

    func testParseInvocationMessageWithSomePropertyOptional() throws {
        let input = "{\"type\": 1, \"target\": \"testTarget\", \"arguments\": [{\"nokey\":123, \"stringVal\":\"val\"}]}\(TextMessageFormat.recordSeparator)" // JSON format for InvocationMessage
        let binder = TestInvocationBinder(binderTypes: [CustomizedClass.self])
        let messages = try jsonHubProtocol.parseMessages(input: .string(input), binder: binder)

        XCTAssertEqual(messages.count, 1)
        XCTAssertTrue(messages[0] is InvocationMessage)
        let msg = messages[0] as! InvocationMessage
        XCTAssertEqual("testTarget", msg.target)
        guard let customizedClass = msg.arguments.value![0] as? CustomizedClass else {
            XCTFail("Expected CustomizedClass")
            return
        }
        XCTAssertEqual("val", customizedClass.stringVal)
        XCTAssertNil(msg.invocationId)
        XCTAssertNil(msg.streamIds)
    }

    private class CustomizedClass: Codable {
        var stringVal: String
        var intVal: Int?
        var boolVal: Bool?
        var doubleVal: Double?
        var arrayVal: [String]?
        var dictVal: [String: String]?
    }

    func testParseInvocationMessageWithArrayElement() throws {
        let input = "{\"type\": 1, \"target\": \"testTarget\", \"arguments\": [\"arg1\", [123, 345, 456]]}\(TextMessageFormat.recordSeparator)" // JSON format for InvocationMessage
        let binder = TestInvocationBinder(binderTypes: [String.self, [Int].self])
        let messages = try jsonHubProtocol.parseMessages(input: .string(input), binder: binder)

        XCTAssertEqual(messages.count, 1)
        XCTAssertTrue(messages[0] is InvocationMessage)
        let msg = messages[0] as! InvocationMessage
        XCTAssertEqual("testTarget", msg.target)
        XCTAssertEqual(2, msg.arguments.value!.count)
        XCTAssertEqual("arg1", msg.arguments.value![0] as! String)
        guard let array = msg.arguments.value![1] as? [Int] else {
            XCTFail("Expected [Int]")
            return
        }
        XCTAssertEqual(3, array.count)
        XCTAssertEqual(123, array[0])
        XCTAssertEqual(345, array[1])
        XCTAssertEqual(456, array[2])
        XCTAssertNil(msg.invocationId)
        XCTAssertNil(msg.streamIds)
    }

    func testParseInvocationMessageWithArrayCusomizedClass() throws {
        let input = "{\"type\": 1, \"target\": \"testTarget\", \"arguments\": [\"arg1\", [{\"stringVal\":\"val\"}]]}\(TextMessageFormat.recordSeparator)" // JSON format for InvocationMessage
        let binder = TestInvocationBinder(binderTypes: [String.self, [CustomizedClass].self])
        let messages = try jsonHubProtocol.parseMessages(input: .string(input), binder: binder)

        XCTAssertEqual(messages.count, 1)
        XCTAssertTrue(messages[0] is InvocationMessage)
        let msg = messages[0] as! InvocationMessage
        XCTAssertEqual("testTarget", msg.target)
        XCTAssertEqual(2, msg.arguments.value!.count)
        XCTAssertEqual("arg1", msg.arguments.value![0] as! String)
        guard let array = msg.arguments.value![1] as? [CustomizedClass] else {
            XCTFail("Expected [CustomizedClass]")
            return
        }
        XCTAssertEqual(1, array.count)
        XCTAssertEqual("val", array[0].stringVal)
        XCTAssertNil(msg.invocationId)
        XCTAssertNil(msg.streamIds)
    }

    func testParseInvocationMessageThrowsForUnmatchedParameterCount() throws {
        let input = "{\"type\": 1, \"target\": \"testTarget\", \"arguments\": [\"arg1\", 123]}\(TextMessageFormat.recordSeparator)" // JSON format for InvocationMessage
        let binder = TestInvocationBinder(binderTypes: [String.self])
        XCTAssertThrowsError(try self.jsonHubProtocol.parseMessages(input: .string(input), binder: binder)) { error in
            XCTAssertEqual(error as? SignalRError, SignalRError.invalidData("Invocation provides 2 argument(s) but target expects 1."))
        }
    }

    func testParseInvocationMessageThrowsForNonDecodableClass() throws {
        let input = "{\"type\": 1, \"target\": \"testTarget\", \"arguments\": [{\"key\":\"val\"}]}\(TextMessageFormat.recordSeparator)" // JSON format for InvocationMessage
        let binder = TestInvocationBinder(binderTypes: [NonDecodableClass.self])
        XCTAssertThrowsError(try self.jsonHubProtocol.parseMessages(input: .string(input), binder: binder)) { error in
            XCTAssertEqual(error as? SignalRError, SignalRError.invalidData("Provided type NonDecodableClass does not conform to Decodable."))
        }
    }

    private class NonDecodableClass {
        var key: String = ""
    }

    func testParseInvocationMessageWithInvocationId() throws {
        let input = "{\"type\": 1, \"invocationId\":\"345\", \"target\": \"testTarget\", \"arguments\": [\"arg1\", 123]}\(TextMessageFormat.recordSeparator)" 
        let binder = TestInvocationBinder(binderTypes: [String.self, Int.self])
        let messages = try jsonHubProtocol.parseMessages(input: .string(input), binder: binder)

        XCTAssertEqual(messages.count, 1)
        XCTAssertTrue(messages[0] is InvocationMessage)
        let msg = messages[0] as! InvocationMessage
        XCTAssertEqual("testTarget", msg.target)
        XCTAssertEqual(2, msg.arguments.value!.count)
        XCTAssertEqual("arg1", msg.arguments.value![0] as! String)
        XCTAssertEqual(123, msg.arguments.value![1] as! Int)
        XCTAssertEqual("345", msg.invocationId!)
        XCTAssertNil(msg.streamIds)
    }

    func testParseInvocationMessageWithStream() throws {
        let input = "{\"type\": 1, \"invocationId\":\"345\", \"target\": \"testTarget\", \"arguments\": [\"arg1\", 123], \"streamIds\": [\"1\"]}\(TextMessageFormat.recordSeparator)" 
        let binder = TestInvocationBinder(binderTypes: [String.self, Int.self])
        let messages = try jsonHubProtocol.parseMessages(input: .string(input), binder: binder)

        XCTAssertEqual(messages.count, 1)
        XCTAssertTrue(messages[0] is InvocationMessage)
        let msg = messages[0] as! InvocationMessage
        XCTAssertEqual("testTarget", msg.target)
        XCTAssertEqual(2, msg.arguments.value!.count)
        XCTAssertEqual("arg1", msg.arguments.value![0] as! String)
        XCTAssertEqual(123, msg.arguments.value![1] as! Int)
        XCTAssertEqual("345", msg.invocationId!)
        XCTAssertEqual("1", msg.streamIds![0])
    }

    func testParseStreamItemMessage() throws {
        let input = "{\"type\": 2, \"invocationId\":\"345\", \"item\": \"someData\"}\(TextMessageFormat.recordSeparator)" // JSON format for StreamItemMessage
        let binder = TestInvocationBinder(binderTypes: [String.self])
        let messages = try jsonHubProtocol.parseMessages(input: .string(input), binder: binder)

        XCTAssertEqual(messages.count, 1)
        XCTAssertTrue(messages[0] is StreamItemMessage)
        guard let msg = messages[0] as? StreamItemMessage else {
            XCTFail("Expected StreamItemMessage")
            return
        }
        XCTAssertEqual("345", msg.invocationId)
        XCTAssertEqual("someData", msg.item.value as! String)
    }

    func testParseStreamItemMessageWithNull() throws {
        let input = "{\"type\": 2, \"invocationId\":\"345\", \"item\": null}\(TextMessageFormat.recordSeparator)" // JSON format for StreamItemMessage
        let binder = TestInvocationBinder(binderTypes: [String.self])
        let messages = try jsonHubProtocol.parseMessages(input: .string(input), binder: binder)

        XCTAssertEqual(messages.count, 1)
        XCTAssertTrue(messages[0] is StreamItemMessage)
        guard let msg = messages[0] as? StreamItemMessage else {
            XCTFail("Expected StreamItemMessage")
            return
        }
        XCTAssertEqual("345", msg.invocationId)
        XCTAssertNil(msg.item.value)
    }

    func testParseCompletionMessage() throws {
        let input = "{\"type\": 3, \"invocationId\":\"345\", \"result\": \"completionResult\"}\(TextMessageFormat.recordSeparator)" // JSON format for CompletionMessage
        let binder = TestInvocationBinder(binderTypes: [String.self])
        let messages = try jsonHubProtocol.parseMessages(input: .string(input), binder: binder)

        XCTAssertEqual(messages.count, 1)
        guard let msg = messages[0] as? CompletionMessage else {
            XCTFail("Expected CompletionMessage")
            return
        }
        XCTAssertEqual("345", msg.invocationId)
        XCTAssertEqual("completionResult", msg.result.value as! String)
    }

    func testParseCompletionMessageWithNull() throws {
        let input = "{\"type\": 3, \"invocationId\":\"345\", \"result\": null}\(TextMessageFormat.recordSeparator)" // JSON format for CompletionMessage
        let binder = TestInvocationBinder(binderTypes: [String.self])
        let messages = try jsonHubProtocol.parseMessages(input: .string(input), binder: binder)

        XCTAssertEqual(messages.count, 1)
        guard let msg = messages[0] as? CompletionMessage else {
            XCTFail("Expected CompletionMessage")
            return
        }
        XCTAssertEqual("345", msg.invocationId)
        XCTAssertNil(msg.result.value)
    }

    func testParseCompletionMessageError() throws {
        let input = "{\"type\": 3, \"invocationId\":\"345\", \"error\": \"Errors\"}\(TextMessageFormat.recordSeparator)" // JSON format for CompletionMessage
        let messages = try jsonHubProtocol.parseMessages(input: .string(input), binder: emptyBinder)

        XCTAssertEqual(messages.count, 1)
        guard let msg = messages[0] as? CompletionMessage else {
            XCTFail("Expected CompletionMessage")
            return
        }
        XCTAssertEqual("345", msg.invocationId)
        XCTAssertEqual("Errors", msg.error)
    }

    func testParseCancelInvocation() throws {
        let input = "{\"type\": 5, \"invocationId\":\"345\"}\(TextMessageFormat.recordSeparator)"
        let messages = try jsonHubProtocol.parseMessages(input: .string(input), binder: emptyBinder)

        XCTAssertEqual(messages.count, 1)
        guard let msg = messages[0] as? CancelInvocationMessage else {
            XCTFail("Expected CancelInvocationMessage")
            return
        }
        XCTAssertEqual("345", msg.invocationId)
    }

    func testParsePing() throws {
        let input = "{\"type\": 6}\(TextMessageFormat.recordSeparator)"
        let messages = try jsonHubProtocol.parseMessages(input: .string(input), binder: emptyBinder)

        XCTAssertEqual(messages.count, 1)
        guard let msg = messages[0] as? PingMessage else {
            XCTFail("Expected PingMessage")
            return
        }
    }

    func testParseCloseMessage() throws {
        let input = "{\"type\": 7, \"error\":\"Connection closed because of an error!\", \"allowReconnect\": true}\(TextMessageFormat.recordSeparator)"
        let messages = try jsonHubProtocol.parseMessages(input: .string(input), binder: emptyBinder)

        XCTAssertEqual(messages.count, 1)
        guard let msg = messages[0] as? CloseMessage else {
            XCTFail("Expected CloseMessage")
            return
        }
        XCTAssertEqual("Connection closed because of an error!", msg.error!)
        XCTAssertTrue(msg.allowReconnect!)
    }

    func testParseAckMessage() throws {
        let input = "{\"type\": 8, \"sequenceId\":1394}\(TextMessageFormat.recordSeparator)"
        let messages = try jsonHubProtocol.parseMessages(input: .string(input), binder: emptyBinder)

        XCTAssertEqual(messages.count, 1)
        guard let msg = messages[0] as? AckMessage else {
            XCTFail("Expected AckMessage")
            return
        }
        XCTAssertEqual(1394, msg.sequenceId)
    }

    func testParseSequenceMessage() throws {
        let input = "{\"type\": 9, \"sequenceId\":1394}\(TextMessageFormat.recordSeparator)"
        let messages = try jsonHubProtocol.parseMessages(input: .string(input), binder: emptyBinder)

        XCTAssertEqual(messages.count, 1)
        guard let msg = messages[0] as? SequenceMessage else {
            XCTFail("Expected SequenceMessage")
            return
        }
        XCTAssertEqual(1394, msg.sequenceId)
    }

    func testParseUnknownMessageType() throws {
        let input = "{\"type\": 99}\(TextMessageFormat.recordSeparator)" // Unknown message type
        let messages = try jsonHubProtocol.parseMessages(input: .string(input), binder: emptyBinder)

        XCTAssertEqual(messages.count, 0)
    }

    func testWriteInvocationMessage() throws {
        let message = InvocationMessage(
            target: "testTarget",
            arguments: AnyEncodableArray(["arg1", 123]),
            streamIds: ["456"],
            headers: ["key1": "value1", "key2": "value2"],
            invocationId: "123"
        )

        try verifyWriteMessage(message: message, expectedJson: """
        {"streamIds":["456"],"type":1,"headers":{"key2":"value2","key1":"value1"},"target":"testTarget","arguments":["arg1",123],"invocationId":"123"}
        """)
    }

    func testWriteInvocationMessageWithAllElement() throws {
        let message = InvocationMessage(
            target: "testTarget",
            arguments: AnyEncodableArray(["arg1", // string
                                          123, // int
                                          3.14, // double
                                          true, // bool
                                          ["array1", 456], // array
                                          ["key1": "value1", "key2": "value2"], // dictionary
                                          CustomizedEncodingClass(stringVal: "str", intVal: 12345, doubleVal: 3.14, boolVal: true)]),

            streamIds: ["456"],
            headers: ["key1": "value1", "key2": "value2"],
            invocationId: "123"
        )

        try verifyWriteMessage(message: message, expectedJson: """
        {"streamIds":["456"],"type":1,"headers":{"key2":"value2","key1":"value1"},"target":"testTarget","arguments":["arg1",123,3.14,true,["array1",456],{"key1":"value1","key2":"value2"},{"stringVal":"str","intVal":12345,"doubleVal":3.14,"boolVal":true}],"invocationId":"123"}
        """)
    }

    private struct CustomizedEncodingClass: Encodable {
        var stringVal: String = ""
        var intVal: Int = 0
        var doubleVal: Double = 0.0
        var boolVal: Bool = false
    }

    func testWriteStreamItemMessage() throws {
        let message = StreamItemMessage(invocationId: "123", item: AnyEncodable("someData"), headers: ["key1": "value1", "key2": "value2"])

        try verifyWriteMessage(message: message, expectedJson: """
        {"type":2,"item":"someData","invocationId":"123","headers":{"key2":"value2","key1":"value1"}}
        """)
    }

    func testWriteStreamItemMessage2() throws {
        let message = StreamItemMessage(invocationId: "123", item: AnyEncodable(["someData", 123]), headers: ["key1": "value1", "key2": "value2"])

        try verifyWriteMessage(message: message, expectedJson: """
        {"type":2,"item":["someData",123],"invocationId":"123","headers":{"key2":"value2","key1":"value1"}}
        """)
    }

    func testWriteStreamItemMessage3() throws {
        let message = StreamItemMessage(invocationId: "123", item: AnyEncodable(nil), headers: ["key1": "value1", "key2": "value2"])

        try verifyWriteMessage(message: message, expectedJson: """
        {"type":2,"item":null,"invocationId":"123","headers":{"key2":"value2","key1":"value1"}}
        """)
    }

    func testWriteCompletionMessage() throws {
        let message = CompletionMessage(
            invocationId: "123",
            error: nil,
            result: AnyEncodable("completionResult"),
            headers: ["key1": "value1", "key2": "value2"]
        )

        try verifyWriteMessage(message: message, expectedJson: """
        {"type":3,"invocationId":"123","result":"completionResult","headers":{"key2":"value2","key1":"value1"}}
        """)
    }

    func testWriteCompletionMessageWithNull() throws {
        let message = CompletionMessage(
            invocationId: "123",
            error: nil,
            result: AnyEncodable(nil),
            headers: ["key1": "value1", "key2": "value2"]
        )

        try verifyWriteMessage(message: message, expectedJson: """
        {"type":3,"invocationId":"123","result":null,"headers":{"key2":"value2","key1":"value1"}}
        """)
    }

    func testWriteStreamInvocationMessage() throws {
        let message = StreamInvocationMessage(
            invocationId: "streamId123",
            target: "streamTarget",
            arguments: AnyEncodableArray(["arg1", 456]),
            streamIds: ["123"],
            headers: ["key1": "value1", "key2": "value2"]
        )

        try verifyWriteMessage(message: message, expectedJson: """
        {"type":4,"target":"streamTarget","arguments":["arg1",456],"invocationId":"streamId123","streamIds":["123"],"headers":{"key2":"value2","key1":"value1"}}
        """)
    }

    func testWriteCancelInvocationMessage() throws {
        let message = CancelInvocationMessage(invocationId: "cancel123", headers: ["key1": "value1", "key2": "value2"])

        try verifyWriteMessage(message: message, expectedJson: """
        {"type":5,"invocationId":"cancel123","headers":{"key2":"value2","key1":"value1"}}
        """)
    }

    func testWritePingMessage() throws {
        let message = PingMessage()

        try verifyWriteMessage(message: message, expectedJson: """
        {"type":6}
        """)
    }

    func testWriteCloseMessage() throws {
        let message = CloseMessage(error: "Connection closed", allowReconnect: true)

        try verifyWriteMessage(message: message, expectedJson: """
        {"type":7,"error":"Connection closed","allowReconnect":true}
        """)
    }

    func testWriteAckMessage() throws {
        let message = AckMessage(sequenceId: 123)

        try verifyWriteMessage(message: message, expectedJson: """
        {"type":8,"sequenceId":123}
        """)
    }

    func testWriteSequenceMessage() throws {
        let message = SequenceMessage(sequenceId: 1001)

        try verifyWriteMessage(message: message, expectedJson: """
        {"type":9,"sequenceId":1001}
        """)
    }

    // Helper function to verify JSON serialization of messages
    private func verifyWriteMessage(message: HubMessage, expectedJson: String) throws {
        let output = try jsonHubProtocol.writeMessage(message: message)

        if case var .string(outputString) = output {
            outputString = String(outputString.dropLast()) // Remove last 0x1E character if present

            // Convert output and expected JSON strings to dictionaries for comparison
            let outputJson = try JSONSerialization.jsonObject(with: outputString.data(using: .utf8)!) as! NSDictionary
            let expectedJsonObject = try JSONSerialization.jsonObject(with: expectedJson.data(using: .utf8)!) as! NSDictionary

            XCTAssertEqual(outputJson, expectedJsonObject, "The JSON output does not match the expected JSON structure for \(message)")
        } else {
            XCTFail("Expected output to be a string")
        }
    }
}

class TestInvocationBinder: InvocationBinder, @unchecked Sendable {
    private let binderTypes: [Any.Type]

    init(binderTypes: [Any.Type]) {
        self.binderTypes = binderTypes
    }

    func getReturnType(invocationId: String) -> Any.Type? {
        return binderTypes.first
    }

    func getParameterTypes(methodName: String) -> [Any.Type] {
        return binderTypes
    }

    func getStreamItemType(streamId: String) -> Any.Type? {
        return binderTypes.first
    }
}



---
File: /Tests/SignalRClientTests/LoggerTests.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import XCTest

@testable import SignalRClient

let dummyLogger = Logger(logLevel: nil, logHandler: MockLogHandler())

final class MockLogHandler: LogHandler, @unchecked Sendable {
    private let queue: DispatchQueue
    private let innerLogHandler: LogHandler?
    private var logs: [String]

    // set showLog to true for debug
    init(showLog: Bool = false) {
        queue = DispatchQueue(label: "MockLogHandler")
        logs = []
        innerLogHandler = showLog ? DefaultLogHandler() : nil
    }

    func log(
        logLevel: SignalRClient.LogLevel, message: SignalRClient.LogMessage,
        file: String, function: String, line: UInt
    ) {
        queue.sync {
            logs.append("\(message)")
        }
        innerLogHandler?.log(
            logLevel: logLevel, message: message, file: file,
            function: function, line: line
        )
    }

}

extension MockLogHandler {
    func clear() {
        queue.sync {
            logs.removeAll()
        }
    }

    func verifyLogged(
        _ message: String, file: StaticString = #filePath, line: UInt = #line
    ) {
        queue.sync {
            for log in logs {
                if log.contains(message) {
                    return
                }
            }
            XCTFail(
                "Expected log not found: \"\(message)\"", file: file, line: line
            )
        }
    }

    func verifyNotLogged(
        _ message: String, file: StaticString = #filePath, line: UInt = #line
    ) {
        queue.sync {
            for log in logs {
                if log.contains(message) {
                    XCTFail(
                        "Unexpected Log found: \"\(message)\"", file: file,
                        line: line
                    )
                }
            }
        }
    }
}

class LoggerTests: XCTestCase {
    func testOSLogHandler() {
        let logger = Logger(logLevel: .debug, logHandler: DefaultLogHandler())
        logger.log(level: .debug, message: "Hello world")
        logger.log(level: .information, message: "Hello world \(true)")
    }

    func testMockHandler() {
        let mockLogHandler = MockLogHandler()
        let logger = Logger(logLevel: .information, logHandler: mockLogHandler)
        logger.log(level: .error, message: "error")
        logger.log(level: .information, message: "info")
        logger.log(level: .debug, message: "debug")
        mockLogHandler.verifyLogged("error")
        mockLogHandler.verifyLogged("info")
        mockLogHandler.verifyNotLogged("debug")
        mockLogHandler.clear()
        mockLogHandler.verifyNotLogged("error")
        mockLogHandler.verifyNotLogged("info")
    }
}



---
File: /Tests/SignalRClientTests/LongPollingTransportTests.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import XCTest

@testable import SignalRClient

class LongPollingTransportTests: XCTestCase {
    // MARK: poll
    func testPollCancelled() async throws {
        let client = MockHttpClient()
        let logHandler = MockLogHandler()
        let logger = Logger(logLevel: .debug, logHandler: logHandler)
        var options = HttpConnectionOptions()
        options.logMessageContent = true
        let lpt = LongPollingTransport(
            httpClient: client, logger: logger, options: options
        )
        await lpt.onClose { err in }
        await lpt.SetRunning(running: true)
        let request = HttpRequest(
            mockId: "poll", method: .GET, url: "http://signalr.com/hub/chat"
        )
        await client.mock(mockId: "poll") { request in
            try await Task.sleep(for: .milliseconds(100))
            return (
                StringOrData.string("poll-result"),
                HttpResponse(statusCode: 200)
            )
        }
        let t = Task {
            await lpt.poll(pollRequest: request)
        }
        try await Task.sleep(for: .milliseconds(300))
        logHandler.verifyLogged("polling")
        logHandler.verifyLogged("data received")
        logHandler.verifyLogged("poll-result")
        logHandler.verifyNotLogged("complete")
        t.cancel()
        try await Task.sleep(for: .milliseconds(300))
        logHandler.verifyLogged("complete")
        await t.value
        logHandler.verifyNotLogged("onclose event")
    }

    func testPollStopRunning() async throws {
        let client = MockHttpClient()
        let logHandler = MockLogHandler()
        let logger = Logger(logLevel: .debug, logHandler: logHandler)
        var options = HttpConnectionOptions()
        options.logMessageContent = true
        let lpt = LongPollingTransport(
            httpClient: client, logger: logger, options: options
        )
        await lpt.onClose { err in }
        await lpt.SetRunning(running: true)
        let request = HttpRequest(
            mockId: "poll", method: .GET, url: "http://signalr.com/hub/chat"
        )
        await client.mock(mockId: "poll") { request in
            try await Task.sleep(for: .milliseconds(100))
            return (
                StringOrData.string("poll-result"),
                HttpResponse(statusCode: 200)
            )
        }
        let t = Task {
            await lpt.poll(pollRequest: request)
        }
        try await Task.sleep(for: .milliseconds(300))
        logHandler.verifyLogged("polling")
        logHandler.verifyLogged("data received")
        logHandler.verifyLogged("poll-result")
        logHandler.verifyNotLogged("complete")
        await lpt.SetRunning(running: false)
        try await Task.sleep(for: .milliseconds(300))
        logHandler.verifyLogged("complete")
        await t.value
        logHandler.verifyLogged("onclose event")
    }

    func testPollTerminatedWith204() async throws {
        let client = MockHttpClient()
        let logHandler = MockLogHandler()
        let logger = Logger(logLevel: .debug, logHandler: logHandler)
        var options = HttpConnectionOptions()
        options.logMessageContent = true
        let lpt = LongPollingTransport(
            httpClient: client, logger: logger, options: options
        )
        await lpt.SetRunning(running: true)
        let request = HttpRequest(
            mockId: "poll", method: .GET, url: "http://signalr.com/hub/chat"
        )
        await client.mock(mockId: "poll") { request in
            try await Task.sleep(for: .milliseconds(100))
            return (
                StringOrData.string("poll-result"),
                HttpResponse(statusCode: 204)
            )
        }
        let t = Task {
            await lpt.poll(pollRequest: request)
        }
        try await Task.sleep(for: .milliseconds(300))
        logHandler.verifyLogged("polling")
        logHandler.verifyLogged("terminated")
        logHandler.verifyNotLogged("data received")
        logHandler.verifyNotLogged("poll-result")
        logHandler.verifyLogged("complete")
        await t.value
    }

    func testPollUnexpectedStatusCode() async throws {
        let client = MockHttpClient()
        let logHandler = MockLogHandler()
        let logger = Logger(logLevel: .debug, logHandler: logHandler)
        var options = HttpConnectionOptions()
        options.logMessageContent = true
        let lpt = LongPollingTransport(
            httpClient: client, logger: logger, options: options
        )
        await lpt.SetRunning(running: true)
        let request = HttpRequest(
            mockId: "poll", method: .GET, url: "http://signalr.com/hub/chat"
        )
        await client.mock(mockId: "poll") { request in
            try await Task.sleep(for: .milliseconds(100))
            return (
                StringOrData.string("poll-result"),
                HttpResponse(statusCode: 222)
            )
        }
        let t = Task {
            await lpt.poll(pollRequest: request)
        }
        try await Task.sleep(for: .milliseconds(300))
        logHandler.verifyLogged("polling")
        logHandler.verifyNotLogged("data received")
        logHandler.verifyNotLogged("poll-result")
        logHandler.verifyNotLogged("complete")
        let err = await lpt.closeError as? SignalRError
        XCTAssertEqual(err, SignalRError.unexpectedResponseCode(222))
        t.cancel()
        try await Task.sleep(for: .milliseconds(300))
        logHandler.verifyLogged("complete")
        await t.value
    }

    func testPollTimeoutWithEmptyMessage() async throws {
        let client = MockHttpClient()
        let logHandler = MockLogHandler()
        let logger = Logger(logLevel: .debug, logHandler: logHandler)
        var options = HttpConnectionOptions()
        options.logMessageContent = true
        let lpt = LongPollingTransport(
            httpClient: client, logger: logger, options: options
        )
        await lpt.SetRunning(running: true)
        let request = HttpRequest(
            mockId: "poll", method: .GET, url: "http://signalr.com/hub/chat"
        )
        await client.mock(mockId: "poll") { request in
            try await Task.sleep(for: .milliseconds(100))
            return (StringOrData.string(""), HttpResponse(statusCode: 200))
        }
        let t = Task {
            await lpt.poll(pollRequest: request)
        }
        try await Task.sleep(for: .milliseconds(300))
        logHandler.verifyLogged("polling")
        logHandler.verifyLogged("timed out")
        logHandler.verifyNotLogged("data received")
        logHandler.verifyNotLogged("complete")
        t.cancel()
        try await Task.sleep(for: .milliseconds(300))
        logHandler.verifyLogged("complete")
        await t.value
    }

    func testPollHttpTimeout() async throws {
        let client = MockHttpClient()
        let logHandler = MockLogHandler()
        let logger = Logger(logLevel: .debug, logHandler: logHandler)
        var options = HttpConnectionOptions()
        options.logMessageContent = true
        let lpt = LongPollingTransport(
            httpClient: client, logger: logger, options: options
        )
        await lpt.SetRunning(running: true)
        let request = HttpRequest(
            mockId: "poll", method: .GET, url: "http://signalr.com/hub/chat"
        )
        await client.mock(mockId: "poll") { request in
            throw SignalRError.httpTimeoutError
        }
        let t = Task {
            await lpt.poll(pollRequest: request)
        }
        try await Task.sleep(for: .milliseconds(300))
        logHandler.verifyLogged("polling")
        logHandler.verifyLogged("timed out")
        logHandler.verifyNotLogged("data received")
        logHandler.verifyNotLogged("complete")
        t.cancel()
        try await Task.sleep(for: .milliseconds(300))
        logHandler.verifyLogged("complete")
        await t.value
    }

    func testPollUnknownException() async throws {
        let client = MockHttpClient()
        let logHandler = MockLogHandler()
        let logger = Logger(logLevel: .debug, logHandler: logHandler)
        var options = HttpConnectionOptions()
        options.logMessageContent = true
        let lpt = LongPollingTransport(
            httpClient: client, logger: logger, options: options
        )
        await lpt.SetRunning(running: true)
        let request = HttpRequest(
            mockId: "poll", method: .GET, url: "http://signalr.com/hub/chat"
        )
        await client.mock(mockId: "poll") { request in
            throw SignalRError.invalidDataType
        }
        let t = Task {
            await lpt.poll(pollRequest: request)
        }
        try await Task.sleep(for: .milliseconds(300))
        logHandler.verifyLogged("polling")
        logHandler.verifyLogged("complete")
        let err = await lpt.closeError as? SignalRError
        XCTAssertEqual(err, SignalRError.invalidDataType)
        let running = await lpt.running
        XCTAssertEqual(running, false)
        await t.value
    }

    // MARK: send
    func testSendOK() async throws {
        let client = MockHttpClient()
        let logHandler = MockLogHandler()
        let logger = Logger(logLevel: .debug, logHandler: logHandler)
        let options = HttpConnectionOptions()
        let lpt = LongPollingTransport(
            httpClient: client, logger: logger, options: options
        )
        await lpt.SetRunning(running: true)
        await lpt.SetUrl(url: "http://abc")
        await client.mock(mockId: "string") { request in
            XCTAssertEqual(request.content, StringOrData.string("stringbody"))
            try await Task.sleep(for: .milliseconds(100))
            return (
                StringOrData.string(""),
                HttpResponse(statusCode: 200)
            )
        }
        await lpt.SetMockId(mockId: "string")
        try await lpt.send(.string("stringbody"))
        logHandler.verifyLogged("200")
    }
    
    func testSend403() async throws {
        let client = MockHttpClient()
        let logHandler = MockLogHandler()
        let logger = Logger(logLevel: .debug, logHandler: logHandler)
        let options = HttpConnectionOptions()
        let lpt = LongPollingTransport(
            httpClient: client, logger: logger, options: options
        )
        await lpt.SetRunning(running: true)
        await lpt.SetUrl(url: "http://abc")
        await client.mock(mockId: "string") { request in
            XCTAssertEqual(request.content, StringOrData.string("stringbody"))
            try await Task.sleep(for: .milliseconds(100))
            return (
                StringOrData.string(""),
                HttpResponse(statusCode: 403)
            )
        }
        await lpt.SetMockId(mockId: "string")
        do{
            try await lpt.send(.string("stringbody"))
            XCTFail("Long polling send should fail when getting 403")
        }catch{
            guard let err = error as? SignalRError else{
                XCTFail("Long polling send should throw SignalRError when getting 403")
                return
            }
            XCTAssertEqual(err, SignalRError.unexpectedResponseCode(403))
        }
        logHandler.verifyLogged("403")
    }

    // MARK: stop
    func testStop() async throws {
        let client = MockHttpClient()
        let logHandler = MockLogHandler()
        let logger = Logger(logLevel: .debug, logHandler: logHandler)
        let options = HttpConnectionOptions()
        let lpt = LongPollingTransport(
            httpClient: client, logger: logger, options: options
        )
        await lpt.SetRunning(running: true)
        await lpt.SetUrl(url: "http://abc")
        await client.mock(mockId: "stop200") { request in
            XCTAssertEqual(request.method, .DELETE)
            try await Task.sleep(for: .milliseconds(100))
            return (
                StringOrData.string(""),
                HttpResponse(statusCode: 200)
            )
        }
        await client.mock(mockId: "stop404") { request in
            XCTAssertEqual(request.method, .DELETE)
            try await Task.sleep(for: .milliseconds(100))
            return (
                StringOrData.string(""),
                HttpResponse(statusCode: 404)
            )
        }

        await client.mock(mockId: "stop300") { request in
            XCTAssertEqual(request.method, .DELETE)
            try await Task.sleep(for: .milliseconds(100))
            return (
                StringOrData.string(""),
                HttpResponse(statusCode: 300)
            )
        }

        await lpt.SetMockId(mockId: "stop200")
        try await lpt.stop(error: nil)
        logHandler.verifyLogged("accepted")

        logHandler.clear()
        await lpt.SetMockId(mockId: "stop404")
        try await lpt.stop(error: nil)
        logHandler.verifyLogged("404")

        logHandler.clear()
        await lpt.SetMockId(mockId: "stop300")
        try await lpt.stop(error: nil)
        logHandler.verifyLogged("Unexpected")
    }

    // MARK: connect
    func testConnect() async throws {
        let client = MockHttpClient()
        let logHandler = MockLogHandler()
        let logger = Logger(logLevel: .debug, logHandler: logHandler)
        var options = HttpConnectionOptions()
        options.logMessageContent = true
        let lpt = LongPollingTransport(
            httpClient: client, logger: logger, options: options
        )
        await lpt.onClose { err in }
        await client.mock(mockId: "connect") { request in
            try await Task.sleep(for: .milliseconds(100))
            return (
                StringOrData.string(""),
                HttpResponse(statusCode: 200)
            )
        }
        await lpt.SetMockId(mockId: "connect")
        try await lpt.connect(url: "url", transferFormat: .text)
        try await Task.sleep(for: .milliseconds(300))

        let running = await lpt.running
        XCTAssertTrue(running)
        await lpt.SetRunning(running: false)
    }

    func testConnectFail() async throws {
        let client = MockHttpClient()
        let logHandler = MockLogHandler()
        let logger = Logger(logLevel: .debug, logHandler: logHandler)
        var options = HttpConnectionOptions()
        options.logMessageContent = true
        let lpt = LongPollingTransport(
            httpClient: client, logger: logger, options: options
        )
        await lpt.onClose { err in }
        await client.mock(mockId: "connect") { request in
            try await Task.sleep(for: .milliseconds(100))
            return (
                StringOrData.string(""),
                HttpResponse(statusCode: 404)
            )
        }
        await lpt.SetMockId(mockId: "connect")
        try await lpt.connect(url: "url", transferFormat: .text)
        try await Task.sleep(for: .milliseconds(300))

        let running = await lpt.running
        XCTAssertFalse(running)
    }

    func testHttpRequestAppendDate() async throws {
        var request = HttpRequest(method: .DELETE, url: "http://abc", content: .string(""), responseType: .binary, headers: nil, timeout: nil)
        request.appendDateInUrl()
        XCTAssertEqual(request.url.components(separatedBy: "&").count, 2)
        request.appendDateInUrl()
        XCTAssertEqual(request.url.components(separatedBy: "&").count, 2)
    }
}

extension LongPollingTransport {
    fileprivate func SetRunning(running: Bool) {
        self.running = running
    }

    fileprivate func SetUrl(url: String) {
        self.url = url
    }

    fileprivate func SetMockId(mockId: String) {
        if self.options.headers == nil {
            self.options.headers = [:]
        }
        self.options.headers![mockKey] = mockId
    }
}



---
File: /Tests/SignalRClientTests/MessageBufferTests.swift
---

import XCTest

@testable import SignalRClient

class MessageBufferTest: XCTestCase {
    func testSendWithinBufferSize() async throws {
        let buffer = MessageBuffer(bufferSize: 100)
        let expectation = XCTestExpectation(description: "Should enqueue")
        Task {
            try await buffer.enqueue(content: .string("data"))
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testSendTriggersBackpressure() async throws {
        let buffer = MessageBuffer(bufferSize: 5)
        let expectation1 = XCTestExpectation(description: "Should not enqueue")
        expectation1.isInverted = true
        let expectation2 = XCTestExpectation(description: "Should enqueue")
        Task {
            try await buffer.enqueue(content: .string("123456"))
            expectation1.fulfill()
            expectation2.fulfill()
        }
        
        await fulfillment(of: [expectation1], timeout: 0.5)
        let content = try await buffer.TryDequeue() // Only after dequeue, the ack takes effect
        XCTAssertEqual("123456", content?.convertToString())
        let rst = try await buffer.ack(sequenceId: 1)
        XCTAssertEqual(true, rst)
        await fulfillment(of: [expectation2], timeout: 1)
    }

    func testBackPressureAndRelease() async throws {
        let buffer = MessageBuffer(bufferSize: 10)
        try await buffer.enqueue(content: .string("1234567890"))
        async let eq1 = buffer.enqueue(content: .string("1"))
        async let eq2 = buffer.enqueue(content: .string("2"))

        try await Task.sleep(for: .microseconds(10))
        try await buffer.TryDequeue() // 1234567890
        try await buffer.TryDequeue() // 1
        try await buffer.TryDequeue() // 2
        
        // ack 1 and all should be below 
        try await buffer.ack(sequenceId: 1)

        try await eq1
        try await eq2
    }

    func testBackPressureAndRelease2() async throws {
        let buffer = MessageBuffer(bufferSize: 10)
        let expect1 = XCTestExpectation(description: "Should not release 1")
        expect1.isInverted = true
        let expect2 = XCTestExpectation(description: "Should not release 2")
        expect2.isInverted = true
        let expect3 = XCTestExpectation(description: "Should not release 3")
        expect3.isInverted = true

        try await buffer.enqueue(content: .string("1234567890")) //10
        try await Task.sleep(for: .microseconds(10)) 
        let t1 = Task { 
            try await buffer.enqueue(content: .string("1"))
            expect1.fulfill()
        }// 11
        try await Task.sleep(for: .microseconds(10))
        let t2 = Task { 
            try await buffer.enqueue(content: .string("2")) 
            expect2.fulfill()
        }// 12
        try await Task.sleep(for: .microseconds(10))
        let t3 = Task {
            try await buffer.enqueue(content: .string("123456789")) 
            expect3.fulfill()
        }// 21
        try await Task.sleep(for: .microseconds(10))

        try await buffer.TryDequeue() // 1234567890
        try await buffer.TryDequeue() // 1
        try await buffer.TryDequeue() // 2
        try await buffer.TryDequeue() // 1234567890
        
        // ack 1 and all should be below 
        try await buffer.ack(sequenceId: 1) // remain 11, nothing will release

        await fulfillment(of: [expect1, expect2, expect3], timeout: 0.5)
        try await buffer.ack(sequenceId: 2) // remain 10, all released
        await t1.result
        await t2.result
        await t3.result
    }

    func testAckInvalidSequenceIdIgnored() async throws {
        let buffer = MessageBuffer(bufferSize: 100)
        let rst = try await buffer.ack(sequenceId: 1) // without any send
        XCTAssertEqual(false, rst)
        
        // Enqueue but not send
        try await buffer.enqueue(content: .string("abc"))
        let rst2 = try await buffer.ack(sequenceId: 1)
        XCTAssertEqual(false, rst2)
    }

    func testWaitToDequeueReturnsImmediatelyIfAvailable() async throws {
        let buffer = MessageBuffer(bufferSize: 100)
        _ = try await buffer.enqueue(content: .string("msg"))
        let result = try await buffer.WaitToDequeue()
        XCTAssertTrue(result)
        let content = try await buffer.TryDequeue()
        XCTAssertEqual("msg", content?.convertToString())
    }

    func testWaitToDequeueFirst() async throws {
        let buffer = MessageBuffer(bufferSize: 100)
        async let dqueue: Bool = try await buffer.WaitToDequeue()
        try await Task.sleep(for: .milliseconds(10))

        try await buffer.enqueue(content: .string("test"))
        try await buffer.enqueue(content: .string("test2"))

        let rst = try await dqueue
        XCTAssertTrue(rst)
        let content = try await buffer.TryDequeue()
        XCTAssertEqual("test", content?.convertToString())
    }

    func testMultipleDequeueWait() async throws {
        let buffer = MessageBuffer(bufferSize: 100)
        async let dqueue1: Bool = try await buffer.WaitToDequeue()
        async let dqueue2: Bool = try await buffer.WaitToDequeue()
        try await Task.sleep(for: .milliseconds(10))

        try await buffer.enqueue(content: .string("test"))

        let rst = try await dqueue1
        XCTAssertTrue(rst)
        let rst2 = try await dqueue2
        XCTAssertTrue(rst2)
        let content = try await buffer.TryDequeue()
        XCTAssertEqual("test", content?.convertToString())
    }

    func testTryDequeueReturnsNilIfEmpty() async throws {
        let buffer = MessageBuffer(bufferSize: 100)
        let result = try await buffer.TryDequeue()
        XCTAssertNil(result)
    }

    func testResetDequeueResetsCorrectly() async throws {
        let buffer = MessageBuffer(bufferSize: 100)
        try await buffer.enqueue(content: .string("test1"))
        try await buffer.enqueue(content: .string("test2"))
        let t1 = try await buffer.TryDequeue()
        XCTAssertEqual("test1", t1?.convertToString())
        let t2 = try await buffer.TryDequeue()
        XCTAssertEqual("test2", t2?.convertToString())

        // wait here
        async let dq = try await buffer.WaitToDequeue()
        try await Task.sleep(for: .milliseconds(10))
        Task {
            try await buffer.ResetDequeue()
        }

        try await dq
        let t3 = try await buffer.TryDequeue()
        XCTAssertEqual("test1", t3?.convertToString())
        let t4 = try await buffer.TryDequeue()
        XCTAssertEqual("test2", t4?.convertToString())
    }

    func testContinuousBackPressure() async throws {
        let buffer = MessageBuffer(bufferSize: 5)
        var tasks: [Task<Void, any Error>] = []
        for i in 0..<100 {
            let task = Task {
                try await buffer.enqueue(content: .string("123456"))
            }
            tasks.append(task)
        }

        Task {
            while (try await buffer.WaitToDequeue()) {
                try await buffer.TryDequeue()
            }
        }

        for i in 0..<100 {
            await tasks[i]
        }

        await buffer.close()
    }
}


---
File: /Tests/SignalRClientTests/MessagePackHubProtocolTests.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import Foundation
import XCTest

@testable import SignalRClient

class MessagePackHubProtocolTests: XCTestCase {
    func testInvocationMessage() throws {
        let data = Data([
            0x96, 0x01, 0x80, 0xa3, 0x78, 0x79, 0x7a, 0xa6, 0x6d, 0x65, 0x74,
            0x68, 0x6f, 0x64, 0x91, 0x2a, 0x90,
        ])
        let binder = TestInvocationBinder(binderTypes: [Int.self])
        let msgpack = MessagePackHubProtocol()
        let message =
            try msgpack.parseMessage(message: data, binder: binder)
            as! InvocationMessage
        XCTAssertEqual(message.headers, [:])
        XCTAssertEqual(message.invocationId, "xyz")
        XCTAssertEqual(message.target, "method")
        XCTAssertEqual(message.arguments.value?.count, 1)
        XCTAssertEqual(message.arguments.value?[0] as? Int, 42)
        XCTAssertEqual(message.streamIds, [])

        switch try msgpack.writeMessage(message: message) {
        case .data(let d):
            XCTAssertEqual(d, try BinaryMessageFormat.write(data))
        default:
            XCTFail("Wrong encoded typed")
        }
    }

    func testParseStreamInvocationMessage() throws {
        let data = Data([
            0x96, 0x04, 0x80, 0xa3, 0x78, 0x79, 0x7a, 0xa6, 0x6d, 0x65, 0x74,
            0x68, 0x6f, 0x64, 0x91, 0x2a, 0x90,
        ])
        let binder = TestInvocationBinder(binderTypes: [Int.self])
        let msgpack = MessagePackHubProtocol()
        let message =
            try msgpack.parseMessage(message: data, binder: binder)
        XCTAssertNil(message)
    }

    func testWriteInvocationMessage() throws {
        let data = Data([
            0x96, 0x04, 0x80, 0xa3, 0x78, 0x79, 0x7a, 0xa6, 0x6d, 0x65, 0x74,
            0x68, 0x6f, 0x64, 0x91, 0x2a, 0x90,
        ])
        let msgpack = MessagePackHubProtocol()
        switch try msgpack.writeMessage(
            message: StreamInvocationMessage(
                invocationId: "xyz", target: "method",
                arguments: AnyEncodableArray([42]), streamIds: [],
                headers: [:]
            )) {
        case .data(let d):
            XCTAssertEqual(d, try BinaryMessageFormat.write(data))
        default:
            XCTFail("Wrong encoded typed")
        }
    }

    func testStreamItemMessage() throws {
        let data = Data([
            0x94, 0x02, 0x80, 0xa3, 0x78, 0x79, 0x7a, 0x2a,
        ])
        let binder = TestInvocationBinder(binderTypes: [Int.self])
        let msgpack = MessagePackHubProtocol()
        let message =
            try msgpack.parseMessage(message: data, binder: binder)
            as! StreamItemMessage
        XCTAssertEqual(message.headers, [:])
        XCTAssertEqual(message.invocationId, "xyz")
        XCTAssertEqual(message.item.value as? Int, 42)

        switch try msgpack.writeMessage(message: message) {
        case .data(let d):
            XCTAssertEqual(d, try BinaryMessageFormat.write(data))
        default:
            XCTFail("Wrong encoded typed")
        }
    }

    func testCompletionMessageError() throws {
        let data = Data([
            0x95, 0x03, 0x80, 0xa3, 0x78, 0x79, 0x7a, 0x01, 0xa5, 0x45, 0x72,
            0x72, 0x6f, 0x72,
        ])
        let binder = TestInvocationBinder(binderTypes: [Int.self])
        let msgpack = MessagePackHubProtocol()
        let message =
            try msgpack.parseMessage(message: data, binder: binder)
            as! CompletionMessage
        XCTAssertEqual(message.headers, [:])
        XCTAssertEqual(message.invocationId, "xyz")
        XCTAssertEqual(message.error, "Error")

        switch try msgpack.writeMessage(message: message) {
        case .data(let d):
            XCTAssertEqual(d, try BinaryMessageFormat.write(data))
        default:
            XCTFail("Wrong encoded typed")
        }
    }

    func testCompletionMessageVoid() throws {
        let data = Data([
            0x94, 0x03, 0x80, 0xa3, 0x78, 0x79, 0x7a, 0x02,
        ])
        let binder = TestInvocationBinder(binderTypes: [Int.self])
        let msgpack = MessagePackHubProtocol()
        let message =
            try msgpack.parseMessage(message: data, binder: binder)
            as! CompletionMessage
        XCTAssertEqual(message.headers, [:])
        XCTAssertEqual(message.invocationId, "xyz")
        XCTAssertNil(message.error)
        XCTAssertNil(message.result.value)

        switch try msgpack.writeMessage(message: message) {
        case .data(let d):
//            XCTAssertEqual(d, try BinaryMessageFormat.write(data))
            // Encoded to resultKind = 3
            XCTAssertEqual(d, try BinaryMessageFormat.write(Data([
                0x95, 0x03, 0x80, 0xa3, 0x78, 0x79, 0x7a, 0x03, 0xc0
            ])))
        default:
            XCTFail("Wrong encoded typed")
        }
    }

    func testCompletionMessageResult() throws {
        let data = Data([
            0x95, 0x03, 0x80, 0xa3, 0x78, 0x79, 0x7a, 0x03, 0x2a,
        ])
        let binder = TestInvocationBinder(binderTypes: [Int.self])
        let msgpack = MessagePackHubProtocol()
        let message =
            try msgpack.parseMessage(message: data, binder: binder)
            as! CompletionMessage
        XCTAssertEqual(message.headers, [:])
        XCTAssertEqual(message.invocationId, "xyz")
        XCTAssertNil(message.error)
        XCTAssertEqual(message.result.value as? Int, 42)

        switch try msgpack.writeMessage(message: message) {
        case .data(let d):
            XCTAssertEqual(d, try BinaryMessageFormat.write(data))
        default:
            XCTFail("Wrong encoded typed")
        }
    }

    func testCompletionMessageResultNoBinder() throws {
        let data = Data([
            0x95, 0x03, 0x80, 0xa3, 0x78, 0x79, 0x7a, 0x03, 0x2a,
        ])
        let binder = TestInvocationBinder(binderTypes: [])
        let msgpack = MessagePackHubProtocol()
        let message =
            try msgpack.parseMessage(message: data, binder: binder)
            as! CompletionMessage
        XCTAssertEqual(message.headers, [:])
        XCTAssertEqual(message.invocationId, "xyz")
        XCTAssertNil(message.error)
        XCTAssertNil(message.result.value)
    }

    func testCompletionMessageResultNotDecodable() throws {
        let data = Data([
            0x95, 0x03, 0x80, 0xa3, 0x78, 0x79, 0x7a, 0x03, 0x2a,
        ])
        let binder = TestInvocationBinder(binderTypes: [LogHandler.self])
        let msgpack = MessagePackHubProtocol()

        do {
            try msgpack.parseMessage(message: data, binder: binder)
            XCTFail("Should throw when paring not decodable")
        } catch SignalRError.invalidData(let errmsg) {
            XCTAssertTrue(errmsg.contains("Decodable"))
        }
    }

    func testCancelInvocationMessage() throws {
        let data = Data([
            0x93, 0x05, 0x80, 0xa3, 0x78, 0x79, 0x7a,
        ])
        let binder = TestInvocationBinder(binderTypes: [Int.self])
        let msgpack = MessagePackHubProtocol()
        let message =
            try msgpack.parseMessage(message: data, binder: binder)
            as! CancelInvocationMessage
        XCTAssertEqual(message.headers, [:])
        XCTAssertEqual(message.invocationId, "xyz")

        switch try msgpack.writeMessage(message: message) {
        case .data(let d):
            XCTAssertEqual(d, try BinaryMessageFormat.write(data))
        default:
            XCTFail("Wrong encoded typed")
        }
    }

    func testPingMessage() throws {
        let data = Data([
            0x91, 0x06,
        ])
        let binder = TestInvocationBinder(binderTypes: [Int.self])
        let msgpack = MessagePackHubProtocol()
        let message =
            try msgpack.parseMessage(message: data, binder: binder)
            as! PingMessage

        switch try msgpack.writeMessage(message: message) {
        case .data(let d):
            XCTAssertEqual(d, try BinaryMessageFormat.write(data))
        default:
            XCTFail("Wrong encoded typed")
        }
    }

    func testParseCloseMessageWithoutReconnect() throws {
        let data = Data([
            0x92, 0x07, 0xa3, 0x78, 0x79, 0x7a,
        ])
        let binder = TestInvocationBinder(binderTypes: [Int.self])
        let msgpack = MessagePackHubProtocol()
        let message =
            try msgpack.parseMessage(message: data, binder: binder)
            as! CloseMessage
        XCTAssertEqual(message.error, "xyz")
        XCTAssertNil(message.allowReconnect)
    }

    func testCloseMessageWithReconnect() throws {
        let data = Data([
            0x93, 0x07, 0xa3, 0x78, 0x79, 0x7a, 0xc3,
        ])
        let binder = TestInvocationBinder(binderTypes: [Int.self])
        let msgpack = MessagePackHubProtocol()
        let message =
            try msgpack.parseMessage(message: data, binder: binder)
            as! CloseMessage
        XCTAssertEqual(message.error, "xyz")
        XCTAssertEqual(message.allowReconnect, true)
        switch try msgpack.writeMessage(message: message) {
        case .data(let d):
            // allowReconnect field is not encoded at client side
            XCTAssertEqual(
                d,
                try BinaryMessageFormat.write(
                    Data([
                        0x92, 0x07, 0xa3, 0x78, 0x79, 0x7a,
                    ]))
            )
        default:
            XCTFail("Wrong encoded typed")
        }
    }

    func testAckMessage() throws {
        let data = Data([
            0x92, 0x08, 0xcc, 0x24,
        ])
        let binder = TestInvocationBinder(binderTypes: [Int.self])
        let msgpack = MessagePackHubProtocol()
        let message =
            try msgpack.parseMessage(message: data, binder: binder)
            as! AckMessage
        XCTAssertEqual(message.sequenceId, 36)
        switch try msgpack.writeMessage(message: message) {
        case .data(let d):
            XCTAssertEqual(
                d, try BinaryMessageFormat.write(Data([0x92, 0x08, 0x24]))
            )
        default:
            XCTFail("Wrong encoded typed")
        }
    }

    func testSequenceMessage() throws {
        let data = Data([
            0x92, 0x09, 0xcc, 0x13,
        ])
        let binder = TestInvocationBinder(binderTypes: [Int.self])
        let msgpack = MessagePackHubProtocol()
        let message =
            try msgpack.parseMessage(message: data, binder: binder)
            as! SequenceMessage
        XCTAssertEqual(message.sequenceId, 19)
        switch try msgpack.writeMessage(message: message) {
        case .data(let d):
            XCTAssertEqual(
                d, try BinaryMessageFormat.write(Data([0x92, 0x09, 0x13]))
            )
        default:
            XCTFail("Wrong encoded typed")
        }
    }

    func testInvocationMessageWithHeaders() throws {
        let data = Data([
            0x96, 0x01, 0x81, 0xa1, 0x78, 0xa1, 0x79,
            0xa3, 0x78, 0x79, 0x7a, 0xa6, 0x6d, 0x65, 0x74, 0x68, 0x6f, 0x64,
            0x91, 0x2a, 0x90,
        ])
        let binder = TestInvocationBinder(binderTypes: [Int.self])
        let msgpack = MessagePackHubProtocol()
        let message =
            try msgpack.parseMessage(message: data, binder: binder)
            as! InvocationMessage
        XCTAssertEqual(message.headers?.count, 1)
        XCTAssertEqual(message.headers?["x"], "y")
        XCTAssertEqual(message.invocationId, "xyz")
        XCTAssertEqual(message.target, "method")
        XCTAssertEqual(message.arguments.value?.count, 1)
        XCTAssertEqual(message.arguments.value?[0] as? Int, 42)
        XCTAssertEqual(message.streamIds, [])

        switch try msgpack.writeMessage(message: message) {
        case .data(let d):
            XCTAssertEqual(d, try BinaryMessageFormat.write(data))
        default:
            XCTFail("Wrong encoded typed")
        }
    }
}



---
File: /Tests/SignalRClientTests/ServerSentEventTransportTests.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

#if canImport(EventSource)
    import XCTest

    @testable import SignalRClient

    actor MockEventSourceAdaptor: EventSourceAdaptor {
        let canConnect: Bool
        let sendMessage: Bool
        let disconnect: Bool
    
        var messageHandler: ((String) async -> Void)?
        var closeHandler: (((any Error)?) async -> Void)?

        init(canConnect: Bool, sendMessage: Bool, disconnect: Bool) {
            self.canConnect = canConnect
            self.sendMessage = sendMessage
            self.disconnect = disconnect
        }
    
        func start(url: String, headers: [String: String]) async throws {
            guard self.canConnect else {
                throw SignalRError.eventSourceFailedToConnect
            }
            Task {
                try await Task.sleep(for: .milliseconds(100))
                if sendMessage {
                    await self.messageHandler?("123")
                }
                try await Task.sleep(for: .milliseconds(200))
                if disconnect {
                    await self.closeHandler?(SignalRError.connectionAborted)
                }
            }
        }
    
        func stop(err: Error?) async {
            await self.closeHandler?(err)
        }
    
        func onClose(closeHandler: @escaping ((any Error)?) async -> Void) async {
            self.closeHandler = closeHandler
        }
    
        func onMessage(messageHandler: @escaping (String) async -> Void) async {
            self.messageHandler = messageHandler

        }
    }

    class ServerSentEventTransportTests: XCTestCase {
        // MARK: connect
        func testConnectSucceed() async throws {
            let client = MockHttpClient()
            let logHandler = MockLogHandler()
            let logger = Logger(logLevel: .debug, logHandler: logHandler)
            var options = HttpConnectionOptions()
            let eventSource = MockEventSourceAdaptor(canConnect: true, sendMessage: false, disconnect: false)
            options.eventSource = eventSource
            let sse = ServerSentEventTransport(
                httpClient: client, accessToken: "", logger: logger, options: options
            )
            try await sse.connect(url: "https://www.bing.com/signalr", transferFormat: .text)
            logHandler.verifyLogged("Connecting")
            logHandler.verifyLogged("connected")
        }
    
        func testConnectWrongTranferformat() async throws {
            let client = MockHttpClient()
            let logHandler = MockLogHandler()
            let logger = Logger(logLevel: .debug, logHandler: logHandler)
            var options = HttpConnectionOptions()
            let eventSource = MockEventSourceAdaptor(canConnect: true, sendMessage: false, disconnect: false)
            options.eventSource = eventSource
            let sse = ServerSentEventTransport(
                httpClient: client, accessToken: "", logger: logger, options: options
            )
            await sse.SetEventSource(eventSource: eventSource)
            do {
                try await sse.connect(url: "https://abc", transferFormat: .binary)
                XCTFail("SSE connect should fail")
            } catch SignalRError.eventSourceInvalidTransferFormat {
            }
            logHandler.verifyNotLogged("connected")
        }
    
        func testConnectFail() async throws {
            let client = MockHttpClient()
            let logHandler = MockLogHandler()
            let logger = Logger(logLevel: .debug, logHandler: logHandler)
            var options = HttpConnectionOptions()
            let eventSource = MockEventSourceAdaptor(canConnect: false, sendMessage: false, disconnect: false)
            options.eventSource = eventSource
            let sse = ServerSentEventTransport(
                httpClient: client, accessToken: "", logger: logger, options: options
            )
            do {
                try await sse.connect(url: "https://abc", transferFormat: .text)
                XCTFail("SSE connect should fail")
            } catch SignalRError.eventSourceFailedToConnect {
            }
            logHandler.verifyNotLogged("connected")
        }
    
        func testConnectAndReceiveMessage() async throws {
            let client = MockHttpClient()
            let logHandler = MockLogHandler()
            let logger = Logger(logLevel: .debug, logHandler: logHandler)
            var options = HttpConnectionOptions()
            let eventSource = MockEventSourceAdaptor(canConnect: true, sendMessage: true, disconnect: false)
            options.eventSource = eventSource
            let sse = ServerSentEventTransport(
                httpClient: client, accessToken: "", logger: logger, options: options
            )
            let expectation = XCTestExpectation(description: "Message should be received")
            await sse.onReceive() { message in
                switch message {
                case .string(let str):
                    if str == "123" {
                        expectation.fulfill()
                    }
                default:
                    break
                }
            }
            try await sse.connect(url: "https://abc", transferFormat: .text)
            logHandler.verifyLogged("connected")
            await fulfillment(of: [expectation], timeout: 1)
        }
    
        func testConnectAndDisconnect() async throws {
            let client = MockHttpClient()
            let logHandler = MockLogHandler()
            let logger = Logger(logLevel: .debug, logHandler: logHandler)
            var options = HttpConnectionOptions()
            let eventSource = MockEventSourceAdaptor(canConnect: true, sendMessage: false, disconnect: true)
            options.eventSource = eventSource
            let sse = ServerSentEventTransport(
                httpClient: client, accessToken: "", logger: logger, options: options
            )
            let expectation = XCTestExpectation(description: "SSE should be disconnected")
            await sse.onClose() { err in
                let err = err as? SignalRError
                if err == SignalRError.connectionAborted {
                    expectation.fulfill()
                }
            }
            try await sse.connect(url: "https://abc", transferFormat: .text)
            logHandler.verifyLogged("connected")
            await fulfillment(of: [expectation], timeout: 1)
        }
    
        // MARK: send
        func testSend() async throws {
            let client = MockHttpClient()
            let logHandler = MockLogHandler()
            let logger = Logger(logLevel: .debug, logHandler: logHandler)
            let options = HttpConnectionOptions()
            let sse = ServerSentEventTransport(
                httpClient: client, accessToken: "", logger: logger, options: options
            )
            let eventSource = MockEventSourceAdaptor(canConnect: false, sendMessage: false, disconnect: false)
            await sse.SetEventSource(eventSource: eventSource)
            await sse.SetUrl(url: "http://abc")
            await client.mock(mockId: "string") { request in
                XCTAssertEqual(request.content, StringOrData.string("stringbody"))
                try await Task.sleep(for: .milliseconds(100))
                return (
                    StringOrData.string(""),
                    HttpResponse(statusCode: 200)
                )
            }
            await sse.SetMockId(mockId: "string")
            try await sse.send(.string("stringbody"))
            logHandler.verifyLogged("200")
        }
    
        // MARK: asyncStream
        func testAsyncStream() async {
            let stream: AsyncStream<Int> = AsyncStream { continuition in
                Task {
                    for i in 0 ... 99 {
                        try await Task.sleep(for: .microseconds(100))
                        continuition.yield(i)
                    }
                    continuition.finish()
                }
            }
            var count = 0
            for await _ in stream {
                count += 1
            }
            XCTAssertEqual(count, 100)
        }
    }

    extension ServerSentEventTransport {
        fileprivate func SetEventSource(eventSource: EventSourceAdaptor) {
            self.eventSource = eventSource
        }

        fileprivate func SetUrl(url: String) {
            self.url = url
        }

        fileprivate func SetMockId(mockId: String) {
            if self.options.headers == nil {
                self.options.headers = [:]
            }
            self.options.headers![mockKey] = mockId
        }
    }
#endif


---
File: /Tests/SignalRClientTests/TaskCompletionSourceTests.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import XCTest

@testable import SignalRClient

class TaskCompletionSourceTests: XCTestCase {
    func testSetVarAfterWait() async throws {
        let tcs = TaskCompletionSource<Bool>()
        let t = Task {
            try await Task.sleep(for: .seconds(1))
            let set = await tcs.trySetResult(.success(true))
            XCTAssertTrue(set)
        }
        let start = Date()
        let value = try await tcs.task()
        let elapsed = Date().timeIntervalSince(start)
        XCTAssertTrue(value)
        XCTAssertLessThan(abs(elapsed - 1), 0.5)
        try await t.value
    }

    func testSetVarBeforeWait() async throws {
        let tcs = TaskCompletionSource<Bool>()
        let set = await tcs.trySetResult(.success(true))
        XCTAssertTrue(set)
        let start = Date()
        let value = try await tcs.task()
        let elapsed = Date().timeIntervalSince(start)
        XCTAssertTrue(value)
        XCTAssertLessThan(elapsed, 0.1)
    }

    func testSetException() async throws {
        let tcs = TaskCompletionSource<Bool>()
        let t = Task {
            try await Task.sleep(for: .seconds(1))
            let set = await tcs.trySetResult(
                .failure(SignalRError.noHandshakeMessageReceived))
            XCTAssertTrue(set)
        }
        let start = Date()
        do {
            _ = try await tcs.task()
        } catch {
            XCTAssertEqual(
                error as? SignalRError, SignalRError.noHandshakeMessageReceived
            )
        }
        let elapsed = Date().timeIntervalSince(start)
        XCTAssertLessThan(abs(elapsed - 1), 0.5)
        try await t.value
    }

    func testMultiSetAndMultiWait() async throws {
        let tcs = TaskCompletionSource<Bool>()

        let t = Task {
            try await Task.sleep(for: .seconds(1))
            var set = await tcs.trySetResult(.success(true))
            XCTAssertTrue(set)
            set = await tcs.trySetResult(.success(false))
            XCTAssertFalse(set)
        }

        let start = Date()
        let value = try await tcs.task()
        let elapsed = Date().timeIntervalSince(start)
        XCTAssertTrue(value)
        XCTAssertLessThan(abs(elapsed - 1), 0.5)

        let start2 = Date()
        let value2 = try await tcs.task()
        let elapsed2 = Date().timeIntervalSince(start2)
        XCTAssertTrue(value2)
        XCTAssertLessThan(elapsed2, 0.1)

        try await t.value
    }

    func testBench() async {
        let total = 10000
        var tcss: [TaskCompletionSource<Void>] = []
        tcss.reserveCapacity(total)
        for _ in 1 ... total {
            tcss.append(TaskCompletionSource<Void>())
        }
        let start = Date()
        let expectation = expectation(description: "Tcss should all complete")
        let counter = Counter(value: 0)
        for tcs in tcss {
            Task {
                try await Task.sleep(for: .microseconds(10))
                try await tcs.task()
                let c = await counter.increase(delta: 1)
                if c == total {
                    expectation.fulfill()
                    print(Date().timeIntervalSince(start))
                }
            }
        }

        for (i, tcs) in tcss.enumerated() {
            Task {
                try await Task.sleep(
                    for: .microseconds(i % 2 == 0 ? 5 : 15))
                _ = await tcs.trySetResult(.success(()))
            }
        }

        await fulfillment(of: [expectation], timeout: 1)
    }
}

actor Counter {
    var value: Int
    init(value: Int) {
        self.value = value
    }
    func increase(delta: Int) -> Int {
        value += delta
        return value
    }
}



---
File: /Tests/SignalRClientTests/TimeSchedulerTests.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

import XCTest
@testable import SignalRClient

class TimeSchedulerrTests: XCTestCase {
    var scheduler: TimeScheduler!
    var sendActionCalled: Bool!
    
    override func setUp() {
        super.setUp()
        scheduler = TimeScheduler(initialInterval: 0.1)
        sendActionCalled = false
    }
    
    override func tearDown() async throws {
        await scheduler.stop()
        scheduler = nil
        sendActionCalled = nil
        try await super.tearDown()
    }
    
    func testStart() async {
        let expectations = [
            self.expectation(description: "sendAction called"),
            self.expectation(description: "sendAction called"),
            self.expectation(description: "sendAction called")
        ]
        
        var counter = 0
        await scheduler.start {
            if counter <= 2 {
                expectations[counter].fulfill()
            }
            counter += 1
        }
        
        await fulfillment(of: [expectations[0], expectations[1], expectations[2]], timeout: 1)
    }
    
    func testStop() async {
        let stopExpectation = self.expectation(description: "sendAction not called")
        stopExpectation.isInverted = true
        
        await scheduler.start {
            stopExpectation.fulfill()
        }
        
        await scheduler.stop()

        await fulfillment(of: [stopExpectation], timeout: 0.5)
    }
    
    func testUpdateInterval() async {
        let invertedExpectation = self.expectation(description: "Should not called")
        invertedExpectation.isInverted = true
        let expectation = self.expectation(description: "sendAction called")
        await scheduler.updateInterval(to: 5)

        await scheduler.start {
            invertedExpectation.fulfill()
            expectation.fulfill()
        }

        await fulfillment(of: [invertedExpectation], timeout: 0.5)
        await scheduler.updateInterval(to: 0.1)

        await fulfillment(of: [expectation], timeout: 1)
    }
}


---
File: /Tests/SignalRClientTests/WebSocketTransportTests.swift
---

// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif
import XCTest
@testable import SignalRClient

class WebSocketTransportTests: XCTestCase {
    private var logger: Logger!
    private var mockWebSocketConnection: MockWebSocketConnection!
    private var webSocketTransport: WebSocketTransport!

    override func setUp() {
        super.setUp()
        logger = Logger(logLevel: .debug, logHandler: DefaultLogHandler())
        mockWebSocketConnection = MockWebSocketConnection()
        webSocketTransport = WebSocketTransport(accessTokenFactory: nil, logger: logger, headers: [:], websocket: mockWebSocketConnection)
    }

    func testConnect() async throws {
        let url = "http://example.com"
        try await webSocketTransport.connect(url: url, transferFormat: .text)
        XCTAssertTrue(mockWebSocketConnection.connectCalled)
    }

    func testSend() async throws {
        let data = StringOrData.string("test message")
        try await webSocketTransport.send(data)
        XCTAssertEqual(mockWebSocketConnection.sentData, data)
    }

    func testStop() async throws {
        try await webSocketTransport.stop(error: nil)
        XCTAssertTrue(mockWebSocketConnection.stopCalled)
    }

    func testOnReceive() async {
        let expectation = XCTestExpectation(description: "onReceive handler called")
        await webSocketTransport.onReceive { data in
            expectation.fulfill()
        }
        await mockWebSocketConnection.triggerReceive(.string("test message"))
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testOnClose() async {
        let expectation = XCTestExpectation(description: "onClose handler called")
        await webSocketTransport.onClose { error in
            expectation.fulfill()
        }
        await mockWebSocketConnection.triggerClose(nil)
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testConnectWithHttpUrl() async throws {
        let url = "http://example.com"
        try await webSocketTransport.connect(url: url, transferFormat: .text)
        XCTAssertTrue(mockWebSocketConnection.connectCalled)
        XCTAssertEqual(mockWebSocketConnection.request?.url?.scheme, "ws")
    }

    func testConnectWithHttpsUrl() async throws {
        let url = "https://example.com"
        try await webSocketTransport.connect(url: url, transferFormat: .text)
        XCTAssertTrue(mockWebSocketConnection.connectCalled)
        XCTAssertEqual(mockWebSocketConnection.request?.url?.scheme, "wss")
    }

    func testConnectWithHeaders() async throws {
        let headers = ["Authorization": "Bearer token"]
        webSocketTransport = WebSocketTransport(accessTokenFactory: nil, logger: logger, headers: headers, websocket: mockWebSocketConnection)
        let url = "http://example.com"
        try await webSocketTransport.connect(url: url, transferFormat: .text)
        XCTAssertTrue(mockWebSocketConnection.connectCalled)
        XCTAssertEqual(mockWebSocketConnection.request?.allHTTPHeaderFields?["Authorization"], "Bearer token")
    }

    func testConnectWithAccessToken() async throws {
        let accessTokenFactory: @Sendable () async throws -> String? = { return "test_token" }
        webSocketTransport = WebSocketTransport(accessTokenFactory: accessTokenFactory, logger: logger, headers: [:], websocket: mockWebSocketConnection)
        let url = "http://example.com"
        try await webSocketTransport.connect(url: url, transferFormat: .text)
        XCTAssertTrue(mockWebSocketConnection.connectCalled)
        XCTAssertEqual(mockWebSocketConnection.request?.value(forHTTPHeaderField: "Authorization"), "Bearer test_token")
    }
}

class MockWebSocketConnection: WebSocketTransport.WebSocketConnection {
    var connectCalled = false
    var sentData: StringOrData?
    var stopCalled = false
    var onReceiveHandler: Transport.OnReceiveHandler?
    var onCloseHandler: Transport.OnCloseHander?
    var request: URLRequest?

    func connect(request: URLRequest, transferFormat: TransferFormat) async throws {
        self.request = request
        connectCalled = true
    }

    func send(_ data: StringOrData) async throws {
        sentData = data
    }

    func stop(error: Error?) async {
        stopCalled = true
    }

    func onReceive(_ handler: Transport.OnReceiveHandler?) async {
        onReceiveHandler = handler
    }

    func onClose(_ handler: Transport.OnCloseHander?) async {
        onCloseHandler = handler
    }

    func triggerReceive(_ data: StringOrData) async {
        await onReceiveHandler?(data)
    }

    func triggerClose(_ error: Error?) async {
        await onCloseHandler?(error)
    }
}



---
File: /Package.swift
---

// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SignalRClient",
    platforms: [
        .macOS(.v11),
        .iOS(.v14)
    ],
    products: [
        .library(name: "SignalRClient", targets: ["SignalRClient"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SignalRClient",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "SignalRClientTests", dependencies: ["SignalRClient"],
            swiftSettings: [
                //                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "SignalRClientIntegrationTests", dependencies: ["SignalRClient"]
        ),
    ]
)
