import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/components/buttons/primary.dart';
import 'package:wallet/components/dialogs/calculator.dart';
import 'package:wallet/components/dialogs/tx.dart';
import 'package:wallet/components/inputs/primary.dart';
import 'package:wallet/components/slivers/spacing.dart';
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

    final useGauForFee = useState(false);  // Gasless by default

    useEffect(
      () {
        // Already defaults to true (gasless), no need to change
        return null;
      },
      [maticBalance],
    );

    final amountWidget = currency.type == CurrencyTicker.gau
        ? GPrimaryInput(
            label: 'Amount',
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
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
            ),
            currency: true,
          );

    return CustomScrollView(
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.small(context))),
        SliverToBoxAdapter(child: amountWidget),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.medium(context))),
        SliverToBoxAdapter(
          child: GPrimaryInput(
            label: 'Address',
            controller: addr,
            suffix: IconButton(
              onPressed: () async {
                final qr = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QRScreen()),
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
        if (currency.type == CurrencyTicker.gau || currency.type == CurrencyTicker.usdt) ...[
          SliverToBoxAdapter(
            child: SizedBox(height: GPaddings.small(context)),
          ),
          SliverToBoxAdapter(
            child: CheckboxListTile(
              title: const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Gasless transfer (pay fee with token)',
                  style: GTextStyles.poppinsMediumButton,
                ),
              ),
              visualDensity: const VisualDensity(horizontal: -3, vertical: -4),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.trailing,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              value: useGauForFee.value,
              onChanged: (el) {
                useGauForFee.value = el!;
              },
            ),
          ),
        ],
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
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
                    (currency.type == CurrencyTicker.gau || currency.type == CurrencyTicker.usdt) && useGauForFee.value,
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
