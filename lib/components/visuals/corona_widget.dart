import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:wallet/styling.dart';

class CoronaWidget extends StatefulWidget {

  const CoronaWidget({super.key, required this.onLaunch});
  final VoidCallback onLaunch;

  @override
  State<CoronaWidget> createState() => _CoronaWidgetState();
}

class _CoronaWidgetState extends State<CoronaWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _tectonicController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    )..repeat();

    _tectonicController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _tectonicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tectonic Rise Animation (Slide up + Fade in)
    return AnimatedBuilder(
      animation: _tectonicController,
      builder: (context, child) {
        final curve =
            CurvedAnimation(parent: _tectonicController, curve: const Cubic(0.16, 1.0, 0.3, 1.0));
        return Opacity(
          opacity: curve.value,
          child: Transform.translate(
            offset: Offset(0, 60 * (1 - curve.value)),
            child: child,
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Pulse Rings (The Waves)
          _buildPulseRing(0),
          _buildPulseRing(2.5), // Staggered by 2.5s

          // 2. Orbital Ring (35 Currencies)
          _buildOrbitalRing(),

          // 3. The Crystal Corona (Rotating Rings) with Chromatic Aberration
          _buildCoronaWithChromaticAberration(),

          // 4. Launch Button (Center)
          _buildLaunchButton(),
        ],
      ),
    );
  }

  Widget _buildPulseRing(double delay) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        // Calculate shifted value for stagger
        final value = (_pulseController.value + (delay / 5)) % 1.0;
        
        // Custom curve: fast out, slow decay
        // Scale 1 -> 3
        final scale = 1.0 + (value * 2.5); 
        // Opacity 0.5 -> 0
        final opacity = (1.0 - value) * 0.5;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: GColors.corona.withOpacity(opacity),
                width: 0.5,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrbitalRing() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        // Rotates slower than the corona
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi * 0.5, 
          child: SizedBox(
            width: 200, // Slightly larger than button, smaller than corona
            height: 200,
            child: CustomPaint(
              painter: _OrbitalDotsPainter(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoronaRing(bool reverse, {bool chromaticLayer = false}) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        var angle = _rotationController.value * 2 * math.pi;
        if (reverse) angle = -angle * 0.8; // Reverse is slightly slower

        return Transform.rotate(
          angle: angle,
          child: ClipPath(
            clipper: _RingClipper(),
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    GColors.corona.withOpacity(chromaticLayer ? 0.05 : 0.1),
                    GColors.corona.withOpacity(chromaticLayer ? 0.35 : 0.7),
                    GColors.coronaGlow.withOpacity(chromaticLayer ? 0.45 : 0.9),
                    GColors.corona.withOpacity(chromaticLayer ? 0.2 : 0.4),
                    GColors.corona.withOpacity(chromaticLayer ? 0.05 : 0.1),
                  ],
                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Chromatic Aberration: Stack of corona rings with color offsets
  Widget _buildCoronaWithChromaticAberration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Main Corona Rings
        _buildCoronaRing(false), // Clockwise
        _buildCoronaRing(true), // Counter-Clockwise

        // Cyan Prismatic Edge (offset left, screen blend)
        Transform.translate(
          offset: const Offset(-2, 0),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              GColors.prismCyan.withOpacity(0.4),
              BlendMode.screen,
            ),
            child: _buildCoronaRing(false, chromaticLayer: true),
          ),
        ),

        // Violet Prismatic Edge (offset right, screen blend)
        Transform.translate(
          offset: const Offset(2, 0),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              GColors.prismViolet.withOpacity(0.35),
              BlendMode.screen,
            ),
            child: _buildCoronaRing(true, chromaticLayer: true),
          ),
        ),
      ],
    );
  }

  Widget _buildLaunchButton() {
    return GestureDetector(
      onTap: widget.onLaunch,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              GColors.corona.withOpacity(0.2),
              GColors.coronaSoft.withOpacity(0.1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: GColors.corona.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'LAUNCH',
              style: GTextStyles.buttonMedium.copyWith(
                color: GColors.champagne,
                letterSpacing: 2.0,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'GAU',
              style: GTextStyles.monoRegular.copyWith(
                color: GColors.coronaGlow.withOpacity(0.8),
                fontSize: 10,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Paints the 35 dots
class _OrbitalDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..color = GColors.coronaGlow;

    for (var i = 0; i < 35; i++) {
      final angle = (i / 35) * 2 * math.pi;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Clips the container to create a ring shape (donut with hole in center)
class _RingClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.40; // 40% hole in center

    // Outer circle
    path.addOval(Rect.fromCircle(center: center, radius: outerRadius));

    // Inner circle (hole) - using PathFillType.evenOdd to cut it out
    path.addOval(Rect.fromCircle(center: center, radius: innerRadius));
    path.fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
