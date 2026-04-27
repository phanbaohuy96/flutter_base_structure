# Quick Start - iOS Provisioning Profile Setup

## ✅ What's Already Configured

1. ✅ Xcode project configured for **manual signing**
2. ✅ All build configurations updated (Debug, Release, Profile for dev/staging/sandbox/prod)
3. ✅ ExportOptions.plist files set to manual signing
4. ✅ Configuration files ready to accept provisioning profile names

## 🎯 What You Need To Do

### Step 1: Create/Download Provisioning Profiles

Go to [Apple Developer Portal](https://developer.apple.com/account/resources/profiles/list) and create provisioning profiles:

#### Development Profile
- **Bundle ID**: `com.pbh.myflutterbase.dev`
- **Type**: iOS App Development
- **Certificate**: iOS Development

#### Staging Profile  
- **Bundle ID**: `com.pbh.myflutterbase.staging`
- **Type**: Ad Hoc or App Store
- **Certificate**: iOS Distribution

#### Sandbox Profile
- **Bundle ID**: `com.pbh.myflutterbase.sandbox`
- **Type**: Ad Hoc or App Store
- **Certificate**: iOS Distribution

#### Production Profile
- **Bundle ID**: `com.pbh.myflutterbase`
- **Type**: App Store
- **Certificate**: iOS Distribution

### Step 2: Install Provisioning Profiles

Double-click each `.mobileprovision` file to install it to:
```
~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/
```

### Step 3: Find Your Profile Names

Run this command to see all installed provisioning profiles:

```bash
cd ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/
for file in *.mobileprovision; do
    echo "File: $file"
    security cms -D -i "$file" | grep -A2 "Name"
    echo "---"
done
```

### Step 4: Update AppSpecific.xcconfig

**Option A: Edit the generated file directly (Quick but temporary)**

Edit this file:
```
apps/main/ios/Flutter/AppSpecific.xcconfig
```

**Option B: Edit the source configuration (Recommended - persists through regeneration)**

Edit this file:
```
apps/main/app_identifier.yaml
```

Update the iOS section with your provisioning profile names:

```yaml
ios:
  dev:
    package: com.pbh.myflutterbase.dev
    name: YourApp DEV
    provisioning_profile_specifier: "YOUR_DEV_PROFILE_NAME_HERE"
  staging:
    package: com.pbh.myflutterbase.staging
    name: YourApp Staging
    provisioning_profile_specifier: "YOUR_STAGING_PROFILE_NAME_HERE"
  sandbox:
    package: com.pbh.myflutterbase.sandbox
    name: YourApp Sandbox
    provisioning_profile_specifier: "YOUR_SANDBOX_PROFILE_NAME_HERE"
  prod:
    package: com.pbh.myflutterbase
    name: YourApp
    provisioning_profile_specifier: "YOUR_PROD_PROFILE_NAME_HERE"
```

Then regenerate the configuration:
```bash
cd apps/main
dart run module_generator:generate_app_identifier
```

Or directly edit `AppSpecific.xcconfig`:

```xcconfig
// dev
DEV_APP_DISPLAY_NAME=YourApp DEV
DEV_PRODUCT_BUNDLE_IDENTIFIER=com.pbh.myflutterbase.dev
DEV_PROVISIONING_PROFILE_SPECIFIER=YOUR_DEV_PROFILE_NAME_HERE

// staging
STAGING_APP_DISPLAY_NAME=YourApp Staging
STAGING_PRODUCT_BUNDLE_IDENTIFIER=com.pbh.myflutterbase.staging
STAGING_PROVISIONING_PROFILE_SPECIFIER=YOUR_STAGING_PROFILE_NAME_HERE

// sandbox
SANDBOX_APP_DISPLAY_NAME=YourApp Sandbox
SANDBOX_PRODUCT_BUNDLE_IDENTIFIER=com.pbh.myflutterbase.sandbox
SANDBOX_PROVISIONING_PROFILE_SPECIFIER=YOUR_SANDBOX_PROFILE_NAME_HERE

// prod
PROD_APP_DISPLAY_NAME=YourApp
PROD_PRODUCT_BUNDLE_IDENTIFIER=com.pbh.myflutterbase
PROD_PROVISIONING_PROFILE_SPECIFIER=YOUR_PROD_PROFILE_NAME_HERE
```

**Example with actual names:**
```xcconfig
DEV_PROVISIONING_PROFILE_SPECIFIER=YourApp Dev Profile 2024
STAGING_PROVISIONING_PROFILE_SPECIFIER=YourApp Staging AdHoc
SANDBOX_PROVISIONING_PROFILE_SPECIFIER=YourApp Sandbox AdHoc
PROD_PROVISIONING_PROFILE_SPECIFIER=YourApp AppStore Profile
```

### Step 5: Verify in Xcode

1. Open the project:
   ```bash
   open apps/main/ios/Runner.xcworkspace
   ```

2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Verify for each configuration:
   - ❌ "Automatically manage signing" should be **unchecked**
   - ✅ Team shows: **95UD7HJB4N**
   - ✅ Provisioning Profile shows your profile name
   - ✅ No errors displayed

### Step 6: Build and Test

```bash
# Test development build
flutter build ios --flavor dev --debug

# Test production build
flutter build ios --flavor prod --release
```

## 🚨 Common Issues

### Issue: "No provisioning profile found"
**Solution**: Make sure you've installed the `.mobileprovision` files and the profile names in `AppSpecific.xcconfig` match exactly.

### Issue: "Code signing identity not found"
**Solution**: Install the required certificates in Keychain Access (iOS Development or iOS Distribution).

### Issue: Profile expired
**Solution**: Create new provisioning profiles in Apple Developer portal and update the names in `AppSpecific.xcconfig`.

## 📚 More Details

For comprehensive documentation, see:
```
apps/main/ios/PROVISIONING_PROFILE_SETUP.md
```

## 💡 Tips

1. Profile names are **case-sensitive** - copy them exactly
2. Include spaces if they're in the profile name
3. Don't commit `.mobileprovision` files to git
4. Keep certificates backed up securely
5. For CI/CD, use Fastlane Match or similar tools
