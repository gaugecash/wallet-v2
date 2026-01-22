import 'dart:math' as math;
import 'package:flutter/material.dart';

class GuillocheBackground extends StatefulWidget {
  const GuillocheBackground({super.key});

  @override
  State<GuillocheBackground> createState() => _GuillocheBackgroundState();
}

class _GuillocheBackgroundState extends State<GuillocheBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Ultra-slow breathing animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120), // Very slow cycle
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GuillochePainter(time: _controller.value * 2 * math.pi),
          size: Size.infinite,
        );
      },
    );
  }
}

class _GuillochePainter extends CustomPainter {

  _GuillochePainter({required this.time});
  final double time;

  // Rose Gold palette
  static const List<Color> roseGoldColors = [
    Color(0xFFB76E79), // rose-core
    Color(0xFFDAA591), // rose-copper
    Color(0xFFCD919E), // rose-blush
    Color(0xFFE6BEAA), // rose-champagne
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final maxRadius = math.max(size.width, size.height);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Layers configuration matching the web version
    final layers = [
      _Layer(frequency: 0.008, amplitude: 70, phase: 0, opacity: 0.12, colorIndex: 0),
      _Layer(frequency: 0.012, amplitude: 50, phase: math.pi / 3, opacity: 0.09, colorIndex: 1),
      _Layer(frequency: 0.006, amplitude: 90, phase: math.pi / 6, opacity: 0.10, colorIndex: 2),
      _Layer(frequency: 0.015, amplitude: 40, phase: math.pi / 2, opacity: 0.07, colorIndex: 3),
    ];

    for (final layer in layers) {
      final color = roseGoldColors[layer.colorIndex];
      
      // Draw concentric guilloché curves
      // Starting from r=50 to avoid cluttering the absolute center (where the button goes)
      for (double r = 50; r < maxRadius; r += 22) {
        final path = Path();
        
        // Breathing scale effect
        final breathScale = 1 + math.sin(time * 2 + r * 0.01) * 0.03;
        final adjustedR = r * breathScale;

        var firstPoint = true;

        // Resolution of the curve
        for (double angle = 0; angle < math.pi * 2; angle += 0.015) {
          // Gravitational lensing - pull toward center
          final distanceFromCenter = adjustedR / maxRadius;
          // Cubic for stronger effect near center
          final gravityPull = math.pow(1 - distanceFromCenter, 3) * 0.5; 
          
          // Space-time curvature effect
          final curvatureAngle = angle + gravityPull * math.sin(angle * 2 + time) * 0.3;
          
          // Sine wave modulation
          final waveOffset = math.sin(
            curvatureAngle * (8 + layer.frequency * 1000) + 
            layer.phase + 
            time + 
            r * layer.frequency,
          ) * layer.amplitude * (1 - gravityPull * 0.8);

          final finalR = adjustedR + waveOffset;
          
          // Apply gravity distortion to coordinates
          final x = centerX + math.cos(curvatureAngle) * finalR * (1 - gravityPull * 0.2);
          final y = centerY + math.sin(curvatureAngle) * finalR * (1 - gravityPull * 0.2);

          if (firstPoint) {
            path.moveTo(x, y);
            firstPoint = false;
          } else {
            path.lineTo(x, y);
          }
        }
        
        path.close();

        // Calculate opacity based on distance from center (simplified content-aware)
        // In Flutter custom painter, per-pixel opacity is expensive.
        // We use a general opacity for the ring.
        paint.color = color.withOpacity(layer.opacity);
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GuillochePainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

class _Layer {

  _Layer({
    required this.frequency,
    required this.amplitude,
    required this.phase,
    required this.opacity,
    required this.colorIndex,
  });
  final double frequency;
  final double amplitude;
  final double phase;
  final double opacity;
  final int colorIndex;
}
