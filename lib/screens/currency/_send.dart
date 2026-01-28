import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/components/buttons/primary.dart';
import 'package:wallet/components/dialogs/calculator.dart';
import 'package:wallet/components/dialogs/tx.dart';
import 'package:wallet/components/inputs/primary.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/models/tx.dart';
import 'package:wallet/screens/_generic/scan_qr.dart';
import 'package:wallet/styling.dart';

class SendCurrencyTab extends HookWidget {
  const SendCurrencyTab(this.currency, this.maticBalance, {super.key});

  final Currency currency;
  final double? maticBalance;

  @override
  Widget build(BuildContext context) {
    useAutomaticKeepAlive();

    final addr = useTextEditingController();
    final amount = useTextEditingController();

    // Smart gasless auto-detection based on POL balance
    final shouldUseGasless = (maticBalance ?? 0) < gaslessBalanceThreshold;

    final amountWidget = currency.type == CurrencyTicker.gau
        ? GPrimaryInput(
            label: 'Amount',
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            suffix: IconButton(
              icon: const Icon(
                LucideIcons.calculator,
                color: GColors.white,
              ),
              onPressed: () async {
                final currentAmount = double.tryParse(amount.text) ?? 0;
                final newAmount =
                    await showCalculatorDialog(context, currentAmount);
                if (newAmount != null) {
                  amount.text = newAmount.toString();
                }
              },
            ),
            currency: true,
          )
        : GPrimaryInput(
            label: 'Amount',
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            currency: true,
          );

    return CustomScrollView(
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.small(context))),
        SliverToBoxAdapter(child: amountWidget),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  final currentBalance = currency.balance.lastValue ?? 0;
                  double maxAmount;

                  if (currency.type == CurrencyTicker.matic) {
                    // POL: subtract estimated gas fee
                    maxAmount = currentBalance - polMaxSendReserve;
                  } else if ((currency.type == CurrencyTicker.gau || currency.type == CurrencyTicker.usdt) && shouldUseGasless) {
                    // Gasless tokens (GAU/USDT with meta-tx): use full balance
                    maxAmount = currentBalance;
                  } else {
                    // Other tokens: use full balance
                    maxAmount = currentBalance;
                  }

                  // Ensure non-negative
                  if (maxAmount < 0) maxAmount = 0;

                  // Format to reasonable precision (8 decimals)
                  amount.text = maxAmount.toStringAsFixed(8).replaceAll(RegExp(r'\.?0+$'), '');
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                child: Text(
                  'MAX',
                  style: TextStyle(
                    color: GColors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.medium(context))),
        SliverToBoxAdapter(
          child: GPrimaryInput(
            label: 'Address',
            controller: addr,
            suffix: IconButton(
              onPressed: () async {
                final qr = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QRScreen()),
                );
                if (qr is String) {
                  addr.text = qr;
                }
              },
              icon: const Icon(
                LucideIcons.scanLine,
                color: GColors.white,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        if (currency.type == CurrencyTicker.gau || currency.type == CurrencyTicker.usdt) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                shouldUseGasless
                    ? 'Gas fee: Covered by Relayer'
                    : 'Gas fee: ~${(maticBalance ?? 0) * 0.0001} POL',
                style: TextStyle(
                  color: GColors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: GPrimaryButton(
            label: 'Send',
            onPressed: () {
              final value = double.tryParse(amount.text);
              if (value == null) {
                return;
              }

              final data = TxData(
                amount: value,
                currency: currency,
                address: addr.text,
                useMetaIfPossible:
                    (currency.type == CurrencyTicker.gau || currency.type == CurrencyTicker.usdt) && shouldUseGasless,
              );

              final tx = currency.repo.send(data);
              showTxDialog(context, data, tx);
            },
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.small(context))),
      ],
    );
  }
}
