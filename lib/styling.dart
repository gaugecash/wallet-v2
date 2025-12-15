import 'package:flutter/material.dart';

class GTextStyles {
  static const TextStyle chivoLightLogo = TextStyle(
    fontFamily: 'Chivo',
    fontWeight: FontWeight.w300,
    fontSize: 24,
    color: GColors.white,
    letterSpacing: 0.6,
  );

  static const TextStyle chivoRegularCurrency = TextStyle(
    fontFamily: 'Chivo',
    fontWeight: FontWeight.w500,
    fontSize: 17,
    color: GColors.white,
    letterSpacing: 0.4,
  );

  static const TextStyle mulishBlackDisplay = TextStyle(
    fontFamily: 'Mulish',
    fontWeight: FontWeight.w900,
    fontSize: 20,
    color: GColors.white,
    letterSpacing: 0.4,
  );

  static const TextStyle mulishMedium = TextStyle(
    fontFamily: 'Mulish',
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: GColors.white,
    letterSpacing: 0.4,
  );

  static const TextStyle mulishText = TextStyle(
    fontFamily: 'Mulish',
    fontWeight: FontWeight.w500,
    fontSize: 20,
    color: GColors.white,
    letterSpacing: 0.4,
  );

  static const TextStyle mulishBlackHeading = TextStyle(
    fontFamily: 'Mulish',
    fontWeight: FontWeight.w900,
    fontSize: 34,
    color: GColors.white,
    letterSpacing: 0.6,
  );

  static const TextStyle mulishBoldAlert = TextStyle(
    fontFamily: 'Mulish',
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: GColors.white,
  );

  static const TextStyle poppinsBoldButton = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: GColors.blackBlueish,
  );

  static const TextStyle poppinsMediumButton = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: GColors.white,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w700,
    fontSize: 32,
    color: GColors.white,
  );

  // todo configure the right font weight
  static const TextStyle h2 = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 26,
    color: GColors.white,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: 'Mulish',
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: GColors.white,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: 'Mulish',
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: GColors.white,
  );

  static const TextStyle monoLight = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontWeight: FontWeight.w300,
    fontSize: 14,
    color: GColors.white,
    letterSpacing: -0.4,
  );

  static const TextStyle monoAddr = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontWeight: FontWeight.w400,
    // fontSize: 13,
    color: GColors.white,
    letterSpacing: -0.4,
  );

  static const TextStyle mulishLight = TextStyle(
    fontFamily: 'Mulish',
    fontWeight: FontWeight.w200,
    fontSize: 14,
    color: GColors.white,
    // letterSpacing: -0.4,
  );

  static const TextStyle mulishVersionText = TextStyle(
    fontFamily: 'Mulish',
    fontWeight: FontWeight.w400,
    fontSize: 13,
    color: GColors.white,
    // letterSpacing: -0.4,
  );

  static const TextStyle monoBold = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: GColors.white,
    letterSpacing: -0.2,
  );

  static const TextStyle monoTx = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: GColors.white,
    letterSpacing: -0.2,
  );
}

class GColors {
  static const Color white = Color(0xFFEEEEEE);
  static const Color blackBlueish = Color(0xFF310B5C);
  static const Color backgroundScaffold = Color(0xFF140025);
  static const Color backgroundScaffoldAccent = Color(0xFF6100FF);
  static const Color redWarning = Color(0xFFBA5353);
  static const Color redWarningBorder = Color(0xFFFFCECE);
  static const Color cardBackground = Color(0xFF310B5C);
  static const Color greenSuccess = Color(0xFF00c853);
  static const Color greenSuccessBorder = Color(0xFFc8e6c9);
}
