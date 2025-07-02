//
//  TrackMapTests.swift
//  F1DashAppTests
//
//  Tests for TrackMap functionality
//

import XCTest
import SwiftUI
@testable import F1DashApp
@testable import F1DashModels

@MainActor
final class TrackMapTests: XCTestCase {
    
    // MARK: - Map Data Tests
    
    func testTrackMapCreation() {
        let testMap = createTestTrackMap()
        
        XCTAssertEqual(testMap.circuitKey, 123)
        XCTAssertEqual(testMap.circuitName, "Test Circuit")
        XCTAssertEqual(testMap.rotation, 45.0)
        XCTAssertEqual(testMap.x.count, 4)
        XCTAssertEqual(testMap.y.count, 4)
        XCTAssertEqual(testMap.corners.count, 2)
        XCTAssertEqual(testMap.marshalSectors.count, 2)
    }
    
    func testTrackPositionCreation() {
        let position = TrackPosition(x: 100.0, y: 200.0)
        
        XCTAssertEqual(position.x, 100.0)
        XCTAssertEqual(position.y, 200.0)
    }
    
    func testCornerCreation() {
        let trackPosition = TrackPosition(x: 150.0, y: 250.0)
        let corner = Corner(angle: 90.0, length: 50.0, number: 1, trackPosition: trackPosition)
        
        XCTAssertEqual(corner.angle, 90.0)
        XCTAssertEqual(corner.length, 50.0)
        XCTAssertEqual(corner.number, 1)
        XCTAssertEqual(corner.trackPosition.x, 150.0)
        XCTAssertEqual(corner.trackPosition.y, 250.0)
    }
    
    // MARK: - Coordinate Transformation Tests
    
    func testRadiansConversion() {
        let degrees = 90.0
        let radians = TrackMap.radians(from: degrees)
        let expected = Double.pi / 2
        
        XCTAssertEqual(radians, expected, accuracy: 0.0001)
    }
    
    func testPointRotation() {
        let point = TrackPosition(x: 10.0, y: 0.0)
        let rotated = TrackMap.rotate(
            x: point.x,
            y: point.y,
            angle: 90.0,
            centerX: 0.0,
            centerY: 0.0
        )
        
        // After 90° rotation, (10, 0) should become approximately (0, 10)
        XCTAssertEqual(rotated.x, 0.0, accuracy: 0.0001)
        XCTAssertEqual(rotated.y, 10.0, accuracy: 0.0001)
    }
    
    func testPointRotationWithCenter() {
        let point = TrackPosition(x: 20.0, y: 10.0)
        let rotated = TrackMap.rotate(
            x: point.x,
            y: point.y,
            angle: 90.0,
            centerX: 10.0,
            centerY: 10.0
        )
        
        // Rotating (20, 10) around (10, 10) by 90° should give (10, 20)
        XCTAssertEqual(rotated.x, 10.0, accuracy: 0.0001)
        XCTAssertEqual(rotated.y, 20.0, accuracy: 0.0001)
    }
    
    func testDistanceCalculation() {
        let point1 = TrackPosition(x: 0.0, y: 0.0)
        let point2 = TrackPosition(x: 3.0, y: 4.0)
        let distance = TrackMap.distance(from: point1, to: point2)
        
        // Distance should be 5 (3-4-5 triangle)
        XCTAssertEqual(distance, 5.0, accuracy: 0.0001)
    }
    
    func testClosestPointIndex() {
        let target = TrackPosition(x: 2.0, y: 2.0)
        let points = [
            TrackPosition(x: 0.0, y: 0.0),
            TrackPosition(x: 1.0, y: 1.0),
            TrackPosition(x: 2.5, y: 2.5),
            TrackPosition(x: 5.0, y: 5.0)
        ]
        
        let closestIndex = TrackMap.findClosestPointIndex(to: target, in: points)
        
        // Point at index 2 (2.5, 2.5) should be closest to (2.0, 2.0)
        XCTAssertEqual(closestIndex, 2)
    }
    
    // MARK: - Sector Creation Tests
    
    func testSectorCreation() {
        let testMap = createTestTrackMap()
        let sectors = testMap.createSectors()
        
        XCTAssertEqual(sectors.count, 2) // Should match marshalSectors count
        XCTAssertEqual(sectors[0].number, 1)
        XCTAssertEqual(sectors[1].number, 2)
    }
    
    // MARK: - MapService Tests
    
    func testMapServiceInitialization() {
        let mapService = MapService()
        XCTAssertNotNil(mapService)
    }
    
    // MARK: - ViewModel Tests
    
    func testTrackMapViewModelInitialization() {
        let appEnvironment = AppEnvironment()
        let viewModel = TrackMapViewModel(appEnvironment: appEnvironment)
        
        XCTAssertNotNil(viewModel)
        XCTAssertFalse(viewModel.hasMapData)
        XCTAssertEqual(viewModel.minX, 0)
        XCTAssertEqual(viewModel.maxX, 1000)
        XCTAssertEqual(viewModel.minY, 0)
        XCTAssertEqual(viewModel.maxY, 1000)
    }
    
    func testDriverMapPositionCreation() {
        let position = DriverMapPosition(
            racingNumber: "44",
            tla: "HAM",
            point: CGPoint(x: 100, y: 200),
            color: .blue,
            isOnTrack: true,
            isSafetyCar: false,
            isInPit: false,
            isHidden: false,
            isFavorite: true
        )
        
        XCTAssertEqual(position.racingNumber, "44")
        XCTAssertEqual(position.tla, "HAM")
        XCTAssertEqual(position.point.x, 100)
        XCTAssertEqual(position.point.y, 200)
        XCTAssertTrue(position.isOnTrack)
        XCTAssertFalse(position.isSafetyCar)
        XCTAssertFalse(position.isInPit)
        XCTAssertFalse(position.isHidden)
        XCTAssertTrue(position.isFavorite)
    }
    
    func testRenderedSectorCreation() {
        let points = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 100, y: 100),
            CGPoint(x: 200, y: 0)
        ]
        
        let sector = RenderedSector(
            number: 1,
            points: points,
            color: .yellow,
            strokeWidth: 8.0
        )
        
        XCTAssertEqual(sector.number, 1)
        XCTAssertEqual(sector.points.count, 3)
        XCTAssertEqual(sector.color, .yellow)
        XCTAssertEqual(sector.strokeWidth, 8.0)
    }
    
    func testCornerPositionCreation() {
        let corner = CornerPosition(
            number: 1,
            position: CGPoint(x: 50, y: 75)
        )
        
        XCTAssertEqual(corner.number, 1)
        XCTAssertEqual(corner.position.x, 50)
        XCTAssertEqual(corner.position.y, 75)
    }
    
    // MARK: - Color Extension Tests
    
    func testColorFromHex() {
        let redColor = Color(hex: "FF0000")
        XCTAssertNotNil(redColor)
        
        let blueColor = Color(hex: "#0000FF")
        XCTAssertNotNil(blueColor)
        
        let invalidColor = Color(hex: "INVALID")
        XCTAssertNil(invalidColor)
        
        let shortHex = Color(hex: "FFF")
        XCTAssertNil(shortHex) // Should be nil for invalid length
    }
    
    func testColorFromHexWithAlpha() {
        let colorWithAlpha = Color(hex: "FF000080")
        XCTAssertNotNil(colorWithAlpha)
    }
    
    // MARK: - Settings Tests
    
    func testSettingsStoreCornerNumbers() async {
        let settings = SettingsStore()
        
        // Test default value
        XCTAssertFalse(settings.showCornerNumbers)
        
        // Test setting value
        await MainActor.run {
            settings.$showCornerNumbers.withLock { $0 = true }
            XCTAssertTrue(settings.showCornerNumbers)
        }
        
        // Test reset to defaults
        await MainActor.run {
            settings.resetToDefaults()
            XCTAssertFalse(settings.showCornerNumbers)
        }
    }
    
    func testFavoriteDrivers() async {
        let settings = SettingsStore()
        
        await MainActor.run {
            // Test initial state
            XCTAssertFalse(settings.isFavoriteDriver("44"))
            
            // Test adding favorite
            settings.toggleFavoriteDriver("44")
            XCTAssertTrue(settings.isFavoriteDriver("44"))
            
            // Test removing favorite
            settings.toggleFavoriteDriver("44")
            XCTAssertFalse(settings.isFavoriteDriver("44"))
            
            // Test multiple favorites
            settings.toggleFavoriteDriver("44")
            settings.toggleFavoriteDriver("33")
            
            XCTAssertTrue(settings.isFavoriteDriver("44"))
            XCTAssertTrue(settings.isFavoriteDriver("33"))
            XCTAssertFalse(settings.isFavoriteDriver("77"))
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestTrackMap() -> TrackMap {
        let trackPosition1 = TrackPosition(x: 0.0, y: 0.0)
        let trackPosition2 = TrackPosition(x: 100.0, y: 100.0)
        
        let corner1 = Corner(angle: 45.0, length: 50.0, number: 1, trackPosition: trackPosition1)
        let corner2 = Corner(angle: 135.0, length: 75.0, number: 2, trackPosition: trackPosition2)
        
        let candidateLap = CandidateLap(
            driverNumber: "44",
            lapNumber: 1,
            lapStartDate: "2024-01-01T00:00:00Z",
            lapStartSessionTime: 0,
            lapTime: 90000,
            session: "Race",
            sessionStartTime: 0
        )
        
        return TrackMap(
            corners: [corner1, corner2],
            marshalLights: [corner1, corner2],
            marshalSectors: [corner1, corner2],
            candidateLap: candidateLap,
            circuitKey: 123,
            circuitName: "Test Circuit",
            countryIocCode: "TST",
            countryKey: 456,
            countryName: "Test Country",
            location: "Test Location",
            meetingKey: "test-meeting",
            meetingName: "Test Meeting",
            meetingOfficialName: "Official Test Meeting",
            raceDate: "2024-01-01",
            rotation: 45.0,
            round: 1,
            trackPositionTime: [0.0, 1.0, 2.0, 3.0],
            x: [0.0, 100.0, 100.0, 0.0],
            y: [0.0, 0.0, 100.0, 100.0],
            year: 2024
        )
    }
}

// MARK: - Mock Data Tests

extension TrackMapTests {
    func testMockDataGeneration() {
        let mockDrivers = createMockDrivers()
        let mockPositions = createMockPositions()
        
        XCTAssertEqual(mockDrivers.count, 3)
        XCTAssertEqual(mockPositions.count, 3)
        
        let hamiltonData = mockDrivers["44"]
        XCTAssertNotNil(hamiltonData)
        XCTAssertEqual(hamiltonData?.tla, "HAM")
        XCTAssertEqual(hamiltonData?.teamColour, "00D2BE")
        
        let hamiltonPosition = mockPositions["44"]
        XCTAssertNotNil(hamiltonPosition)
        XCTAssertEqual(hamiltonPosition?.status, "OnTrack")
    }
    
    private func createMockDrivers() -> [String: Driver] {
        return [
            "44": Driver(
                racingNumber: "44",
                broadcastName: "L HAMILTON",
                fullName: "Lewis Hamilton",
                tla: "HAM",
                line: 1,
                teamName: "Mercedes",
                teamColour: "00D2BE",
                firstName: "Lewis",
                lastName: "Hamilton",
                reference: "HAMILE01",
                headshotUrl: "",
                countryCode: "GBR"
            ),
            "33": Driver(
                racingNumber: "33",
                broadcastName: "M VERSTAPPEN",
                fullName: "Max Verstappen",
                tla: "VER",
                line: 2,
                teamName: "Red Bull Racing",
                teamColour: "0600EF",
                firstName: "Max",
                lastName: "Verstappen",
                reference: "VERMAX01",
                headshotUrl: "",
                countryCode: "NLD"
            ),
            "16": Driver(
                racingNumber: "16",
                broadcastName: "C LECLERC",
                fullName: "Charles Leclerc",
                tla: "LEC",
                line: 3,
                teamName: "Ferrari",
                teamColour: "DC143C",
                firstName: "Charles",
                lastName: "Leclerc",
                reference: "LECCHA01",
                headshotUrl: "",
                countryCode: "MON"
            )
        ]
    }
    
    private func createMockPositions() -> [String: PositionCar] {
        return [
            "44": PositionCar(status: "OnTrack", x: 1000.0, y: 2000.0, z: 100.0),
            "33": PositionCar(status: "OnTrack", x: 1100.0, y: 2100.0, z: 110.0),
            "16": PositionCar(status: "OnTrack", x: 1200.0, y: 2200.0, z: 120.0)
        ]
    }
}