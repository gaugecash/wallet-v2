import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/providers/auth.dart';
import 'package:wallet/screens/set_up/create/model.dart';
import 'package:wallet/styling.dart';

abstract class SetUpStep extends HookConsumerWidget {
  const SetUpStep({
    super.key,
  });

  int get page;

  String get name;

  // todo: return error message if something is wrong
  Future<bool> Function(WidgetRef ref) get submit;

  // todo call the provider directly
  @Deprecated('is is not really needed')
  void setCanSubmit(WidgetRef ref, bool state) {
    ref.read(setUpCreateProvider.notifier).canContinue = state;
  }

  Widget buildContent(BuildContext context, WidgetRef ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useAutomaticKeepAlive();

    var name = this.name;
    if (page == 2) {
      name = ref.read(authProvider).setUpTitle;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: GTextStyles.mulishBlackHeading),
          const SizedBox(height: 34),
          buildContent(context, ref),
        ],
      ),
    );
  }
}
