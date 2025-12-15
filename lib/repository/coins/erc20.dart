import 'dart:math';

import 'package:dart_web3/dart_web3.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/models/tx.dart';
import 'package:wallet/repository/abi/gau.g.dart';
import 'package:wallet/repository/coins/coin.dart';
import 'package:wallet/repository/gas_station.dart';
import 'package:wallet/utils/gstream.dart';

class Erc20Coin extends CoinRepository {
  Erc20Coin({
    required super.client,
    required super.wallet,
    required this.addr,
    required this.decimals,
  });

  final String addr;
  final int decimals;

  String get smartContractAddress => addr;

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
        final balance = await getBalanceSingle(addr);
        yield balance;
      } catch (_) {}
      await Future.delayed(erc20DataUpdateInterval);
    }
  }

  Future<double> getBalanceSingle(EthereumAddress addr) async {
    final balance = await smartContract.balanceOf(addr);
    final ether = balance / BigInt.from(pow(10, decimals));
    return ether;
  }

  @override
  Future<Tx> send(TxData data) async {
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
}
