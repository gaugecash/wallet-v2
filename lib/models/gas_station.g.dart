// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gas_station.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GasStationModel _$GasStationModelFromJson(Map json) => $checkedCreate(
      'GasStationModel',
      json,
      ($checkedConvert) {
        final val = GasStationModel(
          blockNumber:
              $checkedConvert('blockNumber', (v) => (v as num).toInt()),
          blockTime: $checkedConvert('blockTime', (v) => (v as num).toInt()),
          estimatedBaseFee: $checkedConvert('estimatedBaseFee', (v) => v),
          fast: $checkedConvert(
              'fast',
              (v) => GasStationModelPlan.fromJson(
                  Map<String, dynamic>.from(v as Map))),
          standard: $checkedConvert(
              'standard',
              (v) => GasStationModelPlan.fromJson(
                  Map<String, dynamic>.from(v as Map))),
          safeLow: $checkedConvert(
              'safeLow',
              (v) => GasStationModelPlan.fromJson(
                  Map<String, dynamic>.from(v as Map))),
        );
        return val;
      },
    );

Map<String, dynamic> _$GasStationModelToJson(GasStationModel instance) =>
    <String, dynamic>{
      'blockNumber': instance.blockNumber,
      'blockTime': instance.blockTime,
      'estimatedBaseFee': instance.estimatedBaseFee,
      'fast': instance.fast.toJson(),
      'standard': instance.standard.toJson(),
      'safeLow': instance.safeLow.toJson(),
    };

GasStationModelPlan _$GasStationModelPlanFromJson(Map json) => $checkedCreate(
      'GasStationModelPlan',
      json,
      ($checkedConvert) {
        final val = GasStationModelPlan(
          maxPriorityFee: $checkedConvert('maxPriorityFee', (v) => v),
          maxFee: $checkedConvert('maxFee', (v) => v),
        );
        return val;
      },
    );

Map<String, dynamic> _$GasStationModelPlanToJson(
        GasStationModelPlan instance) =>
    <String, dynamic>{
      'maxPriorityFee': instance.maxPriorityFee,
      'maxFee': instance.maxFee,
    };
