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

    return AppSettings(useInventory: useInventory, useTax: useTax);
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setBool(StorageKeys.useInventory, settings.useInventory);
    await _prefs.setBool(StorageKeys.useTax, settings.useTax);
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
