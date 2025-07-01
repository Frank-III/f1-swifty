-- F1 Dash Database Schema
-- Initial migration for PostgreSQL/TimescaleDB
-- Mirrors the Rust implementation from crates/timescale/

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

-- Create TimescaleDB hypertables (optional - only if TimescaleDB extension is available)
-- These will silently fail if TimescaleDB is not installed
SELECT create_hypertable('timing_driver', 'time', if_not_exists => true);
SELECT create_hypertable('tire_driver', 'time', if_not_exists => true);

-- Create additional indexes optimized for TimescaleDB
CREATE INDEX IF NOT EXISTS idx_timing_driver_nr_time_desc ON timing_driver(nr, time DESC);
CREATE INDEX IF NOT EXISTS idx_tire_driver_nr_time_desc ON tire_driver(nr, time DESC);

-- Comments for documentation
COMMENT ON TABLE timing_driver IS 'Stores F1 timing data including lap times, sectors, and gaps';
COMMENT ON COLUMN timing_driver.nr IS 'Driver racing number';
COMMENT ON COLUMN timing_driver.lap IS 'Lap number (null for out-of-session data)';
COMMENT ON COLUMN timing_driver.gap IS 'Gap to car ahead in milliseconds';
COMMENT ON COLUMN timing_driver.leader_gap IS 'Gap to race leader in milliseconds';
COMMENT ON COLUMN timing_driver.laptime IS 'Lap time in milliseconds';
COMMENT ON COLUMN timing_driver.sector_1 IS 'Sector 1 time in milliseconds';
COMMENT ON COLUMN timing_driver.sector_2 IS 'Sector 2 time in milliseconds';
COMMENT ON COLUMN timing_driver.sector_3 IS 'Sector 3 time in milliseconds';

COMMENT ON TABLE tire_driver IS 'Stores F1 tire compound and usage data';
COMMENT ON COLUMN tire_driver.nr IS 'Driver racing number';
COMMENT ON COLUMN tire_driver.lap IS 'Lap number when tire data was recorded';
COMMENT ON COLUMN tire_driver.compound IS 'Tire compound (SOFT, MEDIUM, HARD, INTERMEDIATE, WET)';
COMMENT ON COLUMN tire_driver.laps IS 'Number of laps completed on this set of tires';