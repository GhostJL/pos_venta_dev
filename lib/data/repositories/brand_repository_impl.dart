import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/data/models/brand_model.dart';
import 'package:myapp/domain/entities/brand.dart';
import 'package:myapp/domain/repositories/brand_repository.dart';

class BrandRepositoryImpl implements BrandRepository {
  final DatabaseHelper dbHelper;

  BrandRepositoryImpl(this.dbHelper);

  @override
  Future<List<Brand>> getAllBrands() async {
    final db = await dbHelper.database;
    final maps = await db.query('brands');
    return maps.map((map) => BrandModel.fromMap(map)).toList();
  }

  @override
  Future<Brand> createBrand(Brand brand) async {
    final db = await dbHelper.database;
    final model = BrandModel(name: brand.name, code: brand.code, isActive: brand.isActive);
    final id = await db.insert('brands', model.toMap());
    return brand.copyWith(id: id);
  }

  @override
  Future<Brand> updateBrand(Brand brand) async {
    final db = await dbHelper.database;
    final model = BrandModel(
      id: brand.id,
      name: brand.name,
      code: brand.code,
      isActive: brand.isActive,
    );
    await db.update(
      'brands',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [brand.id],
    );
    return brand;
  }

  @override
  Future<void> deleteBrand(int brandId) async {
    final db = await dbHelper.database;
    await db.delete(
      'brands',
      where: 'id = ?',
      whereArgs: [brandId],
    );
  }
}
