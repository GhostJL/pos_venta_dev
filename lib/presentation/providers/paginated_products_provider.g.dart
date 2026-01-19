// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_products_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(paginatedProductsCount)
const paginatedProductsCountProvider = PaginatedProductsCountProvider._();

final class PaginatedProductsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  const PaginatedProductsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedProductsCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedProductsCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return paginatedProductsCount(ref);
  }
}

String _$paginatedProductsCountHash() =>
    r'27fcd16947aed7e0632065b92e2a587abbd079b9';

@ProviderFor(paginatedProductsPage)
const paginatedProductsPageProvider = PaginatedProductsPageFamily._();

final class PaginatedProductsPageProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Product>>,
          List<Product>,
          FutureOr<List<Product>>
        >
    with $FutureModifier<List<Product>>, $FutureProvider<List<Product>> {
  const PaginatedProductsPageProvider._({
    required PaginatedProductsPageFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'paginatedProductsPageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$paginatedProductsPageHash();

  @override
  String toString() {
    return r'paginatedProductsPageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Product>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Product>> create(Ref ref) {
    final argument = this.argument as int;
    return paginatedProductsPage(ref, pageIndex: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PaginatedProductsPageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$paginatedProductsPageHash() =>
    r'3d5767b028b7b9bb9bb10461abea93380203b3f6';

final class PaginatedProductsPageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Product>>, int> {
  const PaginatedProductsPageFamily._()
    : super(
        retry: null,
        name: r'paginatedProductsPageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PaginatedProductsPageProvider call({required int pageIndex}) =>
      PaginatedProductsPageProvider._(argument: pageIndex, from: this);

  @override
  String toString() => r'paginatedProductsPageProvider';
}
