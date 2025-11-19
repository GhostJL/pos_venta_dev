import 'package:posventa/domain/entities/brand.dart';
import 'package:posventa/domain/repositories/brand_repository.dart';

class UpdateBrand {
  final BrandRepository repository;

  UpdateBrand(this.repository);

  Future<Brand> call(Brand brand) {
    return repository.updateBrand(brand);
  }
}
