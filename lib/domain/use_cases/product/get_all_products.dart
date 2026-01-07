import 'package:fpdart/fpdart.dart';
import 'package:posventa/core/error/failures.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/repositories/product_repository.dart';

class GetAllProducts {
  final ProductRepository repository;

  GetAllProducts(this.repository);

  Future<Either<Failure, List<Product>>> call({int? limit, int? offset}) {
    return repository.getProducts(limit: limit, offset: offset);
  }
}
