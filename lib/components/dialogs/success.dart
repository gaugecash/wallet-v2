import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/components/dialogs/_generic.dart';
import 'package:wallet/styling.dart';

void showSuccessDialog(
  BuildContext context, {
  String? message,
  bool autoDismiss = true,
}) {
  showDialog(
    barrierColor: Colors.black.withOpacity(0.6),
    context: context,
    builder: (BuildContext context) {
      return GenericDialog(
        backgroundColor: GColors.greenSuccess.withOpacity(0.2),
        borderColor: GColors.greenSuccessBorder.withOpacity(0.8),
        autoDismiss: autoDismiss ? const Duration(milliseconds: 800) : null,
        dismissible: true,
        child: message == null
            ? const SizedBox(
                height: 40,
                width: 40,
                child: Icon(
                  LucideIcons.check,
                  color: GColors.white,
                  size: 36,
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.check,
                    color: GColors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  Text(message, style: GTextStyles.mulishBoldAlert),
                ],
              ),
      );
    },
  );
}
