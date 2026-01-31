import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart' as pc;

// i guess there is no need to use a JsWorker on the web
// since encryption library already calls native apis
// [except on mobile Pbkdf2]

Future<String> computeEncrypt(String password, String payload) =>
    compute(_encryptComputeWrapper, {'password': password, 'payload': payload});

Future<String> computeDecrypt(String password, String payload) =>
    compute(_decryptComputeWrapper, {'password': password, 'payload': payload});

Future<String> _encryptComputeWrapper(Map<String, String> map) =>
    _gEncrypt(map['password']!, map['payload']!);

Future<String> _decryptComputeWrapper(Map<String, String> map) =>
    _gDecrypt(map['password']!, map['payload']!);

/// Generates a cryptographically secure random byte array
List<int> _generateRandomBytes(int length) {
  final random = Random.secure();
  return List<int>.generate(length, (i) => random.nextInt(256));
}

/// Encrypts payload with AES-256-GCM
/// Returns: SALT.IV.ENCRYPTED_DATA.AUTH_TAG (4 parts, base64 encoded)
Future<String> _gEncrypt(String password, String payload) async {
  final algorithm = AesGcm.with256bits();

  // Generate unique salt (32 bytes) and IV (12 bytes) per encryption
  final salt = _generateRandomBytes(32);
  final iv = _generateRandomBytes(12);

  // Derive key from password + salt
  final secret = await _pass2key(password, salt);

  // Encrypt
  final clearText = utf8.encode(payload);
  final secretBox = await algorithm.encrypt(
    clearText,
    secretKey: secret,
    nonce: iv,
  );

  // Encode all components separately (cryptographic best practice)
  final saltB64 = base64.encode(salt);
  final ivB64 = base64.encode(iv);
  final cipherTextB64 = base64.encode(secretBox.cipherText);
  final authTagB64 = base64.encode(secretBox.mac.bytes);

  // Format: SALT.IV.ENCRYPTED_DATA.AUTH_TAG (4 parts)
  return '$saltB64.$ivB64.$cipherTextB64.$authTagB64';
}

/// Decrypts payload encrypted with _gEncrypt
/// Supports BOTH formats for backward compatibility:
/// - NEW FORMAT (4 parts): SALT.IV.ENCRYPTED_DATA.AUTH_TAG
/// - OLD FORMAT (2 parts): ENCRYPTED_DATA.MAC (uses hardcoded salt)
Future<String> _gDecrypt(String password, String encryptedPayload) async {
  final parts = encryptedPayload.split('.');

  // Detect format based on number of parts
  if (parts.length == 2) {
    // OLD FORMAT: ENCRYPTED_DATA.MAC (with hardcoded salt)
    return _gDecryptLegacy(password, encryptedPayload);
  } else if (parts.length == 4) {
    // NEW FORMAT: SALT.IV.ENCRYPTED_DATA.AUTH_TAG
    return _gDecryptNew(password, encryptedPayload);
  } else {
    throw ArgumentError(
      'Invalid encrypted format. Expected 2 parts (legacy) or 4 parts (current), got ${parts.length}'
    );
  }
}

/// Decrypts NEW format: SALT.IV.ENCRYPTED_DATA.AUTH_TAG (4 parts, base64 encoded)
Future<String> _gDecryptNew(String password, String encryptedPayload) async {
  final algorithm = AesGcm.with256bits();

  // Parse 4-part format
  final parts = encryptedPayload.split('.');
  final salt = base64.decode(parts[0]);
  final iv = base64.decode(parts[1]);
  final cipherText = base64.decode(parts[2]);
  final authTag = base64.decode(parts[3]);

  // Derive key from password + salt
  final secret = await _pass2key(password, salt);

  // Decrypt
  final secretBox = SecretBox(cipherText, nonce: iv, mac: Mac(authTag));
  final result = await algorithm.decrypt(
    secretBox,
    secretKey: secret,
  );

  return utf8.decode(result);
}

/// Decrypts LEGACY format using PointyCastle (pure Dart, works on web with 32-byte nonce)
Future<String> _gDecryptLegacyPointyCastle(String password, String encryptedPayload) async {
  try {
    // STEP 1: Parse salt
    const legacySalt = 'RbRiYJBS2MWk5xNIFJrfRBZEqiI/RUE94Euj6cLWO5U=';
    developer.log('[PC] STEP 1: Decoding legacy salt', name: 'PointyCastle');
    final salt = base64.decode(legacySalt);
    developer.log('[PC] STEP 1 ✅: salt length = ${salt.length}', name: 'PointyCastle');

    // STEP 2: Parse 2-part format
    developer.log('[PC] STEP 2: Parsing payload', name: 'PointyCastle');
    final parts = encryptedPayload.split('.');
    if (parts.length != 2) {
      throw ArgumentError('[PC] Invalid payload: expected 2 parts, got ${parts.length}');
    }
    final cipherText = base64.decode(parts[0]);
    final mac = base64.decode(parts[1]);
    developer.log('[PC] STEP 2 ✅: cipherText=${cipherText.length}, mac=${mac.length}', name: 'PointyCastle');

    // STEP 3: Derive key using PBKDF2 (PointyCastle)
    developer.log('[PC] STEP 3: Initializing PBKDF2', name: 'PointyCastle');
    final pbkdf2 = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64))
      ..init(pc.Pbkdf2Parameters(salt, 100000, 32));
    developer.log('[PC] STEP 3a: PBKDF2 initialized, processing password', name: 'PointyCastle');

    final passwordBytes = utf8.encode(password);
    developer.log('[PC] STEP 3b: Password bytes length = ${passwordBytes.length}', name: 'PointyCastle');

    final key = pbkdf2.process(passwordBytes);
    developer.log('[PC] STEP 3 ✅: key length = ${key.length}, type = ${key.runtimeType}', name: 'PointyCastle');

    // STEP 4: Initialize cipher
    developer.log('[PC] STEP 4: Initializing AES-GCM cipher', name: 'PointyCastle');
    final cipher = pc.GCMBlockCipher(pc.AESEngine());
    developer.log('[PC] STEP 4a: Cipher created, initializing with parameters', name: 'PointyCastle');

    cipher.init(
      false, // decrypt
      pc.AEADParameters(
        pc.KeyParameter(key),
        128, // tag length in bits (16 bytes)
        salt, // 32-byte nonce - PointyCastle accepts ANY size
        Uint8List(0), // no AAD
      ),
    );
    developer.log('[PC] STEP 4 ✅: Cipher initialized', name: 'PointyCastle');

    // STEP 5: Combine ciphertext + mac for GCM
    developer.log('[PC] STEP 5: Combining ciphertext and MAC', name: 'PointyCastle');
    final combined = Uint8List(cipherText.length + mac.length);
    combined.setAll(0, cipherText);
    combined.setAll(cipherText.length, mac);
    developer.log('[PC] STEP 5 ✅: combined length = ${combined.length}', name: 'PointyCastle');

    // STEP 6: Decrypt
    developer.log('[PC] STEP 6: Processing decryption', name: 'PointyCastle');
    final decrypted = cipher.process(combined);
    developer.log('[PC] STEP 6 ✅: decrypted length = ${decrypted.length}, type = ${decrypted.runtimeType}', name: 'PointyCastle');

    // STEP 7: Convert to string
    developer.log('[PC] STEP 7: Converting bytes to UTF-8 string', name: 'PointyCastle');

    // Force type to Uint8List to avoid JS type issues
    final decryptedBytes = decrypted is Uint8List ? decrypted : Uint8List.fromList(decrypted);
    developer.log('[PC] STEP 7a: Converted to Uint8List, length = ${decryptedBytes.length}', name: 'PointyCastle');

    final result = utf8.decode(decryptedBytes);
    developer.log('[PC] STEP 7 ✅: string length = ${result.length}', name: 'PointyCastle');

    return result;
  } catch (e, stackTrace) {
    developer.log('[PC] ❌ FAILED', error: e, stackTrace: stackTrace, name: 'PointyCastle');
    developer.log('[PC] Error type: ${e.runtimeType}', name: 'PointyCastle');
    rethrow;
  }
}

/// Decrypts LEGACY format: ENCRYPTED_DATA.MAC (2 parts, with hardcoded salt)
/// This is for backward compatibility with backups created before Phase 1 Security update
Future<String> _gDecryptLegacy(String password, String encryptedPayload) async {
  if (kIsWeb) {
    // Use PointyCastle on web - handles 32-byte nonce without SubtleCrypto restrictions
    return _gDecryptLegacyPointyCastle(password, encryptedPayload);
  }

  // Mobile: use cryptography package (native, fast)
  final algorithm = AesGcm.with256bits();

  // Hardcoded salt from original implementation (SECURITY: kept for backward compatibility only)
  const legacySalt = 'RbRiYJBS2MWk5xNIFJrfRBZEqiI/RUE94Euj6cLWO5U=';
  final salt = base64.decode(legacySalt);

  // Derive key using legacy hardcoded salt
  final secret = await _pass2key(password, salt);

  // In legacy format, IV/nonce was same as salt (32 bytes)
  final nonce = salt;

  // Parse 2-part format
  final parts = encryptedPayload.split('.');
  final cipherText = base64.decode(parts[0]);
  final mac = base64.decode(parts[1]);

  // Decrypt
  final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(mac));
  final result = await algorithm.decrypt(
    secretBox,
    secretKey: secret,
  );

  return utf8.decode(result);
}


/// Derives encryption key from password using PBKDF2
Future<SecretKey> _pass2key(String password, List<int> salt, {bool useDart = false}) async {
  final pbkdf2 = (kIsWeb && useDart)
      ? DartPbkdf2(
          macAlgorithm: Hmac.sha256(),
          iterations: 100000,
          bits: 256,
        )
      : Pbkdf2(
          macAlgorithm: Hmac.sha256(),
          iterations: 100000,
          bits: 256,
        );

  final passwordBytes = utf8.encode(password);
  final secretKey = SecretKey(passwordBytes);

  // Derive key using unique salt
  final newSecretKey = await pbkdf2.deriveKey(
    secretKey: secretKey,
    nonce: salt,
  );

  return newSecretKey;
}
