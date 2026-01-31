-- ============================================================================
-- MOVE VECTOR EXTENSION TO EXTENSIONS SCHEMA
-- ============================================================================
-- This migration moves the vector extension from public schema to extensions schema
-- Addresses Supabase warning: "Extension vector is installed in the public schema"

-- IMPORTANT: This migration must be run BEFORE creating any tables that use the vector type
-- If you already have places_embeddings table, you'll need to:
--   1. Backup the data
--   2. Drop the table
--   3. Run this migration
--   4. Recreate the table (migration 004 will handle this on db reset)

-- Note: This migration is safe for fresh deployments
-- For existing deployments with data, see VECTOR_MIGRATION.md for detailed steps

-- Create extensions schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS extensions AUTHORIZATION postgres;
COMMENT ON SCHEMA extensions IS 'PostgreSQL extensions (uuid-ossp, pgcrypto, vector)';

-- Check if vector extension exists and where
DO $$
DECLARE
  ext_schema text;
BEGIN
  SELECT n.nspname INTO ext_schema
  FROM pg_extension e
  JOIN pg_namespace n ON e.extnamespace = n.oid
  WHERE e.extname = 'vector';
  
  IF ext_schema IS NOT NULL AND ext_schema != 'extensions' THEN
    -- Extension exists in wrong schema, need to move it
    RAISE NOTICE 'Vector extension found in schema: %. Moving to extensions schema.', ext_schema;
    
    -- Drop and recreate (WARNING: This will drop dependent tables!)
    DROP EXTENSION IF EXISTS vector CASCADE;
    CREATE EXTENSION vector WITH SCHEMA extensions;
    
    RAISE NOTICE 'Vector extension successfully moved to extensions schema';
    RAISE NOTICE 'WARNING: Dependent tables were dropped. You will need to recreate them.';
  ELSIF ext_schema IS NULL THEN
    -- Extension doesn't exist, create it
    RAISE NOTICE 'Creating vector extension in extensions schema';
    CREATE EXTENSION vector WITH SCHEMA extensions;
  ELSE
    -- Extension already in correct location
    RAISE NOTICE 'Vector extension already in extensions schema';
  END IF;
END
$$;

-- Verify the extension is in the correct schema
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_extension e
    JOIN pg_namespace n ON e.extnamespace = n.oid
    WHERE e.extname = 'vector' AND n.nspname = 'extensions'
  ) THEN
    RAISE EXCEPTION 'vector extension was not successfully moved to extensions schema';
  END IF;
END
$$;

COMMENT ON EXTENSION vector IS 'Vector similarity search for PostgreSQL (pgvector)';
