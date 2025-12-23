// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SupplierList)
const supplierListProvider = SupplierListProvider._();

final class SupplierListProvider
    extends $AsyncNotifierProvider<SupplierList, List<Supplier>> {
  const SupplierListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supplierListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supplierListHash();

  @$internal
  @override
  SupplierList create() => SupplierList();
}

String _$supplierListHash() => r'69d176644af8c9bee97158acb5bfbe9110757893';

abstract class _$SupplierList extends $AsyncNotifier<List<Supplier>> {
  FutureOr<List<Supplier>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Supplier>>, List<Supplier>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Supplier>>, List<Supplier>>,
              AsyncValue<List<Supplier>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
