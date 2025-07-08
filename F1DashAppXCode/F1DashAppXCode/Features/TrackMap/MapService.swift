//
//  MapService.swift
//  F1DashApp
//
//  Service for fetching track map data
//

import Foundation
import F1DashModels

@MainActor
final class MapService: ObservableObject {
    private let session = URLSession.shared
    private var mapCache: [Int: TrackMap] = [:]
    
    func fetchMap(for circuitKey: Int) async throws -> TrackMap {
        // Check cache first
        if let cachedMap = mapCache[circuitKey] {
            return cachedMap
        }
        
        let year = Calendar.current.component(.year, from: Date())
        let url = URL(string: "https://api.multiviewer.app/api/v1/circuits/\(circuitKey)/\(year)")!
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MapServiceError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let map = try decoder.decode(TrackMap.self, from: data)
            
            // Cache the result
            mapCache[circuitKey] = map
            
            return map
        } catch let decodingError as DecodingError {
            // If decoding fails due to floating-point precision issues,
            // try parsing the JSON manually with more lenient number handling
            if case .dataCorrupted = decodingError {
                print("Warning: JSON decoding failed, attempting fallback parsing")
                // For now, rethrow the error - a more complex solution would involve
                // using JSONSerialization with .allowFragments option
                throw MapServiceError.decodingError
            }
            throw decodingError
        }
    }
}

enum MapServiceError: Error {
    case invalidResponse
    case decodingError
}
