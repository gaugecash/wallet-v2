import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/components/buttons/secondary.dart';
import 'package:wallet/components/dialogs/error.dart';
import 'package:wallet/components/dialogs/loading.dart';
import 'package:wallet/components/dialogs/success.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/screens/set_up/components/step.dart';
import 'package:wallet/screens/set_up/restore/model.dart';
import 'package:wallet/services/wallet_backup.dart';
import 'package:wallet/styling.dart';

// todo display status that the file is uploaded OR errors
// todo(critical) support drag and drop
class SetUpRestore0FileStep extends SetUpStep {
  const SetUpRestore0FileStep({super.key});

  @override
  int get page => 0;

  @override
  String get name => 'Upload the Gaugecash Wallet backup file';

  @override
  Future<bool> Function(WidgetRef ref) get submit => (ref) async {
        return true;
      };

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    final done = useState<bool>(false);

    return Column(
      children: [
        if(done.value)
          const Center(
            child: Text(
              'The file was selected successfully',
              style: GTextStyles.mulishBoldAlert,
            ),
          ),
        if(!done.value)
        GSecondaryButton(
          label: 'Select the backup file',
          onPressed: () async {
            showLoadingDialog(context);
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['txt'],
              withData: true,
            );

            Navigator.pop(context);

            if (result == null || result.files.length != 1) {
              showErrorDialog(context, 'No file selected');
              return;
            }

            final file = result.files[0].bytes;

            if (file == null) {
              showErrorDialog(context, 'No file selected');
              return;
            }

            late String contents;
            try {
              contents = utf8.decode(file);
            } catch (e) {
              showErrorDialog(context, 'Unable to decode');
              return;
            }

            if (WalletBackup.validate(contents)) {
              logger.i('Success');
              done.value = true;

              showSuccessDialog(context);
              ref.read(setUpRestoreProvider).backupFile = contents;
              ref.read(setUpRestoreProvider).canContinue = true;
            } else {
              showErrorDialog(context, 'Invalid backup file');
            }
          },
        ),
        const SizedBox(height: 26 + 13),
      ],
    );
  }
}
