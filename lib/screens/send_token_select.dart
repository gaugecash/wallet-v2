import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/layouts/app_layout_sliver.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/styling.dart';

@RoutePage()
class SendTokenSelectScreen extends HookConsumerWidget {
  const SendTokenSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.read(walletProvider);

    // Subscribe to POL balance stream to force rebuild when balance changes.
    // This ensures the visibility filter re-runs with fresh data.
    final pols = wallet.currencies?.where((c) => c.type == CurrencyTicker.matic);
    if (pols != null && pols.isNotEmpty) {
      useStream(pols.first.balance.stream);
    }

    // Filter currencies: GAU, USDT always show; POL only if balance > threshold
    final availableTokens = wallet.currencies!.where((currency) {
      if (currency.type == CurrencyTicker.gau || currency.type == CurrencyTicker.usdt) {
        return true;
      }
      if (currency.type == CurrencyTicker.matic) {
        // Show POL only if balance > threshold
        final balance = currency.balance.lastValue;
        return balance != null && balance > polVisibilityThreshold;
      }
      return false;
    }).toList();

    return AppLayoutSliver(
      showBackButton: true,
      children: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: GPaddings.layoutHorizontalPadding(),
            ),
            child: Text(
              'Select Token',
              style: GTextStyles.h1,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: GPaddings.medium(context)),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: GPaddings.layoutHorizontalPadding(),
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final currency = availableTokens[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to send screen with pre-selected ticker
                      context.router.pushNamed('/send?ticker=${currency.type.ticker}');
                    },
                    child: Container(
                      height: 74,
                      decoration: BoxDecoration(
                        color: GColors.cardBackground.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: GColors.white.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Icon(
                            currency.type.icon,
                            color: GColors.white,
                            size: 26,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            currency.type.ticker.toUpperCase(),
                            style: GTextStyles.chivoRegularCurrency.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            LucideIcons.arrowRight,
                            color: GColors.white,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: availableTokens.length,
            ),
          ),
        ),
      ],
    );
  }
}
