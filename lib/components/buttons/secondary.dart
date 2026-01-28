import 'package:flutter/material.dart';
import 'package:wallet/components/buttons/_sizes.dart';
import 'package:wallet/components/buttons/base.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/styling.dart';

class GSecondaryButton extends GButtonBase {
  const GSecondaryButton({
    required this.label,
    this.size = GButtonSize.medium,
    this.icon,
    super.onPressed,
  });

  final String label;
  final GButtonSize size;
  final IconData? icon;

  @override
  Widget body(BuildContext context) => icon == null
      ? Text(label, style: GTextStyles.poppinsMediumButton)
      : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: GTextStyles.poppinsMediumButton),
            SizedBox(width: GPaddings.tiny(context)),
            Icon(icon, color: GColors.white),
          ],
        );

  @override
  Color get backgroundColor => Colors.transparent;

  @override
  BorderSide get border => BorderSide(
        color:
            onPressed != null ? GColors.white : GColors.white.withValues(alpha: 0.2),
        width: 2,
      );

  @override
  BorderSide get focusedBorder => BorderSide(
        color:
            onPressed != null ? GColors.white : GColors.white.withValues(alpha: 0.2),
        width: 2.8,
      );

  @override
  double get height => size.size;
}
