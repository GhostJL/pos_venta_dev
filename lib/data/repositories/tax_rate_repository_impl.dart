import '../models/tax_rate_model.dart';
import '../../domain/entities/tax_rate.dart';
import '../../domain/repositories/tax_rate_repository.dart';
import '../datasources/database_helper.dart';

class TaxRateRepositoryImpl implements TaxRateRepository {
  final DatabaseHelper databaseHelper;

  TaxRateRepositoryImpl(this.databaseHelper);

  @override
  Future<TaxRate> createTaxRate(TaxRate taxRate) async {
    try {
      final taxRateModel = TaxRateModel.fromEntity(taxRate);
      final id = await databaseHelper.insert('tax_rates', taxRateModel.toJson());
      return taxRate.copyWith(id: id);
    } catch (e) {
      throw Exception('Failed to create tax rate: $e');
    }
  }

  @override
  Future<void> deleteTaxRate(int id) async {
    try {
      await databaseHelper.delete('tax_rates', id);
    } catch (e) {
      throw Exception('Failed to delete tax rate: $e');
    }
  }

  @override
  Future<List<TaxRate>> getAllTaxRates() async {
    try {
      final maps = await databaseHelper.queryAll('tax_rates');
      final taxRates = maps.map((map) => TaxRateModel.fromJson(map).toEntity()).toList();
      return taxRates;
    } catch (e) {
      throw Exception('Failed to get all tax rates: $e');
    }
  }

  @override
  Future<TaxRate> getTaxRateById(int id) async {
    try {
      final map = await databaseHelper.queryById('tax_rates', id);
      if (map != null) {
        final taxRate = TaxRateModel.fromJson(map).toEntity();
        return taxRate;
      } else {
        throw Exception('Tax rate not found');
      }
    } catch (e) {
      throw Exception('Failed to get tax rate by id: $e');
    }
  }

  @override
  Future<void> setDefaultTaxRate(int id) async {
    try {
      final db = await databaseHelper.database;
      await db.transaction((txn) async {
        await txn.update('tax_rates', {'is_default': 0});
        await txn.update('tax_rates', {'is_default': 1}, where: 'id = ?', whereArgs: [id]);
      });
    } catch (e) {
      throw Exception('Failed to set default tax rate: $e');
    }
  }

  @override
  Future<TaxRate> updateTaxRate(TaxRate taxRate) async {
    try {
      final taxRateModel = TaxRateModel.fromEntity(taxRate);
      await databaseHelper.update('tax_rates', taxRateModel.toJson());
      return taxRate;
    } catch (e) {
      throw Exception('Failed to update tax rate: $e');
    }
  }
}
