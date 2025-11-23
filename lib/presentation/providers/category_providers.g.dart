// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(categoryRepository)
const categoryRepositoryProvider = CategoryRepositoryProvider._();

final class CategoryRepositoryProvider
    extends
        $FunctionalProvider<
          CategoryRepository,
          CategoryRepository,
          CategoryRepository
        >
    with $Provider<CategoryRepository> {
  const CategoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CategoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoryRepository create(Ref ref) {
    return categoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryRepository>(value),
    );
  }
}

String _$categoryRepositoryHash() =>
    r'bc939ee7e3bf3705e86fd5613543606bcd1247ec';

@ProviderFor(getAllCategoriesUseCase)
const getAllCategoriesUseCaseProvider = GetAllCategoriesUseCaseProvider._();

final class GetAllCategoriesUseCaseProvider
    extends
        $FunctionalProvider<
          GetAllCategories,
          GetAllCategories,
          GetAllCategories
        >
    with $Provider<GetAllCategories> {
  const GetAllCategoriesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAllCategoriesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAllCategoriesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetAllCategories> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetAllCategories create(Ref ref) {
    return getAllCategoriesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAllCategories value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAllCategories>(value),
    );
  }
}

String _$getAllCategoriesUseCaseHash() =>
    r'a213d4efd4d428822d7b4298c918defdbeffa330';

@ProviderFor(createCategoryUseCase)
const createCategoryUseCaseProvider = CreateCategoryUseCaseProvider._();

final class CreateCategoryUseCaseProvider
    extends $FunctionalProvider<CreateCategory, CreateCategory, CreateCategory>
    with $Provider<CreateCategory> {
  const CreateCategoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createCategoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createCategoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateCategory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateCategory create(Ref ref) {
    return createCategoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateCategory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateCategory>(value),
    );
  }
}

String _$createCategoryUseCaseHash() =>
    r'6013f15b039317131d4bf430e7d8ab7106e6fd19';

@ProviderFor(updateCategoryUseCase)
const updateCategoryUseCaseProvider = UpdateCategoryUseCaseProvider._();

final class UpdateCategoryUseCaseProvider
    extends $FunctionalProvider<UpdateCategory, UpdateCategory, UpdateCategory>
    with $Provider<UpdateCategory> {
  const UpdateCategoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateCategoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateCategoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateCategory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateCategory create(Ref ref) {
    return updateCategoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateCategory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateCategory>(value),
    );
  }
}

String _$updateCategoryUseCaseHash() =>
    r'4a52ae307e704917e0793a8544b0cf090dbc82f1';

@ProviderFor(deleteCategoryUseCase)
const deleteCategoryUseCaseProvider = DeleteCategoryUseCaseProvider._();

final class DeleteCategoryUseCaseProvider
    extends $FunctionalProvider<DeleteCategory, DeleteCategory, DeleteCategory>
    with $Provider<DeleteCategory> {
  const DeleteCategoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteCategoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteCategoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteCategory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteCategory create(Ref ref) {
    return deleteCategoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteCategory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteCategory>(value),
    );
  }
}

String _$deleteCategoryUseCaseHash() =>
    r'5efff475b5083f22fbfb0dd20657c8f04d77a602';

@ProviderFor(CategoryList)
const categoryListProvider = CategoryListProvider._();

final class CategoryListProvider
    extends $AsyncNotifierProvider<CategoryList, List<Category>> {
  const CategoryListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryListHash();

  @$internal
  @override
  CategoryList create() => CategoryList();
}

String _$categoryListHash() => r'da76f8544681439e2bfa2f0e522579fa6ed8a9ca';

abstract class _$CategoryList extends $AsyncNotifier<List<Category>> {
  FutureOr<List<Category>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Category>>, List<Category>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Category>>, List<Category>>,
              AsyncValue<List<Category>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
