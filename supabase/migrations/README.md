# Schema Migrations - TimescaleDB + pgvector

**Environment:** Timescale Cloud  

---

## ⚠️ DESTRUCTIVE DEPLOYMENT

Clean break deployment - drops existing data.

---

## Migration Files

- **001_extensions_and_schemas.sql** - Extensions, app schemas, revoke public CREATE
- **002_roles_and_privileges.sql** - App roles (readonly/readwrite/admin)
- **003_cache_hypertables.sql** - Cache tables with compression + retention
- **004_embeddings_table.sql** - Embeddings table with pgvector index
- **005_rls_policies.sql** - Role-based RLS policies
- **006_functions.sql** - Schema-qualified functions with SECURITY DEFINER
- **007_monitoring.sql** - Monitoring views

---

## Features

### TimescaleDB Hypertables
- Automatic time-based partitioning (created_at)
- Columnstore compression (90%+ storage reduction)
- Automatic retention policies (14 days search, 60 days location)
- Sparse indexes for query pruning

### Application Roles
- `app_readonly` - dashboards, monitoring (SELECT only)
- `app_readwrite` - application (SELECT/INSERT/UPDATE)
- `app_admin` - embedding service, operations (ALL)

### Security
- Explicit RLS policies per role
- Public schema CREATE revoked
- Functions use SECURITY DEFINER with SET search_path
- Metadata size constraints

### Monitoring
- `app_monitoring.cache_health` - real-time cache stats
- `app_monitoring.embedding_health` - embedding stats by source
- `app_monitoring.compression_stats` - TimescaleDB compression metrics
- `app_monitoring.timescaledb_jobs` - background job status

---

## Deployment

### Option 1: Timescale Cloud Console

1. **Drop existing schema**:
   ```sql
   DROP SCHEMA IF EXISTS public CASCADE;
   CREATE SCHEMA public;
   GRANT USAGE ON SCHEMA public TO PUBLIC;
   ```

2. **Apply migrations** (001 → 007):
   - Timescale Cloud Console → SQL Editor
   - Copy/paste each migration file
   - Run one at a time

3. **Verify**:
   ```sql
   SELECT schema_name FROM information_schema.schemata WHERE schema_name LIKE 'app_%';
   SELECT * FROM timescaledb_information.hypertables WHERE hypertable_schema = 'app_cache';
   SELECT * FROM timescaledb_information.jobs WHERE job_type = 'columnstore_policy';
   SELECT * FROM timescaledb_information.jobs WHERE job_type = 'retention_policy';
   SELECT rolname FROM pg_roles WHERE rolname LIKE 'app_%';
   ```

### Option 2: Supabase CLI

```bash
supabase stop
supabase start
supabase db reset
supabase db diff
supabase link --project-ref $SUPABASE_PROJECT_REF
supabase db push
```

### Option 3: psql

```bash
export DATABASE_URL="postgresql://tsdbadmin:password@host.tsdb.cloud.timescale.com:port/dbname?sslmode=require"

psql $DATABASE_URL -f supabase/migrations/001_extensions_and_schemas.sql
psql $DATABASE_URL -f supabase/migrations/002_roles_and_privileges.sql
psql $DATABASE_URL -f supabase/migrations/003_cache_hypertables.sql
psql $DATABASE_URL -f supabase/migrations/004_embeddings_table.sql
psql $DATABASE_URL -f supabase/migrations/005_rls_policies.sql
psql $DATABASE_URL -f supabase/migrations/006_functions.sql
psql $DATABASE_URL -f supabase/migrations/007_monitoring.sql
```

---

## Verification

```sql
-- Check schemas exist
SELECT schema_name FROM information_schema.schemata WHERE schema_name LIKE 'app_%';

-- Check hypertables created
SELECT * FROM timescaledb_information.hypertables WHERE hypertable_schema = 'app_cache';

-- Check compression policies
SELECT * FROM timescaledb_information.jobs WHERE job_type = 'columnstore_policy';

-- Check retention policies
SELECT * FROM timescaledb_information.jobs WHERE job_type = 'retention_policy';

-- Check roles
SELECT rolname FROM pg_roles WHERE rolname LIKE 'app_%';

-- Check RLS enabled
SELECT schemaname, tablename, rowsecurity FROM pg_tables 
WHERE schemaname IN ('app_cache', 'app_embeddings');

-- Test cache insert
INSERT INTO app_cache.search_results (query_hash, location, intent, results_json, expires_at)
VALUES ('test_hash', 'Test Location', 'Test Intent', '{}'::jsonb, now() + interval '1 hour');

-- Test embedding insert
INSERT INTO app_embeddings.places_embeddings (source, source_id, embedding, metadata)
VALUES ('serp', 'test_123', array_fill(0.0, ARRAY[1536])::vector, '{"name": "Test Place"}'::jsonb);
```

---

## Performance Expectations

### Storage
- ~100MB compressed for 10k cache entries (1MB JSON average)
- 90%+ reduction via TimescaleDB columnstore on chunks older than 1-3 days

### Query Performance
- Chunk pruning: Time-range queries only scan relevant chunks
- Sparse indexes: Skip compressed batches that don't match predicates
- IVFFlat index: Vector similarity search optimized for 10k-100k rows

### Maintenance
- Automatic retention: 14 days (search), 60 days (location)
- Automatic compression: Background jobs compress old chunks
- Automatic deletion: Background jobs handle expiration

---

## ⚠️ NO ROLLBACK

If deployment fails:
1. Fix the migration issue
2. Re-run migrations
3. Move forward

---

## Troubleshooting

**Compression not working?** Check `app_monitoring.compression_stats` - jobs run every 30 min

**Retention not deleting?** Check `app_monitoring.timescaledb_jobs` - retention runs hourly

**RLS blocking writes?** Use app_admin role directly

**Functions not found?** Use schema-qualified names: `app_embeddings.search_places_by_similarity`
