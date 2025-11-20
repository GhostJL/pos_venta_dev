// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CustomerNotifier)
const customerProvider = CustomerNotifierProvider._();

final class CustomerNotifierProvider
    extends $AsyncNotifierProvider<CustomerNotifier, List<Customer>> {
  const CustomerNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customerNotifierHash();

  @$internal
  @override
  CustomerNotifier create() => CustomerNotifier();
}

String _$customerNotifierHash() => r'85d771e35c4a04d7bc6fef2ffc6de7a84f160807';

abstract class _$CustomerNotifier extends $AsyncNotifier<List<Customer>> {
  FutureOr<List<Customer>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Customer>>, List<Customer>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Customer>>, List<Customer>>,
              AsyncValue<List<Customer>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
