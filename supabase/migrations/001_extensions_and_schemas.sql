-- ============================================================================
-- EXTENSIONS AND SCHEMA SETUP
-- ============================================================================
-- Enable required extensions and create application schemas
-- PostgreSQL best practice: avoid public schema for application data

-- Create extensions schema first (before installing extensions)
CREATE SCHEMA IF NOT EXISTS extensions AUTHORIZATION postgres;
COMMENT ON SCHEMA extensions IS 'PostgreSQL extensions (uuid-ossp, pgcrypto, vector)';

-- Enable required extensions in dedicated schema
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS "vector" WITH SCHEMA extensions;

-- Revoke public schema creation (PostgreSQL 15+ best practice)
-- Prevents untrusted users from creating objects in public schema
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- Create application schemas with clear ownership and purpose
CREATE SCHEMA IF NOT EXISTS app_cache AUTHORIZATION postgres;
CREATE SCHEMA IF NOT EXISTS app_embeddings AUTHORIZATION postgres;
CREATE SCHEMA IF NOT EXISTS app_monitoring AUTHORIZATION postgres;

-- Schema documentation
COMMENT ON SCHEMA app_cache IS 'Search and location caching with automatic cleanup';
COMMENT ON SCHEMA app_embeddings IS 'Vector embeddings for semantic search using pgvector (1536 dimensions, OpenAI ada-002)';
COMMENT ON SCHEMA app_monitoring IS 'Observability views, health checks, and performance metrics';

-- Set search_path for new roles (will be applied in next migration)
-- This prevents accidental public schema pollution
-- Note: User-level search_path will be set when roles are created
