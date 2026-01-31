import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wallet/components/buttons/transparent.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/layouts/app_layout_sliver.dart';
import 'package:wallet/model_components/balance_compact.dart';
import 'package:wallet/model_components/wallet_action.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/screens/currency/_receive.dart';
import 'package:wallet/screens/currency/_send.dart';
import 'package:wallet/styling.dart';

@RoutePage()
class CurrencyScreen extends HookConsumerWidget {
  const CurrencyScreen({
    @PathParam('ticker') required this.ticker,
    super.key,
  });

  final String ticker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.read(walletProvider);
    final addrFuture =
        useFuture(useMemoized(() => wallet.wallet!.getAddress(), []));

    final matic = wallet.currencies!.firstWhere(
      (element) => element.type == CurrencyTicker.matic,
    );

    final maticBalance =
        useStream(matic.balance.stream, initialData: matic.balance.lastValue);

    final coin = wallet.currencies!.firstWhere(
      (element) => element.type.ticker == ticker,
    );

    // State to track which action is currently selected (0: Receive, 1: Send)
    final selectedAction = useState(0);

    final wideScreen = MediaQuery.of(context).size.width > breakPointWidth;

    return AppLayoutSliver(
      showBackButton: true,
      children: [
        GPaddingsLayoutHorizontal.sliver(
          child: Hero(
            tag: coin.type.ticker,
            child: BalanceCompactCard(
              model: coin,
              highlighted: coin.type == CurrencyTicker.gau,
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: GPaddings.medium(context))),

        GPaddingsLayoutHorizontal.sliver(
          child: Row(
            children: [
              Expanded(
                child: GWalletActionButton(
                  label: 'Receive',
                  icon: LucideIcons.download,
                  onPressed: () {
                    selectedAction.value = 0;
                  },
                ),
              ),
              SizedBox(width: GPaddings.small(context)),
              Expanded(
                child: GWalletActionButton(
                  label: 'Send',
                  icon: LucideIcons.send,
                  onPressed: () {
                    selectedAction.value = 1;
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
              const Spacer(),
              GTransparentButton(
                child: Row(
                  children: [
                    Text(
                      wideScreen ? 'Transactions' : 'TXs',
                      style: GTextStyles.h1
                          .copyWith(color: GColors.white.withValues(alpha: 0.4)),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      LucideIcons.externalLink,
                      color: GColors.white.withValues(alpha: 0.4),
                    ),
                  ],
                ),
                onPressed: () {
                  if (!addrFuture.hasData) {
                    return;
                  }
                  final addr = addrFuture.data.toString();
                  launchUrlString(
                    'https://polygonscan.com/address/$addr#transactions',
                  );
                },
              ),
            ],
          ),
        ),

        SliverFillRemaining(
          hasScrollBody: false,
          child: GPaddingsLayoutHorizontal(
            child: selectedAction.value == 0
                ? const ReceiveCurrencyTab()
                : SendCurrencyTab(coin, maticBalance.data),
          ),
        ),
        // // const SizedBox(height: 12),
        // Expanded(
        //   child: TabBarView(
        //     controller: controller,
        //     children: [
        //       const SingleChildScrollView(child: ReceiveCurrencyTab()),
        //       SingleChildScrollView(child: SendCurrencyTab(coin)),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
