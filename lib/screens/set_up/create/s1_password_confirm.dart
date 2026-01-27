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

class SetUpCreate1PasswordConfirmStep extends SetUpStep {
  SetUpCreate1PasswordConfirmStep({super.key});

  @override
  int get page => 1;

  @override
  String get name => 'Confirm your password';

  // Store context for use in submit function (needed for SnackBar feedback)
  BuildContext? _currentContext;

  @override
  Future<bool> Function(WidgetRef ref) get submit => (ref) async {
        final setupService = ref.read(setUpCreateProvider);

        developer.log('PASSWORD CONFIRM: Starting wallet creation', name: 'GAUwallet');
        final walletService = ref.read(walletProvider);

        developer.log('PASSWORD CONFIRM: Computing random mnemonic', name: 'GAUwallet');
        final mnemonic = await computeRandomMnemonic();
        developer.log('PASSWORD CONFIRM: Mnemonic generated, creating backup', name: 'GAUwallet');

        final backup = await WalletBackup.generate(mnemonic);
        developer.log('PASSWORD CONFIRM: Backup created', name: 'GAUwallet');

        final encryptedFile = await backup.encrypt(setupService.password!);
        developer.log('PASSWORD CONFIRM: Backup encrypted', name: 'GAUwallet');

        await walletService.saveMnemonic(mnemonic);
        developer.log('PASSWORD CONFIRM: Mnemonic saved', name: 'GAUwallet');

        await walletService.saveBackupWallet(encryptedFile);
        developer.log('PASSWORD CONFIRM: Backup saved to Hive', name: 'GAUwallet');

        backup.autoSave(setupService.password!, context: _currentContext);
        developer.log('PASSWORD CONFIRM: Wallet creation complete, auto-save triggered', name: 'GAUwallet');

        return true;
      };

  void listener(
    TextEditingController passwordConfirm,
    WidgetRef ref,
  ) {
    final provider = ref.read(setUpCreateProvider);

    if (provider.currentPage != page) {
      return;
    }

    final p1 = provider.password ?? '';
    final p2 = passwordConfirm.text;

    // Check both passwords match
    final validation = p1.isNotEmpty && p2.isNotEmpty && p1 == p2;

    setCanSubmit(ref, validation);
  }

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    // Store context for use in submit function (enables SnackBar feedback)
    _currentContext = context;

    final provider = ref.read(setUpCreateProvider);
    final passwordConfirm = useTextEditingController();
    final passwordsMatch = useState<bool?>(null);

    useEffect(() {
      void localListener() => listener(passwordConfirm, ref);
      passwordConfirm.addListener(localListener);
      return () {
        passwordConfirm.removeListener(localListener);
      };
    }, [passwordConfirm],);

    // Check password match for visual feedback
    useEffect(() {
      if (passwordConfirm.text.isNotEmpty) {
        passwordsMatch.value = provider.password == passwordConfirm.text;
      } else {
        passwordsMatch.value = null;
      }
      return null;
    }, [passwordConfirm.text],);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.centerRight,
          children: [
            GPrimaryInput(
              controller: passwordConfirm,
              label: 'Confirm password',
              obscureText: true,
            ),
            if (passwordsMatch.value != null)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  passwordsMatch.value! ? Icons.check_circle : Icons.cancel,
                  color: passwordsMatch.value! ? Colors.green : Colors.red,
                  size: 24,
                ),
              ),
          ],
        ),
        const SizedBox(height: 13),
        const WarningAlertComponent(
          text:
              'The wallet backup file will be encrypted with this password. You will need it only when restoring the wallet.',
        ),
      ],
    );
  }
}
