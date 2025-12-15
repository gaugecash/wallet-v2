import 'dart:math';

import 'package:flutter/material.dart';

class GSliverWithMinHeight extends StatelessWidget {
  const GSliverWithMinHeight({
    required this.child,
    required this.minHeight,
    super.key,
  });

  final Widget child;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.remainingPaintExtent;
        return SliverToBoxAdapter(
          child: SizedBox(
            height: max(minHeight, h),
            child: child,
          ),
        );
      },
    );
  }
}
