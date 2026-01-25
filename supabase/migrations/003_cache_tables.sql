-- ============================================================================
-- CACHE TABLES (Standard PostgreSQL)
-- ============================================================================
-- Search results and location cache with standard PostgreSQL features

-- ============================================================================
-- SEARCH RESULTS CACHE
-- ============================================================================

CREATE TABLE app_cache.search_results (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  query_hash text NOT NULL UNIQUE,
  location text NOT NULL,
  intent text NOT NULL,
  results_json jsonb NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  expires_at timestamptz NOT NULL,
  
  CONSTRAINT valid_expiration CHECK (expires_at > created_at),
  CONSTRAINT reasonable_ttl CHECK (expires_at < created_at + interval '14 days'),
  CONSTRAINT reasonable_json_size CHECK (octet_length(results_json::text) < 1048576)
);

CREATE INDEX idx_search_results_query_hash ON app_cache.search_results(query_hash);
CREATE INDEX idx_search_results_expires ON app_cache.search_results(expires_at);
CREATE INDEX idx_search_results_location ON app_cache.search_results(location);
CREATE INDEX idx_search_results_created ON app_cache.search_results(created_at DESC);

COMMENT ON TABLE app_cache.search_results IS 'Search results cache with 14-day TTL';

-- ============================================================================
-- LOCATION CACHE
-- ============================================================================

CREATE TABLE app_cache.location_cache (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  raw_input text NOT NULL UNIQUE,
  normalized_location text NOT NULL,
  confidence float NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
  raw_candidates jsonb DEFAULT '[]'::jsonb NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  expires_at timestamptz NOT NULL,
  
  CONSTRAINT valid_expiration CHECK (expires_at > created_at),
  CONSTRAINT reasonable_ttl CHECK (expires_at < created_at + interval '60 days'),
  CONSTRAINT reasonable_candidates_size CHECK (octet_length(raw_candidates::text) < 524288)
);

CREATE INDEX idx_location_cache_raw_input ON app_cache.location_cache(raw_input);
CREATE INDEX idx_location_cache_expires ON app_cache.location_cache(expires_at);
CREATE INDEX idx_location_cache_created ON app_cache.location_cache(created_at DESC);

COMMENT ON TABLE app_cache.location_cache IS 'Location normalization cache with 60-day TTL';

-- ============================================================================
-- CLEANUP FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION app_cache.cleanup_expired()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = app_cache, pg_temp
AS $$
BEGIN
  -- Delete expired search results
  DELETE FROM app_cache.search_results WHERE expires_at < now();
  
  -- Delete expired location cache
  DELETE FROM app_cache.location_cache WHERE expires_at < now();
END;
$$;

COMMENT ON FUNCTION app_cache.cleanup_expired IS 'Delete expired cache entries (call periodically via pg_cron or manually)';
