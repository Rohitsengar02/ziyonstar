#!/bin/bash

# Define paths
ROOT_DIR="/Users/patelpulseventures/Documents/rohit/Ziyonstar/ziyonstar"
TECH_DIR="$ROOT_DIR/technitian_panal"
ADMIN_DIR="$ROOT_DIR/admin_panal"
USER_APP_DIR="$ROOT_DIR"
DEST_DIR="/Users/patelpulseventures/Documents/ZIYONSTARAPP"

# Create destination directory
mkdir -p "$DEST_DIR"
echo "Created destination folder: $DEST_DIR"

# --- Technician App ---
echo "Processing Technician App..."
cd "$TECH_DIR"
# Generate Icons and Splash
flutter pub get
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
# Build APK
flutter build apk --release
# Copy APK
cp "build/app/outputs/flutter-apk/app-release.apk" "$DEST_DIR/technician_app.apk"
echo "Technician App built and copied."

# --- Admin Panel ---
echo "Processing Admin Panel..."
cd "$ADMIN_DIR"
# Generate Icons and Splash
flutter pub get
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
# Build APK
flutter build apk --release
# Copy APK
cp "build/app/outputs/flutter-apk/app-release.apk" "$DEST_DIR/admin_app.apk"
echo "Admin App built and copied."

# --- User App ---
echo "Processing User App..."
cd "$USER_APP_DIR"
# Assuming User App also needs icon generation if configured, but user didn't explicitly ask to change it.
# However, for safety, we just build. If icons are configured in pubspec, we could run it, but let's stick to the specific request for Tech and Admin icons.
# Build APK
flutter build apk --release
# Copy APK
cp "build/app/outputs/flutter-apk/app-release.apk" "$DEST_DIR/user_app.apk"
echo "User App built and copied."

echo "All builds completed successfully! APKs are in $DEST_DIR"
ls -l "$DEST_DIR"
