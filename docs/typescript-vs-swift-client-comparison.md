# TypeScript vs Swift Client Implementation Comparison

## Overview
This document compares how TypeScript and Swift clients handle F1 data updates, focusing on why the TypeScript approach is superior for partial updates.

## TypeScript Client Approach

### 1. Transport: Server-Sent Events (SSE)
```typescript
const sse = new EventSource(`${env.NEXT_PUBLIC_LIVE_URL}/api/sse`);

sse.addEventListener("initial", (message) => {
    handleInitial(JSON.parse(message.data));
});

sse.addEventListener("update", (message) => {
    handleUpdate(JSON.parse(message.data));
});
```

### 2. Data Storage: Plain Objects with Stateful Buffers
```typescript
// No type decoding during updates!
const push = (update: RecursivePartial<T>) => {
    currentRef.current = merge(currentRef.current ?? {}, update) as T;
    buffer.push(currentRef.current);
};
```

### 3. Merge Strategy: Recursive Object Merging
```typescript
// Works with any partial object
export const merge = (base: unknown, update: unknown): unknown => {
    if (isObject(base) && isObject(update)) {
        const result = { ...base };
        for (const [key, value] of Object.entries(update)) {
            result[key] = merge(base[key] ?? null, value);
        }
        return result;
    }
    return update;
};
```

### 4. Type Safety: Only at Display Time
- Data stored as plain objects
- Types applied when accessing data
- No decoding errors during updates

## Swift Client Current Approach

### 1. Transport: WebSocket with Custom Messages
```swift
enum WebSocketMessage {
    case fullState(F1State)
    case stateUpdate(SendableJSON)
}
```

### 2. Data Storage: Strongly Typed Models
```swift
// Requires all fields during decoding
public struct BestSpeeds: Codable {
    public let i1: PersonalBestLapTime  // Fails if missing
    public let i2: PersonalBestLapTime  // Fails if missing
    // ...
}
```

### 3. Merge Strategy: JSON Serialization/Deserialization
```swift
// Expensive and error-prone
let currentStateData = try encoder.encode(createCurrentF1State())
var stateDict = try JSONSerialization.jsonObject(with: currentStateData)
DataTransformation.mergeStates(&stateDict, with: update.dictionary)
let mergedData = try JSONSerialization.data(withJSONObject: stateDict)
let mergedState = try decoder.decode(F1State.self, from: mergedData)
```

### 4. Issues with Partial Updates
- Decoding fails when fields are missing
- Can't handle incremental updates well
- Requires all model properties to be optional

## Why TypeScript Approach is Better

### 1. **No Decoding During Updates**
- TypeScript: Stores raw objects, merges without type checking
- Swift: Must decode to typed structures, fails on missing fields

### 2. **Natural Partial Update Handling**
- TypeScript: Merge function handles any partial object
- Swift: Requires all properties to be optional or decoding fails

### 3. **Performance**
- TypeScript: Direct object manipulation
- Swift: JSON encode → merge → JSON decode cycle

### 4. **Flexibility**
- TypeScript: Can handle any data structure changes
- Swift: Requires model updates for any API changes

## Recommended Migration for Swift

### Option 1: Minimal Changes (Quick Fix)
Keep WebSocket but change data handling:

```swift
// Store as dictionary instead of typed models
private var stateDict: [String: Any] = [:]

func applyUpdate(_ update: [String: Any]) {
    // Direct merge without encoding/decoding
    DataTransformation.mergeStates(&stateDict, with: update)
    
    // Only decode when accessing data
    if let timingData = try? decode(TimingData.self, from: stateDict["timingData"]) {
        // Use timingData
    }
}
```

### Option 2: Full Migration to SSE (Recommended)
Adopt TypeScript's approach completely:

#### Server Changes:
```swift
// Add SSE endpoint
app.get("v1/live/sse") { req in
    let eventStream = req.eventStream
    
    // Send initial state
    eventStream.send(event: "initial", data: fullState)
    
    // Send updates
    for await update in updates {
        eventStream.send(event: "update", data: update)
    }
}
```

#### Client Changes:
```swift
// Use EventSource for SSE
class SSEClient {
    func connect() {
        let url = URL(string: "http://localhost:8080/v1/live/sse")!
        let source = EventSource(url: url)
        
        source.onMessage("initial") { id, event, data in
            handleInitial(data)
        }
        
        source.onMessage("update") { id, event, data in
            handleUpdate(data)
        }
    }
}
```

## Benefits of Migration

1. **No More Decoding Errors**: Partial updates work naturally
2. **Better Performance**: No serialization overhead
3. **Simpler Code**: Remove complex merge logic
4. **Future Proof**: Handle API changes without model updates
5. **Automatic Reconnection**: SSE handles reconnection automatically

## Implementation Priority

1. **Immediate**: Store data as dictionaries, decode only when needed
2. **Short Term**: Migrate server to send raw JSON without WebSocketMessage wrapper
3. **Medium Term**: Switch from WebSocket to SSE for simpler architecture