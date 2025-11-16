import 'package:myapp/domain/entities/brand.dart';

abstract class BrandRepository {
  Future<List<Brand>> getAllBrands();
  Future<Brand> createBrand(Brand brand);
  Future<Brand> updateBrand(Brand brand);
  Future<void> deleteBrand(int brandId);
}
