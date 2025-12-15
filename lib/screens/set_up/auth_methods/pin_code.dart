import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:wallet/providers/auth.dart';
import 'package:wallet/screens/set_up/create/model.dart';
import 'package:wallet/screens/set_up/restore/model.dart';
import 'package:wallet/styling.dart';

class SetUpPinCodeAuth extends HookConsumerWidget {
  const SetUpPinCodeAuth({super.key});

  TextStyle get titleStyle => GTextStyles.mulishBoldAlert;

  TextStyle get pinTextStyle => GTextStyles.mulishBoldAlert;

  double get size => 56;

  // TODO(critical): fix `autofocus` on web from iOS | impossible to progress to next screen
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinController = useTextEditingController();
    final pin1 = useState<String?>(null);
    final done = useState<bool>(false);

    return Column(
      children: [
        const SizedBox(width: double.infinity),
        if (pin1.value == null)
          Text(
            'Come up with a 4 digit code',
            style: titleStyle,
          ),
        if (pin1.value != null && done.value == false)
          Text(
            'Repeat the code',
            style: titleStyle,
          ),
        if (done.value == true)
          Text(
            'The code was set successfully',
            style: titleStyle,
          ),
        const SizedBox(height: 20),
        if (done.value == false)
          // todo show error when retyped password is not the same
          // todo this is really messy, maybe use a stateful widget (?)
          Pinput(
            controller: pinController,
            autofocus: true,
            obscureText: true,
            onCompleted: (pin) {
              if (pin1.value == null) {
                pin1.value = pin;
                pinController.text = '';
              } else {
                if (pin1.value != pin) {
                  pin1.value = null;
                  pinController.text = '';
                  return;
                }
                done.value = true;

                ref.read(authProvider).setPinCode(pin1.value!);
                //todo use a proper provider (not critical though)
                ref.read(setUpCreateProvider).canContinue = true;
                ref.read(setUpRestoreProvider).canContinue = true;
              }
            },
            showCursor: false,
            focusedPinTheme: PinTheme(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GColors.white, width: 2),
              ),
              textStyle: pinTextStyle,
            ),
            submittedPinTheme: PinTheme(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              height: size,
              width: size,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: GColors.white,
                  width: 1.4,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: pinTextStyle,
            ),
            defaultPinTheme: PinTheme(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              height: size,
              width: size,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: GColors.white.withOpacity(0.4),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: pinTextStyle,
            ),
          ),
      ],
    );
  }
}
