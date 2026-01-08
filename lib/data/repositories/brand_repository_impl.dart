import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/data/models/brand_model.dart';
import 'package:posventa/domain/entities/brand.dart';
import 'package:posventa/domain/repositories/brand_repository.dart';

class BrandRepositoryImpl implements BrandRepository {
  final drift_db.AppDatabase db;

  BrandRepositoryImpl(this.db);

  @override
  Future<List<Brand>> getAllBrands() async {
    final rows = await db.select(db.brands).get();
    return rows
        .map(
          (row) => BrandModel(
            id: row.id,
            name: row.name,
            code: row.code,
            isActive: row.isActive,
          ),
        )
        .toList();
  }

  @override
  Future<Brand> createBrand(Brand brand) async {
    final id = await db
        .into(db.brands)
        .insert(
          drift_db.BrandsCompanion.insert(
            name: brand.name,
            code: brand.code,
            isActive: Value(brand.isActive),
          ),
        );
    return brand.copyWith(id: id);
  }

  @override
  Future<Brand> updateBrand(Brand brand) async {
    await (db.update(db.brands)..where((t) => t.id.equals(brand.id!))).write(
      drift_db.BrandsCompanion(
        name: Value(brand.name),
        code: Value(brand.code),
        isActive: Value(brand.isActive),
      ),
    );
    return brand;
  }

  @override
  Future<void> deleteBrand(int brandId) async {
    await (db.delete(db.brands)..where((t) => t.id.equals(brandId))).go();
  }
}
