# iOS Manual Signing with Provisioning Profiles - Setup Guide

## Overview
Your iOS app has been configured for **manual signing** using provisioning profiles. This means you need to provide specific provisioning profiles for each build configuration.

## Current Configuration

### Team ID
- **95UD7HJB4N**

### Bundle Identifiers (from AppSpecific.xcconfig)
- **Dev**: `com.example.app.dev`
- **Staging**: `com.example.app.staging`
- **Sandbox**: `com.example.app.sandbox`
- **Production**: `com.example.app`

### Build Configurations
1. **Debug-dev** → Development builds (uses iPhone Developer certificate)
2. **Release-dev** → Development release (uses iPhone Developer certificate)
3. **Profile-dev** → Development profiling (uses iPhone Developer certificate)
4. **Debug-staging** → Staging builds (uses iPhone Distribution certificate)
5. **Release-staging** → Staging release (uses iPhone Distribution certificate)
6. **Profile-staging** → Staging profiling (uses iPhone Distribution certificate)
7. **Debug-sandbox** → Sandbox builds (uses iPhone Distribution certificate)
8. **Release-sandbox** → Sandbox release (uses iPhone Distribution certificate)
9. **Profile-sandbox** → Sandbox profiling (uses iPhone Distribution certificate)
10. **Debug-prod** → Production builds (uses iPhone Distribution certificate)
11. **Release-prod** → Production release (uses iPhone Distribution certificate)
12. **Profile-prod** → Production profiling (uses iPhone Distribution certificate)

## Required Steps

### Step 1: Generate or Download Provisioning Profiles

You need to create provisioning profiles in your Apple Developer account for each bundle identifier:

#### For Development (Debug-dev, Release-dev, Profile-dev)
- Type: **iOS App Development**
- Bundle ID: `com.example.app.dev`
- Certificate: **iOS Development certificate**
- Devices: Include all test devices

#### For Staging (Debug/Release/Profile-staging)
- Type: **Ad Hoc** or **App Store**
- Bundle ID: `com.example.app.staging`
- Certificate: **iOS Distribution certificate**
- Devices: Include devices if Ad Hoc

#### For Sandbox (Debug/Release/Profile-sandbox)
- Type: **Ad Hoc** or **App Store**
- Bundle ID: `com.example.app.sandbox`
- Certificate: **iOS Distribution certificate**
- Devices: Include devices if Ad Hoc

#### For Production (Debug/Release/Profile-prod)
- Type: **App Store**
- Bundle ID: `com.example.app`
- Certificate: **iOS Distribution certificate**

### Step 2: Install Provisioning Profiles

Download the `.mobileprovision` files from Apple Developer portal and double-click them to install, or use:

```bash
# Install provisioning profile
cp path/to/profile.mobileprovision ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/
```

### Step 3: Get Provisioning Profile Names

To find the exact name of your installed provisioning profiles:

```bash
# List all installed profiles with their names
security find-identity -v -p codesigning
```

Or check in Xcode:
1. Open Xcode → Preferences → Accounts
2. Select your team
3. Click "Manage Certificates"
4. View "Download Manual Profiles"

### Step 4: Configure Provisioning Profile Names

⚠️ **CRITICAL**: You MUST use the exact provisioning profile NAME, not the bundle ID!

You need to add the provisioning profile specifier to the appropriate xcconfig files:

#### Option A: Add to AppSpecific.xcconfig (Recommended)

Edit `/apps/main/ios/Flutter/AppSpecific.xcconfig` and **REPLACE** the bundle IDs with actual profile names:

```xcconfig
// Provisioning Profile Specifiers
// For Development builds
DEV_PROVISIONING_PROFILE_SPECIFIER=Your Dev Profile Name Here

// For Staging builds
STAGING_PROVISIONING_PROFILE_SPECIFIER=Your Staging Profile Name Here

// For Sandbox builds
SANDBOX_PROVISIONING_PROFILE_SPECIFIER=Your Sandbox Profile Name Here

// For Production builds
PROD_PROVISIONING_PROFILE_SPECIFIER=Your Prod Profile Name Here
```

Then update each environment config file to reference the variable:

**Default-dev.xcconfig:**
```xcconfig
APP_DISPLAY_NAME=$(DEV_APP_DISPLAY_NAME)
PRODUCT_BUNDLE_IDENTIFIER=$(DEV_PRODUCT_BUNDLE_IDENTIFIER)
PROVISIONING_PROFILE_SPECIFIER=$(DEV_PROVISIONING_PROFILE_SPECIFIER)
```

**Default-stag.xcconfig:**
```xcconfig
APP_DISPLAY_NAME=$(STAGING_APP_DISPLAY_NAME)
PRODUCT_BUNDLE_IDENTIFIER=$(STAGING_PRODUCT_BUNDLE_IDENTIFIER)
PROVISIONING_PROFILE_SPECIFIER=$(STAGING_PROVISIONING_PROFILE_SPECIFIER)
```

**Default-sandbox.xcconfig:**
```xcconfig
APP_DISPLAY_NAME=$(SANDBOX_APP_DISPLAY_NAME)
PRODUCT_BUNDLE_IDENTIFIER=$(SANDBOX_PRODUCT_BUNDLE_IDENTIFIER)
PROVISIONING_PROFILE_SPECIFIER=$(SANDBOX_PROVISIONING_PROFILE_SPECIFIER)
```

**Default-prod.xcconfig:**
```xcconfig
APP_DISPLAY_NAME=$(PROD_APP_DISPLAY_NAME)
PRODUCT_BUNDLE_IDENTIFIER=$(PROD_PRODUCT_BUNDLE_IDENTIFIER)
PROVISIONING_PROFILE_SPECIFIER=$(PROD_PROVISIONING_PROFILE_SPECIFIER)
```

#### Option B: Add directly to each xcconfig file

Add this line to each Default-*.xcconfig file with the actual profile name:

```xcconfig
PROVISIONING_PROFILE_SPECIFIER=Your Profile Name Here
```

### Step 5: Verify Configuration

1. Open the project in Xcode:
   ```bash
   open apps/main/ios/Runner.xcworkspace
   ```

2. Select the Runner target
3. Go to "Signing & Capabilities"
4. Ensure "Automatically manage signing" is **unchecked**
5. For each build configuration, verify:
   - Team: **95UD7HJB4N**
   - Provisioning Profile: Should show your profile name
   - Signing Certificate: Should match the configuration

### Step 6: Build and Test

Test each configuration:

```bash
# For development
flutter build ios --flavor dev --debug

# For production release
flutter build ios --flavor prod --release
```

## Troubleshooting

### "No matching provisioning profile found"
- Ensure the provisioning profile is installed in `~/Library/Developer/Xcode/UserData/Provisioning Profiles/`
- Verify the bundle ID in the profile matches the one in your app
- Check that the profile hasn't expired

### "Code signing identity not found"
- Install the required certificate in Keychain Access
- For development: iOS Development certificate
- For distribution: iOS Distribution certificate

### Profile Name Doesn't Match
- Check the exact name using: `security cms -D -i ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/*.mobileprovision | grep -A1 "Name"`
- Use the exact name including spaces and special characters

### Xcode Shows Errors After Configuration
- Clean the project: `flutter clean`
- Remove DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData`
- Re-open Xcode workspace

## CI/CD Configuration

For automated builds, you'll need to:

1. Export certificates and provisioning profiles
2. Store them securely (encrypted in repository or CI secrets)
3. Install them during the build process
4. Use `--export-options-plist` when building

Example for Fastlane:
```ruby
match(
  type: "appstore",
  readonly: true,
  app_identifier: "com.example.app"
)
```

## Security Notes

- ⚠️ Never commit `.mobileprovision` files to git
- ⚠️ Never commit private keys or certificates to git
- ✅ Use environment variables or secure vaults for sensitive data
- ✅ Add `*.mobileprovision` to `.gitignore`

## Additional Resources

- [Apple Code Signing Guide](https://developer.apple.com/support/code-signing/)
- [Provisioning Profile Types](https://developer.apple.com/documentation/xcode/preparing-your-app-for-distribution)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)

## Support

If you encounter issues:
1. Check Xcode's "Report Navigator" for detailed errors
2. Verify all certificates are valid in Apple Developer portal
3. Ensure provisioning profiles include the correct devices and capabilities
