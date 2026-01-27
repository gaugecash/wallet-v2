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
  String get name => 'Create your password';

  // Store context for use in submit function (needed for SnackBar feedback)
  BuildContext? _currentContext;

  @override
  Future<bool> Function(WidgetRef ref) get submit => (ref) async {
        final setupService = ref.read(setUpCreateProvider);

        // Check if we're on step 1 - if so, advance to step 2
        if (setupService.passwordStep == 1) {
          setupService.passwordStep = 2;
          setupService.canContinue = false; // Disable button until passwords match
          return false; // Don't proceed to next page yet
        }

        // Step 2: Actually create the wallet
        developer.log('PASSWORD STEP 1: Starting wallet creation', name: 'GAUwallet');
        final walletService = ref.read(walletProvider);

        developer.log('PASSWORD STEP 2: Computing random mnemonic', name: 'GAUwallet');
        final mnemonic = await computeRandomMnemonic();
        developer.log('PASSWORD STEP 3: Mnemonic generated, creating backup', name: 'GAUwallet');

        final backup = await WalletBackup.generate(mnemonic);
        developer.log('PASSWORD STEP 4: Backup created', name: 'GAUwallet');

        final encryptedFile = await backup.encrypt(setupService.password!);
        developer.log('PASSWORD STEP 5: Backup encrypted', name: 'GAUwallet');

        await walletService.saveMnemonic(mnemonic);
        developer.log('PASSWORD STEP 6: Mnemonic saved', name: 'GAUwallet');

        await walletService.saveBackupWallet(encryptedFile);
        developer.log('PASSWORD STEP 7: Backup saved to Hive', name: 'GAUwallet');

        backup.autoSave(setupService.password!, context: _currentContext);
        developer.log('PASSWORD STEP 8: Wallet creation complete, auto-save triggered', name: 'GAUwallet');

        return true;
      };

  bool validateStep1(String p1) {
    return p1.isNotEmpty;
  }

  bool validateStep2(String p1, String p2) {
    return p2.isNotEmpty && p1 == p2;
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

    if (provider.passwordStep == 1) {
      // Step 1: Validate first password input
      final validation = validateStep1(p1);
      setCanSubmit(ref, validation);
    } else {
      // Step 2: Validate passwords match
      final validation = validateStep2(p1, p2);
      setCanSubmit(ref, validation);
      provider.password = p1;
    }
  }

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    // Store context for use in submit function (enables SnackBar feedback)
    _currentContext = context;

    final password = useTextEditingController();
    final passwordRepeat = useTextEditingController();
    final provider = ref.watch(setUpCreateProvider);
    final passwordsMatch = useState<bool?>(null);

    useEffect(() {
      void localListener() => listener(password, passwordRepeat, ref);
      password.addListener(localListener);
      passwordRepeat.addListener(localListener);
      return () {
        password.removeListener(localListener);
        passwordRepeat.removeListener(localListener);
      };
    }, [password, passwordRepeat],);

    // Check password match for visual feedback in step 2
    useEffect(() {
      if (provider.passwordStep == 2 && passwordRepeat.text.isNotEmpty) {
        passwordsMatch.value = password.text == passwordRepeat.text;
      } else {
        passwordsMatch.value = null;
      }
      return null;
    }, [passwordRepeat.text, provider.passwordStep]);

    if (provider.passwordStep == 1) {
      // Step 1: Create password
      return Column(
        children: [
          GPrimaryInput(
            controller: password,
            label: 'Password',
            obscureText: true,
          ),
          const SizedBox(height: 8),
          Text(
            'We recommend at least 8 characters for better security',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 18 + 13),
          const WarningAlertComponent(
            text:
                'The wallet backup file will be encrypted with this password. You will need it only when restoring the wallet.',
          ),
        ],
      );
    } else {
      // Step 2: Confirm password
      return Column(
        children: [
          Stack(
            alignment: Alignment.centerRight,
            children: [
              GPrimaryInput(
                controller: passwordRepeat,
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
        ],
      );
    }
  }
}
