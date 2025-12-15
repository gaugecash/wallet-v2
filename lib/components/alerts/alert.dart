import 'package:flutter/material.dart';
import 'package:wallet/styling.dart';

abstract class AlertComponent extends StatelessWidget {
  const AlertComponent({required this.text, super.key});

  final String text;

  Color get bgColor;

  Color get borderColor;

  Color get textColor;

  IconData get icon;

  CrossAxisAlignment get alignment => CrossAxisAlignment.start;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: alignment,
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style: GTextStyles.mulishBoldAlert.copyWith(color: textColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
