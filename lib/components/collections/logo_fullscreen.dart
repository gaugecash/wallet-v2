import 'package:flutter/material.dart';
import 'package:wallet/styling.dart';

class LogoFullScreenComponent extends StatelessWidget {
  const LogoFullScreenComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'logo_fullscreen',
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            Image.asset(
              'assets/logo/logo_400.png',
              width: 200,
              height: 200,
              color: GColors.white,
            ),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'The World’s First\nDecentralized\nMonetary System',
                style: GTextStyles.mulishBlackDisplay,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
