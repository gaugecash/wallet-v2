import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/components/dialogs/_generic.dart';
import 'package:wallet/styling.dart';

void showErrorDialog(BuildContext context, String? message) {
  showDialog(
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.6),
    context: context,
    builder: (BuildContext context) {
      return GenericDialog(
        backgroundColor: GColors.redWarning.withOpacity(0.2),
        borderColor: GColors.redWarningBorder.withOpacity(0.8),
        autoDismiss: const Duration(milliseconds: 1200),
        dismissible: true,
        child: SizedBox(
          width: 120,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.x,
                color: GColors.white,
                size: 36,
              ),
              const SizedBox(height: 6),
              Text(
                message ?? 'Error',
                style: GTextStyles.mulishBoldAlert,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    },
  );
}
