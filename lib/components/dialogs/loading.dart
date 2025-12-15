import 'package:flutter/material.dart';
import 'package:wallet/components/dialogs/_generic.dart';
import 'package:wallet/styling.dart';

void showLoadingDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.6),
    context: context,
    builder: (BuildContext context) {
      return GenericDialog(
        backgroundColor: GColors.white.withOpacity(0.2),
        borderColor: GColors.white.withOpacity(0.8),
        autoDismiss: null,
        dismissible: false,
        child: const SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(
            color: GColors.white,
          ),
        ),
      );
    },
  );
}
