import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet/components/buttons/icon.dart';
import 'package:wallet/components/dialogs/success.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/styling.dart';

class ReceiveCurrencyTab extends HookConsumerWidget {
  const ReceiveCurrencyTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useAutomaticKeepAlive();

    final wallet = ref.read(walletProvider);
    final addr = useFuture(useMemoized(() => wallet.wallet!.getAddress(), []));

    if (addr.data == null) {
      return const SizedBox();
    }

    final wideScreen = MediaQuery.of(context).size.width > breakPointWidth;

    return CustomScrollView(
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.small(context))),
        SliverToBoxAdapter(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: GColors.white.withOpacity(0.6),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: AutoSizeText(
                    addr.data.toString(),
                    style: GTextStyles.monoAddr,
                    maxLines: 2,
                    maxFontSize: 22,
                    minFontSize: 13,
                  ),
                ),
              ),
              SizedBox(width: GPaddings.small(context)),
              GIconButton(
                icon: LucideIcons.share2,
                onPressed: () {
                  Share.share(addr.data.toString());
                },
              ),
              SizedBox(width: GPaddings.small(context)),
              GIconButton(
                icon: LucideIcons.copy,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: addr.data.toString()));
                  showSuccessDialog(context);
                },
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.small(context))),
        SliverToBoxAdapter(
          child: Center(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: QrImageView(
                data: addr.data.toString(),
                size: 280.0,
                version: QrVersions.auto,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: GPaddings.small(context))),
      ],
    );
  }
}
