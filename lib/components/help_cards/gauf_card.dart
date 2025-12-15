import 'package:flutter/material.dart';
import 'package:wallet/components/help_cards/_template.dart';

class LearnMoreGaufGenericCard extends StatelessWidget {
  const LearnMoreGaufGenericCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const LearnMoreTemplate(
      id: 'gauf_generic',
      text: 'Learn how to invest in GAU',
      url: 'https://gaugecash.gitbook.io/gaugecash/gaugefield/introduction',
    );
  }
}
