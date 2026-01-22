import 'dart:math';

import 'package:dart_web3/dart_web3.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/models/tx.dart';
import 'package:wallet/repository/abi/gau.g.dart';
import 'package:wallet/repository/abi/link.g.dart';
import 'package:wallet/repository/coins/coin.dart';
import 'package:wallet/repository/gas_station.dart';
import 'package:wallet/repository/meta_tx.dart';
import 'package:wallet/utils/gstream.dart';

enum UsdCoinType { usdt, usdc }

class UsdCoin extends CoinRepository {
  UsdCoin({
    required super.client,
    required super.wallet,
    required this.type,
  }) ;

  final UsdCoinType type;

  String get smartContractAddress {
    if (type == UsdCoinType.usdc) {
      return network == Network.main ? mainUsdcAddress : testUsdcAddress;
    } else if (type == UsdCoinType.usdt) {
      return network == Network.main ? mainUsdtAddress : testUsdtAddress;
    }

    throw UnimplementedError('Unknown coin type: $type');
  }

  int get decimals {
    if (type == UsdCoinType.usdc) {
      return usdcDecimals;
    } else if (type == UsdCoinType.usdt) {
      return usdtDecimals;
    }

    throw UnimplementedError('Unknown coin type: $type');
  }

  /// todo: make erc a generic contract that everyone can use
  Gau get smartContract => Gau(
        client: client.web3,
        address: EthereumAddress.fromHex(smartContractAddress),
      );

  @override
  Stream<double> getBalance() async* {
    final addr = await wallet.getAddress();

    while (true) {
      try {
        final balance = await _getBalance(addr);
        yield balance;
      } catch (_) {}
      await Future.delayed(importantDataUpdateInterval);
    }
  }

  Future<double> _getBalance(EthereumAddress addr) async {
    final balance = await smartContract.balanceOf(addr);
    final ether = balance / BigInt.from(pow(10, decimals));
    return ether;
  }

  String get linkSmartContractAddress {
    if (type == UsdCoinType.usdc) {
      return network == Network.main ? mainUsdcLinkAddress : testUsdcLinkAddress;
    } else if (type == UsdCoinType.usdt) {
      return network == Network.main ? mainUsdtLinkAddress : testUsdtLinkAddress;
    }

    throw UnimplementedError('Unknown coin type: $type');
  }

  Stream<double> getPriceInUSD() async* {
    final smartContract = Link(
      client: client.web3,
      address: EthereumAddress.fromHex(linkSmartContractAddress),
    );

    while (true) {
      try {
        final balance = await _getPriceInUSD(smartContract);
        yield balance;
      } catch (_) {}
      await Future.delayed(secondaryDataUpdateInterval);
    }
  }

  Future<double> _getPriceInUSD(Link smartContract) async {
    final price = await smartContract.latestAnswer();
    final ether = price / BigInt.from(pow(10, usdLinkDecimals));
    return ether;
  }

  @override
  Future<Tx> send(TxData data) async {
    // Use meta-transaction for USDT if enabled
    if (data.useMetaIfPossible && type == UsdCoinType.usdt) {
      return sendMeta(data);
    }

    late EthereumAddress addr;

    try {
      addr = EthereumAddress.fromHex(data.address!);
    } catch (e) {
      logger.e(e);
      return Tx.error(data, 'Invalid address', TxType.send);
    }

    final wei = BigInt.from(data.amount * pow(10, decimals));

    try {
      final gas = await GasStation.getGas();

      final tx = await wallet.transact((creds) async {
        final res = await smartContract.transfer(
          addr,
          wei,
          credentials: creds,
          transaction: Transaction(
            maxFeePerGas: gas.maxFeePerGas,
            maxPriorityFeePerGas: gas.maxPriorityFeePerGas,
            maxGas: gas.maxGas,
          ),
        );
        return res;
      });
      final events = Stream<TxEvent>.value(const TxEvent(status: TxStatus.sent)).asBroadcastStream();
      final stream = GStream(events);
      return Tx(tx: tx, events: stream, data: data, type: TxType.send);
    } catch (e) {
      logger.e(e);
      return Tx.error(data, e.toString(), TxType.send);
    }
  }

  Future<Tx> sendMeta(TxData data) async {
    logger.i('Sending USDT with a meta tx');

    late EthereumAddress addr;

    try {
      addr = EthereumAddress.fromHex(data.address!);
    } catch (e) {
      logger.e(e);
      return Tx.error(data, 'Invalid address', TxType.send);
    }

    final wei = BigInt.from(data.amount * pow(10, decimals));
    final ownerAddr = await wallet.getAddress();

    try {
      final nonce = await MetaTx.getNonceUsdt(client, ownerAddr);

      final payload = await MetaTx.getSignedUsdtPayload(
        client: client,
        walletAddr: ownerAddr,
        privateKey: wallet.privateKey,
        nonceValue: nonce,
        amount: wei,
        to: addr,
      );

      final res = await MetaTx.sendUsdtTransfer(payload);

      if (!res) {
        return Tx.error(data, 'Meta tx failed', TxType.send);
      }

      final events = Stream<TxEvent>.value(const TxEvent(status: TxStatus.sent))
          .asBroadcastStream();
      final stream = GStream(events);
      return Tx(tx: null, events: stream, data: data, type: TxType.send);
    } catch (e) {
      logger.e(e);
      return Tx.error(data, e.toString(), TxType.send);
    }
  }
}
