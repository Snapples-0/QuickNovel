# QuickNovel iOS Build Guide

This document provides comprehensive instructions for building and running the QuickNovel iOS app.

## Prerequisites

### Required Software
- **macOS** 13.0 (Ventura) or later
- **Xcode** 15.0 or later
- **iOS Device or Simulator** running iOS 15.0+
- **CocoaPods** (for dependency management)

### Installing CocoaPods
If you don't have CocoaPods installed:
```bash
sudo gem install cocoapods
```

## Setup Instructions

### Option A: Using Makefile (Recommended)

The project includes a Makefile for streamlined building and IPA generation.

#### 1. Quick Setup
```bash
cd ios
make setup
```

This will install all dependencies and prepare the project.

#### 2. Building the App
```bash
# Build for simulator (Debug)
make build

# Build for device (Release)
make build-release

# Run on iOS Simulator
make simulator
```

#### 3. Creating an IPA
```bash
# Generate IPA for App Store distribution
make ipa

# Generate IPA for Ad-Hoc distribution
make ipa-adhoc

# Generate IPA for Development
make ipa-development
```

**Note:** Before creating IPAs, you need to:
1. Configure code signing in Xcode
2. Edit `ExportOptions.plist` and set your Apple Developer Team ID

#### 4. Other Commands
```bash
# Run tests
make test

# Clean build artifacts
make clean

# Clean everything including dependencies
make clean-all

# Show all available commands
make help
```

### Option B: Using Xcode GUI

#### 1. Clone the Repository
```bash
git clone https://github.com/LagradOst/QuickNovel.git
cd QuickNovel
```

#### 2. Install Dependencies
```bash
cd ios
pod install
```

#### 3. Open the Project
```bash
open QuickNovel.xcworkspace
```

**Important:** Always open the `.xcworkspace` file, not the `.xcodeproj` file, when using CocoaPods.

#### 4. Configure Code Signing
1. In Xcode, select the `QuickNovel` project in the navigator
2. Select the `QuickNovel` target
3. Go to the "Signing & Capabilities" tab
4. Select your development team from the dropdown
5. Xcode will automatically manage your provisioning profile

#### 5. Select Your Target Device
- For simulator: Choose any iOS simulator from the device dropdown
- For physical device: Connect your iPhone/iPad and select it from the dropdown

#### 6. Build and Run
- Press `Cmd + R` or click the Play button in Xcode
- The app will build and launch on your selected device

## Project Structure

```
ios/
├── QuickNovel/
│   ├── QuickNovelApp.swift          # App entry point
│   ├── ContentView.swift             # Main navigation
│   ├── Info.plist                    # App configuration
│   ├── Models/
│   │   └── Models.swift              # Data models
│   ├── Views/
│   │   ├── HomeView.swift            # Home screen
│   │   ├── SearchView.swift          # Search interface
│   │   ├── DownloadsView.swift       # Downloads management
│   │   ├── HistoryView.swift         # Reading history
│   │   ├── SettingsView.swift        # App settings
│   │   ├── NovelDetailView.swift     # Novel details
│   │   ├── ReaderView.swift          # Reading interface
│   │   └── EmptyStateView.swift      # Empty state UI
│   ├── ViewModels/
│   │   └── ViewModels.swift          # All view models
│   ├── Providers/
│   │   ├── ProviderProtocol.swift    # Provider interface
│   │   ├── RoyalRoadProvider.swift   # Royal Road implementation
│   │   └── AllProviders.swift        # All provider implementations
│   ├── Network/
│   │   └── NetworkManager.swift      # Networking layer
│   ├── Services/
│   │   ├── TTSManager.swift          # Text-to-Speech
│   │   ├── DownloadManager.swift     # Download management
│   │   └── StorageManager.swift      # Local storage
│   └── Assets.xcassets/              # App assets
├── QuickNovel.xcodeproj/             # Xcode project
├── Podfile                           # CocoaPods dependencies
└── Package.swift                     # Swift Package Manager

```

## Features Implemented

### ✅ Completed
- [x] SwiftUI-based user interface
- [x] Tab-based navigation (Home, Search, Downloads, History, Settings)
- [x] Multi-provider novel search (20+ providers)
- [x] Novel detail view with chapters
- [x] Reading interface with customizable settings
  - Font family, size, and color
  - Background color
  - Line spacing and alignment
  - Bionic reading mode
- [x] Text-to-Speech (TTS) with AVSpeechSynthesizer
  - Adjustable speech rate
  - Adjustable pitch
  - Play/Pause/Stop controls
- [x] Download management
  - Progress tracking
  - Pause/Resume support
  - EPUB generation
- [x] Reading history tracking
- [x] Bookmark management
- [x] Local storage with UserDefaults
- [x] Network caching
- [x] Provider implementations for 20+ sources

### 🚧 In Progress / Future Enhancements
- [ ] iCloud sync for bookmarks and progress
- [ ] iPad optimization with split view
- [ ] Apple Pencil annotations
- [ ] Offline reading mode improvements
- [ ] Advanced EPUB reader features
- [ ] Share extension for importing from Safari
- [ ] Widget support for recent novels
- [ ] Dark mode optimization
- [ ] Accessibility improvements (VoiceOver, Dynamic Type)
- [ ] Complete provider HTML parsing with SwiftSoup

## Architecture

### MVVM Pattern
The app follows the Model-View-ViewModel (MVVM) architectural pattern:

- **Models**: Data structures (SearchResponse, ChapterData, etc.)
- **Views**: SwiftUI views for UI components
- **ViewModels**: Business logic and state management (@ObservableObject)

### Key Components

#### 1. Provider System
Each novel source implements the `NovelProvider` protocol:
```swift
protocol NovelProvider {
    func search(query: String) async throws -> [SearchResponse]
    func load(url: String) async throws -> LoadResponse
    func loadHtml(url: String) async throws -> ChapterContent
}
```

#### 2. Network Layer
`NetworkManager` handles all HTTP requests with:
- Automatic caching (10-minute TTL)
- Custom headers and User-Agent
- Error handling for rate limits and Cloudflare
- Async/await support

#### 3. Storage Layer
`StorageManager` provides persistent storage:
- Bookmarks
- Reading history
- Reading progress
- App settings
- Downloaded novels

#### 4. Services
- **TTSManager**: Text-to-Speech functionality
- **DownloadManager**: Novel and chapter downloads
- **StorageManager**: Local data persistence

## Debugging

### Common Issues

#### 1. Build Errors
```
Error: Module 'SwiftSoup' not found
```
**Solution:** Run `pod install` in the ios directory

#### 2. Code Signing Errors
```
Error: Failed to register bundle identifier
```
**Solution:** Change the bundle identifier in Xcode to something unique

#### 3. Runtime Crashes
- Check the Xcode console for error messages
- Enable zombie objects for memory debugging
- Use Instruments for performance profiling

### Logging
The app uses standard `print()` statements. To view logs:
1. Run the app in Xcode
2. Open the Console (Cmd + Shift + C)
3. Filter by "QuickNovel" to see app-specific logs

## Testing

### Unit Tests
```bash
# Run unit tests
xcodebuild test -workspace QuickNovel.xcworkspace \
    -scheme QuickNovel \
    -destination 'platform=iOS Simulator,name=iPhone 15'
```

### UI Tests
- Open the project in Xcode
- Press Cmd + U to run all tests
- Or select Product > Test from the menu

## Distribution

### Building IPA Files

The project includes a Makefile for automated IPA generation. There are three distribution methods:

#### 1. App Store Distribution
For submitting to the App Store or TestFlight:
```bash
cd ios
make ipa
```

This will:
1. Create an archive of your app
2. Export an IPA suitable for App Store submission
3. Place the IPA in `build/ipa/`

#### 2. Ad-Hoc Distribution
For distributing to specific devices (up to 100 devices):
```bash
make ipa-adhoc
```

The IPA will be placed in `build/ipa/adhoc/`

#### 3. Development Distribution
For internal testing on development devices:
```bash
make ipa-development
```

The IPA will be placed in `build/ipa/development/`

### Prerequisites for IPA Generation
1. **Valid Apple Developer Account** ($99/year)
2. **Code Signing Certificate** (Developer or Distribution)
3. **Provisioning Profile** for your app
4. **Team ID** from Apple Developer account

### Configuring Code Signing for IPA

1. Open the project in Xcode:
   ```bash
   open QuickNovel.xcworkspace
   ```

2. Select the QuickNovel project, then the QuickNovel target

3. Go to "Signing & Capabilities" tab

4. Check "Automatically manage signing"

5. Select your Team from the dropdown

6. For distribution builds, ensure you have a valid Distribution certificate

### Setting Your Team ID

After running `make ipa` for the first time, edit the generated `ExportOptions.plist`:

```xml
<key>teamID</key>
<string>YOUR_TEAM_ID</string>
```

Replace `YOUR_TEAM_ID` with your actual 10-character Team ID from:
- Apple Developer Portal > Membership
- Or Xcode > Preferences > Accounts > Your Team

### Manual Archive and Export (Alternative)

If you prefer using Xcode GUI:

1. **Create Archive:**
   - Product > Archive
   - Wait for the archive to complete
   - Xcode Organizer will open automatically

2. **Export IPA:**
   - Select your archive in the Organizer
   - Click "Distribute App"
   - Choose distribution method:
     - App Store Connect (for TestFlight/App Store)
     - Ad Hoc (for specific devices)
     - Development (for testing)
   - Follow the wizard to export the IPA

### TestFlight
1. Archive the app (Product > Archive)
2. Upload to App Store Connect
3. Submit for TestFlight review
4. Invite beta testers

### App Store
1. Complete App Store Connect listing
2. Submit for review
3. Wait for approval (typically 24-48 hours)

## Performance Optimization

### Memory Management
- All network responses are cached for 10 minutes
- Images are loaded asynchronously with SwiftUI's AsyncImage
- Large novel content is paginated

### Network Optimization
- Concurrent provider searches
- Request deduplication
- Automatic retry with exponential backoff

## Contributing

See the main README.md for contribution guidelines.

## Support

For issues specific to the iOS version:
1. Check existing GitHub issues
2. Join the Discord: https://discord.gg/5Hus6fM
3. Create a new issue with:
   - iOS version
   - Device model
   - Xcode version
   - Detailed steps to reproduce

## License

Same as the main project - see LICENSE file.

## Acknowledgments

- Original Android app by LagradOst
- iOS port uses SwiftUI and modern Swift concurrency
- Provider implementations adapted from Android Kotlin code
- Icons from SF Symbols
