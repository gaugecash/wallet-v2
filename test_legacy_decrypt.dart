import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/export.dart' as pc;

const String testPayload = 'JftslCkE0cyA4X1sB46CGYrNG+2R54PCX2Cusv4pirAEIQeis7StBM9f54OTCsk6chg6x/eWupmLiRqrcdoZDFrkFQN9wwZgyBTBacZOsJkki/nXrJFSGceS0JHekHfG5l84FbtGtHbr5zSxjCd8/1imNpjSuY70qHlMokecY0OC/6C0UJyPCOHJ2fJBTKPZJb+UHaPB+BS3NJKDSspydiC3smxlw/d1gfE1tC3DtKNWbcGeLuZBkN4MpaMfKNe5EMm5qyp7.AuvR68MFv0GYOQSvzuuwkw==';
const String testPassword = 'walleta';
const String legacySalt = 'RbRiYJBS2MWk5xNIFJrfRBZEqiI/RUE94Euj6cLWO5U=';

/// Test decryption using PointyCastle (web approach)
Future<String> testPointyCastleDecrypt(String password, String encryptedPayload) async {
  print('\n=== TESTING POINTYCASTLE DECRYPTION ===');

  final salt = base64.decode(legacySalt);
  print('Salt (first 16 bytes): ${salt.sublist(0, 16)}');
  print('Salt length: ${salt.length} bytes');

  // Parse 2-part format
  final parts = encryptedPayload.split('.');
  print('Payload parts: ${parts.length}');

  final cipherText = base64.decode(parts[0]);
  final mac = base64.decode(parts[1]);
  print('Ciphertext length: ${cipherText.length} bytes');
  print('MAC length: ${mac.length} bytes');

  // Derive key using PBKDF2 (PointyCastle)
  print('\nDeriving key with PBKDF2...');
  final pbkdf2 = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64))
    ..init(pc.Pbkdf2Parameters(salt, 100000, 32));
  final key = pbkdf2.process(utf8.encode(password));
  print('Derived key (first 16 bytes): ${key.sublist(0, 16)}');
  print('Derived key length: ${key.length} bytes');

  // Decrypt using AES-GCM (PointyCastle)
  print('\nDecrypting with AES-GCM...');
  final cipher = pc.GCMBlockCipher(pc.AESEngine())
    ..init(
      false, // decrypt
      pc.AEADParameters(
        pc.KeyParameter(key),
        128, // tag length in bits (16 bytes)
        salt, // 32-byte nonce
        Uint8List(0), // no AAD
      ),
    );

  // Combine ciphertext + mac for GCM
  final combined = Uint8List(cipherText.length + mac.length);
  combined.setAll(0, cipherText);
  combined.setAll(cipherText.length, mac);
  print('Combined input length: ${combined.length} bytes');

  try {
    final decrypted = cipher.process(combined);
    final result = utf8.decode(decrypted);
    print('\n✅ POINTYCASTLE DECRYPTION SUCCESS');
    print('Decrypted length: ${decrypted.length} bytes');
    print('Result (first 100 chars): ${result.substring(0, result.length > 100 ? 100 : result.length)}...');
    return result;
  } catch (e, stackTrace) {
    print('\n❌ POINTYCASTLE DECRYPTION FAILED');
    print('Error: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

/// Test decryption using cryptography package (mobile approach)
Future<String> testCryptographyDecrypt(String password, String encryptedPayload) async {
  print('\n=== TESTING CRYPTOGRAPHY PACKAGE DECRYPTION ===');

  final algorithm = AesGcm.with256bits();
  final salt = base64.decode(legacySalt);
  print('Salt length: ${salt.length} bytes');

  // Derive key using PBKDF2
  print('\nDeriving key with PBKDF2...');
  final pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 100000,
    bits: 256,
  );

  final passwordBytes = utf8.encode(password);
  final secretKey = SecretKey(passwordBytes);

  final derivedKey = await pbkdf2.deriveKey(
    secretKey: secretKey,
    nonce: salt,
  );

  final derivedKeyBytes = await derivedKey.extractBytes();
  print('Derived key (first 16 bytes): ${derivedKeyBytes.sublist(0, 16)}');

  // In legacy format, IV/nonce was same as salt (32 bytes)
  final nonce = salt;

  // Parse 2-part format
  final parts = encryptedPayload.split('.');
  final cipherText = base64.decode(parts[0]);
  final mac = base64.decode(parts[1]);
  print('Ciphertext length: ${cipherText.length} bytes');
  print('MAC length: ${mac.length} bytes');

  // Decrypt
  print('\nDecrypting with AES-GCM (32-byte nonce)...');
  final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(mac));

  try {
    final result = await algorithm.decrypt(
      secretBox,
      secretKey: derivedKey,
    );
    final resultString = utf8.decode(result);
    print('\n✅ CRYPTOGRAPHY PACKAGE DECRYPTION SUCCESS');
    print('Decrypted length: ${result.length} bytes');
    print('Result (first 100 chars): ${resultString.substring(0, resultString.length > 100 ? 100 : resultString.length)}...');
    return resultString;
  } catch (e, stackTrace) {
    print('\n❌ CRYPTOGRAPHY PACKAGE DECRYPTION FAILED');
    print('Error: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

void main() async {
  print('╔════════════════════════════════════════════════════════════╗');
  print('║  LEGACY BACKUP DECRYPTION TEST                             ║');
  print('╚════════════════════════════════════════════════════════════╝');
  print('\nTest data:');
  print('- Password: $testPassword');
  print('- Legacy salt: $legacySalt');
  print('- Payload (first 50 chars): ${testPayload.substring(0, 50)}...');

  String? pointyCastleResult;
  String? cryptographyResult;

  // Test 1: PointyCastle (web approach)
  try {
    pointyCastleResult = await testPointyCastleDecrypt(testPassword, testPayload);
  } catch (e) {
    print('\n⚠️  PointyCastle test failed, continuing with cryptography package test...');
  }

  // Test 2: Cryptography package (mobile approach)
  try {
    cryptographyResult = await testCryptographyDecrypt(testPassword, testPayload);
  } catch (e) {
    print('\n⚠️  Cryptography package test failed');
  }

  // Compare results
  print('\n╔════════════════════════════════════════════════════════════╗');
  print('║  COMPARISON RESULTS                                        ║');
  print('╚════════════════════════════════════════════════════════════╝');

  if (pointyCastleResult != null && cryptographyResult != null) {
    if (pointyCastleResult == cryptographyResult) {
      print('\n✅ BOTH METHODS SUCCESSFUL AND MATCH');
      print('✅ PointyCastle and cryptography package produce identical results');
      print('\nDecrypted content:');
      print('─────────────────────────────────────────────────────────────');
      print(pointyCastleResult);
      print('─────────────────────────────────────────────────────────────');
    } else {
      print('\n❌ BOTH METHODS SUCCESSFUL BUT RESULTS DIFFER');
      print('PointyCastle length: ${pointyCastleResult.length}');
      print('Cryptography package length: ${cryptographyResult.length}');
    }
  } else if (pointyCastleResult != null) {
    print('\n⚠️  Only PointyCastle succeeded');
    print('Decrypted content:');
    print('─────────────────────────────────────────────────────────────');
    print(pointyCastleResult);
    print('─────────────────────────────────────────────────────────────');
  } else if (cryptographyResult != null) {
    print('\n⚠️  Only cryptography package succeeded');
    print('Decrypted content:');
    print('─────────────────────────────────────────────────────────────');
    print(cryptographyResult);
    print('─────────────────────────────────────────────────────────────');
  } else {
    print('\n❌ BOTH METHODS FAILED');
    print('⚠️  Cannot decrypt test payload with either approach');
  }
}
