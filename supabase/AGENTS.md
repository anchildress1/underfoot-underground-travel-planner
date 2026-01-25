# Supabase AI Agent Instructions

TimescaleDB + pgvector integration with application schemas and role-based security.

## Schema Architecture

### Application Schemas
- `app_cache` - TimescaleDB hypertables for search/location caching
- `app_embeddings` - pgvector embeddings for semantic search
- `app_monitoring` - Observability views and metrics

### Key Tables
- `app_cache.search_results` - Query results cache (14-day retention)
- `app_cache.location_cache` - Location data cache (60-day retention)
- `app_embeddings.places_embeddings` - Vector embeddings for places

### Application Roles
- `app_readonly` - SELECT only (dashboards, monitoring)
- `app_readwrite` - SELECT/INSERT/UPDATE (backend services)
- `app_admin` - Full access (embedding service, manual operations)

## Security Principles

### Row Level Security (RLS)

- **ALL tables have RLS enabled** - No exceptions
- **Explicit policies per role** - Never use `USING (true)`
- **app_admin required for DELETE** - Prevent accidental data loss
- **Schema-qualified names mandatory** - `app_cache.search_results`, not `search_results`

### Authentication

- **Use SUPABASE_KEY** - app_admin_user password for database access
- **No Supabase role mapping** - Direct PostgreSQL role authentication
- **Never expose credentials** - Backend .env only

## TimescaleDB Features

### Automatic Retention
- **search_results**: 14 days (doubled for testing)
- **location_cache**: 60 days (doubled for testing)
- **Automatic cleanup** - TimescaleDB handles deletion

### Compression
- **Columnstore enabled** - 90%+ storage reduction after 1-3 days
- **Automatic background jobs** - Runs every 30 minutes
- **Only on cache tables** - Embeddings table excluded (pgvector incompatible)

### Hypertables
- **Time-based partitioning** - Automatic chunking on `created_at`
- **Chunk pruning** - Only scan relevant time ranges
- **Sparse indexes** - Optimized for time-series queries

## Cache Best Practices

### Cache Key Design
- **SHA-256 hashes** - Deterministic, collision-resistant
- **Include location** - Same query + different location = different hash
- **Normalize inputs** - Lowercase, trim, consistent formatting

### Write Strategy
- **Upsert on conflict** - Overwrite stale entries
- **Schema-qualified inserts** - `supabase.table('app_cache.search_results')`
- **Set expires_at** - Required for proper expiration
- **Validate before caching** - Prevent garbage data

### Read Strategy
- **Check expiration** - `gt('expires_at', now())`
- **Schema-qualified reads** - Always prefix with schema name
- **Single query lookups** - Use `.single()` with error handling
- **Fail gracefully** - Cache miss should not break search

## Vector Search

### Embeddings Table
- **1536-dimension vectors** - OpenAI text-embedding-3-small
- **IVFFlat index** - 100 lists for <1M rows
- **Metadata JSONB** - Flexible place attributes
- **Source tracking** - serp, google_places, etc.

### Similarity Search
```python
# Call schema-qualified function
supabase.rpc(
    'app_embeddings.search_places_by_similarity',
    {
        'query_embedding': vector,
        'match_threshold': 0.7,
        'match_count': 10
    }
)
```

## Monitoring

### Health Checks
```sql
-- Cache table health
SELECT * FROM app_monitoring.cache_health;

-- Compression stats
SELECT * FROM app_monitoring.compression_stats;

-- Background job status
SELECT * FROM app_monitoring.timescaledb_jobs;

-- System health
SELECT * FROM app_monitoring.system_health;
```

## Required Environment Variables

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=<app_admin_user_password>
```

## Testing Checklist

- [ ] Schema-qualified table names in all queries
- [ ] RLS policies block unauthorized operations
- [ ] Retention policies scheduled and active
- [ ] Compression jobs running (check after 24 hours)
- [ ] Vector search returns results
- [ ] Monitoring views accessible
- [ ] No hardcoded table names without schemas

## Common Pitfalls

- **Forgetting schema prefix** - Always use `app_cache.table_name`
- **Using SUPABASE_SECRET_KEY** - Use SUPABASE_KEY instead
- **Expecting instant compression** - Takes 1-3 days for first run
- **Retention cleanup** - TimescaleDB handles this automatically
- **Columnstore on embeddings** - Not supported with pgvector

## Verification Commands

```bash
# Check hypertables exist
psql $DATABASE_URL -c "SELECT * FROM timescaledb_information.hypertables WHERE hypertable_schema = 'app_cache';"

# Check retention policies
psql $DATABASE_URL -c "SELECT * FROM timescaledb_information.jobs WHERE job_type = 'retention_policy';"

# Check RLS enabled
psql $DATABASE_URL -c "SELECT schemaname, tablename, rowsecurity FROM pg_tables WHERE schemaname IN ('app_cache', 'app_embeddings');"

# Test vector search
psql $DATABASE_URL -c "SELECT * FROM app_embeddings.search_places_by_similarity(array_fill(0.0, ARRAY[1536])::vector, 0.7, 10);"
```

## Reference

- Migrations: `supabase/migrations/README.md`
- Deployment: `supabase/DEPLOYMENT_CHECKLIST.md`
- Schema review: `supabase/SCHEMA_REDESIGN_REVIEW.md`
