import 'package:flutter/material.dart';
import 'package:wallet/components/visuals/guilloche_painter.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/styling.dart';

class BaseLayout extends StatelessWidget {
  const BaseLayout({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GColors.abyssDeep, // Ensure base color is correct
      body: Stack(
        children: [
          // New Design Language Background
          const Positioned.fill(
            child: GuillocheBackground(),
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