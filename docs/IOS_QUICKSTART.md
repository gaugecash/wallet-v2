# iOS Deployment - Quick Start Guide

**For:** Manuel
**Goal:** Get iOS automated deployment working today
**Status:** 95% Complete - Just need signing certificates

## What's Already Done ✅

1. ✅ GitHub Actions workflow created (.github/workflows/ci-cd.yml)
2. ✅ Fastlane configuration created (ios/fastlane/)
3. ✅ App Store Connect API key stored locally
4. ✅ API key file secured and gitignored
5. ✅ Comprehensive documentation written

## What You Need To Do Right Now

### Step 1: Install GitHub CLI (1 minute)

```bash
# We need this issue - Homebrew is broken on your system
# Use the standalone installer instead
curl -fsSL https://github.com/cli/cli/releases/download/v2.40.1/gh_2.40.1_macOS_arm64.zip -o gh.zip
unzip gh.zip
sudo mv gh_2.40.1_macOS_arm64/bin/gh /usr/local/bin/
rm -rf gh.zip gh_2.40.1_macOS_arm64

# Authenticate
gh auth login
# Choose: GitHub.com → HTTPS → Yes → Login with browser
```

### Step 2: Add App Store Connect API Secrets (1 minute)

```bash
cd /Users/manuel/gaugecash/wallet-v2

# Run the helper script
./scripts/add-ios-secrets.sh
```

This adds:
- APP_STORE_CONNECT_KEY_ID
- APP_STORE_CONNECT_API_ISSUER_ID
- APP_STORE_CONNECT_API_KEY
- KEYCHAIN_PASSWORD (auto-generated)

### Step 3: Get Signing Certificate (5-10 minutes)

**Option A: If you have a certificate in Keychain**

```bash
# 1. Check if you have one
security find-identity -v -p codesigning | grep "iPhone Distribution"

# 2. If found, export it
# - Open Keychain Access app
# - Find "iPhone Distribution: [Your Name]" or similar
# - Right-click → Export "..."
# - Save as: ~/Desktop/gaugecash-dist.p12
# - Set password: [choose a strong password]

# 3. Add to GitHub
cd /Users/manuel/gaugecash/wallet-v2
gh secret set APPLE_CERTIFICATE --body "$(base64 -i ~/Desktop/gaugecash-dist.p12)"
gh secret set APPLE_CERTIFICATE_PASSWORD --body "YOUR_P12_PASSWORD"

# 4. Clean up
rm ~/Desktop/gaugecash-dist.p12
```

**Option B: If you DON'T have a certificate (Use Xcode to create one)**

```bash
# 1. Open Xcode
open /Users/manuel/gaugecash/wallet-v2/ios/Runner.xcworkspace

# 2. In Xcode:
#    - Select "Runner" project
#    - Go to "Signing & Capabilities" tab
#    - Uncheck "Automatically manage signing"
#    - Team: Select "GAUGECASH NETWORK INC" (MG9USD9QPW)
#    - Click "Download Manual Profiles"
#    - If prompted, "Create Certificate" for distribution

# 3. After Xcode creates it, export from Keychain (see Option A step 2-4)
```

### Step 4: Get Provisioning Profile (3-5 minutes)

```bash
# 1. Go to Apple Developer Portal
open "https://developer.apple.com/account/resources/profiles/list"

# 2. Find or create "App Store" profile for "com.gaugecash.app"
#    - If it exists: Download it
#    - If not: Click "+" → App Store → Select App ID "com.gaugecash.app" → Select Certificate → Generate

# 3. Download the profile (should be named like "GAUGECASH_App_Store.mobileprovision")

# 4. Add to GitHub
cd /Users/manuel/gaugecash/wallet-v2
gh secret set PROVISIONING_PROFILE --body "$(base64 -i ~/Downloads/GAUGECASH_App_Store.mobileprovision)"

# 5. Clean up
rm ~/Downloads/GAUGECASH_App_Store.mobileprovision
```

### Step 5: Verify All Secrets Are Set (30 seconds)

```bash
gh secret list

# You should see:
# APP_STORE_CONNECT_API_ISSUER_ID
# APP_STORE_CONNECT_API_KEY
# APP_STORE_CONNECT_KEY_ID
# APPLE_CERTIFICATE
# APPLE_CERTIFICATE_PASSWORD
# KEYCHAIN_PASSWORD
# PROVISIONING_PROFILE
```

### Step 6: Trigger iOS Build (10 seconds)

```bash
cd /Users/manuel/gaugecash/wallet-v2
gh workflow run ci-cd.yml -f action=build-ios

# Watch it run
gh run watch
```

### Step 7: Monitor Progress (20-30 minutes)

```bash
# Check latest run status
gh run list --workflow=ci-cd.yml --limit 1

# View logs if needed
gh run view --log
```

## Expected Timeline

```
00:00 - Workflow triggered
00:02 - Dependencies installed
00:05 - Flutter build complete
00:15 - Xcode build & signing complete
00:20 - Upload to TestFlight starts
00:25 - Upload complete ✅
00:30 - Workflow finishes

Then Apple's side:
00:30 - TestFlight processing begins
00:45 - Build available for testing ✅
```

## Troubleshooting

### "gh: command not found"
```bash
# Download directly
curl -fsSL https://github.com/cli/cli/releases/download/v2.40.1/gh_2.40.1_macOS_arm64.zip -o gh.zip
unzip gh.zip && sudo mv gh_2.40.1_macOS_arm64/bin/gh /usr/local/bin/
```

### "No certificate found in Keychain"
- Use Option B above (Xcode will create one)
- Or create manually in Apple Developer Portal

### "Invalid provisioning profile"
- Ensure it's "App Store" type (not Ad Hoc or Development)
- Ensure it includes your distribution certificate
- Ensure bundle ID is exactly "com.gaugecash.app"

### Workflow fails at "Import Code Signing Certificates"
- Verify certificate is base64 encoded: `echo "$APPLE_CERTIFICATE" | base64 -D | file -`
- Should output: "data" or "PKCS12"
- If not, re-encode: `base64 -i cert.p12 | gh secret set APPLE_CERTIFICATE`

### Workflow fails at "Upload to TestFlight"
- Check API key has "App Manager" or "Admin" role in App Store Connect
- Verify bundle ID matches in Xcode: com.gaugecash.app
- Check App Store Connect for existing build processing

## Alternative: Fastlane Match (Future - More Automated)

If you want even more automation (shared certificates across team):

```bash
# 1. Create private repo
gh repo create gaugecash/ios-certificates --private

# 2. Initialize Match (requires local Fastlane - skip for now due to Ruby issues)
cd ios
fastlane match init
# Choose "git"
# Enter: https://github.com/gaugecash/ios-certificates

# 3. Generate certificates
fastlane match appstore

# 4. Update workflow to use Match instead
# (Requires MATCH_PASSWORD and MATCH_GIT_URL secrets)
```

## Summary

**Time to complete:** 20-30 minutes (mostly waiting for Apple)
**Difficulty:** Medium (certificate export is the tricky part)
**Result:** Full automated iOS deployment via GitHub Actions

**Once set up:** Just run `gh workflow run ci-cd.yml -f action=build-ios` and everything else is automatic!

---

**Questions?** Check docs/IOS_DEPLOYMENT_SETUP.md for detailed explanations.
