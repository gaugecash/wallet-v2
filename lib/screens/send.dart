import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/layouts/app_layout_sliver.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/screens/currency/_send.dart';
import 'package:wallet/styling.dart';

@RoutePage()
class SendScreen extends HookConsumerWidget {
  const SendScreen({super.key, @QueryParam('ticker') this.preselectedTicker});

  final String? preselectedTicker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.read(walletProvider);

    // If no ticker provided, redirect to token selection screen
    useEffect(() {
      if (preselectedTicker == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.router.replaceNamed('/send-token-select');
        });
      }
      return null;
    }, []);

    // Get selected currency from ticker
    final selectedCurrency = preselectedTicker != null
        ? wallet.currencies!.firstWhere(
            (c) => c.type.ticker.toLowerCase() == preselectedTicker!.toLowerCase(),
            orElse: () => wallet.currencies!.first,
          )
        : null;

    // Get MATIC balance for gasless fee calculation
    final matic = wallet.currencies!.firstWhere(
      (element) => element.type == CurrencyTicker.matic,
    );
    final maticBalance =
        useStream(matic.balance.stream, initialData: matic.balance.lastValue);

    // If no currency selected, show loading while redirecting
    if (selectedCurrency == null) {
      return AppLayoutSliver(
        showBackButton: true,
        children: [
          SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    return AppLayoutSliver(
      showBackButton: true,
      children: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: GPaddings.layoutHorizontalPadding(),
            ),
            child: Text(
              'Send ${selectedCurrency.type.ticker.toUpperCase()}',
              style: GTextStyles.h1,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: GPaddings.medium(context)),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: GPaddings.layoutHorizontalPadding(),
            ),
            child: SendCurrencyTab(
              selectedCurrency,
              maticBalance.data,
            ),
          ),
        ),
      ],
    );
  }
}
