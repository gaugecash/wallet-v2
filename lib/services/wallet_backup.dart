import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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

  factory WalletBackup.fromJson(Map<String, dynamic> json) => _$WalletBackupFromJson(json);

  static Future<WalletBackup> generate(String mnemonic) async {
    final createdAt = DateTime.now();

    // BUILD 152 - Re-enabled with getGitCommit() fix (now uses build-time constant)
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = packageInfo.version;

    // Fixed: Now uses build-time constant instead of reading from assets
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
    final json = jsonDecode(result) as Map<String, dynamic>;
    return WalletBackup.fromJson(json);
  }

  /// Validates encrypted backup file format
  /// Supports BOTH formats for backward compatibility:
  /// - NEW FORMAT (4 parts): SALT.IV.ENCRYPTED_DATA.AUTH_TAG
  /// - LEGACY FORMAT (2 parts): ENCRYPTED_DATA.MAC (from before Phase 1 Security)
  static bool validate(String file) {
    if (!file.contains('.')) {
      return false;
    }

    try {
      final parts = file.split('.');

      // Validate based on number of parts
      if (parts.length == 2) {
        // LEGACY FORMAT: ENCRYPTED_DATA.MAC
        return _validateLegacyFormat(parts);
      } else if (parts.length == 4) {
        // NEW FORMAT: SALT.IV.ENCRYPTED_DATA.AUTH_TAG
        return _validateNewFormat(parts);
      } else {
        // Invalid format
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Validates NEW format: SALT.IV.ENCRYPTED_DATA.AUTH_TAG (4 parts)
  static bool _validateNewFormat(List<String> parts) {
    try {
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

  /// Validates LEGACY format: ENCRYPTED_DATA.MAC (2 parts)
  static bool _validateLegacyFormat(List<String> parts) {
    try {
      // Validate both parts are non-empty and valid base64
      for (final part in parts) {
        if (part.isEmpty) {
          return false;
        }
        base64Decode(part);
      }

      // Legacy format doesn't have strict byte length requirements
      // Just verify both parts decode successfully (already done above)
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
  Future<void> autoSave(String password, {BuildContext? context}) async {
    print('DEBUG: autoSave() called - starting backup');

    void showMessage(String message) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      print('DEBUG: $message');
    }

    try {
      showMessage('Encrypting backup...');
      final encrypted = await encrypt(password);
      showMessage('Backup encrypted (${encrypted.length} chars)');

      if (Platform.isIOS) {
        showMessage('Saving to iCloud...');
        await _saveToiCloud(encrypted, context: context);
        showMessage('✓ Backup saved to iCloud');
      } else if (Platform.isAndroid) {
        showMessage('Saving to Android backup...');
        // Android Auto Backup integration (Phase 1.3 - COMPLETED)
        // Save to app files directory - Android automatically backs up to Google Drive
        // Configuration in backup_rules.xml and data_extraction_rules.xml
        await _saveToAndroidFiles(encrypted);
        showMessage('✓ Backup saved to app files');
      }
    } catch (e, stackTrace) {
      // Silent failure - do not show error to user
      // This is intentional: ~70-80% iOS users have iCloud enabled
      // For the 20-30% who don't, backup fails silently (zero friction UX)
      showMessage('⚠ Auto-save failed: $e');
      print('DEBUG: Stack trace: $stackTrace');
    }
  }

  /// Saves encrypted backup to iOS iCloud ubiquity container
  /// Requires iCloud Documents capability (configured in Runner.entitlements)
  Future<void> _saveToiCloud(String encryptedBackup, {BuildContext? context}) async {
    void showMessage(String message) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      print('DEBUG: $message');
    }

    try {
      showMessage('Requesting iCloud container path...');
      // Request iCloud container path from iOS native code
      final iCloudPath = await _platform.invokeMethod<String>('getICloudPath');

      if (iCloudPath == null) {
        showMessage('⚠ iCloud container NOT available (null)');
        throw Exception('iCloud container not available');
      }

      showMessage('✓ iCloud path: $iCloudPath');

      // Ensure Documents directory exists (defensive programming)
      final directory = Directory(iCloudPath);
      if (!await directory.exists()) {
        showMessage('Creating iCloud Documents directory...');
        await directory.create(recursive: true);
        showMessage('✓ Directory created');
      }

      // Save encrypted backup to iCloud
      final backupFile = File('$iCloudPath/wallet_backup.txt');
      showMessage('Writing file to iCloud...');
      await backupFile.writeAsString(encryptedBackup);

      // VERIFY: Check if file actually exists and has content
      final fileExists = await backupFile.exists();

      if (fileExists) {
        final fileSize = await backupFile.length();
        final fileContent = await backupFile.readAsString();
        final matches = fileContent == encryptedBackup;
        showMessage('✓ File written ($fileSize bytes, verified: $matches)');
      } else {
        showMessage('⚠ File verification FAILED - file does not exist!');
        throw Exception('File write verification failed - file does not exist');
      }

      // iOS automatically syncs to iCloud - no additional code needed
    } catch (e, stackTrace) {
      showMessage('⚠ iCloud save failed: $e');
      print('DEBUG: Stack trace: $stackTrace');
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
