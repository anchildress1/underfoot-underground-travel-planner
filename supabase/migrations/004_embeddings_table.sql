-- ============================================================================
-- PLACES EMBEDDINGS TABLE
-- ============================================================================
-- Vector embeddings for semantic search using pgvector

CREATE TABLE app_embeddings.places_embeddings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Source tracking
  source text NOT NULL CHECK (source IN ('serp', 'reddit', 'eventbrite')),
  source_id text NOT NULL,
  
  -- Vector embedding (OpenAI text-embedding-ada-002, 1536 dimensions)
  embedding vector(1536) NOT NULL,
  
  -- Place metadata (name, description, location, url, rating, etc.)
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  
  -- Timestamp
  created_at timestamptz DEFAULT now() NOT NULL,
  
  -- Prevent duplicates from same source
  UNIQUE(source, source_id),
  
  -- Prevent metadata bloat (max 10KB per row)
  CONSTRAINT places_embeddings_metadata_size CHECK (pg_column_size(metadata) < 10000)
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Vector similarity index (cosine distance for OpenAI embeddings)
-- Uses IVFFlat algorithm with 100 lists (good for ~10k-100k rows)
CREATE INDEX idx_places_embeddings_vector
ON app_embeddings.places_embeddings
USING ivfflat(embedding vector_cosine_ops)
WITH (lists = 100);

-- Source lookup index (filter by serp/reddit/eventbrite)
CREATE INDEX idx_places_embeddings_source ON app_embeddings.places_embeddings(source);

-- Created timestamp index (for cleanup/analytics)
CREATE INDEX idx_places_embeddings_created ON app_embeddings.places_embeddings(created_at DESC);

-- Composite index for source + created_at queries
CREATE INDEX idx_places_embeddings_source_created ON app_embeddings.places_embeddings(source, created_at DESC);

-- ============================================================================
-- TABLE DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE app_embeddings.places_embeddings IS 'Vector embeddings for places from SERP, Reddit, Eventbrite. Used for semantic similarity search.';
COMMENT ON COLUMN app_embeddings.places_embeddings.embedding IS 'OpenAI text-embedding-ada-002 vector (1536 dimensions). Indexed with IVFFlat for cosine similarity search.';
COMMENT ON COLUMN app_embeddings.places_embeddings.metadata IS 'Place details: name (required), description, location, url, rating, etc. Max 10KB.';
COMMENT ON COLUMN app_embeddings.places_embeddings.source_id IS 'Unique identifier from source API (e.g., Reddit post ID t3_abc123, Eventbrite event ID 123456789, SERP URL hash).';
COMMENT ON COLUMN app_embeddings.places_embeddings.source IS 'Data source: serp (Google SERP API), reddit (Reddit API), eventbrite (Eventbrite API).';

-- ============================================================================
-- GRANT PRIVILEGES TO ROLES
-- ============================================================================

-- app_readonly: read-only access to embeddings
GRANT SELECT ON app_embeddings.places_embeddings TO app_readonly;

-- app_readwrite: read-only access (embeddings are managed by app_admin only)
GRANT SELECT ON app_embeddings.places_embeddings TO app_readwrite;

-- app_admin: full control (insert/update/delete embeddings)
GRANT ALL ON app_embeddings.places_embeddings TO app_admin;

-- Grant sequence usage
GRANT USAGE ON ALL SEQUENCES IN SCHEMA app_embeddings TO app_readonly, app_readwrite, app_admin;
