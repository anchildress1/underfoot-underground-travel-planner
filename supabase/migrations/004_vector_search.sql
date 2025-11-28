-- Enable pgvector extension for vector similarity search
CREATE EXTENSION IF NOT EXISTS vector;

-- Create places_embeddings table for storing vector representations
CREATE TABLE IF NOT EXISTS places_embeddings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source text NOT NULL CHECK (source IN ('serp', 'reddit', 'eventbrite')),
  source_id text NOT NULL,
  embedding vector(1536),  -- OpenAI ada-002 embedding dimension
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now(),
  UNIQUE(source, source_id)
);

-- Create index for cosine similarity search
CREATE INDEX IF NOT EXISTS places_embeddings_embedding_idx
ON places_embeddings
USING ivfflat(embedding vector_cosine_ops)
WITH (lists = 100);

-- Enable Row Level Security
ALTER TABLE places_embeddings ENABLE ROW LEVEL SECURITY;

-- Allow anonymous read access for search queries
CREATE POLICY "Allow anonymous read" ON places_embeddings
  FOR SELECT USING (true);

-- Restrict write access to service role only
CREATE POLICY "Service role only write" ON places_embeddings
  FOR INSERT WITH CHECK (false);

-- Add size constraint to prevent abuse
ALTER TABLE places_embeddings
ADD CONSTRAINT reasonable_metadata_size
CHECK (pg_column_size(metadata) < 10000);

-- Add comment for documentation
COMMENT ON TABLE places_embeddings IS 'Stores vector embeddings for semantic search of places from various sources';
COMMENT ON COLUMN places_embeddings.embedding IS 'OpenAI ada-002 embedding vector (1536 dimensions)';
COMMENT ON COLUMN places_embeddings.metadata IS 'JSON metadata: name, description, location, url, etc.';
