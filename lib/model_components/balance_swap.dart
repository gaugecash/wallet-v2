import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:wallet/components/buttons/base.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/styling.dart';
import 'package:wallet/utils/gstream.dart';

enum SwapOrder {
  // gau -> matic
  o12,
  // matic -> gau
  o21,
}

class BalanceSwapCard extends GButtonBase {
  const BalanceSwapCard({
    // gau
    required this.c1,
    // matic
    required this.c2,
    required this.order,
    required this.ctaIcon,
    required this.swapStateIcon,
    super.onPressed,
    super.key,
  });

  final Currency c1;
  final Currency c2;
  final SwapOrder order;
  final IconData ctaIcon;
  final IconData swapStateIcon;

  @override
  Color get backgroundColor => GColors.cardBackground.withOpacity(0.8);

  @override
  BorderSide get border => BorderSide(
        color: GColors.white.withOpacity(0.4),
        width: 2,
      );

  @override
  BorderSide get focusedBorder => BorderSide(
        color: GColors.white.withOpacity(0.6),
        width: 2.8,
      );

  Widget _buildBalanceRow(Currency currency) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final key = ValueKey(MediaQuery.of(context));

        return Row(
          children: [
            Text(
              currency.type.ticker,
              style: GTextStyles.chivoRegularCurrency,
            ),
            const Spacer(),
            SizedBox(
              width: 130,
              child: GStreamBuilder<double>(
                gStream: currency.balance,
                key: ValueKey(currency.type.ticker),
                builder: (context, snapshot) {
                  var text = -0.00;
                  if (snapshot.hasData && snapshot.data != null) {
                    text = snapshot.data!;
                  }

                  return Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedDigitWidget(
                      key: key,
                      duration: const Duration(microseconds: 1),
                      value: text,
                      fractionDigits: 4,
                      enableSeparator: true,
                      separateSymbol: ' ',
                      textStyle: GTextStyles.monoBold,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // todo check for responsiveness
  @override
  Widget body(BuildContext context) {
    final matic = _buildBalanceRow(c2);
    final gau = _buildBalanceRow(c1);
    return Row(
      children: [
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              const Spacer(),
              if (order == SwapOrder.o21) matic,
              if (order == SwapOrder.o12) gau,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    swapStateIcon,
                    color: GColors.white,
                    size: 16,
                  ),
                ),
              ),
              if (order == SwapOrder.o21) gau,
              if (order == SwapOrder.o12) matic,
              const Spacer(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        if (onPressed != null) ...[
          Icon(
            ctaIcon,
            color: GColors.white,
          ),
          const SizedBox(width: 24),
        ],
      ],
    );
  }

  @override
  double get height => 108;
}
