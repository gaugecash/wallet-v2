import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/components/inputs/primary.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/screens/set_up/components/step.dart';
import 'package:wallet/screens/set_up/restore/model.dart';
import 'package:wallet/services/wallet_backup.dart';

// todo fix keyboard appearing and breaking the canContinue workflow
class SetUpRestore1PasswordStep extends SetUpStep {
  const SetUpRestore1PasswordStep({super.key});

  @override
  int get page => 1;

  @override
  String get name => 'Enter the password to decrypt the backup file';

  @override
  Future<bool> Function(WidgetRef ref) get submit => (ref) async {
        // trying to decrypt the backup file
        final provider = ref.read(setUpRestoreProvider);

        try {
          final wallet = await WalletBackup.decrypt(
            provider.password!,
            provider.backupFile!,
          );

          final mnemonic = wallet.mnemonic;

          final walletService = ref.read(walletProvider);
          // final setupService = ref.read(setUpCreateProvider);

          // final backup = await WalletBackup.generate(mnemonic);

          await walletService.saveMnemonic(mnemonic);
          await walletService.saveBackupWallet(provider.backupFile!);

          return true;
        } catch (e) {
          logger.e(e);
          return false;
        }
      };

  bool validate(String password) {
    if (password.isEmpty) {
      return false;
    }

    return true;
  }

  void listener(TextEditingController controller, WidgetRef ref) {
    final provider = ref.read(setUpRestoreProvider);

    if (provider.currentPage != page) {
      logger.i('page changed');
      return;
    }

    final password = controller.text;

    final validation = validate(password);
    provider.canContinue = validation;
    provider.password = password;
  }

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    final password = useTextEditingController();

    useEffect(() {
      void localListener() => listener(password, ref);
      password.addListener(localListener);
      return () => password.removeListener(localListener);
    }, [password],);

    return Column(
      children: [
        GPrimaryInput(
          controller: password,
          label: 'Password',
          obscureText: true,
        ),
      ],
    );
  }
}
