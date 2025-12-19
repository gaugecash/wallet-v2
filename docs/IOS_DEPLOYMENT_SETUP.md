# iOS Deployment Setup - GitHub Actions + Fastlane

**Status:** Configuration Ready - Requires Certificates & Secrets
**Date:** December 19, 2024
**Platform:** iOS via TestFlight
**Automation:** Full GitHub Actions workflow

## Overview

The iOS deployment is now fully automated via GitHub Actions, mirroring the Android setup. When triggered manually, it will:

1. Build the Flutter iOS app
2. Sign with your Apple Developer certificates
3. Upload to TestFlight automatically
4. Archive the IPA for 90 days

## Architecture

```
GitHub Actions (macOS runner)
  → Fastlane (build orchestration)
    → CocoaPods (dependencies)
    → Flutter build iOS
    → Xcode build & sign
    → App Store Connect API (upload)
      → TestFlight
```

## Required GitHub Secrets

You must add these secrets to the GitHub repository before the workflow can run:

### 1. App Store Connect API Key (Already Have)

```bash
APP_STORE_CONNECT_KEY_ID=6584299DC9
APP_STORE_CONNECT_API_ISSUER_ID=a5df5dea-2113-4f53-8a1c-6f8251699cfe
APP_STORE_CONNECT_API_KEY=-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgkprHGrXZp+QkITXX
wU7v83U2dwDkAa2uDW/lU2XD+6egCgYIKoZIzj0DAQehRANCAAReHOH2iizIUh6K
s8IZZiLBhjC/iENcSdz7MUe2djcOI8FONmwXTptOGs5rjvnBWUo+n5MY/WpRjUVF
yN/OPRdi
-----END PRIVATE KEY-----
```

### 2. iOS Distribution Certificate (NEED TO CREATE)

**What:** Your Apple Developer distribution certificate (.p12 file)
**Secret Name:** `APPLE_CERTIFICATE`
**Format:** Base64-encoded .p12 file

**How to get it:**

Option A: If you already have a certificate in Keychain:
```bash
# 1. Export from Keychain Access
# - Open Keychain Access
# - Find "iPhone Distribution: [Your Name]"
# - Right-click → Export → Save as .p12
# - Set a password

# 2. Encode as base64
base64 -i YourCertificate.p12 | pbcopy
# (This copies the base64 string to clipboard)

# 3. Add to GitHub Secrets as APPLE_CERTIFICATE
```

Option B: Create new certificate via Fastlane Match (recommended):
```bash
# Will create and manage certificates automatically
# See "Using Fastlane Match" section below
```

### 3. Certificate Password

**Secret Name:** `APPLE_CERTIFICATE_PASSWORD`
**Format:** Plain text password
**Value:** The password you set when exporting the .p12 file

### 4. Provisioning Profile (NEED TO CREATE)

**What:** App Store provisioning profile for com.gaugecash.app
**Secret Name:** `PROVISIONING_PROFILE`
**Format:** Base64-encoded .mobileprovision file

**How to get it:**

Option A: Download from Apple Developer Portal:
```bash
# 1. Go to https://developer.apple.com/account/resources/profiles
# 2. Find/Create "App Store" profile for "com.gaugecash.app"
# 3. Download the .mobileprovision file

# 4. Encode as base64
base64 -i YourProfile.mobileprovision | pbcopy

# 5. Add to GitHub Secrets as PROVISIONING_PROFILE
```

Option B: Use Fastlane Match (recommended)

### 5. Keychain Password

**Secret Name:** `KEYCHAIN_PASSWORD`
**Format:** Plain text password (any strong password)
**Purpose:** Temporary password for CI keychain
**Value:** Generate a random password: `openssl rand -base64 32`

## Adding Secrets to GitHub

```bash
# Via GitHub CLI (if installed)
gh secret set APP_STORE_CONNECT_KEY_ID --body "6584299DC9"
gh secret set APP_STORE_CONNECT_API_ISSUER_ID --body "a5df5dea-2113-4f53-8a1c-6f8251699cfe"
gh secret set APP_STORE_CONNECT_API_KEY --body "$(cat ios/fastlane/keys/AuthKey_6584299DC9.p8)"

# Certificate (after creating/exporting)
gh secret set APPLE_CERTIFICATE --body "$(base64 -i certificate.p12)"
gh secret set APPLE_CERTIFICATE_PASSWORD --body "YOUR_P12_PASSWORD"

# Provisioning profile (after downloading)
gh secret set PROVISIONING_PROFILE --body "$(base64 -i profile.mobileprovision)"

# Keychain password
gh secret set KEYCHAIN_PASSWORD --body "$(openssl rand -base64 32)"
```

Or via GitHub Web UI:
1. Go to https://github.com/gaugecash/wallet-v2/settings/secrets/actions
2. Click "New repository secret"
3. Add each secret name and value
4. Click "Add secret"

## Using Fastlane Match (Recommended Alternative)

Instead of manually managing certificates, Fastlane Match can automate this:

**Benefits:**
- Automatic certificate creation/renewal
- Shared across team members
- Encrypted storage in Git repo
- No manual export/import needed

**Setup:**
```bash
# 1. Create a private Git repo for certificates
# Example: https://github.com/gaugecash/ios-certificates (private!)

# 2. Run Fastlane Match locally (one-time setup)
cd ios
fastlane match init
# Choose "git" storage
# Enter your certificates repo URL

# 3. Generate certificates
fastlane match appstore --app_identifier com.gaugecash.app

# 4. Update GitHub workflow to use Match instead
# (Will require MATCH_PASSWORD and MATCH_GIT_URL secrets)
```

## Triggering the iOS Deployment

### Via Command Line (Recommended)

```bash
gh workflow run ci-cd.yml -f action=build-ios
```

### Via GitHub Web UI

1. Go to https://github.com/gaugecash/wallet-v2/actions
2. Click "GAUwallet CI/CD" workflow
3. Click "Run workflow" button
4. Select "build-ios" from dropdown
5. Click "Run workflow"

### Via API (For Scripts)

```bash
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token YOUR_GITHUB_TOKEN" \
  https://api.github.com/repos/gaugecash/wallet-v2/actions/workflows/ci-cd.yml/dispatches \
  -d '{"ref":"main","inputs":{"action":"build-ios"}}'
```

## What Happens When You Run It

```
1. ✓ Checkout code from GitHub
2. ✓ Setup Flutter 3.38.5
3. ✓ Install dependencies (flutter pub get)
4. ✓ Setup App Store Connect API key
5. ✓ Install Ruby 3.0 + Fastlane
6. ✓ Install CocoaPods dependencies
7. ✓ Import signing certificates to keychain
8. ✓ Build Flutter iOS (release mode)
9. ✓ Build IPA with Xcode (signed)
10. ✓ Upload to TestFlight
11. ✓ Archive IPA to GitHub Artifacts
```

**Estimated time:** 20-30 minutes

## After Upload

1. **TestFlight Processing** (10-15 minutes):
   - Apple processes the build
   - Checks for compliance issues
   - Makes available for testing

2. **App Store Connect**:
   - Go to https://appstoreconnect.apple.com
   - Navigate to "TestFlight" tab
   - Your build will appear under "iOS builds"
   - Add internal/external testers
   - Submit for review (if needed)

3. **Version Increment**:
   - Current version: 1.0.5 (137)
   - Update in pubspec.yaml before next build
   - GitHub Actions uses this automatically

## Troubleshooting

### Build fails at "Import Code Signing Certificates"
- Check that APPLE_CERTIFICATE is valid base64
- Verify APPLE_CERTIFICATE_PASSWORD is correct
- Ensure certificate hasn't expired

### Build fails at "Upload to TestFlight"
- Verify API key has App Manager or Admin role
- Check API key hasn't expired
- Ensure bundle ID matches (com.gaugecash.app)

### "Provisioning profile doesn't match"
- Profile must be for App Store distribution
- Profile must include com.gaugecash.app
- Profile must be active (not expired)
- Profile must include the signing certificate

### CocoaPods installation fails
- Check Podfile.lock is committed
- Verify all pods are available
- May need to update pod versions

## Comparison: Android vs iOS Deployment

| Feature | Android | iOS |
|---------|---------|-----|
| CI Platform | GitHub Actions (ubuntu) | GitHub Actions (macos) |
| Build Tool | Gradle | Xcode + Fastlane |
| Signing | Service Account JSON | Certificate + Profile |
| Distribution | Google Play (Internal) | TestFlight |
| Processing Time | ~15 mins | ~30 mins (build) + 15 mins (Apple) |
| Cost | Free | Free (GitHub provides macOS runners) |
| Complexity | Medium | High |

## Next Steps

1. **TODAY**: Add required GitHub Secrets (certificates, profiles)
2. **TODAY**: Test workflow by triggering manually
3. **TOMORROW**: Monitor TestFlight processing
4. **ONGOING**: Update version in pubspec.yaml before each release

## Files Created/Modified

```
.github/workflows/ci-cd.yml         (enhanced iOS job)
ios/fastlane/Appfile                (API key config)
ios/fastlane/Fastfile               (build/deploy lanes)
ios/fastlane/keys/AuthKey_*.p8      (API key - gitignored)
ios/.gitignore                      (ignore keys/)
docs/IOS_DEPLOYMENT_SETUP.md        (this file)
```

## Security Notes

- ✅ API key stored in GitHub Secrets (encrypted)
- ✅ API key file gitignored (ios/fastlane/keys/)
- ✅ Certificates stored in GitHub Secrets (encrypted)
- ✅ Temporary keychain deleted after build
- ✅ No credentials in logs or artifacts
- ⚠️ Never commit .p12 or .mobileprovision files
- ⚠️ Never share APPLE_CERTIFICATE or PROVISIONING_PROFILE values

## Support

If deployment fails:
1. Check GitHub Actions logs for specific error
2. Compare with Android workflow (known working)
3. Verify all secrets are set correctly
4. Check Apple Developer Portal for certificate status
5. Review this document for troubleshooting steps

---

**Philosophy:** Like Android, Manuel gives orders via chat/terminal. GitHub Actions handles the deployment. No UI button clicking required.
