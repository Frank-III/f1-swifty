# F1DashPersistence

Data persistence layer for the F1-Dash Swift server, providing PostgreSQL/TimescaleDB integration for storing and querying historical F1 telemetry data.

## Overview

This library mirrors the functionality of the Rust implementation described in `docs/f1-dash-server.md`, specifically the `crates/timescale` and `services/importer` components. It provides:

- Database connection management with PostgreSQL/TimescaleDB
- Automatic schema migrations
- Data parsing and persistence for timing and tire data
- Analytics queries for historical data retrieval

## Architecture

### Components

1. **DatabaseManager** - Connection pooling and database operations
2. **DataParser** - Converts F1 data models to database-compatible formats
3. **MigrationManager** - Handles database schema versioning and updates

### Database Schema

The implementation creates two main tables:

#### timing_driver
Stores lap timing data including:
- Driver number and lap
- Gap to leader and car ahead
- Lap time and sector times
- Timestamps for time-series analysis

#### tire_driver
Stores tire compound and usage data:
- Driver number and lap
- Tire compound (SOFT, MEDIUM, HARD, INTERMEDIATE, WET)
- Number of laps on current tires
- Timestamps for historical tracking

## Usage

### Server Integration

Enable persistence when starting the F1DashServer:

```bash
swift run F1DashServer --persistence
```

### Environment Variables

Configure database connection using environment variables:

- `DATABASE_HOST` - PostgreSQL host (default: localhost)
- `DATABASE_PORT` - PostgreSQL port (default: 5432)
- `DATABASE_NAME` - Database name (default: f1dash)
- `DATABASE_USER` - Database username (default: postgres)
- `DATABASE_PASSWORD` - Database password (default: empty)

### Database Setup

#### PostgreSQL
```sql
CREATE DATABASE f1dash;
CREATE USER f1dash WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE f1dash TO f1dash;
```

#### TimescaleDB (Optional)
For optimal time-series performance, install TimescaleDB:

```sql
CREATE EXTENSION IF NOT EXISTS timescaledb;
```

The system will automatically create hypertables if TimescaleDB is available.

## API Endpoints

When persistence is enabled, the following analytics endpoints become available:

### Get Driver Lap Times
```
GET /api/analytics/laptime/{driver_nr}
```

Returns historical lap times for a specific driver:
```json
[
  {
    "time": "2024-06-30T14:15:30Z",
    "lap": 25,
    "laptime": 78306
  }
]
```

### Get Driver Gaps
```
GET /api/analytics/gap/{driver_nr}
```

Returns gap-to-leader data for a specific driver:
```json
[
  {
    "time": "2024-06-30T14:15:30Z",
    "gap": 15420
  }
]
```

### Database Health Check
```
GET /api/database/health
```

Returns database connection status:
```json
{
  "connected": true,
  "host": "localhost",
  "port": 5432,
  "database": "f1dash",
  "lastCheck": "2024-06-30T14:15:30Z"
}
```

## Data Flow

1. **Live Data Reception** - SignalR client receives F1 data
2. **State Processing** - SessionStateCache applies updates to canonical state
3. **Data Persistence** - Updated timing/tire data is parsed and stored
4. **Historical Queries** - Analytics endpoints serve historical data

This mirrors the Rust implementation's architecture where:
- `services/importer` → SessionStateCache persistence logic
- `services/analytics` → APIRouter analytics endpoints
- `crates/timescale` → DatabaseManager and schema

## Performance Considerations

- Uses TimescaleDB hypertables for optimal time-series performance
- Indexes on driver number and time for fast queries
- Connection pooling for efficient database usage
- Async/await throughout for non-blocking operations

## Migration Support

Schema changes are managed through the MigrationManager:
- Automatic migration execution on startup
- Version tracking in `schema_migrations` table
- Safe, idempotent migration scripts
- Support for both PostgreSQL and TimescaleDB features