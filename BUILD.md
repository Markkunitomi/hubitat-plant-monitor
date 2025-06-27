# Building HubitatSensor from Command Line

This document provides instructions for building the HubitatSensor macOS app from the command line without keeping Xcode open.

## Prerequisites

- Xcode 15 or later installed
- macOS 13.0 or later
- Command Line Tools for Xcode

## Quick Start

### Method 1: Using Makefile (Recommended)

```bash
# Build debug version
make build

# Build release version  
make build-release

# Install to Applications folder
make install

# Build and run
make run

# Clean build artifacts
make clean

# Show available commands
make help
```

### Method 2: Using Build Scripts

```bash
# Build debug version
./build.sh

# Build release version
./build-release.sh

# Clean previous builds first
./build.sh clean
```

### Method 3: Direct xcodebuild Commands

```bash
# Build debug version (unsigned for testing)
xcodebuild -scheme HubitatSensor \
           -configuration Debug \
           build \
           CODE_SIGN_IDENTITY="" \
           CODE_SIGNING_REQUIRED=NO

# Build release version with local output
xcodebuild -scheme HubitatSensor \
           -configuration Release \
           -derivedDataPath ./build \
           build \
           CODE_SIGN_IDENTITY="" \
           CODE_SIGNING_REQUIRED=NO

# Clean build artifacts
xcodebuild -scheme HubitatSensor clean
```

## Build Outputs

### Debug Builds
Debug builds are stored in the system's DerivedData directory:
```
~/Library/Developer/Xcode/DerivedData/HubitatSensor-*/Build/Products/Debug/HubitatSensor.app
```

### Release Builds
Release builds (when using local derivedDataPath) are stored in:
```
./build/Build/Products/Release/HubitatSensor.app
```

## Code Signing

The provided build commands disable code signing for development purposes:
- `CODE_SIGN_IDENTITY=""`
- `CODE_SIGNING_REQUIRED=NO`

For distribution, you'll need to:
1. Set up a Developer ID certificate in Xcode
2. Remove the code signing overrides
3. Optionally notarize the app for Gatekeeper

## Project Structure

- **No external dependencies** - Pure Swift/AppKit project
- **Single target** - HubitatSensor app
- **No package managers** - No CocoaPods, Carthage, or Swift Package Manager dependencies

## Available Schemes and Configurations

```bash
# List all available schemes and configurations
xcodebuild -list
```

Current project has:
- **Target**: HubitatSensor
- **Schemes**: HubitatSensor  
- **Configurations**: Debug, Release

## Troubleshooting

### Build Fails with Signing Errors
Use the code signing overrides as shown in the examples above.

### Cannot Find xcodebuild
Ensure Xcode Command Line Tools are installed:
```bash
xcode-select --install
```

### App Won't Run Due to Security
For unsigned apps, you may need to:
1. Right-click the app and select "Open"
2. Allow the app in System Preferences > Security & Privacy

### Missing Derived Data
If the app isn't found in the expected location, check:
```bash
# Find all HubitatSensor.app bundles
find ~/Library/Developer/Xcode/DerivedData -name "HubitatSensor.app" 2>/dev/null
```

## Distribution

For distributing the app:

1. **Build release version**:
   ```bash
   make build-release
   ```

2. **Create ZIP archive**:
   ```bash
   cd build/Build/Products/Release
   zip -r HubitatSensor-$(date +%Y%m%d).zip HubitatSensor.app
   ```

3. **Install locally**:
   ```bash
   make install
   ```

## Environment Details

- **Target OS**: macOS 13.0+
- **Architecture**: Universal (arm64/x86_64)  
- **Bundle ID**: com.github.hubitat-plant-monitor
- **App Category**: Utilities
- **Background App**: Yes (LSUIElement = YES)