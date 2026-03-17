CREATE DATABASE IF NOT EXISTS voos;
USE voos;

-- ============================================================
-- 1. CVC Searches - Metadata Table
-- ============================================================
DROP TABLE IF EXISTS cvc_searches;
CREATE TABLE IF NOT EXISTS cvc_searches (
    -- Identification
    search_hash       String COMMENT 'Unique hash for multi-date search (global params)',
    date_hash         String COMMENT 'Unique hash for this specific date (used as PK)',
    created_at        DateTime DEFAULT now(),
    expires_at        DateTime,
    
    -- Search Parameters
    origin            LowCardinality(String),
    destination       LowCardinality(String),
    date_outbound     Date,
    date_inbound      Nullable(Date),
    adults            UInt8,
    children          UInt8,
    babies            UInt8,
    class_service     UInt8,
    rav_percentage    UInt8,
    
    -- Counts
    total_trips       UInt32 COMMENT 'Total ida+volta combinations',
    total_outbound    UInt32 COMMENT 'Total unique outbounds (for pagination)',
    
    -- Prices
    price_min         Float64,
    price_max         Float64,
    
    -- Global Duration
    duration_min      UInt16 COMMENT 'Minimum duration in minutes',
    duration_max      UInt16 COMMENT 'Maximum duration in minutes',
    
    -- Aggregated Arrays
    airlines          Array(String) COMMENT 'Available airlines',
    fare_families     Array(String) COMMENT 'Fare families',
    
    -- Outbound Meta
    outbound_departure_time_min  UInt16 COMMENT 'Minutes since 00:00',
    outbound_departure_time_max  UInt16,
    outbound_arrival_time_min    UInt16,
    outbound_arrival_time_max    UInt16,
    outbound_duration_min        UInt16,
    outbound_duration_max        UInt16,
    
    -- Inbound Meta
    inbound_departure_time_min   UInt16 DEFAULT 0,
    inbound_departure_time_max   UInt16 DEFAULT 0,
    inbound_arrival_time_min     UInt16 DEFAULT 0,
    inbound_arrival_time_max     UInt16 DEFAULT 0,
    inbound_duration_min         UInt16 DEFAULT 0,
    inbound_duration_max         UInt16 DEFAULT 0
)
ENGINE = ReplacingMergeTree()
ORDER BY (search_hash, date_hash)
TTL expires_at
SETTINGS index_granularity = 8192;

-- ============================================================
-- 2. Flight Pairs - Main Cache Table
-- ============================================================
DROP TABLE IF EXISTS flight_pairs;
CREATE TABLE IF NOT EXISTS flight_pairs (
    -- Search Identifiers
    search_hash       String,
    date_hash         String,
    created_at        DateTime DEFAULT now(),
    expires_at        DateTime,

    -- Grouping and Identification Keys
    outbound_key      String COMMENT 'Hash grouping identical outbound flights',
    outbound_token    String,
    inbound_token     Nullable(String),

    -- Prices (for complete pair)
    total_price       Float64,
    total_tax         Float64,
    
    -- ========================================
    -- OUTBOUND (IDA) - Prefix: outbound_
    -- ========================================
    outbound_airline           LowCardinality(String),
    outbound_airline_iata      LowCardinality(String),
    outbound_governing         LowCardinality(String),
    outbound_departure_location LowCardinality(String),
    outbound_arrival_location   LowCardinality(String),
    outbound_departure_time    DateTime,
    outbound_arrival_time      DateTime,
    outbound_duration_min      UInt16,
    outbound_stops             UInt8,
    outbound_stop_locations    Array(String),
    outbound_connection_airports Array(String),
    outbound_has_airport_change UInt8,
    outbound_hand_baggage_included UInt8,
    outbound_baggage_included  UInt8,
    outbound_baggage_qty       UInt8,
    outbound_fare_family       String,
    outbound_class_service     UInt8,
    outbound_service_class     LowCardinality(String),
    outbound_flight_number     String,
    outbound_deep_link         String,
    outbound_stops_json        String DEFAULT '[]',
    outbound_escala            String DEFAULT '',
    outbound_time_stop_max_min UInt16 DEFAULT 0,
    outbound_time_stop_max_formatted String DEFAULT '',
    outbound_services_json     String DEFAULT '[]',

    -- ========================================
    -- INBOUND (VOLTA) - Prefix: inbound_
    -- All nullable to support one-way flights
    -- ========================================
    inbound_airline           LowCardinality(Nullable(String)),
    inbound_airline_iata      LowCardinality(Nullable(String)),
    inbound_governing         LowCardinality(Nullable(String)),
    inbound_departure_location LowCardinality(Nullable(String)),
    inbound_arrival_location   LowCardinality(Nullable(String)),
    inbound_departure_time    Nullable(DateTime),
    inbound_arrival_time      Nullable(DateTime),
    inbound_duration_min      Nullable(UInt16),
    inbound_stops             Nullable(UInt8),
    inbound_stop_locations    Array(String),
    inbound_connection_airports Array(String),
    inbound_has_airport_change Nullable(UInt8),
    inbound_hand_baggage_included Nullable(UInt8),
    inbound_baggage_included  Nullable(UInt8),
    inbound_baggage_qty       Nullable(UInt8),
    inbound_fare_family       Nullable(String),
    inbound_class_service     Nullable(UInt8),
    inbound_service_class     LowCardinality(Nullable(String)),
    inbound_flight_number     Nullable(String),
    inbound_deep_link         Nullable(String),
    inbound_stops_json        String DEFAULT '[]',
    inbound_escala            Nullable(String) DEFAULT NULL,
    inbound_time_stop_max_min Nullable(UInt16) DEFAULT NULL,
    inbound_time_stop_max_formatted Nullable(String) DEFAULT NULL,
    inbound_services_json     String DEFAULT '[]',
    
    -- Indexes for query optimization
    INDEX idx_search_hash search_hash TYPE bloom_filter GRANULARITY 3,
    INDEX idx_outbound_key outbound_key TYPE bloom_filter GRANULARITY 3,
    INDEX idx_price total_price TYPE minmax GRANULARITY 3,
    INDEX idx_out_stops outbound_stops TYPE minmax GRANULARITY 3,
    INDEX idx_out_time outbound_departure_time TYPE minmax GRANULARITY 3,
    INDEX idx_in_time inbound_departure_time TYPE minmax GRANULARITY 3
)
ENGINE = MergeTree()
PARTITION BY toYYYYMMDD(created_at)
ORDER BY (search_hash, outbound_key, total_price)
TTL expires_at
SETTINGS index_granularity = 8192;

-- ============================================================
-- 3. Flight Stops - Detailed Stop Information
-- ============================================================
DROP TABLE IF EXISTS flight_stops;
CREATE TABLE IF NOT EXISTS flight_stops (
    search_hash       String,
    rate_token        String COMMENT 'Flight this stop belongs to',
    stop_index        UInt8 COMMENT 'Stop order (0, 1, 2...)',
    
    airport_code      LowCardinality(String),
    arrival_time      DateTime,
    departure_time    DateTime,
    duration_minutes  UInt16,
    next_airport      LowCardinality(String),
    is_airport_change UInt8,
    
    created_at        DateTime DEFAULT now(),
    expires_at        DateTime,
    
    INDEX idx_airport airport_code TYPE set(100) GRANULARITY 3
)
ENGINE = MergeTree()
ORDER BY (search_hash, rate_token, stop_index)
TTL expires_at;

-- ============================================================
-- 4. Rate Token Mapping - For Cache Invalidation
-- ============================================================

CREATE TABLE IF NOT EXISTS rate_token_mapping (
    rate_token   String,
    search_hash  String,
    created_at   DateTime DEFAULT now(),
    expires_at   DateTime
)
ENGINE = ReplacingMergeTree()
ORDER BY rate_token
TTL expires_at;

-- ============================================================
-- 5. Connection Airports - For Filter Queries
-- ============================================================
DROP TABLE IF EXISTS connection_airports;
CREATE TABLE IF NOT EXISTS connection_airports (
    search_hash  String,
    date_hash    String,
    flight_type  Enum8('outbound' = 1, 'inbound' = 2),
    airport_code LowCardinality(String),
    created_at   DateTime DEFAULT now(),
    expires_at   DateTime
)
ENGINE = MergeTree()
ORDER BY (search_hash, flight_type, airport_code)
TTL expires_at;
