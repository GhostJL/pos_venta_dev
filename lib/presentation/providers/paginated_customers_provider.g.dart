// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_customers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CustomerSearchQuery)
const customerSearchQueryProvider = CustomerSearchQueryProvider._();

final class CustomerSearchQueryProvider
    extends $NotifierProvider<CustomerSearchQuery, String> {
  const CustomerSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customerSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customerSearchQueryHash();

  @$internal
  @override
  CustomerSearchQuery create() => CustomerSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$customerSearchQueryHash() =>
    r'01fc9d7e854b50ba948ec50cece20004946e3f03';

abstract class _$CustomerSearchQuery extends $Notifier<String> {
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

@ProviderFor(CustomerShowInactive)
const customerShowInactiveProvider = CustomerShowInactiveProvider._();

final class CustomerShowInactiveProvider
    extends $NotifierProvider<CustomerShowInactive, bool> {
  const CustomerShowInactiveProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customerShowInactiveProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customerShowInactiveHash();

  @$internal
  @override
  CustomerShowInactive create() => CustomerShowInactive();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$customerShowInactiveHash() =>
    r'9f836b8fee92ef2a425904207dc6e27b1dfeed8a';

abstract class _$CustomerShowInactive extends $Notifier<bool> {
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

@ProviderFor(paginatedCustomersCount)
const paginatedCustomersCountProvider = PaginatedCustomersCountProvider._();

final class PaginatedCustomersCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  const PaginatedCustomersCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paginatedCustomersCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paginatedCustomersCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return paginatedCustomersCount(ref);
  }
}

String _$paginatedCustomersCountHash() =>
    r'06f674027eaf2459930b82bbebb1efd8c9276b4b';

@ProviderFor(paginatedCustomersPage)
const paginatedCustomersPageProvider = PaginatedCustomersPageFamily._();

final class PaginatedCustomersPageProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Customer>>,
          List<Customer>,
          FutureOr<List<Customer>>
        >
    with $FutureModifier<List<Customer>>, $FutureProvider<List<Customer>> {
  const PaginatedCustomersPageProvider._({
    required PaginatedCustomersPageFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'paginatedCustomersPageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$paginatedCustomersPageHash();

  @override
  String toString() {
    return r'paginatedCustomersPageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Customer>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Customer>> create(Ref ref) {
    final argument = this.argument as int;
    return paginatedCustomersPage(ref, pageIndex: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PaginatedCustomersPageProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$paginatedCustomersPageHash() =>
    r'598ecf353ede3adc8b920e66e5ef1020e8d2f53b';

final class PaginatedCustomersPageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Customer>>, int> {
  const PaginatedCustomersPageFamily._()
    : super(
        retry: null,
        name: r'paginatedCustomersPageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PaginatedCustomersPageProvider call({required int pageIndex}) =>
      PaginatedCustomersPageProvider._(argument: pageIndex, from: this);

  @override
  String toString() => r'paginatedCustomersPageProvider';
}
