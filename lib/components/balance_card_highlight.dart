import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:wallet/styling.dart';

class HighlightBackground extends StatefulWidget {
  const HighlightBackground({required this.child, super.key});

  final Widget child;

  @override
  State<HighlightBackground> createState() => __HighlightBackgroundState();
}

class __HighlightBackgroundState extends State<HighlightBackground>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: const ParticleOptions(
            particleCount: 10,
            spawnMinRadius: 15,
            spawnMaxRadius: 30,
            maxOpacity: 0.08,
            minOpacity: 0.06,
            spawnMinSpeed: 2,
            spawnMaxSpeed: 5,
            baseColor: GColors.backgroundScaffoldAccent,
          ),
        ),
        vsync: this,
        child: widget.child,
      ),
    );
  }
}
