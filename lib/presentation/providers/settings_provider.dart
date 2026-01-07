import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/entities/app_settings.dart';
import 'package:posventa/presentation/providers/di/core_di.dart';
import 'package:posventa/presentation/providers/di/inventory_di.dart';

part 'settings_provider.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Future<AppSettings> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
    return repository.getSettings();
  }

  Future<void> toggleInventory(bool value) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(useInventory: value));

    try {
      final repository = await ref.read(settingsRepositoryProvider.future);
      await repository.setUseInventory(value);

      if (!value) {
        // Strict Mode: Reset all inventory if disabled
        final resetInventory = ref.read(resetInventoryUseCaseProvider);
        await resetInventory.call();
      }
    } catch (e) {
      state = AsyncData(current);
      rethrow;
    }
  }

  Future<void> toggleTax(bool value) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(useTax: value));

    try {
      final repository = await ref.read(settingsRepositoryProvider.future);
      await repository.setUseTax(value);
    } catch (e) {
      state = AsyncData(current);
      rethrow;
    }
  }
}
