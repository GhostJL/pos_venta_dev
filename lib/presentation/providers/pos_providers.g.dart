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

String _$pOSNotifierHash() => r'8005f22fdbd11880eb2c90b84ec2f36b06ccc661';

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
