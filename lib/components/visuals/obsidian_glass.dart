import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:wallet/styling.dart';

class ObsidianGlass extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  const ObsidianGlass({
    Key? key,
    required this.child,
    this.blur = 40.0, // Matches website CSS blur(40px)
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        // Subtle border "Light Edge"
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
        // Obsidian gradient background with opacity
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GColors.obsidian.withOpacity(0.8),
            GColors.obsidian.withOpacity(0.4),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
