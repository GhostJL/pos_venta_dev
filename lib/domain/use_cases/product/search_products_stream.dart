import 'package:fpdart/fpdart.dart';
import 'package:posventa/core/error/failures.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/repositories/product_repository.dart';

class SearchProductsStream {
  final ProductRepository repository;

  SearchProductsStream(this.repository);

  Stream<Either<Failure, List<Product>>> call(String query) {
    return repository.searchProductsStream(query);
  }
}
