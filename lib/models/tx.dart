import 'package:wallet/logger.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/utils/gstream.dart';

enum TxStatus {
  sent,
  sending,
  error,
}

enum TxType { send, swap }

class Tx {
  const Tx({
    required this.tx,
    required this.events,
    required this.data,
    required this.type,
  });

  factory Tx.error(TxData data, String message, TxType type) {
    logger.e(message);

    final events = Stream<TxEvent>.value(TxError(message)).asBroadcastStream();
    final stream = GStream(events);
    return Tx(tx: null, events: stream, data: data, type: type);
  }

  final String? tx;
  final GStream<TxEvent> events;
  final TxData data;
  final TxType type;
}

class TxEvent {
  const TxEvent({
    required this.status,
  });

  final TxStatus status;
}

class TxError extends TxEvent {
  const TxError(this.error) : super(status: TxStatus.error);

  final String error;
}

class TxData {
  const TxData({
    required this.amount,
    required this.currency,
    // as can be just swap
    this.address,
    this.useMetaIfPossible = false,
  });

  final double amount;
  final Currency currency;
  final String? address;
  final bool useMetaIfPossible;
}
