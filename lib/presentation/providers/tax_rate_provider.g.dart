// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_rate_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TaxRateList)
const taxRateListProvider = TaxRateListProvider._();

final class TaxRateListProvider
    extends $AsyncNotifierProvider<TaxRateList, List<TaxRate>> {
  const TaxRateListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taxRateListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taxRateListHash();

  @$internal
  @override
  TaxRateList create() => TaxRateList();
}

String _$taxRateListHash() => r'c17fccf1b043d2f663cb2ff135838f03baaf2e20';

abstract class _$TaxRateList extends $AsyncNotifier<List<TaxRate>> {
  FutureOr<List<TaxRate>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<TaxRate>>, List<TaxRate>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<TaxRate>>, List<TaxRate>>,
              AsyncValue<List<TaxRate>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
