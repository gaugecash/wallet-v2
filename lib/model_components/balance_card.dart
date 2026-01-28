import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/components/buttons/base.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/styling.dart';
import 'package:wallet/utils/gstream.dart';
// import 'package:websafe_svg/websafe_svg.dart';

class BalanceCard extends GButtonBase {
  const BalanceCard({
    required this.model,
    this.small = false,
    this.highlighted = false,
    this.heightVal = 74,
    super.onPressed,
    super.key,
  });

  final Currency model;
  final bool small;
  final bool highlighted;
  final double heightVal;

  Widget _buildTitle({bool big = false}) {
    final ic = SizedBox(
      width: 28,
      height: 28,
      child: Icon(
        model.type.icon,
        color: GColors.white,
        size: 26,
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
          style: GTextStyles.chivoRegularCurrency.copyWith(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // @override
  // String get heroTag => model.type.ticker;

  Widget get _buildArrow => const Icon(
        LucideIcons.arrowRight,
        color: GColors.white,
        size: 22,
      );

  @override
  Color get backgroundColor => GColors.cardBackground.withValues(alpha: 0.8);

  @override
  BorderSide get border => BorderSide(
        color: GColors.white.withValues(alpha: highlighted ? 0.6 : 0.4),
        width: 2,
      );

  @override
  BorderSide get focusedBorder => BorderSide(
        color: GColors.white.withValues(alpha: 0.6),
        width: 2.8,
      );

  @override
  double get elevation => highlighted ? 3 : 0;

  @override
  Widget body(BuildContext context) {
    return background(
      context,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.biggest.width;
          final key = ValueKey(MediaQuery.of(context));

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                SizedBox(
                  width: w > 290 ? 100 : 28,
                  child: _buildTitle(big: w > 290),
                ),
                const Spacer(),
                SizedBox(
                  width: 130,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GStreamBuilder<double>(
                      gStream: model.balance,
                      builder: (context, snapshot) {
                        var text = -0.00;
                        if (snapshot.hasData && snapshot.data != null) {
                          text = snapshot.data!;
                        }

                        return AnimatedDigitWidget(
                          key: key,
                          value: text,
                          fractionDigits: 2,
                          enableSeparator: true,
                          separateSymbol: ' ',
                          textStyle: GTextStyles.monoBold.copyWith(
                            fontSize: 18,
                          ),
                          duration: const Duration(milliseconds: 140),
                        );
                      },
                    ),
                  ),
                ),
                const Spacer(),
                if (w > 310) _buildArrow,
              ],
            ),
          );
        },
      ),
    );
  }

  Widget background(BuildContext context, {required Widget child}) {
    return child;
    // if (!highlighted) return child;
    //
    // return HighlightBackground(child: child);
  }

  @override
  double get height => heightVal;
}
