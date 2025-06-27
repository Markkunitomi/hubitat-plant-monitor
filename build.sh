#!/bin/bash

# HubitatSensor Build Script
# This script builds the HubitatSensor macOS app from command line without keeping Xcode open

set -e  # Exit on any error

echo "🔨 Building HubitatSensor macOS App"
echo "=================================="

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

# Build configurations
PROJECT_NAME="HubitatSensor"
SCHEME_NAME="HubitatSensor"

echo "📁 Project directory: $SCRIPT_DIR"
echo "🎯 Building scheme: $SCHEME_NAME"

# Clean previous build (optional)
if [[ "$1" == "clean" ]]; then
    echo "🧹 Cleaning previous build..."
    xcodebuild -scheme "$SCHEME_NAME" clean
fi

# Build the app
echo "⚙️  Building Debug configuration..."
xcodebuild -scheme "$SCHEME_NAME" \
           -configuration Debug \
           build \
           CODE_SIGN_IDENTITY="" \
           CODE_SIGNING_REQUIRED=NO

# Build success
echo "✅ Build completed successfully!"

# Find the built app
DERIVED_DATA_PATH=$(xcodebuild -showBuildSettings -scheme "$SCHEME_NAME" | grep BUILT_PRODUCTS_DIR | head -1 | awk '{print $3}')
if [[ -n "$DERIVED_DATA_PATH" ]]; then
    APP_PATH="$DERIVED_DATA_PATH/$PROJECT_NAME.app"
    echo "📱 Built app location: $APP_PATH"
    
    if [[ -d "$APP_PATH" ]]; then
        echo "🎉 App bundle created successfully!"
        echo ""
        echo "To run the app:"
        echo "  open \"$APP_PATH\""
        echo ""
        echo "To copy to Applications folder:"
        echo "  cp -r \"$APP_PATH\" /Applications/"
    else
        echo "⚠️  Warning: App bundle not found at expected location"
    fi
else
    echo "⚠️  Warning: Could not determine build output path"
fi

echo ""
echo "🏁 Build script completed"