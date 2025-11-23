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
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taxRateListHash();

  @$internal
  @override
  TaxRateList create() => TaxRateList();
}

String _$taxRateListHash() => r'8b16987b948067ae92ea9511f9ddf67549343fe8';

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

@ProviderFor(taxRateRepository)
const taxRateRepositoryProvider = TaxRateRepositoryProvider._();

final class TaxRateRepositoryProvider
    extends
        $FunctionalProvider<
          TaxRateRepository,
          TaxRateRepository,
          TaxRateRepository
        >
    with $Provider<TaxRateRepository> {
  const TaxRateRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taxRateRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taxRateRepositoryHash();

  @$internal
  @override
  $ProviderElement<TaxRateRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TaxRateRepository create(Ref ref) {
    return taxRateRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaxRateRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaxRateRepository>(value),
    );
  }
}

String _$taxRateRepositoryHash() => r'82b5118797be76f236ba6c9c4c2fb952ecf653eb';

@ProviderFor(getAllTaxRates)
const getAllTaxRatesProvider = GetAllTaxRatesProvider._();

final class GetAllTaxRatesProvider
    extends $FunctionalProvider<GetAllTaxRates, GetAllTaxRates, GetAllTaxRates>
    with $Provider<GetAllTaxRates> {
  const GetAllTaxRatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAllTaxRatesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAllTaxRatesHash();

  @$internal
  @override
  $ProviderElement<GetAllTaxRates> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetAllTaxRates create(Ref ref) {
    return getAllTaxRates(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAllTaxRates value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAllTaxRates>(value),
    );
  }
}

String _$getAllTaxRatesHash() => r'f056e7a5fc2a9c46d0dcfd56adc4a6367800d10f';

@ProviderFor(createTaxRate)
const createTaxRateProvider = CreateTaxRateProvider._();

final class CreateTaxRateProvider
    extends $FunctionalProvider<CreateTaxRate, CreateTaxRate, CreateTaxRate>
    with $Provider<CreateTaxRate> {
  const CreateTaxRateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createTaxRateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createTaxRateHash();

  @$internal
  @override
  $ProviderElement<CreateTaxRate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateTaxRate create(Ref ref) {
    return createTaxRate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateTaxRate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateTaxRate>(value),
    );
  }
}

String _$createTaxRateHash() => r'1e7b510ad25d3e5855a783f9efb4ab70ec9b61d2';

@ProviderFor(updateTaxRate)
const updateTaxRateProvider = UpdateTaxRateProvider._();

final class UpdateTaxRateProvider
    extends $FunctionalProvider<UpdateTaxRate, UpdateTaxRate, UpdateTaxRate>
    with $Provider<UpdateTaxRate> {
  const UpdateTaxRateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateTaxRateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateTaxRateHash();

  @$internal
  @override
  $ProviderElement<UpdateTaxRate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateTaxRate create(Ref ref) {
    return updateTaxRate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateTaxRate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateTaxRate>(value),
    );
  }
}

String _$updateTaxRateHash() => r'2fba762b6701acc234216a2209edc3ce4f05919f';

@ProviderFor(deleteTaxRate)
const deleteTaxRateProvider = DeleteTaxRateProvider._();

final class DeleteTaxRateProvider
    extends $FunctionalProvider<DeleteTaxRate, DeleteTaxRate, DeleteTaxRate>
    with $Provider<DeleteTaxRate> {
  const DeleteTaxRateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteTaxRateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteTaxRateHash();

  @$internal
  @override
  $ProviderElement<DeleteTaxRate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteTaxRate create(Ref ref) {
    return deleteTaxRate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteTaxRate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteTaxRate>(value),
    );
  }
}

String _$deleteTaxRateHash() => r'028d40eaeed6c15ecada0010cf7ac3cf7efb309e';

@ProviderFor(setDefaultTaxRate)
const setDefaultTaxRateProvider = SetDefaultTaxRateProvider._();

final class SetDefaultTaxRateProvider
    extends
        $FunctionalProvider<
          SetDefaultTaxRate,
          SetDefaultTaxRate,
          SetDefaultTaxRate
        >
    with $Provider<SetDefaultTaxRate> {
  const SetDefaultTaxRateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setDefaultTaxRateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setDefaultTaxRateHash();

  @$internal
  @override
  $ProviderElement<SetDefaultTaxRate> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SetDefaultTaxRate create(Ref ref) {
    return setDefaultTaxRate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetDefaultTaxRate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetDefaultTaxRate>(value),
    );
  }
}

String _$setDefaultTaxRateHash() => r'1b6d3d1b84b520e3c41ddd59a9d44851a6d44581';
