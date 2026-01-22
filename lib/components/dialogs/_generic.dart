import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wallet/components/slivers/spacing.dart';

class GenericDialog extends HookWidget {
  const GenericDialog({
    required this.child,
    required this.backgroundColor,
    required this.borderColor,
    required this.autoDismiss,
    required this.dismissible,
    super.key,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Widget child;
  final Duration? autoDismiss;
  final bool dismissible;

  @override
  Widget build(BuildContext context) {
    useEffect(
      () {
        if (autoDismiss == null) {
          return null;
        }

        Future.delayed(autoDismiss!, () {
          if (context.mounted) {
            final route = ModalRoute.of(context);
            if (route != null && route.isCurrent) {
              Navigator.of(context).pop();
            }
          }
        });

        return null;
      },
      [],
    );

    return PopScope(
      canPop: dismissible,
      child: GestureDetector(
        onTap: () {
          if (dismissible) {
            Navigator.pop(context);
          }
        },
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Material(
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: backgroundColor,
                    border: Border.all(
                      color: borderColor,
                      width: 2,
                    ),
                  ),
                  padding: EdgeInsets.all(GPaddings.big(context)),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
