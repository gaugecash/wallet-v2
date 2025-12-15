import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/components/buttons/secondary.dart';
import 'package:wallet/components/dialogs/loading.dart';
import 'package:wallet/providers/auth.dart';
import 'package:wallet/styling.dart';

class AuthLocalAuthComponent extends HookConsumerWidget {
  const AuthLocalAuthComponent({super.key});

  TextStyle get pinTextStyle => GTextStyles.mulishBoldAlert;

  double get size => 56;

  Future<bool> tryToAuth(BuildContext context, AuthProvider provider) async {
    await Future.delayed(Duration.zero);
    showLoadingDialog(context);
    final result = await provider.useLocalAuth();
    await Future.delayed(Duration.zero);
    Navigator.pop(context);
    if (result) {
      context.router.replaceNamed('/');
    }
    return result;
  }

  // TODO(critical): fix `autofocus` on web from iOS | impossible to progress to next screen
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(authProvider);
    final tryAgain = useState(false);

    useEffect(
      () {
        () async {
          final l = await tryToAuth(context, provider);
          if (!l) {
            tryAgain.value = true;
          }
        }();

        return null;
      },
      [],
    );

    // todo as a component to avoid duplication
    return Column(
      children: [
        const Spacer(),
        const SizedBox(width: double.infinity),
        const Text(
          'Authenticate using biometrics to continue',
          style: GTextStyles.mulishBlackDisplay,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),
        if (tryAgain.value)
          GSecondaryButton(
            label: 'Try again',
            onPressed: () {
              tryToAuth(context, provider);
            },
          ),
        const Spacer(),
        const Spacer(),
        const Spacer(),
      ],
    );
  }
}
