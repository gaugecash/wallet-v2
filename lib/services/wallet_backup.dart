import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
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

  static const String _backupFileName = 'wallet_backup.txt';

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

  /// Auto-saves encrypted backup to local storage
  /// iOS: Application Support directory (auto-backed up by iCloud Backup)
  /// Android: Application Documents directory (auto-backed up by Google Auto Backup)
  /// Silently fails if storage is unavailable (zero UX friction)
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

      showMessage('Saving to local storage...');
      await _saveToLocalStorage(encrypted);

      if (kIsWeb) {
        showMessage('✓ Backup encrypted. Download the backup file to save it.');
      } else if (Platform.isIOS) {
        showMessage('✓ Backup saved (auto-backed up by iCloud Backup)');
      } else if (Platform.isAndroid) {
        showMessage('✓ Backup saved (auto-backed up by Google Auto Backup)');
      }
    } catch (e, stackTrace) {
      // Silent failure - do not show error to user
      // This is intentional: ~70-80% iOS users have iCloud enabled
      // For the 20-30% who don't, backup fails silently (zero friction UX)
      showMessage('⚠ Auto-save failed: $e');
      print('DEBUG: Stack trace: $stackTrace');
    }
  }

  /// Saves encrypted backup to local storage
  /// iOS: Application Support directory (hidden from user, auto-backed up by iCloud Backup)
  /// Android: Application Documents directory (auto-backed up by Google Auto Backup)
  /// Web: Skip auto-save (user downloads .txt file manually via share button)
  Future<void> _saveToLocalStorage(String encryptedBackup) async {
    try {
      // Web: Skip local storage save (no persistent file system)
      // User will download backup manually via share button
      if (kIsWeb) {
        developer.log('DEBUG: LOCAL BACKUP - Web platform detected, skipping auto-save', name: 'GAUwallet');
        return;
      }

      // Get platform-specific directory
      final Directory directory;
      if (Platform.isIOS) {
        // iOS: Use Application Support directory (hidden from user, auto-backed up)
        directory = await getApplicationSupportDirectory();
      } else {
        // Android: Use Application Documents directory (auto-backed up by Google Auto Backup)
        directory = await getApplicationDocumentsDirectory();
      }

      developer.log('DEBUG: LOCAL BACKUP - Save target directory: ${directory.path}', name: 'GAUwallet');

      // Ensure directory exists (defensive programming)
      if (!await directory.exists()) {
        developer.log('DEBUG: LOCAL BACKUP - Directory does not exist, creating...', name: 'GAUwallet');
        await directory.create(recursive: true);
      }

      // ATOMIC WRITE: Write to temporary file first, then rename
      final finalPath = '${directory.path}/$_backupFileName';
      final tempPath = '$finalPath.tmp';
      
      developer.log('DEBUG: LOCAL BACKUP - Writing to temp file: $tempPath', name: 'GAUwallet');
      final tempFile = File(tempPath);
      await tempFile.writeAsString(encryptedBackup);
      
      developer.log('DEBUG: LOCAL BACKUP - Renaming to final path: $finalPath', name: 'GAUwallet');
      // Rename is an atomic operation at the OS level
      await tempFile.rename(finalPath);

      // VERIFY: Check if file actually exists now
      final exists = await File(finalPath).exists();
      developer.log('DEBUG: LOCAL BACKUP - Save complete. File exists at final path: $exists', name: 'GAUwallet');

      // System-level backup handles cloud sync:
      // - iOS: iCloud Backup (automatic, when device locked + charging + WiFi)
      // - Android: Google Auto Backup (automatic, when idle + charging + WiFi)
    } catch (e, stackTrace) {
      developer.log('DEBUG: LOCAL BACKUP ERROR: Failed to save backup', error: e, stackTrace: stackTrace, name: 'GAUwallet');
      rethrow;
    }
  }

  /// Checks if an auto-saved backup exists in local storage
  /// Returns the encrypted backup string if found, null otherwise
  static Future<String?> checkForAutoSavedBackup() async {
    developer.log('DEBUG: LOCAL BACKUP - checkForAutoSavedBackup() called', name: 'GAUwallet');
    try {
      final result = await _checkLocalBackup();
      developer.log('DEBUG: LOCAL BACKUP - checkForAutoSavedBackup() returning ${result != null ? "FOUND" : "NOT FOUND"}', name: 'GAUwallet');
      return result;
    } catch (e, stackTrace) {
      developer.log('DEBUG: LOCAL BACKUP ERROR: Error checking for backup', error: e, stackTrace: stackTrace, name: 'GAUwallet');
      return null;
    }
  }

  /// Checks for backup in local storage
  /// iOS: Application Support directory
  /// Android: Application Documents directory
  /// Web: No auto-saved backup (user downloads manually)
  static Future<String?> _checkLocalBackup() async {
    try {
      // Web: No local file storage, return null
      if (kIsWeb) {
        developer.log('DEBUG: LOCAL BACKUP - Web platform detected, no auto-saved backup available', name: 'GAUwallet');
        return null;
      }

      // Get platform-specific directory
      final Directory directory;
      if (Platform.isIOS) {
        directory = await getApplicationSupportDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final backupPath = '${directory.path}/$_backupFileName';
      developer.log('DEBUG: LOCAL BACKUP - Checking for file at: $backupPath', name: 'GAUwallet');

      final backupFile = File(backupPath);

      if (await backupFile.exists()) {
        final content = await backupFile.readAsString();
        developer.log('DEBUG: LOCAL BACKUP - Found existing backup (${content.length} chars)', name: 'GAUwallet');
        return content;
      }

      developer.log('DEBUG: LOCAL BACKUP - No existing backup found at: $backupPath', name: 'GAUwallet');
      return null;
    } catch (e, stackTrace) {
      developer.log('DEBUG: LOCAL BACKUP ERROR: Failed to read backup file', error: e, stackTrace: stackTrace, name: 'GAUwallet');
      rethrow;
    }
  }
}
