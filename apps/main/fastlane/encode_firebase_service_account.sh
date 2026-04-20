#!/bin/bash

# Script to encode Firebase Service Account JSON for CI/CD
# Usage: sh encode_firebase_service_account.sh <path-to-service-account.json>

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 Firebase Service Account Encoder for CI/CD"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if file path is provided
if [ -z "$1" ]; then
  echo "❌ Error: Please provide the path to your Firebase service account JSON file"
  echo ""
  echo "Usage: sh encode_firebase_service_account.sh <path-to-service-account.json>"
  echo ""
  echo "How to get the service account JSON:"
  echo "  1. Go to Firebase Console: https://console.firebase.google.com/"
  echo "  2. Select your project"
  echo "  3. Click Settings (⚙️) → Project Settings"
  echo "  4. Go to 'Service accounts' tab"
  echo "  5. Click 'Generate new private key'"
  echo "  6. Save the JSON file securely"
  echo ""
  exit 1
fi

SERVICE_ACCOUNT_FILE="$1"

# Check if file exists
if [ ! -f "$SERVICE_ACCOUNT_FILE" ]; then
  echo "❌ Error: File not found: $SERVICE_ACCOUNT_FILE"
  exit 1
fi

# Validate JSON format
if ! python3 -m json.tool "$SERVICE_ACCOUNT_FILE" > /dev/null 2>&1; then
  echo "❌ Error: Invalid JSON file"
  exit 1
fi

# Extract project ID from JSON
PROJECT_ID=$(python3 -c "import json; print(json.load(open('$SERVICE_ACCOUNT_FILE'))['project_id'])" 2>/dev/null || echo "unknown")

echo "📄 Service Account File: $SERVICE_ACCOUNT_FILE"
echo "🏷️  Project ID: $PROJECT_ID"
echo ""

# Encode to base64
ENCODED=$(cat "$SERVICE_ACCOUNT_FILE" | base64)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Encoded Successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Add this to your .env file:"
echo ""
echo "FIREBASE_SERVICE_ACCOUNT_JSON=$ENCODED"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔒 For CI/CD (GitHub Secrets):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Add to fastlane/.env file (for FASTLANE_ENV_FILE secret):"
echo "   FIREBASE_SERVICE_ACCOUNT_JSON=$ENCODED"
echo ""
echo "2. Then re-encode the entire .env file:"
echo "   cat fastlane/.env | base64"
echo ""
echo "3. Update GitHub Secret: FASTLANE_ENV_FILE"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  Security Notes:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  • Never commit the service account JSON file to Git"
echo "  • Keep the encoded string secure"
echo "  • Service accounts have full project access"
echo "  • Rotate service accounts periodically"
echo "  • Use different service accounts for different environments if needed"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
