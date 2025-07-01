import Foundation
import PostgresNIO
import Logging

/// Manager for database schema migrations
public actor MigrationManager {
    private let logger = Logger(label: "MigrationManager")
    
    // MARK: - Migration Management
    
    /// Run all pending migrations
    public static func runMigrations() async throws {
        let manager = MigrationManager()
        try await manager.executeMigrations()
    }
    
    /// Execute all database migrations
    private func executeMigrations() async throws {
        logger.info("Starting database migrations...")
        
        // Get database client
        let client = try await DatabaseManager.shared.getClient()
        
        // Create migrations table if it doesn't exist
        try await createMigrationsTable(client: client)
        
        // Get list of applied migrations
        let appliedMigrations = try await getAppliedMigrations(client: client)
        
        // Execute pending migrations
        let allMigrations = getAllMigrations()
        
        for migration in allMigrations {
            if !appliedMigrations.contains(migration.name) {
                logger.info("Applying migration: \(migration.name)")
                try await executeMigration(migration, client: client)
                try await recordMigration(migration.name, client: client)
                logger.info("Migration applied successfully: \(migration.name)")
            } else {
                logger.debug("Migration already applied: \(migration.name)")
            }
        }
        
        logger.info("All migrations completed successfully")
    }
    
    /// Create the migrations tracking table
    private func createMigrationsTable(client: PostgresClient) async throws {
        try await client.query("""
            CREATE TABLE IF NOT EXISTS schema_migrations (
                id SERIAL PRIMARY KEY,
                migration_name VARCHAR(255) NOT NULL UNIQUE,
                applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
            );
            """, logger: logger)
        logger.debug("Created/verified schema_migrations table")
    }
    
    /// Get list of already applied migrations
    private func getAppliedMigrations(client: PostgresClient) async throws -> Set<String> {
        let rows = try await client.query(
            "SELECT migration_name FROM schema_migrations ORDER BY applied_at;",
            logger: logger
        )
        
        var appliedMigrations = Set<String>()
        for try await (migrationName) in rows.decode(String.self) {
            appliedMigrations.insert(migrationName)
        }
        
        logger.debug("Found \(appliedMigrations.count) applied migrations")
        return appliedMigrations
    }
    
    /// Record a migration as applied
    private func recordMigration(_ name: String, client: PostgresClient) async throws {
        try await client.query(
            "INSERT INTO schema_migrations (migration_name) VALUES (\(name));",
            logger: logger
        )
    }
    
    /// Execute a single migration
    private func executeMigration(_ migration: Migration, client: PostgresClient) async throws {
        do {
            try await client.query(
                PostgresQuery(unsafeSQL: migration.sql),
                logger: logger
            )
        } catch {
            logger.error("Failed to execute migration \(migration.name): \(error)")
            throw MigrationError.executionFailed(migration.name, error)
        }
    }
    
    /// Get all available migrations
    private func getAllMigrations() -> [Migration] {
        return [
            Migration(
                name: "001_initial_schema",
                sql: Migration001.sql
            )
        ]
    }
}

// MARK: - Migration Definitions

/// Represents a database migration
private struct Migration {
    let name: String
    let sql: String
}

/// Initial schema migration
private struct Migration001 {
    static let sql = """
        -- F1 Dash Database Schema
        -- Initial migration for PostgreSQL/TimescaleDB
        
        -- Create timing_driver table for storing lap timing data
        CREATE TABLE IF NOT EXISTS timing_driver (
            id SERIAL PRIMARY KEY,
            time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            nr VARCHAR(10) NOT NULL,
            lap INTEGER,
            gap BIGINT NOT NULL DEFAULT 0,
            leader_gap BIGINT NOT NULL DEFAULT 0,
            laptime BIGINT NOT NULL DEFAULT 0,
            sector_1 BIGINT NOT NULL DEFAULT 0,
            sector_2 BIGINT NOT NULL DEFAULT 0,
            sector_3 BIGINT NOT NULL DEFAULT 0
        );
        
        -- Create tire_driver table for storing tire compound data
        CREATE TABLE IF NOT EXISTS tire_driver (
            id SERIAL PRIMARY KEY,
            time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            nr VARCHAR(10) NOT NULL,
            lap INTEGER,
            compound VARCHAR(20) NOT NULL,
            laps INTEGER NOT NULL DEFAULT 0
        );
        
        -- Create indexes for better query performance
        CREATE INDEX IF NOT EXISTS idx_timing_driver_nr_time ON timing_driver(nr, time DESC);
        CREATE INDEX IF NOT EXISTS idx_timing_driver_lap ON timing_driver(lap);
        CREATE INDEX IF NOT EXISTS idx_timing_driver_time ON timing_driver(time DESC);
        
        CREATE INDEX IF NOT EXISTS idx_tire_driver_nr_time ON tire_driver(nr, time DESC);
        CREATE INDEX IF NOT EXISTS idx_tire_driver_lap ON tire_driver(lap);
        CREATE INDEX IF NOT EXISTS idx_tire_driver_time ON tire_driver(time DESC);
        """
}

// MARK: - Error Types

public enum MigrationError: Error, LocalizedError {
    case executionFailed(String, any Error)
    
    public var errorDescription: String? {
        switch self {
        case .executionFailed(let migration, let error):
            return "Migration '\(migration)' failed: \(error.localizedDescription)"
        }
    }
}
