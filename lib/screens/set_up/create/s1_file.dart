import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/components/alerts/warning_alert.dart';
import 'package:wallet/components/buttons/secondary.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/screens/set_up/components/step.dart';
import 'package:wallet/screens/set_up/create/model.dart';
import 'package:wallet/services/share_file.dart';

class SetUpCreate1FileStep extends SetUpStep {
  const SetUpCreate1FileStep({super.key});

  @override
  int get page => 1;

  @override
  String get name => 'Save this file somewhere secure';

  @override
  Future<bool> Function(WidgetRef ref) get submit => (ref) async {
        return true;
      };

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    final file = ref.read(walletProvider).getBackupWallet()!;
    return Column(
      children: [
        GSecondaryButton(
          label: 'Download file',
          onPressed: () {
            shareFile(file, context);
            ref.read(setUpCreateProvider.notifier).canContinue = true;
          },
        ),
        const SizedBox(height: 26 + 13),
        const WarningAlertComponent(
          text:
              'This file is the only way to recover your wallet in case you lose your device or delete the app.',
        ),
      ],
    );
  }
}
