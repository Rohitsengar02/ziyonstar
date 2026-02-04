#!/bin/bash

echo "🚀 Starting Flutter Web Build..."

# Download Flutter SDK
echo "📦 Downloading Flutter SDK..."
if [ -d "flutter" ]; then
  echo "✅ Flutter directory exists, updating..."
  cd flutter
  git pull origin stable
  cd ..
else
  echo "⬇️  Cloning Flutter SDK (stable branch)..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# Set Flutter path
export PATH="$PATH:`pwd`/flutter/bin"

echo "🔧 Flutter Configuration..."
flutter config --enable-web --no-analytics

echo "📦 Installing Dependencies..."
flutter pub get

echo "🏗️  Building Web App..."
flutter build web --release --no-wasm-dry-run

echo "✅ Build Complete!"
