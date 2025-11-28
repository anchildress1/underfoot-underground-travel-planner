-- ============================================================================
-- PLACES EMBEDDINGS: Vector storage for external source items
-- ============================================================================
-- Complements semantic_cache (which stores intent vectors)
-- This table stores embeddings for actual places/events from SERP/Reddit/Eventbrite

CREATE TABLE IF NOT EXISTS places_embeddings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Source tracking
  source text NOT NULL CHECK (source IN ('serp', 'reddit', 'eventbrite')),
  source_id text NOT NULL,

  -- Vector embedding
  embedding vector(1536) NOT NULL,

  -- Place metadata (name, description, location, url, etc.)
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,

  -- Timestamp
  created_at timestamptz DEFAULT now() NOT NULL,

  -- Prevent duplicates from same source
  UNIQUE(source, source_id)
);

-- Vector similarity index (cosine distance)
CREATE INDEX idx_places_embeddings_vector
ON places_embeddings
USING ivfflat(embedding vector_cosine_ops)
WITH (lists = 100);

-- Source lookup index
CREATE INDEX idx_places_embeddings_source ON places_embeddings(source);

-- Enable Row Level Security
ALTER TABLE places_embeddings ENABLE ROW LEVEL SECURITY;

-- Allow anonymous read for search queries
CREATE POLICY "places_embeddings_select_policy" ON places_embeddings
  FOR SELECT USING (true);

-- Restrict writes to service role only
CREATE POLICY "places_embeddings_insert_policy" ON places_embeddings
  FOR INSERT WITH CHECK (false);

-- Prevent metadata bloat
ALTER TABLE places_embeddings
ADD CONSTRAINT places_embeddings_metadata_size
CHECK (pg_column_size(metadata) < 10000);

-- Documentation
COMMENT ON TABLE places_embeddings IS 'Vector embeddings for places from SERP, Reddit, Eventbrite. Used for semantic similarity search.';
COMMENT ON COLUMN places_embeddings.embedding IS 'OpenAI text-embedding-ada-002 (1536 dimensions)';
COMMENT ON COLUMN places_embeddings.metadata IS 'Place details: name, description, location, url, rating, etc.';
COMMENT ON COLUMN places_embeddings.source_id IS 'Unique identifier from source API (e.g., Reddit post ID, Eventbrite event ID)';
