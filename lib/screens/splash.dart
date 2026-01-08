import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/components/visuals/corona_widget.dart';
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
    const secureStorage = FlutterSecureStorage();
    print('reading secure key');
    final containsEncryptionKey = await secureStorage.read(key: 'hive');
    print('checking secure key');
    if (containsEncryptionKey == null) {
      print('no secure key, generating');
      key = Hive.generateSecureKey();
      await secureStorage.write(key: 'hive', value: base64Encode(key));
    } else {
      print('there is a key, reading');
      key = base64Decode(containsEncryptionKey);
    }

    print('got a key');
    return key;
  }

  Future<void> _initStorage() async {
    if (Hive.isBoxOpen('safe')) {
      return;
    }

    await Hive.initFlutter();

    final key = await _getStorageKey();

    // mnemonic, backup, auth
    await Hive.openBox<String>(safeBox, encryptionCipher: HiveAesCipher(key));
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

    // Artificial delay to show the animation a bit longer if initialization is too fast
    await Future.delayed(const Duration(seconds: 2));

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

    return BaseLayout(
      child: Center(
        child: CoronaWidget(
          onLaunch: () {
            // Interactive launch? For now, handled by _init
            logger.i("Launch button tapped");
          },
        ),
      ),
    );
  }
}