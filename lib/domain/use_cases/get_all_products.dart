import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/repositories/product_repository.dart';

class GetAllProducts {
  final ProductRepository repository;

  GetAllProducts(this.repository);

  Future<List<Product>> call() {
    return repository.getAllProducts();
  }
}
