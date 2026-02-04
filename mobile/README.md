# Underfoot Mobile

Flutter frontend for the Underfoot Underground Travel Planner.

## Features

- 🎨 Beautiful light/dark theme with Electric Violet/Magenta palette
- 📱 Responsive design (mobile, tablet, desktop)
- 💬 Real-time chat interface
- 🗺️ Google Maps integration (native) / Custom map view (web)
- ♿ WCAG AA accessibility compliance
- 🎯 BLoC state management
- ✅ Comprehensive test suite (35+ tests)

## Prerequisites

- Flutter SDK 3.29+ ([Install Flutter](https://docs.flutter.dev/get-started/install))
- For iOS development: Xcode with iOS 12.0+ support
- For Android development: Android Studio with API level 21+
- Backend running at `localhost:8000`

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run on web (Chrome)
flutter run -d chrome

# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android
```

## Development Commands

```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Build for web
flutter build web --release

# Build for iOS
flutter build ios --release

# Build for Android
flutter build apk --release
```

## Testing

### Unit Tests (21 tests)
Tests for models, services, repositories, BLoCs, and theme configuration.

```bash
flutter test test/unit/
```

### Widget Tests (14 tests)
Tests for individual UI components and full app rendering.

```bash
flutter test test/widget/
```

### Integration Tests (6 tests)
End-to-end tests covering complete user flows.

**Note:** Integration tests require a platform target (iOS/Android) and cannot run on web.

```bash
# Run on iOS simulator
flutter test integration_test/app_test.dart -d ios

# Run on Android emulator
flutter test integration_test/app_test.dart -d android
```

## Project Structure

```
lib/
├── app.dart                          # Root MaterialApp
├── main.dart                         # Entry point
├── core/
│   ├── theme/                        # Light/dark themes, colors
│   └── constants/                    # API endpoints, constants
├── data/
│   ├── models/                       # Data models (Place, SearchResponse)
│   ├── services/                     # API client
│   └── repositories/                 # Data repositories
└── presentation/
    ├── blocs/                        # State management (BLoC)
    ├── screens/                      # App screens
    └── widgets/                      # Reusable widgets
```

## Architecture

- **State Management:** BLoC pattern with flutter_bloc
- **API Client:** HTTP with json_serialization
- **Navigation:** Material Navigator
- **Theme:** Material Design 3 with custom color palette
- **Persistence:** SharedPreferences for theme settings

## Environment Configuration

Pass the API base URL at build time:

```bash
# Production
flutter build web --dart-define=API_BASE=https://api.checkmarkdevtools.dev

# Local dev (default)
flutter run -d chrome --dart-define=API_BASE=http://localhost:8000
```

## Deployment

See [Cloudflare Flutter Deployment Guide](../docs/tech_guides/CLOUDFLARE_FLUTTER_DEPLOYMENT.md) for complete deployment instructions.

### Quick Deploy to Cloudflare Pages

```bash
flutter build web --release
npx wrangler pages deploy build/web --project-name=underfoot
```

## Accessibility

All components include:
- Semantic labels for screen readers
- Proper focus traversal
- WCAG AA contrast ratios (≥4.5:1 for text)
- Keyboard navigation support

## Performance

- CanvasKit renderer for high-fidelity graphics
- Tree-shaken icon fonts (99.4% size reduction)
- Lazy loading for images
- Efficient list builders with `const` constructors

## Troubleshooting

### "Connection refused" when sending messages

Ensure the Django backend is running:
```bash
cd ../backend && uv run python manage.py runserver
```

### Google Maps not showing on web

Google Maps Flutter plugin requires a native platform. On web, a custom placeholder map is shown.

### Theme not persisting

SharedPreferences requires initialization. Clear app data and restart if issues persist.

## Contributing

1. Format code before committing: `dart format .`
2. Ensure all tests pass: `flutter test`
3. Run analyzer: `flutter analyze`
4. Follow existing code style and patterns

## License

See parent project LICENSE.
