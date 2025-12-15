import 'package:dart_web3/dart_web3.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/repository/abi/uniswap_quote2.g.dart';
import 'package:wallet/repository/rpc.dart';
import 'package:wallet/repository/simple_swap_graph.dart';
import 'package:wallet/repository/wallet.dart';

class SimpleSwapEstimateFunctions {
  const SimpleSwapEstimateFunctions({required this.wallet, required this.client});

  final GWallet wallet;
  final GClient client;

  Future<(String, BigInt)> estimate(String tokenIn, String tokenOut, FeeLevels fee, BigInt amount) async {
    final uniswapQuote2 = Uniswap_quote2(
      address: EthereumAddress.fromHex(mainUniswap3Quote02),
      client: client.web3,
    );

    // final gas = await GasStation.getGas();

    final tx = await wallet.transact((creds) async {
      final txData = await client.web3.call(
        sender: await wallet.getAddress(),
        contract: uniswapQuote2.self,
        function: uniswapQuote2.self.function('quoteExactInputSingle'),
        params: [
          [
            EthereumAddress.fromHex(tokenIn),
            EthereumAddress.fromHex(tokenOut),
            amount,
            BigInt.from(getFeeNumber(fee)),
            BigInt.zero,
          ]
        ],
      );

      logger.i('received from quoter: $txData');

      return txData[0].toString();
    });

    return ('', BigInt.parse(tx));
  }
}
