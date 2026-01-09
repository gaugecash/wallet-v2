import 'package:flutter/material.dart';

class GTextStyles {
  // Display & Headings - Bodoni Moda
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'BodoniModa',
    fontWeight: FontWeight.w800,
    fontStyle: FontStyle.italic,
    fontSize: 32,
    color: GColors.white,
    letterSpacing: -0.03,
    height: 0.95,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: 'BodoniModa',
    fontWeight: FontWeight.w700,
    fontSize: 28,
    color: GColors.white,
    letterSpacing: -0.02,
    height: 1.0,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'BodoniModa',
    fontWeight: FontWeight.w700,
    fontSize: 24,
    color: GColors.white,
    letterSpacing: -0.02,
    height: 1.0,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: 'BodoniModa',
    fontWeight: FontWeight.w600,
    fontSize: 20,
    color: GColors.white,
    letterSpacing: -0.01,
  );

  // Body & UI - Space Grotesk
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w300,
    fontSize: 18,
    color: GColors.white,
    letterSpacing: 0.02,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w300,
    fontSize: 16,
    color: GColors.white,
    letterSpacing: 0.02,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w300,
    fontSize: 14,
    color: GColors.white,
    letterSpacing: 0.02,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w500,
    fontSize: 18,
    color: GColors.abyssDeep, // Button text usually on bright background
    letterSpacing: 0.05,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: GColors.white,
    letterSpacing: 0.05,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: GColors.roseGold,
    letterSpacing: 0.15,
  );

  // Data & Mono - JetBrains Mono
  static const TextStyle monoBold = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: GColors.white,
    letterSpacing: -0.2,
  );

  static const TextStyle monoRegular = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: GColors.white,
    letterSpacing: -0.2,
  );

  // Legacy mappings to prevent build errors during transition
  // We map old style names to new design tokens
  static const TextStyle mulishBlackDisplay = displayLarge;
  static const TextStyle mulishBlackHeading = h1;
  static const TextStyle mulishText = bodyLarge;
  static const TextStyle mulishMedium = bodyMedium;
  static const TextStyle mulishLight = bodySmall;
  static const TextStyle mulishBoldAlert = bodyMedium;
  static const TextStyle mulishVersionText = label;
  
  static const TextStyle poppinsBoldButton = buttonLarge;
  static const TextStyle poppinsMediumButton = buttonMedium;
  
  static const TextStyle chivoLightLogo = h2;
  static const TextStyle chivoRegularCurrency = bodyMedium;
  static const TextStyle h4 = h3;
  static const TextStyle monoLight = monoRegular;
  static const TextStyle monoTx = monoRegular;
  static const TextStyle monoAddr = monoRegular;
}

class GColors {
  // Base - The Abyss
  static const Color abyssDeep = Color(0xFF211225);
  static const Color abyssSurface = Color(0xFF2C1B30);
  static const Color obsidian = Color(0xFF251829);
  static const Color obsidianGlass = Color(0x29251829); // ~16% opacity

  // Primary - Sapphire Eclipse
  static const Color corona = Color(0xFF5A9BFF);
  static const Color coronaGlow = Color(0xFF78B2FF); // Slightly lighter
  static const Color coronaSoft = Color(0xFF4A6CD4); // Deeper violet-blue

  // Secondary - Rose Gold
  static const Color roseGold = Color(0xFFDFA879);
  static const Color roseGoldGlow = Color(0xFFE6B08A);
  
  // Functional
  static const Color prismCyan = Color(0xFF51F0F5);
  static const Color prismViolet = Color(0xFFB57FE6);
  static const Color champagne = Color(0xFFA8C5FF); // Sapphire Champagne
  static const Color redWarning = Color(0xFFEF4444); // Glow Danger
  static const Color greenSuccess = Color(0xFF10B981);

  // Legacy mappings
  static const Color white = Color(0xFFFFFFFF); // Light Pure
  static const Color blackBlueish = abyssDeep;
  static const Color backgroundScaffold = abyssDeep;
  static const Color backgroundScaffoldAccent = abyssSurface;
  static const Color cardBackground = obsidian;
  
  static const Color redWarningBorder = Color(0x4DFF4444); // 30% red
  static const Color greenSuccessBorder = Color(0x4D10B981); // 30% green
}