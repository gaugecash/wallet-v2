import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wallet/components/buttons/primary.dart';
import 'package:wallet/components/buttons/secondary.dart';
import 'package:wallet/components/buttons/transparent.dart';
import 'package:wallet/components/dialogs/error.dart';
import 'package:wallet/components/dialogs/loading.dart';
import 'package:wallet/components/dialogs/success.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/layouts/app_layout_sliver.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/repository/coins/erc20.dart';
import 'package:wallet/repository/simple_swap_exchange.dart';
import 'package:wallet/services/share_file.dart';
import 'package:wallet/services/wallet_backup.dart';
import 'package:wallet/styling.dart';
import 'package:wallet/utils/git_commit.dart';

@RoutePage()
class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.read(walletProvider);
    // final addrM = useMemoized(() => wallet.wallet!.getAddress());
    // final addr = useFuture<EthereumAddress>(addrM);

    final versionData = useFuture(useMemoized(PackageInfo.fromPlatform, []));
    final gitCode = useFuture(useMemoized(getGitCommit, []));

    final version = versionData.data != null ? versionData.data!.version : '';
    final versionCode =
        versionData.data != null ? versionData.data!.buildNumber : '';

    final investorMode = useMemoized(
      () =>
          Hive.box<String>(safeBox).get('investor_mode', defaultValue: 'false'),
      [],
    );

    final enableExchange = useMemoized(
      () => Hive.box<String>(safeBox)
          .get('enable_exchange', defaultValue: 'false'),
      [],
    );

    final wmaticRepo = useMemoized(
      () => Erc20Coin(
        client: wallet.client,
        wallet: wallet.wallet!,
        addr: mainWmaticAddress,
        decimals: 18,
      ),
    );

    final isWmatic = useFuture(
      useMemoized(() async {
        final addr = await wallet.wallet?.getAddress();
        print('got address: $addr');
        final maticBalance = await wmaticRepo.getBalanceSingle(addr!);
        print('maticBalance: $maticBalance');
        return maticBalance;
      }),
    );

    final withdrawnWmatic = useState(false);

    final showExchange =
        kIsWeb || !['ios', 'macos'].contains(Platform.operatingSystem);

    return AppLayoutSliver(
      showBackButton: true,
      children: [
        // GPaddingsLayoutHorizontal.sliver(
        //   child: const Text('Settings', style: GTextStyles.h1),
        // ),

        SliverToBoxAdapter(child: SizedBox(height: GPaddings.medium(context))),

        if (isWmatic.data != 0 &&
            isWmatic.data != null &&
            !withdrawnWmatic.value)
          GPaddingsLayoutHorizontal.sliver(
            child: GPrimaryButton(
              label: 'Recover failed transactions (${isWmatic.data} POL)',
              onPressed: () async {
                showLoadingDialog(context);

                final simpleSwap = SimpleSwapExchangeFunctions(
                  wallet: wallet.wallet!,
                  client: wallet.client,
                );

                await simpleSwap.withdrawWmatic();

                withdrawnWmatic.value = true;

                Navigator.pop(context);
                showSuccessDialog(context);
              },
            ),
          ),

        if (isWmatic.data != 0 &&
            isWmatic.data != null &&
            !withdrawnWmatic.value)
          SliverToBoxAdapter(
            child: SizedBox(height: GPaddings.big(context)),
          ),

        if (showExchange)
          GPaddingsLayoutHorizontal.sliver(
            child: SwitchListTile(
              visualDensity: const VisualDensity(vertical: 1.5),
              tileColor: GColors.blackBlueish.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: GColors.white.withValues(alpha: 0.4),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Exchange (beta)',
                style: GTextStyles.poppinsMediumButton.copyWith(
                  color: enableExchange == 'true'
                      ? GColors.white
                      : GColors.white.withValues(alpha: 0.9),
                ),
              ),
              value: enableExchange == 'true',
              activeColor: GColors.white,
              // inactiveThumbColor: GColors.white.withValues(alpha: 0.4),
              onChanged: (bool? value) async {
                await Hive.box<String>(safeBox).put(
                  'enable_exchange',
                  enableExchange == 'false' ? 'true' : 'false',
                );

                context.router.pushNamed('/');
                context.router.removeWhere((route) => route.path != '/');
              },
            ),
          ),

        if (showExchange)
          SliverToBoxAdapter(child: SizedBox(height: GPaddings.small(context))),

        GPaddingsLayoutHorizontal.sliver(
          child: SwitchListTile(
            visualDensity: const VisualDensity(vertical: 1.5),
            tileColor: GColors.blackBlueish.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: GColors.white.withValues(alpha: 0.4),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Investor mode',
              style: GTextStyles.poppinsMediumButton.copyWith(
                color: investorMode != 'false'
                    ? GColors.white
                    : GColors.white.withValues(alpha: 0.9),
              ),
            ),
            value: investorMode != 'false',
            activeColor: GColors.white,
            // inactiveThumbColor: GColors.white.withValues(alpha: 0.4),
            onChanged: (bool? value) async {
              await Hive.box<String>(safeBox).put(
                'investor_mode',
                investorMode == 'false' ? 'true' : 'false',
              );

              context.router.pushNamed('/');
              context.router.removeWhere((route) => route.path != '/');
            },
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.medium(context))),

        GPaddingsLayoutHorizontal.sliver(
          child: GSecondaryButton(
            label: 'Copy the debug log',
            onPressed: () async {
              copyLogsToClipboard();
              showSuccessDialog(context);
            },
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.small(context))),
        GPaddingsLayoutHorizontal.sliver(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              'This creates an encrypted file you can save anywhere. Your password protects it.',
              style: TextStyle(
                color: GColors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.small(context))),
        GPaddingsLayoutHorizontal.sliver(
          child: GPrimaryButton(
            label: 'Export the backup file',
            onLongPress: () async {
              final mnemonic = Hive.box<String>(safeBox).get('mnemonic');
              if (mnemonic == null) {
                showErrorDialog(context, 'Unable to get seed phrase');
                return;
              }

              Clipboard.setData(ClipboardData(text: mnemonic));

              showSuccessDialog(
                context,
                message: 'Seed phrase copied to clipboard',
                autoDismiss: false,
              );
            },
            onPressed: () async {
              final file = wallet.getBackupWallet();
              if (file == null) {
                return;
              }
              shareFile(file, context);
            },
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: GPaddings.small(context))),

        // SliverToBoxAdapter(child: SizedBox(height: GPaddings.small(context))),
        // GPaddingsLayoutHorizontal.sliver(
        //   child: GSecondaryButton(
        //     label: investorMode != 'false'
        //         ? 'Disable investor mode'
        //         : 'Enable investor mode',
        //     onPressed: () async {
        //       await Hive.box<String>(safeBox).put(
        //         'investor_mode',
        //         investorMode == 'false' ? 'true' : 'false',
        //       );
        //
        //       context.router.pushNamed('/');
        //       context.router.removeWhere((route) => route.path != '/');
        //     },
        //   ),
        // ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.small(context))),
        GPaddingsLayoutHorizontal.sliver(
          child: GSecondaryButton(
            label: 'Log Out',
            onPressed: () async {
              showLoadingDialog(context);
              await Hive.box<String>(safeBox).clear();
              Navigator.pop(context);

              context.router.pushNamed('/');
              context.router.removeWhere((route) => route.path != '/');
            },
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.big(context))),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.medium(context))),
        GPaddingsLayoutHorizontal.sliver(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GTransparentButton(
                child: const Icon(
                  LucideIcons.globe,
                  color: GColors.white,
                ),
                onPressed: () {
                  launchUrlString('https://gaugecash.com');
                },
              ),
              GTransparentButton(
                child: const Icon(
                  LineIcons.telegram,
                  color: GColors.white,
                  size: 26,
                ),
                onPressed: () {
                  launchUrlString('https://t.me/gaugecashchat');
                },
              ),
              GTransparentButton(
                child: const Icon(
                  LucideIcons.twitter,
                  color: GColors.white,
                ),
                onPressed: () {
                  launchUrlString('https://twitter.com/GaugeCash');
                },
              ),
              GTransparentButton(
                child: const Icon(
                  LucideIcons.linkedin,
                  color: GColors.white,
                ),
                onPressed: () {
                  launchUrlString('https://www.linkedin.com/company/gaugecash');
                },
              ),
              GTransparentButton(
                child: const Icon(
                  LucideIcons.github,
                  color: GColors.white,
                ),
                onPressed: () {
                  launchUrlString('https://github.com/gaugecash');
                },
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.tiny(context))),
        GPaddingsLayoutHorizontal.sliver(
          child: Center(
            child: GTransparentButton(
              onPressed: () {
                // launchUrl(Uri.parse('https://github.com/gaugecash/wallet'));
                launchUrlString('https://gaugecash.com');
              },
              child: Text(
                'GAU wallet v$version+$versionCode (${gitCode.data ?? ''})',
                style: GTextStyles.mulishVersionText.copyWith(
                  color: GColors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        ),
        // SliverToBoxAdapter(child: SizedBox(height: GPaddings.tiny(context))),
        // GPaddingsLayoutHorizontal.sliver(
        //   child: Center(
        //     child: GTransparentButton(
        //       onPressed: () {
        //         launchUrlString('https://www.gaugecash.com');
        //       },
        //       child: Text(
        //         '(c) gaugecash.com',
        //         style: GTextStyles.mulishVersionText.copyWith(
        //           color: GColors.white.withValues(alpha: 0.8),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
