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
        isAutoDispose: true,
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
    r'0f80a0471e875fca86c4d5831e88ce80c92d6670';

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
    r'34237fa79a80e0c976ed0a0e157e0054dad2d668';

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
