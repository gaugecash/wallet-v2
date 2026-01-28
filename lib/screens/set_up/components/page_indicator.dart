import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:wallet/styling.dart';

class DPageIndicator extends StatelessWidget {
  const DPageIndicator(this.pageController, {this.steps = 3, super.key});

  final PageController pageController;
  final int steps;
  static const spacing = 14.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final spacingTotal = spacing * (steps - 1);
        final width = (constraints.maxWidth - spacingTotal) / steps;

        return SmoothPageIndicator(
          controller: pageController, // PageController
          count: steps,
          effect: SlideEffect(
            spacing: spacing,
            radius: 6,
            dotWidth: width,
            dotHeight: 10,
            dotColor: GColors.white.withValues(alpha: 0.4),
            activeDotColor: GColors.white,
          ),
        );
      },
    );
  }
}
