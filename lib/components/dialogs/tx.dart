import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wallet/components/buttons/primary.dart';
import 'package:wallet/components/buttons/secondary.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/models/tx.dart';
import 'package:wallet/styling.dart';

void showTxDialog(BuildContext context, TxData data, Future<Tx> tx) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return TxDialog(data, tx);
    },
  );
}

class TxDialog extends HookWidget {
  const TxDialog(this.data, this.tx, {super.key});

  final TxData data;
  final Future<Tx> tx;

  BoxDecoration _boxDecoration(TxStatus status) {
    late Color color;
    late Color borderColor;

    switch (status) {
      case TxStatus.sending:
        color = GColors.white.withValues(alpha: 0.2);
        borderColor = GColors.white.withValues(alpha: 0.8);
        break;
      case TxStatus.error:
        color = GColors.redWarning.withValues(alpha: 0.2);
        borderColor = GColors.redWarningBorder.withValues(alpha: 0.8);
        break;
      case TxStatus.sent:
        color = GColors.greenSuccess.withValues(alpha: 0.2);
        borderColor = GColors.greenSuccessBorder.withValues(alpha: 0.8);
        break;
    }

    return BoxDecoration(
      color: color,
      border: Border.all(color: borderColor, width: 2),
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildTopBodySwap() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: double.infinity),
        Row(
          children: [
            const Text(
              'Swapping',
              style: GTextStyles.mulishBoldAlert,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${data.amount} ${data.currency.type.ticker}',
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: GTextStyles.mulishBoldAlert,
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildTopBodySend() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: double.infinity),
        Row(
          children: [
            const Text(
              'Sending',
              style: GTextStyles.mulishBoldAlert,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${data.amount} ${data.currency.type.ticker}',
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: GTextStyles.mulishBoldAlert,
              ),
            )
          ],
        ),
        Row(
          children: [
            const Text(
              'To',
              style: GTextStyles.mulishBoldAlert,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                data.address ?? '',
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: GTextStyles.monoTx,
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildTopBody() {
    // todo check against data type instead
    if (data.address != null) {
      return _buildTopBodySend();
    } else {
      return _buildTopBodySwap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tx = useFuture(this.tx);
    final events = tx.data?.events;

    AsyncSnapshot<TxEvent>? eventStream;
    if (events != null) {
      eventStream = useStream(useMemoized(() => events.stream));
    }

    late TxEvent status;

    if (events != null && events.lastValue != null) {
      status = events.lastValue!;
    } else {
      status = const TxEvent(status: TxStatus.sending);
    }

    // print('status: ${status.status.name}');

    return Center(
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Material(
            color: Colors.transparent,
            child: AnimatedContainer(
              width: 300,
              decoration: _boxDecoration(status.status),
              duration: const Duration(milliseconds: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 18,
                    ),
                    child: _buildTopBody(),
                  ),
                  Container(
                    color: GColors.white,
                    height: 2,
                    width: double.infinity,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (status.status == TxStatus.sending) ...[
                          const SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(
                              color: GColors.white,
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'In progress, do not close the wallet',
                            textAlign: TextAlign.center,
                            style: GTextStyles.mulishBoldAlert
                                .copyWith(fontSize: 12),
                          ),
                        ],
                        if (status.status == TxStatus.sent) ...[
                          const Text(
                            'Success',
                            style: GTextStyles.mulishBoldAlert,
                          ),
                          if (tx.data?.tx != null) ...[
                            const SizedBox(height: 12),
                            GSecondaryButton(
                              label: 'Open on polygonscan',
                              onPressed: () {
                                const url = network == Network.main
                                    ? mainPolygonScan
                                    : testPolygonScan;
                                launchUrlString('$url/tx/${tx.data!.tx}');
                              },
                            ),
                          ],
                          const SizedBox(height: 12),
                          GPrimaryButton(
                            label: 'Close',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                        if (status.status == TxStatus.error) ...[
                          const Text(
                            'Error!',
                            style: GTextStyles.mulishBoldAlert,
                          ),
                          Text(
                            (status as TxError).error,
                            style: GTextStyles.mulishBoldAlert,
                          ),
                          const SizedBox(height: 12),
                          GPrimaryButton(
                            label: 'Copy debug info & Exit',
                            onPressed: () {
                              copyLogsToClipboard();
                              Navigator.of(context).pop();
                            },
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
