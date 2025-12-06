-- Vector similarity search function
CREATE OR REPLACE FUNCTION search_places_by_similarity(
  query_embedding vector(1536),
  match_threshold float DEFAULT 0.7,
  match_count int DEFAULT 10
)
RETURNS TABLE (
  id uuid,
  source text,
  source_id text,
  metadata jsonb,
  similarity float
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    places_embeddings.id,
    places_embeddings.source,
    places_embeddings.source_id,
    places_embeddings.metadata,
    1 - (places_embeddings.embedding <=> query_embedding) AS similarity
  FROM places_embeddings
  WHERE 1 - (places_embeddings.embedding <=> query_embedding) > match_threshold
  ORDER BY places_embeddings.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

COMMENT ON FUNCTION search_places_by_similarity IS 'Searches places using cosine similarity with configurable threshold and limit';
