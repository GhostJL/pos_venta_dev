import 'package:fpdart/fpdart.dart';
import 'package:posventa/core/error/failures.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/repositories/product_repository.dart';

class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<Either<Failure, void>> call(Product product, {required int userId}) {
    return repository.updateProduct(product, userId: userId);
  }
}
