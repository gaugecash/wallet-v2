import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

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
/// Expects: SALT.IV.ENCRYPTED_DATA.AUTH_TAG (4 parts, base64 encoded)
Future<String> _gDecrypt(String password, String encryptedPayload) async {
  final algorithm = AesGcm.with256bits();

  // Parse 4-part format
  final parts = encryptedPayload.split('.');
  if (parts.length != 4) {
    throw ArgumentError('Invalid encrypted format. Expected 4 parts (SALT.IV.ENCRYPTED_DATA.AUTH_TAG), got ${parts.length}');
  }

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

/// Derives encryption key from password using PBKDF2
Future<SecretKey> _pass2key(String password, List<int> salt) async {
  final pbkdf2 = Pbkdf2(
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
