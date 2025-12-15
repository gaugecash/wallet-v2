import 'dart:math';

import 'package:dart_web3/dart_web3.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/models/tx.dart';
import 'package:wallet/repository/abi/gau.g.dart';
import 'package:wallet/repository/abi/gaufrate.g.dart';
import 'package:wallet/repository/atm.dart';
import 'package:wallet/repository/coins/coin.dart';
import 'package:wallet/repository/gas_station.dart';
import 'package:wallet/utils/gstream.dart';

// TODO This does not work yet
// todo [refactor] have a mixin or interface for marking swappable functions
class GaufCoin extends CoinRepository {
  GaufCoin({
    required super.client,
    required super.wallet,
  })  : atm = AtmMachine(wallet: wallet, client: client);

  final AtmMachine atm;

  String get smartContractAddress =>
      network == Network.main ? mainGauiAddress : testGaufAddress;

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
    final ether = balance / BigInt.from(pow(10, gaufDecimals));
    return ether;
  }

  String get rateSmartContractAddress =>
      network == Network.main ? mainGauiRateAddress : testGaufRateAddress;

  Stream<double> getPriceInMatic() async* {
    final smartContract = Gaufrate(
      client: client.web3,
      address: EthereumAddress.fromHex(rateSmartContractAddress),
    );

    while (true) {
      try {
        final balance = await _getPriceInMatic(smartContract);
        yield balance;
      } catch (_) {}
      await Future.delayed(secondaryDataUpdateInterval);
    }
  }

  Future<double> _getPriceInMatic(Gaufrate smartContract) async {
    final rate = await smartContract.rate();
    final ether = rate / BigInt.from(pow(10, 18));
    return ether;
  }

  // todo implement gauf send
  // todo all erc20 tokens will have this -> make more abstract
  @override
  Future<Tx> send(TxData data) async {
    late EthereumAddress addr;

    try {
      addr = EthereumAddress.fromHex(data.address!);
    } catch (e) {
      logger.e(e);
      return Tx.error(data, 'Invalid address', TxType.send);
    }

    final wei = BigInt.from(data.amount * pow(10, gaufDecimals));

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

  Future<Tx> buyTokens(TxData data) async {
    // final wei = BigInt.from(data.amount * pow(10, 18));
    // final value = EtherAmount.fromUnitAndValue(EtherUnit.wei, wei);

    if (data.amount <= 0) {
      return Tx.error(data, 'Invalid amount', TxType.swap);
    }

    try {
      final tx = await atm.buyGauf(data.amount);

      final events = Stream<TxEvent>.value(const TxEvent(status: TxStatus.sent))
          .asBroadcastStream();
      final stream = GStream(events);
      return Tx(tx: tx, events: stream, data: data, type: TxType.swap);
    } catch (e) {
      logger.e(e);
      return Tx.error(data, e.toString(), TxType.swap);
    }
  }
}
