import 'package:posventa/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<void> createCategory(Category category);
  Future<Category?> getCategoryById(int id);
  Future<List<Category>> getAllCategories();
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(int id);
}
