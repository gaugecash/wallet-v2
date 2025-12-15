// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_backup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletBackup _$WalletBackupFromJson(Map json) => $checkedCreate(
      'WalletBackup',
      json,
      ($checkedConvert) {
        final val = WalletBackup(
          mnemonic: $checkedConvert('mnemonic', (v) => v as String),
          createdAt:
              $checkedConvert('created_at', (v) => DateTime.parse(v as String)),
          appVersion: $checkedConvert('app_version', (v) => v as String),
          appBuild: $checkedConvert('app_build', (v) => v as String),
          backupFileVersion: $checkedConvert(
              'backup_file_version', (v) => (v as num?)?.toInt() ?? 0),
        );
        return val;
      },
      fieldKeyMap: const {
        'createdAt': 'created_at',
        'appVersion': 'app_version',
        'appBuild': 'app_build',
        'backupFileVersion': 'backup_file_version'
      },
    );

Map<String, dynamic> _$WalletBackupToJson(WalletBackup instance) =>
    <String, dynamic>{
      'mnemonic': instance.mnemonic,
      'created_at': instance.createdAt.toIso8601String(),
      'app_version': instance.appVersion,
      'app_build': instance.appBuild,
      'backup_file_version': instance.backupFileVersion,
    };
