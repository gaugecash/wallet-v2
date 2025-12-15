import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet/components/collections/logo_inline.dart';
import 'package:wallet/layouts/base.dart';

class AppLayout extends StatelessWidget {
  const AppLayout({
    required this.child,
    this.showBackButton = false,
    this.suffixIcon,
    this.suffixClick,
    super.key,
  });

  final Widget child;
  final bool showBackButton;
  final IconData? suffixIcon;
  final void Function()? suffixClick;

  @override
  Widget build(BuildContext context) {
    final column = Column(
      children: [
        LogoInlineComponent(
          showBackButton: showBackButton,
          suffixIcon: suffixIcon,
          suffixClick: suffixClick,
        ),
        Expanded(child: child),
      ],
    );
    return BaseLayout(
      child: showBackButton
          ? Dismissible(
              // onDismissed: (_) {
              //   context.router.pop();
              // },
              direction: DismissDirection.vertical,
              onUpdate: (upd) {
                if (upd.progress > 0.2) {
                  context.router.maybePop();
                }
              },
              key: const ValueKey(''),
              child: column,
            )
          : column,
    );
  }
}
