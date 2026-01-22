import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/components/alerts/info_alert.dart';
import 'package:wallet/components/alerts/success_alert.dart';
import 'package:wallet/components/buttons/_sizes.dart';
import 'package:wallet/components/buttons/primary.dart';
import 'package:wallet/components/buttons/secondary.dart';
import 'package:wallet/components/expansion_tile.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/layouts/app_layout_sliver.dart';
import 'package:wallet/model_components/balance_compact.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/screens/home/swap_gau.dart';
import 'package:wallet/screens/set_up/components/page_indicator.dart';
import 'package:wallet/styling.dart';

@RoutePage()
class BuyGauScreen extends HookConsumerWidget {
  const BuyGauScreen({super.key});

  bool canContinue({
    required int step,
    required double maticValue,
    required double usdtValue,
  }) {
    switch (step) {
      // case 0:
      //   return maticValue > 0.01;
      case 0:
        return usdtValue > 0.01;
      case 1:
        return false;
    }
    throw UnimplementedError('');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();

    final currentPage = useState(0);

    // todo fix
    final matic = ref.read(walletProvider).currencies!.firstWhere(
          (element) => element.type == CurrencyTicker.matic,
        );

    final usdt = ref.read(walletProvider).currencies!.firstWhere(
          (element) => element.type == CurrencyTicker.usdt,
        );

    final usdtBalance =
        useStream(usdt.balance.stream, initialData: usdt.balance.lastValue);

    return AppLayoutSliver(
      showBackButton: true,
      children: [
        GPaddingsLayoutHorizontal.sliver(
          child: const Text(
            'Buy GAU',
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
                  padding: (currentPage.value != 1)
                      ? EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.width >
                                  breakPointWidth
                              ? 210
                              : 170,
                        )
                      : EdgeInsets.zero,
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: pageController,
                    children: const [
                      _SecondStep(),
                      _ThirdStep(),
                    ],
                  ),
                ),
              ),
              if (currentPage.value != 1)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // if (currentPage.value == 0 && maticBalance.data! > 0.01)
                      //   const GPaddingsLayoutHorizontal(
                      //     child: SuccessAlertComponent(
                      //       text:
                      //           "Hooray, you have POL!\nYou can click 'Continue'",
                      //     ),
                      //   ),
                      // if (currentPage.value == 0 && maticBalance.data! <= 0.01)
                      //   const GPaddingsLayoutHorizontal(
                      //     child: InfoAlertComponent(
                      //       text: 'You need to have POL to continue',
                      //     ),
                      //   ),
                      if (currentPage.value == 0 && usdtBalance.data! > 0.01)
                        const GPaddingsLayoutHorizontal(
                          child: SuccessAlertComponent(
                            text:
                                "Great, you have USDT!\nYou can click 'Continue'",
                          ),
                        ),
                      if (currentPage.value == 0 && usdtBalance.data! <= 0.01)
                        const GPaddingsLayoutHorizontal(
                          child: InfoAlertComponent(
                            text: 'You need to have USDT to continue',
                          ),
                        ),
                      SizedBox(height: GPaddings.big(context)),
                      GPaddingsLayoutHorizontal(
                        child: GPrimaryButton(
                          label: 'Continue',
                          onPressed: pageController.positions.isNotEmpty &&
                                  canContinue(
                                    step: currentPage.value,
                                    maticValue: matic.balance.lastValue ?? 0,
                                    usdtValue: matic.balance.lastValue ?? 0,
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

class _ThirdStep extends HookConsumerWidget {
  const _ThirdStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        GPaddingsLayoutHorizontal.sliver(
          child: Row(
            children: [
              const Icon(LucideIcons.dollarSign),
              SizedBox(width: GPaddings.small(context)),
              const Text(
                'Swap USDT to GAU',
                style: GTextStyles.h2,
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.small(context))),
        GPaddingsLayoutHorizontal.sliver(
          child: const InfoAlertComponent(
            text: 'Congrats! You can get GAU now!',
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        const SliverFillRemaining(child: SwapGauFragment()),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
      ],
    );
  }
}

class _SecondStep extends HookConsumerWidget {
  const _SecondStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usdt = ref.read(walletProvider).currencies!.firstWhere(
          (element) => element.type == CurrencyTicker.usdt,
        );

    return CustomScrollView(
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        GPaddingsLayoutHorizontal.sliver(
          child: Row(
            children: [
              const Icon(LucideIcons.arrowLeftRight),
              SizedBox(width: GPaddings.small(context)),
              const Text(
                'Get USDT',
                style: GTextStyles.h2,
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.medium(context))),
        GPaddingsLayoutHorizontal.sliver(
          child: BalanceCompactCard(
            model: usdt,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),

        GPaddingsLayoutHorizontal.sliver(
          child: ConfigurableExpansionTile(
            header: Flexible(
              child: Row(
                children: [
                  const Icon(LucideIcons.helpCircle, size: 18),
                  SizedBox(width: GPaddings.small(context)),
                  const Text(
                    'How to get USDT',
                    style: GTextStyles.h3,
                  ),
                ],
              ),
            ),
            animatedWidgetFollowingHeader:
                const Icon(LucideIcons.chevronDown, size: 20),
            childrenBody: Column(
              children: [
                SizedBox(height: GPaddings.medium(context)),
                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Text(
                //       '1.',
                //       style:
                //           GTextStyles.h4.copyWith(fontWeight: FontWeight.w600),
                //     ),
                //     SizedBox(width: GPaddings.small(context)),
                //     Expanded(
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           const Text(
                //             'Buy USDT using fiat money',
                //             style: GTextStyles.h4,
                //           ),
                //           SizedBox(height: GPaddings.small(context)),
                //           GSecondaryButton(
                //             label: 'Buy with Credit Card',
                //             size: GButtonSize.small,
                //             icon: LucideIcons.arrowUpRight,
                //             onPressed: () {
                //               final wallet = addr.data;
                //
                //               final url = '''
                //                   https://widget.onramper.com
                //                   ?color=140025
                //                   &onlyCryptos=usdt_polygon
                //                   &isAddressEditable=false
                //                   &wallets=usdt_polygon:$wallet
                //                   &supportSell=false
                //                   &apiKey=pk_prod_rOFZAVNmLXNumgb7VR7XgVZD0HMSWZoWMoluJMnrRi40
                //                 '''
                //                   .split('\n')
                //                   .map((e) => e.trim())
                //                   .join();
                //
                //               logger.d('launching $url');
                //
                //               launchUrlString(url);
                //             },
                //           ),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
                // SizedBox(height: GPaddings.medium(context)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   '2.',
                    //   style:
                    //       GTextStyles.h4.copyWith(fontWeight: FontWeight.w600),
                    // ),
                    SizedBox(width: GPaddings.small(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Swap POL to USDT right in the GAU Wallet',
                            style: GTextStyles.h4,
                          ),
                          SizedBox(height: GPaddings.small(context)),
                          GSecondaryButton(
                            label: 'Open Swap',
                            size: GButtonSize.small,
                            icon: LucideIcons.arrowUpRight,
                            onPressed: () {
                              context.router.pushNamed('/swap?swap=matic_usdt');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: GPaddings.big(context)),
                const InfoAlertComponent(
                  text: 'USDT is needed to get GAU',
                ),
                SizedBox(height: GPaddings.big(context)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        // const SliverFillRemaining(child: SwapMaticFragment()),
        // SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
      ],
    );
  }
}

