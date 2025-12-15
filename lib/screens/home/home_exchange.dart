import 'package:animated_digit/animated_digit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/components/buttons/icon.dart';
import 'package:wallet/components/buttons/primary.dart';
import 'package:wallet/components/dialogs/tx.dart';
import 'package:wallet/components/inputs/primary.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/model_components/balance_card.dart';
import 'package:wallet/model_components/balance_compact.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/models/tx.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/styling.dart';
import 'package:wallet/utils/gstream.dart';

class MenuItem {
  const MenuItem({
    required this.text,
    required this.icon,
  });

  final String text;
  final IconData icon;
}

enum Type { give, receive }

final exchangeEstimateLoaderProvider = StateProvider<CurrencyTicker?>((_) => null);

class HomePageExchangeFragment extends HookConsumerWidget {
  const HomePageExchangeFragment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useAutomaticKeepAlive();

    final wallet = ref.read(walletProvider);

    final usdc = wallet.currencies!.firstWhere(
      (el) => el.type == CurrencyTicker.usdc,
    );

    final pol = wallet.currencies!.firstWhere(
      (el) => el.type == CurrencyTicker.matic,
    );

    final currency1 = useState<Currency>(pol);
    final currency2 = useState<Currency>(usdc);

    final currency1Input = useTextEditingController();
    final currency2Input = useTextEditingController();

    return CustomScrollView(
      primary: true,
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: GPaddings.tiny(context)),
        ),

        GPaddingsLayoutHorizontal.sliver(
          child: _ExchangeCoin(
            coin: currency1.value,
            otherCoin: currency2.value,
            all: wallet.currencies,
            coinController: currency1Input,
            otherCoinController: currency2Input,
            onChanged: (value) {
              currency1.value = value;
            },
            type: Type.give,
            changeOrder: () {
              final tmp = currency1.value;
              final tmpValue = currency1Input.text;

              currency1.value = currency2.value;
              currency1Input.text = currency2Input.text;

              currency2.value = tmp;
              currency2Input.text = tmpValue;
            },
          ),
        ),

        GPaddingsLayoutHorizontal.sliver(
          child: _ExchangeCoin(
            coin: currency2.value,
            coinController: currency2Input,
            otherCoinController: currency1Input,
            otherCoin: currency1.value,
            all: wallet.currencies,
            // controller: currency2Input,
            onChanged: (value) {
              currency2.value = value;
            },
            type: Type.receive,
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: GPaddings.small(context)),
        ),

        // 3.39 usdc I have
        GPaddingsLayoutHorizontal.sliver(
          child: GPrimaryButton(
            label: 'Exchange ${currency1.value.type.ticker} for ${currency2.value.type.ticker}',
            onPressed: currency1.value.type != currency2.value.type
                ? () {
                    late Future<Tx> tx;
                    late TxData txData;

                    final value = double.tryParse(currency1Input.text);
                    if (value == null) {
                      return;
                    }
                    txData = TxData(
                      amount: value,
                      currency: currency1.value,
                    );
                    tx = currency1.value.repo.swapAny(
                      txData,
                      currency1.value.type,
                      currency2.value.type,
                      ref,
                    );

                    showTxDialog(context, txData, tx);

                    // final from = currency1.value.type.name;
                    // final to = currency2.value.type.name;
                    // context.router.pushNamed('/exchange/${from}_$to');
                  }
                : null,
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: GPaddings.big(context)),
        ),

        GPaddingsLayoutHorizontal.sliver(
          child: const Text(
            'All tokens',
            style: GTextStyles.h2,
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: GPaddings.small(context)),
        ),

        for (final currency in wallet.currencies!.where((element) => !element.investOnly)) ...[
          GPaddingsLayoutHorizontal.sliver(
            child: Hero(
              tag: currency.type.ticker + '_exchange',
              child: BalanceCard(
                small: currency.type != CurrencyTicker.gau,
                heightVal: 60,
                model: currency,
                onPressed: () {
                  context.router.pushNamed('/coin/${currency.type.ticker}');
                },
                highlighted: currency.type == CurrencyTicker.gau,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: GPaddings.small(context)),
          ),
        ],

        SliverToBoxAdapter(
          child: SizedBox(height: GPaddings.small(context)),
        ),

        SliverToBoxAdapter(child: SizedBox(height: GPaddings.small(context))),
      ],
    );
  }
}

class _ExchangeCoin extends HookConsumerWidget {
  const _ExchangeCoin({
    required this.coin,
    required this.otherCoin,
    required this.all,
    required this.onChanged,
    required this.type,
    required this.coinController,
    required this.otherCoinController,
    this.changeOrder,
  });

  final Currency coin;
  final Currency otherCoin;
  final List<Currency>? all;
  final Function(Currency calue) onChanged;
  final Type type;
  final TextEditingController coinController;
  final TextEditingController otherCoinController;

  final Function()? changeOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = (all ?? []).where(
      (element) => !element.investOnly,
    );

    final loader = ref.watch(exchangeEstimateLoaderProvider);

    Future<void> recalculateOther(String str) async {
      final val = double.tryParse(str);
      if (val == null) {
        otherCoinController.clear();
        return;
      }

      ref.read(exchangeEstimateLoaderProvider.notifier).update((_) => otherCoin.type);

      logger.i('calculating for ${coin.type} ${otherCoin.type}');
      final calculation = await coin.repo.estimateAny(val, coin.type, otherCoin.type, ref);
      logger.i('calculated: $calculation');

      final newValue = calculation.toStringAsFixed(2);
      if (otherCoinController.text != newValue) {
        otherCoinController.text = newValue;
      }

      ref.read(exchangeEstimateLoaderProvider.notifier).update((_) => null);
    }

    useEffect(
      () {
        Future.delayed(const Duration(milliseconds: 100), () {
          recalculateOther(coinController.text);
        });
        return;
      },
      [coin, otherCoin],
    );

    return Column(
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButton2(
            customButton: Row(
              key: Key(coin.type.name),
              children: [
                if (loader == coin.type)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: GColors.white,
                      ),
                    ),
                  ),
                Expanded(
                  child: GPrimaryInput(
                    key: Key(coin.type.name),
                    label: type == Type.give ? 'You Pay' : 'You Get',
                    controller: coinController,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: false,
                      decimal: true,
                    ),
                    currency: true,
                    onChanged: recalculateOther,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: GColors.white.withOpacity(0.2),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        coin.type.icon,
                        color: GColors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.chevronDown),
                    ],
                  ),
                ),
              ],
            ),
            items: coins.map((currency) {
              final selected = currency.type == coin.type;

              return DropdownMenuItem<MenuItem>(
                enabled: !selected,
                value: MenuItem(
                  text: currency.type.name,
                  icon: LucideIcons.fileQuestion,
                ),
                child: Opacity(
                  opacity: selected ? 0.6 : 1,
                  child: BalanceCompactCard(
                    model: currency,
                    noBorder: true,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              onChanged(
                all!.firstWhere(
                  (element) => element.type.name == value!.text,
                ),
              );
            },
            buttonStyleData: ButtonStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.transparent,
              ),
              overlayColor: const MaterialStatePropertyAll(Colors.transparent),
            ),
            dropdownStyleData: DropdownStyleData(
              elevation: 24,
              // width: 1000,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: GColors.backgroundScaffold,
                border: Border.all(
                  color: GColors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              offset: const Offset(0, -2),
            ),
            menuItemStyleData: const MenuItemStyleData(
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        // const SizedBox(height: 3),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Balance: ',
                    style: GTextStyles.mulishMedium.copyWith(fontSize: 13),
                  ),
                  SizedBox(
                    child: GStreamBuilder<double>(
                      key: Key(coin.type.ticker),
                      gStream: coin.balance,
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
                            textStyle: GTextStyles.monoBold.copyWith(
                              fontSize: 13,
                            ),
                            duration: const Duration(milliseconds: 140),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    coin.type.ticker,
                    style: GTextStyles.chivoRegularCurrency.copyWith(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const Expanded(child: SizedBox()),
              if (changeOrder != null)
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: GIconButton(
                    icon: LucideIcons.repeat,
                    onPressed: changeOrder,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
