// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(calculateCartItemUseCase)
const calculateCartItemUseCaseProvider = CalculateCartItemUseCaseProvider._();

final class CalculateCartItemUseCaseProvider
    extends
        $FunctionalProvider<
          CalculateCartItemUseCase,
          CalculateCartItemUseCase,
          CalculateCartItemUseCase
        >
    with $Provider<CalculateCartItemUseCase> {
  const CalculateCartItemUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calculateCartItemUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calculateCartItemUseCaseHash();

  @$internal
  @override
  $ProviderElement<CalculateCartItemUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CalculateCartItemUseCase create(Ref ref) {
    return calculateCartItemUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalculateCartItemUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalculateCartItemUseCase>(value),
    );
  }
}

String _$calculateCartItemUseCaseHash() =>
    r'7da4235c6f6ab3fef6ebc29295389eaa990b273a';

@ProviderFor(processSaleUseCase)
const processSaleUseCaseProvider = ProcessSaleUseCaseProvider._();

final class ProcessSaleUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProcessSaleUseCase>,
          ProcessSaleUseCase,
          FutureOr<ProcessSaleUseCase>
        >
    with
        $FutureModifier<ProcessSaleUseCase>,
        $FutureProvider<ProcessSaleUseCase> {
  const ProcessSaleUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'processSaleUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$processSaleUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<ProcessSaleUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProcessSaleUseCase> create(Ref ref) {
    return processSaleUseCase(ref);
  }
}

String _$processSaleUseCaseHash() =>
    r'5d1d2eb8cd0cdd712b1c4bfd53d5402cc63ccb40';
