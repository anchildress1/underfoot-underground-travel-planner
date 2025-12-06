# Supabase Integration Plan

## Current Status

### ✅ Completed
- Basic cache tables (`search_results`, `location_cache`)
- RLS policies with proper security
- Anti-spam triggers
- Vector embeddings table (`places_embeddings`)
- Python service layer (`SupabaseService`)
- Environment variables renamed to new convention

### ⚠️ Issues Fixed
- Removed duplicate migration (`004_vector_search.sql`)
- Fixed RLS INSERT policy (removed blocking policy)
- Updated all documentation to use `SUPABASE_PUBLISHABLE_KEY` / `SUPABASE_SECRET_KEY`

### 🔴 Not Yet Implemented
- Vector embedding generation service
- Semantic search functions
- Cache write operations from backend
- Vector similarity search queries
- Learning/analytics tables

## Integration Tasks

### Phase 1: Basic Cache Integration (Immediate)

**Goal**: Backend writes/reads from Supabase cache tables

#### 1.1 Local Testing Setup
```bash
# Install Supabase CLI
brew install supabase/tap/supabase

# Start local stack
cd supabase
supabase start

# Get credentials
supabase status

# Update backend/.env with local credentials
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_PUBLISHABLE_KEY=<local-anon-key>
SUPABASE_SECRET_KEY=<local-service-role-key>
```

#### 1.2 Backend Service Integration
- [x] `SupabaseService` class exists
- [ ] Add vector embedding methods
- [ ] Test cache write operations
- [ ] Test cache read operations
- [ ] Add integration tests

**Test Coverage Goal**: 40% (current: 35.31%)

#### 1.3 Cache Service Updates
File: `backend/src/services/cache_service.py`

Add Supabase fallback:
```python
async def get_cached_results(self, query_hash: str):
    # Try in-memory first
    result = self.memory_cache.get(query_hash)
    if result:
        return result
    
    # Fallback to Supabase
    from src.services.supabase_service import supabase
    result = supabase.get_search_results(query_hash)
    if result:
        # Warm in-memory cache
        self.memory_cache[query_hash] = result
    return result
```

### Phase 2: Vector Embeddings (Short-term)

**Goal**: Store and search embeddings for places

#### 2.1 Embedding Service
File: `backend/src/services/embedding_service.py` (new)

```python
from openai import AsyncOpenAI
from src.services.supabase_service import supabase

class EmbeddingService:
    def __init__(self):
        self.client = AsyncOpenAI()
    
    async def generate_embedding(self, text: str) -> list[float]:
        """Generate OpenAI ada-002 embedding"""
        response = await self.client.embeddings.create(
            model="text-embedding-ada-002",
            input=text
        )
        return response.data[0].embedding
    
    async def store_place_embedding(
        self, 
        source: str,
        source_id: str,
        text: str,
        metadata: dict
    ):
        """Generate and store embedding for a place"""
        embedding = await self.generate_embedding(text)
        
        # Store in Supabase
        supabase.client.table("places_embeddings").upsert({
            "source": source,
            "source_id": source_id,
            "embedding": embedding,
            "metadata": metadata
        }).execute()
    
    async def search_similar_places(
        self,
        query: str,
        limit: int = 10,
        threshold: float = 0.7
    ):
        """Find similar places using vector search"""
        query_embedding = await self.generate_embedding(query)
        
        # Use RPC function for similarity search
        results = supabase.client.rpc(
            "search_similar_places",
            {
                "query_embedding": query_embedding,
                "match_threshold": threshold,
                "match_count": limit
            }
        ).execute()
        
        return results.data
```

#### 2.2 Database Function
File: `supabase/migrations/005_vector_search_functions.sql` (new)

```sql
-- Vector similarity search function
CREATE OR REPLACE FUNCTION search_similar_places(
  query_embedding vector(1536),
  match_threshold float,
  match_count int
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
    1 - (places_embeddings.embedding <=> query_embedding) as similarity
  FROM places_embeddings
  WHERE 1 - (places_embeddings.embedding <=> query_embedding) > match_threshold
  ORDER BY places_embeddings.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION search_similar_places TO authenticated, anon;
```

#### 2.3 Integration Points

**When to generate embeddings:**
1. After fetching results from SERP/Reddit/Eventbrite
2. Before storing in cache
3. Async task (don't block request)

**Search flow:**
1. User query → generate embedding
2. Search `places_embeddings` for similar vectors
3. Merge with fresh API results
4. Rank by combined score

### Phase 3: Advanced Features (Future)

#### 3.1 Semantic Query Cache
Store user intent embeddings to find similar past searches

```sql
CREATE TABLE semantic_cache (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  query_text text NOT NULL,
  query_embedding vector(1536) NOT NULL,
  location_normalized text NOT NULL,
  results jsonb NOT NULL,
  cache_score float DEFAULT 0.5,
  created_at timestamptz DEFAULT now(),
  accessed_count int DEFAULT 0,
  expires_at timestamptz NOT NULL
);

CREATE INDEX idx_semantic_cache_vector
ON semantic_cache
USING ivfflat(query_embedding vector_cosine_ops)
WITH (lists = 100);
```

#### 3.2 User Preferences & Learning
Track user interactions for personalized results

```sql
CREATE TABLE user_interactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id text NOT NULL,
  search_id uuid REFERENCES semantic_cache(id),
  result_id uuid REFERENCES places_embeddings(id),
  action text CHECK (action IN ('click', 'save', 'thumbs_up', 'thumbs_down')),
  created_at timestamptz DEFAULT now()
);

CREATE TABLE user_preferences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id text NOT NULL,
  preference_type text NOT NULL,
  preference_data jsonb NOT NULL,
  confidence_score float NOT NULL CHECK (confidence_score BETWEEN 0 AND 1),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, preference_type)
);
```

## Testing Strategy

### Unit Tests
- [ ] `SupabaseService` write operations
- [ ] `SupabaseService` read operations
- [ ] `EmbeddingService` generation
- [ ] `EmbeddingService` storage

### Integration Tests
- [ ] Local Supabase → Backend connection
- [ ] Cache write/read cycle
- [ ] Vector search accuracy
- [ ] RLS policy enforcement

### Performance Tests
- [ ] Vector search latency (< 100ms)
- [ ] Cache hit rate (> 60%)
- [ ] Embedding generation (< 500ms)

## Deployment Strategy

### Local Development
```bash
# 1. Start Supabase
supabase start

# 2. Run migrations
supabase db reset

# 3. Start backend
cd backend
poetry run uvicorn src.workers.chat_worker:app --reload

# 4. Test
curl http://localhost:8000/health
```

### Production
```bash
# 1. Push migrations
export SUPABASE_ACCESS_TOKEN=<token>
supabase link --project-ref uqvwaiexsgprdbdecoxx
supabase db push

# 2. Verify
curl "https://uqvwaiexsgprdbdecoxx.supabase.co/rest/v1/search_results?limit=1" \
  -H "apikey: $SUPABASE_PUBLISHABLE_KEY"

# 3. Deploy backend (handled by GitHub Actions)
```

## Rollout Plan

### Week 1: Foundation
- [x] Fix migration issues
- [ ] Test local Supabase setup
- [ ] Write cache integration tests
- [ ] Test cache read/write cycle

### Week 2: Vector Integration
- [ ] Create embedding service
- [ ] Add vector search function
- [ ] Test similarity search
- [ ] Integrate with search flow

### Week 3: Production
- [ ] Deploy migrations to production
- [ ] Monitor cache performance
- [ ] Optimize vector search
- [ ] Add monitoring dashboards

## Success Metrics

- **Cache Hit Rate**: 60%+ within 2 weeks
- **Vector Search Latency**: < 100ms p95
- **Test Coverage**: 40%+ backend
- **RLS Policy**: 100% effective (no unauthorized writes)
- **Uptime**: 99.9%

## Rollback Plan

If issues arise:
1. Switch backend to in-memory cache only
2. Disable vector search queries
3. Keep Supabase read-only
4. Fix issues in local env
5. Re-deploy with fixes

## Dependencies

- OpenAI API (text-embedding-ada-002)
- Supabase (PostgreSQL 17 + pgvector)
- Docker (for local testing)
- Poetry (Python dependencies)
