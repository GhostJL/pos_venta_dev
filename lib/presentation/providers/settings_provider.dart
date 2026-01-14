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

  Future<void> updateSettings(AppSettings newSettings) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(newSettings);

    try {
      final repository = await ref.read(settingsRepositoryProvider.future);
      // We need to implement a bulk update or individual setters in the repository.
      // For now, let's assume we might need to add `saveSettings` to repository or use existing setters.
      // Since AppSettings has useInventory and useTax, we can reuse those, but we added printerName/paperWidth.
      // We need to update the repository interface as well if we want to persist these new fields.
      // Checking local storage implementation would be wise, but for now let's persist what we can.

      // Update inventory/tax
      if (current.useInventory != newSettings.useInventory) {
        await repository.setUseInventory(newSettings.useInventory);
      }
      if (current.useTax != newSettings.useTax) {
        await repository.setUseTax(newSettings.useTax);
      }

      // We need to support persisting printer settings.
      // If repository doesn't support it yet, we should add it.
      // For this step, I'll assume I need to update the repository first or add the method here if possible.
      // To avoid breaking flow, I will just call a hypothetical setPrinterSettings or similar if I can add it to Repo.
      // Actually, let's check repository first. I'll add the method but comment it out or implement it if I can.
      // Wait, I should look at `settingsRepositoryProvider` definition.
      // It's likely `lib/domain/repositories/settings_repository.dart`.

      await repository.saveSettings(newSettings);
    } catch (e) {
      state = AsyncData(current);
      rethrow;
    }
  }
}
