import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/components/help_cards/gauf_card.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/model_components/balance_card.dart';
import 'package:wallet/model_components/wallet_action.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/providers/wallet.dart';

class HomePageInvestorFragment extends HookConsumerWidget {
  const HomePageInvestorFragment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useAutomaticKeepAlive();

    final wallet = ref.read(walletProvider);

    return CustomScrollView(
      primary: true,
      // physics: const NeverScrollableScrollPhysics(),
      slivers: [
        for (final currency in wallet.currencies!.where((element) => element.investOnly)) ...[
          GPaddingsLayoutHorizontal.sliver(
            child: Hero(
              tag: currency.type.ticker,
              child: BalanceCard(
                model: currency,
                onPressed: () {
                  context.router.pushNamed('/coin/${currency.type.ticker}');
                },
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: GPaddings.small(context))),
        ],
        GPaddingsLayoutHorizontal.sliver(
          child: Row(
            children: [
              Expanded(
                child: GWalletActionButton(
                  label: 'Invest',
                  icon: LucideIcons.coins,
                  onPressed: () {
                    context.router.pushNamed('/invest');
                  },
                ),
              ),
              // SizedBox(width: GSmallSpacing.getPadding(context)),
              // Expanded(
              //   child: GWalletActionButton(
              //     label: 'Withdraw',
              //     icon: LucideIcons.banknote,
              //     onPressed: () {
              //       context.router.pushNamed('/swap');
              //     },
              //   ),
              // ),
            ],
          ),
        ),
        GPaddingsLayoutHorizontal.sliver(
          child: const LearnMoreGaufGenericCard(),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.small(context))),
        // GSliverBoxWithLayoutPadding(
        //   child: Row(
        //     // crossAxisAlignment: CrossAxisAlignment,
        //     children: [
        //       const Text(
        //         'Portfolio',
        //         style: GTextStyles.h2,
        //       ),
        //       const SizedBox(width: 6),
        //       Container(
        //         decoration: BoxDecoration(
        //           color: GColors.white,
        //           borderRadius: BorderRadius.circular(6),
        //         ),
        //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        //         margin: const EdgeInsets.only(top: 4),
        //         child: Text(
        //           'soon',
        //           style: GTextStyles.mulishVersionText
        //               .copyWith(color: Colors.black),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: GPaddingsLayoutHorizontal(
            child: Column(
              children: [
                const Spacer(),
                // RatesCard(),
                SizedBox(height: GPaddings.layoutVerticalPadding(context)),
                const SafeArea(top: false, child: SizedBox()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
