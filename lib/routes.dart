import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:wallet/screens/_generic/network_error.dart';
import 'package:wallet/screens/auth/auth.dart';
import 'package:wallet/screens/currency/currency.dart';
import 'package:wallet/screens/home/buy_gau.dart';
import 'package:wallet/screens/home/calculator.dart';
import 'package:wallet/screens/home/home.dart';
import 'package:wallet/screens/home/invest.dart';
import 'package:wallet/screens/home/settings.dart';
import 'package:wallet/screens/home/swap.dart';
import 'package:wallet/screens/intro/intro.dart';
import 'package:wallet/screens/receive.dart';
import 'package:wallet/screens/send.dart';
import 'package:wallet/screens/set_up/_wrapper.dart';
import 'package:wallet/screens/splash.dart';

part 'routes.gr.dart';

Widget secondaryTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SharedAxisTransition(
    animation: animation,
    secondaryAnimation: secondaryAnimation,
    fillColor: Colors.transparent,
    transitionType: SharedAxisTransitionType.vertical,
    child: child,
  );
}

Widget mainTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeThroughTransition(
    animation: animation,
    secondaryAnimation: secondaryAnimation,
    fillColor: Colors.transparent,
    child: child,
  );
}

@AutoRouterConfig(
// replaceInRouteName: 'Page,Route'
    )
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.custom(
        reverseDurationInMilliseconds: 300,
        durationInMilliseconds: 300,
      );

  @override
  final List<AutoRoute> routes = [
    CustomRoute(
      page: SplashRoute.page,
      path: '/',
      transitionsBuilder: mainTransition,
    ),
    CustomRoute(
      page: NetworkErrorRoute.page,
      path: '/network_error',
      transitionsBuilder: mainTransition,
    ),
    CustomRoute(
      page: IntroRoute.page,
      path: '/set_up',
      transitionsBuilder: mainTransition,
    ),
    CustomRoute(
      page: SetUpCreateRoute.page,
      path: '/set_up/create',
      transitionsBuilder: secondaryTransition,
    ),
    CustomRoute(
      page: SetUpRestoreRoute.page,
      path: '/set_up/restore',
      transitionsBuilder: secondaryTransition,
    ),
    CustomRoute(
      page: AuthRoute.page,
      path: '/auth',
      transitionsBuilder: mainTransition,
    ),
    CustomRoute(
      page: HomeRoute.page,
      path: '/home',
      transitionsBuilder: mainTransition,
    ),
    CustomRoute(
      page: SettingsRoute.page,
      path: '/settings',
      transitionsBuilder: secondaryTransition,
    ),
    CustomRoute(
      page: CalculatorRoute.page,
      path: '/calculator',
      transitionsBuilder: secondaryTransition,
    ),
    CustomRoute(
      page: BuyGauRoute.page,
      path: '/buy_gau',
      transitionsBuilder: secondaryTransition,
    ),
    CustomRoute(
      page: GaufInvestRoute.page,
      path: '/invest',
      transitionsBuilder: secondaryTransition,
    ),
    CustomRoute(
      page: SwapRoute.page,
      path: '/swap',
      transitionsBuilder: secondaryTransition,
    ),
    CustomRoute(
      page: SendRoute.page,
      path: '/send',
      transitionsBuilder: secondaryTransition,
    ),
    CustomRoute(
      page: ReceiveRoute.page,
      path: '/receive',
      transitionsBuilder: secondaryTransition,
    ),
    CustomRoute(
      page: CurrencyRoute.page,
      path: '/coin/:ticker',
      transitionsBuilder: secondaryTransition,
    ),
    // CustomRoute(
    //   page: SwapExchangeRoute.page,
    //   path: '/exchange/:pair',
    //   transitionsBuilder: secondaryTransition,
    // ),
  ];
}

// // todo improvement: nested route instead, so that the background & layout elements stay the same
// @CustomAutoRouter(
//   replaceInRouteName: 'Page,Route',
//   // transitionsBuilder: transition,
//   reverseDurationInMilliseconds: 300,
//   durationInMilliseconds: 300,
//   routes: <AutoRoute>[
//     CustomRoute(
//       page: SplashScreen,
//       initial: true,
//       path: '/',
//       transitionsBuilder: mainTransition,
//     ),
//     CustomRoute(
//       page: NetworkErrorScreen,
//       path: '/network_error',
//       transitionsBuilder: mainTransition,
//     ),
//     CustomRoute(
//       page: IntroScreen,
//       path: '/set_up',
//       transitionsBuilder: mainTransition,
//     ),
//     CustomRoute(
//       page: SetUpCreateScreen,
//       path: '/set_up/create',
//       transitionsBuilder: secondaryTransition,
//     ),
//     CustomRoute(
//       page: SetUpRestoreScreen,
//       path: '/set_up/restore',
//       transitionsBuilder: secondaryTransition,
//     ),
//     CustomRoute(
//       page: AuthScreen,
//       path: '/auth',
//       transitionsBuilder: mainTransition,
//     ),
//     CustomRoute(
//       page: HomeScreen,
//       path: '/home',
//       transitionsBuilder: mainTransition,
//     ),
//     CustomRoute(
//       page: SettingsScreen,
//       path: '/settings',
//       transitionsBuilder: secondaryTransition,
//     ),
//     CustomRoute(
//       page: CalculatorScreen,
//       path: '/calculator',
//       transitionsBuilder: secondaryTransition,
//     ),
//     CustomRoute(
//       page: BuyGauScreen,
//       path: '/buy_gau',
//       transitionsBuilder: secondaryTransition,
//     ),
//     CustomRoute(
//       page: GaufInvestScreen,
//       path: '/invest',
//       transitionsBuilder: secondaryTransition,
//     ),
//     CustomRoute(
//       page: SwapScreen,
//       path: '/swap',
//       transitionsBuilder: secondaryTransition,
//     ),
//     CustomRoute(
//       page: CurrencyScreen,
//       path: '/coin/:ticker',
//       transitionsBuilder: secondaryTransition,
//     ),
//   ],
// )
// class $AppRouter {}
