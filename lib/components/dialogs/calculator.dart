import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/components/buttons/secondary.dart';
import 'package:wallet/components/inputs/primary.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/styling.dart';

/// takes in value in gau
/// returns value in gau
// todo: make more generic & reusable
Future<double?> showCalculatorDialog(BuildContext context, double gau) {
  return showDialog<double>(
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.6),
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Material(
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
              child: _CalculatorDialog(gauValue: gau),
            ),
          ),
        ),
      );
    },
  );
}

// todo: make calculator a class or something
// todo: as this is just copy-paste
class _CalculatorDialog extends HookConsumerWidget {
  const _CalculatorDialog({required this.gauValue});

  final double gauValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gau = useTextEditingController();
    final usd = useTextEditingController();

    final val = useMemoized(() => ref.read(walletProvider).currencies![0].price);
    final stream = useStream(val?.stream);

    final rate = stream.data ?? val!.lastValue;

    useEffect(
      () {
        if (gauValue != 0 && rate != null) {
          gau.text = gauValue.toStringAsFixed(2);
          usd.text = (gauValue * rate).toStringAsFixed(2);
        }
        return null;
      },
      [],
    );

    return Container(
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: GColors.white.withOpacity(0.1),
        border: Border.all(
          color: GColors.white.withOpacity(0.8),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GPrimaryInput(
            label: 'GAU',
            controller: gau,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            currency: true,
            onChanged: (str) {
              final val = double.tryParse(str);
              if (val == null) {
                return;
              }
              if (rate == null) {
                return;
              }
              usd.text = (val * rate).toStringAsFixed(2);
            },
          ),
          const SizedBox(height: 18),
          GPrimaryInput(
            label: 'USD',
            controller: usd,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            currency: true,
            onChanged: (str) {
              final val = double.tryParse(str);
              if (val == null) {
                return;
              }
              if (rate == null) {
                return;
              }
              gau.text = (val * (1 / rate)).toStringAsFixed(2);
            },
          ),
          const SizedBox(height: 32),
          GSecondaryButton(
            label: 'Done',
            onPressed: () {
              final newGau = double.tryParse(gau.text) ?? 0;
              Navigator.pop(context, newGau);
            },
          ),
        ],
      ),
    );
  }
}
