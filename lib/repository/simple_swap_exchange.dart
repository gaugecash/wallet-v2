import 'dart:math';

import 'package:dart_web3/dart_web3.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/repository/abi/gau.g.dart';
import 'package:wallet/repository/abi/uniswap_router2.g.dart';
import 'package:wallet/repository/abi/wmatic.g.dart';
import 'package:wallet/repository/atm.dart';
import 'package:wallet/repository/gas_station.dart';
import 'package:wallet/repository/rpc.dart';
import 'package:wallet/repository/simple_swap_graph.dart';
import 'package:wallet/repository/wallet.dart';

class SimpleSwapExchangeFunctions {
  const SimpleSwapExchangeFunctions({required this.wallet, required this.client});

  final GWallet wallet;
  final GClient client;

  AtmMachine get atm => AtmMachine(wallet: wallet, client: client);

  String get _transferEvent => '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef';

  Future<(String, BigInt)> uniswap({
    required BigInt amount,
    required String tokenIn,
    required String tokenOut,
    required FeeLevels fee,
    required bool complex,
  }) async {
    // approve
    logger.i('approving uniswap');
    await _approveToken(
      0,
      tokenIn,
      0,
      exact: amount,
      spender: mainUniswap3Router02,
    );

    final addr = await wallet.getAddress();

    final router = Uniswap_router2(
      client: client.web3,
      address: EthereumAddress.fromHex(mainUniswap3Router02),
    );

    final gas = await GasStation.getGas();

    final tx = await wallet.transact((creds) async {
      final tx = await router.exactInputSingle(
        [
          EthereumAddress.fromHex(tokenIn), // token in
          EthereumAddress.fromHex(tokenOut), // token out
          BigInt.from(getFeeNumber(fee)), // fee
          addr, // recipient
          amount, // amount in
          BigInt.from(0), // amount out minimum
          BigInt.from(0) // sqrt price limit x96
        ],
        credentials: creds,
        transaction: Transaction(
          maxFeePerGas: gas.maxFeePerGas,
          maxPriorityFeePerGas: gas.maxPriorityFeePerGas,
          maxGas: gas.maxGas,
        ),
      );
      logger.i('uniswap done tx: $tx');
      return tx;
    });

    var valueReceived = BigInt.zero;
    if (complex) {
      valueReceived = await getSwapOutput(tx);
    }

    return (tx, valueReceived);
  }

// before: 11.40 matic, 0.04 gau
  Future<String> depositWmatic(double amount, {BigInt? exact}) async {
    final wmatic = Wmatic(
      client: client.web3,
      address: EthereumAddress.fromHex(mainWmaticAddress),
    );

    final wei = exact ?? BigInt.from(amount * pow(10, maticDecimals));
    final val = EtherAmount.inWei(wei);

    final gas = await GasStation.getGas();

    final depositTx = await wallet.transact((creds) async {
      final deposit = Transaction.callContract(
        contract: wmatic.self,
        function: wmatic.self.function('deposit'),
        parameters: [],
        value: val,
        from: await wallet.getAddress(),
        maxFeePerGas: gas.maxFeePerGas,
        maxPriorityFeePerGas: gas.maxPriorityFeePerGas,
        maxGas: gas.maxGas,
      );
      logger.i('depositing');
      final depositTx = await client.web3.sendTransaction(
        creds,
        deposit,
        chainId: wallet.chainId,
      );
      logger.i('depositing done: $depositTx');
      while (true) {
        try {
          final res = await client.web3.getTransactionByHash(depositTx);
          logger.i('deposited: ${res.blockNumber}');
          break;
        } catch (_) {
          logger.i('not deposited yet');
          await Future.delayed(const Duration(seconds: 3));
        }
      }
      return depositTx;
    });

    return depositTx;
  }

  Future<String> withdrawWmatic() async {
    final wmatic = Wmatic(
      client: client.web3,
      address: EthereumAddress.fromHex(mainWmaticAddress),
    );

    final addr = await wallet.getAddress();
    var balance = BigInt.zero;

    logger.i('calculating balance for withdrawing');
    while (balance == BigInt.zero) {
      balance = await wmatic.balanceOf(addr);
      logger.i('balance: $balance');
      await Future.delayed(const Duration(seconds: 1));
    }

    final gas = await GasStation.getGas();

    final withdrawTx = await wallet.transact((creds) async {
      final withdraw = Transaction.callContract(
        contract: wmatic.self,
        function: wmatic.self.function('withdraw'),
        parameters: [balance],
        // value: val,
        from: await wallet.getAddress(),
        maxFeePerGas: gas.maxFeePerGas,
        maxPriorityFeePerGas: gas.maxPriorityFeePerGas,
        maxGas: gas.maxGas,
      );
      await Future.delayed(const Duration(seconds: 1));
      logger.i('withdrawing');
      final withdrawTx = await client.web3.sendTransaction(
        creds,
        withdraw,
        chainId: wallet.chainId,
      );

      logger.i('withdrawing done: $withdrawTx');

      // while (true) {
      //   try {
      //     final res = await client.web3.getTransactionByHash(withdrawTx);
      //     logger.i('withdrawn: ${res.blockNumber}');
      //     break;
      //   } catch (_) {
      //     logger.i('not withdrawn yet');
      //     await Future.delayed(const Duration(seconds: 3));
      //   }
      // }

      return withdrawTx;
    });

    return withdrawTx;
  }

  Future<String> _approveToken(
    double amount,
    String tokenAddr,
    int decimals, {
    BigInt? exact,
    required String spender,
  }) async {
    final wei = exact ?? BigInt.from(amount * pow(10, decimals));

    final gas = await GasStation.getGas();

    // can be any erc2- token
    final approveCoin = Gau(
      client: client.web3,
      address: EthereumAddress.fromHex(tokenAddr),
    );

    final approveTx = await wallet.transact((creds) async {
      final approve = Transaction.callContract(
        contract: approveCoin.self,
        function: approveCoin.self.function('approve'),
        parameters: [
          EthereumAddress.fromHex(spender),
          wei,
        ],
        from: await wallet.getAddress(),
        maxFeePerGas: gas.maxFeePerGas,
        maxPriorityFeePerGas: gas.maxPriorityFeePerGas,
        maxGas: gas.maxGas,
      );

      logger.i('approving');
      final approveTx = await client.web3.sendTransaction(
        creds,
        approve,
        chainId: wallet.chainId,
      );
      logger.i('approving done: $approveTx');

      while (true) {
        try {
          final res = await client.web3.getTransactionByHash(approveTx);
          logger.i('approved: ${res.blockNumber}');
          break;
        } catch (_) {
          logger.i('not approved yet');
          await Future.delayed(const Duration(seconds: 3));
        }
      }
      return approveTx;
    });

    return approveTx;
  }

  Future<BigInt> getSwapOutput(String tx) async {
    var t = 0;
    while (t < 4) {
      final receipt = await client.web3.getTransactionReceipt(tx);
      logger.i('trying to get the tx receipt');
      if (receipt == null) {
        await Future.delayed(const Duration(seconds: 1));
        continue;
      }
      final logs = receipt.logs;

      for (final log in logs) {
        final topic0 = log.topics![0];
        // final topic1 = log.topics![1];
        final topic2 = log.topics![2];

        final topic2Int = BigInt.parse(topic2.replaceFirst('0x', ''), radix: 16);
        // final topic1Int =
        //     BigInt.parse(topic1.replaceFirst('0x', ''), radix: 16);

        final addr = (await wallet.getAddress()).hexNo0x;
        final walletInt = BigInt.parse(
          addr,
          radix: 16,
        );

        if (topic0 == _transferEvent && (topic2Int == walletInt)) {
          final value = BigInt.parse(
            (log.data!).replaceFirst('0x', ''),
            radix: 16,
          );

          logger.i(log);
          logger.i('the value to transfer: {${EtherAmount.inWei(value)}}}');
          return value;
        } else {
          logger.i('not outputing: $tx');
          logger.i(log);
        }
      }
      await Future.delayed(const Duration(seconds: 1));
      t++;
    }

    throw Exception('no output');
  }
}
