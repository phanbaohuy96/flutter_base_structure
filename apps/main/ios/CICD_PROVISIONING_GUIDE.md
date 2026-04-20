# CI/CD Setup for iOS Provisioning Profiles

## Overview

Yes, manual signing with provisioning profiles **works with CI/CD**! Here are the best practices for storing and managing provisioning profiles in automated build environments.

**📚 For complete CI/CD secrets setup guide (Fastlane + iOS + Android), see:** [`../CICD_SECRETS_SETUP.md`](../CICD_SECRETS_SETUP.md)

This document focuses specifically on iOS provisioning profile management strategies.

## 🔐 Storage Options for Provisioning Profiles

### Option 1: GitHub Secrets (Recommended for GitHub Actions) ✅

Store base64-encoded provisioning profiles and certificates as GitHub repository secrets.

**Advantages:**
- ✅ Secure and encrypted
- ✅ Easy to update without code changes
- ✅ Built-in access control
- ✅ No additional services required

**Setup Steps:**

1. **Export and encode your provisioning profiles:**

```bash
# Navigate to provisioning profiles directory
cd ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/

# Find your profile UUID
ls -la

# Base64 encode the profile
base64 -i YOUR_PROFILE_UUID.mobileprovision | pbcopy
```

2. **Export and encode your certificates:**

```bash
# Export certificate from Keychain Access as .p12
# Then encode it
base64 -i certificate.p12 | pbcopy
```

3. **Add to GitHub Secrets:**

Go to: `Repository Settings → Secrets and variables → Actions → New repository secret`

Add these secrets:
- `IOS_DEV_PROVISIONING_PROFILE` - Base64 encoded dev profile
- `IOS_STAGING_PROVISIONING_PROFILE` - Base64 encoded staging profile
- `IOS_SANDBOX_PROVISIONING_PROFILE` - Base64 encoded sandbox profile
- `IOS_PROD_PROVISIONING_PROFILE` - Base64 encoded prod profile
- `IOS_DISTRIBUTION_CERTIFICATE` - Base64 encoded .p12 certificate
- `IOS_CERTIFICATE_PASSWORD` - Password for the .p12 file
- `APP_STORE_CONNECT_KEY_ID` - For App Store Connect API
- `APP_STORE_CONNECT_ISSUER_ID` - For App Store Connect API
- `APP_STORE_CONNECT_KEY_CONTENT` - Base64 encoded API key

4. **Profile Names (as secrets or in config):**
- `IOS_DEV_PROFILE_NAME` - Name of dev provisioning profile
- `IOS_STAGING_PROFILE_NAME` - Name of staging provisioning profile
- `IOS_SANDBOX_PROFILE_NAME` - Name of sandbox provisioning profile
- `IOS_PROD_PROFILE_NAME` - Name of prod provisioning profile

---

### Option 2: Fastlane Match (Apple's Recommended) ⭐

Fastlane Match stores certificates and profiles in a private Git repository (or S3, Google Cloud).

**Advantages:**
- ✅ Team-wide certificate and profile management
- ✅ Automatic certificate rotation
- ✅ Prevents certificate conflicts
- ✅ Works across teams and CI/CD platforms

**Setup Steps:**

1. **Initialize Fastlane Match:**

```bash
cd apps/main
fastlane match init
```

Choose storage option (git is most common).

2. **Create a private repository for certificates:**

```bash
# Create private repo on GitHub/GitLab
# Example: your-org/ios-certificates-private
```

3. **Generate and store profiles:**

```bash
# For development
fastlane match development --app_identifier "com.example.app.dev"

# For distribution (staging/sandbox/prod)
fastlane match appstore --app_identifier "com.example.app.staging"
fastlane match appstore --app_identifier "com.example.app.sandbox"
fastlane match appstore --app_identifier "com.example.app"
```

4. **Update Fastfile** (see example below)

---

### Option 3: Encrypted Files in Repository

Store encrypted provisioning profiles in the repository and decrypt during CI.

**Advantages:**
- ✅ Version controlled
- ✅ No external dependencies
- ✅ Works with any CI/CD platform

**Setup Steps:**

1. **Create certificates directory:**

```bash
mkdir -p apps/main/ios/certificates
```

2. **Encrypt profiles:**

```bash
# Using GPG
gpg --symmetric --cipher-algo AES256 profile.mobileprovision

# Or using OpenSSL
openssl enc -aes-256-cbc -salt -in profile.mobileprovision -out profile.mobileprovision.enc
```

3. **Add to repository:**

```bash
git add apps/main/ios/certificates/*.enc
```

4. **Store decryption key as secret:**
- `CERTIFICATE_ENCRYPTION_KEY`

---

### Option 4: CI/CD Platform Secure Files

Most CI platforms have secure file storage:

- **GitHub Actions**: Use secrets (as in Option 1)
- **GitLab CI**: Use CI/CD Variables with File type
- **Azure DevOps**: Use Secure Files library
- **Bitrise**: Use Code Signing tab
- **Codemagic**: Use Code Signing identities

---

## 📝 Example: GitHub Actions Workflow

Create `.github/workflows/ios_build.yaml`:

```yaml
name: iOS Build and Deploy

on:
  push:
    branches: [main, develop]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to build'
        required: true
        type: choice
        options:
          - dev
          - staging
          - sandbox
          - prod

jobs:
  build-ios:
    runs-on: macos-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      
      - name: Setup Ruby and Bundler
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.0'
          bundler-cache: true
          working-directory: apps/main
      
      - name: Setup iOS provisioning profiles
        run: |
          # Decode and install all 4 provisioning profiles
          echo "${{ secrets.IOS_DEV_PROFILE }}" | base64 --decode > dev.mobileprovision
          echo "${{ secrets.IOS_STAGING_PROFILE }}" | base64 --decode > staging.mobileprovision
          echo "${{ secrets.IOS_SANDBOX_PROFILE }}" | base64 --decode > sandbox.mobileprovision
          echo "${{ secrets.IOS_PROD_PROFILE }}" | base64 --decode > prod.mobileprovision
          
          # Install profiles (opening .mobileprovision files installs them)
          open dev.mobileprovision
          open staging.mobileprovision
          open sandbox.mobileprovision
          open prod.mobileprovision
          
          # Wait for profiles to be installed
          sleep 2
      
      - name: Build and Deploy using distribution.sh
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
          FIREBASE_APP_ID_IOS_DEV: ${{ secrets.FIREBASE_APP_ID_IOS_DEV }}
          FIREBASE_APP_ID_IOS_STAGING: ${{ secrets.FIREBASE_APP_ID_IOS_STAGING }}
          FIREBASE_APP_ID_IOS_SANDBOX: ${{ secrets.FIREBASE_APP_ID_IOS_SANDBOX }}
          FIREBASE_APP_ID_IOS_PROD: ${{ secrets.FIREBASE_APP_ID_IOS_PROD }}
        run: |
          ENVIRONMENT="${{ github.event.inputs.environment || 'dev' }}"
          sh ./distribution.sh -a main -e $ENVIRONMENT -p ios
      
      - name: Clean up provisioning profile files
        if: always()
        run: |
          rm -f *.mobileprovision
      
      - name: Upload IPA artifact
        uses: actions/upload-artifact@v3
        with:
          name: ios-ipa-${{ github.event.inputs.environment || 'dev' }}
          path: apps/main/build/ios/ipa/*.ipa
          retention-days: 7
```

---

## 📝 Example: Fastlane Match Integration

**Note:** The current project uses manual signing with `distribution.sh` script for builds. Fastlane Match is optional for team-based certificate management.

If you want to use Fastlane Match for certificate management, update `apps/main/fastlane/Fastfile`:

```ruby
default_platform(:ios)

platform :ios do
  
  desc "Setup code signing with Match"
  lane :setup_signing do |options|
    environment = options[:environment] || "dev"
    
    # Match configuration
    case environment
    when "dev"
      match_type = "development"
      app_id = "com.example.app.dev"
    when "staging"
      match_type = "appstore"
      app_id = "com.example.app.staging"
    when "sandbox"
      match_type = "appstore"
      app_id = "com.example.app.sandbox"
    when "prod"
      match_type = "appstore"
      app_id = "com.example.app"
    end
    
    match(
      type: match_type,
      app_identifier: app_id,
      readonly: true, # Don't create new certificates/profiles in CI
      git_url: "git@github.com:your-org/ios-certificates.git",
      git_basic_authorization: ENV["MATCH_GIT_BASIC_AUTHORIZATION"]
    )
  end
  
  # Deployment lanes (already exist in your Fastfile)
  desc "Upload to Firebase"
  lane :upload_firebase_dev do |options|
    ipa_path = options[:binary_path]
    groups = options.fetch(:group, "ios-internal")
    testers = options.fetch(:testers, "")

    firebase_options = {
      app: ENV["FIREBASE_APP_ID_IOS_DEV"] || "",
      groups: groups,
      testers: testers,
      release_notes_file: "release_notes_dev.txt",
      ipa_path: ipa_path
    }
    
    firebase_options[:firebase_cli_token] = ENV["FIREBASE_TOKEN"] if ENV["FIREBASE_TOKEN"]
    
    firebase_app_distribution(firebase_options)
  end
  
  # ... other upload lanes for staging, sandbox, prod
end
```

Create `apps/main/fastlane/Matchfile`:

```ruby
git_url("git@github.com:your-org/ios-certificates.git")
storage_mode("git")

type("appstore") # or "development", "adhoc"

app_identifier([
  "com.example.app.dev",
  "com.example.app.staging",
  "com.example.app.sandbox",
  "com.example.app"
])

username("your-apple-id@example.com")
team_id("95UD7HJB4N")
```

---

## 🔄 Updating Provisioning Profiles in CI/CD

### When profiles need updating:

1. **Generate new profiles** (Apple Developer Portal or Fastlane Match)
2. **Encode and update secrets** (if using GitHub Secrets)
3. **Run match sync** (if using Fastlane Match)
4. **Update profile names** in `app_identifier.yaml` if names changed

### Automatic profile name injection:

Instead of hardcoding names, inject them at build time:

```bash
# In CI/CD script
export PROFILE_NAME="${{ secrets.IOS_PROD_PROFILE_NAME }}"

# Update app_identifier.yaml
yq eval ".ios.prod.provisioning_profile_specifier = \"$PROFILE_NAME\"" -i apps/main/app_identifier.yaml

# Regenerate config
cd apps/main
dart run module_generator:generate_app_identifier
```

---

## 📋 Required CI/CD Environment Variables/Secrets

### Minimum required secrets:

```bash
# Certificates
## 📋 Required CI/CD Environment Variables/Secrets

### iOS-Specific Secrets (4 Total)

**For complete list including Fastlane and Android secrets, see:** [`../CICD_SECRETS_SETUP.md`](../CICD_SECRETS_SETUP.md)

```bash
# iOS Provisioning Profiles (Base64 encoded .mobileprovision files)
IOS_DEV_PROFILE                    # Development profile
IOS_STAGING_PROFILE                # Staging profile
IOS_SANDBOX_PROFILE                # Sandbox profile
IOS_PROD_PROFILE                   # Production profile
```

**Note:** Certificates are embedded in provisioning profiles, so no separate certificate secrets are needed for CI/CD.

### How to generate iOS secrets:

**Use the provided script:**
```bash
cd apps/main/ios
sh encode_for_cicd.sh
```

The script will automatically encode all 4 provisioning profiles and output ready-to-use secrets.

**Manual encoding (if needed):**
```bash
# Navigate to provisioning profiles directory
cd ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/

# Encode a specific profile
base64 -i YOUR_PROFILE.mobileprovision | pbcopy

# View profile details
security cms -D -i YOUR_PROFILE.mobileprovision | plutil -p -
```**Never commit plaintext certificates or profiles**
   - Add to `.gitignore`:
     ```
     *.mobileprovision
     *.p12
     *.cer
     *.certSigningRequest
     ios/certificates/*
     !ios/certificates/*.enc
     ```

2. **Use separate profiles for each environment**
   - Dev uses development profile
   - Staging/Sandbox/Prod use distribution profiles

3. **Rotate certificates before expiration**
## 🎯 Recommended Approach for Your Project

Based on your current setup with GitHub Actions, Fastlane, and the `distribution.sh` script:

**Best Option: GitHub Secrets + Manual Signing (Current Setup)**

Your project is already configured for manual signing with the `distribution.sh` script. For CI/CD:

1. **Store provisioning profiles in GitHub Secrets** (Base64 encoded)
2. **Store profile names in GitHub Secrets**
3. **Use `distribution.sh` script** for building and deployment
4. **Fastlane handles only Firebase deployment** (not building)

This gives you:
- ✅ Secure storage
- ✅ Works with existing distribution script
- ✅ Simple CI/CD setup
- ✅ No changes to local development workflow
- ✅ Fastlane only for deployment (not building)

**Optional Enhancement: Add Fastlane Match** (for team collaboration)

If you want better team certificate management:
- Use Match for certificate sync across team
- Keep `distribution.sh` for building
- Fastlane for deployment only

---

## 🚀 Quick Start Implementation

### For your current manual signing setup:

1. **Encode iOS provisioning profiles:**

   ```bash
   # Use the provided script to encode all profiles
   cd apps/main/ios
   sh encode_for_cicd.sh
   ```

2. **Add to GitHub Secrets:**
   - `IOS_DEV_PROFILE` (Base64 encoded .mobileprovision)
   - `IOS_STAGING_PROFILE` (Base64 encoded .mobileprovision)
   - `IOS_SANDBOX_PROFILE` (Base64 encoded .mobileprovision)
   - `IOS_PROD_PROFILE` (Base64 encoded .mobileprovision)
   - See [`../CICD_SECRETS_SETUP.md`](../CICD_SECRETS_SETUP.md) for Fastlane and Android secrets

3. **Update `.gitignore`:**
   ```
   *.mobileprovision
   *.p12
   *.cer
   .env
   ```

4. **Create workflow file** (use example above)

5. **Test locally first:**
   ```bash
   # Test distribution script
   sh ./distribution.sh -a main -e dev -p ios
   ```

6. **Push to CI/CD**

### If using Fastlane Match:

1. **Initialize Match:**
   ```bash
   cd apps/main
   fastlane match init
   ```

2. **Create private certificates repo**

3. **Generate profiles:**
   ```bash
   fastlane match development --app_identifier "com.example.app.dev"
   fastlane match appstore --app_identifier "com.example.app.staging"
   ```

4. **Add Match secrets to GitHub:**
   - `MATCH_PASSWORD`
   - `MATCH_GIT_BASIC_AUTHORIZATION`

5. **Update workflow to use Match**
- ✅ Secure storage
- ✅ Easy team onboarding
- ✅ Automatic updates
- ✅ Works with existing Fastlane setup

---

## 🚀 Quick Start Implementation

1. **Add secrets to GitHub** (as shown above)

2. **Update `.gitignore`** (ensure profiles are ignored)

3. **Create Matchfile** (if using Fastlane Match)

4. **Update workflow file** (use example above)

5. **Test locally first:**
   ```bash
   # Encode your current profile
   base64 -i ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles//YOUR_PROFILE.mobileprovision
   
   # Test decode
   echo "BASE64_STRING" | base64 --decode > test.mobileprovision
   ```

6. **Run CI/CD pipeline**

---

## 📞 Need Help?

- Check Fastlane docs: https://docs.fastlane.tools/actions/match/
- GitHub Actions secrets: https://docs.github.com/en/actions/security-guides/encrypted-secrets
- Apple code signing: https://developer.apple.com/support/code-signing/

