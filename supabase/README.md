# Supabase Database

**PostgreSQL + pgvector**

---

## Features

- **Application Schemas:** app_cache, app_embeddings, app_monitoring
- **Application Roles:** app_readonly, app_readwrite, app_admin
- **Vector Search:** pgvector with IVFFlat index (OpenAI ada-002)
- **Monitoring:** Built-in health views

---

## Deploy

```bash
cd supabase
supabase db reset
```

---

## Documentation

- **[migrations/README.md](migrations/README.md)** - Migration reference
- **[AGENTS.md](AGENTS.md)** - AI agent guidelines

---

## Schema Overview

### app_cache Schema
- `search_results` - Query results cache (14-day TTL)
- `location_cache` - Location normalization cache (60-day TTL)
- `cleanup_expired()` - Function to delete expired entries

### app_embeddings Schema
- `places_embeddings` - pgvector table (1536 dimensions, IVFFlat index)
- `search_places_by_similarity()` - Vector similarity search function

### app_monitoring Schema
- `cache_health` - Real-time cache statistics view
- `embedding_health` - Embedding statistics by source view

---

## Application Roles

| Role | Access | Use Case |
|------|--------|----------|
| `app_readonly` | SELECT on all tables | Dashboards, monitoring, analytics |
| `app_readwrite` | SELECT/INSERT/UPDATE on cache | Application cache operations |
| `app_admin` | ALL privileges | Embedding service, operations |

---

## Local Development

```bash
# Start local Supabase
supabase start

# Reset and apply migrations
supabase db reset

# Get credentials
supabase status
```

---

## Verification Queries

```sql
-- Check schemas created
SELECT schema_name FROM information_schema.schemata WHERE schema_name LIKE 'app_%';

-- Check tables
SELECT schemaname, tablename FROM pg_tables WHERE schemaname IN ('app_cache', 'app_embeddings');

-- Check monitoring views
SELECT * FROM app_monitoring.cache_health;
```
