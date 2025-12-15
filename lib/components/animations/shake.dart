import 'package:flutter/material.dart';

// adapted from https://stackoverflow.com/a/65121843
class ShakeAnimation extends StatefulWidget {
  const ShakeAnimation({
    super.key,
    required this.child,
    this.animationRange = 24,
    this.controller,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  final Widget child;

  final double animationRange;
  final ShakeAnimationController? controller;
  final Duration animationDuration;

  @override
  _ShakeAnimationState createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    animationController =
        AnimationController(duration: widget.animationDuration, vsync: this);

    widget.controller?.state = this;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final offsetAnimation = Tween(begin: 0.0, end: widget.animationRange)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(animationController)
      ..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed) {
            animationController.reverse();
          }
        },
      );

    return AnimatedBuilder(
      animation: offsetAnimation,
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(offsetAnimation.value, 0),
          child: child,
        );
      },
    );
  }
}

class ShakeAnimationController {
  late _ShakeAnimationState _state;

  set state(_ShakeAnimationState state) {
    _state = state;
  }

  Future<void> shake() {
    return _state.animationController.forward(from: 0.0);
  }
}
