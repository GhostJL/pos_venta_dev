// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(POSNotifier)
const pOSProvider = POSNotifierProvider._();

final class POSNotifierProvider
    extends $NotifierProvider<POSNotifier, POSState> {
  const POSNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pOSProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pOSNotifierHash();

  @$internal
  @override
  POSNotifier create() => POSNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(POSState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<POSState>(value),
    );
  }
}

String _$pOSNotifierHash() => r'95b6e7c9b753e678ededa81eba2837f77c6e6a11';

abstract class _$POSNotifier extends $Notifier<POSState> {
  POSState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<POSState, POSState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<POSState, POSState>,
              POSState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(allTaxRates)
const allTaxRatesProvider = AllTaxRatesProvider._();

final class AllTaxRatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaxRate>>,
          List<TaxRate>,
          FutureOr<List<TaxRate>>
        >
    with $FutureModifier<List<TaxRate>>, $FutureProvider<List<TaxRate>> {
  const AllTaxRatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allTaxRatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allTaxRatesHash();

  @$internal
  @override
  $FutureProviderElement<List<TaxRate>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TaxRate>> create(Ref ref) {
    return allTaxRates(ref);
  }
}

String _$allTaxRatesHash() => r'56989f18b0e49db9bf72bd2e7e24d37473181175';
