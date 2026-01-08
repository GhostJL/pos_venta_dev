// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_sales_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SaleDateRange)
const saleDateRangeProvider = SaleDateRangeProvider._();

final class SaleDateRangeProvider
    extends
        $NotifierProvider<SaleDateRange, ({DateTime? end, DateTime? start})> {
  const SaleDateRangeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleDateRangeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleDateRangeHash();

  @$internal
  @override
  SaleDateRange create() => SaleDateRange();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(({DateTime? end, DateTime? start}) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<({DateTime? end, DateTime? start})>(
        value,
      ),
    );
  }
}

String _$saleDateRangeHash() => r'8e817be72c4a61b8592eb5355539536d455ea03c';

abstract class _$SaleDateRange
    extends $Notifier<({DateTime? end, DateTime? start})> {
  ({DateTime? end, DateTime? start}) build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              ({DateTime? end, DateTime? start}),
              ({DateTime? end, DateTime? start})
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({DateTime? end, DateTime? start}),
                ({DateTime? end, DateTime? start})
              >,
              ({DateTime? end, DateTime? start}),
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(paginatedSalesCount)
const paginatedSalesCountProvider = PaginatedSalesCountProvider._();

final class PaginatedSalesCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  const PaginatedSalesCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedSalesCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedSalesCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return paginatedSalesCount(ref);
  }
}

String _$paginatedSalesCountHash() =>
    r'd538409a29adb1fd6333f40cbdb304cd24036626';

@ProviderFor(paginatedSalesPage)
const paginatedSalesPageProvider = PaginatedSalesPageFamily._();

final class PaginatedSalesPageProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Sale>>,
          List<Sale>,
          FutureOr<List<Sale>>
        >
    with $FutureModifier<List<Sale>>, $FutureProvider<List<Sale>> {
  const PaginatedSalesPageProvider._({
    required PaginatedSalesPageFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'paginatedSalesPageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$paginatedSalesPageHash();

  @override
  String toString() {
    return r'paginatedSalesPageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Sale>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Sale>> create(Ref ref) {
    final argument = this.argument as int;
    return paginatedSalesPage(ref, pageIndex: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PaginatedSalesPageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$paginatedSalesPageHash() =>
    r'48b1dd9713e7fc065bc72264b61cf539f1846f44';

final class PaginatedSalesPageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Sale>>, int> {
  const PaginatedSalesPageFamily._()
    : super(
        retry: null,
        name: r'paginatedSalesPageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PaginatedSalesPageProvider call({required int pageIndex}) =>
      PaginatedSalesPageProvider._(argument: pageIndex, from: this);

  @override
  String toString() => r'paginatedSalesPageProvider';
}
