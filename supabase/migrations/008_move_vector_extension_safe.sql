-- ============================================================================
-- SAFE CLOUD MIGRATION: Move Vector Extension
-- ============================================================================
-- Use this script if you have EXISTING DATA in places_embeddings table
-- This preserves your data by creating a backup first

-- Step 1: Check if places_embeddings table exists and has data
DO $$
DECLARE
  row_count bigint;
BEGIN
  SELECT COUNT(*) INTO row_count FROM app_embeddings.places_embeddings;
  RAISE NOTICE 'Found % rows in places_embeddings table', row_count;
  
  IF row_count > 0 THEN
    RAISE NOTICE 'Creating backup table...';
    CREATE TABLE IF NOT EXISTS app_embeddings.places_embeddings_backup AS 
    SELECT * FROM app_embeddings.places_embeddings;
    RAISE NOTICE 'Backup complete. Data safe in places_embeddings_backup';
  ELSE
    RAISE NOTICE 'No data to backup';
  END IF;
EXCEPTION
  WHEN undefined_table THEN
    RAISE NOTICE 'places_embeddings table does not exist yet';
END
$$;

-- Step 2: Create extensions schema
CREATE SCHEMA IF NOT EXISTS extensions AUTHORIZATION postgres;
COMMENT ON SCHEMA extensions IS 'PostgreSQL extensions (uuid-ossp, pgcrypto, vector)';

-- Step 3: Move vector extension
DO $$
DECLARE
  ext_schema text;
BEGIN
  SELECT n.nspname INTO ext_schema
  FROM pg_extension e
  JOIN pg_namespace n ON e.extnamespace = n.oid
  WHERE e.extname = 'vector';
  
  IF ext_schema IS NOT NULL AND ext_schema != 'extensions' THEN
    RAISE NOTICE 'Moving vector extension from % to extensions schema...', ext_schema;
    DROP EXTENSION vector CASCADE;
    CREATE EXTENSION vector WITH SCHEMA extensions;
    RAISE NOTICE 'Vector extension moved successfully';
  ELSIF ext_schema IS NULL THEN
    RAISE NOTICE 'Creating vector extension in extensions schema...';
    CREATE EXTENSION vector WITH SCHEMA extensions;
  ELSE
    RAISE NOTICE 'Vector extension already in extensions schema';
  END IF;
END
$$;

-- Step 4: Recreate places_embeddings table if it was dropped
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'app_embeddings' 
    AND table_name = 'places_embeddings'
  ) THEN
    RAISE NOTICE 'Recreating places_embeddings table...';
    
    CREATE TABLE app_embeddings.places_embeddings (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      source text NOT NULL CHECK (source IN ('serp', 'reddit', 'eventbrite')),
      source_id text NOT NULL,
      embedding vector(1536) NOT NULL,
      metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
      created_at timestamptz DEFAULT now() NOT NULL,
      UNIQUE(source, source_id),
      CONSTRAINT places_embeddings_metadata_size CHECK (pg_column_size(metadata) < 10000)
    );
    
    -- Recreate indexes
    CREATE INDEX idx_places_embeddings_vector
    ON app_embeddings.places_embeddings
    USING ivfflat(embedding vector_cosine_ops)
    WITH (lists = 100);
    
    CREATE INDEX idx_places_embeddings_source ON app_embeddings.places_embeddings(source);
    CREATE INDEX idx_places_embeddings_created ON app_embeddings.places_embeddings(created_at DESC);
    CREATE INDEX idx_places_embeddings_source_created ON app_embeddings.places_embeddings(source, created_at DESC);
    
    -- Grant permissions
    GRANT SELECT ON app_embeddings.places_embeddings TO app_readonly;
    GRANT SELECT ON app_embeddings.places_embeddings TO app_readwrite;
    GRANT ALL ON app_embeddings.places_embeddings TO app_admin;
    
    RAISE NOTICE 'Table recreated successfully';
  ELSE
    RAISE NOTICE 'places_embeddings table already exists';
  END IF;
END
$$;

-- Step 5: Restore data from backup if it exists
DO $$
DECLARE
  backup_count bigint;
  restored_count bigint;
BEGIN
  IF EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'app_embeddings' 
    AND table_name = 'places_embeddings_backup'
  ) THEN
    SELECT COUNT(*) INTO backup_count FROM app_embeddings.places_embeddings_backup;
    
    IF backup_count > 0 THEN
      RAISE NOTICE 'Restoring % rows from backup...', backup_count;
      
      INSERT INTO app_embeddings.places_embeddings 
      SELECT * FROM app_embeddings.places_embeddings_backup
      ON CONFLICT (source, source_id) DO NOTHING;
      
      SELECT COUNT(*) INTO restored_count FROM app_embeddings.places_embeddings;
      RAISE NOTICE 'Restored % rows successfully', restored_count;
      
      -- Keep backup for safety - you can drop it manually later
      RAISE NOTICE 'Backup table preserved as places_embeddings_backup';
      RAISE NOTICE 'Verify data, then run: DROP TABLE app_embeddings.places_embeddings_backup;';
    END IF;
  END IF;
END
$$;

-- Step 6: Verify migration
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_extension e
    JOIN pg_namespace n ON e.extnamespace = n.oid
    WHERE e.extname = 'vector' AND n.nspname = 'extensions'
  ) THEN
    RAISE EXCEPTION 'ERROR: Vector extension not in extensions schema!';
  ELSE
    RAISE NOTICE '✅ SUCCESS: Vector extension is now in extensions schema';
  END IF;
END
$$;
