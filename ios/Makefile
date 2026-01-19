# QuickNovel iOS Build System
# This Makefile provides commands for building the QuickNovel iOS app and generating IPAs

# Configuration
PROJECT_NAME = QuickNovel
SCHEME = $(PROJECT_NAME)
WORKSPACE = $(PROJECT_NAME).xcworkspace
PROJECT = $(PROJECT_NAME).xcodeproj
CONFIGURATION_DEBUG = Debug
CONFIGURATION_RELEASE = Release
BUNDLE_ID = com.lagradost.quicknovel

# Paths
BUILD_DIR = build
ARCHIVE_PATH = $(BUILD_DIR)/$(PROJECT_NAME).xcarchive
IPA_DIR = $(BUILD_DIR)/ipa
EXPORT_OPTIONS_PLIST = ExportOptions.plist

# Default target device
DEVICE = "iPhone 15"
IOS_VERSION = 15.0

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
NC = \033[0m # No Color

.PHONY: help install clean build archive ipa simulator test lint setup export-options

# Default target
help:
	@echo "$(GREEN)QuickNovel iOS Build System$(NC)"
	@echo ""
	@echo "Available commands:"
	@echo "  $(YELLOW)make setup$(NC)           - Complete project setup (install CocoaPods, generate workspace)"
	@echo "  $(YELLOW)make install$(NC)         - Install CocoaPods dependencies"
	@echo "  $(YELLOW)make build$(NC)           - Build the project for simulator (Debug)"
	@echo "  $(YELLOW)make build-release$(NC)   - Build the project for device (Release)"
	@echo "  $(YELLOW)make simulator$(NC)       - Build and run on iOS Simulator"
	@echo "  $(YELLOW)make archive$(NC)         - Create an archive for distribution"
	@echo "  $(YELLOW)make ipa$(NC)             - Build and export IPA for distribution"
	@echo "  $(YELLOW)make ipa-adhoc$(NC)       - Build and export IPA for Ad-Hoc distribution"
	@echo "  $(YELLOW)make ipa-development$(NC) - Build and export IPA for development"
	@echo "  $(YELLOW)make test$(NC)            - Run unit tests"
	@echo "  $(YELLOW)make clean$(NC)           - Clean build artifacts"
	@echo "  $(YELLOW)make clean-all$(NC)       - Clean all build artifacts and dependencies"
	@echo ""
	@echo "$(GREEN)Requirements:$(NC)"
	@echo "  - macOS with Xcode 15.0 or later"
	@echo "  - CocoaPods (install with: sudo gem install cocoapods)"
	@echo "  - Valid Apple Developer account for IPA distribution"
	@echo ""

# Complete setup
setup: install
	@echo "$(GREEN)✓ Project setup complete!$(NC)"
	@echo "$(YELLOW)Next steps:$(NC)"
	@echo "  1. Open $(WORKSPACE) in Xcode"
	@echo "  2. Configure code signing in Xcode project settings"
	@echo "  3. Run 'make build' to build the project"

# Install CocoaPods dependencies
install:
	@echo "$(GREEN)Installing CocoaPods dependencies...$(NC)"
	@if ! command -v pod > /dev/null; then \
		echo "$(RED)Error: CocoaPods not found. Install it with: sudo gem install cocoapods$(NC)"; \
		exit 1; \
	fi
	@pod install --repo-update
	@echo "$(GREEN)✓ Dependencies installed$(NC)"

# Clean build artifacts
clean:
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	@rm -rf $(BUILD_DIR)
	@rm -rf DerivedData
	@xcodebuild clean -workspace $(WORKSPACE) -scheme $(SCHEME) 2>/dev/null || \
		xcodebuild clean -project $(PROJECT) -scheme $(SCHEME) 2>/dev/null || true
	@echo "$(GREEN)✓ Build artifacts cleaned$(NC)"

# Clean everything including dependencies
clean-all: clean
	@echo "$(YELLOW)Cleaning all dependencies...$(NC)"
	@rm -rf Pods
	@rm -rf $(WORKSPACE)
	@rm -rf ~/Library/Developer/Xcode/DerivedData/$(PROJECT_NAME)-*
	@echo "$(GREEN)✓ All artifacts and dependencies cleaned$(NC)"

# Build for simulator (Debug)
build:
	@echo "$(GREEN)Building for iOS Simulator (Debug)...$(NC)"
	@if [ -d "$(WORKSPACE)" ]; then \
		xcodebuild build \
			-workspace $(WORKSPACE) \
			-scheme $(SCHEME) \
			-configuration $(CONFIGURATION_DEBUG) \
			-destination "platform=iOS Simulator,name=$(DEVICE)" \
			-derivedDataPath $(BUILD_DIR)/DerivedData \
			| xcpretty || xcodebuild build \
				-workspace $(WORKSPACE) \
				-scheme $(SCHEME) \
				-configuration $(CONFIGURATION_DEBUG) \
				-destination "platform=iOS Simulator,name=$(DEVICE)" \
				-derivedDataPath $(BUILD_DIR)/DerivedData; \
	else \
		echo "$(YELLOW)Workspace not found. Installing dependencies first...$(NC)"; \
		$(MAKE) install; \
		xcodebuild build \
			-workspace $(WORKSPACE) \
			-scheme $(SCHEME) \
			-configuration $(CONFIGURATION_DEBUG) \
			-destination "platform=iOS Simulator,name=$(DEVICE)" \
			-derivedDataPath $(BUILD_DIR)/DerivedData \
			| xcpretty || xcodebuild build \
				-workspace $(WORKSPACE) \
				-scheme $(SCHEME) \
				-configuration $(CONFIGURATION_DEBUG) \
				-destination "platform=iOS Simulator,name=$(DEVICE)" \
				-derivedDataPath $(BUILD_DIR)/DerivedData; \
	fi
	@echo "$(GREEN)✓ Build completed$(NC)"

# Build for device (Release)
build-release:
	@echo "$(GREEN)Building for iOS Device (Release)...$(NC)"
	@if [ -d "$(WORKSPACE)" ]; then \
		xcodebuild build \
			-workspace $(WORKSPACE) \
			-scheme $(SCHEME) \
			-configuration $(CONFIGURATION_RELEASE) \
			-sdk iphoneos \
			-derivedDataPath $(BUILD_DIR)/DerivedData \
			| xcpretty || xcodebuild build \
				-workspace $(WORKSPACE) \
				-scheme $(SCHEME) \
				-configuration $(CONFIGURATION_RELEASE) \
				-sdk iphoneos \
				-derivedDataPath $(BUILD_DIR)/DerivedData; \
	else \
		echo "$(YELLOW)Workspace not found. Installing dependencies first...$(NC)"; \
		$(MAKE) install; \
		xcodebuild build \
			-workspace $(WORKSPACE) \
			-scheme $(SCHEME) \
			-configuration $(CONFIGURATION_RELEASE) \
			-sdk iphoneos \
			-derivedDataPath $(BUILD_DIR)/DerivedData \
			| xcpretty || xcodebuild build \
				-workspace $(WORKSPACE) \
				-scheme $(SCHEME) \
				-configuration $(CONFIGURATION_RELEASE) \
				-sdk iphoneos \
				-derivedDataPath $(BUILD_DIR)/DerivedData; \
	fi
	@echo "$(GREEN)✓ Release build completed$(NC)"

# Run on simulator
simulator: build
	@echo "$(GREEN)Launching on iOS Simulator...$(NC)"
	@xcrun simctl boot "$(DEVICE)" 2>/dev/null || true
	@xcrun simctl install "$(DEVICE)" $(BUILD_DIR)/DerivedData/Build/Products/$(CONFIGURATION_DEBUG)-iphonesimulator/$(PROJECT_NAME).app
	@xcrun simctl launch "$(DEVICE)" $(BUNDLE_ID)
	@echo "$(GREEN)✓ App launched on simulator$(NC)"

# Create archive for distribution
archive:
	@echo "$(GREEN)Creating archive...$(NC)"
	@if [ ! -d "$(WORKSPACE)" ]; then \
		echo "$(YELLOW)Workspace not found. Installing dependencies first...$(NC)"; \
		$(MAKE) install; \
	fi
	@mkdir -p $(BUILD_DIR)
	@xcodebuild archive \
		-workspace $(WORKSPACE) \
		-scheme $(SCHEME) \
		-configuration $(CONFIGURATION_RELEASE) \
		-archivePath $(ARCHIVE_PATH) \
		-sdk iphoneos \
		-destination "generic/platform=iOS" \
		| xcpretty || xcodebuild archive \
			-workspace $(WORKSPACE) \
			-scheme $(SCHEME) \
			-configuration $(CONFIGURATION_RELEASE) \
			-archivePath $(ARCHIVE_PATH) \
			-sdk iphoneos \
			-destination "generic/platform=iOS"
	@echo "$(GREEN)✓ Archive created at $(ARCHIVE_PATH)$(NC)"

# Generate export options plist
export-options:
	@echo "$(GREEN)Generating ExportOptions.plist...$(NC)"
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > $(EXPORT_OPTIONS_PLIST)
	@echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> $(EXPORT_OPTIONS_PLIST)
	@echo '<plist version="1.0">' >> $(EXPORT_OPTIONS_PLIST)
	@echo '<dict>' >> $(EXPORT_OPTIONS_PLIST)
	@echo '    <key>method</key>' >> $(EXPORT_OPTIONS_PLIST)
	@echo '    <string>app-store</string>' >> $(EXPORT_OPTIONS_PLIST)
	@echo '    <key>teamID</key>' >> $(EXPORT_OPTIONS_PLIST)
	@echo '    <string>XXXXXXXXXX</string>' >> $(EXPORT_OPTIONS_PLIST)
	@echo '    <key>uploadBitcode</key>' >> $(EXPORT_OPTIONS_PLIST)
	@echo '    <false/>' >> $(EXPORT_OPTIONS_PLIST)
	@echo '    <key>uploadSymbols</key>' >> $(EXPORT_OPTIONS_PLIST)
	@echo '    <true/>' >> $(EXPORT_OPTIONS_PLIST)
	@echo '    <key>compileBitcode</key>' >> $(EXPORT_OPTIONS_PLIST)
	@echo '    <false/>' >> $(EXPORT_OPTIONS_PLIST)
	@echo '</dict>' >> $(EXPORT_OPTIONS_PLIST)
	@echo '</plist>' >> $(EXPORT_OPTIONS_PLIST)
	@echo "$(YELLOW)Note: Edit $(EXPORT_OPTIONS_PLIST) and replace XXXXXXXXXX with your 10-character Apple Developer Team ID$(NC)"
	@echo "$(GREEN)✓ ExportOptions.plist generated$(NC)"

# Export IPA for App Store distribution
ipa: archive
	@echo "$(GREEN)Exporting IPA for App Store distribution...$(NC)"
	@if [ ! -f "$(EXPORT_OPTIONS_PLIST)" ]; then \
		echo "$(YELLOW)ExportOptions.plist not found. Generating default...$(NC)"; \
		$(MAKE) export-options; \
	fi
	@mkdir -p $(IPA_DIR)
	@xcodebuild -exportArchive \
		-archivePath $(ARCHIVE_PATH) \
		-exportPath $(IPA_DIR) \
		-exportOptionsPlist $(EXPORT_OPTIONS_PLIST) \
		| xcpretty || xcodebuild -exportArchive \
			-archivePath $(ARCHIVE_PATH) \
			-exportPath $(IPA_DIR) \
			-exportOptionsPlist $(EXPORT_OPTIONS_PLIST)
	@echo "$(GREEN)✓ IPA exported to $(IPA_DIR)$(NC)"
	@ls -lh $(IPA_DIR)/*.ipa

# Export IPA for Ad-Hoc distribution
ipa-adhoc:
	@echo "$(GREEN)Exporting IPA for Ad-Hoc distribution...$(NC)"
	@$(MAKE) archive
	@mkdir -p $(IPA_DIR)
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > $(EXPORT_OPTIONS_PLIST).adhoc
	@echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> $(EXPORT_OPTIONS_PLIST).adhoc
	@echo '<plist version="1.0">' >> $(EXPORT_OPTIONS_PLIST).adhoc
	@echo '<dict>' >> $(EXPORT_OPTIONS_PLIST).adhoc
	@echo '    <key>method</key>' >> $(EXPORT_OPTIONS_PLIST).adhoc
	@echo '    <string>ad-hoc</string>' >> $(EXPORT_OPTIONS_PLIST).adhoc
	@echo '    <key>teamID</key>' >> $(EXPORT_OPTIONS_PLIST).adhoc
	@echo '    <string>XXXXXXXXXX</string>' >> $(EXPORT_OPTIONS_PLIST).adhoc
	@echo '    <key>uploadBitcode</key>' >> $(EXPORT_OPTIONS_PLIST).adhoc
	@echo '    <false/>' >> $(EXPORT_OPTIONS_PLIST).adhoc
	@echo '    <key>compileBitcode</key>' >> $(EXPORT_OPTIONS_PLIST).adhoc
	@echo '    <false/>' >> $(EXPORT_OPTIONS_PLIST).adhoc
	@echo '</dict>' >> $(EXPORT_OPTIONS_PLIST).adhoc
	@echo '</plist>' >> $(EXPORT_OPTIONS_PLIST).adhoc
	@xcodebuild -exportArchive \
		-archivePath $(ARCHIVE_PATH) \
		-exportPath $(IPA_DIR)/adhoc \
		-exportOptionsPlist $(EXPORT_OPTIONS_PLIST).adhoc \
		| xcpretty || xcodebuild -exportArchive \
			-archivePath $(ARCHIVE_PATH) \
			-exportPath $(IPA_DIR)/adhoc \
			-exportOptionsPlist $(EXPORT_OPTIONS_PLIST).adhoc
	@echo "$(GREEN)✓ Ad-Hoc IPA exported to $(IPA_DIR)/adhoc$(NC)"
	@ls -lh $(IPA_DIR)/adhoc/*.ipa

# Export IPA for development
ipa-development:
	@echo "$(GREEN)Exporting IPA for Development...$(NC)"
	@$(MAKE) archive
	@mkdir -p $(IPA_DIR)
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > $(EXPORT_OPTIONS_PLIST).dev
	@echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> $(EXPORT_OPTIONS_PLIST).dev
	@echo '<plist version="1.0">' >> $(EXPORT_OPTIONS_PLIST).dev
	@echo '<dict>' >> $(EXPORT_OPTIONS_PLIST).dev
	@echo '    <key>method</key>' >> $(EXPORT_OPTIONS_PLIST).dev
	@echo '    <string>development</string>' >> $(EXPORT_OPTIONS_PLIST).dev
	@echo '    <key>teamID</key>' >> $(EXPORT_OPTIONS_PLIST).dev
	@echo '    <string>XXXXXXXXXX</string>' >> $(EXPORT_OPTIONS_PLIST).dev
	@echo '    <key>uploadBitcode</key>' >> $(EXPORT_OPTIONS_PLIST).dev
	@echo '    <false/>' >> $(EXPORT_OPTIONS_PLIST).dev
	@echo '    <key>compileBitcode</key>' >> $(EXPORT_OPTIONS_PLIST).dev
	@echo '    <false/>' >> $(EXPORT_OPTIONS_PLIST).dev
	@echo '</dict>' >> $(EXPORT_OPTIONS_PLIST).dev
	@echo '</plist>' >> $(EXPORT_OPTIONS_PLIST).dev
	@xcodebuild -exportArchive \
		-archivePath $(ARCHIVE_PATH) \
		-exportPath $(IPA_DIR)/development \
		-exportOptionsPlist $(EXPORT_OPTIONS_PLIST).dev \
		| xcpretty || xcodebuild -exportArchive \
			-archivePath $(ARCHIVE_PATH) \
			-exportPath $(IPA_DIR)/development \
			-exportOptionsPlist $(EXPORT_OPTIONS_PLIST).dev
	@echo "$(GREEN)✓ Development IPA exported to $(IPA_DIR)/development$(NC)"
	@ls -lh $(IPA_DIR)/development/*.ipa

# Run tests
test:
	@echo "$(GREEN)Running tests...$(NC)"
	@if [ ! -d "$(WORKSPACE)" ]; then \
		echo "$(YELLOW)Workspace not found. Installing dependencies first...$(NC)"; \
		$(MAKE) install; \
	fi
	@xcodebuild test \
		-workspace $(WORKSPACE) \
		-scheme $(SCHEME) \
		-destination "platform=iOS Simulator,name=$(DEVICE)" \
		-derivedDataPath $(BUILD_DIR)/DerivedData \
		| xcpretty || xcodebuild test \
			-workspace $(WORKSPACE) \
			-scheme $(SCHEME) \
			-destination "platform=iOS Simulator,name=$(DEVICE)" \
			-derivedDataPath $(BUILD_DIR)/DerivedData
	@echo "$(GREEN)✓ Tests completed$(NC)"

# Lint code (if SwiftLint is installed)
lint:
	@echo "$(GREEN)Running SwiftLint...$(NC)"
	@if command -v swiftlint > /dev/null; then \
		swiftlint; \
	else \
		echo "$(YELLOW)SwiftLint not installed. Install with: brew install swiftlint$(NC)"; \
	fi
