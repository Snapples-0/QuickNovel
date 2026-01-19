# iOS IPA Build Workflow

This GitHub Actions workflow automatically builds an IPA (iOS App) file for the QuickNovel iOS application.

## Workflow Details

- **File**: `.github/workflows/build-ios.yml`
- **Name**: Build iOS IPA
- **Trigger**: Runs on push to any branch
- **Runner**: macOS (latest)

## What It Does

1. **Checks out the repository** - Gets the latest code
2. **Sets up Xcode** - Configures the latest stable version of Xcode
3. **Installs CocoaPods** - Installs iOS dependencies
4. **Builds and Archives** - Creates an iOS archive without code signing
5. **Exports IPA** - Packages the archive into an IPA file
6. **Uploads Artifact** - Makes the IPA available for download

## Downloading the IPA

1. Navigate to the repository's **Actions** tab on GitHub
2. Click on the latest **Build iOS IPA** workflow run
3. Scroll down to the **Artifacts** section
4. Download the **QuickNovel-iOS** artifact
5. Extract the downloaded zip file to get `QuickNovel.ipa`

## Important Notes

### Code Signing

This workflow builds an **unsigned IPA** suitable for:
- Testing and development purposes
- Reviewing the build process
- Automated CI/CD verification

The unsigned IPA **cannot** be installed on physical devices without additional steps.

### For App Store Distribution

To create a signed IPA for App Store or device installation:
1. Build locally using Xcode or the Makefile
2. Configure proper code signing with your Apple Developer account
3. Use a valid provisioning profile

See the [iOS BUILD_GUIDE.md](../../ios/BUILD_GUIDE.md) for detailed instructions.

## Technical Details

### Build Configuration

- **Workspace**: `QuickNovel.xcworkspace`
- **Scheme**: `QuickNovel`
- **Configuration**: Release
- **SDK**: iOS (iphoneos)
- **Destination**: Generic iOS device

### Code Signing Settings

The workflow disables code signing to allow builds without certificates:
```
CODE_SIGN_IDENTITY=""
CODE_SIGNING_REQUIRED=NO
CODE_SIGNING_ALLOWED=NO
```

### Fallback Mechanism

If the standard IPA export fails, the workflow automatically:
1. Extracts the `.app` bundle from the archive
2. Creates a `Payload` directory structure
3. Manually zips it into an IPA file

This ensures the workflow produces an artifact even if export fails.

## Troubleshooting

### Workflow Fails During Archive

- Check that all Swift dependencies are correctly specified
- Verify CocoaPods installation completed successfully
- Review the Xcode version compatibility

### IPA Not Found

- Check the workflow logs for errors during the export step
- Verify the fallback manual IPA creation executed

### Cannot Install IPA on Device

- This is expected for unsigned IPAs
- Use Xcode or a signed build for device installation
- Consider using TestFlight for distribution

## Modifications

To customize this workflow:

1. **Change Xcode version**: Edit the `xcode-version` in the "Set up Xcode" step
2. **Add signing**: Remove or modify the `CODE_SIGN_*` parameters
3. **Change trigger**: Modify the `on:` section to trigger on specific branches or tags
4. **Add tests**: Insert a test step before building

## Related Files

- **Workflow**: `.github/workflows/build-ios.yml`
- **iOS Project**: `ios/QuickNovel.xcodeproj`
- **Makefile**: `ios/Makefile` (for local builds)
- **Build Guide**: `ios/BUILD_GUIDE.md`
