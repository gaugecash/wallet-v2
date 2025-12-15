// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'routes.dart';

/// generated route for
/// [AuthScreen]
class AuthRoute extends PageRouteInfo<void> {
  const AuthRoute({List<PageRouteInfo>? children})
      : super(
          AuthRoute.name,
          initialChildren: children,
        );

  static const String name = 'AuthRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AuthScreen();
    },
  );
}

/// generated route for
/// [BuyGauScreen]
class BuyGauRoute extends PageRouteInfo<void> {
  const BuyGauRoute({List<PageRouteInfo>? children})
      : super(
          BuyGauRoute.name,
          initialChildren: children,
        );

  static const String name = 'BuyGauRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BuyGauScreen();
    },
  );
}

/// generated route for
/// [CalculatorScreen]
class CalculatorRoute extends PageRouteInfo<void> {
  const CalculatorRoute({List<PageRouteInfo>? children})
      : super(
          CalculatorRoute.name,
          initialChildren: children,
        );

  static const String name = 'CalculatorRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CalculatorScreen();
    },
  );
}

/// generated route for
/// [CurrencyScreen]
class CurrencyRoute extends PageRouteInfo<CurrencyRouteArgs> {
  CurrencyRoute({
    required String ticker,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          CurrencyRoute.name,
          args: CurrencyRouteArgs(
            ticker: ticker,
            key: key,
          ),
          rawPathParams: {'ticker': ticker},
          initialChildren: children,
        );

  static const String name = 'CurrencyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CurrencyRouteArgs>(
          orElse: () =>
              CurrencyRouteArgs(ticker: pathParams.getString('ticker')));
      return CurrencyScreen(
        ticker: args.ticker,
        key: args.key,
      );
    },
  );
}

class CurrencyRouteArgs {
  const CurrencyRouteArgs({
    required this.ticker,
    this.key,
  });

  final String ticker;

  final Key? key;

  @override
  String toString() {
    return 'CurrencyRouteArgs{ticker: $ticker, key: $key}';
  }
}

/// generated route for
/// [GaufInvestScreen]
class GaufInvestRoute extends PageRouteInfo<void> {
  const GaufInvestRoute({List<PageRouteInfo>? children})
      : super(
          GaufInvestRoute.name,
          initialChildren: children,
        );

  static const String name = 'GaufInvestRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const GaufInvestScreen();
    },
  );
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [IntroScreen]
class IntroRoute extends PageRouteInfo<void> {
  const IntroRoute({List<PageRouteInfo>? children})
      : super(
          IntroRoute.name,
          initialChildren: children,
        );

  static const String name = 'IntroRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const IntroScreen();
    },
  );
}

/// generated route for
/// [NetworkErrorScreen]
class NetworkErrorRoute extends PageRouteInfo<void> {
  const NetworkErrorRoute({List<PageRouteInfo>? children})
      : super(
          NetworkErrorRoute.name,
          initialChildren: children,
        );

  static const String name = 'NetworkErrorRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NetworkErrorScreen();
    },
  );
}

/// generated route for
/// [SetUpCreateScreen]
class SetUpCreateRoute extends PageRouteInfo<void> {
  const SetUpCreateRoute({List<PageRouteInfo>? children})
      : super(
          SetUpCreateRoute.name,
          initialChildren: children,
        );

  static const String name = 'SetUpCreateRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SetUpCreateScreen();
    },
  );
}

/// generated route for
/// [SetUpRestoreScreen]
class SetUpRestoreRoute extends PageRouteInfo<void> {
  const SetUpRestoreRoute({List<PageRouteInfo>? children})
      : super(
          SetUpRestoreRoute.name,
          initialChildren: children,
        );

  static const String name = 'SetUpRestoreRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SetUpRestoreScreen();
    },
  );
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

/// generated route for
/// [SwapScreen]
class SwapRoute extends PageRouteInfo<void> {
  const SwapRoute({List<PageRouteInfo>? children})
      : super(
          SwapRoute.name,
          initialChildren: children,
        );

  static const String name = 'SwapRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SwapScreen();
    },
  );
}
