// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PurchaseNotifier)
const purchaseProvider = PurchaseNotifierProvider._();

final class PurchaseNotifierProvider
    extends $AsyncNotifierProvider<PurchaseNotifier, List<Purchase>> {
  const PurchaseNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseNotifierHash();

  @$internal
  @override
  PurchaseNotifier create() => PurchaseNotifier();
}

String _$purchaseNotifierHash() => r'4143c8710e5128821f1741c69183bc81e077d701';

abstract class _$PurchaseNotifier extends $AsyncNotifier<List<Purchase>> {
  FutureOr<List<Purchase>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Purchase>>, List<Purchase>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Purchase>>, List<Purchase>>,
              AsyncValue<List<Purchase>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(purchaseById)
const purchaseByIdProvider = PurchaseByIdFamily._();

final class PurchaseByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<Purchase?>,
          Purchase?,
          FutureOr<Purchase?>
        >
    with $FutureModifier<Purchase?>, $FutureProvider<Purchase?> {
  const PurchaseByIdProvider._({
    required PurchaseByIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'purchaseByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$purchaseByIdHash();

  @override
  String toString() {
    return r'purchaseByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Purchase?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Purchase?> create(Ref ref) {
    final argument = this.argument as int;
    return purchaseById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PurchaseByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$purchaseByIdHash() => r'96ae13757c9e4570815a0c3ed156f90a81cce01c';

final class PurchaseByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Purchase?>, int> {
  const PurchaseByIdFamily._()
    : super(
        retry: null,
        name: r'purchaseByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PurchaseByIdProvider call(int id) =>
      PurchaseByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'purchaseByIdProvider';
}
