import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/components/dialogs/polygon_reminder.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/layouts/app_layout_sliver.dart';
import 'package:wallet/screens/home/home_default.dart';
import 'package:wallet/screens/home/home_exchange.dart';
import 'package:wallet/screens/home/home_investor.dart';
import 'package:wallet/styling.dart';

@RoutePage()
class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final wallet = ref.read(walletProvider);

    final investorMode = useMemoized(
      () => Hive.box<String>(safeBox).get('investor_mode'),
      [],
    );

    final enableExchange = useMemoized(
      () {
        if (!kIsWeb && ['ios', 'macos'].contains(Platform.operatingSystem)) {
          return 'false';
        }

        return Hive.box<String>(safeBox).get('enable_exchange');
      },
      [],
    );

    var length = 1;
    if (investorMode != null && investorMode != 'false') {
      length++;
    }
    if (enableExchange == 'true') {
      length++;
    }

    final tabController = useTabController(
      initialLength: length,
    );

    final mounted = useIsMounted();

    useMemoized(
      () {
        () async {
          // Hive.box<String>(safeBox)
          //     .put('startup_polygon_warning_shown', 'false');

          final warningDialogShown = Hive.box<String>(safeBox)
              .get('startup_polygon_warning_shown', defaultValue: 'false');
          if (warningDialogShown == 'true') {
            return;
          }

          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted()) {
            showPolygonReminderDialog(context);
          }
        }.call();
      },
      [],
    );

    return AppLayoutSliver(
      suffixIcon: LucideIcons.settings,
      suffixClick: () => context.router.pushNamed('/settings'),
      containsScrollable: true,
      children: [
        Row(
          children: [
            Expanded(
              child: TabBar(
                padding: EdgeInsets.symmetric(
                  horizontal: GPaddings.layoutHorizontalPadding(),
                ),
                controller: tabController,
                indicatorColor: Colors.transparent,
                labelStyle: GTextStyles.h1,
                isScrollable: true,
                labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                unselectedLabelColor: GColors.white.withOpacity(0.4),
                splashBorderRadius: BorderRadius.circular(12),
                splashFactory: NoSplash.splashFactory,
                tabs: [
                  if (investorMode == 'primary') const Text('Invest'),
                  const Text('Wallet'),
                  if (enableExchange == 'true') const Text('Exchange'),
                  if (investorMode == 'true') const Text('Invest'),
                ],
              ),
            ),
            // AnimatedOpacity(opacity: opacity, duration: duration)
            // AnimatedBuilder(
            //   animation: tabController,
            //   builder: (ctx, child) {
            //     if (investorMode == 'false') {
            //       return child!;
            //     }
            //     if ((tabController.index == 1 && investorMode == 'true') ||
            //         (tabController.index == 2 && investorMode == 'primary')) {
            //       return child!;
            //     }
            //     return SizedBox();
            //   },
            //   // todo: animate
            //   child: const TotalWallet(),
            // ),
          ],
        ),
        SizedBox(height: GPaddings.tiny(context)),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              if (investorMode == 'primary')
                const HomePageInvestorFragment(key: ValueKey('invest')),
              const HomePageDefaultFragment(key: ValueKey('home')),
              if (enableExchange == 'true')
                const HomePageExchangeFragment(key: ValueKey('exchange')),
              if (investorMode == 'true')
                const HomePageInvestorFragment(key: ValueKey('invest')),
            ],
          ),
        ),
        // SliverFillRemaining(
        //   child: TabBarView(
        //     physics: const AlwaysScrollableScrollPhysics(),
        //     controller: tabController,
        //     children: [
        //       if (investorMode == 'primary') const HomePageInvestorFragment(key: ValueKey('invest')),
        //       const HomePageDefaultFragment(key: ValueKey('home')),
        //       if (enableExchange == 'true') const HomePageExchangeFragment(key: ValueKey('exchange')),
        //       if (investorMode == 'true') const HomePageInvestorFragment(key: ValueKey('invest')),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
