import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/components/buttons/primary.dart';
import 'package:wallet/components/dialogs/calculator.dart';
import 'package:wallet/components/dialogs/tx.dart';
import 'package:wallet/components/inputs/primary.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/model_components/balance_swap.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/models/tx.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/styling.dart';

class SwapGauFragment extends HookConsumerWidget {
  const SwapGauFragment({super.key});

  // todo: abstract it all away [will GAUF will be easy to add for swap?]
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.read(walletProvider);

    final gau = wallet.currencies!.firstWhere(
      (el) => el.type == CurrencyTicker.gau,
    );

    final swapToken = wallet.currencies!.firstWhere(
      (el) => el.type == gauSwapCoin,
    );

    final matic = wallet.currencies!.firstWhere(
      (el) => el.type == CurrencyTicker.matic,
    );

    final maticBalance =
        useStream(matic.balance.stream, initialData: matic.balance.lastValue);

    final useMetaForFee = useState(false);

    useEffect(
      () {
        if (maticBalance.data != null && maticBalance.data == 0) {
          useMetaForFee.value = true;
        }
        return null;
      },
      [maticBalance],
    );

    final gauController = useTextEditingController();
    final maticController = useTextEditingController();

    final gauPriceStream = useStream(gau.price?.stream);
    final maticPriceStream = useStream(swapToken.price?.stream);

    final gauPrice = gauPriceStream.data ?? gau.price?.lastValue; // 1.73
    final maticPrice =
        maticPriceStream.data ?? swapToken.price?.lastValue; // 0.69

    // todo loading state [CRITICAL & EASY TO ACHIVE: the app will crash if the data is not present]
    final gauPriceInMatic = gauPrice! / maticPrice!;

    /// price is in swapToken
    final swapOrder = useState(SwapOrder.o21);

    final gauInput = GPaddingsLayoutHorizontal.sliver(
      child: GPrimaryInput(
        key: ValueKey(gau.type.ticker),
        label: gau.type.ticker,
        controller: gauController,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        currency: true,
        suffix: IconButton(
          onPressed: () async {
            final currentGau = double.tryParse(gauController.text) ?? 0;
            final newGau = await showCalculatorDialog(context, currentGau);
            if (newGau != null) {
              gauController.text = newGau.toString();
              maticController.text =
                  (newGau * gauPriceInMatic).toStringAsFixed(2);
            }
          },
          icon: const Icon(
            LucideIcons.calculator,
            color: GColors.white,
          ),
        ),
        onChanged: (str) {
          // todo: refactor into a more generic function/struct
          final gauVal = double.tryParse(str);
          if (gauVal == null) {
            maticController.clear();
            return;
          }
          // todo: [CRITICAL]: think of the rounding, it should be up, probably?
          maticController.text = (gauVal * gauPriceInMatic).toStringAsFixed(2);
        },
      ),
    );

    final maticInput = GPaddingsLayoutHorizontal.sliver(
      child: GPrimaryInput(
        key: ValueKey(swapToken.type.ticker),
        label: swapToken.type.ticker,
        controller: maticController,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        currency: true,
        onChanged: (str) {
          // todo: refactor into a more generic function/struct [+ tests]
          final maticVal = double.tryParse(str);
          if (maticVal == null) {
            gauController.clear();
            return;
          }
          // todo: [CRITICAL]: think of the rounding, it should be up, probably?
          gauController.text =
              (maticVal * (1 / gauPriceInMatic)).toStringAsFixed(2);
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
            c1: gau,
            c2: swapToken,
            order: swapOrder.value,
            onPressed: () {
              swapOrder.value = swapOrder.value == SwapOrder.o21
                  ? SwapOrder.o12
                  : SwapOrder.o21;
            },
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        if (swapOrder.value == SwapOrder.o21) maticInput,
        if (swapOrder.value == SwapOrder.o12) gauInput,
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        if (swapOrder.value == SwapOrder.o21) gauInput,
        if (swapOrder.value == SwapOrder.o12) maticInput,
        ...[
          SliverToBoxAdapter(
            child: SizedBox(height: GPaddings.small(context)),
          ),
          GPaddingsLayoutHorizontal.sliver(
            child: CheckboxListTile(
              title: const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Gasless swap (pay fee with token)',
                  style: GTextStyles.poppinsMediumButton,
                ),
              ),
              visualDensity: const VisualDensity(horizontal: -3, vertical: -4),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.trailing,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              value: useMetaForFee.value,
              onChanged: (el) {
                useMetaForFee.value = el!;
              },
            ),
          ),
        ],
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),

        GPaddingsLayoutHorizontal.sliver(
          child: GPrimaryButton(
            label: swapOrder.value == SwapOrder.o21
                ? 'Get GAU'
                : 'Get ${swapToken.type.ticker}',
            onPressed: () {
              late Future<Tx> tx;
              late TxData txData;

              if (swapOrder.value == SwapOrder.o21) {
                // if matic -> gau

                final value = double.tryParse(maticController.text);
                if (value == null) {
                  return;
                }

                txData = TxData(
                  amount: value,
                  currency: swapToken,
                );
                tx = swapToken.repo.swapAny(
                  txData,
                  swapToken.type,
                  gau.type,
                  ref,
                  useMetaForFee.value,
                );
              } else {
                // if gau -> matic

                final value = double.tryParse(gauController.text);
                if (value == null) {
                  return;
                }

                txData = TxData(
                  amount: value,
                  currency: gau,
                );
                tx = swapToken.repo.swapAny(
                  txData,
                  gau.type,
                  swapToken.type,
                  ref,
                  useMetaForFee.value,
                );
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
