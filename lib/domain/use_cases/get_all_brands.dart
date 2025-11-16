import 'package:myapp/domain/entities/brand.dart';
import 'package:myapp/domain/repositories/brand_repository.dart';

class GetAllBrands {
  final BrandRepository repository;

  GetAllBrands(this.repository);

  Future<List<Brand>> call() {
    return repository.getAllBrands();
  }
}
