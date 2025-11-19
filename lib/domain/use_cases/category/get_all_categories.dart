import 'package:posventa/domain/entities/category.dart';
import 'package:posventa/domain/repositories/category_repository.dart';

class GetAllCategories {
  final CategoryRepository repository;

  GetAllCategories(this.repository);

  Future<List<Category>> call() {
    return repository.getAllCategories();
  }
}
