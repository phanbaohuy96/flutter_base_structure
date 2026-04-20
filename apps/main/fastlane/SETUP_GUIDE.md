# Fastlane CI/CD Setup Guide

## Overview
This Fastfile provides automated deployment lanes for both Android and iOS platforms across multiple environments (dev, staging, sandbox, production).

**Note:** Building is handled by `distribution.sh` script. Fastlane is used only for deployment to Firebase App Distribution, TestFlight, and App Store.

**📚 For complete CI/CD secrets setup guide, see:** [`../CICD_SECRETS_SETUP.md`](../CICD_SECRETS_SETUP.md)

## Prerequisites

### 1. Install Dependencies
```bash
# Install Fastlane
gem install fastlane

# Or using Bundler (recommended)
cd apps/main
bundle install

# Install Firebase CLI (for Firebase App Distribution)
npm install -g firebase-tools
# Or using Homebrew
brew install firebase-cli
```

### 2. Setup Environment Variables

Copy `.env.example` to `.env` and fill in your actual values:
```bash
cd apps/main/fastlane
cp .env.example .env
```

**Never commit the `.env` file to version control!**

### 3. Firebase Setup

#### Firebase Authentication (Choose ONE method)

**Method 1: Service Account (RECOMMENDED for CI/CD - Never Expires)**

Service accounts provide long-lived, secure authentication for CI/CD environments.

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click Settings (⚙️) → Project Settings
4. Go to "Service accounts" tab
5. Click "Generate new private key"
6. Save the JSON file securely (e.g., `firebase-service-account.json`)
7. Encode for `.env` file:
   ```bash
   cd fastlane
   sh encode_firebase_service_account.sh path/to/firebase-service-account.json
   ```
8. Copy the output and add to `.env` file as `FIREBASE_SERVICE_ACCOUNT_JSON`

**Method 2: CLI Token (Alternative - May Expire After 6 Months)**

**For local development:** Just run `firebase login` once, no token needed.

**For CI/CD environments:**
```bash
firebase login:ci
```
Copy the token and set it as `FIREBASE_TOKEN` in your CI/CD secrets or `.env` file.

> ⚠️ **Note:** CLI tokens may expire after ~6 months of inactivity or if you change your password. Service accounts are recommended for production CI/CD.

#### Get Firebase App IDs
1. Go to Firebase Console → Project Settings
2. Under "Your apps", find each app's App ID (format: `1:xxxxx:android:xxxxx` or `1:xxxxx:ios:xxxxx`)
3. Set them in `.env` file:
   - `FIREBASE_APP_ID_ANDROID_DEV`
   - `FIREBASE_APP_ID_ANDROID_STAGING`
   - `FIREBASE_APP_ID_ANDROID_SANDBOX`
   - `FIREBASE_APP_ID_ANDROID_PROD`
   - `FIREBASE_APP_ID_IOS_DEV`
   - `FIREBASE_APP_ID_IOS_STAGING`
   - `FIREBASE_APP_ID_IOS_SANDBOX`
   - `FIREBASE_APP_ID_IOS_PROD`

### 4. iOS Code Signing Setup

**Manual Signing (Current Setup)**
- Download provisioning profiles from Apple Developer Portal
- Install them by double-clicking `.mobileprovision` files
- Ensure profiles are named to match bundle IDs (as configured in `AppSpecific.xcconfig`)
- See `apps/main/ios/QUICK_START.md` for detailed iOS signing setup

### 5. App Store Connect API Key (Optional - for TestFlight/App Store)

Only needed if you plan to use `upload_testflight` or `deploy_app_store` lanes.

1. Go to [App Store Connect → Users and Access → Keys](https://appstoreconnect.apple.com/access/api)
2. Create a new API Key with "App Manager" role
3. Download the `.p8` file
4. Set environment variables in `.env`:
   ```bash
   APP_STORE_CONNECT_API_KEY_ID=ABC123XYZ
   APP_STORE_CONNECT_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   APP_STORE_CONNECT_API_KEY_CONTENT=$(cat AuthKey_ABC123XYZ.p8 | base64)
   ```

## Available Lanes

### Android Lanes

```bash
# Deploy to Firebase App Distribution
cd apps/main
bundle exec fastlane android upload_firebase_dev binary_path:build/app/outputs/flutter-apk/app-dev-release.apk
bundle exec fastlane android upload_firebase_staging binary_path:build/app/outputs/flutter-apk/app-staging-release.apk
bundle exec fastlane android upload_firebase_sandbox binary_path:build/app/outputs/flutter-apk/app-sandbox-release.apk
bundle exec fastlane android upload_firebase_prod binary_path:build/app/outputs/flutter-apk/app-prod-release.apk

# Deploy to Google Play Store (internal track)
bundle exec fastlane android deploy_play_store flavor:prod track:internal
```

### iOS Lanes

```bash
# Deploy to Firebase App Distribution
cd apps/main
bundle exec fastlane ios upload_firebase_dev binary_path:build/ios/ipa/Runner.ipa
bundle exec fastlane ios upload_firebase_staging binary_path:build/ios/ipa/Runner.ipa
bundle exec fastlane ios upload_firebase_sandbox binary_path:build/ios/ipa/Runner.ipa
bundle exec fastlane ios upload_firebase_prod binary_path:build/ios/ipa/Runner.ipa

# Upload to TestFlight
bundle exec fastlane ios upload_testflight binary_path:build/ios/ipa/Runner.ipa

# Deploy to App Store
bundle exec fastlane ios deploy_app_store binary_path:build/ios/ipa/Runner.ipa
```

## Typical Workflow

### Using distribution.sh Script (Recommended)

The `distribution.sh` script handles both building and deployment:

```bash
# Build and deploy to Firebase - Development
sh ./distribution.sh -a main -e dev -p ios

# Build and deploy to Firebase - Staging
sh ./distribution.sh -a main -e staging -p android

# Deploy to all platforms
sh ./distribution.sh -a main -e prod -p all
```

### Manual Build + Fastlane Deploy

If you want more control:

```bash
# 1. Build using Flutter
flutter build apk --flavor dev --release
# or
flutter build ipa --flavor dev --release

# 2. Deploy using Fastlane
cd apps/main
bundle exec fastlane android upload_firebase_dev binary_path:../../build/app/outputs/flutter-apk/app-dev-release.apk
# or
bundle exec fastlane ios upload_firebase_dev binary_path:../../build/ios/ipa/Runner.ipa
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy to Firebase

on:
  push:
    branches: [develop, main]

jobs:
  deploy-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
          working-directory: apps/main
      
      - name: Setup Fastlane .env file
        working-directory: apps/main/fastlane
        run: |
          echo "${{ secrets.FASTLANE_ENV_FILE }}" | base64 -d > .env
      
      - name: Setup Android signing
        working-directory: apps/main/android/keystores
        run: |
          # Keystores are committed to repo, only decode the properties file
          echo "${{ secrets.ANDROID_KEYSTORE_PROPERTIES }}" | base64 -d > keystore.properties
          
      - name: Build APK using distribution script
        run: sh ./distribution.sh -a main -e dev -p android
        
      - name: Deploy to Firebase (handled by distribution.sh)
        # Distribution script already deploys to Firebase
        run: echo "Deployed by distribution.sh"

  deploy-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
          working-directory: apps/main
      
      - name: Setup Fastlane .env file
        working-directory: apps/main/fastlane
        run: |
          echo "${{ secrets.FASTLANE_ENV_FILE }}" | base64 -d > .env
      
      - name: Setup iOS signing
        run: |
          # Install provisioning profiles from secrets
          echo "${{ secrets.IOS_DEV_PROFILE }}" | base64 -d > dev.mobileprovision
          echo "${{ secrets.IOS_STAGING_PROFILE }}" | base64 -d > staging.mobileprovision
          echo "${{ secrets.IOS_SANDBOX_PROFILE }}" | base64 -d > sandbox.mobileprovision
          echo "${{ secrets.IOS_PROD_PROFILE }}" | base64 -d > prod.mobileprovision
          
          # Install all profiles
          open dev.mobileprovision
          open staging.mobileprovision
          open sandbox.mobileprovision
          open prod.mobileprovision
          
      - name: Build and Deploy using distribution script
        run: sh ./distribution.sh -a main -e dev -p ios
```

### GitLab CI Example

```yaml
stages:
  - build_deploy

.android_template:
  image: mingc/android-build-box:latest
  before_script:
    - gem install bundler
    - cd apps/main && bundle install

deploy_android_dev:
  extends: .android_template
  stage: build_deploy
  before_script:
    - gem install bundler
    - cd apps/main && bundle install
    - cd fastlane && echo "$FASTLANE_ENV_FILE" | base64 -d > .env
    - cd ../android/keystores
    # Keystores are committed to repo, only decode the properties file
    - echo "$ANDROID_KEYSTORE_PROPERTIES" | base64 -d > keystore.properties
    - cd ../../..
  script:
    - sh ./distribution.sh -a main -e dev -p android
  only:
    - develop

.ios_template:
  tags:
    - macos
  before_script:
    - gem install bundler
    - cd apps/main && bundle install

deploy_ios_dev:
  extends: .ios_template
  stage: build_deploy
  before_script:
    - gem install bundler
    - cd apps/main && bundle install
    - cd fastlane && echo "$FASTLANE_ENV_FILE" | base64 -d > .env
    - cd ..
    - echo "$IOS_DEV_PROFILE" | base64 -d > dev.mobileprovision
    - echo "$IOS_STAGING_PROFILE" | base64 -d > staging.mobileprovision
    - echo "$IOS_SANDBOX_PROFILE" | base64 -d > sandbox.mobileprovision
    - echo "$IOS_PROD_PROFILE" | base64 -d > prod.mobileprovision
    - open dev.mobileprovision
    - open staging.mobileprovision
    - open sandbox.mobileprovision
    - open prod.mobileprovision
    - cd ..
  script:
    - sh ./distribution.sh -a main -e dev -p ios
  only:
    - develop
```

### Required CI/CD Secrets

**Total: 6 Secrets**

For GitHub Actions/GitLab CI, set these secrets:

**Fastlane (1 secret):**
- `FASTLANE_ENV_FILE` - Base64 encoded `.env` file (see [Encoding .env for CI/CD](#encoding-env-for-cicd))

**iOS Provisioning (4 secrets - Base64 encoded):**
- `IOS_DEV_PROFILE`
- `IOS_STAGING_PROFILE`
- `IOS_SANDBOX_PROFILE`
- `IOS_PROD_PROFILE`

**Android Signing (1 secret - Base64 encoded):**
- `ANDROID_KEYSTORE_PROPERTIES` - Contains passwords for committed keystores

**Note:** Android `.jks` keystores are committed to the repository at `apps/main/android/keystores/*.jks`. Only the `keystore.properties` file (containing passwords) is kept as a secret.

**📚 For complete setup instructions with all secrets (Fastlane + iOS + Android), see:** [`../CICD_SECRETS_SETUP.md`](../CICD_SECRETS_SETUP.md)

### Encoding .env for CI/CD

Instead of setting each environment variable individually as secrets, encode your entire `.env` file:

```bash
# 1. Create and fill your .env file
cd apps/main/fastlane
cp .env.example .env
# Edit .env with your actual values

# 2. Run the encoding script
sh encode_env_for_cicd.sh
```

The script will output a base64-encoded string. Copy this and add it as a secret named `FASTLANE_ENV_FILE` in your CI/CD platform.

**GitHub Actions:** Settings → Secrets and variables → Actions → New repository secret

**GitLab CI:** Settings → CI/CD → Variables → Add variable

## Best Practices

### 1. Use Environment-Specific Configuration
- Keep separate Firebase projects for dev/staging/prod
- Use different bundle IDs for each environment (already configured)
- Maintain separate signing keys/certificates

### 2. Secure Secrets Management
- Use CI/CD platform's secret management
- Never commit `.env` or credentials to repository
- Add `.env` to `.gitignore`
- Rotate API keys regularly

### 3. Version Control
- Tag releases: `git tag -a v1.0.0+100 -m "Release 1.0.0"`
- Keep release notes updated in `release_notes_*.txt` files
- Use semantic versioning

### 4. Code Signing
- Keep provisioning profiles updated
- Store `.mobileprovision` files securely (not in git)
- Document certificate renewal process
- Backup certificates and private keys

### 5. Testing
- Test locally before pushing to CI/CD
- Use internal testing groups first
- Gradual rollout for production releases

## Troubleshooting

### Firebase CLI Not Found
```bash
# Install Firebase CLI
npm install -g firebase-tools
# Or
brew install firebase-cli

# Verify installation
firebase --version
```

### Firebase Authentication Issues

**Error: "could not generate credentials from the refresh token"**

This happens when the Firebase CLI token expires or becomes invalid.

**Solution 1: Switch to Service Account (RECOMMENDED)**
```bash
# 1. Generate service account (see Firebase Setup section above)
# 2. Encode it
cd fastlane
sh encode_firebase_service_account.sh path/to/firebase-service-account.json

# 3. Update .env file with FIREBASE_SERVICE_ACCOUNT_JSON
# 4. Re-encode .env for CI/CD
cat .env | base64

# 5. Update GitHub Secret: FASTLANE_ENV_FILE
```

**Solution 2: Regenerate CLI Token**
```bash
# Local: Just re-login
firebase login

# CI/CD: Generate new token
firebase login:ci
# Update FIREBASE_TOKEN in .env
# Re-encode .env and update FASTLANE_ENV_FILE secret
```

> 💡 **Tip:** Service accounts never expire and are more suitable for CI/CD than CLI tokens.

### iOS Signing Issues
```bash
# Verify certificates are installed
security find-identity -v -p codesigning

# Check provisioning profiles
ls -la ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/

# Re-download and install profiles from Apple Developer Portal
```

### Android Build Failures
```bash
# Clean build
flutter clean
cd android && ./gradlew clean

# Rebuild
flutter build apk --flavor dev --release
```

### Distribution Script Issues
```bash
# Check if all dependencies are installed
flutter doctor

# Verify Firebase login
firebase login

# Check Fastlane installation
bundle exec fastlane --version

# Run with verbose output
sh -x ./distribution.sh -a main -e dev -p ios
```

## Support

For more information:
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
- [Flutter Deployment](https://docs.flutter.dev/deployment)
