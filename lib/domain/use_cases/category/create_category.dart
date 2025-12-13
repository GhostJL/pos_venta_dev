import 'package:posventa/domain/entities/category.dart';
import 'package:posventa/domain/repositories/category_repository.dart';

class CreateCategory {
  final CategoryRepository repository;

  CreateCategory(this.repository);

  Future<int> call(Category category) {
    return repository.createCategory(category);
  }
}
