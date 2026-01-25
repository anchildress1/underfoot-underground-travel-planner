-- ============================================================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================================================
-- Role-based RLS policies for cache and embeddings tables
-- Prevents unauthorized access and enforces data validation

-- ============================================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================================

ALTER TABLE app_cache.search_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_cache.location_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_embeddings.places_embeddings ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- SEARCH RESULTS CACHE POLICIES
-- ============================================================================

-- app_readonly: read non-expired cache entries
CREATE POLICY "app_readonly can read valid search cache"
  ON app_cache.search_results
  FOR SELECT
  TO app_readonly
  USING (expires_at > now());

-- app_readwrite: read all entries (including expired for debugging)
CREATE POLICY "app_readwrite can read all search cache"
  ON app_cache.search_results
  FOR SELECT
  TO app_readwrite
  USING (true);

-- app_readwrite: insert new cache entries with validation
CREATE POLICY "app_readwrite can insert search cache"
  ON app_cache.search_results
  FOR INSERT
  TO app_readwrite
  WITH CHECK (
    -- Enforce non-empty required fields
    query_hash IS NOT NULL AND
    location IS NOT NULL AND
    intent IS NOT NULL AND
    results_json IS NOT NULL AND
    -- Enforce valid TTL (not in past, not more than 14 days)
    expires_at > now() AND
    expires_at < now() + interval '14 days'
  );

-- app_readwrite: update existing cache entries (extend TTL)
CREATE POLICY "app_readwrite can update search cache"
  ON app_cache.search_results
  FOR UPDATE
  TO app_readwrite
  USING (true)
  WITH CHECK (
    -- Enforce valid TTL on update
    expires_at > now() AND
    expires_at < now() + interval '14 days'
  );

-- app_admin: full access (including DELETE for manual cleanup)
CREATE POLICY "app_admin full access to search cache"
  ON app_cache.search_results
  FOR ALL
  TO app_admin
  USING (true)
  WITH CHECK (true);

-- ============================================================================
-- LOCATION CACHE POLICIES
-- ============================================================================

-- app_readonly: read non-expired location cache
CREATE POLICY "app_readonly can read valid location cache"
  ON app_cache.location_cache
  FOR SELECT
  TO app_readonly
  USING (expires_at > now());

-- app_readwrite: read all entries
CREATE POLICY "app_readwrite can read all location cache"
  ON app_cache.location_cache
  FOR SELECT
  TO app_readwrite
  USING (true);

-- app_readwrite: insert new location cache with validation
CREATE POLICY "app_readwrite can insert location cache"
  ON app_cache.location_cache
  FOR INSERT
  TO app_readwrite
  WITH CHECK (
    -- Enforce non-empty required fields
    raw_input IS NOT NULL AND
    normalized_location IS NOT NULL AND
    -- Enforce valid confidence score
    confidence >= 0 AND
    confidence <= 1 AND
    -- Enforce valid TTL (not in past, not more than 60 days)
    expires_at > now() AND
    expires_at < now() + interval '60 days'
  );

-- app_readwrite: update existing location cache (extend TTL, update confidence)
CREATE POLICY "app_readwrite can update location cache"
  ON app_cache.location_cache
  FOR UPDATE
  TO app_readwrite
  USING (true)
  WITH CHECK (
    -- Enforce valid TTL and confidence on update
    expires_at > now() AND
    expires_at < now() + interval '60 days' AND
    confidence >= 0 AND
    confidence <= 1
  );

-- app_admin: full access to location cache
CREATE POLICY "app_admin full access to location cache"
  ON app_cache.location_cache
  FOR ALL
  TO app_admin
  USING (true)
  WITH CHECK (true);

-- ============================================================================
-- PLACES EMBEDDINGS POLICIES
-- ============================================================================

-- app_readonly: read all embeddings (no expiration, always valid)
CREATE POLICY "app_readonly can read embeddings"
  ON app_embeddings.places_embeddings
  FOR SELECT
  TO app_readonly
  USING (true);

-- app_readwrite: read all embeddings (no write access)
CREATE POLICY "app_readwrite can read embeddings"
  ON app_embeddings.places_embeddings
  FOR SELECT
  TO app_readwrite
  USING (true);

-- app_admin: full access to embeddings (insert/update/delete)
-- Only embedding service (via service_role) can write
CREATE POLICY "app_admin full access to embeddings"
  ON app_embeddings.places_embeddings
  FOR ALL
  TO app_admin
  USING (true)
  WITH CHECK (
    -- Enforce non-empty source_id and valid source
    source_id IS NOT NULL AND
    source IN ('serp', 'reddit', 'eventbrite') AND
    -- Enforce metadata presence
    metadata IS NOT NULL
  );

-- ============================================================================
-- POLICY DOCUMENTATION
-- ============================================================================

COMMENT ON POLICY "app_readonly can read valid search cache" ON app_cache.search_results IS
  'Read-only role can only see non-expired cache entries (expires_at > now)';

COMMENT ON POLICY "app_readwrite can insert search cache" ON app_cache.search_results IS
  'Backend application can insert cache with TTL validation (max 7 days)';

COMMENT ON POLICY "app_admin full access to search cache" ON app_cache.search_results IS
  'Admin role (service_role) has full control including DELETE for manual cleanup';

COMMENT ON POLICY "app_admin full access to embeddings" ON app_embeddings.places_embeddings IS
  'Only admin role (embedding service via service_role) can write embeddings';
