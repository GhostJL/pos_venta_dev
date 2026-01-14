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
