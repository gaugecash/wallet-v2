import 'package:flutter/material.dart';
import 'package:wallet/components/buttons/base.dart';
import 'package:wallet/styling.dart';

class GWalletActionButton extends GButtonBase {
  const GWalletActionButton({
    required this.label,
    required this.icon,
    super.onPressed,
  });

  final String label;
  final IconData icon;

  @override
  Widget body(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final text = Text(label, style: GTextStyles.poppinsMediumButton);
        final ic = Icon(icon, color: GColors.white);
        final w = constraints.biggest.width;

        if (w < 66) {
          return ic;
        }

        if (w < 100) {
          return text;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ic,
            const SizedBox(width: 10),
            text,
          ],
        );
      },
    );
  }

  @override
  double get height => 48;

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
