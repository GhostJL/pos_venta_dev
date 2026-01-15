import 'package:fpdart/fpdart.dart';
import 'package:posventa/core/error/failures.dart';
import 'package:posventa/domain/repositories/product_repository.dart';

class DeleteProduct {
  final ProductRepository repository;

  DeleteProduct(this.repository);

  Future<Either<Failure, void>> call(int id, {required int userId}) {
    return repository.deleteProduct(id, userId: userId);
  }
}
