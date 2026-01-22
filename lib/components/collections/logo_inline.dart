import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/styling.dart';

class LogoInlineComponent extends StatelessWidget {
  const LogoInlineComponent({
    this.showBackButton = false,
    this.suffixIcon,
    this.suffixClick,
    super.key,
  });

  final bool showBackButton;
  final IconData? suffixIcon;
  final void Function()? suffixClick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            if (!showBackButton && suffixIcon != null)
              const SizedBox(height: 48, width: 48),
            if (showBackButton)
              SizedBox(
                height: 48,
                width: 48,
                child: IconButton(
                  icon:
                      const Icon(LucideIcons.chevronLeft, color: GColors.white),
                  onPressed: context.router.maybePop,
                ),
              ),
            const Spacer(),
            const _Logo(),
            const Spacer(),
            if (suffixIcon != null)
              SizedBox(
                height: 48,
                width: 48,
                child: IconButton(
                  icon: Icon(suffixIcon, color: GColors.white),
                  onPressed: suffixClick,
                ),
              ),
            if (showBackButton && suffixIcon == null)
              const SizedBox(width: 48, height: 48),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  // String get versionLabel {
  //   return 'polygon mainnet';
  //   var part1 = '';
  //   if (kReleaseMode) {
  //     part1 = 'alpha';
  //   } else if (kDebugMode) {
  //     part1 = 'debug';
  //   }
  //
  //   var part2 = '';
  //   if (network == Network.main) {
  //     part2 = 'mainnet';
  //   } else if (network == Network.test) {
  //     part2 = 'testnet';
  //   }
  //
  //   return '$part1-$part2';
  // }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'logo',
      child: Row(
        children: [
          Image.asset(
            'assets/logo/logo_150.png',
            width: 44,
            height: 44,
          ),
          const SizedBox(width: 14),
          DefaultTextStyle(
            style: const TextStyle(),
            child: Stack(
              children: [
                const Center(
                  child: Text('GAUGECASH', style: GTextStyles.chivoLightLogo),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      'polygon mainnet',
                      style: GTextStyles.monoLight.copyWith(fontSize: 10),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
