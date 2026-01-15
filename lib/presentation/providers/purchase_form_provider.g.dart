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
    r'905ec0d1bb25c03a72661f88cf35e622e6db3359';

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
    r'4b05032572a45e4ad6f625063871312d8daa7567';

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
