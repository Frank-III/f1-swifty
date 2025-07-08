//
//  MapData.swift
//  F1DashModels
//
//  Map data models for track visualization
//

import Foundation

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

public struct TrackMap: Codable {
    public let corners: [Corner]
    public let marshalLights: [Corner]
    public let marshalSectors: [Corner]
    public let candidateLap: CandidateLap
    public let circuitKey: Int
    public let circuitName: String
    public let countryIocCode: String
    public let countryKey: Int
    public let countryName: String
    public let location: String
    public let meetingKey: String
    public let meetingName: String
    public let meetingOfficialName: String
    public let raceDate: String
    public let rotation: Double
    public let round: Int
    public let trackPositionTime: [Double]
    public let x: [Double]
    public let y: [Double]
    public let year: Int
    
    public init(
        corners: [Corner],
        marshalLights: [Corner],
        marshalSectors: [Corner],
        candidateLap: CandidateLap,
        circuitKey: Int,
        circuitName: String,
        countryIocCode: String,
        countryKey: Int,
        countryName: String,
        location: String,
        meetingKey: String,
        meetingName: String,
        meetingOfficialName: String,
        raceDate: String,
        rotation: Double,
        round: Int,
        trackPositionTime: [Double],
        x: [Double],
        y: [Double],
        year: Int
    ) {
        self.corners = corners
        self.marshalLights = marshalLights
        self.marshalSectors = marshalSectors
        self.candidateLap = candidateLap
        self.circuitKey = circuitKey
        self.circuitName = circuitName
        self.countryIocCode = countryIocCode
        self.countryKey = countryKey
        self.countryName = countryName
        self.location = location
        self.meetingKey = meetingKey
        self.meetingName = meetingName
        self.meetingOfficialName = meetingOfficialName
        self.raceDate = raceDate
        self.rotation = rotation
        self.round = round
        self.trackPositionTime = trackPositionTime
        self.x = x
        self.y = y
        self.year = year
    }
}

public struct CandidateLap: Codable {
    public let driverNumber: String
    public let lapNumber: Int
    public let lapStartDate: String
    public let lapStartSessionTime: Int
    public let lapTime: Int
    public let session: String
    public let sessionStartTime: Int
    
    public init(
        driverNumber: String,
        lapNumber: Int,
        lapStartDate: String,
        lapStartSessionTime: Int,
        lapTime: Int,
        session: String,
        sessionStartTime: Int
    ) {
        self.driverNumber = driverNumber
        self.lapNumber = lapNumber
        self.lapStartDate = lapStartDate
        self.lapStartSessionTime = lapStartSessionTime
        self.lapTime = lapTime
        self.session = session
        self.sessionStartTime = sessionStartTime
    }
}

public struct Corner: Codable {
    public let angle: Double
    public let length: Double
    public let number: Int
    public let trackPosition: TrackPosition
    
    public init(
        angle: Double,
        length: Double,
        number: Int,
        trackPosition: TrackPosition
    ) {
        self.angle = angle
        self.length = length
        self.number = number
        self.trackPosition = trackPosition
    }
}

public struct TrackPosition: Codable {
    public let x: Double
    public let y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

// MARK: - Map Helper Functions

public extension TrackMap {
    /// Converts degrees to radians
    static func radians(from degrees: Double) -> Double {
        return degrees * (Double.pi / 180)
    }
    
    /// Rotates a point around a center point by the given angle
    static func rotate(
        x: Double,
        y: Double,
        angle: Double,
        centerX: Double,
        centerY: Double
    ) -> TrackPosition {
        let cos = cos(radians(from: angle))
        let sin = sin(radians(from: angle))
        
        let translatedX = x - centerX
        let translatedY = y - centerY
        
        let rotatedX = translatedX * cos - translatedY * sin
        let rotatedY = translatedY * cos + translatedX * sin
        
        return TrackPosition(
            x: rotatedY + centerX,
            y: rotatedX + centerY
        )
    }
    
    /// Calculates the distance between two points
    static func distance(from point1: TrackPosition, to point2: TrackPosition) -> Double {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        return sqrt(dx * dx + dy * dy)
    }
    
    /// Finds the closest point index in an array of points
    static func findClosestPointIndex(
        to target: TrackPosition,
        in points: [TrackPosition]
    ) -> Int {
        var minDistance = Double.infinity
        var closestIndex = 0
        
        for (index, point) in points.enumerated() {
            let dist = distance(from: target, to: point)
            if dist < minDistance {
                minDistance = dist
                closestIndex = index
            }
        }
        
        return closestIndex
    }
}

// MARK: - Map Sector

public struct MapSector {
    public let number: Int
    public let start: TrackPosition
    public let end: TrackPosition
    public let points: [TrackPosition]
    
    public init(number: Int, start: TrackPosition, end: TrackPosition, points: [TrackPosition]) {
        self.number = number
        self.start = start
        self.end = end
        self.points = points
    }
}

public extension TrackMap {
    /// Creates sectors from marshal sectors
    func createSectors() -> [MapSector] {
        var sectors: [MapSector] = []
        let trackPoints = zip(x, y).map { TrackPosition(x: $0, y: $1) }
        
        for i in 0..<marshalSectors.count {
            let sectorStart = marshalSectors[i].trackPosition
            let sectorEnd = i + 1 < marshalSectors.count ? 
                marshalSectors[i + 1].trackPosition : 
                marshalSectors[0].trackPosition
            
            sectors.append(MapSector(
                number: i + 1,
                start: sectorStart,
                end: sectorEnd,
                points: []
            ))
        }
        
        return sectors
    }
}