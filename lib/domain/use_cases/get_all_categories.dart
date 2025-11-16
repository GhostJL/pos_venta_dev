import 'package:myapp/domain/entities/category.dart';
import 'package:myapp/domain/repositories/category_repository.dart';

class GetAllCategories {
  final CategoryRepository repository;

  GetAllCategories(this.repository);

  Future<List<Category>> call() {
    return repository.getAllCategories();
  }
}
