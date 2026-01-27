import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/components/help_cards/gau_card.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/model_components/balance_card.dart';
import 'package:wallet/model_components/rates_card.dart';
import 'package:wallet/model_components/wallet_action.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/styling.dart';

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
            (element.type != CurrencyTicker.matic || (element.balance.lastValue ?? 0) > 0.000001),
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
          //         color: GColors.white.withOpacity(0.2),
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
                    // Show bottom sheet with token selection
                    final sendableCurrencies = wallet.currencies!
                        .where((c) =>
                          !c.investOnly &&
                          !c.exchangeOnly &&
                          (c.type == CurrencyTicker.gau ||
                           c.type == CurrencyTicker.usdt ||
                           c.type == CurrencyTicker.matic) &&
                          (c.balance.lastValue ?? 0) > 0.000001)
                        .toList();

                    showModalBottomSheet(
                      context: context,
                      backgroundColor: GColors.backgroundScaffold,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                child: Text(
                                  'Select Token',
                                  style: GTextStyles.h2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...sendableCurrencies.map((currency) {
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                  title: Text(
                                    currency.type.ticker.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    currency.type.name,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    context.router.pushNamed('/send?ticker=${currency.type.ticker}');
                                  },
                                );
                              }).toList(),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    );
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
