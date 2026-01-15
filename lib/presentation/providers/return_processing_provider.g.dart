// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'return_processing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReturnProcessing)
const returnProcessingProvider = ReturnProcessingProvider._();

final class ReturnProcessingProvider
    extends $NotifierProvider<ReturnProcessing, ReturnProcessingState> {
  const ReturnProcessingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'returnProcessingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$returnProcessingHash();

  @$internal
  @override
  ReturnProcessing create() => ReturnProcessing();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReturnProcessingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReturnProcessingState>(value),
    );
  }
}

String _$returnProcessingHash() => r'622b3fbddcbde8a657cbd0ec668395073f9373e0';

abstract class _$ReturnProcessing extends $Notifier<ReturnProcessingState> {
  ReturnProcessingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ReturnProcessingState, ReturnProcessingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReturnProcessingState, ReturnProcessingState>,
              ReturnProcessingState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
