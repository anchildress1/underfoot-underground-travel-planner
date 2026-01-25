-- ============================================================================
-- FUNCTIONS AND PROCEDURES
-- ============================================================================
-- Application functions moved to proper schemas with SECURITY DEFINER

-- ============================================================================
-- VECTOR SIMILARITY SEARCH FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION app_embeddings.search_places_by_similarity(
  query_embedding vector(1536),
  match_threshold float DEFAULT 0.7,
  match_count int DEFAULT 10
)
RETURNS TABLE (
  id uuid,
  source text,
  source_id text,
  metadata jsonb,
  similarity float
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = app_embeddings, pg_temp
AS $$
BEGIN
  -- Validate inputs
  IF match_threshold < 0 OR match_threshold > 1 THEN
    RAISE EXCEPTION 'match_threshold must be between 0 and 1, got %', match_threshold;
  END IF;
  
  IF match_count < 1 OR match_count > 100 THEN
    RAISE EXCEPTION 'match_count must be between 1 and 100, got %', match_count;
  END IF;
  
  -- Perform vector similarity search using cosine distance
  -- 1 - (embedding <=> query_embedding) converts distance to similarity
  RETURN QUERY
  SELECT
    p.id,
    p.source,
    p.source_id,
    p.metadata,
    1 - (p.embedding <=> query_embedding) AS similarity
  FROM app_embeddings.places_embeddings p
  WHERE 1 - (p.embedding <=> query_embedding) > match_threshold
  ORDER BY p.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

-- Grant execute to roles that need it
GRANT EXECUTE ON FUNCTION app_embeddings.search_places_by_similarity TO app_readwrite, app_admin;

-- Function documentation
COMMENT ON FUNCTION app_embeddings.search_places_by_similarity IS 
  'Searches places using cosine similarity with configurable threshold (0-1) and limit (1-100). Returns results ordered by similarity score.';

-- ============================================================================
-- CACHE CLEANUP FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION app_cache.clean_expired_cache()
RETURNS TABLE (
  deleted_search_results bigint,
  deleted_location_cache bigint
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = app_cache, pg_temp
AS $$
DECLARE
  deleted_search bigint;
  deleted_location bigint;
BEGIN
  -- Delete expired search results
  DELETE FROM app_cache.search_results WHERE expires_at < now();
  GET DIAGNOSTICS deleted_search = ROW_COUNT;
  
  -- Delete expired location cache
  DELETE FROM app_cache.location_cache WHERE expires_at < now();
  GET DIAGNOSTICS deleted_location = ROW_COUNT;
  
  -- Return counts
  RETURN QUERY SELECT deleted_search, deleted_location;
END;
$$;

-- Grant execute to admin role only (cleanup is privileged operation)
GRANT EXECUTE ON FUNCTION app_cache.clean_expired_cache TO app_admin;

-- Function documentation
COMMENT ON FUNCTION app_cache.clean_expired_cache IS 
  'Manually delete expired cache entries. Can be called periodically via pg_cron or manually as needed.';

-- ============================================================================
-- CACHE STATISTICS FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION app_monitoring.get_cache_stats()
RETURNS TABLE (
  table_name text,
  total_rows bigint,
  valid_rows bigint,
  expired_rows bigint,
  avg_ttl_hours numeric,
  oldest_entry timestamptz,
  newest_entry timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = app_cache, app_monitoring, pg_temp
AS $$
BEGIN
  RETURN QUERY
  SELECT
    'app_cache.search_results'::text,
    COUNT(*)::bigint,
    COUNT(*) FILTER (WHERE expires_at > now())::bigint,
    COUNT(*) FILTER (WHERE expires_at <= now())::bigint,
    ROUND(AVG(EXTRACT(EPOCH FROM (expires_at - created_at)) / 3600)::numeric, 2),
    MIN(created_at),
    MAX(created_at)
  FROM app_cache.search_results
  
  UNION ALL
  
  SELECT
    'app_cache.location_cache'::text,
    COUNT(*)::bigint,
    COUNT(*) FILTER (WHERE expires_at > now())::bigint,
    COUNT(*) FILTER (WHERE expires_at <= now())::bigint,
    ROUND(AVG(EXTRACT(EPOCH FROM (expires_at - created_at)) / 3600)::numeric, 2),
    MIN(created_at),
    MAX(created_at)
  FROM app_cache.location_cache;
END;
$$;

-- Grant execute to all roles (monitoring function)
GRANT EXECUTE ON FUNCTION app_monitoring.get_cache_stats TO app_readonly, app_readwrite, app_admin;

-- Function documentation
COMMENT ON FUNCTION app_monitoring.get_cache_stats IS 
  'Returns cache health statistics: row counts, valid/expired entries, average TTL, and timestamp ranges.';

-- ============================================================================
-- EMBEDDING STATISTICS FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION app_monitoring.get_embedding_stats()
RETURNS TABLE (
  source text,
  total_embeddings bigint,
  avg_metadata_size_bytes numeric,
  oldest_entry timestamptz,
  newest_entry timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = app_embeddings, app_monitoring, pg_temp
AS $$
BEGIN
  RETURN QUERY
  SELECT
    p.source,
    COUNT(*)::bigint,
    ROUND(AVG(pg_column_size(p.metadata))::numeric, 2),
    MIN(p.created_at),
    MAX(p.created_at)
  FROM app_embeddings.places_embeddings p
  GROUP BY p.source
  ORDER BY p.source;
END;
$$;

-- Grant execute to all roles (monitoring function)
GRANT EXECUTE ON FUNCTION app_monitoring.get_embedding_stats TO app_readonly, app_readwrite, app_admin;

-- Function documentation
COMMENT ON FUNCTION app_monitoring.get_embedding_stats IS 
  'Returns embedding statistics by source: counts, average metadata size, and timestamp ranges.';
