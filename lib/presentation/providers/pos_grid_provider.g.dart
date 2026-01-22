// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_grid_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(posGridItems)
const posGridItemsProvider = PosGridItemsProvider._();

final class PosGridItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProductGridItem>>,
          List<ProductGridItem>,
          FutureOr<List<ProductGridItem>>
        >
    with
        $FutureModifier<List<ProductGridItem>>,
        $FutureProvider<List<ProductGridItem>> {
  const PosGridItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'posGridItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$posGridItemsHash();

  @$internal
  @override
  $FutureProviderElement<List<ProductGridItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProductGridItem>> create(Ref ref) {
    return posGridItems(ref);
  }
}

String _$posGridItemsHash() => r'1787aa0ece6cc1a149c74d93eef36e52af1ab8f9';
