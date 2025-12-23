import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tax_rate_provider.g.dart';

@Riverpod(keepAlive: true)
class TaxRateList extends _$TaxRateList {
  @override
  Future<List<TaxRate>> build() async {
    final getAllTaxRates = ref.watch(getAllTaxRatesUseCaseProvider);
    return getAllTaxRates();
  }

  Future<void> addTaxRate(TaxRate taxRate) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(createTaxRateProvider).call(taxRate);
      return ref.read(getAllTaxRatesUseCaseProvider).call();
    });
  }

  Future<void> updateTaxRate(TaxRate taxRate) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateTaxRateProvider).call(taxRate);
      return ref.read(getAllTaxRatesUseCaseProvider).call();
    });
  }

  Future<void> deleteTaxRate(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteTaxRateProvider).call(id);
      return ref.read(getAllTaxRatesUseCaseProvider).call();
    });
  }

  Future<void> setDefaultTaxRate(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(setDefaultTaxRateProvider).call(id);
      return ref.read(getAllTaxRatesUseCaseProvider).call();
    });
  }

  bool isDuplicateName(String name, int? excludeId) {
    final taxRates = state.asData?.value ?? [];
    return taxRates.any(
      (t) => t.name.toLowerCase() == name.toLowerCase() && t.id != excludeId,
    );
  }

  bool isDuplicateCode(String code, int? excludeId) {
    final taxRates = state.asData?.value ?? [];
    return taxRates.any(
      (t) => t.code.toLowerCase() == code.toLowerCase() && t.id != excludeId,
    );
  }
}

// We need to export the manual providers that were previously defined here if they are used elsewhere.
// However, providers.dart seems to define the use cases, but NOT the repository provider for TaxRate?
// Let's check providers.dart again. It does NOT seem to have TaxRate providers.
// The previous file defined: taxRateRepositoryProvider, getAllTaxRatesProvider, etc.
// I need to keep these or move them to providers.dart or keep them here using riverpod_generator.

// Re-implementing the use case providers using riverpod_generator in this file for now to avoid breaking changes in other files that might import them from here.

// Providers moved to product_di.dart
