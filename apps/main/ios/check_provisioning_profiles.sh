#!/bin/bash

# iOS Provisioning Profile Helper Script
# This script helps you find and verify provisioning profiles for manual signing

echo "=================================================="
echo "iOS Provisioning Profile Configuration Helper"
echo "=================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Path to provisioning profiles
PROFILES_DIR="$HOME/Library/Developer/Xcode/UserData/Provisioning Profiles/"

echo -e "${BLUE}Step 1: Checking installed provisioning profiles...${NC}"
echo ""

if [ ! -d "$PROFILES_DIR" ]; then
    echo -e "${RED}❌ Provisioning profiles directory not found!${NC}"
    echo "Directory: $PROFILES_DIR"
    echo "Please install at least one provisioning profile."
    exit 1
fi

PROFILE_COUNT=$(ls -1 "$PROFILES_DIR"/*.mobileprovision 2>/dev/null | wc -l)

if [ "$PROFILE_COUNT" -eq 0 ]; then
    echo -e "${RED}❌ No provisioning profiles found!${NC}"
    echo "Please download and install provisioning profiles from Apple Developer Portal."
    echo "Double-click .mobileprovision files to install them."
    exit 1
fi

echo -e "${GREEN}✅ Found $PROFILE_COUNT provisioning profile(s)${NC}"
echo ""

echo "=================================================="
echo "Installed Provisioning Profiles:"
echo "=================================================="
echo ""

# Array to store profile information
declare -a dev_profiles
declare -a staging_profiles
declare -a sandbox_profiles
declare -a prod_profiles

# Bundle IDs we're looking for
DEV_BUNDLE="com.example.app.dev"
STAGING_BUNDLE="com.example.app.staging"
SANDBOX_BUNDLE="com.example.app.sandbox"
PROD_BUNDLE="com.example.app"

for profile in "$PROFILES_DIR"/*.mobileprovision; do
    if [ -f "$profile" ]; then
        # Extract profile information using plutil
        PROFILE_NAME=$(security cms -D -i "$profile" 2>/dev/null | plutil -extract Name raw - 2>/dev/null)
        BUNDLE_ID=$(security cms -D -i "$profile" 2>/dev/null | plutil -extract Entitlements.application-identifier raw - 2>/dev/null | cut -d. -f2-)
        TEAM_ID=$(security cms -D -i "$profile" 2>/dev/null | plutil -extract TeamIdentifier.0 raw - 2>/dev/null)
        EXPIRY=$(security cms -D -i "$profile" 2>/dev/null | plutil -extract ExpirationDate raw - 2>/dev/null)
        
        # Determine profile type
        GET_TASK_ALLOW=$(security cms -D -i "$profile" 2>/dev/null | plutil -extract Entitlements.get-task-allow raw - 2>/dev/null)
        HAS_DEVICES=$(security cms -D -i "$profile" 2>/dev/null | plutil -extract ProvisionedDevices raw - 2>/dev/null)
        
        if [[ "$GET_TASK_ALLOW" == "true" ]]; then
            PROFILE_TYPE="Development"
        elif [[ "$HAS_DEVICES" != "" ]] && [[ "$HAS_DEVICES" != *"does not exist"* ]]; then
            PROFILE_TYPE="Ad Hoc"
        else
            PROFILE_TYPE="App Store"
        fi
        
        echo -e "${YELLOW}Profile:${NC} $PROFILE_NAME"
        echo "  Bundle ID: $BUNDLE_ID"
        echo "  Team ID: $TEAM_ID"
        echo "  Type: $PROFILE_TYPE"
        echo "  Expires: $EXPIRY"
        
        # Categorize profiles by bundle ID
        if [[ "$BUNDLE_ID" == *"$DEV_BUNDLE"* ]]; then
            dev_profiles+=("$PROFILE_NAME")
            echo -e "  ${GREEN}✅ Matches DEV bundle ID${NC}"
        elif [[ "$BUNDLE_ID" == *"$STAGING_BUNDLE"* ]]; then
            staging_profiles+=("$PROFILE_NAME")
            echo -e "  ${GREEN}✅ Matches STAGING bundle ID${NC}"
        elif [[ "$BUNDLE_ID" == *"$SANDBOX_BUNDLE"* ]]; then
            sandbox_profiles+=("$PROFILE_NAME")
            echo -e "  ${GREEN}✅ Matches SANDBOX bundle ID${NC}"
        elif [[ "$BUNDLE_ID" == *"$PROD_BUNDLE"* ]]; then
            prod_profiles+=("$PROFILE_NAME")
            echo -e "  ${GREEN}✅ Matches PROD bundle ID${NC}"
        fi
        
        echo ""
    fi
done

echo "=================================================="
echo "Summary & Configuration Guide:"
echo "=================================================="
echo ""

echo "Edit this file:"
echo -e "${BLUE}apps/main/ios/Flutter/AppSpecific.xcconfig${NC}"
echo ""

echo "Recommended configuration:"
echo ""

if [ ${#dev_profiles[@]} -gt 0 ]; then
    echo -e "${GREEN}DEV Profile Found:${NC}"
    echo "DEV_PROVISIONING_PROFILE_SPECIFIER=${dev_profiles[0]}"
else
    echo -e "${RED}❌ No DEV profile found for: $DEV_BUNDLE${NC}"
    echo "DEV_PROVISIONING_PROFILE_SPECIFIER="
fi
echo ""

if [ ${#staging_profiles[@]} -gt 0 ]; then
    echo -e "${GREEN}STAGING Profile Found:${NC}"
    echo "STAGING_PROVISIONING_PROFILE_SPECIFIER=${staging_profiles[0]}"
else
    echo -e "${RED}❌ No STAGING profile found for: $STAGING_BUNDLE${NC}"
    echo "STAGING_PROVISIONING_PROFILE_SPECIFIER="
fi
echo ""

if [ ${#sandbox_profiles[@]} -gt 0 ]; then
    echo -e "${GREEN}SANDBOX Profile Found:${NC}"
    echo "SANDBOX_PROVISIONING_PROFILE_SPECIFIER=${sandbox_profiles[0]}"
else
    echo -e "${RED}❌ No SANDBOX profile found for: $SANDBOX_BUNDLE${NC}"
    echo "SANDBOX_PROVISIONING_PROFILE_SPECIFIER="
fi
echo ""

if [ ${#prod_profiles[@]} -gt 0 ]; then
    echo -e "${GREEN}PROD Profile Found:${NC}"
    echo "PROD_PROVISIONING_PROFILE_SPECIFIER=${prod_profiles[0]}"
else
    echo -e "${RED}❌ No PROD profile found for: $PROD_BUNDLE${NC}"
    echo "PROD_PROVISIONING_PROFILE_SPECIFIER="
fi
echo ""

echo "=================================================="
echo "Next Steps:"
echo "=================================================="
echo ""
echo "1. Copy the configuration lines above"
echo "2. Edit: apps/main/ios/Flutter/AppSpecific.xcconfig"
echo "3. Replace the empty PROVISIONING_PROFILE_SPECIFIER values"
echo "4. Open Xcode and verify in Signing & Capabilities"
echo "5. Build your app!"
echo ""

# Check if all profiles are present
MISSING=0
[ ${#dev_profiles[@]} -eq 0 ] && MISSING=$((MISSING + 1))
[ ${#staging_profiles[@]} -eq 0 ] && MISSING=$((MISSING + 1))
[ ${#sandbox_profiles[@]} -eq 0 ] && MISSING=$((MISSING + 1))
[ ${#prod_profiles[@]} -eq 0 ] && MISSING=$((MISSING + 1))

if [ $MISSING -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Warning: $MISSING profile(s) missing${NC}"
    echo "You need to create and install provisioning profiles for:"
    [ ${#dev_profiles[@]} -eq 0 ] && echo "  - Development: $DEV_BUNDLE"
    [ ${#staging_profiles[@]} -eq 0 ] && echo "  - Staging: $STAGING_BUNDLE"
    [ ${#sandbox_profiles[@]} -eq 0 ] && echo "  - Sandbox: $SANDBOX_BUNDLE"
    [ ${#prod_profiles[@]} -eq 0 ] && echo "  - Production: $PROD_BUNDLE"
    echo ""
    echo "Visit: https://developer.apple.com/account/resources/profiles/list"
else
    echo -e "${GREEN}✅ All required provisioning profiles found!${NC}"
fi

echo ""
