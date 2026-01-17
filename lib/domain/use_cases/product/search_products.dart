import 'package:fpdart/fpdart.dart';
import 'package:posventa/core/error/failures.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/repositories/product_repository.dart';

class SearchProducts {
  final ProductRepository repository;

  SearchProducts(this.repository);

  Future<Either<Failure, List<Product>>> call(
    String query, {
    int? limit,
    int? offset,
    String? sortOrder,
    bool onlyWithStock = false,
    List<int>? ids,
  }) {
    return repository.getProducts(
      query: query,
      limit: limit,
      offset: offset,
      sortOrder: sortOrder,
      onlyWithStock: onlyWithStock,
      ids: ids,
    );
  }
}
