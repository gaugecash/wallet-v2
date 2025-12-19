#!/bin/bash

# Helper script to add iOS deployment secrets to GitHub
# Run this from the wallet-v2 directory

set -e

echo "╔══════════════════════════════════════════════════════════╗"
echo "║  Adding iOS Deployment Secrets to GitHub                ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed"
    echo "Install with: brew install gh"
    echo "Then run: gh auth login"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub"
    echo "Run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is ready"
echo ""

# Add App Store Connect API secrets
echo "📝 Adding App Store Connect API secrets..."
echo ""

echo "1. APP_STORE_CONNECT_KEY_ID"
gh secret set APP_STORE_CONNECT_KEY_ID --body "6584299DC9"

echo "2. APP_STORE_CONNECT_API_ISSUER_ID"
gh secret set APP_STORE_CONNECT_API_ISSUER_ID --body "a5df5dea-2113-4f53-8a1c-6f8251699cfe"

echo "3. APP_STORE_CONNECT_API_KEY"
gh secret set APP_STORE_CONNECT_API_KEY --body "$(cat ios/fastlane/keys/AuthKey_6584299DC9.p8)"

echo ""
echo "✅ App Store Connect API secrets added!"
echo ""

# Generate and add keychain password
echo "4. KEYCHAIN_PASSWORD (generating random password)"
KEYCHAIN_PASSWORD=$(openssl rand -base64 32)
gh secret set KEYCHAIN_PASSWORD --body "$KEYCHAIN_PASSWORD"
echo "✅ Keychain password generated and added!"
echo ""

echo "╔══════════════════════════════════════════════════════════╗"
echo "║  ✅ Phase 1 Complete: API Secrets Added                 ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "⚠️  STILL NEEDED: Signing certificates and provisioning profile"
echo ""
echo "Next steps:"
echo ""
echo "Option A: Use existing certificate (if you have one)"
echo "  1. Export certificate from Keychain as .p12"
echo "  2. Run: gh secret set APPLE_CERTIFICATE --body \"\$(base64 -i cert.p12)\""
echo "  3. Run: gh secret set APPLE_CERTIFICATE_PASSWORD --body \"YOUR_PASSWORD\""
echo "  4. Download provisioning profile from Apple Developer"
echo "  5. Run: gh secret set PROVISIONING_PROFILE --body \"\$(base64 -i profile.mobileprovision)\""
echo ""
echo "Option B: Use Fastlane Match (recommended - automated)"
echo "  1. Create private repo for certificates"
echo "  2. Run: cd ios && fastlane match init"
echo "  3. Run: fastlane match appstore"
echo "  4. Update GitHub workflow to use Match"
echo ""
echo "See docs/IOS_DEPLOYMENT_SETUP.md for detailed instructions"
echo ""
