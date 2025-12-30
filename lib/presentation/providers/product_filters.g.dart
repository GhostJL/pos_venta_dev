// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_filters.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProductFilters)
const productFiltersProvider = ProductFiltersProvider._();

final class ProductFiltersProvider
    extends $NotifierProvider<ProductFilters, ProductFilterState> {
  const ProductFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productFiltersHash();

  @$internal
  @override
  ProductFilters create() => ProductFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductFilterState>(value),
    );
  }
}

String _$productFiltersHash() => r'0b550b603cd882d8f84ef7b4383b61503ee35723';

abstract class _$ProductFilters extends $Notifier<ProductFilterState> {
  ProductFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ProductFilterState, ProductFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProductFilterState, ProductFilterState>,
              ProductFilterState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(filteredProducts)
const filteredProductsProvider = FilteredProductsProvider._();

final class FilteredProductsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProductPaginationState>,
          AsyncValue<ProductPaginationState>,
          AsyncValue<ProductPaginationState>
        >
    with $Provider<AsyncValue<ProductPaginationState>> {
  const FilteredProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredProductsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredProductsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<ProductPaginationState>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<ProductPaginationState> create(Ref ref) {
    return filteredProducts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ProductPaginationState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<ProductPaginationState>>(
        value,
      ),
    );
  }
}

String _$filteredProductsHash() => r'5f84321a7b41993e8615fe8607ff642169d636db';
