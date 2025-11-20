import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/repositories/product_repository.dart';

class SearchProducts {
  final ProductRepository repository;

  SearchProducts(this.repository);

  Future<List<Product>> call(String query) {
    return repository.searchProducts(query);
  }
}
