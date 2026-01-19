// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(labelService)
const labelServiceProvider = LabelServiceProvider._();

final class LabelServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<LabelService>,
          LabelService,
          FutureOr<LabelService>
        >
    with $FutureModifier<LabelService>, $FutureProvider<LabelService> {
  const LabelServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'labelServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$labelServiceHash();

  @$internal
  @override
  $FutureProviderElement<LabelService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LabelService> create(Ref ref) {
    return labelService(ref);
  }
}

String _$labelServiceHash() => r'3916e6678e3e0d57ca3b48137fc767a9984fe911';

@ProviderFor(productLocalDataSource)
const productLocalDataSourceProvider = ProductLocalDataSourceProvider._();

final class ProductLocalDataSourceProvider
    extends
        $FunctionalProvider<
          ProductLocalDataSource,
          ProductLocalDataSource,
          ProductLocalDataSource
        >
    with $Provider<ProductLocalDataSource> {
  const ProductLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<ProductLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductLocalDataSource create(Ref ref) {
    return productLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductLocalDataSource>(value),
    );
  }
}

String _$productLocalDataSourceHash() =>
    r'97ac3be0c1f29f5b7c8c220f329262552ee7766e';

@ProviderFor(productRepository)
const productRepositoryProvider = ProductRepositoryProvider._();

final class ProductRepositoryProvider
    extends
        $FunctionalProvider<
          ProductRepository,
          ProductRepository,
          ProductRepository
        >
    with $Provider<ProductRepository> {
  const ProductRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProductRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductRepository create(Ref ref) {
    return productRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductRepository>(value),
    );
  }
}

String _$productRepositoryHash() => r'21b6c7863ea37fefbedb0767ae07aecaa8b9ea5d';

@ProviderFor(getAllProducts)
const getAllProductsProvider = GetAllProductsProvider._();

final class GetAllProductsProvider
    extends $FunctionalProvider<GetAllProducts, GetAllProducts, GetAllProducts>
    with $Provider<GetAllProducts> {
  const GetAllProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAllProductsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAllProductsHash();

  @$internal
  @override
  $ProviderElement<GetAllProducts> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetAllProducts create(Ref ref) {
    return getAllProducts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAllProducts value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAllProducts>(value),
    );
  }
}

String _$getAllProductsHash() => r'c3ac952cc908ae400e33b23c535dfe98f4e68d5a';

@ProviderFor(createProduct)
const createProductProvider = CreateProductProvider._();

final class CreateProductProvider
    extends $FunctionalProvider<CreateProduct, CreateProduct, CreateProduct>
    with $Provider<CreateProduct> {
  const CreateProductProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createProductProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createProductHash();

  @$internal
  @override
  $ProviderElement<CreateProduct> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateProduct create(Ref ref) {
    return createProduct(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateProduct value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateProduct>(value),
    );
  }
}

String _$createProductHash() => r'fc7b2830886a8f75cebcde18247df99c52ffebaa';

@ProviderFor(updateProduct)
const updateProductProvider = UpdateProductProvider._();

final class UpdateProductProvider
    extends $FunctionalProvider<UpdateProduct, UpdateProduct, UpdateProduct>
    with $Provider<UpdateProduct> {
  const UpdateProductProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateProductProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateProductHash();

  @$internal
  @override
  $ProviderElement<UpdateProduct> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateProduct create(Ref ref) {
    return updateProduct(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateProduct value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateProduct>(value),
    );
  }
}

String _$updateProductHash() => r'550cf10a8a4919fd361dacc938307517f851497f';

@ProviderFor(deleteProduct)
const deleteProductProvider = DeleteProductProvider._();

final class DeleteProductProvider
    extends $FunctionalProvider<DeleteProduct, DeleteProduct, DeleteProduct>
    with $Provider<DeleteProduct> {
  const DeleteProductProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteProductProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteProductHash();

  @$internal
  @override
  $ProviderElement<DeleteProduct> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteProduct create(Ref ref) {
    return deleteProduct(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteProduct value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteProduct>(value),
    );
  }
}

String _$deleteProductHash() => r'5850111edda5cac19ef54114f99d4d2be5fcd6a4';

@ProviderFor(searchProducts)
const searchProductsProvider = SearchProductsProvider._();

final class SearchProductsProvider
    extends $FunctionalProvider<SearchProducts, SearchProducts, SearchProducts>
    with $Provider<SearchProducts> {
  const SearchProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchProductsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchProductsHash();

  @$internal
  @override
  $ProviderElement<SearchProducts> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SearchProducts create(Ref ref) {
    return searchProducts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchProducts value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchProducts>(value),
    );
  }
}

String _$searchProductsHash() => r'e7a0bddb97037d8060018ebe2cf71717022599bf';

@ProviderFor(unitOfMeasureRepository)
const unitOfMeasureRepositoryProvider = UnitOfMeasureRepositoryProvider._();

final class UnitOfMeasureRepositoryProvider
    extends
        $FunctionalProvider<
          UnitOfMeasureRepository,
          UnitOfMeasureRepository,
          UnitOfMeasureRepository
        >
    with $Provider<UnitOfMeasureRepository> {
  const UnitOfMeasureRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unitOfMeasureRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unitOfMeasureRepositoryHash();

  @$internal
  @override
  $ProviderElement<UnitOfMeasureRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UnitOfMeasureRepository create(Ref ref) {
    return unitOfMeasureRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnitOfMeasureRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnitOfMeasureRepository>(value),
    );
  }
}

String _$unitOfMeasureRepositoryHash() =>
    r'2b166cb70141ae8861d5cf7b38a9537bd13421c8';

@ProviderFor(unitList)
const unitListProvider = UnitListProvider._();

final class UnitListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UnitOfMeasure>>,
          List<UnitOfMeasure>,
          FutureOr<List<UnitOfMeasure>>
        >
    with
        $FutureModifier<List<UnitOfMeasure>>,
        $FutureProvider<List<UnitOfMeasure>> {
  const UnitListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unitListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unitListHash();

  @$internal
  @override
  $FutureProviderElement<List<UnitOfMeasure>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UnitOfMeasure>> create(Ref ref) {
    return unitList(ref);
  }
}

String _$unitListHash() => r'9cdd6ca6c9018e567a7a0a83abb16947514d8b92';

@ProviderFor(taxRateRepository)
const taxRateRepositoryProvider = TaxRateRepositoryProvider._();

final class TaxRateRepositoryProvider
    extends
        $FunctionalProvider<
          TaxRateRepository,
          TaxRateRepository,
          TaxRateRepository
        >
    with $Provider<TaxRateRepository> {
  const TaxRateRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taxRateRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taxRateRepositoryHash();

  @$internal
  @override
  $ProviderElement<TaxRateRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TaxRateRepository create(Ref ref) {
    return taxRateRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaxRateRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaxRateRepository>(value),
    );
  }
}

String _$taxRateRepositoryHash() => r'ef32f8f14569cda7649860d88c9b91a5159db009';

@ProviderFor(getAllTaxRatesUseCase)
const getAllTaxRatesUseCaseProvider = GetAllTaxRatesUseCaseProvider._();

final class GetAllTaxRatesUseCaseProvider
    extends $FunctionalProvider<GetAllTaxRates, GetAllTaxRates, GetAllTaxRates>
    with $Provider<GetAllTaxRates> {
  const GetAllTaxRatesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAllTaxRatesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAllTaxRatesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetAllTaxRates> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetAllTaxRates create(Ref ref) {
    return getAllTaxRatesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAllTaxRates value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAllTaxRates>(value),
    );
  }
}

String _$getAllTaxRatesUseCaseHash() =>
    r'6100e3389d68e15fc52ae8784d6dbd7237e68328';

@ProviderFor(createTaxRate)
const createTaxRateProvider = CreateTaxRateProvider._();

final class CreateTaxRateProvider
    extends $FunctionalProvider<CreateTaxRate, CreateTaxRate, CreateTaxRate>
    with $Provider<CreateTaxRate> {
  const CreateTaxRateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createTaxRateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createTaxRateHash();

  @$internal
  @override
  $ProviderElement<CreateTaxRate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateTaxRate create(Ref ref) {
    return createTaxRate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateTaxRate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateTaxRate>(value),
    );
  }
}

String _$createTaxRateHash() => r'5833e30f9ffa4f5edf9efc8278a59ffa987a6242';

@ProviderFor(updateTaxRate)
const updateTaxRateProvider = UpdateTaxRateProvider._();

final class UpdateTaxRateProvider
    extends $FunctionalProvider<UpdateTaxRate, UpdateTaxRate, UpdateTaxRate>
    with $Provider<UpdateTaxRate> {
  const UpdateTaxRateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateTaxRateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateTaxRateHash();

  @$internal
  @override
  $ProviderElement<UpdateTaxRate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateTaxRate create(Ref ref) {
    return updateTaxRate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateTaxRate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateTaxRate>(value),
    );
  }
}

String _$updateTaxRateHash() => r'6dfb1eee3ebd632b3c10b1d864c56117c38ec7a3';

@ProviderFor(deleteTaxRate)
const deleteTaxRateProvider = DeleteTaxRateProvider._();

final class DeleteTaxRateProvider
    extends $FunctionalProvider<DeleteTaxRate, DeleteTaxRate, DeleteTaxRate>
    with $Provider<DeleteTaxRate> {
  const DeleteTaxRateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteTaxRateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteTaxRateHash();

  @$internal
  @override
  $ProviderElement<DeleteTaxRate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteTaxRate create(Ref ref) {
    return deleteTaxRate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteTaxRate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteTaxRate>(value),
    );
  }
}

String _$deleteTaxRateHash() => r'e54fc26c088da644588925877edc4356bc5b6a37';

@ProviderFor(setDefaultTaxRate)
const setDefaultTaxRateProvider = SetDefaultTaxRateProvider._();

final class SetDefaultTaxRateProvider
    extends
        $FunctionalProvider<
          SetDefaultTaxRate,
          SetDefaultTaxRate,
          SetDefaultTaxRate
        >
    with $Provider<SetDefaultTaxRate> {
  const SetDefaultTaxRateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setDefaultTaxRateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setDefaultTaxRateHash();

  @$internal
  @override
  $ProviderElement<SetDefaultTaxRate> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SetDefaultTaxRate create(Ref ref) {
    return setDefaultTaxRate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetDefaultTaxRate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetDefaultTaxRate>(value),
    );
  }
}

String _$setDefaultTaxRateHash() => r'c2e9cb86da496b946bd1263c27b2f6fb57aff1e8';

@ProviderFor(departmentRepository)
const departmentRepositoryProvider = DepartmentRepositoryProvider._();

final class DepartmentRepositoryProvider
    extends
        $FunctionalProvider<
          DepartmentRepository,
          DepartmentRepository,
          DepartmentRepository
        >
    with $Provider<DepartmentRepository> {
  const DepartmentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'departmentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$departmentRepositoryHash();

  @$internal
  @override
  $ProviderElement<DepartmentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DepartmentRepository create(Ref ref) {
    return departmentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DepartmentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DepartmentRepository>(value),
    );
  }
}

String _$departmentRepositoryHash() =>
    r'848c65d7f1983fe421333aaee8d30f0ccf6717b7';

@ProviderFor(getAllDepartmentsUseCase)
const getAllDepartmentsUseCaseProvider = GetAllDepartmentsUseCaseProvider._();

final class GetAllDepartmentsUseCaseProvider
    extends
        $FunctionalProvider<
          GetAllDepartments,
          GetAllDepartments,
          GetAllDepartments
        >
    with $Provider<GetAllDepartments> {
  const GetAllDepartmentsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAllDepartmentsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAllDepartmentsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetAllDepartments> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetAllDepartments create(Ref ref) {
    return getAllDepartmentsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAllDepartments value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAllDepartments>(value),
    );
  }
}

String _$getAllDepartmentsUseCaseHash() =>
    r'4163d3e0f5ae24121101c9a670a9fc7aa4a526d6';

@ProviderFor(createDepartmentUseCase)
const createDepartmentUseCaseProvider = CreateDepartmentUseCaseProvider._();

final class CreateDepartmentUseCaseProvider
    extends
        $FunctionalProvider<
          CreateDepartment,
          CreateDepartment,
          CreateDepartment
        >
    with $Provider<CreateDepartment> {
  const CreateDepartmentUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createDepartmentUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createDepartmentUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateDepartment> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateDepartment create(Ref ref) {
    return createDepartmentUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateDepartment value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateDepartment>(value),
    );
  }
}

String _$createDepartmentUseCaseHash() =>
    r'be7772cdf31a24a6e35e5eda0679335b8a9bb24d';

@ProviderFor(updateDepartmentUseCase)
const updateDepartmentUseCaseProvider = UpdateDepartmentUseCaseProvider._();

final class UpdateDepartmentUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateDepartment,
          UpdateDepartment,
          UpdateDepartment
        >
    with $Provider<UpdateDepartment> {
  const UpdateDepartmentUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateDepartmentUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateDepartmentUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateDepartment> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateDepartment create(Ref ref) {
    return updateDepartmentUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateDepartment value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateDepartment>(value),
    );
  }
}

String _$updateDepartmentUseCaseHash() =>
    r'246a31caa66429d6b66a05a44301e6f76e09a475';

@ProviderFor(deleteDepartmentUseCase)
const deleteDepartmentUseCaseProvider = DeleteDepartmentUseCaseProvider._();

final class DeleteDepartmentUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteDepartment,
          DeleteDepartment,
          DeleteDepartment
        >
    with $Provider<DeleteDepartment> {
  const DeleteDepartmentUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteDepartmentUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteDepartmentUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteDepartment> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteDepartment create(Ref ref) {
    return deleteDepartmentUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteDepartment value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteDepartment>(value),
    );
  }
}

String _$deleteDepartmentUseCaseHash() =>
    r'e719891e6061d0a2bd02abf0282c476baea32ca5';

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
    r'210b2401e114ed8cf42a618156444e121ea8770b';

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
    r'aaf0e7914750c6e97d9cb57cd7b354bf88bb620d';

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
    r'fa594d13698e3aff16b814ad79d39ed12e78c87e';

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
    r'90d6f17d3839fb803c2c73d4197269c92f2e2cbe';

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
    r'4891f945eb0a19af83d8a3e9941f76f334c57bb4';
