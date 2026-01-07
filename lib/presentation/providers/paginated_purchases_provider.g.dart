// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_purchases_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PurchaseSearchQuery)
const purchaseSearchQueryProvider = PurchaseSearchQueryProvider._();

final class PurchaseSearchQueryProvider
    extends $NotifierProvider<PurchaseSearchQuery, String> {
  const PurchaseSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseSearchQueryHash();

  @$internal
  @override
  PurchaseSearchQuery create() => PurchaseSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$purchaseSearchQueryHash() =>
    r'941b0b33eeb4cc681af6f15353f1a3935b01f70d';

abstract class _$PurchaseSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(paginatedPurchasesCount)
const paginatedPurchasesCountProvider = PaginatedPurchasesCountProvider._();

final class PaginatedPurchasesCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  const PaginatedPurchasesCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedPurchasesCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedPurchasesCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return paginatedPurchasesCount(ref);
  }
}

String _$paginatedPurchasesCountHash() =>
    r'5a2d67c1e97d6092de9a21a8c7906bc3dcd04319';

@ProviderFor(paginatedPurchasesPage)
const paginatedPurchasesPageProvider = PaginatedPurchasesPageFamily._();

final class PaginatedPurchasesPageProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Purchase>>,
          List<Purchase>,
          FutureOr<List<Purchase>>
        >
    with $FutureModifier<List<Purchase>>, $FutureProvider<List<Purchase>> {
  const PaginatedPurchasesPageProvider._({
    required PaginatedPurchasesPageFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'paginatedPurchasesPageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$paginatedPurchasesPageHash();

  @override
  String toString() {
    return r'paginatedPurchasesPageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Purchase>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Purchase>> create(Ref ref) {
    final argument = this.argument as int;
    return paginatedPurchasesPage(ref, pageIndex: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PaginatedPurchasesPageProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$paginatedPurchasesPageHash() =>
    r'62b8e267d23fa5e7117343066896a2a7bfcdadf9';

final class PaginatedPurchasesPageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Purchase>>, int> {
  const PaginatedPurchasesPageFamily._()
    : super(
        retry: null,
        name: r'paginatedPurchasesPageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PaginatedPurchasesPageProvider call({required int pageIndex}) =>
      PaginatedPurchasesPageProvider._(argument: pageIndex, from: this);

  @override
  String toString() => r'paginatedPurchasesPageProvider';
}
