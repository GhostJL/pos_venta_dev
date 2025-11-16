import 'package:myapp/domain/entities/brand.dart';
import 'package:myapp/domain/repositories/brand_repository.dart';

class CreateBrand {
  final BrandRepository repository;

  CreateBrand(this.repository);

  Future<Brand> call(Brand brand) {
    return repository.createBrand(brand);
  }
}
