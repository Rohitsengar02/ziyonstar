#!/bin/bash

echo "Downloading Flutter..."
if [ -d "flutter" ]; then
  cd flutter
  git pull
  cd ..
else
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

echo "Building Web App..."
./flutter/bin/flutter config --enable-web
./flutter/bin/flutter build web --release
