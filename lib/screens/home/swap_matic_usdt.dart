import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/components/buttons/primary.dart';
import 'package:wallet/components/dialogs/tx.dart';
import 'package:wallet/components/inputs/primary.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/model_components/balance_swap.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/models/tx.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/repository/coins/matic.dart';
import 'package:wallet/repository/coins/usd.dart';

class SwapMaticFragment extends HookConsumerWidget {
  const SwapMaticFragment({super.key});

  // todo: abstract it all away [will GAUF will be easy to add for swap?]
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.read(walletProvider);

    final matic = wallet.currencies!.firstWhere(
      (el) => el.type == CurrencyTicker.matic,
    );

    final usdt = wallet.currencies!.firstWhere(
      (el) => el.type == CurrencyTicker.usdt,
    );

    final maticController = useTextEditingController();
    final usdtController = useTextEditingController();

    final maticPriceStream = useStream(matic.price?.stream);
    final usdtPriceStream = useStream(usdt.price?.stream);

    final maticPrice = maticPriceStream.data ?? matic.price?.lastValue; // 1.73
    final usdtPrice = usdtPriceStream.data ?? usdt.price?.lastValue; // 0.69
    // print('matic: ${maticPrice}, usdt: ${usdtPrice}');
    //
    // // todo loading state [CRITICAL & EASY TO ACHIVE: the app will crash if the data is not present]
    final maticPriceInUsdt = maticPrice! / usdtPrice!;
    // final

    /// price is in swapToken
    final swapOrder = useState(SwapOrder.o12);

    final maticInput = GPaddingsLayoutHorizontal.sliver(
      child: GPrimaryInput(
        key: ValueKey(matic.type.ticker),
        label: matic.type.ticker,
        controller: maticController,
        keyboardType: const TextInputType.numberWithOptions(
          signed: false,
          decimal: true,
        ),
        currency: true,
        onChanged: (str) {
          // todo: refactor into a more generic function/struct
          final maticVal = double.tryParse(str);
          if (maticVal == null) {
            usdtController.clear();
            return;
          }
          if (maticPriceInUsdt == null) {
            return;
          }
          // // todo: [CRITICAL]: think of the rounding, it should be up, probably?
          usdtController.text = (maticVal * maticPriceInUsdt).toStringAsFixed(2);
        },
      ),
    );

    final usdtInput = GPaddingsLayoutHorizontal.sliver(
      child: GPrimaryInput(
        key: ValueKey(usdt.type.ticker),
        label: usdt.type.ticker,
        controller: usdtController,
        keyboardType: const TextInputType.numberWithOptions(
          signed: false,
          decimal: true,
        ),
        currency: true,
        onChanged: (str) {
          // todo: refactor into a more generic function/struct [+ tests]
          final usdtVal = double.tryParse(str);
          if (usdtVal == null) {
            maticController.clear();
            return;
          }
          if (maticPriceInUsdt == null) {
            return;
          }
          // todo: [CRITICAL]: think of the rounding, it should be up, probably?
          maticController.text = (usdtVal * (1 / maticPriceInUsdt)).toStringAsFixed(2);
        },
      ),
    );

    return CustomScrollView(
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        // GPaddingsLayoutHorizontal.sliver(
        //   child: const Text('Swap', style: GTextStyles.h1),
        // ),
        // SliverToBoxAdapter(child: SizedBox(height: GPaddings.medium(context))),
        GPaddingsLayoutHorizontal.sliver(
          child: BalanceSwapCard(
            ctaIcon: LucideIcons.repeat,
            swapStateIcon: LucideIcons.arrowDown,
            c1: matic,
            c2: usdt,
            order: swapOrder.value,
            onPressed: () {
              swapOrder.value = swapOrder.value == SwapOrder.o21 ? SwapOrder.o12 : SwapOrder.o21;
            },
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        if (swapOrder.value == SwapOrder.o21) usdtInput,
        if (swapOrder.value == SwapOrder.o12) maticInput,
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        if (swapOrder.value == SwapOrder.o21) maticInput,
        if (swapOrder.value == SwapOrder.o12) usdtInput,
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        GPaddingsLayoutHorizontal.sliver(
          child: GPrimaryButton(
            label: swapOrder.value == SwapOrder.o21 ? 'Get ${matic.type.ticker}' : 'Get ${usdt.type.ticker}',
            onPressed: () {
              late Future<Tx> tx;
              late TxData txData;

              if (swapOrder.value == SwapOrder.o21) {
                // // if usdt -> matic
                //
                final value = double.tryParse(usdtController.text);
                if (value == null) {
                  return;
                }
                txData = TxData(
                  amount: value,
                  currency: usdt,
                );

                tx = usdt.repo.swapAny(txData, usdt.type, matic.type, ref);
              } else {
                // // if matic -> usdt
                //
                final value = double.tryParse(maticController.text);
                if (value == null) {
                  return;
                }

                txData = TxData(
                  amount: value,
                  currency: matic,
                );

                tx = usdt.repo.swapAny(txData, matic.type, usdt.type, ref);
              }

              showTxDialog(context, txData, tx);
            },
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        // SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        // GPaddingsLayoutHorizontal.sliver(
        //   child: const Text('Or buy via Credit Card', style: GTextStyles.h1),
        // ),
        // SliverToBoxAdapter(child: SizedBox(height: GPaddings.medium(context))),
        // GPaddingsLayoutHorizontal.sliver(
        //   child: GSecondaryButton(
        //     label: 'Buy USDT',
        //     onPressed: (){
        //       final wallet = addr.data;
        //
        //       final url = '''
        //         https://widget.onramper.com
        //         ?color=140025
        //         &onlyCryptos=usdt_polygon
        //         &isAddressEditable=false
        //         &wallets=usdt_polygon:$wallet
        //         &supportSell=false
        //         &apiKey=pk_prod_rOFZAVNmLXNumgb7VR7XgVZD0HMSWZoWMoluJMnrRi40
        //       '''.split('\n').map((e) => e.trim()).join();
        //
        //       print('launching $url');
        //
        //       launchUrlString(url);
        //     },
        //   ),
        // ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.medium(context))),
      ],
    );
  }
}
