import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/repositories/tax_rate_repository.dart';
import 'package:posventa/data/repositories/tax_rate_repository_impl.dart';
import 'package:posventa/domain/use_cases/tax_rate/get_all_tax_rates.dart';
import 'package:posventa/domain/use_cases/tax_rate/create_tax_rate.dart';
import 'package:posventa/domain/use_cases/tax_rate/update_tax_rate.dart';
import 'package:posventa/domain/use_cases/tax_rate/delete_tax_rate.dart';
import 'package:posventa/domain/use_cases/tax_rate/set_default_tax_rate.dart';

part 'tax_rate_provider.g.dart';

@riverpod
class TaxRateList extends _$TaxRateList {
  @override
  Future<List<TaxRate>> build() async {
    final getAllTaxRates = ref.watch(getAllTaxRatesProvider);
    return getAllTaxRates();
  }

  Future<void> addTaxRate(TaxRate taxRate) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(createTaxRateProvider).call(taxRate);
      return ref.read(getAllTaxRatesProvider).call();
    });
  }

  Future<void> updateTaxRate(TaxRate taxRate) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateTaxRateProvider).call(taxRate);
      return ref.read(getAllTaxRatesProvider).call();
    });
  }

  Future<void> deleteTaxRate(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteTaxRateProvider).call(id);
      return ref.read(getAllTaxRatesProvider).call();
    });
  }

  Future<void> setDefaultTaxRate(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(setDefaultTaxRateProvider).call(id);
      return ref.read(getAllTaxRatesProvider).call();
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

@riverpod
TaxRateRepository taxRateRepository(ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return TaxRateRepositoryImpl(dbHelper);
}

@riverpod
GetAllTaxRates getAllTaxRates(ref) {
  final repository = ref.watch(taxRateRepositoryProvider);
  return GetAllTaxRates(repository);
}

@riverpod
CreateTaxRate createTaxRate(ref) {
  final repository = ref.watch(taxRateRepositoryProvider);
  return CreateTaxRate(repository);
}

@riverpod
UpdateTaxRate updateTaxRate(ref) {
  final repository = ref.watch(taxRateRepositoryProvider);
  return UpdateTaxRate(repository);
}

@riverpod
DeleteTaxRate deleteTaxRate(ref) {
  final repository = ref.watch(taxRateRepositoryProvider);
  return DeleteTaxRate(repository);
}

@riverpod
SetDefaultTaxRate setDefaultTaxRate(ref) {
  final repository = ref.watch(taxRateRepositoryProvider);
  return SetDefaultTaxRate(repository);
}
