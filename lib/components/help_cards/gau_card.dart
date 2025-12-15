import 'package:flutter/material.dart';
import 'package:wallet/components/help_cards/_template.dart';

class LearnMoreGauGenericCard extends StatelessWidget {
  const LearnMoreGauGenericCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const LearnMoreTemplate(
      id: 'gau_generic_v2',
      text: 'Learn more about GAUGECASH',
      url:
          'https://www.youtube.com/playlist?list=PLZWguVRAz5geo5ipyhAXgYH_BClu5NFDq',
    );
  }
}
