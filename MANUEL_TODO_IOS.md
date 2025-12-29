# iOS Setup - What Manuel Needs To Do

**Status:** Automated as much as possible - 3 manual steps required

## What I Did Autonomously ✅

1. ✅ Downloaded GitHub CLI (gh) to /tmp/gh_2.40.1_macOS_arm64/bin/gh
2. ✅ Checked for existing certificates: **NONE FOUND**
3. ✅ Checked for existing provisioning profiles: **NONE FOUND**
4. ✅ Checked for GitHub authentication: **NOT LOGGED IN**
5. ✅ Checked Xcode installation: **Only Command Line Tools (need full Xcode)**

## What You Need To Do (Browser Required) ⚠️

### STEP 1: Authenticate GitHub CLI (2 minutes)

```bash
cd /Users/manuel/gaugecash/wallet-v2

# Use the downloaded gh
/tmp/gh_2.40.1_macOS_arm64/bin/gh auth login
# Choose: GitHub.com → HTTPS → Yes → Login with browser
# (This will open your browser for authentication)
```

### STEP 2: Add GitHub Secrets (30 seconds - after Step 1)

```bash
# Update the script to use the downloaded gh
sed -i '' 's|gh secret|/tmp/gh_2.40.1_macOS_arm64/bin/gh secret|g' scripts/add-ios-secrets.sh

# Run it
./scripts/add-ios-secrets.sh
```

This will add:
- APP_STORE_CONNECT_KEY_ID
- APP_STORE_CONNECT_API_ISSUER_ID
- APP_STORE_CONNECT_API_KEY
- KEYCHAIN_PASSWORD (auto-generated)

### STEP 3: Create Certificate & Provisioning Profile (10-15 minutes)

Since you have NO certificates or profiles, you have 2 options:

**Option A: Let GitHub Actions Handle It (Recommended - Easiest)**

Use Fastlane Match to auto-create certificates:

1. Create a private repo for certificates:
```bash
/tmp/gh_2.40.1_macOS_arm64/bin/gh repo create gaugecash/ios-certificates --private
```

2. Add Match secrets:
```bash
# Generate a strong password for encrypting certificates
MATCH_PASSWORD=$(openssl rand -base64 32)
/tmp/gh_2.40.1_macOS_arm64/bin/gh secret set MATCH_PASSWORD --body "$MATCH_PASSWORD"
/tmp/gh_2.40.1_macOS_arm64/bin/gh secret set MATCH_GIT_URL --body "https://github.com/gaugecash/ios-certificates"
```

3. Update the GitHub workflow to use Match (I'll do this after you choose)

4. First workflow run will create certificates automatically via Fastlane Match

**Option B: Manual Certificate Creation (More Control)**

You need full Xcode installed for this. If not installed:

```bash
# Install Xcode from App Store (8+ GB download, takes 30-60 minutes)
# Then open it once to accept license
```

After Xcode is installed:

1. Open the iOS project:
```bash
open /Users/manuel/gaugecash/wallet-v2/ios/Runner.xcworkspace
```

2. In Xcode:
   - Select "Runner" project in left sidebar
   - Click "Signing & Capabilities" tab
   - Team: Select "GAUGECASH NETWORK INC"
   - Xcode will automatically create certificate & profile

3. Export the certificate:
   - Open "Keychain Access" app
   - Find "Apple Distribution: GAUGECASH NETWORK INC" (or similar)
   - Right-click → Export
   - Save as: ~/Desktop/gaugecash-dist.p12
   - Set a password (remember it!)

4. Add to GitHub:
```bash
cd /Users/manuel/gaugecash/wallet-v2
/tmp/gh_2.40.1_macOS_arm64/bin/gh secret set APPLE_CERTIFICATE --body "$(base64 -i ~/Desktop/gaugecash-dist.p12)"
/tmp/gh_2.40.1_macOS_arm64/bin/gh secret set APPLE_CERTIFICATE_PASSWORD --body "YOUR_P12_PASSWORD"
rm ~/Desktop/gaugecash-dist.p12
```

5. Download provisioning profile:
   - Go to https://developer.apple.com/account/resources/profiles/list
   - Download the "App Store" profile for "com.gaugecash.app"
   - It will be in ~/Downloads/

6. Add to GitHub:
```bash
/tmp/gh_2.40.1_macOS_arm64/bin/gh secret set PROVISIONING_PROFILE --body "$(base64 -i ~/Downloads/GAUGECASH_App_Store.mobileprovision)"
```

## After Setup is Complete

### Verify All Secrets
```bash
/tmp/gh_2.40.1_macOS_arm64/bin/gh secret list
```

You should see either:
- **Option A (Match)**: 6 secrets (API key x3, KEYCHAIN_PASSWORD, MATCH_PASSWORD, MATCH_GIT_URL)
- **Option B (Manual)**: 7 secrets (API key x3, KEYCHAIN_PASSWORD, APPLE_CERTIFICATE, APPLE_CERTIFICATE_PASSWORD, PROVISIONING_PROFILE)

### Deploy to TestFlight
```bash
/tmp/gh_2.40.1_macOS_arm64/bin/gh workflow run ci-cd.yml -f action=build-ios
/tmp/gh_2.40.1_macOS_arm64/bin/gh run watch
```

## My Recommendation

**Use Option A (Fastlane Match)** because:
1. No Xcode required on your Mac
2. Certificates managed in Git (encrypted)
3. Shareable across team members
4. Auto-renewal when they expire
5. First run creates everything automatically
6. Faster setup (5 minutes vs 45 minutes with Xcode download)

The only downside is you need to create one private Git repo.

## Summary

**What's blocking you:**
1. Need to run `gh auth login` (requires browser)
2. Need to choose Certificate option (A or B)
3. If Option A: Create private repo + 2 secrets
4. If Option B: Wait for Xcode to download/install, then create cert manually

**Time estimate:**
- Option A: 5 minutes after gh auth
- Option B: 45-60 minutes (Xcode download) + 10 minutes (manual export)

Let me know which option you prefer and I'll help with the next steps.
