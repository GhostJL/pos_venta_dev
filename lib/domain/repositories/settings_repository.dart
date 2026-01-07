import 'package:posventa/domain/entities/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<void> setUseInventory(bool value);
  Future<void> setUseTax(bool value);
}
