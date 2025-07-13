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
    
    /// Custom decoder that handles floating-point precision issues
    static func decode(from data: Data) throws -> TrackMap {
        // First, try the standard decoder
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode(TrackMap.self, from: data)
        } catch DecodingError.dataCorrupted(_) {
            // If we get a data corrupted error, it's likely due to precision issues
            // Fall back to JSONSerialization with more lenient parsing
            return try decodeWithJSONSerialization(from: data)
        }
    }
    
    private static func decodeWithJSONSerialization(from data: Data) throws -> TrackMap {
        // Parse with JSONSerialization which handles numbers differently
        guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: [],
                debugDescription: "Root object is not a dictionary"
            ))
        }
        
        // Print available keys for debugging
        print("Available JSON keys: \(Array(json.keys).sorted())")
        
        // Extract and convert all required fields with detailed error reporting
        var missingFields: [String] = []
        
        // Parse complex fields first
        let corners: [Corner]
        do {
            corners = try parseCorners(from: json["corners"]) ?? []
        } catch {
            print("Error parsing corners: \(error)")
            corners = []
        }
        
        let marshalLights: [Corner]
        do {
            marshalLights = try parseCorners(from: json["marshalLights"]) ?? []
        } catch {
            print("Error parsing marshalLights: \(error)")
            marshalLights = []
        }
        
        let marshalSectors: [Corner]
        do {
            marshalSectors = try parseCorners(from: json["marshalSectors"]) ?? []
        } catch {
            print("Error parsing marshalSectors: \(error)")
            marshalSectors = []
        }
        
        let candidateLap: CandidateLap
        do {
            candidateLap = try parseCandidateLap(from: json["candidateLap"]) ?? CandidateLap(
                driverNumber: "",
                lapNumber: 0,
                lapStartDate: "",
                lapStartSessionTime: 0,
                lapTime: 0,
                session: "",
                sessionStartTime: 0
            )
        } catch {
            print("Error parsing candidateLap: \(error)")
            candidateLap = CandidateLap(
                driverNumber: "",
                lapNumber: 0,
                lapStartDate: "",
                lapStartSessionTime: 0,
                lapTime: 0,
                session: "",
                sessionStartTime: 0
            )
        }
        
        // Parse simple fields with nil coalescing and error tracking
        let circuitKey = json["circuitKey"] as? Int ?? {
            missingFields.append("circuitKey (found: \(type(of: json["circuitKey"])))")
            return 0
        }()
        
        let circuitName = json["circuitName"] as? String ?? {
            missingFields.append("circuitName (found: \(type(of: json["circuitName"])))")
            return ""
        }()
        
        let countryIocCode = json["countryIocCode"] as? String ?? {
            missingFields.append("countryIocCode (found: \(type(of: json["countryIocCode"])))")
            return ""
        }()
        
        let countryKey = json["countryKey"] as? Int ?? {
            missingFields.append("countryKey (found: \(type(of: json["countryKey"])))")
            return 0
        }()
        
        let countryName = json["countryName"] as? String ?? {
            missingFields.append("countryName (found: \(type(of: json["countryName"])))")
            return ""
        }()
        
        let location = json["location"] as? String ?? {
            missingFields.append("location (found: \(type(of: json["location"])))")
            return ""
        }()
        
        let meetingKey = json["meetingKey"] as? String ?? {
            missingFields.append("meetingKey (found: \(type(of: json["meetingKey"])))")
            return ""
        }()
        
        let meetingName = json["meetingName"] as? String ?? {
            missingFields.append("meetingName (found: \(type(of: json["meetingName"])))")
            return ""
        }()
        
        let meetingOfficialName = json["meetingOfficialName"] as? String ?? {
            missingFields.append("meetingOfficialName (found: \(type(of: json["meetingOfficialName"])))")
            return ""
        }()
        
        let raceDate = json["raceDate"] as? String ?? {
            missingFields.append("raceDate (found: \(type(of: json["raceDate"])))")
            return ""
        }()
        
        let rotation = parseDouble(from: json["rotation"]) ?? {
            missingFields.append("rotation (found: \(type(of: json["rotation"])))")
            return 0.0
        }()
        
        let round = json["round"] as? Int ?? {
            missingFields.append("round (found: \(type(of: json["round"])))")
            return 0
        }()
        
        let trackPositionTime = parseDoubleArray(from: json["trackPositionTime"]) ?? {
            missingFields.append("trackPositionTime (found: \(type(of: json["trackPositionTime"])))")
            return []
        }()
        
        let x = parseDoubleArray(from: json["x"]) ?? {
            missingFields.append("x (found: \(type(of: json["x"])))")
            return []
        }()
        
        let y = parseDoubleArray(from: json["y"]) ?? {
            missingFields.append("y (found: \(type(of: json["y"])))")
            return []
        }()
        
        let year = json["year"] as? Int ?? {
            missingFields.append("year (found: \(type(of: json["year"])))")
            return 2023  // Default to 2023 if missing
        }()
        
        // Only throw error for critical missing fields
        let criticalFields = ["x", "y", "circuitKey"]
        let criticalMissing = missingFields.filter { field in
            criticalFields.contains { critical in field.hasPrefix(critical) }
        }
        
        if !criticalMissing.isEmpty {
            print("Critical missing fields: \(criticalMissing)")
            print("All missing/invalid fields: \(missingFields)")
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: [],
                debugDescription: "Critical fields missing: \(criticalMissing.joined(separator: ", "))"
            ))
        }
        
        if !missingFields.isEmpty {
            print("Non-critical missing/invalid fields (using defaults): \(missingFields)")
        }
        
        return TrackMap(
            corners: corners,
            marshalLights: marshalLights,
            marshalSectors: marshalSectors,
            candidateLap: candidateLap,
            circuitKey: circuitKey,
            circuitName: circuitName,
            countryIocCode: countryIocCode,
            countryKey: countryKey,
            countryName: countryName,
            location: location,
            meetingKey: meetingKey,
            meetingName: meetingName,
            meetingOfficialName: meetingOfficialName,
            raceDate: raceDate,
            rotation: rotation,
            round: round,
            trackPositionTime: trackPositionTime,
            x: x,
            y: y,
            year: year
        )
    }
    
    private static func parseCorners(from value: Any?) throws -> [Corner]? {
        guard let array = value as? [[String: Any]] else { return nil }
        
        return try array.map { dict in
            guard let angle = parseDouble(from: dict["angle"]),
                  let length = parseDouble(from: dict["length"]),
                  let number = dict["number"] as? Int,
                  let trackPositionDict = dict["trackPosition"] as? [String: Any],
                  let x = parseDouble(from: trackPositionDict["x"]),
                  let y = parseDouble(from: trackPositionDict["y"]) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Invalid corner data"
                ))
            }
            
            return Corner(
                angle: angle,
                length: length,
                number: number,
                trackPosition: TrackPosition(x: x, y: y)
            )
        }
    }
    
    private static func parseCandidateLap(from value: Any?) throws -> CandidateLap? {
        guard let dict = value as? [String: Any],
              let driverNumber = dict["driverNumber"] as? String,
              let lapNumber = dict["lapNumber"] as? Int,
              let lapStartDate = dict["lapStartDate"] as? String,
              let lapStartSessionTime = dict["lapStartSessionTime"] as? Int,
              let lapTime = dict["lapTime"] as? Int,
              let session = dict["session"] as? String,
              let sessionStartTime = dict["sessionStartTime"] as? Int else {
            return nil
        }
        
        return CandidateLap(
            driverNumber: driverNumber,
            lapNumber: lapNumber,
            lapStartDate: lapStartDate,
            lapStartSessionTime: lapStartSessionTime,
            lapTime: lapTime,
            session: session,
            sessionStartTime: sessionStartTime
        )
    }
    
    private static func parseDouble(from value: Any?) -> Double? {
        if let double = value as? Double {
            return double
        } else if let int = value as? Int {
            return Double(int)
        } else if let string = value as? String, let double = Double(string) {
            return double
        } else if let number = value as? NSNumber {
            return number.doubleValue
        }
        return nil
    }
    
    private static func parseDoubleArray(from value: Any?) -> [Double]? {
        guard let array = value as? [Any] else { return nil }
        
        return array.compactMap { element in
            parseDouble(from: element)
        }
    }
}