import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:wallet/components/collections/logo_inline.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/layouts/base_sliver.dart';

class AppLayoutSliver extends StatelessWidget {
  const AppLayoutSliver({
    required this.children,
    this.showBackButton = false,
    this.suffixIcon,
    this.suffixClick,
    this.containsScrollable = false,
    super.key,
  });

  final List<Widget> children;
  final bool showBackButton;
  final IconData? suffixIcon;
  final void Function()? suffixClick;
  final bool containsScrollable;

  @override
  Widget build(BuildContext context) {
    var body = children;
    if (!containsScrollable) {
      body = [
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (!showBackButton) {
                return false;
              }
              if (notification is ScrollUpdateNotification &&
                  (notification.scrollDelta ?? 0) < -10 &&
                  notification.metrics.outOfRange) {
                context.router.maybePop();
              }
              return false;
            },
            child: CustomScrollView(
              primary: true,
              slivers: children,
            ),
          ),
        ),
      ];
    }

    return BaseLayoutSliver(
      dismissible: showBackButton,
      heading: [
        const SliverSafeArea(
          bottom: false,
          sliver: SliverToBoxAdapter(),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.layoutVerticalPadding(context))),
        GPaddingsLayoutHorizontal.sliver(
          child: LogoInlineComponent(
            showBackButton: showBackButton,
            suffixIcon: suffixIcon,
            suffixClick: suffixClick,
          ),
        ),
      ],
      children: body,
    );
  }
}
