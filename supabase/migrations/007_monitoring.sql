-- ============================================================================
-- MONITORING VIEWS
-- ============================================================================
-- Observability views for cache health, performance, and usage analytics

-- ============================================================================
-- CACHE HEALTH VIEW
-- ============================================================================

CREATE OR REPLACE VIEW app_monitoring.cache_health AS
SELECT
  'app_cache.search_results' as table_name,
  COUNT(*) as total_rows,
  COUNT(*) FILTER (WHERE expires_at > now()) as valid_rows,
  COUNT(*) FILTER (WHERE expires_at <= now()) as expired_rows,
  ROUND(AVG(octet_length(results_json::text))::numeric, 2) as avg_json_size_bytes,
  ROUND(AVG(EXTRACT(EPOCH FROM (expires_at - created_at)) / 3600)::numeric, 2) as avg_ttl_hours,
  MIN(created_at) as oldest_entry,
  MAX(created_at) as newest_entry,
  MAX(created_at) - MIN(created_at) as time_range
FROM app_cache.search_results

UNION ALL

SELECT
  'app_cache.location_cache' as table_name,
  COUNT(*) as total_rows,
  COUNT(*) FILTER (WHERE expires_at > now()) as valid_rows,
  COUNT(*) FILTER (WHERE expires_at <= now()) as expired_rows,
  NULL as avg_json_size_bytes,
  ROUND(AVG(EXTRACT(EPOCH FROM (expires_at - created_at)) / 3600)::numeric, 2) as avg_ttl_hours,
  MIN(created_at) as oldest_entry,
  MAX(created_at) as newest_entry,
  MAX(created_at) - MIN(created_at) as time_range
FROM app_cache.location_cache;

GRANT SELECT ON app_monitoring.cache_health TO app_readonly, app_readwrite, app_admin;

COMMENT ON VIEW app_monitoring.cache_health IS 
  'Real-time cache health metrics: row counts, valid/expired entries, average TTL, and time ranges.';

-- ============================================================================
-- EMBEDDING HEALTH VIEW
-- ============================================================================

CREATE OR REPLACE VIEW app_monitoring.embedding_health AS
SELECT
  source,
  COUNT(*) as total_embeddings,
  ROUND(AVG(pg_column_size(metadata))::numeric, 2) as avg_metadata_size_bytes,
  MIN(created_at) as oldest_entry,
  MAX(created_at) as newest_entry,
  MAX(created_at) - MIN(created_at) as time_range
FROM app_embeddings.places_embeddings
GROUP BY source

UNION ALL

SELECT
  'ALL' as source,
  COUNT(*) as total_embeddings,
  ROUND(AVG(pg_column_size(metadata))::numeric, 2) as avg_metadata_size_bytes,
  MIN(created_at) as oldest_entry,
  MAX(created_at) as newest_entry,
  MAX(created_at) - MIN(created_at) as time_range
FROM app_embeddings.places_embeddings;

GRANT SELECT ON app_monitoring.embedding_health TO app_readonly, app_readwrite, app_admin;

COMMENT ON VIEW app_monitoring.embedding_health IS 
  'Embedding statistics by source (serp/reddit/eventbrite): counts, metadata size, and time ranges.';

-- ============================================================================
-- SYSTEM HEALTH VIEW
-- ============================================================================

CREATE OR REPLACE VIEW app_monitoring.system_health AS
SELECT
  'Database Size' as metric,
  pg_size_pretty(pg_database_size(current_database())) as value,
  NULL::text as details
  
UNION ALL

SELECT
  'Active Connections' as metric,
  COUNT(*)::text as value,
  NULL::text as details
FROM pg_stat_activity
WHERE datname = current_database()

UNION ALL

SELECT
  'Cache Tables' as metric,
  COUNT(*)::text as value,
  string_agg(tablename, ', ') as details
FROM pg_tables
WHERE schemaname = 'app_cache'

UNION ALL

SELECT
  'Embedding Tables' as metric,
  COUNT(*)::text as value,
  string_agg(tablename, ', ') as details
FROM pg_tables
WHERE schemaname = 'app_embeddings';

GRANT SELECT ON app_monitoring.system_health TO app_readonly, app_readwrite, app_admin;

COMMENT ON VIEW app_monitoring.system_health IS 
  'System-level health metrics: database size, connections, and table counts.';
