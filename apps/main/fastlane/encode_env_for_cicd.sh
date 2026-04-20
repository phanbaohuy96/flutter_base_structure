#!/bin/bash

# Script to encode .env file for CI/CD secrets
# Usage: sh encode_env_for_cicd.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

echo "======================================"
echo "Encode .env for CI/CD"
echo "======================================"
echo ""

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: .env file not found at $ENV_FILE"
    echo ""
    echo "Please create .env file first:"
    echo "  cd $SCRIPT_DIR"
    echo "  cp .env.example .env"
    echo "  # Edit .env with your actual values"
    exit 1
fi

# Encode .env file to base64
echo "📦 Encoding .env file..."
ENCODED_ENV=$(cat "$ENV_FILE" | base64)

echo ""
echo "✅ Successfully encoded .env file!"
echo ""
echo "======================================"
echo "Add this secret to your CI/CD:"
echo "======================================"
echo ""
echo "Secret Name: FASTLANE_ENV_FILE"
echo ""
echo "Secret Value (copy the entire output below):"
echo "--------------------------------------"
echo "$ENCODED_ENV"
echo "--------------------------------------"
echo ""
echo "======================================"
echo "GitHub Actions Usage:"
echo "======================================"
echo ""
echo "Add this step to your workflow before running Fastlane:"
echo ""
cat << 'EOF'
      - name: Setup Fastlane .env file
        working-directory: apps/main/fastlane
        run: |
          echo "${{ secrets.FASTLANE_ENV_FILE }}" | base64 -d > .env
EOF
echo ""
echo "======================================"
echo "GitLab CI Usage:"
echo "======================================"
echo ""
echo "Add this to your .gitlab-ci.yml before_script:"
echo ""
cat << 'EOF'
  before_script:
    - cd apps/main/fastlane
    - echo "$FASTLANE_ENV_FILE" | base64 -d > .env
EOF
echo ""
