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

String _$pOSNotifierHash() => r'076f283ab92008529499c4a3f8d4f91d6142d4a3';

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
