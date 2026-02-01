// Stub for mobile platforms - JS decrypt not available
// This file is used when compiling for iOS/Android

String decryptLegacyBackupJS(String password, String payload) {
  throw UnsupportedError('JavaScript decrypt not available on this platform - use PointyCastle implementation instead');
}
