import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:wallet/components/buttons/_sizes.dart';
import 'package:wallet/components/buttons/secondary.dart';
import 'package:wallet/components/dialogs/_generic.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/styling.dart';

void showPolygonReminderDialog(BuildContext context) {
  showDialog(
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.6),
    context: context,
    builder: (BuildContext context) {
      return GenericDialog(
        backgroundColor: GColors.redWarning.withOpacity(0.2),
        borderColor: GColors.redWarningBorder.withOpacity(0.8),
        autoDismiss: null,
        dismissible: false,
        child: const _PolygonReminderDialog(),
      );
    },
  );
}

class _PolygonReminderDialog extends HookWidget {
  const _PolygonReminderDialog();

  @override
  Widget build(BuildContext context) {
    final canContinueSeconds = useState<int>(6);
    useMemoized(
      () async {
        while (canContinueSeconds.value != 0) {
          await Future.delayed(const Duration(seconds: 1));
          canContinueSeconds.value--;
        }
      },
      [],
    );

    return SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reminder!', style: GTextStyles.mulishBlackDisplay),
          SizedBox(height: GPaddings.big(context)),
          Text(
            'The wallet operates on the Polygon Network.',
            style: GTextStyles.mulishText.copyWith(
              fontSize: 18,
            ),
          ),
          SizedBox(height: GPaddings.small(context)),
          Text(
            'Sending funds to a network other than Polygon will result in their loss.',
            style: GTextStyles.mulishText.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: GPaddings.big(context)),
          GSecondaryButton(
            label: canContinueSeconds.value != 0
                ? 'I understand (${canContinueSeconds.value})'
                : 'I understand',
            onPressed: canContinueSeconds.value != 0
                ? null
                : () {
                    Hive.box<String>(safeBox)
                        .put('startup_polygon_warning_shown', 'true');
                    Navigator.of(context).pop();
                  },
            size: GButtonSize.small,
          ),
        ],
      ),
    );
  }
}
