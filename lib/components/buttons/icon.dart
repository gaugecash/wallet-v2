import 'package:flutter/material.dart';
import 'package:wallet/components/buttons/base.dart';
import 'package:wallet/styling.dart';

class GIconButton extends GButtonBase {
  const GIconButton({
    required this.icon,
    this.size = 48,
    super.onPressed,
  });

  final IconData icon;
  final double size;

  @override
  Widget body(BuildContext context) {
    return Icon(
      icon,
      color: GColors.white,
      size: 20,
    );
  }

  @override
  double get height => size;

  @override
  double get width => size;

  @override
  Color get backgroundColor => Colors.transparent;

  @override
  BorderSide get border => BorderSide(
        color: GColors.white.withOpacity(0.6),
        width: 2,
      );

  @override
  BorderSide get focusedBorder => BorderSide(
        color: GColors.white.withOpacity(0.8),
        width: 2.8,
      );
}
