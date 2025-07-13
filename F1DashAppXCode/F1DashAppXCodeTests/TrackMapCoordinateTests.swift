//
//  TrackMapCoordinateTests.swift
//  F1DashAppXCodeTests
//
//  Tests for track map coordinate transformations and position mapping
//

import XCTest
import CoreLocation
import F1DashModels
@testable import F1DashAppXCode

final class TrackMapCoordinateTests: XCTestCase {
    
    // MARK: - Test Data
    
    // Real telemetry position data from the user
    let samplePositionData: [String: (x: Double, y: Double, z: Double)] = [
        "44": (x: -4437, y: -261, z: 7396),
        "18": (x: -8209, y: 5460, z: 7833),
        "27": (x: -6421, y: 5658, z: 7822),
        "22": (x: -3262, y: -2076, z: 7381),
        "81": (x: -1525, y: -1921, z: 7251),
        "4": (x: -5830, y: 2294, z: 7457),
        "23": (x: -6430, y: 3390, z: 7528),
        "24": (x: 673, y: -1324, z: 7214),
        "20": (x: -4470, y: -212, z: 7396),
        "11": (x: -6686, y: 5674, z: 7833),
        "10": (x: -2738, y: -2236, z: 7338),
        "31": (x: -6167, y: 2979, z: 7493),
        "55": (x: -7311, y: 5669, z: 7847),
        "14": (x: -8070, y: 5088, z: 7781),
        "1": (x: -1362, y: 4963, z: 7634),
        "63": (x: -5082, y: 775, z: 7414),
        "2": (x: -993, y: -1774, z: 7229),
        "21": (x: -2256, y: -2122, z: 7299),
        "77": (x: 2347, y: -872, z: 7227),
        "16": (x: -6028, y: 2710, z: 7476)
    ]
    
    // Albert Park GPS center
    let albertParkCenter = CLLocationCoordinate2D(latitude: -37.8497, longitude: 144.9680)
    
    // MARK: - Coordinate Bounds Tests
    
    func testTelemetryDataBounds() {
        // Extract X and Y values
        let xValues = samplePositionData.values.map { $0.x }
        let yValues = samplePositionData.values.map { $0.y }
        let zValues = samplePositionData.values.map { $0.z }
        
        // Calculate bounds
        let xMin = xValues.min()!
        let xMax = xValues.max()!
        let yMin = yValues.min()!
        let yMax = yValues.max()!
        let zMin = zValues.min()!
        let zMax = zValues.max()!
        
        print("X bounds: \(xMin) to \(xMax) (range: \(xMax - xMin))")
        print("Y bounds: \(yMin) to \(yMax) (range: \(yMax - yMin))")
        print("Z bounds: \(zMin) to \(zMax) (range: \(zMax - zMin))")
        
        // Test expectations based on telemetry data
        XCTAssertLessThan(xMin, -8000, "X minimum should be less than -8000")
        XCTAssertGreaterThan(xMax, 2000, "X maximum should be greater than 2000")
        XCTAssertLessThan(yMin, -2000, "Y minimum should be less than -2000")
        XCTAssertGreaterThan(yMax, 5000, "Y maximum should be greater than 5000")
        
        // Z values are relatively consistent (elevation)
        XCTAssertLessThan(zMax - zMin, 1000, "Z range should be less than 1000 (relatively flat)")
    }
    
    // MARK: - Track Shape Tests
    
    func testTrackDimensionsFromTelemetry() {
        // Calculate track dimensions from telemetry
        let xValues = samplePositionData.values.map { $0.x }
        let yValues = samplePositionData.values.map { $0.y }
        
        let trackWidth = xValues.max()! - xValues.min()!
        let trackHeight = yValues.max()! - yValues.min()!
        
        print("Track dimensions from telemetry:")
        print("Width: \(trackWidth) units")
        print("Height: \(trackHeight) units")
        print("Aspect ratio: \(trackWidth / trackHeight)")
        
        // Albert Park is roughly 5.3km long
        // If telemetry units are meters, this seems too large
        XCTAssertGreaterThan(trackWidth, 10000, "Track width in telemetry units")
        XCTAssertGreaterThan(trackHeight, 7000, "Track height in telemetry units")
        
        // This suggests telemetry units might not be meters
        // Or there's an offset/scale factor needed
    }
    
    // MARK: - Coordinate Transformation Tests
    
    func testCoordinateTransformationScale() {
        // Test different scale factors to find the right one
        let testScales: [Double] = [0.1, 0.15, 0.2, 0.3, 0.5, 1.0]
        
        for scale in testScales {
            print("\nTesting scale: \(scale)")
            
            // Transform a few key positions
            let testPositions = [
                ("Start/Finish", samplePositionData["77"]!),  // Positive X (east side)
                ("West side", samplePositionData["18"]!),     // Negative X (west side)
                ("North", samplePositionData["1"]!),          // Positive Y
                ("South", samplePositionData["22"]!)          // Negative Y
            ]
            
            for (name, pos) in testPositions {
                let gps = transformToGPS(
                    x: pos.x,
                    y: pos.y,
                    scale: scale,
                    center: albertParkCenter
                )
                
                // Calculate distance from center
                let distance = calculateDistance(from: albertParkCenter, to: gps)
                print("\(name): \(distance)m from center")
            }
        }
    }
    
    func testDriverPositionsOnTrack() {
        // Test that all driver positions transform to reasonable GPS coordinates
        let scale = 0.3 // Adjusted scale based on testing
        
        var transformedPositions: [String: CLLocationCoordinate2D] = [:]
        
        for (driver, pos) in samplePositionData {
            let gps = transformToGPS(
                x: pos.x,
                y: pos.y,
                scale: scale,
                center: albertParkCenter
            )
            transformedPositions[driver] = gps
            
            // Test that position is within reasonable bounds of Albert Park
            let distance = calculateDistance(from: albertParkCenter, to: gps)
            XCTAssertLessThan(distance, 3000, "Driver \(driver) should be within 3km of center")
            XCTAssertGreaterThan(distance, 100, "Driver \(driver) should not be at center")
        }
        
        // Test relative positions make sense
        // Drivers with similar telemetry positions should be close on GPS
        let driver44 = transformedPositions["44"]!
        let driver20 = transformedPositions["20"]!
        let distance44to20 = calculateDistance(from: driver44, to: driver20)
        
        print("Distance between drivers 44 and 20: \(distance44to20)m")
        XCTAssertLessThan(distance44to20, 100, "Drivers 44 and 20 should be close (similar telemetry)")
    }
    
    // MARK: - Track Map Drawing Tests
    
    func testCreateTrackOutlineFromDriverPositions() {
        // Use convex hull or similar to create track outline from driver positions
        let scale = 0.3
        
        // Group drivers by track sectors based on their positions
        var sectors: [[String]] = []
        
        // Simple clustering based on position
        // In real implementation, would use track progress or timing data
        let sortedByX = samplePositionData.sorted { $0.value.x < $1.value.x }
        
        print("\nDrivers sorted by X position:")
        for (driver, pos) in sortedByX {
            print("Driver \(driver): X=\(pos.x), Y=\(pos.y)")
        }
        
        // Create track segments
        var trackPoints: [CLLocationCoordinate2D] = []
        
        // Add points in a rough track order
        // This is simplified - real implementation would use track distance
        for (_, pos) in sortedByX {
            let gps = transformToGPS(
                x: pos.x,
                y: pos.y,
                scale: scale,
                center: albertParkCenter
            )
            trackPoints.append(gps)
        }
        
        // Test track bounds
        let latitudes = trackPoints.map { $0.latitude }
        let longitudes = trackPoints.map { $0.longitude }
        
        let latRange = latitudes.max()! - latitudes.min()!
        let lonRange = longitudes.max()! - longitudes.min()!
        
        print("\nTrack GPS bounds:")
        print("Latitude range: \(latRange) degrees")
        print("Longitude range: \(lonRange) degrees")
        
        // Convert to approximate meters
        let latMeters = latRange * 111_000
        let lonMeters = lonRange * 93_000
        
        print("Approximate size: \(latMeters)m x \(lonMeters)m")
        
        // Albert Park is approximately 5.3km long
        XCTAssertGreaterThan(max(latMeters, lonMeters), 2000, "Track should be at least 2km long")
        XCTAssertLessThan(max(latMeters, lonMeters), 10000, "Track should be less than 10km long")
    }
    
    // MARK: - Helper Functions
    
    private func transformToGPS(
        x: Double,
        y: Double,
        scale: Double,
        center: CLLocationCoordinate2D,
        rotation: Double = 0
    ) -> CLLocationCoordinate2D {
        // Scale the coordinates
        let scaledX = x * scale
        let scaledY = y * scale  // Note: might need to invert Y
        
        // Apply rotation if needed
        let rotationRad = rotation * .pi / 180.0
        let rotatedX = scaledX * cos(rotationRad) - scaledY * sin(rotationRad)
        let rotatedY = scaledX * sin(rotationRad) + scaledY * cos(rotationRad)
        
        // Convert to GPS
        let metersPerDegreeLat = 111_000.0
        let metersPerDegreeLon = 93_000.0  // At Melbourne latitude
        
        let deltaLat = rotatedY / metersPerDegreeLat
        let deltaLon = rotatedX / metersPerDegreeLon
        
        return CLLocationCoordinate2D(
            latitude: center.latitude + deltaLat,
            longitude: center.longitude + deltaLon
        )
    }
    
    private func calculateDistance(
        from coord1: CLLocationCoordinate2D,
        to coord2: CLLocationCoordinate2D
    ) -> Double {
        // Haversine formula for distance between GPS coordinates
        let earthRadius = 6371000.0 // meters
        
        let lat1Rad = coord1.latitude * .pi / 180
        let lat2Rad = coord2.latitude * .pi / 180
        let deltaLat = (coord2.latitude - coord1.latitude) * .pi / 180
        let deltaLon = (coord2.longitude - coord1.longitude) * .pi / 180
        
        let a = sin(deltaLat/2) * sin(deltaLat/2) +
                cos(lat1Rad) * cos(lat2Rad) *
                sin(deltaLon/2) * sin(deltaLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        return earthRadius * c
    }
    
    // MARK: - Integration Tests
    
    func testFullTrackMapIntegration() async throws {
        // This would test with real track map data
        // For now, we'll simulate
        
        // Create mock track map
        let mockTrackMap = createMockTrackMap()
        
        // Test that driver positions fall within track bounds
        for (driver, pos) in samplePositionData {
            let isOnTrack = isPositionOnTrack(
                x: pos.x,
                y: pos.y,
                trackMap: mockTrackMap
            )
            
            print("Driver \(driver): \(isOnTrack ? "ON TRACK" : "OFF TRACK")")
            
            // Most drivers should be on track
            if driver != "77" { // Driver 77 might be in pit lane
                XCTAssertTrue(isOnTrack, "Driver \(driver) should be on track")
            }
        }
    }
    
    private func createMockTrackMap() -> [(x: Double, y: Double)] {
        // Create a simple oval track for testing
        var points: [(x: Double, y: Double)] = []
        let steps = 100
        
        for i in 0..<steps {
            let angle = Double(i) / Double(steps) * 2 * .pi
            let x = cos(angle) * 5000 + sin(angle * 2) * 1000
            let y = sin(angle) * 3000 + cos(angle * 3) * 500
            points.append((x: x, y: y))
        }
        
        return points
    }
    
    private func isPositionOnTrack(
        x: Double,
        y: Double,
        trackMap: [(x: Double, y: Double)],
        tolerance: Double = 200
    ) -> Bool {
        // Simple point-to-line distance check
        var minDistance = Double.infinity
        
        for i in 0..<trackMap.count {
            let p1 = trackMap[i]
            let p2 = trackMap[(i + 1) % trackMap.count]
            
            let distance = pointToLineDistance(
                point: (x: x, y: y),
                lineStart: p1,
                lineEnd: p2
            )
            
            minDistance = min(minDistance, distance)
        }
        
        return minDistance < tolerance
    }
    
    private func pointToLineDistance(
        point: (x: Double, y: Double),
        lineStart: (x: Double, y: Double),
        lineEnd: (x: Double, y: Double)
    ) -> Double {
        let A = point.x - lineStart.x
        let B = point.y - lineStart.y
        let C = lineEnd.x - lineStart.x
        let D = lineEnd.y - lineStart.y
        
        let dot = A * C + B * D
        let lenSq = C * C + D * D
        var param = -1.0
        
        if lenSq != 0 {
            param = dot / lenSq
        }
        
        var xx: Double
        var yy: Double
        
        if param < 0 {
            xx = lineStart.x
            yy = lineStart.y
        } else if param > 1 {
            xx = lineEnd.x
            yy = lineEnd.y
        } else {
            xx = lineStart.x + param * C
            yy = lineStart.y + param * D
        }
        
        let dx = point.x - xx
        let dy = point.y - yy
        
        return sqrt(dx * dx + dy * dy)
    }
}

// MARK: - Test Runner

extension TrackMapCoordinateTests {
    static func runAllTests() {
        let suite = TrackMapCoordinateTests()
        
        print("=== Running Track Map Coordinate Tests ===\n")
        
        print("1. Testing telemetry data bounds...")
        suite.testTelemetryDataBounds()
        
        print("\n2. Testing track dimensions...")
        suite.testTrackDimensionsFromTelemetry()
        
        print("\n3. Testing coordinate transformation scales...")
        suite.testCoordinateTransformationScale()
        
        print("\n4. Testing driver positions on track...")
        suite.testDriverPositionsOnTrack()
        
        print("\n5. Testing track outline creation...")
        suite.testCreateTrackOutlineFromDriverPositions()
        
        print("\n=== Tests Complete ===")
    }
}
