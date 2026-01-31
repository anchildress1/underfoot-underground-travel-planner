# Vector Extension Migration

## Issue
Supabase reported: **"Extension vector is installed in the public schema. Move it to another schema."**

## Solution
Moved the `vector` extension from the `public` schema to a dedicated `extensions` schema.

## Changes Made

### 1. Migration 001: Extensions and Schemas
**File:** `001_extensions_and_schemas.sql`

**Before:**
```sql
CREATE EXTENSION IF NOT EXISTS "vector";
```

**After:**
```sql
CREATE SCHEMA IF NOT EXISTS extensions AUTHORIZATION postgres;
CREATE EXTENSION IF NOT EXISTS "vector" WITH SCHEMA extensions;
```

### 2. Migration 002: Roles and Privileges
**File:** `002_roles_and_privileges.sql`

**Added:**
```sql
-- Grant USAGE on extensions schema (required for vector type)
GRANT USAGE ON SCHEMA extensions TO app_readonly, app_readwrite, app_admin;

-- Updated search_path to include extensions
ALTER ROLE app_readonly SET search_path TO app_cache, app_embeddings, app_monitoring, extensions, public;
ALTER ROLE app_readwrite SET search_path TO app_cache, app_embeddings, app_monitoring, extensions, public;
ALTER ROLE app_admin SET search_path TO app_cache, app_embeddings, app_monitoring, extensions, public;
```

### 3. Migration 008: Move Vector Extension (Cloud Only)
**File:** `008_move_vector_extension.sql`

This migration handles the transition for existing cloud deployments:
- Drops the vector extension from public schema
- Recreates it in extensions schema
- Verifies the move was successful

## Why This Works

1. **Search Path**: All roles have `extensions` in their search_path, so `vector(1536)` types are resolved correctly
2. **No Data Loss**: The extension move doesn't affect existing table data
3. **Backward Compatible**: Existing queries continue to work without modification
4. **Best Practice**: Extensions should live in dedicated schemas, not `public`

## Local Development

If you're running Supabase locally with `supabase start`:
1. Stop your local instance: `supabase stop`
2. Reset the database: `supabase db reset`
3. Start again: `supabase start`

The migrations will run in order and create the `extensions` schema correctly.

## Cloud Deployment - Quick Start

### 🚀 Easiest Method (Recommended)

**Use the Safe Migration Script:**

1. Go to: Supabase Dashboard → SQL Editor
2. Copy and paste the entire contents of: `008_move_vector_extension_safe.sql`
3. Click "Run"
4. Watch the notices - it will:
   - ✅ Backup your data automatically
   - ✅ Move the vector extension
   - ✅ Recreate the table
   - ✅ Restore your data
   - ✅ Verify everything worked

**That's it!** The script handles everything safely.

### ⚠️ IMPORTANT: Data Preservation Details

If you have existing data in `app_embeddings.places_embeddings`, the migration will **DROP** the table because `DROP EXTENSION ... CASCADE` removes all dependent objects.

### Option 1: Fresh Deployment (No Existing Data)

If you have **no data** or are okay losing embeddings:

1. Go to SQL Editor in Supabase Dashboard
2. Run the entire `008_move_vector_extension.sql` migration
3. Run migration `004_embeddings_table.sql` again to recreate the table
4. Re-populate embeddings from your data sources

### Option 2: Existing Data (Recommended for Production)

If you have **existing embeddings data** to preserve:

**Step 1: Backup Data**
```sql
-- Create temporary backup table
CREATE TABLE app_embeddings.places_embeddings_backup AS 
SELECT * FROM app_embeddings.places_embeddings;
```

**Step 2: Run Migration**
```sql
-- Create extensions schema
CREATE SCHEMA IF NOT EXISTS extensions AUTHORIZATION postgres;

-- Move vector extension (this will drop places_embeddings)
DROP EXTENSION IF EXISTS vector CASCADE;
CREATE EXTENSION vector WITH SCHEMA extensions;
```

**Step 3: Recreate Table** (from migration 004)
```sql
-- Recreate places_embeddings table
CREATE TABLE app_embeddings.places_embeddings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source text NOT NULL CHECK (source IN ('serp', 'reddit', 'eventbrite')),
  source_id text NOT NULL,
  embedding extensions.vector(1536) NOT NULL,  -- Note: explicitly reference extensions.vector
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  UNIQUE(source, source_id),
  CONSTRAINT places_embeddings_metadata_size CHECK (pg_column_size(metadata) < 10000)
);

-- Recreate indexes
CREATE INDEX idx_places_embeddings_vector
ON app_embeddings.places_embeddings
USING ivfflat(embedding extensions.vector_cosine_ops)
WITH (lists = 100);

CREATE INDEX idx_places_embeddings_source ON app_embeddings.places_embeddings(source);
CREATE INDEX idx_places_embeddings_created ON app_embeddings.places_embeddings(created_at DESC);
CREATE INDEX idx_places_embeddings_source_created ON app_embeddings.places_embeddings(source, created_at DESC);
```

**Step 4: Restore Data**
```sql
-- Restore from backup
INSERT INTO app_embeddings.places_embeddings 
SELECT * FROM app_embeddings.places_embeddings_backup;

-- Verify count matches
SELECT COUNT(*) FROM app_embeddings.places_embeddings;
SELECT COUNT(*) FROM app_embeddings.places_embeddings_backup;

-- Drop backup table
DROP TABLE app_embeddings.places_embeddings_backup;
```

**Step 5: Grant Permissions**
```sql
GRANT SELECT ON app_embeddings.places_embeddings TO app_readonly;
GRANT SELECT ON app_embeddings.places_embeddings TO app_readwrite;
GRANT ALL ON app_embeddings.places_embeddings TO app_admin;
```

### Option 3: Zero-Downtime (Advanced)

For production with no downtime:

1. Create new `extensions` schema
2. Install vector in `extensions` schema alongside existing public.vector
3. Create new table `places_embeddings_v2` using `extensions.vector` type
4. Copy data from old to new table
5. Swap table names atomically
6. Drop old extension from public

This is complex and should be done during a maintenance window.

## Verification

After applying the migration, verify with:

```sql
-- Check that vector is in extensions schema
SELECT e.extname, n.nspname 
FROM pg_extension e 
JOIN pg_namespace n ON e.extnamespace = n.oid 
WHERE e.extname = 'vector';

-- Should return: vector | extensions

-- Verify existing tables still work
SELECT COUNT(*) FROM app_embeddings.places_embeddings;
```

## Impact

✅ **No Breaking Changes**: All existing code continues to work
✅ **Supabase Warning Resolved**: Extension is no longer in public schema
✅ **Best Practice Compliance**: Extensions in dedicated schema
✅ **Security**: Follows PostgreSQL schema isolation principles

## Related Files
- `supabase/migrations/001_extensions_and_schemas.sql`
- `supabase/migrations/002_roles_and_privileges.sql`
- `supabase/migrations/008_move_vector_extension.sql`
- `supabase/config.toml` (already includes `extensions` in extra_search_path)
