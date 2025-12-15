import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/styling.dart';

class BaseLayoutSliver extends HookWidget {
  const BaseLayoutSliver({
    required this.children,
    required this.heading,
    required this.dismissible,
    super.key,
  });

  final List<Widget> children;
  final List<Widget> heading;
  final bool dismissible;

  @override
  Widget build(BuildContext context) {

    // final scroll = CustomScrollView(
    //   shrinkWrap: true,
    //   // primary: true,
    //   slivers: children,
    //   // controller: controller,
    //   physics: const AlwaysScrollableScrollPhysics(),
    // );
    final child = NestedScrollView(
      // physics: Sch(),
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return heading;
      },
      body: Column(children: children),
      // body: Column(
      //   // physics: NeverScrollableScrollPhysics(),
      //   children: children,
      // ),
      // controller: controller,
      // physics: const AlwaysScrollableScrollPhysics(),
    );

    return Scaffold(
      body: Stack(
        children: [
          // todo use [nested] Navigator() instead
          const Positioned.fill(
            child: _Background(),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > breakPointWidth) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: breakPointWidth.toDouble()),
                      child: child,
                    ),
                  );
                }

                return child;
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
