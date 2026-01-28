import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:wallet/components/balance_card_highlight.dart';
import 'package:wallet/components/buttons/base.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/styling.dart';
import 'package:wallet/utils/gstream.dart';

class BalanceCompactCard extends GButtonBase {
  const BalanceCompactCard({
    required this.model,
    this.highlighted = false,
    this.noBorder = false,
    super.key,
  }) : super(onPressed: null);

  final Currency model;
  final bool highlighted;
  final bool noBorder;

  Widget _buildTitle({bool big = false}) {
    final ic = SizedBox(
      width: 22,
      height: 22,
      child: Icon(
        model.type.icon,
        color: GColors.white,
        size: 22,
      ),
    );
    if (!big) {
      return ic;
    }
    return Row(
      children: [
        ic,
        const SizedBox(width: 14),
        Text(
          model.type.ticker,
          style: GTextStyles.chivoRegularCurrency,
        ),
      ],
    );
  }

  @override
  Color get backgroundColor => noBorder ? Colors.transparent : GColors.cardBackground.withValues(alpha: 0.8);

  @override
  BorderSide get border => BorderSide(
        color: noBorder? Colors.transparent : GColors.white.withValues(alpha: highlighted ? 0.5 : 0.4),
        width: 2,
      );

  @override
  BorderSide get focusedBorder => BorderSide(
        color: noBorder ? Colors.transparent : GColors.white.withValues(alpha: 0.6),
        width: 2.8,
      );

  // @override
  // Widget get stacked {
  //   return Transform.translate(
  //     offset: const Offset(2, -8),
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 14),
  //       child: Material(
  //         color: const Color(0xFF796491),
  //         borderRadius: BorderRadius.circular(4),
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
  //           child: Text(
  //             'polygon network',
  //             style: GTextStyles.mulishLight.copyWith(
  //               fontWeight: FontWeight.w400,
  //               fontSize: 12,
  //               color: GColors.white.withValues(alpha: 0.88),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  double get elevation => highlighted ? 2 : 0;

  // todo check for responsiveness
  @override
  Widget body(BuildContext context) {
    return background(
      context,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.biggest.width;
          final key = ValueKey(MediaQuery.of(context));
          // print('w: $w');

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _buildTitle(big: w > 250),
                ),
                // const Spacer(),
                SizedBox(
                  // width: 100,
                  child: GStreamBuilder<double>(
                    gStream: model.balance,
                    builder: (context, snapshot) {
                      var text = -0.00;
                      if (snapshot.hasData && snapshot.data != null) {
                        text = snapshot.data!;
                      }

                      return Align(
                        alignment: Alignment.centerRight,
                        child: AnimatedDigitWidget(
                          key: key,
                          value: text,
                          fractionDigits: 4,
                          enableSeparator: true,
                          separateSymbol: ' ',
                          textStyle: GTextStyles.monoBold,
                          duration: const Duration(milliseconds: 140),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget background(BuildContext context, {required Widget child}) {
    if (!highlighted) return child;

    return HighlightBackground(child: child);
  }

  @override
  double get height => 60;
}
