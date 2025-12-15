import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/components/alerts/alert.dart';
import 'package:wallet/styling.dart';

class InfoAlertComponent extends AlertComponent {
  const InfoAlertComponent({required super.text, super.key});

  @override
  Color get bgColor => GColors.white.withOpacity(0.2);

  @override
  Color get borderColor => GColors.white.withOpacity(0.6);

  @override
  Color get textColor => GColors.white;

  @override
  IconData get icon => LucideIcons.info;
}
