import 'dart:math';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/models/tx.dart';
import 'package:wallet/repository/meta_tx.dart';
import 'package:wallet/repository/rpc.dart';
import 'package:wallet/repository/simple_swap.dart';
import 'package:wallet/repository/wallet.dart';
import 'package:wallet/utils/gstream.dart';

abstract class CoinRepository {
  CoinRepository({
    required this.client,
    required this.wallet,
  });

  final GClient client;
  final GWallet wallet;

  Stream<double> getBalance();
  Future<Tx> send(TxData data);

  // todo make this interface the main for swapping
  Future<Tx> swapAny(
    TxData data,
    CurrencyTicker c1,
    CurrencyTicker c2,
    WidgetRef ref, [
    bool useMeta = false,
  ]) async {
    // final wei = BigInt.from(data.amount * pow(10, 18))
    // final value = EtherAmount.fromUnitAndValue(EtherUnit.wei, wei);

    if (data.amount <= 0) {
      return Tx.error(data, 'Invalid amount', TxType.swap);
    }

    if (useMeta && c1 == CurrencyTicker.gau && c2 == CurrencyTicker.usdt) {
      return swapGauToUsdtMeta(data);
    }
    if (useMeta && c1 == CurrencyTicker.usdt && c2 == CurrencyTicker.gau) {
      return swapUsdtToGauMeta(data);
    }

    logger.i('Swapping normally ${data.amount} $c1 for $c2');

    final simpleSwap = SimpleSwap(wallet: wallet, client: client, ref: ref);

    try {
      final tx = await simpleSwap.swapAny(c1, c2, data.amount);

      final events = Stream<TxEvent>.value(const TxEvent(status: TxStatus.sent))
          .asBroadcastStream();
      final stream = GStream(events);
      return Tx(tx: tx, events: stream, data: data, type: TxType.swap);
    } catch (e) {
      logger.e(e);
      return Tx.error(data, e.toString(), TxType.swap);
    }
  }

  Future<Tx> swapGauToUsdtMeta(TxData data) async {
    logger.i('Swapping GAU for USDT with a meta tx');

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
      );

      final res = await MetaTx.swapGauToUsdtMeta(payload);

      if (!res) {
        return Tx.error(data, 'Meta tx failed', TxType.send);
      }

      final events = Stream<TxEvent>.value(const TxEvent(status: TxStatus.sent))
          .asBroadcastStream();
      final stream = GStream(events);
      return Tx(tx: null, events: stream, data: data, type: TxType.swap);
    } catch (e) {
      logger.e(e);
      return Tx.error(data, e.toString(), TxType.swap);
    }
  }

  Future<Tx> swapUsdtToGauMeta(TxData data) async {
    logger.i('Swapping USDT for GAU with a meta tx');

    final wei = BigInt.from(data.amount * pow(10, usdtDecimals));

    final ownerAddr = await wallet.getAddress();

    try {
      final nonce = await MetaTx.getNonceUsdt(client, ownerAddr);

      final payload = await MetaTx.getSignedUsdtPayload(
        client: client,
        walletAddr: ownerAddr,
        privateKey: wallet.privateKey,
        nonceValue: nonce,
        amount: wei,
      );

      final res = await MetaTx.swapUsdtToGauMeta(payload);

      if (!res) {
        return Tx.error(data, 'Meta tx failed', TxType.send);
      }

      final events = Stream<TxEvent>.value(const TxEvent(status: TxStatus.sent))
          .asBroadcastStream();
      final stream = GStream(events);
      return Tx(tx: null, events: stream, data: data, type: TxType.swap);
    } catch (e) {
      logger.e(e);
      return Tx.error(data, e.toString(), TxType.swap);
    }
  }

  Future<double> estimateAny(double amount, CurrencyTicker c1,
      CurrencyTicker c2, WidgetRef ref) async {
    // final wei = BigInt.from(data.amount * pow(10, 18))
    // final value = EtherAmount.fromUnitAndValue(EtherUnit.wei, wei);

    if (amount <= 0) {
      return 0;
    }

    final simpleSwap = SimpleSwap(wallet: wallet, client: client, ref: ref);
    final value = await simpleSwap.estimateAny(c1, c2, amount);
    return value;
  }
}
