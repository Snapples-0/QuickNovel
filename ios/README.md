# iOS Build System - Quick Reference

This directory contains a complete iOS build system using a Makefile for easy IPA generation.

## Quick Start

```bash
# First time setup
make setup

# Build and run on simulator
make simulator

# Create an IPA
make ipa
```

## Common Commands

### Setup & Dependencies
```bash
make setup          # Complete project setup
make install        # Install CocoaPods dependencies only
```

### Building
```bash
make build          # Build for simulator (Debug)
make build-release  # Build for device (Release)
make simulator      # Build and run on iOS Simulator
```

### IPA Generation
```bash
make ipa              # App Store distribution IPA
make ipa-adhoc        # Ad-Hoc distribution IPA  
make ipa-development  # Development IPA
```

### Testing & Maintenance
```bash
make test       # Run unit tests
make clean      # Clean build artifacts
make clean-all  # Clean everything including dependencies
```

### Help
```bash
make help       # Show all available commands
```

## Requirements

- **macOS** 13.0 (Ventura) or later
- **Xcode** 15.0 or later
- **CocoaPods** - Install with: `sudo gem install cocoapods`
- **Apple Developer Account** (for IPA distribution)

## Before Creating IPAs

1. **Configure Code Signing:**
   - Open `QuickNovel.xcworkspace` in Xcode
   - Select the QuickNovel target
   - Go to "Signing & Capabilities"
   - Select your development team

2. **Set Your Team ID:**
   - After running `make ipa` once, edit `ExportOptions.plist`
   - Replace `YOUR_TEAM_ID` with your Apple Developer Team ID
   - Find your Team ID in Apple Developer Portal > Membership

## Output Locations

- **Simulator builds:** `build/DerivedData/Build/Products/Debug-iphonesimulator/`
- **Archives:** `build/QuickNovel.xcarchive`
- **IPAs:**
  - App Store: `build/ipa/`
  - Ad-Hoc: `build/ipa/adhoc/`
  - Development: `build/ipa/development/`

## Troubleshooting

### "Command not found: pod"
Install CocoaPods:
```bash
sudo gem install cocoapods
```

### "No such file or directory: QuickNovel.xcworkspace"
Run dependencies install first:
```bash
make install
```

### Code Signing Errors
1. Open project in Xcode: `open QuickNovel.xcworkspace`
2. Fix signing issues in Xcode's Signing & Capabilities tab
3. Try building in Xcode first to ensure signing is correct
4. Then retry the Makefile commands

### "YOUR_TEAM_ID not found"
Edit `ExportOptions.plist` and set your real Team ID

## More Information

See [BUILD_GUIDE.md](BUILD_GUIDE.md) for comprehensive build instructions and architecture details.
