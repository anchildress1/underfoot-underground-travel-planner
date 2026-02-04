# Cloudflare Pages Deployment Guide for Flutter Web

This guide covers deploying the Underfoot Flutter web application to Cloudflare Pages.

## Prerequisites

- Cloudflare account with Pages enabled
- Flutter SDK 3.29+ installed
- Git repository connected to Cloudflare (or direct upload)

## Build Configuration

### Local Build

```bash
cd mobile
flutter build web --release --web-renderer canvaskit
```

Build output: `mobile/build/web/`

### Environment-Specific API Base

Pass the API base URL at build time:

```bash
# Production
flutter build web --release --dart-define=API_BASE=https://api.checkmarkdevtools.dev

# Staging
flutter build web --release --dart-define=API_BASE=https://staging-api.checkmarkdevtools.dev

# Local dev
flutter build web --release --dart-define=API_BASE=http://localhost:8000
```

## Cloudflare Pages Setup

### Option 1: Git Integration (Recommended)

1. Go to Cloudflare Dashboard > Pages > Create a project
2. Connect your GitHub/GitLab repository
3. Configure build settings:
   - **Framework preset**: None
   - **Build command**: `cd mobile && flutter build web --release`
   - **Build output directory**: `mobile/build/web`
   - **Root directory**: `/` (repo root)

4. Environment variables (optional):
   - `FLUTTER_WEB_CANVASKIT_URL`: Custom CanvasKit CDN (optional)

### Option 2: Direct Upload

```bash
cd mobile
flutter build web --release
npx wrangler pages deploy build/web --project-name=underfoot
```

## Custom Domain Setup

1. Go to Pages project > Custom domains
2. Add domain: `checkmarkdevtools.dev/underfoot` or `underfoot.checkmarkdevtools.dev`
3. Follow DNS configuration instructions
4. SSL certificate provisioned automatically

## Backend CORS Configuration

The backend must allow your Cloudflare Pages domain. Already configured in `backend/underfoot/settings.py`:

```python
CORS_ALLOWED_ORIGIN_REGEXES = [
    r"^https://.*\.pages\.dev$",
    r"^https://.*checkmarkdevtools\.dev$",
]
```

## Performance Optimizations

### CanvasKit vs HTML Renderer

- **CanvasKit** (default): Better fidelity, larger download (~2MB)
- **HTML**: Smaller download, some visual differences

```bash
# HTML renderer (smaller)
flutter build web --release --web-renderer html

# CanvasKit (recommended for production)
flutter build web --release --web-renderer canvaskit
```

### Caching Headers

Add `_headers` file in `mobile/web/`:

```
/*
  Cache-Control: public, max-age=31536000, immutable

/index.html
  Cache-Control: no-cache

/flutter_service_worker.js
  Cache-Control: no-cache
```

## Testing Deployment

1. **Preview deployment**: Every push creates a preview URL at `*.underfoot.pages.dev`
2. **Production**: Merges to main branch deploy to production URL

### Smoke Test Checklist

- [ ] App loads without JavaScript errors
- [ ] Theme toggle works (light/dark)
- [ ] Chat input accepts messages
- [ ] API calls succeed (check Network tab)
- [ ] PWA installable (check Application tab > Manifest)

## Troubleshooting

### CORS Errors

If you see CORS errors:
1. Verify backend CORS settings include your Pages domain
2. Check the backend is running and accessible
3. Confirm the API_BASE URL is correct

### Blank Screen

1. Check browser console for errors
2. Verify Flutter assets loaded (flutter.js, main.dart.js)
3. Try HTML renderer if CanvasKit fails

### Service Worker Issues

Clear service worker cache:
1. DevTools > Application > Service Workers > Unregister
2. Clear site data
3. Hard refresh

## CI/CD Integration

Example GitHub Actions workflow (`.github/workflows/deploy-flutter.yml`):

```yaml
name: Deploy Flutter Web

on:
  push:
    branches: [main]
    paths:
      - 'mobile/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.0'
          channel: 'stable'
      
      - name: Build
        working-directory: mobile
        run: flutter build web --release
      
      - name: Deploy to Cloudflare Pages
        uses: cloudflare/pages-action@v1
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          projectName: underfoot
          directory: mobile/build/web
```

Required secrets:
- `CLOUDFLARE_API_TOKEN`: API token with Pages edit permissions
- `CLOUDFLARE_ACCOUNT_ID`: Your Cloudflare account ID

## Mobile Deployment Notes

### Android

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
# Requires Mac with Xcode
```

See [Flutter deployment docs](https://docs.flutter.dev/deployment) for app store submissions.
