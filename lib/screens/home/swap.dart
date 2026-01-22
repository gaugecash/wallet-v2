import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:wallet/components/buttons/transparent.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/layouts/app_layout_sliver.dart';
import 'package:wallet/model_components/balance_swap.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/screens/home/swap_gau.dart';
import 'package:wallet/screens/home/swap_matic_usdt.dart';
import 'package:wallet/styling.dart';

// enum _SwapPairs {};

enum _SwapScreenState { choose, usdtGau, usdtMatic }

@RoutePage()
class SwapScreen extends HookConsumerWidget {
  const SwapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(walletProvider);

    final gau = provider.currencies!.firstWhere(
      (el) => el.type == CurrencyTicker.gau,
    );

    final usdt = provider.currencies!.firstWhere(
      (el) => el.type == CurrencyTicker.usdt,
    );

    final matic = provider.currencies!.firstWhere(
      (el) => el.type == CurrencyTicker.matic,
    );

    final state = useState(_SwapScreenState.choose);

    final query = context.routeData.queryParams;

    useMemoized(() {
      if (query.optString('swap') == 'matic_usdt') {
        state.value = _SwapScreenState.usdtMatic;
      }
    });

    return AppLayoutSliver(
      showBackButton: true,
      children: [
        SliverAnimatedSwitcher(
          duration: const Duration(milliseconds: 370),
          child: state.value == _SwapScreenState.choose
              ? GPaddingsLayoutHorizontal.sliver(
                  child: const Text(
                    'Choose the Swap Pair',
                    style: GTextStyles.h1,
                  ),
                )
              : GPaddingsLayoutHorizontal.sliver(
                  child: Row(
                    children: [
                      const Text(
                        'Swap',
                        style: GTextStyles.h1,
                      ),
                      const SizedBox(width: 8),
                      GTransparentButton(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.chevronsLeftRight,
                                color: GColors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Change the Swap Pair',
                                style: GTextStyles.poppinsMediumButton
                                    .copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () {
                          state.value = _SwapScreenState.choose;
                        },
                      ),
                    ],
                  ),
                ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.medium(context))),
        SliverAnimatedSwitcher(
          duration: const Duration(milliseconds: 370),
          child: state.value == _SwapScreenState.choose
              ? GPaddingsLayoutHorizontal.sliver(
                  key: const ValueKey<int>(0),
                  child: Column(
                    children: [
                      BalanceSwapCard(
                        ctaIcon: LucideIcons.pointer,
                        swapStateIcon: LucideIcons.arrowUpDown,
                        c1: usdt,
                        c2: gau,
                        order: SwapOrder.o12,
                        onPressed: () {
                          state.value = _SwapScreenState.usdtGau;
                        },
                      ),
                      SizedBox(height: GPaddings.medium(context)),
                      BalanceSwapCard(
                        ctaIcon: LucideIcons.pointer,
                        swapStateIcon: LucideIcons.arrowUpDown,
                        c1: matic,
                        c2: usdt,
                        order: SwapOrder.o12,
                        onPressed: () {
                          state.value = _SwapScreenState.usdtMatic;
                        },
                      ),
                    ],
                  ),
                )
              : SliverFillRemaining(
                  child: state.value == _SwapScreenState.usdtGau
                      ? const SwapGauFragment()
                      : const SwapMaticFragment(),
                ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.medium(context))),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.medium(context))),
      ],
    );
  }
}
