import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:posventa/data/repositories/category_repository_impl.dart';
import 'package:posventa/domain/entities/category.dart';
import 'package:posventa/domain/repositories/category_repository.dart';
import 'package:posventa/domain/use_cases/create_category.dart';
import 'package:posventa/domain/use_cases/delete_category.dart';
import 'package:posventa/domain/use_cases/get_all_categories.dart';
import 'package:posventa/domain/use_cases/update_category.dart';
import 'package:posventa/presentation/providers/department_providers.dart';

// Provider for the Repository
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return CategoryRepositoryImpl(dbHelper);
});

// Use Case Providers
final getAllCategoriesUseCaseProvider = Provider(
  (ref) => GetAllCategories(ref.watch(categoryRepositoryProvider)),
);
final createCategoryUseCaseProvider = Provider(
  (ref) => CreateCategory(ref.watch(categoryRepositoryProvider)),
);
final updateCategoryUseCaseProvider = Provider(
  (ref) => UpdateCategory(ref.watch(categoryRepositoryProvider)),
);
final deleteCategoryUseCaseProvider = Provider(
  (ref) => DeleteCategory(ref.watch(categoryRepositoryProvider)),
);

// StateNotifier for the category list
class CategoryListNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final GetAllCategories _getAllCategories;
  final CreateCategory _createCategory;
  final UpdateCategory _updateCategory;
  final DeleteCategory _deleteCategory;

  CategoryListNotifier(
    this._getAllCategories,
    this._createCategory,
    this._updateCategory,
    this._deleteCategory,
  ) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _getAllCategories();
      state = AsyncValue.data(categories);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await _createCategory(category);
    } finally {
      await loadCategories();
    }
  }

  Future<void> updateCategory(Category category) async {
    final previousState = state;
    if (state is AsyncData<List<Category>>) {
      final currentCategories = state.value!;
      final updatedList = [
        for (final cat in currentCategories)
          if (cat.id == category.id) category else cat,
      ];
      state = AsyncValue.data(updatedList);
    }

    try {
      await _updateCategory(category);
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _deleteCategory(id);
    } finally {
      await loadCategories();
    }
  }
}

// The final provider for the notifier
final categoryListProvider =
    StateNotifierProvider<CategoryListNotifier, AsyncValue<List<Category>>>((
      ref,
    ) {
      return CategoryListNotifier(
        ref.watch(getAllCategoriesUseCaseProvider),
        ref.watch(createCategoryUseCaseProvider),
        ref.watch(updateCategoryUseCaseProvider),
        ref.watch(deleteCategoryUseCaseProvider),
      );
    });
