import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/data/models/category_model.dart';
import 'package:posventa/domain/entities/category.dart';
import 'package:posventa/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final drift_db.AppDatabase db;

  CategoryRepositoryImpl(this.db);

  @override
  Future<int> createCategory(Category category) async {
    return await db
        .into(db.categories)
        .insert(
          drift_db.CategoriesCompanion.insert(
            name: category.name,
            code: category.code,
            departmentId: category.departmentId,
            parentCategoryId: Value(category.parentCategoryId),
            description: Value(category.description),
            displayOrder: Value(category.displayOrder),
            isActive: Value(category.isActive),
          ),
        );
  }

  @override
  Future<Category?> getCategoryById(int id) async {
    final row = await (db.select(
      db.categories,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row != null) {
      return CategoryModel(
        id: row.id,
        name: row.name,
        code: row.code,
        departmentId: row.departmentId,
        parentCategoryId: row.parentCategoryId,
        description: row.description,
        displayOrder: row.displayOrder,
        isActive: row.isActive,
      );
    }
    return null;
  }

  @override
  Future<List<Category>> getAllCategories() async {
    final rows = await (db.select(
      db.categories,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
    return rows
        .map(
          (row) => CategoryModel(
            id: row.id,
            name: row.name,
            code: row.code,
            departmentId: row.departmentId,
            parentCategoryId: row.parentCategoryId,
            description: row.description,
            displayOrder: row.displayOrder,
            isActive: row.isActive,
          ),
        )
        .toList();
  }

  @override
  Future<void> updateCategory(Category category) async {
    await (db.update(
      db.categories,
    )..where((t) => t.id.equals(category.id!))).write(
      drift_db.CategoriesCompanion(
        name: Value(category.name),
        code: Value(category.code),
        departmentId: Value(category.departmentId),
        parentCategoryId: Value(category.parentCategoryId),
        description: Value(category.description),
        displayOrder: Value(category.displayOrder),
        isActive: Value(category.isActive),
      ),
    );
  }

  @override
  Future<void> deleteCategory(int id) async {
    await (db.delete(db.categories)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<bool> isCodeUnique(String code, {int? excludeId}) async {
    final q = db.select(db.categories)..where((t) => t.code.equals(code));
    if (excludeId != null) {
      q.where((t) => t.id.equals(excludeId).not());
    }
    final res = await q.get();
    return res.isEmpty;
  }
}
