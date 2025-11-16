import 'package:myapp/domain/repositories/brand_repository.dart';

class DeleteBrand {
  final BrandRepository repository;

  DeleteBrand(this.repository);

  Future<void> call(int brandId) {
    return repository.deleteBrand(brandId);
  }
}
