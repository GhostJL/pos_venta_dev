import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/repositories/product_repository.dart';

class CreateProduct {
  final ProductRepository repository;

  CreateProduct(this.repository);

  Future<int> call(Product product) {
    return repository.createProduct(product);
  }
}
