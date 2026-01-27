-- ============================================================================
-- APPLICATION ROLES AND PRIVILEGES
-- ============================================================================
-- Create dedicated application roles for fine-grained access control
-- PostgreSQL best practice: separate read-only, read-write, and admin roles

-- ============================================================================
-- ROLE CREATION
-- ============================================================================

-- Read-only role (for dashboards, monitoring, analytics)
CREATE ROLE app_readonly NOLOGIN;
COMMENT ON ROLE app_readonly IS 'Read-only access to cache, embeddings, and monitoring data';

-- Read-write role (for backend application cache operations)
CREATE ROLE app_readwrite NOLOGIN;
COMMENT ON ROLE app_readwrite IS 'Read-write access to cache tables, read-only to embeddings';

-- Admin role (for embedding service, manual cleanup, administrative tasks)
CREATE ROLE app_admin NOLOGIN;
COMMENT ON ROLE app_admin IS 'Full control over all application schemas and objects';

-- ============================================================================
-- SCHEMA PRIVILEGES
-- ============================================================================

-- app_readonly: USAGE on all schemas, SELECT on all tables
GRANT USAGE ON SCHEMA app_cache, app_embeddings, app_monitoring TO app_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA app_cache, app_embeddings, app_monitoring
  GRANT SELECT ON TABLES TO app_readonly;

-- app_readwrite: USAGE on schemas, SELECT/INSERT/UPDATE on cache, SELECT on embeddings
GRANT USAGE ON SCHEMA app_cache, app_embeddings, app_monitoring TO app_readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA app_cache
  GRANT SELECT, INSERT, UPDATE ON TABLES TO app_readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA app_embeddings, app_monitoring
  GRANT SELECT ON TABLES TO app_readwrite;

-- app_admin: ALL privileges on all schemas
GRANT ALL ON SCHEMA app_cache, app_embeddings, app_monitoring TO app_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA app_cache, app_embeddings, app_monitoring
  GRANT ALL ON TABLES TO app_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA app_cache, app_embeddings, app_monitoring
  GRANT ALL ON SEQUENCES TO app_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA app_cache, app_embeddings, app_monitoring
  GRANT ALL ON FUNCTIONS TO app_admin;

-- ============================================================================
-- SEARCH PATH CONFIGURATION
-- ============================================================================
-- Set default search_path for each role to prefer application schemas

ALTER ROLE app_readonly SET search_path TO app_cache, app_embeddings, app_monitoring, public;
ALTER ROLE app_readwrite SET search_path TO app_cache, app_embeddings, app_monitoring, public;
ALTER ROLE app_admin SET search_path TO app_cache, app_embeddings, app_monitoring, public;
