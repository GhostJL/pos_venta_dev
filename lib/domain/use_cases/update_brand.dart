import 'package:myapp/domain/entities/brand.dart';
import 'package:myapp/domain/repositories/brand_repository.dart';

class UpdateBrand {
  final BrandRepository repository;

  UpdateBrand(this.repository);

  Future<Brand> call(Brand brand) {
    return repository.updateBrand(brand);
  }
}
