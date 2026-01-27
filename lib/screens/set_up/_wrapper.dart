import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/components/buttons/primary.dart';
import 'package:wallet/components/dialogs/error.dart';
import 'package:wallet/components/dialogs/loading.dart';
import 'package:wallet/layouts/app_layout.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/screens/set_up/_model.dart';
import 'package:wallet/screens/set_up/components/page_indicator.dart';
import 'package:wallet/screens/set_up/components/step.dart';
import 'package:wallet/screens/set_up/create/model.dart';
import 'package:wallet/screens/set_up/create/s0_password.dart';
import 'package:wallet/screens/set_up/create/s2_security.dart';
import 'package:wallet/screens/set_up/restore/model.dart';
import 'package:wallet/screens/set_up/restore/s0_file.dart';
import 'package:wallet/screens/set_up/restore/s1_password.dart';

enum SetUpAction { create, restore }

@RoutePage()
class SetUpCreateScreen extends StatelessWidget {
  const SetUpCreateScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const _SetUpWrapperScreen(SetUpAction.create);
}

@RoutePage()
class SetUpRestoreScreen extends StatelessWidget {
  const SetUpRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const _SetUpWrapperScreen(SetUpAction.restore);
}

class _SetUpWrapperScreen extends HookConsumerWidget {
  const _SetUpWrapperScreen(this.action, {super.key});

  final SetUpAction action;

  List<SetUpStep> get steps {
    logger.d('getting the steps');
    if (action == SetUpAction.create) {
      return [
        SetUpCreate0PasswordStep(),
        // SetUpCreate1FileStep removed - Phase 1 uses silent auto-backup instead
        const SetUpCreate2SecurityStep(),
      ];
    }

    if (action == SetUpAction.restore) {
      return [
        const SetUpRestore0FileStep(),
        SetUpRestore1PasswordStep(),
        const SetUpCreate2SecurityStep(),
      ];
    }

    throw UnimplementedError();
  }

  SetUpModel model(WidgetRef ref) {
    if (action == SetUpAction.create) {
      return ref.watch(setUpCreateProvider);
    }
    if (action == SetUpAction.restore) {
      return ref.watch(setUpRestoreProvider);
    }
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();

    useEffect(
      () {
        ref.refresh(setUpCreateProvider);
        ref.refresh(setUpRestoreProvider);
        return null;
      },
      [],
    );

    final provider = model(ref);

    return AppLayout(
      showBackButton: true,
      child: Column(
        children: [
          DPageIndicator(pageController),
          const SizedBox(height: 22),
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              children: steps,
              onPageChanged: (value) => provider.currentPage = value,
            ),
          ),
          const SizedBox(height: 22),
          Hero(
            tag: action == SetUpAction.create ? 'primary' : 'secondary',
            child: GPrimaryButton(
              label: provider.currentPage != 1 ? 'Continue ' : 'Finish',
              onPressed: provider.canContinue
                  ? () async {
                      final page = steps[provider.currentPage];
                      showLoadingDialog(context);
                      final result = await page.submit(ref);
                      Navigator.pop(context);
                      await Future.delayed(Duration.zero);
                      FocusManager.instance.primaryFocus?.unfocus();

                      if (result) {
                        if (provider.currentPage == 1) {
                          context.router.pushNamed('/');
                          context.router
                              .removeWhere((route) => route.path != '/');
                          return;
                        }
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                        provider.canContinue = false;
                      } else {
                        showErrorDialog(context, 'Error');
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
