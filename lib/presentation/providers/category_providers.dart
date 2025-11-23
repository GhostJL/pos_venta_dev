import 'package:posventa/domain/entities/category.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/repositories/category_repository.dart';
import 'package:posventa/data/repositories/category_repository_impl.dart';
import 'package:posventa/domain/use_cases/category/create_category.dart';
import 'package:posventa/domain/use_cases/category/delete_category.dart';
import 'package:posventa/domain/use_cases/category/get_all_categories.dart';
import 'package:posventa/domain/use_cases/category/update_category.dart';

part 'category_providers.g.dart';

@riverpod
CategoryRepository categoryRepository(ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return CategoryRepositoryImpl(dbHelper);
}

@riverpod
GetAllCategories getAllCategoriesUseCase(ref) {
  return GetAllCategories(ref.watch(categoryRepositoryProvider));
}

@riverpod
CreateCategory createCategoryUseCase(ref) {
  return CreateCategory(ref.watch(categoryRepositoryProvider));
}

@riverpod
UpdateCategory updateCategoryUseCase(ref) {
  return UpdateCategory(ref.watch(categoryRepositoryProvider));
}

@riverpod
DeleteCategory deleteCategoryUseCase(ref) {
  return DeleteCategory(ref.watch(categoryRepositoryProvider));
}

@riverpod
class CategoryList extends _$CategoryList {
  @override
  Future<List<Category>> build() async {
    final getAllCategories = ref.watch(getAllCategoriesUseCaseProvider);
    return getAllCategories();
  }

  Future<void> addCategory(Category category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(createCategoryUseCaseProvider).call(category);
      return ref.read(getAllCategoriesUseCaseProvider).call();
    });
  }

  Future<void> updateCategory(Category category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateCategoryUseCaseProvider).call(category);
      return ref.read(getAllCategoriesUseCaseProvider).call();
    });
  }

  Future<void> deleteCategory(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteCategoryUseCaseProvider).call(id);
      return ref.read(getAllCategoriesUseCaseProvider).call();
    });
  }
}
