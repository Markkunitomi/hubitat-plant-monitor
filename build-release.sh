#!/bin/bash

# HubitatSensor Release Build Script
# This script builds a release version of the HubitatSensor macOS app

set -e  # Exit on any error

echo "🚀 Building HubitatSensor Release Build"
echo "======================================"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

# Build configurations
PROJECT_NAME="HubitatSensor"
SCHEME_NAME="HubitatSensor"

echo "📁 Project directory: $SCRIPT_DIR"
echo "🎯 Building scheme: $SCHEME_NAME (Release)"

# Clean previous build
echo "🧹 Cleaning previous builds..."
xcodebuild -scheme "$SCHEME_NAME" clean

# Build the release version
echo "⚙️  Building Release configuration..."
xcodebuild -scheme "$SCHEME_NAME" \
           -configuration Release \
           -derivedDataPath ./build \
           build \
           CODE_SIGN_IDENTITY="" \
           CODE_SIGNING_REQUIRED=NO

# Build success
echo "✅ Release build completed successfully!"

# Find the built app in local build directory
LOCAL_BUILD_PATH="./build/Build/Products/Release"
APP_PATH="$LOCAL_BUILD_PATH/$PROJECT_NAME.app"

if [[ -d "$APP_PATH" ]]; then
    echo "📱 Built app location: $SCRIPT_DIR/$APP_PATH"
    
    # Get app info
    APP_SIZE=$(du -sh "$APP_PATH" | cut -f1)
    echo "📦 App bundle size: $APP_SIZE"
    
    echo "🎉 Release app bundle created successfully!"
    echo ""
    echo "To run the app:"
    echo "  open \"$SCRIPT_DIR/$APP_PATH\""
    echo ""
    echo "To install in Applications folder:"
    echo "  cp -r \"$SCRIPT_DIR/$APP_PATH\" /Applications/"
    echo ""
    echo "To create a distributable archive:"
    echo "  cd \"$SCRIPT_DIR\""
    echo "  zip -r HubitatSensor-$(date +%Y%m%d).zip \"$APP_PATH\""
else
    echo "❌ Error: App bundle not found at $APP_PATH"
    exit 1
fi

echo ""
echo "🏁 Release build script completed"