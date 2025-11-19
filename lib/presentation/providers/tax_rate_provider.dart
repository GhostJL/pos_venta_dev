import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/repositories/tax_rate_repository_impl.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/domain/use_cases/tax_rate/create_tax_rate.dart';
import 'package:posventa/domain/use_cases/tax_rate/delete_tax_rate.dart';
import 'package:posventa/domain/use_cases/tax_rate/get_all_tax_rates.dart';
import 'package:posventa/domain/use_cases/tax_rate/set_default_tax_rate.dart';
import 'package:posventa/domain/use_cases/tax_rate/update_tax_rate.dart';

final taxRateRepositoryProvider = Provider((ref) {
  final dbHelper = DatabaseHelper.instance;
  return TaxRateRepositoryImpl(dbHelper);
});

final getAllTaxRatesProvider = Provider((ref) {
  final repository = ref.watch(taxRateRepositoryProvider);
  return GetAllTaxRates(repository);
});

final createTaxRateProvider = Provider((ref) {
  final repository = ref.watch(taxRateRepositoryProvider);
  return CreateTaxRate(repository);
});

final updateTaxRateProvider = Provider((ref) {
  final repository = ref.watch(taxRateRepositoryProvider);
  return UpdateTaxRate(repository);
});

final deleteTaxRateProvider = Provider((ref) {
  final repository = ref.watch(taxRateRepositoryProvider);
  return DeleteTaxRate(repository);
});

final setDefaultTaxRateProvider = Provider((ref) {
  final repository = ref.watch(taxRateRepositoryProvider);
  return SetDefaultTaxRate(repository);
});

final taxRateListProvider =
    StateNotifierProvider<TaxRateNotifier, AsyncValue<List<TaxRate>>>((ref) {
      return TaxRateNotifier(ref);
    });

class TaxRateNotifier extends StateNotifier<AsyncValue<List<TaxRate>>> {
  final Ref _ref;

  TaxRateNotifier(this._ref) : super(const AsyncValue.loading()) {
    fetchTaxRates();
  }

  Future<void> fetchTaxRates() async {
    state = const AsyncValue.loading();
    try {
      final taxRates = await _ref.read(getAllTaxRatesProvider)();
      state = AsyncValue.data(taxRates);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> addTaxRate(TaxRate taxRate) async {
    try {
      await _ref.read(createTaxRateProvider)(taxRate);
      await fetchTaxRates();
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> updateTaxRate(TaxRate taxRate) async {
    try {
      await _ref.read(updateTaxRateProvider)(taxRate);
      await fetchTaxRates();
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> deleteTaxRate(int id) async {
    try {
      await _ref.read(deleteTaxRateProvider)(id);
      await fetchTaxRates();
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> setDefaultTaxRate(int id) async {
    try {
      await _ref.read(setDefaultTaxRateProvider)(id);
      await fetchTaxRates();
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}
