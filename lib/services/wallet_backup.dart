import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
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

  /// Validates encrypted backup file format
  /// Expected format: SALT.IV.ENCRYPTED_DATA.AUTH_TAG (4 parts, base64 encoded)
  static bool validate(String file) {
    if (!file.contains('.') || file.split('.').length != 4) {
      return false;
    }
    try {
      final parts = file.split('.');

      // Validate all 4 parts are non-empty and valid base64
      for (final part in parts) {
        if (part.isEmpty) {
          return false;
        }
        base64Decode(part);
      }

      // Validate expected byte lengths after decoding
      final salt = base64Decode(parts[0]);
      final iv = base64Decode(parts[1]);
      final authTag = base64Decode(parts[3]);

      // Salt must be 32 bytes, IV must be 12 bytes (GCM standard), Auth tag must be 16 bytes
      if (salt.length != 32) return false;
      if (iv.length != 12) return false;
      if (authTag.length != 16) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Platform channel for iOS/Android native code
  static const _platform = MethodChannel('com.gaugecash.wallet/backup');

  /// Auto-saves encrypted backup to platform-specific cloud storage
  /// iOS: iCloud ubiquity container
  /// Android: Google Auto Backup (automatic sync to Google Drive)
  /// Silently fails if cloud storage is unavailable (zero UX friction)
  Future<void> autoSave(String password) async {
    try {
      final encrypted = await encrypt(password);

      if (Platform.isIOS) {
        await _saveToiCloud(encrypted);
      } else if (Platform.isAndroid) {
        // Android Auto Backup integration (Phase 1.3 - COMPLETED)
        // Save to app files directory - Android automatically backs up to Google Drive
        // Configuration in backup_rules.xml and data_extraction_rules.xml
        await _saveToAndroidFiles(encrypted);
      }
    } catch (e) {
      // Silent failure - do not show error to user
      // This is intentional: ~70-80% iOS users have iCloud enabled
      // For the 20-30% who don't, backup fails silently (zero friction UX)
      print('Auto-save failed (expected if cloud storage disabled): $e');
    }
  }

  /// Saves encrypted backup to iOS iCloud ubiquity container
  /// Requires iCloud Documents capability (configured in Runner.entitlements)
  Future<void> _saveToiCloud(String encryptedBackup) async {
    try {
      // Request iCloud container path from iOS native code
      final iCloudPath = await _platform.invokeMethod<String>('getICloudPath');

      if (iCloudPath == null) {
        throw Exception('iCloud container not available');
      }

      // Save encrypted backup to iCloud
      final backupFile = File('$iCloudPath/wallet_backup.txt');
      await backupFile.writeAsString(encryptedBackup);

      // iOS automatically syncs to iCloud - no additional code needed
    } catch (e) {
      rethrow;
    }
  }

  /// Saves encrypted backup to Android app files directory
  /// Android Auto Backup automatically syncs this to Google Drive
  /// Configuration in backup_rules.xml and data_extraction_rules.xml
  Future<void> _saveToAndroidFiles(String encryptedBackup) async {
    try {
      // Get app documents directory (automatically backed up by Android)
      final directory = await getApplicationDocumentsDirectory();

      // Save encrypted backup to app files
      final backupFile = File('${directory.path}/wallet_backup.txt');
      await backupFile.writeAsString(encryptedBackup);

      // Android Auto Backup automatically syncs to Google Drive when:
      // - User has backup enabled in Android settings
      // - Device is idle, charging, and on Wi-Fi
      // - Less than 24 hours since last backup
    } catch (e) {
      rethrow;
    }
  }

  /// Checks if an auto-saved backup exists in platform-specific cloud storage
  /// Returns the encrypted backup string if found, null otherwise
  static Future<String?> checkForAutoSavedBackup() async {
    try {
      if (Platform.isIOS) {
        return await _checkiCloudBackup();
      } else if (Platform.isAndroid) {
        return await _checkAndroidBackup();
      }
      return null;
    } catch (e) {
      // Silent failure
      return null;
    }
  }

  /// Checks for backup in iOS iCloud ubiquity container
  static Future<String?> _checkiCloudBackup() async {
    try {
      final iCloudPath = await _platform.invokeMethod<String>('getICloudPath');

      if (iCloudPath == null) {
        return null;
      }

      final backupFile = File('$iCloudPath/wallet_backup.txt');

      if (await backupFile.exists()) {
        return await backupFile.readAsString();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Checks for backup in Android app files directory
  /// Android Auto Backup syncs files to/from Google Drive automatically
  static Future<String?> _checkAndroidBackup() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupFile = File('${directory.path}/wallet_backup.txt');

      if (await backupFile.exists()) {
        return await backupFile.readAsString();
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
