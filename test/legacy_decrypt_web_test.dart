import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/services/encrypt.dart';

const String testPayload = 'JftslCkE0cyA4X1sB46CGYrNG+2R54PCX2Cusv4pirAEIQeis7StBM9f54OTCsk6chg6x/eWupmLiRqrcdoZDFrkFQN9wwZgyBTBacZOsJkki/nXrJFSGceS0JHekHfG5l84FbtGtHbr5zSxjCd8/1imNpjSuY70qHlMokecY0OC/6C0UJyPCOHJ2fJBTKPZJb+UHaPB+BS3NJKDSspydiC3smxlw/d1gfE1tC3DtKNWbcGeLuZBkN4MpaMfKNe5EMm5qyp7.AuvR68MFv0GYOQSvzuuwkw==';
const String testPassword = 'walleta';

void main() {
  group('Legacy decrypt web test', () {
    test('Decrypt legacy backup in browser JavaScript environment', () async {
      print('═══════════════════════════════════════════════════════');
      print('TESTING LEGACY DECRYPTION IN BROWSER');
      print('═══════════════════════════════════════════════════════');
      print('Platform: Web (JavaScript compilation)');
      print('Payload: ${testPayload.substring(0, 50)}...');
      print('Password: $testPassword');
      print('═══════════════════════════════════════════════════════');

      try {
        // This will trigger the PointyCastle decryption path on web
        final result = await computeDecrypt(testPassword, testPayload);

        print('\n✅ DECRYPTION SUCCEEDED');
        print('Result length: ${result.length}');
        print('Result: $result');

        expect(result, contains('mnemonic'));
        expect(result, contains('cheap script confirm'));
      } catch (e, stackTrace) {
        print('\n❌ DECRYPTION FAILED');
        print('Error: $e');
        print('Error type: ${e.runtimeType}');
        print('Stack trace:');
        print(stackTrace);

        fail('Legacy decryption failed: $e');
      }
    });
  });
}
