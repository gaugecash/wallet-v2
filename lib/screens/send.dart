import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/layouts/app_layout_sliver.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/screens/currency/_send.dart';
import 'package:wallet/styling.dart';

@RoutePage()
class SendScreen extends HookConsumerWidget {
  const SendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.read(walletProvider);
    final selectedCurrency = useState<Currency?>(null);

    // Get MATIC balance for gasless fee calculation
    final matic = wallet.currencies!.firstWhere(
      (element) => element.type == CurrencyTicker.matic,
    );
    final maticBalance =
        useStream(matic.balance.stream, initialData: matic.balance.lastValue);

    // Filter currencies for the dropdown (exclude exchange-only and invest-only)
    final sendableCurrencies = wallet.currencies!
        .where((c) => !c.investOnly && !c.exchangeOnly)
        .toList();

    return AppLayoutSliver(
      showBackButton: true,
      children: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: GPaddings.layoutHorizontalPadding(context),
            ),
            child: Text(
              'Send',
              style: GTextStyles.h1,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: GPaddings.medium(context)),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: GPaddings.layoutHorizontalPadding(context),
            ),
            child: GestureDetector(
              onTap: () {
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
                                selectedCurrency.value = currency;
                                Navigator.pop(context);
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
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: GColors.white.withOpacity(0.6),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCurrency.value == null
                          ? 'Select token'
                          : '${selectedCurrency.value!.type.ticker.toUpperCase()} - ${selectedCurrency.value!.type.name}',
                      style: TextStyle(
                        color: selectedCurrency.value == null
                            ? Colors.white70
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: selectedCurrency.value == null
                            ? FontWeight.normal
                            : FontWeight.w500,
                      ),
                    ),
                    Icon(LucideIcons.chevronDown, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (selectedCurrency.value != null) ...[
          SliverToBoxAdapter(
            child: SizedBox(height: GPaddings.medium(context)),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: GPaddings.layoutHorizontalPadding(context),
              ),
              child: SendCurrencyTab(
                selectedCurrency.value!,
                maticBalance.data,
              ),
            ),
          ),
        ] else ...[
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: GPaddings.layoutHorizontalPadding(context),
                ),
                child: Text(
                  'Select a token to send',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
