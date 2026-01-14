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

    return AppSettings(
      useInventory: useInventory,
      useTax: useTax,
      printerName: printerName,
      printerAddress: printerAddress,
      paperWidthMm: paperWidthMm,
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setBool(StorageKeys.useInventory, settings.useInventory);
    await _prefs.setBool(StorageKeys.useTax, settings.useTax);
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
