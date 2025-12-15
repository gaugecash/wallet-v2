import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:wallet/components/buttons/_sizes.dart';
import 'package:wallet/components/buttons/primary.dart';
import 'package:wallet/components/buttons/secondary.dart';
import 'package:wallet/components/collections/logo_fullscreen.dart';
import 'package:wallet/components/slivers/adaptive_sliver.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/layouts/base_sliver.dart';

@RoutePage()
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLayoutSliver(
      dismissible: false,
      heading: const [],
      children: [
        Expanded(
          child: CustomScrollView(
            primary: true,
            slivers: [
              GSliverWithMinHeight(
                minHeight: 600,
                child: GPaddingsLayoutHorizontal(
                  child: Column(
                    children: [
                      SizedBox(height: GPaddings.layoutVerticalPadding(context)),
                      const Spacer(),
                      const LogoFullScreenComponent(),
                      const Spacer(),
                      Hero(
                        tag: 'primary',
                        child: GPrimaryButton(
                          label: 'Get Started',
                          onPressed: () {
                            context.router.pushNamed('/set_up/create');
                          },
                          size: GButtonSize.large,
                        ),
                      ),
                      SizedBox(height: GPaddings.medium(context)),
                      Hero(
                        tag: 'secondary',
                        child: GSecondaryButton(
                          label: 'Import a wallet',
                          onPressed: () {
                            context.router.pushNamed('/set_up/restore');
                          },
                        ),
                      ),
                      SizedBox(height: GPaddings.layoutVerticalPadding(context)),
                      const SafeArea(top: false, child: SizedBox()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
