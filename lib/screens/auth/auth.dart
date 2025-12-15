import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/layouts/app_layout.dart';
import 'package:wallet/providers/auth.dart';
import 'package:wallet/screens/auth/auth_methods/local_auth.dart';
import 'package:wallet/screens/auth/auth_methods/pin_code.dart';

@RoutePage()
class AuthScreen extends HookConsumerWidget {
  const AuthScreen({super.key});

  Widget getAuthScreen(AuthProvider auth) {
    switch (auth.method) {
      case AuthMethod.pinCode:
        return const AuthPinCodeComponent();
      case AuthMethod.localAuth:
        return const AuthLocalAuthComponent();
      default:
        throw Exception('Unknown AuthMethod');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(authProvider);
    return AppLayout(
      child: getAuthScreen(provider),
    );
  }
}
