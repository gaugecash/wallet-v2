import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/components/inputs/primary.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/layouts/app_layout_sliver.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/styling.dart';

@RoutePage()
class CalculatorScreen extends HookConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gau = useTextEditingController();
    final usd = useTextEditingController();

    final val =
        useMemoized(() => ref.read(walletProvider).currencies![0].price);
    final stream = useStream(val?.stream);

    final rate = stream.data ?? val?.lastValue;

    useEffect(
      () {
        if (gau.text.isEmpty && usd.text.isEmpty && rate != null) {
          usd.text = '1';
          gau.text = (1 / rate).toStringAsFixed(2);
        }
        return null;
      },
      [],
    );

    return AppLayoutSliver(
      showBackButton: true,
      children: [
        GPaddingsLayoutHorizontal.sliver(
          child: const Text(
            'Calculator',
            style: GTextStyles.h1,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.medium(context))),
        GPaddingsLayoutHorizontal.sliver(
          child: GPrimaryInput(
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
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        GPaddingsLayoutHorizontal.sliver(
          child: GPrimaryInput(
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
        ),
      ],
    );
  }
}
