import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/layouts/app_layout_sliver.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/screens/currency/_receive.dart';
import 'package:wallet/styling.dart';

@RoutePage()
class ReceiveScreen extends HookConsumerWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppLayoutSliver(
      showBackButton: true,
      children: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: GPaddings.layoutHorizontalPadding(),
            ),
            child: Text(
              'Receive',
              style: GTextStyles.h1,
            ),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: GPaddings.layoutHorizontalPadding(),
            ),
            child: const ReceiveCurrencyTab(),
          ),
        ),
      ],
    );
  }
}
