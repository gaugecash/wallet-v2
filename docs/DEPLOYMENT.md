# Deployment Guide

## Prerequisites

- Flutter SDK 3.24+
- Vercel CLI (npm i -g vercel)
- Access to gaugecash Vercel team
- Access to Google Play Console (for Android)
- Access to App Store Connect (for iOS)

---

## Web Deployment (Vercel)

### Preview Deployment
cd /path/to/wallet-v2
flutter build web --release
cd build/web
vercel

Preview URL will be generated (e.g., gauwallet-preview.vercel.app)

### Production Deployment
cd /path/to/wallet-v2
flutter build web --release
cd build/web
vercel --prod

Deploys to: https://app.gaugecash.com

### Why Deploy from build/web?

Vercel cannot build Flutter. The Flutter SDK is not available on Vercel servers.

**Correct:** Build locally then upload compiled files
**Wrong:** Try to build Flutter on Vercel (will fail)

---

## Android Deployment (Google Play)

### Build AAB
flutter build appbundle --release

Output: build/app/outputs/bundle/release/app-release.aab

### Upload to Google Play
1. Go to Google Play Console
2. Select GAUwallet app
3. Create new release (Production track)
4. Upload app-release.aab
5. Add release notes
6. Review and publish

### CI/CD (GitHub Actions)
Automatic builds are configured in .github/workflows/ci-cd.yml
- Runs on every push to main
- Builds AAB artifact
- Does NOT auto-upload to Play Store (manual approval required)

---

## iOS Deployment (App Store)

### Build IPA
flutter build ipa --release

### Upload to App Store
1. Open build/ios/archive/*.xcarchive in Xcode
2. Validate app
3. Distribute to App Store Connect
4. Submit for review in App Store Connect

---

## Pre-Deployment Checklist

Before deploying to production:

- [ ] All tests pass
- [ ] Version bumped in pubspec.yaml
- [ ] CHANGELOG updated
- [ ] RPC endpoint verified (lib/conf.dart)
- [ ] Backend URL verified (lib/conf.dart)
- [ ] RelayerV4 address verified (lib/conf.dart)
- [ ] Gasless toggle defaults to false
- [ ] Test on preview deployment first

---

## Rollback Procedure

### Web (Vercel)
vercel ls wallet-v2 --prod
vercel promote <previous-deployment-url> --prod

### Android (Google Play)
Use "Manage releases" to deactivate current version and reactivate previous version

### iOS (App Store)
Submit previous version for expedited review
