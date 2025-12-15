import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wallet/components/app_icons.dart';
import 'package:wallet/repository/coins/coin.dart';
import 'package:wallet/utils/gstream.dart';

enum CurrencyTicker { gau, matic, gauf, usdt, usdc, wmatic, weth, wbtc, w$c, agEur, dai, link, crv, bob, aave }

extension EnumExt on CurrencyTicker {
  String get ticker {
    return switch (this) {
      CurrencyTicker.gau => 'GAU',
      CurrencyTicker.matic => 'POL',
      CurrencyTicker.wmatic => 'WPOL',
      CurrencyTicker.gauf => 'GAUI',
      CurrencyTicker.usdt => 'USDT',
      CurrencyTicker.usdc => 'USDC',
      CurrencyTicker.weth => 'WETH',
      CurrencyTicker.wbtc => 'WBTC',
      CurrencyTicker.w$c => 'W\$C',
      CurrencyTicker.agEur => 'agEUR',
      CurrencyTicker.dai => 'DAI',
      CurrencyTicker.link => 'LINK',
      CurrencyTicker.crv => 'CRV',
      CurrencyTicker.bob => 'BOB',
      CurrencyTicker.aave => 'AAVE'

      // default:
      //   return 'ERR';
    };
  }

  // String get iconPath {
  //   switch (this) {
  //     case CurrencyTicker.gau:
  //       return 'assets/icons/gau.svg';
  //     case CurrencyTicker.matic:
  //       return 'assets/icons/matic.svg';
  //     case CurrencyTicker.gauf:
  //       return 'assets/icons/gauf.svg';
  //     case CurrencyTicker.usdc:
  //       return 'assets/icons/usdc.svg';
  //     case CurrencyTicker.usdt:
  //       return 'assets/icons/usdt.svg';
  //     default:
  //       return 'assets/icons/gau.svg';
  //   }
  // }

  IconData get icon {
    switch (this) {
      case CurrencyTicker.gau:
        return AppIcons.gau;
      case CurrencyTicker.matic:
        return AppIcons.matic;
      case CurrencyTicker.gauf:
        return AppIcons.gauf;
      case CurrencyTicker.usdc:
        return AppIcons.usdc;
      case CurrencyTicker.usdt:
        return AppIcons.usdt;
      case CurrencyTicker.weth:
        return AppIcons.eth;
      case CurrencyTicker.wbtc:
        return AppIcons.wbtc;
      case CurrencyTicker.link:
        return AppIcons.link;
      case CurrencyTicker.crv:
        return AppIcons.crv;
      case CurrencyTicker.w$c:
        return AppIcons.group_46;
      default:
        return LucideIcons.fileQuestion;
    }
  }
}

class Currency {
  Currency({
    required this.type,
    required this.balance,
    this.price,
    required this.repo,
    this.investOnly = false,
    this.exchangeOnly = false,
    // this.displayBalance = true,
    // this.displayRate = true,
  });

  final CurrencyTicker type;
  final GStream<double> balance;
  final GStream<double>? price;
  final bool investOnly;
  final bool exchangeOnly;

  // final bool displayBalance;
  // final bool displayRate;
  final CoinRepository repo;
}
