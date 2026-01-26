import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/components/alerts/warning_alert.dart';
import 'package:wallet/components/inputs/primary.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/screens/set_up/components/step.dart';
import 'package:wallet/screens/set_up/create/model.dart';
import 'package:wallet/services/bip.dart';
import 'package:wallet/services/wallet_backup.dart';

// todo fix keyboard appearing and breaking the canContinue workflow
class SetUpCreate0PasswordStep extends SetUpStep {
  const SetUpCreate0PasswordStep({super.key});

  @override
  int get page => 0;

  @override
  String get name => 'Come up with a password';

  @override
  Future<bool> Function(WidgetRef ref) get submit => (ref) async {
        developer.log('PASSWORD STEP 1: Starting wallet creation', name: 'GAUwallet');
        final walletService = ref.read(walletProvider);
        final setupService = ref.read(setUpCreateProvider);

        developer.log('PASSWORD STEP 2: Computing random mnemonic', name: 'GAUwallet');
        final mnemonic = await computeRandomMnemonic();
        developer.log('PASSWORD STEP 3: Mnemonic generated, creating backup', name: 'GAUwallet');

        // BUILD 152: All operations re-enabled with getGitCommit() fix
        final backup = await WalletBackup.generate(mnemonic);
        developer.log('PASSWORD STEP 4: Backup created', name: 'GAUwallet');

        // Re-enabled: Encryption (PBKDF2 + AES-GCM already in isolate via compute())
        final encryptedFile = await backup.encrypt(setupService.password!);
        developer.log('PASSWORD STEP 5: Backup encrypted', name: 'GAUwallet');

        // Re-enabled: Hive writes to secure storage
        await walletService.saveMnemonic(mnemonic);
        developer.log('PASSWORD STEP 6: Mnemonic saved', name: 'GAUwallet');

        await walletService.saveBackupWallet(encryptedFile);
        developer.log('PASSWORD STEP 7: Backup saved to Hive', name: 'GAUwallet');

        // BUILD 155: Fire-and-forget autoSave (don't await - prevents UI blocking)
        // User will see success/error via separate verification
        backup.autoSave(setupService.password!);
        developer.log('PASSWORD STEP 8: Wallet creation complete, auto-save triggered', name: 'GAUwallet');

        return true;
      };

  bool validate(String p1, String p2) {
    if (p1.isEmpty || p2.isEmpty) {
      return false;
    }

    return p1 == p2;
  }

  void listener(
    TextEditingController password1,
    TextEditingController password2,
    WidgetRef ref,
  ) {
    final provider = ref.read(setUpCreateProvider);

    if (provider.currentPage != page) {
      return;
    }

    final p1 = password1.text;
    final p2 = password2.text;

    final validation = validate(p1, p2);
    setCanSubmit(ref, validation);
    provider.password = p1;
  }

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    final password = useTextEditingController();
    final passwordRepeat = useTextEditingController();

    useEffect(() {
      void localListener() => listener(password, passwordRepeat, ref);
      password.addListener(localListener);
      passwordRepeat.addListener(localListener);
      return () {
        password.removeListener(localListener);
        passwordRepeat.removeListener(localListener);
      };
    }, [password, passwordRepeat],);

    return Column(
      children: [
        GPrimaryInput(
          controller: password,
          label: 'Password',
          obscureText: true,
        ),
        const SizedBox(height: 26),
        GPrimaryInput(
          controller: passwordRepeat,
          label: 'Repeat password',
          obscureText: true,
        ),
        const SizedBox(height: 26 + 13),
        const WarningAlertComponent(
          text:
              'The wallet backup file will be encrypted with this password. You will need it only when restoring the wallet.',
        ),
      ],
    );
  }
}
