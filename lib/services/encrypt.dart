import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:wallet/conf.dart';

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

Future<String> _gEncrypt(String password, String payload) async {
  final algorithm = AesGcm.with256bits();
  final secret = await _pass2key(password);
  final nonce = base64.decode(encryptionSalt);

  // Encrypt
  final clearText = utf8.encode(payload);
  final secretBox = await algorithm.encrypt(
    clearText,
    secretKey: secret,
    nonce: nonce,
  );

  final encrypted = base64.encode(secretBox.cipherText);
  final mac = base64.encode(secretBox.mac.bytes);

  return '$encrypted.$mac';
}

Future<String> _gDecrypt(String password, String decryptedPayload) async {
  final algorithm = AesGcm.with256bits();
  final secret = await _pass2key(password);
  final nonce = base64.decode(encryptionSalt);

  // Encrypt
  final parts = decryptedPayload.split('.');
  final cipherText = base64.decode(parts[0]);
  final mac = base64.decode(parts[1]);
  final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(mac));
  final result = await algorithm.decrypt(
    secretBox,
    secretKey: secret,
  );

  return utf8.decode(result);
}

Future<SecretKey> _pass2key(String password) async {
  final pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 100000,
    bits: 256,
  );

  final passwordBytes = utf8.encode(password);
  final secretKey = SecretKey(passwordBytes);

  final nonce = base64.decode(encryptionSalt);

  // Calculate a hash of the password
  final newSecretKey = await pbkdf2.deriveKey(
    secretKey: secretKey,
    nonce: nonce,
  );

  return newSecretKey;
}
