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
    final mounted = useIsMounted();
    useEffect(
      () {
        if (autoDismiss == null) {
          return;
        }

        Future.delayed(autoDismiss!, () {
          if (mounted() &&
              ModalRoute.of(context) != null &&
              ModalRoute.of(context)!.isCurrent) {
            Navigator.of(context).pop();
          }
        });

        return null;
      },
      [],
    );

    return WillPopScope(
      onWillPop: () => Future.value(dismissible),
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
