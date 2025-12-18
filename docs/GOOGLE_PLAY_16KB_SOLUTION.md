# Google Play 16KB Page Size Compliance - Solution

**Date Solved:** December 18, 2024
**Version:** 1.0.5 (137)
**Status:** ✅ PASSED Google Play Console Validation

## The Problem

Google Play Store 2025 requirements:
1. Apps must support 16KB memory page sizes
2. Apps must target API level 35 (Android 15)

## Root Cause Identified

**The Issue:** Third-party dependency `androidx.camera:camera-core:1.3.3` contained native library `libimage_processing_util_jni.so` with **4KB alignment** (not 16KB compliant).

This dependency was pulled transitively through:
- `mobile_scanner` → `com.google.mlkit:barcode-scanning` → `androidx.camera:camera-core`

## The Solution

### 1. Force CameraX 1.4.0 (16KB-compliant)

**File:** `android/app/build.gradle.kts`

```kotlin
android {
    ndkVersion = "28.2.13676358"  // NDK with 16KB support

    configurations.all {
        resolutionStrategy {
            // Force 16KB-compliant versions
            force("com.google.mlkit:barcode-scanning:17.3.0")
            force("com.google.mlkit:vision-common:17.3.0")
            force("com.google.mlkit:common:18.11.0")
            force("com.google.mlkit:vision-interfaces:16.3.0")
            force("com.google.android.gms:play-services-mlkit-barcode-scanning:18.3.1")
            force("com.google.android.odml:image-jni:1.0.0-beta1")

            // THE KEY FIX: Force CameraX 1.4.0
            force("androidx.camera:camera-core:1.4.0")
            force("androidx.camera:camera-camera2:1.4.0")
            force("androidx.camera:camera-lifecycle:1.4.0")
        }
    }
}
```

### 2. Enable Uncompressed Native Libraries

**File:** `android/gradle.properties`

```properties
android.bundle.enableUncompressedNativeLibs=true
android.useLegacyPackaging=false
```

### 3. Set Manifest Attribute

**File:** `android/app/src/main/AndroidManifest.xml`

```xml
<application
    android:extractNativeLibs="false"
    ...>
```

### 4. Update Target SDK

**File:** `android/local.properties` (generated)

```properties
flutter.targetSdkVersion=35
flutter.compileSdkVersion=35
```

## What We Learned

### ❌ Common Misconceptions:

1. **Compression in AAB doesn't matter**: We spent hours trying to make .so files "Stored" instead of "Deflated" in the AAB. Google Play processes AABs server-side - the compression state in the uploaded AAB is irrelevant.

2. **aaptOptions doesn't help**: `aaptOptions { noCompress("so") }` affects APK generation, not AAB bundling.

3. **Moving packaging blocks**: Moving packaging options between android/release blocks didn't solve anything.

### ✅ What Actually Mattered:

1. **16KB-aligned native binaries**: CameraX 1.4.0 was the first version with 16KB-aligned .so files
2. **Gradle properties**: `enableUncompressedNativeLibs=true` tells bundletool how to generate APKs
3. **Manifest attribute**: `extractNativeLibs="false"` tells the OS not to extract libraries (keep them aligned)
4. **NDK 28.2.13676358**: Required for building with 16KB support

## Verification

To check if an AAB is 16KB compliant:

```bash
# Extract and check alignment
unzip -d /tmp/aab-check your-app.aab
cd /tmp/aab-check
objdump -p base/lib/arm64-v8a/*.so | grep "align"

# Should show: align 2**14 (16KB) or higher
```

## Credits

- **Gemini AI**: Identified CameraX as the root cause (not just ML Kit)
- **Claude AI**: Implementation and build automation
- **Google Play Console**: Final validation

## Timeline

- **v132**: First attempt - Failed (ML Kit 17.2.0 had 4KB binaries)
- **v133**: ML Kit 17.3.0 - Failed (CameraX still 1.3.3)
- **v134-136**: Various packaging attempts - Failed (compression red herring)
- **v137**: CameraX 1.4.0 + proper config - ✅ **SUCCESS**

## Future Reference

For any Flutter app using `mobile_scanner` or ML Kit, ensure:
1. CameraX >= 1.4.0
2. ML Kit >= 17.3.0
3. NDK 28.2+
4. The three configuration changes above

This configuration is compatible with:
- Flutter 3.38.5+
- Android Gradle Plugin 8.6.0+
- Gradle 8.7+
- Kotlin 2.1.0+
