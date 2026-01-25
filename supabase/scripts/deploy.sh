#!/bin/bash
set -e

# Exit codes:
# 1 = CLI tool missing (supabase not installed)
# 2 = Required env var missing (SUPABASE_PROJECT_REF)

echo "⚠️  DESTRUCTIVE DEPLOYMENT - NO DATA MIGRATION"
echo "🚀 Deploying Supabase schema (TimescaleDB + pgvector)..."
echo ""

# Load .env file if it exists
ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
    echo "📂 Loading environment from '$ENV_FILE'"
    set -o allexport
    source "$ENV_FILE"
    set +o allexport
    echo "   ✓ Loaded $(grep -cE '^\s*[A-Za-z_][A-Za-z0-9_]*=' "$ENV_FILE") variables"
else
    echo "⚠️  No '$ENV_FILE' found. Will check for environment exports..."
fi

# Check if Supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI not found. Install with: brew install supabase/tap/supabase"
    exit 1
fi

# Check required environment variables
if [ -z "$SUPABASE_PROJECT_REF" ]; then
    echo "❌ SUPABASE_PROJECT_REF is empty or not set. Set it in '$ENV_FILE' or export it."
    exit 2
fi

# Detect migrations directory
MIGRATION_DIR="supabase/migrations"

if [ ! -d "$MIGRATION_DIR" ]; then
    echo "❌ Migration directory not found: $MIGRATION_DIR"
    echo "   Run this script from project root"
    exit 3
fi

echo "📁 Using migrations: $MIGRATION_DIR"
echo "   Files: $(ls -1 "$MIGRATION_DIR"/*.sql 2>/dev/null | wc -l | tr -d ' ')"
echo ""
echo "⚠️  This will:"
echo "   - Drop existing public schema (ALL DATA LOST)"
echo "   - Create new app schemas (app_cache, app_embeddings, app_monitoring)"
echo "   - Enable TimescaleDB hypertables with compression + retention"
echo "   - Retention: 14 days (search), 60 days (location) - DOUBLED FOR TESTING"
echo ""
read -p "Continue? (type 'yes' to proceed): " confirm
if [ "$confirm" != "yes" ]; then
    echo "❌ Deployment cancelled"
    exit 0
fi

# Link project
echo "🔗 Linking to Supabase project: '$SUPABASE_PROJECT_REF'"
supabase link --project-ref "$SUPABASE_PROJECT_REF"

# Push migrations
echo "📦 Pushing migrations from $MIGRATION_DIR..."
supabase db push

# Verify deployment
echo "✅ Verifying deployment..."
supabase inspect db --schema=app_cache,app_embeddings,app_monitoring

echo ""
echo "🎉 Deployment complete!"
echo ""
echo "⚠️  CRITICAL NEXT STEPS:"
echo "   1. Create app_admin login role in Timescale Cloud console:"
echo "      CREATE ROLE app_admin_user WITH LOGIN PASSWORD 'secure_password';"
echo "      GRANT app_admin TO app_admin_user;"
echo "   2. Update backend .env:"
echo "      SUPABASE_KEY=<app_admin_user_password>"
echo "   3. Update all backend code to use schema-qualified names:"
echo "      app_cache.search_results (was search_results)"
echo "      app_cache.location_cache (was location_cache)"
echo "      app_embeddings.places_embeddings (was places_embeddings)"
echo "      app_embeddings.search_places_by_similarity(...)"
echo "   4. Run verification queries from migrations/README.md"
echo "   5. Test retention: data older than 14/60 days will be auto-deleted"
echo ""
echo "📖 See migrations/README.md for complete deployment guide"
