// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discount_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DiscountList)
const discountListProvider = DiscountListProvider._();

final class DiscountListProvider
    extends $AsyncNotifierProvider<DiscountList, List<Discount>> {
  const DiscountListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discountListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discountListHash();

  @$internal
  @override
  DiscountList create() => DiscountList();
}

String _$discountListHash() => r'df3f5f58d501f21fc2e502e56a7b67048d901df7';

abstract class _$DiscountList extends $AsyncNotifier<List<Discount>> {
  FutureOr<List<Discount>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Discount>>, List<Discount>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Discount>>, List<Discount>>,
              AsyncValue<List<Discount>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
