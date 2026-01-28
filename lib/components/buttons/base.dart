import 'package:flutter/material.dart';
import 'package:wallet/styling.dart';
import 'package:wallet/utils/material_state.dart';

typedef ButtonCallback = void Function()?;

abstract class GButtonBase extends StatelessWidget {
  const GButtonBase({
    this.onPressed,
    this.onLongPress,
    super.key,
  });

  final ButtonCallback onPressed;
  final ButtonCallback? onLongPress;

  double get height;

  double get width => double.infinity;

  Widget body(BuildContext context);

  Color get backgroundColor =>
      onPressed != null ? GColors.white : GColors.white.withValues(alpha: 0.6);

  BorderSide get border => BorderSide.none;

  BorderSide get focusedBorder => BorderSide.none;

  double get elevation => 0;

  ButtonStyle get _style => ButtonStyle(
        backgroundColor: MaterialStateProperty.all(backgroundColor),
        shadowColor: MaterialStateProperty.all(border.color),
        elevation: MaterialStateProperty.all(elevation),
        shape: MaterialStateProperty.resolveWith(
          (states) {
            var radius = 16.0;
            var border = this.border;
            final active = <MaterialState>[
              MaterialState.hovered,
              MaterialState.selected,
              MaterialState.focused,
              MaterialState.pressed,
            ];
            if (states.containsOne(active)) {
              radius = 22.0;
              border = focusedBorder;
            }
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
              side: border,
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: height,
      width: width,
      child: TextButton(
        style: _style,
        onPressed: onPressed,
        onLongPress: onLongPress,
        child: body(context),
      ),
    );

    return button;
  }
}
