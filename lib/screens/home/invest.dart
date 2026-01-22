import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wallet/components/alerts/info_alert.dart';
import 'package:wallet/components/alerts/success_alert.dart';
import 'package:wallet/components/buttons/_sizes.dart';
import 'package:wallet/components/buttons/primary.dart';
import 'package:wallet/components/buttons/secondary.dart';
import 'package:wallet/components/dialogs/tx.dart';
import 'package:wallet/components/expansion_tile.dart';
import 'package:wallet/components/inputs/primary.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/layouts/app_layout_sliver.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/model_components/balance_compact.dart';
import 'package:wallet/model_components/balance_swap.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/models/tx.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/repository/coins/gauf.dart';
import 'package:wallet/screens/set_up/components/page_indicator.dart';
import 'package:wallet/styling.dart';

// todo merge into a single compoennt with buy_gau.dart
@RoutePage()
class GaufInvestScreen extends HookConsumerWidget {
  const GaufInvestScreen({super.key});

  bool canContinue({
    required int step,
    required double maticValue,
  }) {
    switch (step) {
      case 0:
        return maticValue > 0.01;
      case 1:
        return false;
    }
    throw UnimplementedError('');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();

    final currentPage = useState(0);

    // todo fix by subscribing
    final matic = ref.read(walletProvider).currencies!.firstWhere(
          (element) => element.type == CurrencyTicker.matic,
        );

    final maticBalance = useStream(matic.balance.stream, initialData: matic.balance.lastValue);

    return AppLayoutSliver(
      showBackButton: true,
      children: [
        GPaddingsLayoutHorizontal.sliver(
          child: const Text(
            'Invest in GAU',
            style: GTextStyles.h1,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.medium(context))),
        GPaddingsLayoutHorizontal.sliver(
          child: DPageIndicator(pageController, steps: 2),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        SliverFillRemaining(
          child: Stack(
            children: [
              SafeArea(
                top: false,
                child: Padding(
                  padding: (currentPage.value == 0)
                      ? EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.width > breakPointWidth ? 210 : 170,
                        )
                      : EdgeInsets.zero,
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: pageController,
                    children: const [
                      GPaddingsLayoutHorizontal(child: _FirstStep()),
                      _SecondStep(),
                    ],
                  ),
                ),
              ),
              if (currentPage.value == 0)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (maticBalance.data! > 0.01)
                        const GPaddingsLayoutHorizontal(
                          child: SuccessAlertComponent(
                            text: "Hooray, you have POL!\nYou can click 'Continue'",
                          ),
                        ),
                      if (maticBalance.data! <= 0.01)
                        const GPaddingsLayoutHorizontal(
                          child: InfoAlertComponent(
                            text: 'You need to have POL to continue',
                          ),
                        ),
                      SizedBox(height: GPaddings.big(context)),
                      GPaddingsLayoutHorizontal(
                        child: GPrimaryButton(
                          label: 'Continue',
                          onPressed: pageController.positions.isNotEmpty &&
                                  canContinue(
                                    step: currentPage.value,
                                    maticValue: maticBalance.data ?? 0,
                                  )
                              ? () {
                                  pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeIn,
                                  );
                                  currentPage.value++;
                                }
                              : null,
                        ),
                      ),
                      SizedBox(
                        height: GPaddings.layoutVerticalPadding(context),
                      ),
                      const SafeArea(top: false, child: SizedBox()),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SecondStep extends HookConsumerWidget {
  const _SecondStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        GPaddingsLayoutHorizontal.sliver(
          child: Row(
            children: [
              const Icon(LucideIcons.coins),
              SizedBox(width: GPaddings.small(context)),
              const Text(
                'Buy GAUI with POL',
                style: GTextStyles.h2,
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.small(context))),
        GPaddingsLayoutHorizontal.sliver(
          child: const InfoAlertComponent(
            text: 'Congrats! You can invest in GAU now!',
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        const SliverFillRemaining(
          child: _GaufSwap(),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
      ],
    );
  }
}

class _GaufSwap extends HookConsumerWidget {
  const _GaufSwap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matic = ref.read(walletProvider).currencies!.firstWhere(
          (el) => el.type == CurrencyTicker.matic,
        );

    final gauf = ref.read(walletProvider).currencies!.firstWhere(
          (el) => el.type == CurrencyTicker.gauf,
        );

    /// price is in matic
    final rateStream = useMemoized(() => gauf.price, []);
    final rate = useStream(rateStream?.stream);
    // print('initial rate: ${rateStream.lastValue}');
    // print(rate.data ?? 'no rate');

    final gaufController = useTextEditingController();
    final maticController = useTextEditingController();

    final gaufPriceInMatic = rate.data ?? rateStream?.lastValue;

    final maticInput = GPaddingsLayoutHorizontal.sliver(
      child: GPrimaryInput(
        key: ValueKey(matic.type.ticker),
        label: matic.type.ticker,
        controller: maticController,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        currency: true,
        onChanged: (str) {
          // todo: refactor into a more generic function/struct [+ tests]
          final maticVal = double.tryParse(str);
          if (maticVal == null) {
            return;
          }
          if (gaufPriceInMatic == null) {
            return;
          }
          // todo: [CRITICAL]: think of the rounding, it should be up, probably?
          gaufController.text = (maticVal * (1 / gaufPriceInMatic)).toStringAsFixed(2);
        },
      ),
    );

    final gaufInput = GPaddingsLayoutHorizontal.sliver(
      child: GPrimaryInput(
        key: ValueKey(gauf.type.ticker),
        label: gauf.type.ticker,
        controller: gaufController,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        currency: true,
        onChanged: (str) {
          // todo: refactor into a more generic function/struct
          final gauVal = double.tryParse(str);
          if (gauVal == null) {
            return;
          }
          if (gaufPriceInMatic == null) {
            return;
          }
          // todo: [CRITICAL]: think of the rounding, it should be up, probably?
          maticController.text = (gauVal * gaufPriceInMatic).toStringAsFixed(2);
        },
      ),
    );

    return CustomScrollView(
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        // GPaddingsLayoutHorizontal.sliver(
        //   child: const Text('Invest in GAU', style: GTextStyles.h1),
        // ),
        // SliverToBoxAdapter(child: SizedBox(height: GPaddings.medium(context))),
        GPaddingsLayoutHorizontal.sliver(
          child: BalanceSwapCard(
            ctaIcon: LucideIcons.repeat,
            swapStateIcon: LucideIcons.arrowDown,
            c1: matic,
            c2: gauf,
            order: SwapOrder.o12,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        maticInput,
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        gaufInput,
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        GPaddingsLayoutHorizontal.sliver(
          child: GPrimaryButton(
            label: 'Buy GAUI',
            onPressed: () async {
              final value = double.tryParse(maticController.text);
              if (value == null) {
                return;
              }

              final repo = gauf.repo as GaufCoin;

              final txData = TxData(
                amount: value,
                currency: matic,
              );

              final tx = repo.buyTokens(txData);
              showTxDialog(context, txData, tx);
            },
          ),
        ),
      ],
    );
  }
}

class _FirstStep extends HookConsumerWidget {
  const _FirstStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.read(walletProvider);
    final addr = useFuture(useMemoized(() => wallet.wallet!.getAddress(), []));

    final matic = ref.read(walletProvider).currencies!.firstWhere(
          (element) => element.type == CurrencyTicker.matic,
        );

    return CustomScrollView(
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Row(
            children: [
              const Icon(LucideIcons.wallet),
              SizedBox(width: GPaddings.small(context)),
              const Text(
                'Get POL ',
                style: GTextStyles.h2,
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.medium(context))),
        SliverToBoxAdapter(
          child: BalanceCompactCard(
            model: matic,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        SliverToBoxAdapter(
          child: ConfigurableExpansionTile(
            header: Flexible(
              child: Row(
                children: [
                  const Icon(LucideIcons.helpCircle, size: 18),
                  SizedBox(width: GPaddings.small(context)),
                  const Text(
                    'How to get POL',
                    style: GTextStyles.h3,
                  ),
                ],
              ),
            ),
            animatedWidgetFollowingHeader: const Icon(LucideIcons.chevronDown, size: 20),
            childrenBody: Column(
              children: [
                SizedBox(height: GPaddings.medium(context)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1.',
                      style: GTextStyles.h4.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: GPaddings.small(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Buy POL using fiat money',
                            style: GTextStyles.h4,
                          ),
                          SizedBox(height: GPaddings.small(context)),
                          GSecondaryButton(
                            label: 'Buy with Credit Card',
                            size: GButtonSize.small,
                            icon: LucideIcons.arrowUpRight,
                            onPressed: () {
                              final wallet = addr.data;

                              final url = '''
                                  https://widget.onramper.com
                                  ?color=140025
                                  &onlyCryptos=matic
                                  &isAddressEditable=false
                                  &wallets=matic:$wallet
                                  &supportSell=false
                                  &apiKey=pk_prod_rOFZAVNmLXNumgb7VR7XgVZD0HMSWZoWMoluJMnrRi40
                                '''
                                  .split('\n')
                                  .map((e) => e.trim())
                                  .join();

                              logger.d('launching $url');

                              launchUrlString(url);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: GPaddings.medium(context)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2.',
                      style: GTextStyles.h4.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: GPaddings.small(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'If you already own POL, deposit it to this wallet',
                            style: GTextStyles.h4,
                          ),
                          SizedBox(height: GPaddings.small(context)),
                          GSecondaryButton(
                            label: 'Get Wallet Address',
                            size: GButtonSize.small,
                            icon: LucideIcons.arrowUpRight,
                            onPressed: () {
                              context.router.pushNamed('/coin/POL');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: GPaddings.big(context)),
                const InfoAlertComponent(
                  text: 'POL is required for making transaction on the Polygon Network',
                ),
                SizedBox(height: GPaddings.big(context)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
      ],
    );
  }
}
