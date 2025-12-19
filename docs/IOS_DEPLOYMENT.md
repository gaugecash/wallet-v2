# iOS Deployment to TestFlight - COMPLETE ✅

**Status:** AUTOMATED DEPLOYMENT WORKING
**Last Successful Build:** Attempt #6 (Run ID: 20378789802)
**Date:** 2025-12-19
**TestFlight:** LIVE 🚀

---

## Quick Start

### Deploy to TestFlight (Manual Trigger)

1. Go to: https://github.com/gaugecash/wallet-v2/actions/workflows/ci-cd.yml
2. Click "Run workflow"
3. Select action: `build-ios`
4. Click "Run workflow"

The build will automatically:
- Build and sign the iOS app with Fastlane Match
- Upload to TestFlight
- Make the build available for testing (~10-15 min processing time)

### Check TestFlight Status

App Store Connect: https://appstoreconnect.apple.com/apps/6739214175/testflight/ios

---

## Architecture

### GitHub Actions Workflow

**File:** `.github/workflows/ci-cd.yml`

**Automatic Triggers:**
- On push to `main`: Analyze, test, build web, deploy to Vercel

**Manual Triggers:**
- `build-ios`: Build iOS IPA and upload to TestFlight
- `build-android`: Build Android AAB and upload to Google Play
- `integration-tests`: Run backend integration tests

### Fastlane Configuration

**Files:**
- `ios/fastlane/Fastfile` - Main automation script
- `ios/fastlane/Matchfile` - Certificate management config
- `ios/fastlane/Appfile` - App identifier and team info

**Lanes:**
- `build_signed` - Build and sign iOS app
- `beta` - Deploy to TestFlight
- `release` - Deploy to App Store

### Certificate Management

**Fastlane Match** stores certificates in private Git repository:
- **Repo:** `gaugecash/ios-certificates` (private)
- **Authentication:** SSH deploy key
- **Encryption:** AES-256 with `MATCH_PASSWORD`

**Certificates stored:**
- Distribution certificate (Apple Distribution)
- App Store provisioning profile
- Encrypted with Match password

---

## The Journey: 6 Attempts to Success

### ❌ Attempt #1: SSH Git Authentication Failure

**Error:**
```
fatal: could not read Username for 'https://github.com': terminal prompts disabled
```

**Root Cause:**
- Matchfile used SSH URL: `git@github.com:gaugecash/ios-certificates.git` ✓
- BUT Fastfile had HTTPS fallback
- AND GitHub Secret `MATCH_GIT_URL` contained HTTPS URL

**Fix:**
1. Updated Fastfile fallback to SSH
2. Updated `MATCH_GIT_URL` secret to SSH format
3. Added `ssh-keyscan github.com >> ~/.ssh/known_hosts` (Gemini's critical fix)

**Commit:** b4291e9

---

### ❌ Attempt #2: API Key Authentication Failure

**Error:**
```
Missing password for user manuel@gaugecash.com, and running in non-interactive shell
```

**Root Cause:** Environment variable name mismatch
- Workflow provided: `APP_STORE_CONNECT_API_KEY_PATH` and `APP_STORE_CONNECT_API_KEY_ID`
- Fastfile expected: `APP_STORE_CONNECT_KEY_PATH` and `APP_STORE_CONNECT_KEY_ID`
- Result: API key was nil, Match tried username/password auth

**Fix:**
1. Aligned variable names between workflow and Fastfile
2. Removed hardcoded API credentials (security)
3. Changed `readonly: false` to allow certificate creation

**Commit:** 888f29d

---

### ✅❌ Attempt #3: Certificate Created But Wrong Keychain

**Success:** Certificate `ZQFU57VJXL` created and stored! 🎉

**Error:**
```
There are no local code signing identities found
```

**Root Cause:**
- Workflow created custom keychain: `build.keychain`
- Match imported certificate to default: `login.keychain-db`
- Xcode looked in `build.keychain` → cert not found

**Fix:**
1. Added `keychain_name: "build.keychain"` to Match
2. Added `keychain_password: ENV["KEYCHAIN_PASSWORD"]`
3. Passed `KEYCHAIN_PASSWORD` env var to build step

**Commit:** ed4502f

---

### ❌ Attempt #4: Still Keychain Issues

**Error:** Similar keychain access issues

**Root Cause:** Manual keychain creation conflicting with Fastlane's `setup_ci`

**Research Finding:** Fastlane has built-in `setup_ci` action that automatically creates temporary keychains for CI environments. Manual keychain creation was interfering.

---

### ❌ Attempt #5: Lane Order Wrong + Base64 Issue

**Error:**
```
No value found for 'key_id'
```

**Root Causes (TWO CRITICAL ISSUES):**

**Issue #1: Lane execution order wrong**
- OLD: `setup_ci → api_key → build → match → build_app`
- App was built BEFORE certificates were retrieved!
- Result: Xcode tried to sign an already-built app without certs

**Issue #2: is_key_content_base64 mismatch**
- Secret contained RAW .p8 file (PEM format)
- Fastfile had `is_key_content_base64: true`
- Fastlane tried to decode RAW content as base64 → failed

**Fixes:**
1. Reordered Fastfile lane: `match → flutter build → build_app`
2. Base64-encoded the .p8 file: `cat AuthKey_*.p8 | base64`
3. Updated `APP_STORE_CONNECT_API_KEY` secret with base64 content

**Commits:** 3896784

---

### ❌ Attempt #5.5: API Key Before setup_ci

**Error:** Still authentication issues

**Root Cause:** In `before_all` block, `setup_ci` ran BEFORE `app_store_connect_api_key`
- This meant the keychain was created before credentials were loaded
- API key configuration failed silently

**Fix:** Swapped order in `before_all`:
```ruby
before_all do
  # API key FIRST
  app_store_connect_api_key(...)

  # Then setup_ci
  setup_ci if is_ci
end
```

**Commit:** 23f44a0

---

### ✅ Attempt #6: SUCCESS!

**All fixes combined:**
1. ✅ Base64-encoded API key secret
2. ✅ `is_key_content_base64: true` matches secret format
3. ✅ API key loaded BEFORE setup_ci
4. ✅ Correct lane order (match → build → sign)
5. ✅ SSH authentication working
6. ✅ Certificates in ios-certificates repo
7. ✅ `setup_ci` handles keychain automatically

**Result:** Build succeeded, IPA uploaded to TestFlight! 🎉

---

## Final Working Configuration

### GitHub Secrets

```
APP_STORE_CONNECT_KEY_ID             # Key ID from App Store Connect
APP_STORE_CONNECT_API_ISSUER_ID      # Issuer ID from App Store Connect
APP_STORE_CONNECT_API_KEY            # Base64-encoded .p8 file
MATCH_PASSWORD                        # AES-256 encryption password
MATCH_GIT_URL                         # git@github.com:gaugecash/ios-certificates.git
MATCH_GIT_PRIVATE_KEY                # SSH private key for certificates repo
```

### Fastfile before_all (CRITICAL ORDER)

```ruby
before_all do
  # 1. Load API key FIRST (must happen before setup_ci)
  if ENV["APP_STORE_CONNECT_API_KEY_CONTENT"]
    app_store_connect_api_key(
      key_id: ENV["APP_STORE_CONNECT_KEY_ID"],
      issuer_id: ENV["APP_STORE_CONNECT_API_ISSUER_ID"],
      key_content: ENV["APP_STORE_CONNECT_API_KEY_CONTENT"],
      is_key_content_base64: true,  # Secret is base64-encoded
      in_house: false
    )
  end

  # 2. Setup CI keychain (runs after API key is loaded)
  setup_ci if is_ci
end
```

### Fastfile build_signed Lane

```ruby
lane :build_signed do
  # 1. Get certificates from Match
  match(
    type: "appstore",
    readonly: true,
    app_identifier: "com.gaugecash.app",
    git_url: ENV["MATCH_GIT_URL"] || "git@github.com:gaugecash/ios-certificates.git"
    # No keychain params - setup_ci handles it
  )

  # 2. Update Xcode code signing settings
  update_code_signing_settings(
    use_automatic_signing: false,
    path: "Runner.xcodeproj",
    team_id: "MG9USD9QPW",
    bundle_identifier: "com.gaugecash.app",
    profile_name: "match AppStore com.gaugecash.app",
    code_sign_identity: "Apple Distribution"
  )

  # 3. Build Flutter app (unsigned)
  sh("cd ../.. && flutter clean")
  sh("cd ../.. && flutter pub get")
  cocoapods(clean_install: true, podfile: "./Podfile")
  sh("cd ../.. && flutter build ios --release --no-codesign")

  # 4. Build and sign with Xcode
  build_app(
    workspace: "Runner.xcworkspace",
    scheme: "Runner",
    export_method: "app-store",
    configuration: "Release",
    clean: false,
    output_directory: "./build",
    output_name: "GAUGECASH.ipa"
  )
end
```

### Fastfile beta Lane

```ruby
lane :beta do
  build_signed

  upload_to_testflight(
    skip_waiting_for_build_processing: true,
    skip_submission: true,
    notify_external_testers: false
  )
end
```

---

## Key Learnings

### 1. Order Matters CRITICALLY

**Correct order in before_all:**
1. Load API credentials FIRST
2. Then setup CI environment

**Wrong order causes silent failures** because setup_ci creates keychain before credentials are available.

### 2. Base64 Encoding for CI/CD

**Why base64 encode the .p8 file?**
- GitHub Actions can have issues with multi-line secrets
- Base64 encoding creates a single-line value
- More reliable in CI/CD environments

**How to encode:**
```bash
cat AuthKey_6584299DC9.p8 | base64
```

**Then set is_key_content_base64: true** in Fastfile

### 3. Use setup_ci Instead of Manual Keychain

**Don't do this:**
```yaml
- name: Create keychain
  run: |
    security create-keychain -p "$PASSWORD" build.keychain
    security set-keychain-settings -lut 21600 build.keychain
    security unlock-keychain -p "$PASSWORD" build.keychain
```

**Do this instead:**
```ruby
before_all do
  setup_ci if is_ci  # Fastlane handles keychain automatically
end
```

### 4. Match Should Run BEFORE Building

**Critical:** Get certificates BEFORE running `flutter build ios`

If you build first, the app is already compiled unsigned, and signing fails.

### 5. SSH for Private Repositories

**Use SSH deploy keys** for ios-certificates repository:
- More secure than personal access tokens
- Scoped to single repository
- Uses `webfactory/ssh-agent` in GitHub Actions

---

## Troubleshooting

### Build fails with "No value found for 'key_id'"

**Check:**
1. Is `APP_STORE_CONNECT_API_KEY` secret base64-encoded?
2. Is `is_key_content_base64: true` in Fastfile?
3. Is `app_store_connect_api_key()` called BEFORE `setup_ci`?

### Match fails with git authentication error

**Check:**
1. Is `MATCH_GIT_URL` using SSH format: `git@github.com:...`?
2. Is `MATCH_GIT_PRIVATE_KEY` secret set correctly?
3. Is `ssh-keyscan github.com >> ~/.ssh/known_hosts` in workflow?
4. Does deploy key have write access? (needed for first-time cert creation)

### Certificate not found in keychain

**Don't:**
- Manually create keychains
- Pass `keychain_name` to Match
- Unlock keychains manually

**Do:**
- Use `setup_ci` in before_all
- Let Fastlane handle keychain management
- Ensure `setup_ci` runs AFTER API key is loaded

### App already exists on TestFlight but build won't upload

**Check:**
1. Version number in `pubspec.yaml`
2. Build number must be incremented
3. Bundle identifier matches: `com.gaugecash.app`

---

## Team & App Information

**App Name:** GAUGECASH
**Bundle ID:** com.gaugecash.app
**Apple Team ID:** MG9USD9QPW
**App Store Connect:** https://appstoreconnect.apple.com/apps/6739214175

**Certificates Repository:**
https://github.com/gaugecash/ios-certificates (private)

**Developer:**
Manuel Blanco (manuel@gaugecash.com)

---

## Acknowledgments

**Special thanks to:**
- **Gemini CLI** for the pre-flight checklist that caught the lane order issue
- **Gemini CLI** for the base64 encoding recommendation
- **Official Fastlane docs** for setup_ci best practices
- **Community tutorials** (Bright Inventions, Sarunw, polpiella.dev)

**Research Sources:**
- https://docs.fastlane.tools/actions/app_store_connect_api_key/
- https://docs.fastlane.tools/best-practices/continuous-integration/github/
- https://brightinventions.pl/blog/ios-testflight-github-actions-fastlane-match/
- https://sarunw.com/posts/using-app-store-connect-api-with-fastlane-match/

---

## Next Steps

### Promote to Production

When ready to release to App Store:

1. Update version in `pubspec.yaml`
2. Run workflow with `build-ios` action
3. Go to App Store Connect
4. Wait for TestFlight processing to complete
5. Add build to App Store submission
6. Submit for review

### Automate Everything

Current state:
- ✅ Automatic web deployment (on every push)
- ✅ Manual iOS deployment (workflow_dispatch)
- ✅ Manual Android deployment (workflow_dispatch)

Future enhancement:
- Trigger iOS/Android builds on version tag push
- Example: `git tag v1.0.0+42 && git push --tags` → auto-deploy

---

## Support

Issues? Check:
- GitHub Actions logs: https://github.com/gaugecash/wallet-v2/actions
- App Store Connect: https://appstoreconnect.apple.com
- Certificates repo: https://github.com/gaugecash/ios-certificates

---

**Last Updated:** 2025-12-19
**Maintained by:** Manuel Blanco
**Status:** Production Ready ✅
