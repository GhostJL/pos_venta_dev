// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(supplierRepository)
const supplierRepositoryProvider = SupplierRepositoryProvider._();

final class SupplierRepositoryProvider
    extends
        $FunctionalProvider<
          SupplierRepository,
          SupplierRepository,
          SupplierRepository
        >
    with $Provider<SupplierRepository> {
  const SupplierRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supplierRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supplierRepositoryHash();

  @$internal
  @override
  $ProviderElement<SupplierRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SupplierRepository create(Ref ref) {
    return supplierRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupplierRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupplierRepository>(value),
    );
  }
}

String _$supplierRepositoryHash() =>
    r'c806b556b84cf3ea4cbb0b57197b5ce00b70cd6e';

@ProviderFor(getAllSuppliersUseCase)
const getAllSuppliersUseCaseProvider = GetAllSuppliersUseCaseProvider._();

final class GetAllSuppliersUseCaseProvider
    extends
        $FunctionalProvider<GetAllSuppliers, GetAllSuppliers, GetAllSuppliers>
    with $Provider<GetAllSuppliers> {
  const GetAllSuppliersUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAllSuppliersUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAllSuppliersUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetAllSuppliers> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetAllSuppliers create(Ref ref) {
    return getAllSuppliersUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAllSuppliers value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAllSuppliers>(value),
    );
  }
}

String _$getAllSuppliersUseCaseHash() =>
    r'c028edd486ba903004b1360b0c1bbe4a206bb620';

@ProviderFor(createSupplierUseCase)
const createSupplierUseCaseProvider = CreateSupplierUseCaseProvider._();

final class CreateSupplierUseCaseProvider
    extends $FunctionalProvider<CreateSupplier, CreateSupplier, CreateSupplier>
    with $Provider<CreateSupplier> {
  const CreateSupplierUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createSupplierUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createSupplierUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateSupplier> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateSupplier create(Ref ref) {
    return createSupplierUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateSupplier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateSupplier>(value),
    );
  }
}

String _$createSupplierUseCaseHash() =>
    r'7d705ab64872f3f01e4fb31f8f23332a3f2d2182';

@ProviderFor(updateSupplierUseCase)
const updateSupplierUseCaseProvider = UpdateSupplierUseCaseProvider._();

final class UpdateSupplierUseCaseProvider
    extends $FunctionalProvider<UpdateSupplier, UpdateSupplier, UpdateSupplier>
    with $Provider<UpdateSupplier> {
  const UpdateSupplierUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateSupplierUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateSupplierUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateSupplier> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateSupplier create(Ref ref) {
    return updateSupplierUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateSupplier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateSupplier>(value),
    );
  }
}

String _$updateSupplierUseCaseHash() =>
    r'9546f36a61f449d14ba53343d8fa324197d32468';

@ProviderFor(deleteSupplierUseCase)
const deleteSupplierUseCaseProvider = DeleteSupplierUseCaseProvider._();

final class DeleteSupplierUseCaseProvider
    extends $FunctionalProvider<DeleteSupplier, DeleteSupplier, DeleteSupplier>
    with $Provider<DeleteSupplier> {
  const DeleteSupplierUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteSupplierUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteSupplierUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteSupplier> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteSupplier create(Ref ref) {
    return deleteSupplierUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteSupplier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteSupplier>(value),
    );
  }
}

String _$deleteSupplierUseCaseHash() =>
    r'f0433aaa1df23d6945611bc798c08d4a5c4c5a07';

@ProviderFor(SupplierList)
const supplierListProvider = SupplierListProvider._();

final class SupplierListProvider
    extends $AsyncNotifierProvider<SupplierList, List<Supplier>> {
  const SupplierListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supplierListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supplierListHash();

  @$internal
  @override
  SupplierList create() => SupplierList();
}

String _$supplierListHash() => r'd1ac80c182b4eb774dfb27bdd6c24753ea1e4870';

abstract class _$SupplierList extends $AsyncNotifier<List<Supplier>> {
  FutureOr<List<Supplier>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Supplier>>, List<Supplier>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Supplier>>, List<Supplier>>,
              AsyncValue<List<Supplier>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
