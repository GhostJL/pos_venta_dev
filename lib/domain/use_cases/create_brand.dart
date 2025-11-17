import 'package:posventa/domain/entities/brand.dart';
import 'package:posventa/domain/repositories/brand_repository.dart';

class CreateBrand {
  final BrandRepository repository;

  CreateBrand(this.repository);

  Future<Brand> call(Brand brand) {
    return repository.createBrand(brand);
  }
}
