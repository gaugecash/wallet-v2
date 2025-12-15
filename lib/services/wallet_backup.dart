import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wallet/services/encrypt.dart';
import 'package:wallet/utils/git_commit.dart';

part 'wallet_backup.g.dart';

@JsonSerializable()
class WalletBackup {
  const WalletBackup({
    required this.mnemonic,
    required this.createdAt,
    required this.appVersion,
    required this.appBuild,
    this.backupFileVersion = 0,
  });

  factory WalletBackup.fromJson(Map json) => _$WalletBackupFromJson(json);

  static Future<WalletBackup> generate(String mnemonic) async {
    final createdAt = DateTime.now();

    final packageInfo = await PackageInfo.fromPlatform();

    final appVersion = packageInfo.version;

    final appBuildCommit = await getGitCommit();

    return WalletBackup(
      mnemonic: mnemonic,
      createdAt: createdAt,
      appVersion: appVersion,
      appBuild: appBuildCommit,
    );
  }

  final String mnemonic;
  final DateTime createdAt;
  final String appVersion;
  final String appBuild;
  final int backupFileVersion;

  Map<String, dynamic> toJson() => _$WalletBackupToJson(this);

  // todo handle errors
  Future<String> encrypt(String password) async {
    // print('encrypting');
    final json = jsonEncode(toJson());
    final encrypted = await computeEncrypt(password, json);
    return encrypted;
  }

  static Future<WalletBackup> decrypt(String password, String encrypted) async {
    final result = await computeDecrypt(password, encrypted);
    final json = jsonDecode(result) as Map;
    return WalletBackup.fromJson(json);
  }

  // todo validate file function is malfunctioning
  static bool validate(String file) {
    if (!file.contains('.') || file.split('.').length != 2) {
      return false;
    }
    try {
      final split = file.split('.');
      final part1 = split[0];
      final part2 = split[0];

      if(part1.isEmpty || part2.isEmpty){
        return false;
      }

      base64Decode(part1);
      base64Decode(part2);
      return true;
    } catch (e) {}

    return false;
  }
}
