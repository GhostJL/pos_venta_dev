// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variant_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VariantForm)
const variantFormProvider = VariantFormFamily._();

final class VariantFormProvider
    extends $NotifierProvider<VariantForm, VariantFormState> {
  const VariantFormProvider._({
    required VariantFormFamily super.from,
    required ProductVariant? super.argument,
  }) : super(
         retry: null,
         name: r'variantFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$variantFormHash();

  @override
  String toString() {
    return r'variantFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VariantForm create() => VariantForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VariantFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VariantFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VariantFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$variantFormHash() => r'93d00a7fd28d4427b900e69004657a68e204a9b1';

final class VariantFormFamily extends $Family
    with
        $ClassFamilyOverride<
          VariantForm,
          VariantFormState,
          VariantFormState,
          VariantFormState,
          ProductVariant?
        > {
  const VariantFormFamily._()
    : super(
        retry: null,
        name: r'variantFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VariantFormProvider call(ProductVariant? variant) =>
      VariantFormProvider._(argument: variant, from: this);

  @override
  String toString() => r'variantFormProvider';
}

abstract class _$VariantForm extends $Notifier<VariantFormState> {
  late final _$args = ref.$arg as ProductVariant?;
  ProductVariant? get variant => _$args;

  VariantFormState build(ProductVariant? variant);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<VariantFormState, VariantFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VariantFormState, VariantFormState>,
              VariantFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
