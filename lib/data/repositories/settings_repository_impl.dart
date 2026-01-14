import 'package:shared_preferences/shared_preferences.dart';
import 'package:posventa/core/constants/storage_keys.dart';
import 'package:posventa/domain/entities/app_settings.dart';
import 'package:posventa/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepositoryImpl(this._prefs);

  @override
  Future<AppSettings> getSettings() async {
    final useInventory = _prefs.getBool(StorageKeys.useInventory) ?? true;
    final useTax = _prefs.getBool(StorageKeys.useTax) ?? true;
    final printerName = _prefs.getString(StorageKeys.printerName);
    final printerAddress = _prefs.getString(StorageKeys.printerAddress);
    final paperWidthMm = _prefs.getInt(StorageKeys.paperWidthMm) ?? 80;

    // Backup and PDF paths
    final backupPath = _prefs.getString(StorageKeys.backupPath);
    final pdfSavePath = _prefs.getString(StorageKeys.pdfSavePath);

    // Print enable/disable flags
    final enableSalesPrinting =
        _prefs.getBool(StorageKeys.enableSalesPrinting) ?? true;
    final enablePaymentPrinting =
        _prefs.getBool(StorageKeys.enablePaymentPrinting) ?? true;
    final autoSavePdfWhenPrintDisabled =
        _prefs.getBool(StorageKeys.autoSavePdfWhenPrintDisabled) ?? true;

    // Automatic backup settings
    final autoBackupEnabled =
        _prefs.getBool(StorageKeys.autoBackupEnabled) ?? false;
    final autoBackupTimesJson =
        _prefs.getStringList(StorageKeys.autoBackupTimes) ?? [];
    final backupOnAppClose =
        _prefs.getBool(StorageKeys.backupOnAppClose) ?? true;
    final backupOnLogout = _prefs.getBool(StorageKeys.backupOnLogout) ?? true;
    final lastBackupTimeStr = _prefs.getString(StorageKeys.lastBackupTime);
    final lastBackupTime = lastBackupTimeStr != null
        ? DateTime.tryParse(lastBackupTimeStr)
        : null;

    return AppSettings(
      useInventory: useInventory,
      useTax: useTax,
      printerName: printerName,
      printerAddress: printerAddress,
      paperWidthMm: paperWidthMm,
      backupPath: backupPath,
      pdfSavePath: pdfSavePath,
      enableSalesPrinting: enableSalesPrinting,
      enablePaymentPrinting: enablePaymentPrinting,
      autoSavePdfWhenPrintDisabled: autoSavePdfWhenPrintDisabled,
      autoBackupEnabled: autoBackupEnabled,
      autoBackupTimes: autoBackupTimesJson,
      backupOnAppClose: backupOnAppClose,
      backupOnLogout: backupOnLogout,
      lastBackupTime: lastBackupTime,
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setBool(StorageKeys.useInventory, settings.useInventory);
    await _prefs.setBool(StorageKeys.useTax, settings.useTax);

    if (settings.printerName != null) {
      await _prefs.setString(StorageKeys.printerName, settings.printerName!);
    } else {
      await _prefs.remove(StorageKeys.printerName);
    }

    if (settings.printerAddress != null) {
      await _prefs.setString(
        StorageKeys.printerAddress,
        settings.printerAddress!,
      );
    } else {
      await _prefs.remove(StorageKeys.printerAddress);
    }

    await _prefs.setInt(StorageKeys.paperWidthMm, settings.paperWidthMm);

    // Backup and PDF paths
    if (settings.backupPath != null) {
      await _prefs.setString(StorageKeys.backupPath, settings.backupPath!);
    } else {
      await _prefs.remove(StorageKeys.backupPath);
    }

    if (settings.pdfSavePath != null) {
      await _prefs.setString(StorageKeys.pdfSavePath, settings.pdfSavePath!);
    } else {
      await _prefs.remove(StorageKeys.pdfSavePath);
    }

    // Print enable/disable flags
    await _prefs.setBool(
      StorageKeys.enableSalesPrinting,
      settings.enableSalesPrinting,
    );
    await _prefs.setBool(
      StorageKeys.enablePaymentPrinting,
      settings.enablePaymentPrinting,
    );
    await _prefs.setBool(
      StorageKeys.autoSavePdfWhenPrintDisabled,
      settings.autoSavePdfWhenPrintDisabled,
    );

    // Automatic backup settings
    await _prefs.setBool(
      StorageKeys.autoBackupEnabled,
      settings.autoBackupEnabled,
    );
    await _prefs.setStringList(
      StorageKeys.autoBackupTimes,
      settings.autoBackupTimes,
    );
    await _prefs.setBool(
      StorageKeys.backupOnAppClose,
      settings.backupOnAppClose,
    );
    await _prefs.setBool(StorageKeys.backupOnLogout, settings.backupOnLogout);
    if (settings.lastBackupTime != null) {
      await _prefs.setString(
        StorageKeys.lastBackupTime,
        settings.lastBackupTime!.toIso8601String(),
      );
    } else {
      await _prefs.remove(StorageKeys.lastBackupTime);
    }
  }

  @override
  Future<void> setUseInventory(bool value) async {
    await _prefs.setBool(StorageKeys.useInventory, value);
  }

  @override
  Future<void> setUseTax(bool value) async {
    await _prefs.setBool(StorageKeys.useTax, value);
  }
}
