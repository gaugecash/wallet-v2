import 'dart:math';

import 'package:dart_web3/dart_web3.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/models/tx.dart';
import 'package:wallet/repository/abi/link.g.dart';
import 'package:wallet/repository/coins/coin.dart';
import 'package:wallet/repository/gas_station.dart';
import 'package:wallet/utils/gstream.dart';

// todo [refactor] have a mixin or interface for marking swappable functions
class MaticCoin extends CoinRepository {
  MaticCoin({
    required super.client,
    required super.wallet,
  });

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
    final balance = await client.web3.getBalance(addr);
    return balance.getValueInUnit(EtherUnit.ether);
  }

  String get linkSmartContractAddress => network == Network.main ? mainMaticLinkAddress : testMaticLinkAddress;

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
      await Future.delayed(importantDataUpdateInterval);
    }
  }

  Future<double> _getPriceInUSD(Link smartContract) async {
    final price = await smartContract.latestAnswer();
    // todo as a utils function
    final ether = price / BigInt.from(pow(10, maticLinkDecimals));
    return ether;
  }

  @override
  Future<Tx> send(TxData data) async {
    late EthereumAddress addr;

    try {
      addr = EthereumAddress.fromHex(data.address!);
    } catch (e) {
      return Tx.error(data, 'Invalid address', TxType.send);
    }

    final wei = BigInt.from(data.amount * pow(10, 18));
    final value = EtherAmount.fromUnitAndValue(EtherUnit.wei, wei);

    try {
      final gas = await GasStation.getGas();

      final from = await wallet.getAddress();

      final tx = await wallet.transact((creds) async {
        final res = await client.web3.sendTransaction(
          creds,
          Transaction(
            to: addr,
            value: value,
            from: from,
            maxFeePerGas: gas.maxFeePerGas,
            maxPriorityFeePerGas: gas.maxPriorityFeePerGas,
            maxGas: gas.maxGas,
          ),
          chainId: wallet.chainId,
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
}
