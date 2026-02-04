#!/bin/bash
set -e

echo "🤖 Underfoot Mobile - Android Testing Setup"
echo "==========================================="
echo ""

# Find local IP
echo "📡 Finding your local IP address..."
LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')

if [ -z "$LOCAL_IP" ]; then
    echo "❌ Could not detect local IP. Please find it manually:"
    echo "   Run: ifconfig | grep 'inet '"
    exit 1
fi

echo "✅ Your local IP: $LOCAL_IP"
echo ""

# Update env_config.dart
ENV_CONFIG="lib/core/constants/env_config.dart"

echo "📝 Updating API base URL in $ENV_CONFIG..."

# Backup original
cp "$ENV_CONFIG" "$ENV_CONFIG.backup"

# Replace localhost with local IP
sed -i '' "s|defaultValue: 'http://localhost:8000'|defaultValue: 'http://$LOCAL_IP:8000'|g" "$ENV_CONFIG"

echo "✅ Updated API base URL to: http://$LOCAL_IP:8000"
echo ""

# Check if backend is running
echo "🔍 Checking if backend is running..."
if curl -s "http://localhost:8000/api/underfoot/health" > /dev/null 2>&1; then
    echo "✅ Backend is running"
else
    echo "⚠️  Backend not running. Start it with:"
    echo "   cd ../backend && uv run python manage.py runserver"
    echo ""
fi

# Check for connected devices
echo "📱 Checking for connected Android devices..."
DEVICES=$(flutter devices | grep android | wc -l | tr -d ' ')

if [ "$DEVICES" -eq "0" ]; then
    echo "❌ No Android devices found"
    echo ""
    echo "Please connect your Android device via USB and enable USB debugging:"
    echo "  1. Go to Settings → About Phone"
    echo "  2. Tap 'Build Number' 7 times"
    echo "  3. Go to Settings → Developer Options"
    echo "  4. Enable 'USB Debugging'"
    echo "  5. Connect via USB and authorize the computer"
    echo ""
    echo "Then run this script again."
    exit 1
fi

echo "✅ Found $DEVICES Android device(s)"
echo ""

# Offer to build and run
echo "🚀 Ready to build and run on Android!"
echo ""
echo "Options:"
echo "  1. Run debug build (hot reload enabled)"
echo "  2. Build release APK only"
echo "  3. Exit"
echo ""

read -p "Choose option (1-3): " choice

case $choice in
    1)
        echo "🔨 Building and running debug build..."
        flutter run
        ;;
    2)
        echo "🔨 Building release APK..."
        flutter build apk --release
        echo ""
        echo "✅ APK built: build/app/outputs/flutter-apk/app-release.apk"
        echo ""
        echo "Install it with:"
        echo "  adb install build/app/outputs/flutter-apk/app-release.apk"
        ;;
    3)
        echo "👋 Exiting"
        echo ""
        echo "To restore original config:"
        echo "  mv $ENV_CONFIG.backup $ENV_CONFIG"
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

echo ""
echo "📋 Testing Checklist:"
echo "  [ ] Backend running on your machine"
echo "  [ ] Android device on same WiFi network"
echo "  [ ] App installed and running"
echo "  [ ] Send a test message"
echo "  [ ] Check for places in results"
echo ""
echo "To restore original config later:"
echo "  mv $ENV_CONFIG.backup $ENV_CONFIG"
