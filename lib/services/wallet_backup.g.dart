// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_backup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletBackup _$WalletBackupFromJson(Map<String, dynamic> json) => WalletBackup(
      mnemonic: json['mnemonic'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      appVersion: json['appVersion'] as String,
      appBuild: json['appBuild'] as String,
      backupFileVersion: (json['backupFileVersion'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$WalletBackupToJson(WalletBackup instance) =>
    <String, dynamic>{
      'mnemonic': instance.mnemonic,
      'createdAt': instance.createdAt.toIso8601String(),
      'appVersion': instance.appVersion,
      'appBuild': instance.appBuild,
      'backupFileVersion': instance.backupFileVersion,
    };
