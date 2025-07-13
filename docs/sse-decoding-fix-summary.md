# SSE Decoding Fix Summary

## Issue
The F1 API sends inconsistent data types for several fields in timing data:
- `status` fields: Sometimes sends integer values (e.g., 2064), sometimes sends boolean `false`
- `line` fields: Sometimes sends integer values (e.g., 5), sometimes sends boolean `false`

This caused decoding errors like:
```
Failed to decode timingData: typeMismatch(Swift.Int, Swift.DecodingError.Context(codingPath: [CodingKeys(stringValue: "lines", intValue: nil), _CodingKey(stringValue: "77", intValue: nil), CodingKeys(stringValue: "lastLapTime", intValue: nil), CodingKeys(stringValue: "status", intValue: nil)], debugDescription: "Expected to decode Int but found bool instead.", underlyingError: nil))

Failed to decode timingData: typeMismatch(Swift.Int, Swift.DecodingError.Context(codingPath: [CodingKeys(stringValue: "lines", intValue: nil), _CodingKey(stringValue: "1", intValue: nil), CodingKeys(stringValue: "line", intValue: nil)], debugDescription: "Expected to decode Int but found bool instead.", underlyingError: nil))
```

## Solution
Implemented custom decoders for the affected structs that handle both types:

### 1. LapTimeValue
Added custom decoder that tries to decode `status` as Int first, then falls back to Bool (converting false to 0, true to 1).

### 2. Sector
Added custom decoder with same logic for `status` field.

### 3. Segment  
Added custom decoder with same logic for `status` field.

### 4. TimingDataDriver
Added custom decoder that handles `line` field being either Int or Bool (converting false to nil since line 0 doesn't make sense).

### 5. TimingStatsDriver
Added custom decoder with same logic for `line` field.

### 6. TimingAppDataDriver
Added custom decoder that handles `line` field being either Int or Bool (converting false to 0 since line is not optional).

### 7. BestSpeeds
Made all fields optional (`i1`, `i2`, `fl`, `st`) since the F1 API sometimes doesn't send all speed measurement points.

### 4. TrackMapView Fixes
Fixed optional chaining issues where code was force-unwrapping optional fields:
- `lastLapTime.value` → `lastLapTime?.value`
- `bestLapTime.value` → `bestLapTime?.value`
- `gapToLeader` → optional binding

## Result
The app should now properly handle the inconsistent F1 API data without crashing or logging decoding errors. The SSE connection works (verified in tests) and data flows properly through the dictionary-based state management system.

## Testing
Created comprehensive test cases in `TimingDataDecodingTest.swift` to verify the decoders handle both integer and boolean status fields correctly.