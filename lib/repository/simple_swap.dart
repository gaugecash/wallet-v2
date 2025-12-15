// Similar to ATM, but for uniswap

import 'dart:math';

import 'package:directed_graph/directed_graph.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/repository/rpc.dart';
import 'package:wallet/repository/simple_swap_estimate.dart';
import 'package:wallet/repository/simple_swap_exchange.dart';
import 'package:wallet/repository/simple_swap_graph.dart';
import 'package:wallet/repository/wallet.dart';

enum SimpleSwapFunction { swapWMATICForUSDT, swapUSDCForWMATIC, swapWMATICForUSDC, swapUSDTForWMATIC }

class SimpleSwap {
  const SimpleSwap({required this.wallet, required this.client, required this.ref});

  final GWallet wallet;
  final GClient client;
  final WidgetRef ref;

  Future<String> swapAny(
    CurrencyTicker a,
    CurrencyTicker b,
    double amount,
  ) async {
    final graph2 = constructSimpleSwapGraph;

    final shortest = graph2.shortestPath(a, b);
    if (shortest.isEmpty) {
      throw Exception('No path found');
    }

    logger.i('ANY SWAP PATH');
    logger.i(shortest);

    if (shortest.length == 1) {
      throw Exception('No path found');
    }
    logger.i('Amount: $amount');
    logger.i('getting amount: ${shortest[0]}');

    var pointer = 1;
    final decimals = getDecimals(shortest[0]);
    var value = BigInt.from(amount * pow(10, decimals));
    var tx = '';

    final functions = GraphFunctions(
      exchange: SimpleSwapExchangeFunctions(wallet: wallet, client: client),
      estimate: SimpleSwapEstimateFunctions(wallet: wallet, client: client),
    );

    while (pointer < shortest.length) {
      final from = shortest[pointer - 1];
      final to = shortest[pointer];

      GraphStruct? toValue;

      final outgoing = graph2.data[from];
      assert(outgoing != null);
      for (final edge in outgoing!.entries) {
        if (edge.key == to) {
          toValue = edge.value;
          break;
        }
      }

      assert(toValue != null);

      final simpleTx = shortest.length == 2 || pointer == shortest.length - 1;

      final args = GraphArgs(
        functions: functions,
        amount: value,
        isTxComplex: !simpleTx,
        type: GraphOperationType.tx,
        ref: ref,
      );

      final results = await toValue!.graphFunction(args);
      tx = results.$1;
      value = results.$2;

      await Future.delayed(const Duration(milliseconds: 600));
      pointer++;
    }
    logger.i('simple swap done, returning tx');
    return tx;
  }

  Future<double> estimateAny(
    CurrencyTicker a,
    CurrencyTicker b,
    double amount,
  ) async {
    final graph2 = constructSimpleSwapGraph;

    final shortest = graph2.shortestPath(a, b);
    if (shortest.isEmpty) {
      throw Exception('No path found');
    }

    logger.i('ANY Estimate PATH');
    logger.i(shortest);

    if (shortest.length == 1) {
      throw Exception('No path found');
    }

    logger.i('Amount: $amount');
    logger.i('getting amount: ${shortest[0]}');

    var pointer = 1;
    final decimals = getDecimals(shortest[0]);
    var value = BigInt.from(amount * pow(10, decimals));

    final functions = GraphFunctions(
      exchange: SimpleSwapExchangeFunctions(wallet: wallet, client: client),
      estimate: SimpleSwapEstimateFunctions(wallet: wallet, client: client),
    );

    while (pointer < shortest.length) {
      final from = shortest[pointer - 1];
      final to = shortest[pointer];

      GraphStruct? toValue;

      final outgoing = graph2.data[from];
      assert(outgoing != null);
      for (final edge in outgoing!.entries) {
        if (edge.key == to) {
          toValue = edge.value;
          break;
        }
      }

      assert(toValue != null);

      final args = GraphArgs(
        functions: functions,
        amount: value,
        isTxComplex: true,
        type: GraphOperationType.estimateGet,
        ref: ref,
      );

      final results = await toValue!.graphFunction(args);
      value = results.$2;
      pointer++;
    }
    logger.i('estimate done, returning value');

    final decimalsGet = getDecimals(shortest[shortest.length - 1]);
    final totalGet = value / BigInt.from(pow(10, decimalsGet));

    logger.i('totalGet: $totalGet');

    return totalGet;
  }

  int getDecimals(CurrencyTicker ticker) {
    return switch (ticker) {
      CurrencyTicker.usdt => usdtDecimals,
      CurrencyTicker.usdc => usdcDecimals,
      CurrencyTicker.matic => maticDecimals,
      CurrencyTicker.wmatic => maticDecimals,
      CurrencyTicker.gau => gauDecimals,
      CurrencyTicker.weth => mainUniswapWethDecimals,
      CurrencyTicker.wbtc => mainUniswapWbtcDecimals,
      CurrencyTicker.w$c => mainUniswapWb$cDecimals,
      CurrencyTicker.agEur => mainUniswapAgEurDecimals,
      CurrencyTicker.dai => mainUniswapDaiDecimals,
      CurrencyTicker.link => mainUniswapLinkDecimals,
      CurrencyTicker.crv => mainUniswapCrvDecimals,
      CurrencyTicker.bob => mainUniswapBobDecimals,
      CurrencyTicker.aave => mainUniswapAaveDecimals,
      CurrencyTicker.gauf => throw UnimplementedError()
    };
  }
}
