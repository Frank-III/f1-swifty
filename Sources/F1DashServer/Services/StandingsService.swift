import Foundation
import SwiftSoup
import Logging
import F1DashModels
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Service for fetching F1 standings from formula1.com
actor StandingsService {
    
    private let logger = Logger(label: "StandingsService")
    private var driverStandingsCache: DriverStandings?
    private var teamStandingsCache: TeamStandings?
    private var lastDriverFetch: Date?
    private var lastTeamFetch: Date?
    private let cacheTimeout: TimeInterval = 3600 // 1 hour
    
    // MARK: - Public Interface
    
    /// Fetch driver standings for a given year
    func getDriverStandings(year: Int) async throws -> DriverStandings {
        // Check cache
        if let cached = driverStandingsCache,
           cached.year == year,
           let lastFetch = lastDriverFetch,
           Date().timeIntervalSince(lastFetch) < cacheTimeout {
            return cached
        }
        
        // Fetch fresh data
        logger.info("Fetching fresh driver standings for year \(year)")
        let standings = try await fetchDriverStandings(year: year)
        
        // Update cache
        driverStandingsCache = standings
        lastDriverFetch = Date()
        
        return standings
    }
    
    /// Fetch team/constructor standings for a given year
    func getTeamStandings(year: Int) async throws -> TeamStandings {
        // Check cache
        if let cached = teamStandingsCache,
           cached.year == year,
           let lastFetch = lastTeamFetch,
           Date().timeIntervalSince(lastFetch) < cacheTimeout {
            return cached
        }
        
        // Fetch fresh data
        logger.info("Fetching fresh team standings for year \(year)")
        let standings = try await fetchTeamStandings(year: year)
        
        // Update cache
        teamStandingsCache = standings
        lastTeamFetch = Date()
        
        return standings
    }
    
    // MARK: - Private Implementation
    
    private func fetchDriverStandings(year: Int) async throws -> DriverStandings {
        let urlString = "https://www.formula1.com/en/results/\(year)/drivers"
        logger.info("Fetching driver standings from URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            logger.error("Invalid URL for driver standings: \(urlString)")
            throw StandingsError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                logger.info("Driver standings HTTP response code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    logger.warning("Non-200 status code for driver standings: \(httpResponse.statusCode)")
                }
            }
            
            guard let html = String(data: data, encoding: .utf8) else {
                logger.error("Failed to decode HTML data as UTF-8 string")
                throw StandingsError.invalidData
            }
            
            logger.info("Successfully fetched HTML content, length: \(html.count) characters")
            return try parseDriverStandings(html: html, year: year)
        } catch {
            logger.error("Failed to fetch driver standings: \(error)")
            throw error
        }
    }
    
    private func fetchTeamStandings(year: Int) async throws -> TeamStandings {
        let urlString = "https://www.formula1.com/en/results/\(year)/team"
        logger.info("Fetching team standings from URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            logger.error("Invalid URL for team standings: \(urlString)")
            throw StandingsError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                logger.info("Team standings HTTP response code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    logger.warning("Non-200 status code for team standings: \(httpResponse.statusCode)")
                }
            }
            
            guard let html = String(data: data, encoding: .utf8) else {
                logger.error("Failed to decode HTML data as UTF-8 string")
                throw StandingsError.invalidData
            }
            
            logger.info("Successfully fetched HTML content, length: \(html.count) characters")
            return try parseTeamStandings(html: html, year: year)
        } catch {
            logger.error("Failed to fetch team standings: \(error)")
            throw error
        }
    }
    
    private func parseDriverStandings(html: String, year: Int) throws -> DriverStandings {
        logger.info("Starting to parse driver standings HTML")
        
        let doc = try SwiftSoup.parse(html)
        var standings: [DriverStanding] = []
        
        // Try to find the F1 table
        var tableElement: Element? = nil
        
        // First try the modern F1 table format
        let f1Tables = try doc.select("table.f1-table.f1-table-with-data.w-full")
        if !f1Tables.isEmpty() {
            logger.info("Found F1 table format")
            tableElement = f1Tables.first()
        }
        
        // Fall back to old resultsarchive-table format
        if tableElement == nil {
            let archiveTables = try doc.select("table.resultsarchive-table")
            if !archiveTables.isEmpty() {
                logger.info("Found resultsarchive-table format")
                tableElement = archiveTables.first()
            }
        }
        
        guard let table = tableElement else {
            logger.error("Could not find standings table in HTML")
            // Log a snippet of the HTML to help debug
            let snippet = String(html.prefix(1000))
            logger.debug("HTML snippet: \(snippet)")
            throw StandingsError.parseError("Could not find standings table")
        }
        
        // Get rows from the table body
        let rows = try table.select("tbody tr")
        logger.info("Found \(rows.count) rows to parse")
        
        for (index, row) in rows.enumerated() {
            let cells = try row.select("td")
            if cells.size() < 5 {
                logger.warning("Row \(index) has only \(cells.size()) cells, skipping (expected at least 5)")
                continue
            }
            
            do {
                // Extract position from first cell
                let positionText = try cells[0].text()
                let position = Int(positionText) ?? 0
                
                // Extract driver info from second cell
                let driverCell = cells[1]
                // Find all span elements within the link
                let driverLink = try driverCell.select("a").first()
                var fullName = ""
                var driverCode = ""
                
                if let link = driverLink {
                    // Find the spans within the link (skip the avatar span)
                    let spans = try link.select("span").array()
                    
                    // Usually the structure is:
                    // span 0: avatar image
                    // span 1: contains the name spans
                    if spans.count > 1 {
                        let nameContainer = spans[1]
                        let nameText = try nameContainer.text()
                        
                        // Extract the three-letter code (like PIA, NOR, VER)
                        // It's in a span with class containing "md:hidden"
                        if let codeSpan = try? nameContainer.select("span.md\\:hidden").first() {
                            driverCode = try codeSpan.text()
                        }
                        
                        // Extract full name from the visible spans
                        let firstNameSpans = try nameContainer.select("span.max-lg\\:hidden").array()
                        let firstName = firstNameSpans.isEmpty ? "" : try firstNameSpans[0].text()
                        
                        // Last name is in the span that's hidden on medium screens
                        let lastNameSpans = try nameContainer.select("span.max-md\\:hidden").array()
                        let lastName = lastNameSpans.isEmpty ? "" : try lastNameSpans[0].text()
                        
                        fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                        
                        // If we couldn't parse the name properly, fallback to full text
                        if fullName.trimmingCharacters(in: .whitespaces).isEmpty {
                            fullName = nameText.replacingOccurrences(of: driverCode, with: "").trimmingCharacters(in: .whitespaces)
                        }
                    }
                }
                
                // Skip nationality cell (index 2)
                
                // Extract team name from fourth cell
                let teamCell = cells[3]
                let teamName = try teamCell.select("a").text().trimmingCharacters(in: .whitespaces)
                
                // Extract points from fifth cell
                let pointsText = try cells[4].text()
                let points = Double(pointsText) ?? 0.0
                
                logger.debug("Parsed driver: position=\(position), name=\(fullName), code=\(driverCode), team=\(teamName), points=\(points)")
                
                // Create standing entry
                let standing = DriverStanding(
                    position: position,
                    driverName: fullName,
                    driverNumber: driverCode, // Using the 3-letter code as driver number
                    teamName: teamName,
                    points: points,
                    wins: 0 // Wins data not available in this view
                )
                
                standings.append(standing)
            } catch {
                logger.error("Failed to parse row \(index): \(error)")
            }
        }
        
        logger.info("Successfully parsed \(standings.count) driver standings")
        return DriverStandings(year: year, standings: standings)
    }
    
    private func parseTeamStandings(html: String, year: Int) throws -> TeamStandings {
        logger.info("Starting to parse team standings HTML")
        
        let doc = try SwiftSoup.parse(html)
        var standings: [TeamStanding] = []
        
        // Try to find the F1 table
        var tableElement: Element? = nil
        
        // First try the modern F1 table format
        let f1Tables = try doc.select("table.f1-table.f1-table-with-data.w-full")
        if !f1Tables.isEmpty() {
            logger.info("Found F1 table format")
            tableElement = f1Tables.first()
        }
        
        // Fall back to old resultsarchive-table format
        if tableElement == nil {
            let archiveTables = try doc.select("table.resultsarchive-table")
            if !archiveTables.isEmpty() {
                logger.info("Found resultsarchive-table format")
                tableElement = archiveTables.first()
            }
        }
        
        guard let table = tableElement else {
            logger.error("Could not find standings table in HTML")
            // Log a snippet of the HTML to help debug
            let snippet = String(html.prefix(500))
            logger.debug("HTML snippet: \(snippet)")
            throw StandingsError.parseError("Could not find standings table")
        }
        
        // Parse each row
        let rows = try table.select("tbody tr")
        logger.info("Found \(rows.count) rows in the standings table")
        
        for (index, row) in rows.enumerated() {
            let cells = try row.select("td")
            if cells.size() < 3 {
                logger.warning("Row \(index) has only \(cells.size()) cells, skipping (expected at least 3)")
                continue
            }
            
            do {
                // Extract data from cells
                let positionText = try cells[0].text()
                let position = Int(positionText) ?? 0
                
                // Team name is in a link within the cell
                let teamNameCell = cells[1]
                let teamName = try teamNameCell.select("a").text()
                
                // If no link found, try getting the text directly
                let finalTeamName = teamName.isEmpty ? try teamNameCell.text() : teamName
                
                // Points
                let pointsText = try cells[2].text()
                let points = Double(pointsText) ?? 0.0
                
                logger.debug("Parsed team: position=\(position), name=\(finalTeamName), points=\(points)")
                
                // Create standing entry
                let standing = TeamStanding(
                    position: position,
                    teamName: finalTeamName,
                    points: points
                )
                
                standings.append(standing)
            } catch {
                logger.error("Failed to parse row \(index): \(error)")
            }
        }
        
        logger.info("Successfully parsed \(standings.count) team standings")
        return TeamStandings(year: year, standings: standings)
    }
}

// MARK: - Error Types

enum StandingsError: Error {
    case invalidURL
    case invalidData
    case parseError(String)
}