import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:wallet/conf.dart';
// import 'package:local_auth/local_auth.dart';

final authProvider = Provider((_) => AuthProvider());

const _safePinCode = 'pin_code';
const _safeAuthMethod = 'auth_method';

// todo add support for hardware key
// todo allow user to choose the auth method
enum AuthMethod { pinCode, localAuth }

const _titles = {
  AuthMethod.pinCode: 'Set up a pin code for quick access',
  AuthMethod.localAuth: 'Set up biometrics',
};

const _names = {
  AuthMethod.pinCode: 'pin_code',
  AuthMethod.localAuth: 'local_auth',
};

// todo: refactor this mess
class AuthProvider {
  late Box<String> storage;
  late AuthMethod method;
  bool initialized = false;
  bool setUp = false;
  bool isAuthenticated = false;

  String get setUpTitle => _titles[method]!;

  String get methodName => _names[method]!;

  // todo probably extend this class instead
  Future<void> setPinCode(String pinCode) async {
    await storage.put(_safePinCode, pinCode);
    isAuthenticated = true;
  }

  bool verifyPinCode(String pinCode) {
    final p = storage.get(_safePinCode);

    final result = p == pinCode;

    if (setUp == false && result) {
      setUp = true;
    }

    isAuthenticated = result;
    return result;
  }

  Future<bool> useLocalAuth() async {
    final auth = LocalAuthentication();
    final result = await auth.authenticate(
      localizedReason: 'Authenticate to continue',
    );

    if (setUp == false && result) {
      setUp = true;
    }
    isAuthenticated = result;

    return result;
  }

  Future<void> save() => storage.put(_safeAuthMethod, methodName);

  Future<void> init() async {
    storage = Hive.box<String>(safeBox);

    final auth = await _determineAuthMethod();
    method = auth;
    initialized = true;
  }

  Future<AuthMethod> _determineAuthMethod() async {
    final auth = storage.get(_safeAuthMethod);

    if (auth != null) {
      setUp = true;
      return _names.entries.firstWhere((e) => e.value == auth).key;
    } else {
      setUp = false;
    }

    final deviceAuth = LocalAuthentication();

    try {
      final canUseBiometrics = await deviceAuth.canCheckBiometrics;
      final canUseDeviceAuth =
          canUseBiometrics && await deviceAuth.isDeviceSupported();

      if (!canUseDeviceAuth) {
        return AuthMethod.pinCode;
      }

      final getMethods = await deviceAuth.getAvailableBiometrics();

      if (getMethods.isNotEmpty) {
        return AuthMethod.localAuth;
      }
    } catch (_) {}

    return AuthMethod.pinCode;
  }
}
