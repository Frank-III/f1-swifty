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
        
//        let year = Calendar.current.component(.year, from: Date())
        let year = 2023
        let url = URL(string: "https://api.multiviewer.app/api/v1/circuits/\(circuitKey)/\(year)")!
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MapServiceError.invalidResponse
        }
        
        do {
            // Use our custom decoder that handles precision issues
            let map = try TrackMap.decode(from: data)
            
            // Cache the result
            mapCache[circuitKey] = map
            
            return map
        } catch {
            print("Error decoding track map: \(error)")
            throw MapServiceError.decodingError
        }
    }
}

enum MapServiceError: Error {
    case invalidResponse
    case decodingError
}
