import 'package:myapp/domain/entities/category.dart';
import 'package:myapp/domain/repositories/category_repository.dart';

class CreateCategory {
  final CategoryRepository repository;

  CreateCategory(this.repository);

  Future<void> call(Category category) {
    return repository.createCategory(category);
  }
}
