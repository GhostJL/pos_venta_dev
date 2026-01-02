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
    required (ProductVariant?, {VariantType? initialType}) super.argument,
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
        '$argument';
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

String _$variantFormHash() => r'c94221f201ac6ffb6120fcf01d758be2d765f30d';

final class VariantFormFamily extends $Family
    with
        $ClassFamilyOverride<
          VariantForm,
          VariantFormState,
          VariantFormState,
          VariantFormState,
          (ProductVariant?, {VariantType? initialType})
        > {
  const VariantFormFamily._()
    : super(
        retry: null,
        name: r'variantFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VariantFormProvider call(
    ProductVariant? variant, {
    VariantType? initialType,
  }) => VariantFormProvider._(
    argument: (variant, initialType: initialType),
    from: this,
  );

  @override
  String toString() => r'variantFormProvider';
}

abstract class _$VariantForm extends $Notifier<VariantFormState> {
  late final _$args = ref.$arg as (ProductVariant?, {VariantType? initialType});
  ProductVariant? get variant => _$args.$1;
  VariantType? get initialType => _$args.initialType;

  VariantFormState build(ProductVariant? variant, {VariantType? initialType});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args.$1, initialType: _$args.initialType);
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
