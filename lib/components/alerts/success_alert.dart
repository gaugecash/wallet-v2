import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/components/alerts/alert.dart';
import 'package:wallet/styling.dart';

class SuccessAlertComponent extends AlertComponent {
  const SuccessAlertComponent({required super.text, super.key});

  @override
  Color get bgColor => GColors.greenSuccess.withOpacity(0.1);

  @override
  Color get borderColor => GColors.greenSuccessBorder.withOpacity(0.4);

  @override
  Color get textColor => GColors.white;

  @override
  IconData get icon => LucideIcons.check;

  // @override
  // CrossAxisAlignment get alignment => CrossAxisAlignment.center;
}
