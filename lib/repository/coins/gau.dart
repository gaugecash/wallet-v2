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

class GauCoin extends CoinRepository {
  GauCoin({
    required super.client,
    required super.wallet,
  });

  String get smartContractAddress =>
      network == Network.main ? mainGauAddress : testGauAddress;

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
    final ether = balance / BigInt.from(pow(10, gauDecimals));
    return ether;
  }

  String get linkSmartContractAddress =>
      network == Network.main ? mainGauLinkAddress : testGauLinkAddress;

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
    final ether = price / BigInt.from(pow(10, gauLinkDecimals));
    return ether;
  }

  @override
  Future<Tx> send(TxData data) async {
    if (data.useMetaIfPossible) {
      return sendMeta(data);
    }

    late EthereumAddress addr;

    try {
      addr = EthereumAddress.fromHex(data.address!);
    } catch (e) {
      logger.e(e);
      return Tx.error(data, 'Invalid address', TxType.send);
    }

    final wei = BigInt.from(data.amount * pow(10, gauDecimals));

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
      final events = Stream<TxEvent>.value(const TxEvent(status: TxStatus.sent))
          .asBroadcastStream();
      final stream = GStream(events);
      return Tx(tx: tx, events: stream, data: data, type: TxType.send);
    } catch (e) {
      logger.e(e);
      return Tx.error(data, e.toString(), TxType.send);
    }
  }

  Future<Tx> sendMeta(TxData data) async {
    logger.i('Sending GAU with a meta tx');

    late EthereumAddress addr;

    try {
      addr = EthereumAddress.fromHex(data.address!);
    } catch (e) {
      logger.e(e);
      return Tx.error(data, 'Invalid address', TxType.send);
    }

    final wei = BigInt.from(data.amount * pow(10, gauDecimals));

    final ownerAddr = await wallet.getAddress();

    try {
      final nonce = await MetaTx.getNonceGau(client, ownerAddr);

      final payload = await MetaTx.getSignedGauPayload(
        client: client,
        walletAddr: ownerAddr,
        privateKey: wallet.privateKey,
        nonceValue: nonce,
        amount: wei,
        to: addr,
      );

      final res = await MetaTx.sendMetaTx(payload);

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
