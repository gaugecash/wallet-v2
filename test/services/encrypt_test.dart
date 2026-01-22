import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/services/encrypt.dart';

void main() {
  group('Encryption Tests', () {
    const password = 'password';
    const payload = 'test_payload';

    test('encrypt/decrypt cycle preserves payload', () async {
      final encrypted = await computeEncrypt(password, payload);
      final decrypted = await computeDecrypt(password, encrypted);

      expect(encrypted, isNotNull);
      expect(encrypted, isNotEmpty);
      expect(decrypted, equals(payload));
    });

    test('encrypted output has correct 4-part format (SALT.IV.DATA.TAG)', () async {
      final encrypted = await computeEncrypt(password, payload);
      final parts = encrypted.split('.');

      // Verify 4 parts
      expect(parts.length, equals(4),
        reason: 'Expected format: SALT.IV.ENCRYPTED_DATA.AUTH_TAG',);

      // Verify all parts are valid base64
      for (var i = 0; i < parts.length; i++) {
        expect(() => base64.decode(parts[i]), returnsNormally,
          reason: 'Part $i should be valid base64',);
      }
    });

    test('salt, IV, and auth tag have correct byte lengths', () async {
      final encrypted = await computeEncrypt(password, payload);
      final parts = encrypted.split('.');

      final salt = base64.decode(parts[0]);
      final iv = base64.decode(parts[1]);
      final authTag = base64.decode(parts[3]);

      expect(salt.length, equals(32), reason: 'Salt must be 32 bytes');
      expect(iv.length, equals(12), reason: 'IV must be 12 bytes (GCM standard)');
      expect(authTag.length, equals(16), reason: 'Auth tag must be 16 bytes');
    });

    test('each encryption generates unique salt', () async {
      final encrypted1 = await computeEncrypt(password, payload);
      final encrypted2 = await computeEncrypt(password, payload);

      final salt1 = encrypted1.split('.')[0];
      final salt2 = encrypted2.split('.')[0];

      expect(salt1, isNot(equals(salt2)),
        reason: 'Each encryption must generate unique salt',);
    });

    test('each encryption generates unique IV', () async {
      final encrypted1 = await computeEncrypt(password, payload);
      final encrypted2 = await computeEncrypt(password, payload);

      final iv1 = encrypted1.split('.')[1];
      final iv2 = encrypted2.split('.')[1];

      expect(iv1, isNot(equals(iv2)),
        reason: 'Each encryption must generate unique IV/nonce',);
    });

    test('wrong password fails to decrypt', () async {
      final encrypted = await computeEncrypt(password, payload);

      expect(
        () => computeDecrypt('wrong_password', encrypted),
        throwsA(isA<Exception>()),
        reason: 'Decryption with wrong password must fail',
      );
    });

    test('tampered ciphertext fails to decrypt', () async {
      final encrypted = await computeEncrypt(password, payload);
      final parts = encrypted.split('.');

      // Tamper with ciphertext
      final tamperedCiphertext = '${parts[2].substring(0, parts[2].length - 1)}X';
      final tampered = '${parts[0]}.${parts[1]}.$tamperedCiphertext.${parts[3]}';

      expect(
        () => computeDecrypt(password, tampered),
        throwsA(isA<Exception>()),
        reason: 'Tampered ciphertext must fail authentication',
      );
    });

    test('invalid format (wrong number of parts) throws error', () async {
      const invalidFormat = 'part1.part2';  // Only 2 parts instead of 4

      expect(
        () => computeDecrypt(password, invalidFormat),
        throwsA(predicate((e) =>
          e is ArgumentError &&
          e.message.toString().contains('Expected 4 parts'),
        ),),
        reason: 'Invalid format should throw ArgumentError',
      );
    });

    test('different passwords produce different ciphertexts', () async {
      final encrypted1 = await computeEncrypt('password1', payload);
      final encrypted2 = await computeEncrypt('password2', payload);

      expect(encrypted1, isNot(equals(encrypted2)),
        reason: 'Same payload with different passwords must produce different ciphertexts',);
    });

    test('long payload encrypts and decrypts correctly', () async {
      final longPayload = 'A' * 10000;  // 10KB payload

      final encrypted = await computeEncrypt(password, longPayload);
      final decrypted = await computeDecrypt(password, encrypted);

      expect(decrypted, equals(longPayload));
    });
  });
}
