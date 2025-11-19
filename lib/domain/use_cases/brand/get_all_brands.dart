import 'package:posventa/domain/entities/brand.dart';
import 'package:posventa/domain/repositories/brand_repository.dart';

class GetAllBrands {
  final BrandRepository repository;

  GetAllBrands(this.repository);

  Future<List<Brand>> call() {
    return repository.getAllBrands();
  }
}
