import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/data/models/category_model.dart';
import 'package:myapp/domain/entities/category.dart';
import 'package:myapp/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final DatabaseHelper _databaseHelper;

  CategoryRepositoryImpl(this._databaseHelper);

  @override
  Future<void> createCategory(Category category) async {
    final db = await _databaseHelper.database;
    final categoryModel = CategoryModel(
      name: category.name,
      code: category.code,
      departmentId: category.departmentId,
      parentCategoryId: category.parentCategoryId,
      description: category.description,
      displayOrder: category.displayOrder,
      isActive: category.isActive,
    );
    await db.insert('categories', categoryModel.toMap());
  }

  @override
  Future<Category?> getCategoryById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return CategoryModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<Category>> getAllCategories() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('categories', orderBy: 'name ASC');
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<void> updateCategory(Category category) async {
    final db = await _databaseHelper.database;
    final categoryModel = CategoryModel(
      id: category.id,
      name: category.name,
      code: category.code,
      departmentId: category.departmentId,
      parentCategoryId: category.parentCategoryId,
      description: category.description,
      displayOrder: category.displayOrder,
      isActive: category.isActive,
    );
    await db.update(
      'categories',
      categoryModel.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  @override
  Future<void> deleteCategory(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
