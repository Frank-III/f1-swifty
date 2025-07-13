//
//  AustriaTrackMapLiveTest.swift
//  F1DashAppXCodeTests
//
//  Live test with real Austria (Red Bull Ring) data
//

import XCTest
import CoreLocation
import F1DashModels
@testable import F1DashAppXCode

final class AustriaTrackMapLiveTest: XCTestCase {
    
    // Austria (Red Bull Ring) GPS coordinates
    let austriaCenter = CLLocationCoordinate2D(latitude: 47.2197, longitude: 14.7647)
    
    // Track data from API
    let trackBounds = (
        xMin: -8233.0,
        xMax: 4225.0,
        yMin: -2244.0,
        yMax: 5680.0
    )
    
    // Sample position data from your provided telemetry
    let austriaPositions: [(driver: String, x: Double, y: Double)] = [
        ("44", -4437, -261),
        ("18", -8209, 5460),
        ("27", -6421, 5658),
        ("22", -3262, -2076),
        ("81", -1525, -1921),
        ("4", -5830, 2294),
        ("23", -6430, 3390),
        ("24", 673, -1324),
        ("20", -4470, -212),
        ("11", -6686, 5674),
        ("10", -2738, -2236),
        ("31", -6167, 2979),
        ("55", -7311, 5669),
        ("14", -8070, 5088),
        ("1", -1362, 4963),
        ("63", -5082, 775),
        ("2", -993, -1774),
        ("21", -2256, -2122),
        ("77", 2347, -872),
        ("16", -6028, 2710)
    ]
    
    func testAustriaTrackDimensions() {
        // Calculate track dimensions
        let trackWidth = trackBounds.xMax - trackBounds.xMin
        let trackHeight = trackBounds.yMax - trackBounds.yMin
        
        print("Austria Track Dimensions:")
        print("Width: \(trackWidth) units")
        print("Height: \(trackHeight) units")
        print("Aspect ratio: \(trackWidth / trackHeight)")
        
        // Red Bull Ring is approximately 4.3km long
        let diagonal = sqrt(trackWidth * trackWidth + trackHeight * trackHeight)
        print("Diagonal: \(diagonal) units")
        
        // If units are meters, scale factor should be around 1
        let estimatedScale = 4300 / diagonal  // 4.3km track length
        print("Estimated scale factor: \(estimatedScale)")
        
        XCTAssertEqual(trackWidth, 12458, accuracy: 1)
        XCTAssertEqual(trackHeight, 7924, accuracy: 1)
    }
    
    func testDriverPositionsWithinTrackBounds() {
        var insideCount = 0
        var outsideCount = 0
        
        print("\nDriver Position Analysis:")
        for (driver, x, y) in austriaPositions {
            let withinBounds = x >= trackBounds.xMin && 
                              x <= trackBounds.xMax && 
                              y >= trackBounds.yMin && 
                              y <= trackBounds.yMax
            
            if withinBounds {
                insideCount += 1
                print("Driver \(driver): INSIDE track bounds")
            } else {
                outsideCount += 1
                print("Driver \(driver): OUTSIDE track bounds at (\(x), \(y))")
                
                // Calculate how far outside
                var outsideBy = ""
                if x < trackBounds.xMin { outsideBy += "X too small by \(trackBounds.xMin - x), " }
                if x > trackBounds.xMax { outsideBy += "X too large by \(x - trackBounds.xMax), " }
                if y < trackBounds.yMin { outsideBy += "Y too small by \(trackBounds.yMin - y), " }
                if y > trackBounds.yMax { outsideBy += "Y too large by \(y - trackBounds.yMax), " }
                print("  -> \(outsideBy)")
            }
        }
        
        print("\nSummary: \(insideCount) inside, \(outsideCount) outside")
        
        // All drivers should be within track bounds
        XCTAssertEqual(insideCount, 20, "All 20 drivers should be within track bounds")
    }
    
    func testCoordinateTransformationScale() {
        // Based on track dimensions, estimate the right scale
        let trackDiagonal = sqrt(pow(trackBounds.xMax - trackBounds.xMin, 2) + 
                                pow(trackBounds.yMax - trackBounds.yMin, 2))
        
        // Red Bull Ring is ~4.3km
        let realTrackLength = 4318.0  // meters
        let calculatedScale = realTrackLength / trackDiagonal
        
        print("\nScale Calculation:")
        print("Track diagonal: \(trackDiagonal) units")
        print("Real track length: \(realTrackLength) meters")
        print("Calculated scale: \(calculatedScale)")
        
        // Test with different scales
        let testScales = [calculatedScale, 0.3, 0.5, 1.0]
        
        for scale in testScales {
            print("\nTesting scale: \(scale)")
            
            // Transform corner positions
            let topRight = transformToGPS(x: trackBounds.xMax, y: trackBounds.yMax, scale: scale)
            let bottomLeft = transformToGPS(x: trackBounds.xMin, y: trackBounds.yMin, scale: scale)
            
            let distance = calculateDistance(from: bottomLeft, to: topRight)
            print("Track diagonal distance: \(distance)m")
        }
        
        // The calculated scale should be close to the expected value
        XCTAssertEqual(calculatedScale, 0.29, accuracy: 0.05)
    }
    
    func testGPSPositionsOnMap() {
        let scale = 0.3  // Based on our calculations
        
        print("\nDriver GPS Positions:")
        for (driver, x, y) in austriaPositions {
            let gps = transformToGPS(x: x, y: y, scale: scale)
            let distance = calculateDistance(from: austriaCenter, to: gps)
            
            print("Driver \(driver):")
            print("  Telemetry: (\(x), \(y))")
            print("  GPS: \(gps.latitude), \(gps.longitude)")
            print("  Distance from center: \(Int(distance))m")
            
            // Verify reasonable distance from track center
            XCTAssertLessThan(distance, 3000, "Driver should be within 3km of track center")
            XCTAssertGreaterThan(distance, 100, "Driver should not be at exact center")
        }
    }
    
    func testCreateGPSTrackOutline() {
        // Create a simple track outline using the bounds
        let trackCorners = [
            (trackBounds.xMin, trackBounds.yMin),  // SW corner
            (trackBounds.xMin, trackBounds.yMax),  // NW corner
            (trackBounds.xMax, trackBounds.yMax),  // NE corner
            (trackBounds.xMax, trackBounds.yMin),  // SE corner
            (trackBounds.xMin, trackBounds.yMin)   // Close loop
        ]
        
        print("\nTrack Outline GPS Coordinates:")
        for (i, corner) in trackCorners.enumerated() {
            let gps = transformToGPS(x: corner.0, y: corner.1, scale: 0.3)
            print("Corner \(i): \(gps.latitude), \(gps.longitude)")
        }
        
        // Calculate track area
        let width = calculateDistance(
            from: transformToGPS(x: trackBounds.xMin, y: 0, scale: 0.3),
            to: transformToGPS(x: trackBounds.xMax, y: 0, scale: 0.3)
        )
        let height = calculateDistance(
            from: transformToGPS(x: 0, y: trackBounds.yMin, scale: 0.3),
            to: transformToGPS(x: 0, y: trackBounds.yMax, scale: 0.3)
        )
        
        print("\nTrack dimensions in meters:")
        print("Width: \(Int(width))m")
        print("Height: \(Int(height))m")
        
        // Red Bull Ring should be roughly 2-3km in each dimension
        XCTAssertGreaterThan(width, 2000)
        XCTAssertLessThan(width, 5000)
        XCTAssertGreaterThan(height, 1500)
        XCTAssertLessThan(height, 4000)
    }
    
    // MARK: - Helper Functions
    
    private func transformToGPS(
        x: Double,
        y: Double,
        scale: Double,
        rotation: Double = 1  // Austria track rotation from API
    ) -> CLLocationCoordinate2D {
        // Apply scale
        let scaledX = x * scale
        let scaledY = -y * scale  // Invert Y for GPS
        
        // Apply rotation
        let rotRad = rotation * .pi / 180
        let rotatedX = scaledX * cos(rotRad) - scaledY * sin(rotRad)
        let rotatedY = scaledX * sin(rotRad) + scaledY * cos(rotRad)
        
        // Convert to GPS using accurate factors for Austria latitude
        let latRad = austriaCenter.latitude * .pi / 180
        let metersPerDegreeLat = 111132.92 - 559.82 * cos(2 * latRad)
        let metersPerDegreeLon = 111412.84 * cos(latRad)
        
        let deltaLat = rotatedY / metersPerDegreeLat
        let deltaLon = rotatedX / metersPerDegreeLon
        
        return CLLocationCoordinate2D(
            latitude: austriaCenter.latitude + deltaLat,
            longitude: austriaCenter.longitude + deltaLon
        )
    }
    
    private func calculateDistance(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D
    ) -> Double {
        let earthRadius = 6371000.0
        
        let lat1Rad = from.latitude * .pi / 180
        let lat2Rad = to.latitude * .pi / 180
        let deltaLat = (to.latitude - from.latitude) * .pi / 180
        let deltaLon = (to.longitude - from.longitude) * .pi / 180
        
        let a = sin(deltaLat/2) * sin(deltaLat/2) +
                cos(lat1Rad) * cos(lat2Rad) *
                sin(deltaLon/2) * sin(deltaLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        return earthRadius * c
    }
}

// MARK: - Integration Test

extension AustriaTrackMapLiveTest {
    func testLiveDataIntegration() async throws {
        // This test would connect to the running server
        // and fetch real position data
        
        let url = URL(string: "http://localhost:3000/api/state")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse the response
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let positionData = json["positionData"] as? [String: Any],
           let positions = positionData["positionData"] as? [[String: Any]],
           let firstFrame = positions.first,
           let entries = firstFrame["entries"] as? [String: [String: Any]] {
            
            print("\nLive Position Data:")
            for (driver, posData) in entries.prefix(5) {
                if let x = posData["x"] as? Double,
                   let y = posData["y"] as? Double {
                    
                    let gps = transformToGPS(x: x, y: y, scale: 0.3)
                    print("Driver \(driver): (\(x), \(y)) -> GPS: \(gps.latitude), \(gps.longitude)")
                }
            }
        }
    }
}
