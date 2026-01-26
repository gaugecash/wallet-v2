import 'dart:convert';
import 'dart:developer' as developer;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/components/collections/logo_fullscreen.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/layouts/base.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/main.dart';
import 'package:wallet/providers/auth.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/repository/rpc.dart';

@RoutePage()
class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  Future<List<int>> _getStorageKey() async {
    late List<int> key;
    // DISABLED FOR TESTING - FlutterSecureStorage completely bypassed
    // developer.log('KEYCHAIN STEP 1: Creating FlutterSecureStorage', name: 'GAUwallet');
    // const secureStorage = FlutterSecureStorage();

    // developer.log('KEYCHAIN STEP 2: Reading from secure storage (FREEZE POINT?)', name: 'GAUwallet');
    // final containsEncryptionKey = await secureStorage.read(key: 'hive');
    // developer.log('KEYCHAIN STEP 3: Secure storage read completed', name: 'GAUwallet');

    // DUMMY: Always generate a new key (no keychain access)
    // if (containsEncryptionKey == null) {
      // developer.log('KEYCHAIN STEP 4: No key found, generating new', name: 'GAUwallet');
      key = Hive.generateSecureKey();
      // developer.log('KEYCHAIN STEP 5: Writing new key to secure storage (FREEZE POINT?)', name: 'GAUwallet');
      // await secureStorage.write(key: 'hive', value: base64Encode(key));
      // developer.log('KEYCHAIN STEP 6: Key write completed', name: 'GAUwallet');
    // } else {
    //   developer.log('KEYCHAIN STEP 4: Key exists, decoding', name: 'GAUwallet');
    //   key = base64Decode(containsEncryptionKey);
    // }

    // developer.log('KEYCHAIN STEP 7: Returning key', name: 'GAUwallet');
    return key;
  }

  Future<void> _initStorage() async {
    if (Hive.isBoxOpen('safe')) {
      developer.log('STORAGE: Box already open, returning', name: 'GAUwallet');
      return;
    }

    developer.log('STORAGE STEP 1: Starting Hive initialization', name: 'GAUwallet');
    await Hive.initFlutter();
    developer.log('STORAGE STEP 2: Hive initialized, getting storage key', name: 'GAUwallet');

    final key = await _getStorageKey();
    developer.log('STORAGE STEP 3: Got storage key, opening encrypted box', name: 'GAUwallet');

    // mnemonic, backup, auth
    await Hive.openBox<String>(safeBox, encryptionCipher: HiveAesCipher(key));
    developer.log('STORAGE STEP 4: Encrypted box opened successfully', name: 'GAUwallet');
  }

  Future<void> _init(BuildContext context, WidgetRef ref) async {
    logger.i('INIT');
    // so that the UI can build
    await Future.delayed(Duration.zero);
    // FlutterCryptography.enable();

    await _initStorage();

    if (urlInvestorMode) {
      await Hive.box<String>(safeBox).put('investor_mode', 'primary');
    }

    final auth = ref.read(authProvider);
    final wallet = ref.read(walletProvider);

    final client = GClient();
    final clientInitResult = await client.init();

    if (!clientInitResult) {
      context.router.replaceNamed('/network_error');
      return;
    }

    await auth.init();

    if (auth.setUp && !auth.isAuthenticated) {
      context.router.replaceNamed('/auth');

      return;
    }

    // already authenticated
    // if(!wallet.initialized){
    await wallet.init(client);
    // }

    logger.i('providers initialized');

    final isSetUp =
        ref.read(authProvider).setUp && ref.read(walletProvider).wallet != null;

    logger.i('is set up: $isSetUp');

    if (isSetUp) {
      context.router.replaceNamed('/home');
    } else {
      context.router.replaceNamed('/set_up');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logger.i('BUILDING');
    useEffect(
      () {
        _init(context, ref);
        return null;
      },
      [],
    );

    return const BaseLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [LogoFullScreenComponent()],
      ),
    );
  }
}
