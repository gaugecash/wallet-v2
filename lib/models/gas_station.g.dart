// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gas_station.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GasStationModel _$GasStationModelFromJson(Map<String, dynamic> json) =>
    GasStationModel(
      blockNumber: (json['blockNumber'] as num).toInt(),
      blockTime: (json['blockTime'] as num).toInt(),
      estimatedBaseFee: json['estimatedBaseFee'],
      fast: GasStationModelPlan.fromJson(json['fast'] as Map<String, dynamic>),
      standard: GasStationModelPlan.fromJson(
          json['standard'] as Map<String, dynamic>),
      safeLow:
          GasStationModelPlan.fromJson(json['safeLow'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GasStationModelToJson(GasStationModel instance) =>
    <String, dynamic>{
      'blockNumber': instance.blockNumber,
      'blockTime': instance.blockTime,
      'estimatedBaseFee': instance.estimatedBaseFee,
      'fast': instance.fast,
      'standard': instance.standard,
      'safeLow': instance.safeLow,
    };

GasStationModelPlan _$GasStationModelPlanFromJson(Map<String, dynamic> json) =>
    GasStationModelPlan(
      maxPriorityFee: json['maxPriorityFee'],
      maxFee: json['maxFee'],
    );

Map<String, dynamic> _$GasStationModelPlanToJson(
        GasStationModelPlan instance) =>
    <String, dynamic>{
      'maxPriorityFee': instance.maxPriorityFee,
      'maxFee': instance.maxFee,
    };
