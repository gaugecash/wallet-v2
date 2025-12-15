import 'package:flutter/material.dart';
import 'package:wallet/conf.dart';

abstract class GPaddings {
  static double layoutVerticalPadding(BuildContext context) {
    final breakpoint = MediaQuery.of(context).size.width > breakPointWidth;

    return breakpoint ? 28 + 34 : 28;
  }

  static double layoutHorizontalPadding() {
    return 26;
  }

  static double tiny(BuildContext context) {
    final breakpoint = MediaQuery.of(context).size.width > breakPointWidth;
    return breakpoint ? 10 : 6;
  }

  static double small(BuildContext context) {
    final breakpoint = MediaQuery.of(context).size.width > breakPointWidth;
    return breakpoint ? 14 : 12;
  }

  @Deprecated('Use sliver right away instead')
  static double medium(BuildContext context) {
    final breakpoint = MediaQuery.of(context).size.width > breakPointWidth;
    return breakpoint ? 20 : 16;
  }

  static double big(BuildContext context) {
    final breakpoint = MediaQuery.of(context).size.width > breakPointWidth;
    return breakpoint ? 26 : 20;
  }
}

class GPaddingsLayoutHorizontal extends StatelessWidget {
  const GPaddingsLayoutHorizontal({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final padding = GPaddings.layoutHorizontalPadding();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: child,
    );
  }

  @Deprecated('refactor to a separate widget for performance')
  static Widget sliver({required Widget child, Key? key}) {
    return SliverToBoxAdapter(
      child: GPaddingsLayoutHorizontal(key: key, child: child),
    );
  }
}
