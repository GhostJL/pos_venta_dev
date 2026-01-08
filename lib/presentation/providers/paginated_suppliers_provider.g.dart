// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_suppliers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SupplierSearchQuery)
const supplierSearchQueryProvider = SupplierSearchQueryProvider._();

final class SupplierSearchQueryProvider
    extends $NotifierProvider<SupplierSearchQuery, String> {
  const SupplierSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supplierSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supplierSearchQueryHash();

  @$internal
  @override
  SupplierSearchQuery create() => SupplierSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$supplierSearchQueryHash() =>
    r'75fa7df0f0879d37c71d7b49a3df46f187e56ff7';

abstract class _$SupplierSearchQuery extends $Notifier<String> {
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

@ProviderFor(SupplierShowInactive)
const supplierShowInactiveProvider = SupplierShowInactiveProvider._();

final class SupplierShowInactiveProvider
    extends $NotifierProvider<SupplierShowInactive, bool> {
  const SupplierShowInactiveProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supplierShowInactiveProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supplierShowInactiveHash();

  @$internal
  @override
  SupplierShowInactive create() => SupplierShowInactive();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$supplierShowInactiveHash() =>
    r'f226952f5e4a342682591cf4671e99423a33dc77';

abstract class _$SupplierShowInactive extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(paginatedSuppliersCount)
const paginatedSuppliersCountProvider = PaginatedSuppliersCountProvider._();

final class PaginatedSuppliersCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  const PaginatedSuppliersCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedSuppliersCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedSuppliersCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return paginatedSuppliersCount(ref);
  }
}

String _$paginatedSuppliersCountHash() =>
    r'45ea2e7db8efb8acae818ff4d61f4bfd424a8a10';

@ProviderFor(paginatedSuppliersPage)
const paginatedSuppliersPageProvider = PaginatedSuppliersPageFamily._();

final class PaginatedSuppliersPageProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Supplier>>,
          List<Supplier>,
          FutureOr<List<Supplier>>
        >
    with $FutureModifier<List<Supplier>>, $FutureProvider<List<Supplier>> {
  const PaginatedSuppliersPageProvider._({
    required PaginatedSuppliersPageFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'paginatedSuppliersPageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$paginatedSuppliersPageHash();

  @override
  String toString() {
    return r'paginatedSuppliersPageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Supplier>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Supplier>> create(Ref ref) {
    final argument = this.argument as int;
    return paginatedSuppliersPage(ref, pageIndex: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PaginatedSuppliersPageProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$paginatedSuppliersPageHash() =>
    r'9b820c11bc6ddc904d93886292de4d4fb8b4a3ef';

final class PaginatedSuppliersPageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Supplier>>, int> {
  const PaginatedSuppliersPageFamily._()
    : super(
        retry: null,
        name: r'paginatedSuppliersPageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PaginatedSuppliersPageProvider call({required int pageIndex}) =>
      PaginatedSuppliersPageProvider._(argument: pageIndex, from: this);

  @override
  String toString() => r'paginatedSuppliersPageProvider';
}
