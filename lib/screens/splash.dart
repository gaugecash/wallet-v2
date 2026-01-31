import 'dart:convert';
import 'dart:developer' as developer;

import 'package:auto_route/auto_route.dart';
import 'package:cryptography_flutter/cryptography_flutter.dart';
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
import 'package:wallet/services/wallet_backup.dart';

@RoutePage()
class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  Future<List<int>> _getStorageKey() async {
    late List<int> key;
    const secureStorage = FlutterSecureStorage();

    try {
      final containsEncryptionKey = await secureStorage.read(key: 'hive');

      if (containsEncryptionKey == null) {
        // First launch - generate and save key
        developer.log('KEYCHAIN: No key found, generating new', name: 'GAUwallet');
        key = Hive.generateSecureKey();
        await secureStorage.write(key: 'hive', value: base64Encode(key));
      } else {
        // Subsequent launches - reuse existing key
        developer.log('KEYCHAIN: Existing key found', name: 'GAUwallet');
        key = base64Decode(containsEncryptionKey);
      }
    } catch (e, stackTrace) {
      developer.log('KEYCHAIN ERROR: Failed to access secure storage', error: e, stackTrace: stackTrace, name: 'GAUwallet');
      // Fallback: Generate a temporary session key so the app doesn't crash, 
      // but warn that data won't persist across boots.
      key = Hive.generateSecureKey();
    }

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
    FlutterCryptography.enable();

    await _initStorage();

    if (urlInvestorMode) {
      await Hive.box<String>(safeBox).put('investor_mode', 'primary');
    }

    final auth = ref.read(authProvider);
    final wallet = ref.read(walletProvider);

    final client = GClient();
    final clientInitResult = await client.init();

    if (!clientInitResult) {
      if (context.mounted) {
        context.router.replaceNamed('/network_error');
      }
      return;
    }

    await auth.init();
    developer.log('DEBUG: INIT - authProvider.setUp: ${auth.setUp}', name: 'GAUwallet');
    developer.log('DEBUG: INIT - authProvider.isAuthenticated: ${auth.isAuthenticated}', name: 'GAUwallet');

    if (auth.setUp && !auth.isAuthenticated) {
      developer.log('DEBUG: INIT - Navigating to /auth (Biometrics/PIN)', name: 'GAUwallet');
      if (context.mounted) {
        context.router.replaceNamed('/auth');
      }

      return;
    }

    // already authenticated
    // if(!wallet.initialized){
    developer.log('DEBUG: INIT - Initializing walletProvider', name: 'GAUwallet');
    await wallet.init(client);
    // }

    logger.i('providers initialized');

    final isSetUp =
        ref.read(authProvider).setUp && ref.read(walletProvider).wallet != null;

    logger.i('is set up: $isSetUp');
    developer.log('DEBUG: INIT - isSetUp final result: $isSetUp', name: 'GAUwallet');

    if (isSetUp) {
      developer.log('DEBUG: INIT - Navigating to /home', name: 'GAUwallet');
      if (context.mounted) {
        context.router.replaceNamed('/home');
      }
    } else {
      // No wallet found in Hive - check for auto-saved backup
      final autoSavedBackup = await WalletBackup.checkForAutoSavedBackup();

      // VALIDATION: Only navigate to restore if content is a valid backup format
      final isValidBackup = autoSavedBackup != null && WalletBackup.validate(autoSavedBackup);

      if (isValidBackup) {
        developer.log('DEBUG: INIT - Valid auto-saved backup found, navigating to /set_up/restore', name: 'GAUwallet');
        if (context.mounted) {
          context.router.replaceNamed('/set_up/restore');
        }
      } else {
        developer.log('DEBUG: INIT - No valid backup found, navigating to /set_up (intro)', name: 'GAUwallet');
        if (context.mounted) {
          context.router.replaceNamed('/set_up');
        }
      }
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
