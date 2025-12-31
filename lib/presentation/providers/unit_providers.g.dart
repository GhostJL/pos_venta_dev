// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(unitOfMeasureRepository)
const unitOfMeasureRepositoryProvider = UnitOfMeasureRepositoryProvider._();

final class UnitOfMeasureRepositoryProvider
    extends
        $FunctionalProvider<
          UnitOfMeasureRepository,
          UnitOfMeasureRepository,
          UnitOfMeasureRepository
        >
    with $Provider<UnitOfMeasureRepository> {
  const UnitOfMeasureRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unitOfMeasureRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unitOfMeasureRepositoryHash();

  @$internal
  @override
  $ProviderElement<UnitOfMeasureRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UnitOfMeasureRepository create(Ref ref) {
    return unitOfMeasureRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnitOfMeasureRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnitOfMeasureRepository>(value),
    );
  }
}

String _$unitOfMeasureRepositoryHash() =>
    r'461e52deb788864ae51fbcc85e1a322e470a3052';

@ProviderFor(UnitList)
const unitListProvider = UnitListProvider._();

final class UnitListProvider
    extends $AsyncNotifierProvider<UnitList, List<UnitOfMeasure>> {
  const UnitListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unitListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unitListHash();

  @$internal
  @override
  UnitList create() => UnitList();
}

String _$unitListHash() => r'e3175930fd435ae5b61e9b942d78273ec2dfb67b';

abstract class _$UnitList extends $AsyncNotifier<List<UnitOfMeasure>> {
  FutureOr<List<UnitOfMeasure>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<UnitOfMeasure>>, List<UnitOfMeasure>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<UnitOfMeasure>>, List<UnitOfMeasure>>,
              AsyncValue<List<UnitOfMeasure>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
