import 'package:dart_web3/dart_web3.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gas_station.g.dart';

class GasResults {
  const GasResults({
    required this.maxFeePerGas,
    required this.maxPriorityFeePerGas,
    required this.maxGas,
  });

  final EtherAmount maxFeePerGas;
  final EtherAmount maxPriorityFeePerGas;
  final int maxGas;
}

@JsonSerializable()
class GasStationModel {
  const GasStationModel({
    required this.blockNumber,
    required this.blockTime,
    required this.estimatedBaseFee,
    required this.fast,
    required this.standard,
    required this.safeLow,
  });

  factory GasStationModel.fromJson(Map<String, dynamic> json) => _$GasStationModelFromJson(json);

  @JsonKey(name: 'blockNumber')
  final int blockNumber;

  @JsonKey(name: 'blockTime')
  final int blockTime;

  @JsonKey(name: 'estimatedBaseFee')
  final dynamic estimatedBaseFee;

  final GasStationModelPlan fast;
  final GasStationModelPlan standard;

  @JsonKey(name: 'safeLow')
  final GasStationModelPlan safeLow;

  Map<String, dynamic> toJson() => _$GasStationModelToJson(this);
}

@JsonSerializable()
class GasStationModelPlan {
  const GasStationModelPlan({
    required this.maxPriorityFee,
    required this.maxFee,
  });

  factory GasStationModelPlan.fromJson(Map<String, dynamic> json) =>
      _$GasStationModelPlanFromJson(json);

  @JsonKey(name: 'maxPriorityFee')
  final dynamic maxPriorityFee;

  @JsonKey(name: 'maxFee')
  final dynamic maxFee;

  Map<String, dynamic> toJson() => _$GasStationModelPlanToJson(this);
}
