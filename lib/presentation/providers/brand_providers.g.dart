// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(brandRepository)
const brandRepositoryProvider = BrandRepositoryProvider._();

final class BrandRepositoryProvider
    extends
        $FunctionalProvider<BrandRepository, BrandRepository, BrandRepository>
    with $Provider<BrandRepository> {
  const BrandRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brandRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brandRepositoryHash();

  @$internal
  @override
  $ProviderElement<BrandRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BrandRepository create(Ref ref) {
    return brandRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BrandRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BrandRepository>(value),
    );
  }
}

String _$brandRepositoryHash() => r'31f4a9882f91995c5029e22617a2836803fd6e04';

@ProviderFor(getAllBrandsUseCase)
const getAllBrandsUseCaseProvider = GetAllBrandsUseCaseProvider._();

final class GetAllBrandsUseCaseProvider
    extends $FunctionalProvider<GetAllBrands, GetAllBrands, GetAllBrands>
    with $Provider<GetAllBrands> {
  const GetAllBrandsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAllBrandsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAllBrandsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetAllBrands> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetAllBrands create(Ref ref) {
    return getAllBrandsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAllBrands value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAllBrands>(value),
    );
  }
}

String _$getAllBrandsUseCaseHash() =>
    r'343b9b4a5dba9d757b322242a70a14150d8b1a0d';

@ProviderFor(createBrandUseCase)
const createBrandUseCaseProvider = CreateBrandUseCaseProvider._();

final class CreateBrandUseCaseProvider
    extends $FunctionalProvider<CreateBrand, CreateBrand, CreateBrand>
    with $Provider<CreateBrand> {
  const CreateBrandUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createBrandUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createBrandUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateBrand> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateBrand create(Ref ref) {
    return createBrandUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateBrand value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateBrand>(value),
    );
  }
}

String _$createBrandUseCaseHash() =>
    r'7fe663b0f66d05275a8bb95f75ca3855ffd60202';

@ProviderFor(updateBrandUseCase)
const updateBrandUseCaseProvider = UpdateBrandUseCaseProvider._();

final class UpdateBrandUseCaseProvider
    extends $FunctionalProvider<UpdateBrand, UpdateBrand, UpdateBrand>
    with $Provider<UpdateBrand> {
  const UpdateBrandUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateBrandUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateBrandUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateBrand> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateBrand create(Ref ref) {
    return updateBrandUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateBrand value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateBrand>(value),
    );
  }
}

String _$updateBrandUseCaseHash() =>
    r'd13f931fc2cf2cee8e3b9fcc750abc287ed7592e';

@ProviderFor(deleteBrandUseCase)
const deleteBrandUseCaseProvider = DeleteBrandUseCaseProvider._();

final class DeleteBrandUseCaseProvider
    extends $FunctionalProvider<DeleteBrand, DeleteBrand, DeleteBrand>
    with $Provider<DeleteBrand> {
  const DeleteBrandUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteBrandUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteBrandUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteBrand> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteBrand create(Ref ref) {
    return deleteBrandUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteBrand value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteBrand>(value),
    );
  }
}

String _$deleteBrandUseCaseHash() =>
    r'42b65cde5dd072cc5e3edaa287469a10d79c7ce5';

@ProviderFor(BrandList)
const brandListProvider = BrandListProvider._();

final class BrandListProvider
    extends $AsyncNotifierProvider<BrandList, List<Brand>> {
  const BrandListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brandListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brandListHash();

  @$internal
  @override
  BrandList create() => BrandList();
}

String _$brandListHash() => r'872092e5bb92d38fd7e1ca5e3254c7b196440fe8';

abstract class _$BrandList extends $AsyncNotifier<List<Brand>> {
  FutureOr<List<Brand>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Brand>>, List<Brand>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Brand>>, List<Brand>>,
              AsyncValue<List<Brand>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
