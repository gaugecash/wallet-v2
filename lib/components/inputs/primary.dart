import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wallet/styling.dart';

class GPrimaryInput extends HookWidget {
  const GPrimaryInput({
    required this.label,
    this.controller,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.onChanged,
    this.disabled = false,
    // this.formatters,
    this.currency = false,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final bool disabled;
  // final List<TextInputFormatter>? formatters;

  /// filter & comma -> dot replacement
  final bool currency;

  InputBorder get _getBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: GColors.white.withValues(alpha: disabled ? 0.4 : 0.6),
          width: 2,
        ),
      );

  InputBorder get _getFocusedBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: GColors.white,
          width: 2,
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (currency && controller != null) {
      useEffect(() {
        controller!.addListener(() {
          if (controller!.text.contains(',')) {
            final selection = controller!.selection;
            controller!.text = controller!.text.replaceAll(',', '.');
            controller!.selection = selection;
          }
        });

        return null;
      });
    }

    return TextField(
      keyboardAppearance: Brightness.dark,
      enabled: !disabled,
      onChanged: onChanged,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        border: _getBorder,
        enabledBorder: _getBorder,
        focusedBorder: _getFocusedBorder,
        disabledBorder: _getBorder,
        labelText: label,
        labelStyle: GTextStyles.poppinsMediumButton.copyWith(
          color: disabled ? GColors.white.withValues(alpha: 0.6) : GColors.white,
        ),
        suffixIcon: suffix,
      ),
      style: GTextStyles.poppinsMediumButton,
      inputFormatters: currency
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
          : [],
    );
  }
}
