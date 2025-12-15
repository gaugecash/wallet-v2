import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/components/buttons/secondary.dart';
import 'package:wallet/components/dialogs/loading.dart';
import 'package:wallet/components/dialogs/success.dart';
import 'package:wallet/providers/auth.dart';
import 'package:wallet/screens/set_up/create/model.dart';
import 'package:wallet/screens/set_up/restore/model.dart';
import 'package:wallet/styling.dart';

class SetUpLocalAuth extends HookConsumerWidget {
  const SetUpLocalAuth({super.key});

  TextStyle get titleStyle => GTextStyles.mulishBoldAlert;

  TextStyle get pinTextStyle => GTextStyles.mulishBoldAlert;

  double get size => 56;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = useState<bool>(false);
    final auth = ref.read(authProvider);

    return Column(
      children: [
        const SizedBox(width: double.infinity),
        if (done.value)
          Text(
            'Authentication was set up successfully',
            style: titleStyle,
          ),

        if (!done.value)
          GSecondaryButton(
            label: 'Use Biometrics',
            onPressed: () async {
              showLoadingDialog(context);
              final result = await auth.useLocalAuth();
              Navigator.pop(context);

              if (result) {
                await auth.save();
                done.value = true;
                showSuccessDialog(context);
                //todo use a proper provider (not critical though)
                ref.read(setUpCreateProvider).canContinue = true;
                ref.read(setUpRestoreProvider).canContinue = true;
              }
            },
          ),
        // const Spacer(),
        // const Text('Use Pin Code instead'),
      ],
    );
  }
}
