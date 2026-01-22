import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/components/slivers/spacing.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/styling.dart';

// todo animate it somehow
class LearnMoreTemplate extends HookWidget {
  const LearnMoreTemplate({
    required this.id,
    required this.url,
    required this.text,
    super.key,
  });

  final String text;
  final String url;
  final String id;

  @override
  Widget build(BuildContext context) {
    final display =
        useState(Hive.box<String>(safeBox).get('help_$id') != 'false');

    if (!display.value) {
      return const SizedBox();
    }

    return Padding(
      padding: EdgeInsets.only(top: GPaddings.small(context)),
      child: InkWell(
        onTap: () {
          launchUrl(Uri.parse(url));
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          // height: 50,
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                GColors.cardBackground.withOpacity(1),
                GColors.backgroundScaffoldAccent.withOpacity(0.5),
                GColors.backgroundScaffoldAccent.withOpacity(1),
              ],
            ),
          ),
          child: Row(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 18),
              const Icon(
                LucideIcons.helpCircle,
                size: 18,
                color: GColors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(text, style: GTextStyles.mulishMedium),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  Hive.box<String>(safeBox).put('help_$id', 'false');
                  display.value = false;
                },
                icon: const Icon(
                  LucideIcons.x,
                  color: GColors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
