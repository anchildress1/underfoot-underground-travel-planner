# Android Testing & Deployment Guide

## Prerequisites

### Google Maps API Key (Required for Android)

The app requires a Google Maps API key to run on Android. See [GOOGLE_MAPS_SETUP.md](GOOGLE_MAPS_SETUP.md) for complete setup instructions.

**Quick setup:**
1. Get API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable "Maps SDK for Android"
3. Add to `mobile/android/local.properties`:
   ```
   GOOGLE_MAPS_API_KEY=YOUR_KEY_HERE
   ```

## Quick Test on Android Device

### Prerequisites
- Android device with USB debugging enabled
- USB cable
- Android device connected to same network as your dev machine

### Steps

1. **Enable USB Debugging on Android:**
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times to enable Developer Options
   - Go to Settings → Developer Options
   - Enable "USB Debugging"

2. **Connect Device & Verify:**
   ```bash
   # Connect via USB, then verify
   flutter devices
   # Should show your Android device
   ```

3. **Set Backend URL for Testing:**
   
   **Option A: Use Your Machine's Local IP**
   ```bash
   # Find your local IP
   ifconfig | grep "inet " | grep -v 127.0.0.1
   
   # Update mobile/lib/core/constants/env_config.dart
   # Change defaultValue from 'http://localhost:8000' to 'http://YOUR_IP:8000'
   # Example: 'http://192.168.1.100:8000'
   ```

4. **Build & Run on Android:**
   ```bash
   cd mobile
   flutter run -d <device-id>
   # Or just: flutter run (will prompt for device)
   ```

5. **Check Logs:**
   ```bash
   flutter logs
   # Look for debug logs with emojis: 🔍 📦 ✅ ❌
   ```

## Build Release APK

### Debug Build (for testing)
```bash
cd mobile
flutter build apk --debug
# Output: mobile/build/app/outputs/flutter-apk/app-debug.apk
```

### Release Build (for distribution)
```bash
cd mobile
flutter build apk --release
# Output: mobile/build/app/outputs/flutter-apk/app-release.apk
```

### Install APK on Device
```bash
# Via ADB
adb install build/app/outputs/flutter-apk/app-release.apk

# Or share the APK file and install manually
```

## Network Configuration for Testing

### Option 1: Local Network (Recommended for Testing)

1. **Find your machine's IP:**
   ```bash
   # macOS
   ipconfig getifaddr en0
   
   # Linux
   ip addr show | grep "inet " | grep -v 127.0.0.1
   ```

2. **Update env_config.dart:**
   ```dart
   static const String apiBase = String.fromEnvironment(
     'API_BASE',
     defaultValue: 'http://192.168.1.XXX:8000', // Your machine's IP
   );
   ```

3. **Ensure backend allows connections:**
   - Backend already has `ALLOWED_HOSTS = ["*"]` in settings
   - CORS updated to allow all localhost ports

### Option 2: Use ngrok (for external testing)

```bash
# Install ngrok (if not installed)
brew install ngrok

# Start ngrok tunnel
ngrok http 8000

# Use the ngrok URL in env_config.dart
# defaultValue: 'https://abc123.ngrok.io'
```

### Option 3: Deploy Backend to Cloud

Deploy backend to:
- Render.com (free tier)
- Railway.app
- Heroku
- Your own VPS

Update `apiBase` to point to your deployed backend URL.

## Production Deployment

### Android App Store (Google Play)

1. **Create keystore:**
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload
   ```

2. **Configure signing (mobile/android/key.properties):**
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=/Users/<you>/upload-keystore.jks
   ```

3. **Update build.gradle:**
   Reference key.properties in `mobile/android/app/build.gradle`

4. **Build app bundle:**
   ```bash
   flutter build appbundle --release
   ```

5. **Upload to Google Play Console**

### iOS App Store

1. **Requirements:**
   - macOS with Xcode
   - Apple Developer Account ($99/year)

2. **Build for iOS:**
   ```bash
   cd mobile
   flutter build ios --release
   ```

3. **Open in Xcode & Archive:**
   ```bash
   open ios/Runner.xcworkspace
   ```

4. **Submit via Xcode**

## Backend Deployment

### Quick Deploy to Render.com

1. **Create render.yaml:**
   ```yaml
   services:
     - type: web
       name: underfoot-backend
       env: python
       buildCommand: cd backend && uv sync && uv run python manage.py migrate
       startCommand: cd backend && uv run gunicorn underfoot.wsgi:application --bind 0.0.0.0:$PORT
       envVars:
         - key: DJANGO_SECRET_KEY
           generateValue: true
         - key: DEBUG
           value: False
         - key: SUPABASE_URL
           sync: false
         - key: SUPABASE_KEY
           sync: false
         - key: OPENAI_API_KEY
           sync: false
   ```

2. **Push to GitHub**

3. **Connect to Render:**
   - Go to render.com
   - New → Web Service
   - Connect your repo
   - Deploy

4. **Update Flutter app:**
   Update `apiBase` to your Render URL

## Troubleshooting

### "Connection refused" on Android

- Verify backend is running: `curl http://localhost:8000/api/underfoot/health`
- Verify device can reach your machine: `ping YOUR_MACHINE_IP` from device
- Check firewall isn't blocking port 8000
- Use your machine's IP, not localhost

### CORS errors

- Backend CORS now allows all localhost ports
- For production, update CORS_ALLOWED_ORIGINS in settings.py

### Debug logs not showing

```bash
# Flutter console
flutter logs

# Or adb logcat
adb logcat | grep flutter
```

## Quick Test Checklist

- [ ] Backend running (`make dev` or manual)
- [ ] Android device connected & visible (`flutter devices`)
- [ ] env_config.dart has correct IP (not localhost)
- [ ] App installed (`flutter run -d <device>`)
- [ ] Send a test message
- [ ] Check console for debug logs (🔍 📦 ✅)
- [ ] Verify places appear
- [ ] Check map placeholder shows
- [ ] Toggle dark mode works
- [ ] Debug panel opens (bug icon)
