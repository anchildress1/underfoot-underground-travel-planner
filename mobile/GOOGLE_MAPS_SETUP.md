# Google Maps Setup for Android

## Quick Setup

### 1. Get Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable **Maps SDK for Android**:
   - Navigation menu → APIs & Services → Library
   - Search "Maps SDK for Android"
   - Click Enable
4. Create API key:
   - APIs & Services → Credentials
   - Create Credentials → API Key
   - Copy the key

### 2. Configure API Key

Edit `mobile/android/local.properties`:

```properties
GOOGLE_MAPS_API_KEY=YOUR_ACTUAL_API_KEY_HERE
```

**Example:**
```properties
GOOGLE_MAPS_API_KEY=AIzaSyD1234567890abcdefghijklmnopqrstuv
```

### 3. Restrict API Key (Recommended)

For production, restrict your API key:

1. Go to Google Cloud Console → Credentials
2. Click your API key
3. Under "Application restrictions":
   - Select "Android apps"
   - Add your package name: `dev.checkmarkdevtools.underfoot_mobile`
   - Add SHA-1 certificate fingerprint:
     ```bash
     # Debug certificate
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```

### 4. Rebuild & Run

```bash
cd mobile
flutter clean
flutter run
```

## Troubleshooting

### "API key not found" Error

**Cause:** `local.properties` not configured or API key missing

**Fix:**
1. Check `mobile/android/local.properties` exists
2. Verify `GOOGLE_MAPS_API_KEY` is set (no quotes, no spaces)
3. Run `flutter clean && flutter run`

### Maps Show Gray Screen

**Causes:**
- API key not enabled for Maps SDK for Android
- API key restrictions blocking your app
- Network connection issues

**Fix:**
1. Verify Maps SDK for Android is enabled in Google Cloud Console
2. Check API key restrictions allow your package name
3. Wait 5-10 minutes after enabling API (propagation time)

### Build Errors After Adding Key

```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

## Environment-Specific Keys

### Development
Use `local.properties` (gitignored)

### CI/CD
Set environment variable and inject during build:

**GitHub Actions:**
```yaml
- name: Create local.properties
  run: |
    echo "GOOGLE_MAPS_API_KEY=${{ secrets.GOOGLE_MAPS_API_KEY }}" > mobile/android/local.properties
```

**GitLab CI:**
```yaml
before_script:
  - echo "GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY" > mobile/android/local.properties
```

### Production APK
Same as above - inject key during build in CI/CD

## iOS Setup

For iOS, edit `mobile/ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_IOS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

Enable **Maps SDK for iOS** in Google Cloud Console.

## Web Setup

Google Maps doesn't work on Flutter Web with `google_maps_flutter` package. The app shows a placeholder grid instead. For production web, consider:

- Using `google_maps` JavaScript package via `dart:html`
- Using a different mapping library (Leaflet, Mapbox)
- Accepting the placeholder for web (mobile apps are primary)

## Cost & Billing

- Google Maps Platform requires billing account
- Free tier: $200 credit/month
- Maps SDK for Android: $7 per 1000 loads (after free tier)
- Monitor usage in Google Cloud Console

## Security Best Practices

✅ **DO:**
- Restrict API keys to specific apps (package name + SHA-1)
- Use separate keys for dev/staging/prod
- Enable only required APIs
- Monitor usage and set quotas
- Keep `local.properties` in `.gitignore`

❌ **DON'T:**
- Commit API keys to git
- Use same key for all environments
- Leave keys unrestricted
- Embed keys directly in code

## Alternative: No Google Maps

If you don't want to set up Google Maps:

1. The app will crash on Android without the key
2. Options:
   - **Option A:** Add a placeholder that doesn't crash (like web)
   - **Option B:** Disable map feature on Android
   - **Option C:** Use a different mapping provider

To disable crashing, wrap `GoogleMap` widget in error handler.
