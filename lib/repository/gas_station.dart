import 'dart:convert';
import 'dart:math';

import 'package:dart_web3/dart_web3.dart';
import 'package:http/http.dart' as http;
import 'package:wallet/conf.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/models/gas_station.dart';

class GasStation {
  static String get _gasStation =>
      network == Network.main ? mainGasStation : testGasStation;

  /// + in % of gwei
  /// 10%
  static const double _gasAhead = 1.2;

  /// 0.4 million max gas
  /// assuming the gas price is 50 gwei
  /// the max fee is 0.02 matic = 0.012 usd
  static const int _maxGas = 500000;

  // todo handle errors
  static Future<GasStationModel> _getGasStation() async {
    final req = await http.get(Uri.parse(_gasStation));

    final parsed = jsonDecode(req.body) as Map<String, dynamic>;
    return GasStationModel.fromJson(parsed);
  }

  static Future<GasResults> getGas() async {
    final station = await _getGasStation();

    final maxFee = station.fast.maxFee.runtimeType == String
        ? double.parse(station.fast.maxFee as String)
        : station.fast.maxFee as double;

    final maxFeePerGasWei = (maxFee * _gasAhead) * pow(10, 9);
    // final maxPriorityFeePerGasWei =
    //     (station.fast.maxPriorityFee - station.fast.maxFee + _gasAhead) *
    //         pow(10, 9);

    // final maxPriorityFee = double.parse(station.fast.maxPriorityFee);

    final maxPriorityFee = station.fast.maxPriorityFee.runtimeType == String
        ? double.parse(station.fast.maxFee as String)
        : station.fast.maxFee as double;

    final maxPriorityFeePerGasWei =
        (maxPriorityFee * _gasAhead) * pow(10, 9);

    final maxFeePerGas = EtherAmount.inWei(BigInt.from(maxFeePerGasWei));
    final maxPriorityFeePerGas =
        EtherAmount.inWei(BigInt.from(maxPriorityFeePerGasWei));

    logger.i('fee: ${maxFeePerGas.getValueInUnit(EtherUnit.gwei)}');

    return GasResults(
      maxFeePerGas: maxFeePerGas,
      maxPriorityFeePerGas: maxPriorityFeePerGas,
      maxGas: _maxGas,
    );
  }
}
