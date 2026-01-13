// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debtors_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(debtors)
const debtorsProvider = DebtorsProvider._();

final class DebtorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Customer>>,
          List<Customer>,
          FutureOr<List<Customer>>
        >
    with $FutureModifier<List<Customer>>, $FutureProvider<List<Customer>> {
  const DebtorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'debtorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$debtorsHash();

  @$internal
  @override
  $FutureProviderElement<List<Customer>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Customer>> create(Ref ref) {
    return debtors(ref);
  }
}

String _$debtorsHash() => r'82c05a6448b01975ae6dc247693c9a8ac22e1fd5';
