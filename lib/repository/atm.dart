import 'dart:math';

import 'package:dart_web3/dart_web3.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/repository/abi/atm.g.dart';
import 'package:wallet/repository/abi/gaufrate.g.dart';
import 'package:wallet/repository/coins/gau.dart';
import 'package:wallet/repository/coins/usd.dart';
import 'package:wallet/repository/gas_station.dart';
import 'package:wallet/repository/rpc.dart';
import 'package:wallet/repository/wallet.dart';

class AtmMachine {
  const AtmMachine({required this.wallet, required this.client});

  final GWallet wallet;
  final GClient client;

  String get _atmAddress =>
      network == Network.main ? mainAtmAddress : testAtmAddress;

  String get _atmSpendingAddress =>
      network == Network.main ? mainAtmSpendingAddress : testAtmSpendingAddress;

  String get _gaufRateAddress =>
      network == Network.main ? mainGauiRateAddress : testGaufRateAddress;

  // todo dispatch events properly [to a stream]
  // todo [refactor] do not use wallet.transact directly
  Future<String> swapGauForMatic(double amount) async {
    // todo pow should be cone on the big int just to be safe & avoid overflow [probably]
    final wei = BigInt.from(amount * pow(10, gauDecimals));

    final gau = GauCoin(client: client, wallet: wallet);
    final atm = Atm(
      client: client.web3,
      address: EthereumAddress.fromHex(_atmAddress),
    );

    final contract = await wallet.transact((creds) async {
      // print('approving');

      var gas = await GasStation.getGas();
      // todo i guess just calling the generated function should also work fine
      // todo since we are not sending any value with the tx
      // todo refactor to have it in a separate function
      /// Approving
      final approve = Transaction.callContract(
        contract: gau.smartContract.self,
        function: gau.smartContract.self.function('approve'),
        parameters: [
          EthereumAddress.fromHex(_atmSpendingAddress),
          BigInt.from(amount * pow(10, 18)),
        ],
        from: await wallet.getAddress(),
        maxFeePerGas: gas.maxFeePerGas,
        maxPriorityFeePerGas: gas.maxPriorityFeePerGas,
        maxGas: gas.maxGas,
      );

      final approveTx = await client.web3.sendTransaction(
        creds,
        approve,
        chainId: wallet.chainId,
      );
      // print('approve: $approveTx');

      while (true) {
        try {
          final res = await client.web3.getTransactionByHash(approveTx);
          // print('approved: ${res.blockNumber}');
          break;
        } catch (_) {
          // print('not approved yet');
          await Future.delayed(const Duration(seconds: 5));
        }
      }

      // print('checking for the allowance');
      // final allowance = await gau.smartContract.allowance(
      //   await wallet.getAddress(),
      //   EthereumAddress.fromHex(atmAddress),
      // );
      // print('allowance: $allowance');

      gas = await GasStation.getGas();
      // print('attempting to use atm now');
      final tx = Transaction.callContract(
        contract: atm.self,
        function: atm.self.function('swapGauForMatic'),
        parameters: [wei],
        from: await wallet.getAddress(),
        maxFeePerGas: gas.maxFeePerGas,
        maxPriorityFeePerGas: gas.maxPriorityFeePerGas,
        maxGas: gas.maxGas,
      );
      logger.i('sending');

      final res = await client.web3.sendTransaction(
        creds,
        tx,
        chainId: wallet.chainId,
      );
      logger.i('done');

      return res;
    });
    logger.i(contract);
    return contract;
  }

  Future<String> swapMaticForGau(double amount) async {
    final wei = BigInt.from(amount * pow(10, 18));
    final val = EtherAmount.inWei(wei);
    final atm = Atm(
      client: client.web3,
      address: EthereumAddress.fromHex(_atmAddress),
    );

    final gas = await GasStation.getGas();
    final contract = await wallet.transact((creds) async {
      final tx = Transaction.callContract(
        contract: atm.self,
        function: atm.self.function('swapMaticForGau'),
        parameters: [],
        value: val,
        from: await wallet.getAddress(),
        maxFeePerGas: gas.maxFeePerGas,
        maxPriorityFeePerGas: gas.maxPriorityFeePerGas,
        maxGas: gas.maxGas,
      );
      logger.i('sending');
      final res = await client.web3.sendTransaction(
        creds,
        tx,
        chainId: wallet.chainId,
      );
      logger.i('done');
      return res;
    });
    logger.i(contract);
    return contract;
  }

  Future<String> buyGauf(double amount) async {
    final wei = BigInt.from(amount * pow(10, gaufDecimals));
    final val = EtherAmount.inWei(wei);
    final atm = Gaufrate(
      address: EthereumAddress.fromHex(_gaufRateAddress),
      client: client.web3,
      chainId: wallet.chainId,
    );
    final gas = await GasStation.getGas();
    final contract = await wallet.transact((creds) async {
      final tx = Transaction.callContract(
        contract: atm.self,
        function: atm.self.function('buyTokens'),
        parameters: [await wallet.getAddress()],
        value: val,
        from: await wallet.getAddress(),
        maxFeePerGas: gas.maxFeePerGas,
        maxPriorityFeePerGas: gas.maxPriorityFeePerGas,
        maxGas: gas.maxGas,
      );
      logger.i('sending');
      final res = await client.web3.sendTransaction(
        creds,
        tx,
        chainId: wallet.chainId,
      );
      logger.i('done');
      return res;
    });
    logger.i(contract);
    return contract;
  }

  // todo dispatch events properly [to a stream]
  // todo [refactor] do not use wallet.transact directly
  Future<String> swapGauForToken(
    double amount,
    UsdCoinType type, {
    BigInt? exact,
  }) async {
    // todo pow should be cone on the big int just to be safe & avoid overflow [probably]
    final wei = exact ?? BigInt.from(amount * pow(10, gauDecimals));

    final gau = GauCoin(client: client, wallet: wallet);
    final usd = UsdCoin(client: client, wallet: wallet, type: type);

    final atm = Atm(
      client: client.web3,
      address: EthereumAddress.fromHex(_atmAddress),
    );

    final contract = await wallet.transact((creds) async {
      logger.i('approving');

      var gas = await GasStation.getGas();
      // todo i guess just calling the generated function should also work fine
      // todo since we are not sending any value with the tx
      // todo refactor to have it in a separate function
      /// Approving
      final approve = Transaction.callContract(
        contract: gau.smartContract.self,
        function: gau.smartContract.self.function('approve'),
        parameters: [
          EthereumAddress.fromHex(_atmSpendingAddress),
          wei,
          // BigInt.from(amount * pow(10, 18)),
        ],
        from: await wallet.getAddress(),
        maxFeePerGas: gas.maxFeePerGas,
        maxPriorityFeePerGas: gas.maxPriorityFeePerGas,
        maxGas: gas.maxGas,
      );

      final approveTx = await client.web3.sendTransaction(
        creds,
        approve,
        chainId: wallet.chainId,
      );
      logger.i('approve: $approveTx');

      while (true) {
        try {
          final res = await client.web3.getTransactionByHash(approveTx);
          logger.i('approved: ${res.blockNumber}');
          break;
        } catch (_) {
          logger.i('not approved yet');
          await Future.delayed(const Duration(seconds: 5));
        }
      }

      // print('checking for the allowance');
      // final allowance = await gau.smartContract.allowance(
      //   await wallet.getAddress(),
      //   EthereumAddress.fromHex(atmAddress),
      // );
      // print('allowance: $allowance');

      gas = await GasStation.getGas();
      // atm.swapGauForToken(_amount, _tokenAddress, credentials: credentials)
      logger.i('attempting to use atm now');
      final tx = Transaction.callContract(
        contract: atm.self,
        function: atm.self.function('swapGauForToken'),
        parameters: [wei, EthereumAddress.fromHex(usd.smartContractAddress)],
        from: await wallet.getAddress(),
        maxFeePerGas: gas.maxFeePerGas,
        maxPriorityFeePerGas: gas.maxPriorityFeePerGas,
        maxGas: gas.maxGas,
      );
      logger.i('sending');

      final res = await client.web3.sendTransaction(
        creds,
        tx,
        chainId: wallet.chainId,
      );
      logger.i('done');

      return res;
    });
    logger.i(contract);
    return contract;
  }

  // todo dispatch events properly [to a stream]
  // todo [refactor] do not use wallet.transact directly
  Future<String> swapTokenForGau(
    double amount,
    UsdCoinType type, {
    BigInt? exact,
  }) async {
    // todo pow should be cone on the big int just to be safe & avoid overflow [probably]
    final wei = exact ??
        BigInt.from(
          amount *
              pow(
                10,
                type == UsdCoinType.usdc ? usdcDecimals : usdtDecimals,
              ),
        );

    // final gau = GauCoin(client: client, wallet: wallet);
    final usd = UsdCoin(client: client, wallet: wallet, type: type);

    final atm = Atm(
      client: client.web3,
      address: EthereumAddress.fromHex(_atmAddress),
    );

    final contract = await wallet.transact((creds) async {
      logger.i('approving');

      var gas = await GasStation.getGas();
      // todo i guess just calling the generated function should also work fine
      // todo since we are not sending any value with the tx
      // todo refactor to have it in a separate function
      /// Approving
      final approve = Transaction.callContract(
        contract: usd.smartContract.self,
        function: usd.smartContract.self.function('approve'),
        parameters: [
          EthereumAddress.fromHex(_atmAddress),
          wei
          // BigInt.from(amount * pow(10, 18)),
        ],
        from: await wallet.getAddress(),
        maxFeePerGas: gas.maxFeePerGas,
        maxPriorityFeePerGas: gas.maxPriorityFeePerGas,
        maxGas: gas.maxGas,
      );

      final approveTx = await client.web3.sendTransaction(
        creds,
        approve,
        chainId: wallet.chainId,
      );
      logger.i('approve: $approveTx');

      while (true) {
        try {
          final res = await client.web3.getTransactionByHash(approveTx);
          logger.i('approved: ${res.blockNumber}');
          break;
        } catch (_) {
          logger.i('not approved yet');
          await Future.delayed(const Duration(seconds: 5));
        }
      }

      // print('checking for the allowance');
      // final allowance = await gau.smartContract.allowance(
      //   await wallet.getAddress(),
      //   EthereumAddress.fromHex(atmAddress),
      // );
      // print('allowance: $allowance');

      gas = await GasStation.getGas();
      // atm.swapGauForToken(_amount, _tokenAddress, credentials: credentials)
      logger.i('attempting to use atm now');
      final tx = Transaction.callContract(
        contract: atm.self,
        function: atm.self.function('swapTokenForGau'),
        parameters: [wei, EthereumAddress.fromHex(usd.smartContractAddress)],
        from: await wallet.getAddress(),
        maxFeePerGas: gas.maxFeePerGas,
        maxPriorityFeePerGas: gas.maxPriorityFeePerGas,
        maxGas: gas.maxGas,
      );
      logger.i('sending');

      final res = await client.web3.sendTransaction(
        creds,
        tx,
        chainId: wallet.chainId,
      );
      logger.i('done');

      return res;
    });
    logger.i(contract);
    return contract;
  }
}
