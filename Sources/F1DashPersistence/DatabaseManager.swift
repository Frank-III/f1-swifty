import Foundation
import PostgresNIO
import Logging
import F1DashModels
import ServiceLifecycle

/// Database manager for PostgreSQL/TimescaleDB connection pooling and operations
public actor DatabaseManager: Service {
    public static let shared = DatabaseManager()
    
    // MARK: - Properties
    
    private var client: PostgresClient?
    private let logger = Logger(label: "DatabaseManager")
    private var clientTask: Task<Void, any Error>?
    
    // Database configuration
    private let host: String
    private let port: Int
    private let database: String
    private let username: String
    private let password: String
    
    // MARK: - Initialization
    
    private init() {
        // Read configuration from environment variables
        self.host = ProcessInfo.processInfo.environment["DATABASE_HOST"] ?? "localhost"
        self.port = Int(ProcessInfo.processInfo.environment["DATABASE_PORT"] ?? "5432") ?? 5432
        self.database = ProcessInfo.processInfo.environment["DATABASE_NAME"] ?? "f1dash"
        self.username = ProcessInfo.processInfo.environment["DATABASE_USER"] ?? "postgres"
        self.password = ProcessInfo.processInfo.environment["DATABASE_PASSWORD"] ?? "password"
        
        logger.info("DatabaseManager initialized with host: \(host):\(port), database: \(database)")
    }
  
    // MARK: - Connection Management
    
    /// Initialize database connection
    public func run() async throws {
        guard client == nil else {
            logger.debug("Database already connected")
            return
        }
        
        logger.info("Connecting to PostgreSQL database...")
        
        let config = PostgresClient.Configuration(
            host: host,
            port: port,
            username: username,
            password: password,
            database: database,
            tls: .disable
        )
        
        do {
            client = PostgresClient(configuration: config)
            
            // Start the client in a background task
            clientTask = Task {
                await client!.run()
            }
            
            logger.info("Successfully connected to PostgreSQL database")
            
            // Run database migrations
            try await MigrationManager.runMigrations()
            
        } catch {
            logger.error("Failed to connect to database: \(error)")
            throw DatabaseError.connectionFailed(error)
        }
    }
    
    /// Disconnect from database
    public func disconnect() async {
        guard let task = clientTask else {
            return
        }
        
        logger.info("Disconnecting from database...")
        task.cancel()
        client = nil
        clientTask = nil
        logger.info("Disconnected from database")
    }
    
    /// Get database client (ensures connected)
    public func getClient() async throws -> PostgresClient {
        if client == nil {
            try await run()
        }
        
        guard let client = client else {
            throw DatabaseError.notConnected
        }
        
        return client
    }
    
    
    // MARK: - Data Insertion
    
    /// Insert timing driver data (mirrors Rust insert_timing_driver)
    public func insertTimingDriver(_ data: TimingDriverData) async throws {
        let client = try await getClient()
        
        do {
            try await client.query(
                """
                INSERT INTO timing_driver (nr, lap, gap, leader_gap, laptime, sector_1, sector_2, sector_3)
                VALUES (\(data.nr), \(data.lap), \(data.gap), \(data.leaderGap), \(data.laptime), \(data.sector1), \(data.sector2), \(data.sector3))
                """,
                logger: logger
            )
            
            logger.trace("Inserted timing data for driver \(data.nr)")
            
        } catch {
            logger.error("Failed to insert timing driver data: \(error)")
            throw DatabaseError.insertFailed(error)
        }
    }
    
    /// Insert tire driver data (mirrors Rust insert_tire_driver)
    public func insertTireDriver(_ data: TireDriverData) async throws {
        let client = try await getClient()
        
        do {
            try await client.query(
                """
                INSERT INTO tire_driver (nr, lap, compound, laps)
                VALUES (\(data.nr), \(data.lap), \(data.compound), \(data.laps))
                """,
                logger: logger
            )
            
            logger.trace("Inserted tire data for driver \(data.nr)")
            
        } catch {
            logger.error("Failed to insert tire driver data: \(error)")
            throw DatabaseError.insertFailed(error)
        }
    }
    
    // MARK: - Data Querying
    
    /// Get lap times for a driver (mirrors Rust get_laptimes)
    public func getLaptimes(for driverNr: String) async throws -> [Laptime] {
        let client = try await getClient()
        
        do {
            let rows = try await client.query(
                """
                SELECT
                    lap,
                    MIN(laptime) AS laptime,
                    MIN(time) AS time
                FROM timing_driver
                WHERE nr = \(driverNr) AND laptime != 0
                GROUP BY lap
                ORDER BY lap
                """,
                logger: logger
            )
            
            var laptimes: [Laptime] = []
            for try await (lap, laptime, time) in rows.decode((Int?, Int64, Date).self) {
                laptimes.append(Laptime(
                    time: time,
                    lap: lap,
                    laptime: laptime
                ))
            }
            
            logger.debug("Retrieved \(laptimes.count) lap times for driver \(driverNr)")
            return laptimes
            
        } catch {
            logger.error("Failed to get lap times for driver \(driverNr): \(error)")
            throw DatabaseError.queryFailed(error)
        }
    }
    
    /// Get gaps for a driver (mirrors Rust get_gaps)
    public func getGaps(for driverNr: String) async throws -> [Gap] {
        let client = try await getClient()
        
        do {
            let rows = try await client.query(
                """
                SELECT gap, time
                FROM timing_driver
                WHERE nr = \(driverNr) AND gap != 0
                ORDER BY time
                """,
                logger: logger
            )
            
            var gaps: [Gap] = []
            for try await (gap, time) in rows.decode((Int64, Date).self) {
                gaps.append(Gap(
                    time: time,
                    gap: gap
                ))
            }
            
            logger.debug("Retrieved \(gaps.count) gap entries for driver \(driverNr)")
            return gaps
            
        } catch {
            logger.error("Failed to get gaps for driver \(driverNr): \(error)")
            throw DatabaseError.queryFailed(error)
        }
    }
    
    // MARK: - Health Check
    
    /// Check database health
    public func healthCheck() async -> DatabaseHealth {
        do {
            let client = try await getClient()
            
            _ = try await client.query("SELECT 1", logger: logger)
            
            return DatabaseHealth(
                connected: true,
                host: host,
                port: port,
                database: database,
                lastCheck: Date()
            )
            
        } catch {
            logger.error("Database health check failed: \(error)")
            return DatabaseHealth(
                connected: false,
                host: host,
                port: port,
                database: database,
                lastCheck: Date(),
                error: error.localizedDescription
            )
        }
    }
}

// MARK: - Supporting Types

/// Database error types
public enum DatabaseError: Error, LocalizedError {
    case connectionFailed(any Error)
    case notConnected
    case insertFailed(any Error)
    case queryFailed(any Error)
    
    public var errorDescription: String? {
        switch self {
        case .connectionFailed(let error):
            return "Database connection failed: \(error.localizedDescription)"
        case .notConnected:
            return "Database not connected"
        case .insertFailed(let error):
            return "Database insert failed: \(error.localizedDescription)"
        case .queryFailed(let error):
            return "Database query failed: \(error.localizedDescription)"
        }
    }
}

/// Timing driver data for database insertion
public struct TimingDriverData: Sendable {
    public let nr: String
    public let lap: Int?
    public let gap: Int64
    public let leaderGap: Int64
    public let laptime: Int64
    public let sector1: Int64
    public let sector2: Int64
    public let sector3: Int64
    
    public init(
        nr: String,
        lap: Int?,
        gap: Int64,
        leaderGap: Int64,
        laptime: Int64,
        sector1: Int64,
        sector2: Int64,
        sector3: Int64
    ) {
        self.nr = nr
        self.lap = lap
        self.gap = gap
        self.leaderGap = leaderGap
        self.laptime = laptime
        self.sector1 = sector1
        self.sector2 = sector2
        self.sector3 = sector3
    }
}

/// Tire driver data for database insertion
public struct TireDriverData: Sendable {
    public let nr: String
    public let lap: Int?
    public let compound: String
    public let laps: Int
    
    public init(nr: String, lap: Int?, compound: String, laps: Int) {
        self.nr = nr
        self.lap = lap
        self.compound = compound
        self.laps = laps
    }
}

/// Laptime data for analytics queries
public struct Laptime: Sendable, Codable {
    public let time: Date
    public let lap: Int?
    public let laptime: Int64
    
    public init(time: Date, lap: Int?, laptime: Int64) {
        self.time = time
        self.lap = lap
        self.laptime = laptime
    }
}

/// Gap data for analytics queries
public struct Gap: Sendable, Codable {
    public let time: Date
    public let gap: Int64
    
    public init(time: Date, gap: Int64) {
        self.time = time
        self.gap = gap
    }
}

/// Database health status
public struct DatabaseHealth: Sendable, Codable {
    public let connected: Bool
    public let host: String
    public let port: Int
    public let database: String
    public let lastCheck: Date
    public let error: String?
    
    public init(connected: Bool, host: String, port: Int, database: String, lastCheck: Date, error: String? = nil) {
        self.connected = connected
        self.host = host
        self.port = port
        self.database = database
        self.lastCheck = lastCheck
        self.error = error
    }
}
