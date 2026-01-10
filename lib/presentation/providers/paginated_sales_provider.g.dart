// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_sales_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SaleFilter)
const saleFilterProvider = SaleFilterProvider._();

final class SaleFilterProvider
    extends
        $NotifierProvider<
          SaleFilter,
          ({int? cashierId, DateTime? end, DateTime? start})
        > {
  const SaleFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleFilterHash();

  @$internal
  @override
  SaleFilter create() => SaleFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    ({int? cashierId, DateTime? end, DateTime? start}) value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<
            ({int? cashierId, DateTime? end, DateTime? start})
          >(value),
    );
  }
}

String _$saleFilterHash() => r'bd23fba6d9e5ff05853ddb38a6fef58171e479fb';

abstract class _$SaleFilter
    extends $Notifier<({int? cashierId, DateTime? end, DateTime? start})> {
  ({int? cashierId, DateTime? end, DateTime? start}) build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              ({int? cashierId, DateTime? end, DateTime? start}),
              ({int? cashierId, DateTime? end, DateTime? start})
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({int? cashierId, DateTime? end, DateTime? start}),
                ({int? cashierId, DateTime? end, DateTime? start})
              >,
              ({int? cashierId, DateTime? end, DateTime? start}),
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
    r'bc2dd871e1f44d65285304ab5e3e70bc804f236e';

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
    r'79381e2714a5cb87227b0350069109a348deaf5e';

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
