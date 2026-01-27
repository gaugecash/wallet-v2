import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/components/inputs/primary.dart';
import 'package:wallet/screens/set_up/components/step.dart';
import 'package:wallet/screens/set_up/create/model.dart';

class SetUpCreate0PasswordStep extends SetUpStep {
  SetUpCreate0PasswordStep({super.key});

  @override
  int get page => 0;

  @override
  String get name => 'Create your password';

  @override
  Future<bool> Function(WidgetRef ref) get submit => (ref) async {
        // Just store the password and advance to confirmation page
        return true;
      };

  void listener(
    TextEditingController password,
    WidgetRef ref,
  ) {
    final provider = ref.read(setUpCreateProvider);

    if (provider.currentPage != page) {
      return;
    }

    final p1 = password.text;
    final validation = p1.isNotEmpty;

    setCanSubmit(ref, validation);
    provider.password = p1;
  }

  @override
  Widget buildContent(BuildContext context, WidgetRef ref) {
    final password = useTextEditingController();

    useEffect(() {
      void localListener() => listener(password, ref);
      password.addListener(localListener);
      return () {
        password.removeListener(localListener);
      };
    }, [password],);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GPrimaryInput(
          controller: password,
          label: 'Password',
          obscureText: true,
        ),
        const SizedBox(height: 8),
        Text(
          'We recommend at least 8 characters for better security',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
