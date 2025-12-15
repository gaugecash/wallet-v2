import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/components/alerts/alert.dart';
import 'package:wallet/styling.dart';

class WarningAlertComponent extends AlertComponent {
  const WarningAlertComponent({required super.text, super.key});

  @override
  Color get bgColor => GColors.redWarning.withOpacity(0.8);

  @override
  Color get borderColor => GColors.redWarningBorder.withOpacity(0.9);

  @override
  Color get textColor => GColors.white;

  @override
  IconData get icon => LucideIcons.alertOctagon;
}
