// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(customerRepository)
const customerRepositoryProvider = CustomerRepositoryProvider._();

final class CustomerRepositoryProvider
    extends
        $FunctionalProvider<
          CustomerRepository,
          CustomerRepository,
          CustomerRepository
        >
    with $Provider<CustomerRepository> {
  const CustomerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customerRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customerRepositoryHash();

  @$internal
  @override
  $ProviderElement<CustomerRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CustomerRepository create(Ref ref) {
    return customerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomerRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomerRepository>(value),
    );
  }
}

String _$customerRepositoryHash() =>
    r'a951a50031918051ab15246283893956ad1a2980';

@ProviderFor(getCustomersUseCase)
const getCustomersUseCaseProvider = GetCustomersUseCaseProvider._();

final class GetCustomersUseCaseProvider
    extends
        $FunctionalProvider<
          GetCustomersUseCase,
          GetCustomersUseCase,
          GetCustomersUseCase
        >
    with $Provider<GetCustomersUseCase> {
  const GetCustomersUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCustomersUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCustomersUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCustomersUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCustomersUseCase create(Ref ref) {
    return getCustomersUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCustomersUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCustomersUseCase>(value),
    );
  }
}

String _$getCustomersUseCaseHash() =>
    r'90e6692db28342d15d0acc8c2993305b1c6aa4b2';

@ProviderFor(createCustomerUseCase)
const createCustomerUseCaseProvider = CreateCustomerUseCaseProvider._();

final class CreateCustomerUseCaseProvider
    extends
        $FunctionalProvider<
          CreateCustomerUseCase,
          CreateCustomerUseCase,
          CreateCustomerUseCase
        >
    with $Provider<CreateCustomerUseCase> {
  const CreateCustomerUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createCustomerUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createCustomerUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateCustomerUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateCustomerUseCase create(Ref ref) {
    return createCustomerUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateCustomerUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateCustomerUseCase>(value),
    );
  }
}

String _$createCustomerUseCaseHash() =>
    r'575e0c8ffc914f30f8b8429af65ceacf4f322c11';

@ProviderFor(updateCustomerUseCase)
const updateCustomerUseCaseProvider = UpdateCustomerUseCaseProvider._();

final class UpdateCustomerUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateCustomerUseCase,
          UpdateCustomerUseCase,
          UpdateCustomerUseCase
        >
    with $Provider<UpdateCustomerUseCase> {
  const UpdateCustomerUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateCustomerUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateCustomerUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateCustomerUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateCustomerUseCase create(Ref ref) {
    return updateCustomerUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateCustomerUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateCustomerUseCase>(value),
    );
  }
}

String _$updateCustomerUseCaseHash() =>
    r'19bc2997424e1025dfe262ac0958a4701a029b52';

@ProviderFor(deleteCustomerUseCase)
const deleteCustomerUseCaseProvider = DeleteCustomerUseCaseProvider._();

final class DeleteCustomerUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteCustomerUseCase,
          DeleteCustomerUseCase,
          DeleteCustomerUseCase
        >
    with $Provider<DeleteCustomerUseCase> {
  const DeleteCustomerUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteCustomerUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteCustomerUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteCustomerUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteCustomerUseCase create(Ref ref) {
    return deleteCustomerUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteCustomerUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteCustomerUseCase>(value),
    );
  }
}

String _$deleteCustomerUseCaseHash() =>
    r'aac05be22287db5923add1026c643929eac72523';

@ProviderFor(searchCustomersUseCase)
const searchCustomersUseCaseProvider = SearchCustomersUseCaseProvider._();

final class SearchCustomersUseCaseProvider
    extends
        $FunctionalProvider<
          SearchCustomersUseCase,
          SearchCustomersUseCase,
          SearchCustomersUseCase
        >
    with $Provider<SearchCustomersUseCase> {
  const SearchCustomersUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchCustomersUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchCustomersUseCaseHash();

  @$internal
  @override
  $ProviderElement<SearchCustomersUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchCustomersUseCase create(Ref ref) {
    return searchCustomersUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchCustomersUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchCustomersUseCase>(value),
    );
  }
}

String _$searchCustomersUseCaseHash() =>
    r'be80aa7c71d0569f9076658f31b6c9512a33d103';

@ProviderFor(generateNextCustomerCodeUseCase)
const generateNextCustomerCodeUseCaseProvider =
    GenerateNextCustomerCodeUseCaseProvider._();

final class GenerateNextCustomerCodeUseCaseProvider
    extends
        $FunctionalProvider<
          GenerateNextCustomerCodeUseCase,
          GenerateNextCustomerCodeUseCase,
          GenerateNextCustomerCodeUseCase
        >
    with $Provider<GenerateNextCustomerCodeUseCase> {
  const GenerateNextCustomerCodeUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generateNextCustomerCodeUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generateNextCustomerCodeUseCaseHash();

  @$internal
  @override
  $ProviderElement<GenerateNextCustomerCodeUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GenerateNextCustomerCodeUseCase create(Ref ref) {
    return generateNextCustomerCodeUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GenerateNextCustomerCodeUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GenerateNextCustomerCodeUseCase>(
        value,
      ),
    );
  }
}

String _$generateNextCustomerCodeUseCaseHash() =>
    r'551db1bc5936022131f56675aa29316bb8ce10f2';
