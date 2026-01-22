import 'dart:math';

import 'package:directed_graph/directed_graph.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/providers/wallet.dart';
import 'package:wallet/repository/coins/usd.dart';
import 'package:wallet/repository/simple_swap_estimate.dart';
import 'package:wallet/repository/simple_swap_exchange.dart';

WeightedDirectedGraph<CurrencyTicker, GraphStruct> get constructSimpleSwapGraph {
  final graph = WeightedDirectedGraph<CurrencyTicker, GraphStruct>(
    {
      CurrencyTicker.matic: {
        CurrencyTicker.wmatic: GraphStruct((GraphArgs args) async {
          switch (args.type) {
            case GraphOperationType.tx:
              final tx = await args.functions.exchange.depositWmatic(0, exact: args.amount);
              return (tx, args.amount);
            case GraphOperationType.estimateGet:
              return ('', args.amount);
          }
        }),
      },
      CurrencyTicker.gau: {
        CurrencyTicker.usdt: GraphStruct((GraphArgs args) async {
          switch (args.type) {
            case GraphOperationType.tx:
              final swap = await args.functions.exchange.atm.swapGauForToken(0, UsdCoinType.usdt, exact: args.amount);
              var valueReceived = BigInt.zero;
              if (args.isTxComplex) {
                valueReceived = await args.functions.exchange.getSwapOutput(swap);
              }
              return (swap, valueReceived);
            case GraphOperationType.estimateGet:
              final wallet = args.ref.read(walletProvider);
              final rate = wallet.currencies!.firstWhere((el) => el.type == CurrencyTicker.gau).price!.lastValue!;
              final valueDecimals = args.amount / BigInt.from(10).pow(gauDecimals);
              final usdValue = valueDecimals * rate;

              final usdBig = BigInt.from(usdValue * pow(10, usdtDecimals));

              return ('', usdBig);
          }
        }),
      },

      // FROM HERE UNISWAP SWAPS
      CurrencyTicker.wmatic: {
        CurrencyTicker.matic: GraphStruct((GraphArgs args) async {
          switch (args.type) {
            case GraphOperationType.tx:
              final tx = await args.functions.exchange.withdrawWmatic();
              return (tx, args.amount);
            case GraphOperationType.estimateGet:
              return ('', args.amount);
          }
        }),

        // FROM HERE UNISWAP SWAPS ONLY
        CurrencyTicker.usdt:
            GraphStruct((GraphArgs args) => doUniswap(args, mainWmaticAddress, mainUsdtAddress, FeeLevels.l005)),

        CurrencyTicker.usdc:
            GraphStruct((GraphArgs args) => doUniswap(args, mainWmaticAddress, mainUsdcAddress, FeeLevels.l005)),

        CurrencyTicker.weth:
            GraphStruct((GraphArgs args) => doUniswap(args, mainWmaticAddress, mainUniswapWeth, FeeLevels.l005)),

        CurrencyTicker.wbtc:
            GraphStruct((GraphArgs args) => doUniswap(args, mainWmaticAddress, mainUniswapWbtc, FeeLevels.l005)),

        CurrencyTicker.dai:
            GraphStruct((GraphArgs args) => doUniswap(args, mainWmaticAddress, mainUniswapDai, FeeLevels.l005)),

        CurrencyTicker.link:
            GraphStruct((GraphArgs args) => doUniswap(args, mainWmaticAddress, mainUniswapLink, FeeLevels.l005)),

        CurrencyTicker.crv:
            GraphStruct((GraphArgs args) => doUniswap(args, mainWmaticAddress, mainUniswapCrv, FeeLevels.l03)),

        CurrencyTicker.bob:
            GraphStruct((GraphArgs args) => doUniswap(args, mainWmaticAddress, mainUniswapBob, FeeLevels.l005)),

        CurrencyTicker.aave:
            GraphStruct((GraphArgs args) => doUniswap(args, mainWmaticAddress, mainUniswapAave, FeeLevels.l03)),
      },
      CurrencyTicker.usdt: {
        CurrencyTicker.gau: GraphStruct((GraphArgs args) async {
          switch (args.type) {
            case GraphOperationType.tx:
              final swap = await args.functions.exchange.atm.swapTokenForGau(0, UsdCoinType.usdt, exact: args.amount);

              var valueReceived = BigInt.zero;
              if (args.isTxComplex) {
                valueReceived = await args.functions.exchange.getSwapOutput(swap);
              }

              return (swap, valueReceived);
            case GraphOperationType.estimateGet:
              final wallet = args.ref.read(walletProvider);
              final rate = 1 / (wallet.currencies!.firstWhere((el) => el.type == CurrencyTicker.gau).price!.lastValue!);
              final valueDecimals = args.amount / BigInt.from(10).pow(usdtDecimals);
              final gauValue = valueDecimals * rate;

              final gauBig = BigInt.from(gauValue * pow(10, gauDecimals));

              return ('', gauBig);
          }
        }),

        // FROM HERE UNISWAP SWAPS ONLY
        CurrencyTicker.wmatic:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUsdtAddress, mainWmaticAddress, FeeLevels.l005)),
        CurrencyTicker.usdc:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUsdtAddress, mainUsdcAddress, FeeLevels.l001)),
        CurrencyTicker.weth:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUsdtAddress, mainUniswapWeth, FeeLevels.l03)),
        CurrencyTicker.wbtc:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUsdtAddress, mainUniswapWbtc, FeeLevels.l03)),
        CurrencyTicker.dai:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUsdtAddress, mainUniswapDai, FeeLevels.l001)),
        CurrencyTicker.link:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUsdtAddress, mainUniswapLink, FeeLevels.l03)),
        CurrencyTicker.bob:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUsdtAddress, mainUniswapBob, FeeLevels.l001)),
      },
      // FROM HERE UNISWAP COIN SWAPS ONLY

      CurrencyTicker.usdc: {
        CurrencyTicker.wmatic:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUsdcAddress, mainWmaticAddress, FeeLevels.l005)),
        CurrencyTicker.usdt:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUsdcAddress, mainUsdtAddress, FeeLevels.l001)),
        CurrencyTicker.weth:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUsdcAddress, mainUniswapWeth, FeeLevels.l005)),
        CurrencyTicker.wbtc:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUsdcAddress, mainUniswapWbtc, FeeLevels.l005)),
        CurrencyTicker.w$c:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUsdcAddress, mainUniswapW$c, FeeLevels.l03)),
        CurrencyTicker.agEur:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUsdcAddress, mainUniswapAgEur, FeeLevels.l001)),
        CurrencyTicker.dai:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUsdcAddress, mainUniswapDai, FeeLevels.l001)),
        CurrencyTicker.link:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUsdcAddress, mainUniswapLink, FeeLevels.l005)),
        CurrencyTicker.crv:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUsdcAddress, mainUniswapCrv, FeeLevels.l03)),
        CurrencyTicker.bob:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUsdcAddress, mainUniswapBob, FeeLevels.l001)),
        CurrencyTicker.aave:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUsdcAddress, mainUniswapAave, FeeLevels.l03)),
      },

      CurrencyTicker.weth: {
        CurrencyTicker.wmatic:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapWeth, mainWmaticAddress, FeeLevels.l005)),
        CurrencyTicker.usdt:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapWeth, mainUsdtAddress, FeeLevels.l03)),
        CurrencyTicker.usdc:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapWeth, mainUsdcAddress, FeeLevels.l005)),
        CurrencyTicker.wbtc:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapWeth, mainUniswapWbtc, FeeLevels.l03)),
        CurrencyTicker.dai:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapWeth, mainUniswapDai, FeeLevels.l005)),
        CurrencyTicker.link:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapWeth, mainUniswapLink, FeeLevels.l03)),
        CurrencyTicker.crv:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapWeth, mainUniswapCrv, FeeLevels.l03)),
        CurrencyTicker.bob:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapWeth, mainUniswapBob, FeeLevels.l005)),
        CurrencyTicker.aave:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapWeth, mainUniswapAave, FeeLevels.l03)),
      },

      CurrencyTicker.wbtc: {
        CurrencyTicker.wmatic:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapWbtc, mainWmaticAddress, FeeLevels.l005)),
        CurrencyTicker.usdt:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapWbtc, mainUsdtAddress, FeeLevels.l03)),
        CurrencyTicker.usdc:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapWbtc, mainUsdcAddress, FeeLevels.l005)),
        CurrencyTicker.weth:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapWbtc, mainUniswapWeth, FeeLevels.l005)),
        CurrencyTicker.dai:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapWbtc, mainUniswapDai, FeeLevels.l03)),
        CurrencyTicker.link:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapWbtc, mainUniswapLink, FeeLevels.l03)),
      },
      CurrencyTicker.w$c: {
        CurrencyTicker.usdc:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapW$c, mainUsdcAddress, FeeLevels.l03)),
      },
      CurrencyTicker.agEur: {
        CurrencyTicker.usdc:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapAgEur, mainUsdcAddress, FeeLevels.l001)),
      },

      CurrencyTicker.dai: {
        CurrencyTicker.wmatic:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapDai, mainWmaticAddress, FeeLevels.l005)),
        CurrencyTicker.usdt:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapDai, mainUsdtAddress, FeeLevels.l001)),
        CurrencyTicker.usdc:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapDai, mainUsdcAddress, FeeLevels.l001)),
        CurrencyTicker.weth:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapDai, mainUniswapWeth, FeeLevels.l005)),
        CurrencyTicker.wbtc:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapDai, mainUniswapWbtc, FeeLevels.l03)),
      },
      CurrencyTicker.link: {
        CurrencyTicker.wmatic:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapLink, mainWmaticAddress, FeeLevels.l005)),
        CurrencyTicker.usdt:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapLink, mainUsdtAddress, FeeLevels.l03)),
        CurrencyTicker.usdc:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapLink, mainUsdcAddress, FeeLevels.l005)),
        CurrencyTicker.weth:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapLink, mainUniswapWeth, FeeLevels.l03)),
        CurrencyTicker.wbtc:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapLink, mainUniswapWbtc, FeeLevels.l03)),
      },
      CurrencyTicker.crv: {
        CurrencyTicker.wmatic:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapCrv, mainWmaticAddress, FeeLevels.l03)),
        CurrencyTicker.usdc:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapCrv, mainUsdcAddress, FeeLevels.l03)),
        CurrencyTicker.weth:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapCrv, mainUniswapWeth, FeeLevels.l03)),
      },
      CurrencyTicker.bob: {
        CurrencyTicker.wmatic:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapBob, mainWmaticAddress, FeeLevels.l005)),
        CurrencyTicker.usdt:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapBob, mainUsdtAddress, FeeLevels.l001)),
        CurrencyTicker.usdc:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapBob, mainUsdcAddress, FeeLevels.l001)),
        CurrencyTicker.weth:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapBob, mainUniswapWeth, FeeLevels.l005)),
      },
      CurrencyTicker.aave: {
        CurrencyTicker.wmatic:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapAave, mainWmaticAddress, FeeLevels.l03)),
        CurrencyTicker.usdc:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapAave, mainUsdcAddress, FeeLevels.l03)),
        CurrencyTicker.weth:
            GraphStruct((GraphArgs args) => doUniswap(args, mainUniswapAave, mainUniswapWeth, FeeLevels.l03)),
      },
    },
    summation: (a, b) => GraphStruct(
      (GraphArgs args) async => ('', BigInt.zero),
    ),
    zero: GraphStruct(
      (GraphArgs args) async => ('', BigInt.zero),
    ),
    comparator: (a, b) => a.name.compareTo(b.name),
  );

  return graph;
}

Future<(String, BigInt)> doUniswap(GraphArgs args, String tokenIn, String tokenOut, FeeLevels fee) async {
  switch (args.type) {
    case GraphOperationType.tx:
      return args.functions.exchange.uniswap(
        amount: args.amount,
        tokenIn: tokenIn,
        tokenOut: tokenOut,
        fee: fee,
        complex: args.isTxComplex,
      );
    case GraphOperationType.estimateGet:
      return args.functions.estimate.estimate(
        tokenIn,
        tokenOut,
        fee,
        args.amount,
      );
  }
}

enum GraphOperationType { tx, estimateGet }

enum FeeLevels {
  l001,
  l005,
  l03,
  l1,
}

int getFeeNumber(FeeLevels level) {
  switch (level) {
    case FeeLevels.l001:
      return 100;
    case FeeLevels.l005:
      return 500;
    case FeeLevels.l03:
      return 3000;
    case FeeLevels.l1:
      return 1000;
  }
}

// GraphFunctions functions, BigInt amount, bool complex, GraphOperationType type
class GraphArgs {
  const GraphArgs({
    required this.functions,
    required this.amount,
    required this.isTxComplex,
    required this.type,
    required this.ref,
  });

  final GraphFunctions functions;
  final BigInt amount;
  final bool isTxComplex;
  final GraphOperationType type;
  final WidgetRef ref;
}

class GraphFunctions {
  const GraphFunctions({required this.exchange, required this.estimate});

  final SimpleSwapExchangeFunctions exchange;
  final SimpleSwapEstimateFunctions estimate;
}

class GraphStruct implements Comparable<GraphStruct> {
  GraphStruct(this.graphFunction);
  final Future<(String swapTx, BigInt received)> Function(
    GraphArgs args,
  ) graphFunction;

  @override
  int compareTo(GraphStruct other) => 0;

  static int compare(Comparable a, Comparable b) => a.compareTo(b);
}
