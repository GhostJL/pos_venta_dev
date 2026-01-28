// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PurchaseFormNotifier)
const purchaseFormProvider = PurchaseFormNotifierProvider._();

final class PurchaseFormNotifierProvider
    extends $NotifierProvider<PurchaseFormNotifier, PurchaseFormState> {
  const PurchaseFormNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseFormNotifierHash();

  @$internal
  @override
  PurchaseFormNotifier create() => PurchaseFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseFormState>(value),
    );
  }
}

String _$purchaseFormNotifierHash() =>
    r'36c2dbf9a791b1d68d65a0b3552892cb3c8d1ed1';

abstract class _$PurchaseFormNotifier extends $Notifier<PurchaseFormState> {
  PurchaseFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PurchaseFormState, PurchaseFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PurchaseFormState, PurchaseFormState>,
              PurchaseFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(PurchaseItemFormNotifier)
const purchaseItemFormProvider = PurchaseItemFormNotifierProvider._();

final class PurchaseItemFormNotifierProvider
    extends $NotifierProvider<PurchaseItemFormNotifier, PurchaseItemFormState> {
  const PurchaseItemFormNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseItemFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseItemFormNotifierHash();

  @$internal
  @override
  PurchaseItemFormNotifier create() => PurchaseItemFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseItemFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseItemFormState>(value),
    );
  }
}

String _$purchaseItemFormNotifierHash() =>
    r'1b50dea54e5b8dd3fbab2c3a1ce8f4014e4662ab';

abstract class _$PurchaseItemFormNotifier
    extends $Notifier<PurchaseItemFormState> {
  PurchaseItemFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PurchaseItemFormState, PurchaseItemFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PurchaseItemFormState, PurchaseItemFormState>,
              PurchaseItemFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(purchaseProductList)
const purchaseProductListProvider = PurchaseProductListFamily._();

final class PurchaseProductListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Product>>,
          List<Product>,
          FutureOr<List<Product>>
        >
    with $FutureModifier<List<Product>>, $FutureProvider<List<Product>> {
  const PurchaseProductListProvider._({
    required PurchaseProductListFamily super.from,
    required ({int? supplierId, String query}) super.argument,
  }) : super(
         retry: null,
         name: r'purchaseProductListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$purchaseProductListHash();

  @override
  String toString() {
    return r'purchaseProductListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Product>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Product>> create(Ref ref) {
    final argument = this.argument as ({int? supplierId, String query});
    return purchaseProductList(
      ref,
      supplierId: argument.supplierId,
      query: argument.query,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PurchaseProductListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$purchaseProductListHash() =>
    r'419b5522fbe34fcb554e1782847669ba1beef4f2';

final class PurchaseProductListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Product>>,
          ({int? supplierId, String query})
        > {
  const PurchaseProductListFamily._()
    : super(
        retry: null,
        name: r'purchaseProductListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PurchaseProductListProvider call({int? supplierId, String query = ''}) =>
      PurchaseProductListProvider._(
        argument: (supplierId: supplierId, query: query),
        from: this,
      );

  @override
  String toString() => r'purchaseProductListProvider';
}
