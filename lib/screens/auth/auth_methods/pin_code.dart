import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:wallet/components/animations/shake.dart';
import 'package:wallet/providers/auth.dart';
import 'package:wallet/styling.dart';

class AuthPinCodeComponent extends HookConsumerWidget {
  const AuthPinCodeComponent({super.key});

  TextStyle get pinTextStyle => GTextStyles.mulishBoldAlert;

  double get size => 56;

  // TODO(critical): fix `autofocus` on web from iOS | impossible to progress to next screen
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinController = useTextEditingController();
    final provider = ref.read(authProvider);
    final controller = useMemoized(() => ShakeAnimationController());

    // todo as a component to avoid duplication
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        const SizedBox(width: double.infinity),
        const Text(
          'Enter your PIN to continue',
          style: GTextStyles.mulishBlackDisplay,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),
        ShakeAnimation(
          controller: controller,
          animationRange: 35,
          animationDuration: const Duration(milliseconds: 300),
          child: Pinput(
            controller: pinController,
            autofocus: true,
            obscureText: true,
            onCompleted: (pin) {
              final code = pinController.text;
              final res = provider.verifyPinCode(code);
              if (res) {
                context.router.replaceNamed('/');
              } else {
                controller.shake();
                pinController.clear();
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
                  color: GColors.white.withValues(alpha: 0.4),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: pinTextStyle,
            ),
          ),
        ),
        const Spacer(),
        const Spacer(),
        const Spacer(),
      ],
    );
  }
}
