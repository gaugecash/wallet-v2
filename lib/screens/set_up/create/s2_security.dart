import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/providers/auth.dart';
import 'package:wallet/screens/set_up/auth_methods/_wrapper.dart';
import 'package:wallet/screens/set_up/components/step.dart';

class SetUpCreate2SecurityStep extends SetUpStep {
  const SetUpCreate2SecurityStep({super.key});

  @override
  int get page => 1;

  @override
  // name is taken in the SetUpStep via ref
  // todo think of a better way to do this
  String get name => '';

  @override
  Future<bool> Function(WidgetRef ref) get submit => (ref) async {
        await ref.read(authProvider).save();
        return true;
      };

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    return const SetUpAuthMethodWrapper();
  }
}
