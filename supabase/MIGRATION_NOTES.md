# Migration Issues

## Duplicate Migration Files

⚠️ **PROBLEM**: Two migrations create the same `places_embeddings` table:

- `004_vector_search.sql` (older, simpler)
- `20251101000001_places_embeddings.sql` (newer, more detailed)

**Differences:**
- 004: `embedding vector(1536)` (nullable)
- 20251101: `embedding vector(1536) NOT NULL` (required)
- 20251101: Adds `idx_places_embeddings_source` index
- 20251101: Different policy names
- 20251101: More detailed comments

**Recommendation:** Delete `004_vector_search.sql` and keep the newer migration.

## RLS Policy Bug

⚠️ **CRITICAL**: INSERT policy blocks ALL writes including service role

```sql
CREATE POLICY "places_embeddings_insert_policy" ON places_embeddings
  FOR INSERT WITH CHECK (false);  -- ❌ Blocks everyone!
```

**Fix needed:**
```sql
CREATE POLICY "places_embeddings_insert_policy" ON places_embeddings
  FOR INSERT 
  TO authenticated
  WITH CHECK (auth.role() = 'service_role');
```

Or simpler (relying on JWT claims):
```sql
-- No policy = only service_role can write (RLS enabled blocks public)
-- Remove the INSERT policy entirely or use:
CREATE POLICY "places_embeddings_service_write" ON places_embeddings
  FOR INSERT 
  WITH CHECK (auth.jwt()->>'role' = 'service_role');
```

## Testing Needed

Before pushing to production:

1. [ ] Remove duplicate migration (004)
2. [ ] Fix INSERT policy on places_embeddings
3. [ ] Test local: `supabase db reset`
4. [ ] Test INSERT with service role key
5. [ ] Verify SELECT works with publishable key
