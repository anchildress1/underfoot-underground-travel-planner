# CI/CD Configuration

## GitHub Actions Secrets

Required secrets for automated workflows. Add these in GitHub repository Settings → Secrets and variables → Actions.

### Supabase Deployment

| Secret Name | Description | Where to Get It |
| - | - | - |
| `SUPABASE_ACCESS_TOKEN` | Supabase CLI authentication token | [Supabase Dashboard → Account → Access Tokens](https://supabase.com/dashboard/account/tokens) - Create a new access token |
| `SUPABASE_PROJECT_REF` | Supabase project reference ID | Found in your Supabase project settings URL: `https://supabase.com/dashboard/project/YOUR_PROJECT_REF` |

**How to add secrets:**
```bash
# In GitHub repository:
# 1. Go to Settings → Secrets and variables → Actions
# 2. Click "New repository secret"
# 3. Add each secret:
#    - Name: SUPABASE_ACCESS_TOKEN
#    - Value: <your-token-from-supabase>
#    - Name: SUPABASE_PROJECT_REF
#    - Value: <your-project-ref>
```

### What the SUPABASE_ACCESS_TOKEN is for:

This is **NOT** your database credentials. This is a **personal access token** for the Supabase CLI:

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Click your profile (top right)
3. Go to "Account" → "Access Tokens"
4. Click "Generate new token"
5. Give it a name (e.g., "GitHub Actions")
6. Copy the token (it won't be shown again)
7. Add it to GitHub secrets as `SUPABASE_ACCESS_TOKEN`

The CLI uses this token to authenticate when running `supabase link` and `supabase db push` in the workflow.

## Workflows

### Supabase Deploy (`.github/workflows/supabase-deploy.yml`)

**Triggers:**
- Push to `main` branch with changes in `supabase/migrations/**` or `supabase/scripts/**`
- Manual workflow dispatch

**Permissions:**
- `contents: read` (only needs to read repository files)

**What it does:**
1. Checks out code
2. Installs Supabase CLI
3. Links to your Supabase project using `SUPABASE_PROJECT_REF`
4. Pushes new migrations with `supabase db push`
5. Verifies deployment with `supabase inspect db`

**Required secrets:**
- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_PROJECT_REF`

## CloudFlare Workers Secrets (Future)

When deploying the Python backend to CloudFlare Workers, you'll need to set these secrets using `wrangler secret put`:

```bash
# Run these commands in the backend directory:
cd backend

# Required secrets for backend functionality:
wrangler secret put OPENAI_API_KEY
wrangler secret put GEOAPIFY_API_KEY
wrangler secret put SERPAPI_KEY
wrangler secret put REDDIT_CLIENT_ID
wrangler secret put REDDIT_CLIENT_SECRET
wrangler secret put EVENTBRITE_TOKEN
wrangler secret put SUPABASE_URL
wrangler secret put SUPABASE_PUBLISHABLE_KEY
wrangler secret put SUPABASE_SECRET_KEY
```

These are separate from GitHub Actions secrets and are managed directly in CloudFlare.

## Security Notes

- Never commit `.env` files containing real secrets
- Use `.env.example` files to document required variables
- GitHub Actions secrets are encrypted and never shown in logs
- CloudFlare Workers secrets are encrypted at rest
- Supabase access tokens should be scoped to specific projects when possible
- Rotate tokens/keys periodically

---

Generated-by: Verdent AI
