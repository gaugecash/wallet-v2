import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/providers/auth.dart';
import 'package:wallet/screens/set_up/auth_methods/local_auth.dart';
import 'package:wallet/screens/set_up/auth_methods/pin_code.dart';

class SetUpAuthMethodWrapper extends HookConsumerWidget {
  const SetUpAuthMethodWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authProvider);
    switch (auth.method) {
      case AuthMethod.pinCode:
        return const SetUpPinCodeAuth();
      case AuthMethod.localAuth:
        return const SetUpLocalAuth();
    }
  }
}
