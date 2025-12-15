import 'package:flutter/material.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/styling.dart';

class BaseLayout extends StatelessWidget {
  const BaseLayout({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: _Background(),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final _child = SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 28,
                    ),
                    child: child,
                  ),
                );

                if (constraints.maxWidth > breakPointWidth) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: breakPointWidth.toDouble()),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 34),
                        child: _child,
                      ),
                    ),
                  );
                }

                return _child;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BackgroundPainter(),
      isComplex: true,
    );
  }
}

// todo cache the painter as it is somewhat expensive to create
class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GColors.backgroundScaffoldAccent.withOpacity(0.12)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70);

    canvas.drawCircle(
      Offset(size.width + 200, size.height / 2),
      500,
      paint,
    );
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) => false;
}
