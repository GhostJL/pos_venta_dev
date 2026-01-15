import 'package:fpdart/fpdart.dart';
import 'package:posventa/core/error/failures.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/repositories/product_repository.dart';

class CreateProduct {
  final ProductRepository repository;

  CreateProduct(this.repository);

  Future<Either<Failure, int>> call(Product product, {required int userId}) {
    return repository.createProduct(product, userId: userId);
  }
}
