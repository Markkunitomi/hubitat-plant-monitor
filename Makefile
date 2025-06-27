# HubitatSensor Makefile
# Provides convenient command-line build targets

.PHONY: build build-debug build-release clean install help

# Default target
all: build

# Build debug version (default)
build: build-debug

# Build debug version
build-debug:
	@echo "Building Debug version..."
	xcodebuild -scheme HubitatSensor \
		-configuration Debug \
		build \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO

# Build release version with local derived data
build-release:
	@echo "Building Release version..."
	xcodebuild -scheme HubitatSensor \
		-configuration Release \
		-derivedDataPath ./build \
		build \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	xcodebuild -scheme HubitatSensor clean
	rm -rf ./build

# Install to Applications folder (requires release build)
install: build-release
	@echo "Installing to Applications folder..."
	@if [ -d "./build/Build/Products/Release/HubitatSensor.app" ]; then \
		cp -r "./build/Build/Products/Release/HubitatSensor.app" /Applications/; \
		echo "✅ Installed to /Applications/HubitatSensor.app"; \
	else \
		echo "❌ Release build not found. Run 'make build-release' first."; \
		exit 1; \
	fi

# Run the app (from release build)
run: build-release
	@echo "Running HubitatSensor..."
	open "./build/Build/Products/Release/HubitatSensor.app"

# Show build info
info:
	@echo "HubitatSensor Build Information"
	@echo "=============================="
	xcodebuild -list
	@echo ""
	@echo "Available build commands:"
	@echo "  make build        - Build debug version"
	@echo "  make build-debug  - Build debug version"
	@echo "  make build-release- Build release version"
	@echo "  make clean        - Clean build artifacts"
	@echo "  make install      - Install to Applications folder"
	@echo "  make run          - Build and run the app"
	@echo "  make help         - Show this help"

# Show help
help: info