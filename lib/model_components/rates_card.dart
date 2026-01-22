import 'package:animated_digit/animated_digit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/styling.dart';
import 'package:wallet/utils/gstream.dart';
import 'package:wallet/utils/material_state.dart';

class RatesCard extends ConsumerWidget {
  const RatesCard({
    super.key,
  });

  ButtonStyle get _style => ButtonStyle(
        // backgroundColor: MaterialStateProperty.all(backgroundColor),
        // shadowColor: MaterialStateProperty.all(border.color),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.resolveWith(
          (states) {
            var radius = 18.0;
            final border = BorderSide(
              color: GColors.white.withOpacity(0.9),
              width: 2,
            );
            final active = <WidgetState>[
              WidgetState.hovered,
              WidgetState.selected,
              WidgetState.focused,
              WidgetState.pressed,
            ];
            if (states.containsOne(active)) {
              radius = 22.0;
            }
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
              side: border,
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(walletProvider);

    return TextButton(
      onPressed: () {
        context.router.pushNamed('/calculator');
      },
      style: _style,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Expanded(child: SizedBox()),
            Column(
              children: [
                // todo use a for-loop instead
                GStreamBuilder<double>(
                  gStream: provider.currencies![0].price!,
                  builder: (_, data) {
                    var value = -0.00;
                    if (data.hasData && data.data != null) {
                      value = data.data!;
                    }
                    return AnimatedDigitWidget(
                      value: value,
                      fractionDigits: 4,
                      textStyle: GTextStyles.monoBold,
                      prefix: '1 GAU   = ',
                      suffix: ' USD',
                    );
                    // return Text('1 GAU   =  $value USD', style: DTextStyles.monoBold);
                  },
                ),
                const SizedBox(height: 2),
                GStreamBuilder<double>(
                  gStream: provider.currencies![1].price!,
                  builder: (_, data) {
                    var value = -0.00;
                    if (data.hasData && data.data != null) {
                      value = data.data!;
                    }

                    return AnimatedDigitWidget(
                      value: value,
                      fractionDigits: 4,
                      textStyle: GTextStyles.monoBold,
                      prefix: '1 ${provider.currencies![1].type.ticker}  = ',
                      suffix: ' USD',
                    );
                    // return Text('1 MATIC =  $value USD', style: DTextStyles.monoBold);
                  },
                ),
                // if (MediaQuery.of(context).size.height > 700)
                const SizedBox(height: 2),
                // if (MediaQuery.of(context).size.height > 700)
                GStreamBuilder<double>(
                  gStream: provider.currencies![2].price!,
                  builder: (_, data) {
                    var value = -0.00;
                    if (data.hasData && data.data != null) {
                      value = data.data!;
                    }
                    return AnimatedDigitWidget(
                      value: value,
                      fractionDigits: 4,
                      textStyle: GTextStyles.monoBold,
                      prefix: '1 POL   = ',
                      suffix: ' USD',
                    );
                    // return Text('1 GAU   =  $value USD', style: DTextStyles.monoBold);
                  },
                ),
              ],
            ),
            Expanded(
              child: MediaQuery.of(context).size.width > 440
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: GColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          LucideIcons.calculator,
                          color: GColors.blackBlueish,
                          size: 26,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
