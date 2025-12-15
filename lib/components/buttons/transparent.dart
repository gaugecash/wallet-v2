import 'package:flutter/material.dart';
import 'package:wallet/components/buttons/base.dart';

class GTransparentButton extends StatelessWidget {
  const GTransparentButton({
    required this.child,
    this.onPressed,
    super.key,
  });

  final Widget child;
  final ButtonCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: const Size(0, 20),
      ),
      child: child,
    );
  }
}
