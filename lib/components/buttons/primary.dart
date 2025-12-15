import 'package:flutter/material.dart';
import 'package:wallet/components/buttons/_sizes.dart';
import 'package:wallet/components/buttons/base.dart';
import 'package:wallet/styling.dart';

class GPrimaryButton extends GButtonBase {
  const GPrimaryButton({
    required this.label,
    this.size = GButtonSize.medium,
    super.onPressed,
    super.onLongPress,
    super.key,
  });

  final String label;
  final GButtonSize size;

  @override
  Widget body(BuildContext context) =>
      Text(label, style: GTextStyles.poppinsBoldButton);

  @override
  double get height => size.size;
}
