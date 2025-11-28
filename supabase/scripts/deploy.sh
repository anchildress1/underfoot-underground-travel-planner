#!/bin/bash
set -e

echo "🚀 Deploying Supabase migrations..."

# Check if Supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI not found. Install with: brew install supabase/tap/supabase"
    exit 1
fi

# Check required environment variables
if [ -z "$SUPABASE_PROJECT_REF" ]; then
    echo "❌ SUPABASE_PROJECT_REF environment variable not set"
    exit 1
fi

# Link project
echo "🔗 Linking to Supabase project: $SUPABASE_PROJECT_REF"
supabase link --project-ref "$SUPABASE_PROJECT_REF"

# Push migrations
echo "📦 Pushing migrations..."
supabase db push

# Verify deployment
echo "✅ Verifying deployment..."
supabase inspect db --schema=public

echo "🎉 Deployment complete!"
