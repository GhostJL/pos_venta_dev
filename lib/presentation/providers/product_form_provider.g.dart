// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProductFormNotifier)
const productFormProvider = ProductFormNotifierFamily._();

final class ProductFormNotifierProvider
    extends $NotifierProvider<ProductFormNotifier, ProductFormState> {
  const ProductFormNotifierProvider._({
    required ProductFormNotifierFamily super.from,
    required Product? super.argument,
  }) : super(
         retry: null,
         name: r'productFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productFormNotifierHash();

  @override
  String toString() {
    return r'productFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProductFormNotifier create() => ProductFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProductFormNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productFormNotifierHash() =>
    r'dbe0033e76ef4c775299657f7305a7f9a49f244f';

final class ProductFormNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ProductFormNotifier,
          ProductFormState,
          ProductFormState,
          ProductFormState,
          Product?
        > {
  const ProductFormNotifierFamily._()
    : super(
        retry: null,
        name: r'productFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProductFormNotifierProvider call(Product? product) =>
      ProductFormNotifierProvider._(argument: product, from: this);

  @override
  String toString() => r'productFormProvider';
}

abstract class _$ProductFormNotifier extends $Notifier<ProductFormState> {
  late final _$args = ref.$arg as Product?;
  Product? get product => _$args;

  ProductFormState build(Product? product);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<ProductFormState, ProductFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProductFormState, ProductFormState>,
              ProductFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
