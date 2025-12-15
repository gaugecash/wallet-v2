import 'package:animated_digit/animated_digit.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/styling.dart';

class TotalWallet extends HookConsumerWidget {
  const TotalWallet({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(walletProvider);
    final zip = useMemoized(
      () {
        final arr = <Stream<double>>[];
        for (final currency in provider.currencies!) {
          if (currency.investOnly) {
            continue;
          }

          arr.addAll([
            currency.balance.stream,
            currency.price.stream,
          ]);
        }

        return StreamZip(arr);
      },
      [provider],
    );

    return Row(
      children: [
        const Text('Total ', style: GTextStyles.mulishLight),
        StreamBuilder<List<double>>(
          stream: zip,
          builder: (context, snapshot) {
            var value = -0.00;

            if (snapshot.hasData && snapshot.data != null) {
              if (snapshot.data!.length % 2 != 0) {
                throw Exception(
                  'Invalid data: format: [<amount> <usd price> ...]',
                );
              }
              final gauPrice = snapshot.data![1];

              var totalUsd = 0.00;
              for (var i = 0; i < snapshot.data!.length; i += 2) {
                totalUsd += snapshot.data![i] * snapshot.data![i + 1];
              }

              // total usd = gau * price gau
              // gau = total usd / pricegau
              value = totalUsd / gauPrice;
            }

            return Align(
              alignment: Alignment.centerLeft,
              child: AnimatedDigitWidget(
                value: value,
                fractionDigits: 2,
                enableSeparator: true,
                separateSymbol: ' ',
                textStyle: GTextStyles.monoLight,
                suffix: ' GAU',
              ),
            );
          },
        ),
      ],
    );
  }
}
