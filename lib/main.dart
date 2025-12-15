import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:universal_html/html.dart';
import 'package:wallet/routes.dart';
import 'package:wallet/styling.dart';

// before release checklist:
// make sure biometrics works properly [esp on the latest android]

// TODO:
// - proper error handling [intro] + animations
// that's all for set up!
// todo dynamically switch the rpc provider in case of an error + check for available rpcs in the start of the app

bool urlInvestorMode = false;

void main() {
  if (kIsWeb) {
    final url = window.location.href;
    if (url.contains('#')) {
      window.location.href = url.split('#')[0];
    }

    if (url.contains('?')) {
      final query = url.split('?')[1];
      if (query == 'invest') {
        urlInvestorMode = true;
      }
    }
  }
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GAU Wallet',
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        checkboxTheme: CheckboxThemeData(
          checkColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return GColors.blackBlueish;
              }
              return null;
            },
          ),
          fillColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return null;
          }),
        ),

        // colorSchemeSeed: const Color(0xff6750a4),
        brightness: Brightness.dark,

        // splashFactory: MaterialInkSplash.splashFactory,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: GColors.backgroundScaffold,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(Colors.red),
          trackColor: WidgetStateProperty.all(Colors.blue),
          thickness: WidgetStateProperty.all(20),
        ),
      ),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const CupertinoScrollBehavior(),
          child: child!,
        );
      },
    );
  }
}
