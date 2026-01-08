import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/data/models/tax_rate_model.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/domain/repositories/tax_rate_repository.dart';

class TaxRateRepositoryImpl implements TaxRateRepository {
  final drift_db.AppDatabase db;

  TaxRateRepositoryImpl(this.db);

  @override
  Future<TaxRate> createTaxRate(TaxRate taxRate) async {
    try {
      final id = await db
          .into(db.taxRates)
          .insert(
            drift_db.TaxRatesCompanion.insert(
              name: taxRate.name,
              code: taxRate.code,
              rate: taxRate.rate,
              isDefault: Value(taxRate.isDefault),
              isActive: Value(taxRate.isActive),
              isEditable: Value(taxRate.isEditable),
              isOptional: Value(taxRate.isOptional),
            ),
          );
      return taxRate.copyWith(id: id);
    } catch (e) {
      throw Exception('Failed to create tax rate: $e');
    }
  }

  @override
  Future<void> deleteTaxRate(int id) async {
    try {
      await (db.delete(db.taxRates)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw Exception('Failed to delete tax rate: $e');
    }
  }

  @override
  Future<List<TaxRate>> getAllTaxRates() async {
    try {
      final rows = await db.select(db.taxRates).get();
      return rows
          .map(
            (row) => TaxRateModel(
              id: row.id,
              name: row.name,
              code: row.code,
              rate: row.rate,
              isDefault: row.isDefault,
              isActive: row.isActive,
              isEditable: row.isEditable,
              isOptional: row.isOptional,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get all tax rates: $e');
    }
  }

  @override
  Future<TaxRate> getTaxRateById(int id) async {
    try {
      final row = await (db.select(
        db.taxRates,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row != null) {
        return TaxRateModel(
          id: row.id,
          name: row.name,
          code: row.code,
          rate: row.rate,
          isDefault: row.isDefault,
          isActive: row.isActive,
          isEditable: row.isEditable,
          isOptional: row.isOptional,
        );
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
      await db.transaction(() async {
        await db
            .update(db.taxRates)
            .write(const drift_db.TaxRatesCompanion(isDefault: Value(false)));
        await (db.update(db.taxRates)..where((t) => t.id.equals(id))).write(
          const drift_db.TaxRatesCompanion(isDefault: Value(true)),
        );
      });
    } catch (e) {
      throw Exception('Failed to set default tax rate: $e');
    }
  }

  @override
  Future<TaxRate> updateTaxRate(TaxRate taxRate) async {
    try {
      await (db.update(
        db.taxRates,
      )..where((t) => t.id.equals(taxRate.id!))).write(
        drift_db.TaxRatesCompanion(
          name: Value(taxRate.name),
          code: Value(taxRate.code),
          rate: Value(taxRate.rate),
          isDefault: Value(taxRate.isDefault),
          isActive: Value(taxRate.isActive),
          isEditable: Value(taxRate.isEditable),
          isOptional: Value(taxRate.isOptional),
        ),
      );
      return taxRate;
    } catch (e) {
      throw Exception('Failed to update tax rate: $e');
    }
  }
}
