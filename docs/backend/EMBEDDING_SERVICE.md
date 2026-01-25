# Embedding Service - Semantic Search with pgvector

> This service is under active development with breaking changes expected.  

## Overview

The `EmbeddingService` provides vector embeddings and semantic similarity search for places from external sources (SERP, Reddit, Eventbrite). It uses:

- **OpenAI `text-embedding-ada-002`** for generating 1536-dimension embeddings
- **Supabase pgvector** for storing and searching embeddings with cosine similarity
- **Lazy initialization** for pgvector validation (happens on first use, not during import)

## Key Features

### 🔐 Security & Validation

- **Source ID format validation**:
  - Reddit: alphanumeric + underscore (`^[a-z0-9_]+$`)
  - Eventbrite: numeric only
  - SERP: ≥8 characters (URL hash or meaningful ID)

- **Metadata requirements**:
  - Must be non-empty JSON-serializable dict
  - **Required field**: `name` (non-whitespace after normalization)
  - Maximum size: 10KB (enforced by database constraint)

- **Text validation**:
  - Non-empty after whitespace normalization (`text.strip()`)
  - Maximum length: 8000 characters (conservative limit for ada-002)
  - Whitespace normalized **before** length check and embedding generation

### 🚀 Performance

- **Lazy pgvector validation**: RPC function existence validated on first use, not during `__init__`
- **Singleton pattern**: Single instance shared across application
- **Cached OpenAI client**: Reuses connection for all embedding requests

### ⚠️ Error Handling

**All methods RAISE exceptions**:

```python
try:
    service.store_place_embedding(...)
except EmbeddingError as e:
    logger.error(f"Storage failed: {e}")
```

**Empty `[]` from search means "no matches found"**:

```python
results = service.similarity_search("query")  # Raises EmbeddingError on failure
if not results:  # Empty list = no matches above threshold
    logger.info("No matches found")
```

## Usage

### Basic Example

```python
from src.services.embedding_service import get_embedding_service, EmbeddingError

service = get_embedding_service()

# Store place embedding
try:
    service.store_place_embedding(
        source="reddit",
        source_id="post_abc_123",
        text="Secret Cave - Hidden underground cavern in Pikeville",
        metadata={
            "name": "Secret Cave",
            "location": "Pikeville, KY",
            "url": "https://reddit.com/r/kentucky/comments/abc123"
        }
    )
except EmbeddingError as e:
    logger.error(f"Failed to store embedding: {e}")

# Search for similar places
try:
    results = service.similarity_search(
        query_text="underground caves Kentucky",
        limit=10,
        similarity_threshold=0.7
    )
    
    for place in results:
        print(f"{place['metadata']['name']}: {place['similarity']:.2f}")
except EmbeddingError as e:
    logger.error(f"Search failed: {e}")
```

### Error Handling

All errors include actionable context:

```python
# Text too long
ValueError: Text too long (8500 chars). Maximum 8000 chars. Consider summarizing or splitting the text.

# Invalid source_id format
ValueError: Invalid Reddit source_id 'ABC-123'. Expected alphanumeric + underscore.

# Missing metadata name
EmbeddingError: Metadata must include 'name' field with non-empty value (after whitespace normalization).

# pgvector not available
EmbeddingError: pgvector extension or search_places_by_similarity() function not available. 
Ensure migrations have been applied. See supabase/MIGRATION_NOTES.md for setup steps.
```

## Configuration

### Environment Variables

Required environment variables (see `backend/.env.example`):

```bash
OPENAI_API_KEY=sk-...               # OpenAI API key for embeddings
SUPABASE_URL=https://...           # Supabase project URL
SUPABASE_SERVICE_ROLE_KEY=eyJ...   # Service role key (for INSERT)
```

### Model Configuration

**CRITICAL**: The `embedding_dimensions=1536` is **HARD-CODED** in:

1. OpenAI `text-embedding-ada-002` model output
2. Database column: `places_embeddings.embedding vector(1536)`
3. Migration file: `supabase/migrations/20251101000001_places_embeddings.sql`

**Changing models** (e.g., `text-embedding-3-small` with 512 dimensions) requires:

```sql
-- 1. Alter table column type
ALTER TABLE places_embeddings 
ALTER COLUMN embedding TYPE vector(512);

-- 2. Drop existing index
DROP INDEX idx_places_embeddings_vector;

-- 3. Rebuild index
CREATE INDEX idx_places_embeddings_vector
ON places_embeddings 
USING ivfflat(embedding vector_cosine_ops) 
WITH (lists = 100);

-- 4. Re-generate ALL embeddings (no partial migration possible)
TRUNCATE places_embeddings;
```

Then update `EmbeddingService.embedding_dimensions` and `EmbeddingService.embedding_model`.

## Testing

### Unit Tests

Run the comprehensive test suite (50 tests):

```bash
cd backend
pytest tests/unit/test_services/test_embedding_service.py -v
```

**Test coverage: 96%** for `embedding_service.py`

### Integration Testing (Local Supabase)

See `supabase/MIGRATION_NOTES.md` for local Supabase setup and testing steps.

## Database Schema

### `places_embeddings` Table

```sql
CREATE TABLE places_embeddings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source text NOT NULL CHECK (source IN ('serp', 'reddit', 'eventbrite')),
  source_id text NOT NULL,
  embedding vector(1536) NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  UNIQUE(source, source_id)
);

CREATE INDEX idx_places_embeddings_vector
ON places_embeddings 
USING ivfflat(embedding vector_cosine_ops) 
WITH (lists = 100);
```

### RLS Policies

- **SELECT**: Application roles (app_readonly, app_readwrite, app_admin)
- **INSERT**: app_admin role only with schema-qualified tables

## Performance Notes

### Embedding Generation Costs

OpenAI `text-embedding-ada-002` pricing (as of Dec 2025):
- **$0.0001 per 1K tokens** (~750 words)
- Average place description: ~100 tokens = **$0.00001 per embedding**

For 10,000 places: ~$0.10 total embedding cost.

### Search Performance

- **ivfflat index** provides fast approximate nearest neighbor search
- **lists parameter**: Set to 100 for datasets <100K embeddings
- **Cosine similarity**: `1 - (embedding <=> query_embedding)`
- **Threshold tuning**: 0.7 is a good default; adjust based on precision/recall needs

## Troubleshooting

### pgvector validation fails during tests

**Symptom**: `EmbeddingError: pgvector extension or search_places_by_similarity() function not available`

**Solution**: pgvector validation is lazy (happens on first real use). In tests, either:

1. Pre-set the validation flag:
   ```python
   embedding_service._pgvector_validated = True
   ```

2. Mock the Supabase RPC call:
   ```python
   embedding_service.supabase.client.rpc.return_value.execute.return_value = MagicMock(data=[])
   ```

### Dimension mismatch errors

**Symptom**: `EmbeddingError: Dimension mismatch: Expected 1536, got 512`

**Cause**: OpenAI model changed or using different embedding model

**Solution**: Ensure `embedding_model = "text-embedding-ada-002"` and check OpenAI API response

### Metadata serialization errors

**Symptom**: `EmbeddingError: Metadata must be JSON-serializable`

**Common causes**:
- datetime objects: Use `.isoformat()` to convert to strings
- Custom classes: Convert to dict before passing
- Circular references: Flatten or exclude

## References

- [OpenAI Embeddings Guide](https://platform.openai.com/docs/guides/embeddings)
- [pgvector Documentation](https://github.com/pgvector/pgvector)
- [Supabase Vector Search](https://supabase.com/docs/guides/ai/vector-search)
- [Migration Notes](../supabase/MIGRATION_NOTES.md)
