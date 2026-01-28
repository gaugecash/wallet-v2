import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/components/help_cards/gau_card.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/model_components/balance_card.dart';
import 'package:wallet/model_components/rates_card.dart';
import 'package:wallet/model_components/wallet_action.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/providers/wallet.dart';

class HomePageDefaultFragment extends HookConsumerWidget {
  const HomePageDefaultFragment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useAutomaticKeepAlive();

    final wallet = ref.read(walletProvider);

    return CustomScrollView(
      primary: true,
      slivers: [
        for (final currency in wallet.currencies!.where(
          (element) => !element.investOnly && !element.exchangeOnly &&
            (element.type != CurrencyTicker.matic || (element.balance.lastValue ?? 0) > polVisibilityThreshold),
        )) ...[
          GPaddingsLayoutHorizontal.sliver(
            child: Hero(
              tag: currency.type.ticker,
              child: BalanceCard(
                small: currency.type != CurrencyTicker.gau,
                model: currency,
                onPressed: () {
                  context.router.pushNamed('/coin/${currency.type.ticker}');
                },
                highlighted: currency.type == CurrencyTicker.gau,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: GPaddings.small(context)),
          ),
          // if (currency.type == CurrencyTicker.gau) ...[
          //   SliverToBoxAdapter(
          //     child: SizedBox(height: GPaddings.small(context)),
          //   ),
          //   GPaddingsLayoutHorizontal.sliver(
          //     child: Container(
          //       height: 2,
          //       margin: const EdgeInsets.symmetric(horizontal: 12),
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(2),
          //         color: GColors.white.withValues(alpha: 0.2),
          //       ),
          //     ),
          //   ),
          //   SliverToBoxAdapter(
          //     child: SizedBox(height: GPaddings.small(context)),
          //   ),
          // ],
          // if (currency.type != CurrencyTicker.gau)
          //   SliverToBoxAdapter(
          //     child: SizedBox(height: GPaddings.small(context)),
          //   ),
        ],

        // SliverToBoxAdapter(child: SizedBox(height: GPaddings.tiny(context))),
        GPaddingsLayoutHorizontal.sliver(
          child: Row(
            children: [
              Expanded(
                child: GWalletActionButton(
                  label: 'Send',
                  icon: LucideIcons.send,
                  onPressed: () {
                    // Navigate to full-screen token selector
                    context.router.pushNamed('/send-token-select');
                  },
                ),
              ),
              SizedBox(width: GPaddings.small(context)),
              Expanded(
                child: GWalletActionButton(
                  label: 'Receive',
                  icon: LucideIcons.download,
                  onPressed: () {
                    context.router.pushNamed('/receive');
                  },
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.small(context))),
        GPaddingsLayoutHorizontal.sliver(
          child: Row(
            children: [
              Expanded(
                child: GWalletActionButton(
                  label: 'Swap',
                  icon: LucideIcons.arrowLeftRight,
                  onPressed: () {
                    context.router.pushNamed('/swap');
                  },
                ),
              ),
            ],
          ),
        ),
        GPaddingsLayoutHorizontal.sliver(
          child: const LearnMoreGauGenericCard(),
        ),

        SliverToBoxAdapter(child: SizedBox(height: GPaddings.small(context))),
        // GSliverBoxWithLayoutPadding(
        //   child: Row(
        //     // crossAxisAlignment: CrossAxisAlignment,
        //     children: [
        //       const Text(
        //         'Transactions',
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
                const RatesCard(),
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
