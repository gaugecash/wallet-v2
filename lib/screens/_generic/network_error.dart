import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:wallet/components/buttons/secondary.dart';
import 'package:wallet/layouts/base.dart';
import 'package:wallet/styling.dart';

@RoutePage()
class NetworkErrorScreen extends StatelessWidget {
  const NetworkErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Internet error: cannot connect to polygon-rpc.com',
            style: GTextStyles.mulishBlackDisplay,
          ),
          const SizedBox(height: 16),
          GSecondaryButton(
            label: 'Try again',
            onPressed: () {
              context.router.pushNamed('/');
              context.router.removeWhere((route) => route.path != '/');
            },
          )
        ],
      ),
    );
  }
}
