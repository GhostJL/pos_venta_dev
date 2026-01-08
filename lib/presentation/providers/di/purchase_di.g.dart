// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(purchaseRepository)
const purchaseRepositoryProvider = PurchaseRepositoryProvider._();

final class PurchaseRepositoryProvider
    extends
        $FunctionalProvider<
          PurchaseRepository,
          PurchaseRepository,
          PurchaseRepository
        >
    with $Provider<PurchaseRepository> {
  const PurchaseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseRepositoryHash();

  @$internal
  @override
  $ProviderElement<PurchaseRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PurchaseRepository create(Ref ref) {
    return purchaseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseRepository>(value),
    );
  }
}

String _$purchaseRepositoryHash() =>
    r'8ae914ee965ab1068b332fac1dbcbbdbf899dc63';

@ProviderFor(getPurchasesUseCase)
const getPurchasesUseCaseProvider = GetPurchasesUseCaseProvider._();

final class GetPurchasesUseCaseProvider
    extends
        $FunctionalProvider<
          GetPurchasesUseCase,
          GetPurchasesUseCase,
          GetPurchasesUseCase
        >
    with $Provider<GetPurchasesUseCase> {
  const GetPurchasesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPurchasesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getPurchasesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPurchasesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPurchasesUseCase create(Ref ref) {
    return getPurchasesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPurchasesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPurchasesUseCase>(value),
    );
  }
}

String _$getPurchasesUseCaseHash() =>
    r'8c55b8a426b11b2b7ccfa9e2056029f0ae4ad1e8';

@ProviderFor(getPurchaseByIdUseCase)
const getPurchaseByIdUseCaseProvider = GetPurchaseByIdUseCaseProvider._();

final class GetPurchaseByIdUseCaseProvider
    extends
        $FunctionalProvider<
          GetPurchaseByIdUseCase,
          GetPurchaseByIdUseCase,
          GetPurchaseByIdUseCase
        >
    with $Provider<GetPurchaseByIdUseCase> {
  const GetPurchaseByIdUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPurchaseByIdUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getPurchaseByIdUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPurchaseByIdUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPurchaseByIdUseCase create(Ref ref) {
    return getPurchaseByIdUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPurchaseByIdUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPurchaseByIdUseCase>(value),
    );
  }
}

String _$getPurchaseByIdUseCaseHash() =>
    r'25ccbb63fb4bb3ab351b6d849e0c2057847d5b68';

@ProviderFor(createPurchaseUseCase)
const createPurchaseUseCaseProvider = CreatePurchaseUseCaseProvider._();

final class CreatePurchaseUseCaseProvider
    extends
        $FunctionalProvider<
          CreatePurchaseUseCase,
          CreatePurchaseUseCase,
          CreatePurchaseUseCase
        >
    with $Provider<CreatePurchaseUseCase> {
  const CreatePurchaseUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createPurchaseUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createPurchaseUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreatePurchaseUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreatePurchaseUseCase create(Ref ref) {
    return createPurchaseUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreatePurchaseUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreatePurchaseUseCase>(value),
    );
  }
}

String _$createPurchaseUseCaseHash() =>
    r'8d04eb3b1c5b0bae0411ad0b84f05c0d66a1eee4';

@ProviderFor(updatePurchaseUseCase)
const updatePurchaseUseCaseProvider = UpdatePurchaseUseCaseProvider._();

final class UpdatePurchaseUseCaseProvider
    extends
        $FunctionalProvider<
          UpdatePurchaseUseCase,
          UpdatePurchaseUseCase,
          UpdatePurchaseUseCase
        >
    with $Provider<UpdatePurchaseUseCase> {
  const UpdatePurchaseUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updatePurchaseUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updatePurchaseUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdatePurchaseUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdatePurchaseUseCase create(Ref ref) {
    return updatePurchaseUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdatePurchaseUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdatePurchaseUseCase>(value),
    );
  }
}

String _$updatePurchaseUseCaseHash() =>
    r'a2c85efd8df5f369e8550192060cfb71f9a888c3';

@ProviderFor(deletePurchaseUseCase)
const deletePurchaseUseCaseProvider = DeletePurchaseUseCaseProvider._();

final class DeletePurchaseUseCaseProvider
    extends
        $FunctionalProvider<
          DeletePurchaseUseCase,
          DeletePurchaseUseCase,
          DeletePurchaseUseCase
        >
    with $Provider<DeletePurchaseUseCase> {
  const DeletePurchaseUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deletePurchaseUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deletePurchaseUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeletePurchaseUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeletePurchaseUseCase create(Ref ref) {
    return deletePurchaseUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeletePurchaseUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeletePurchaseUseCase>(value),
    );
  }
}

String _$deletePurchaseUseCaseHash() =>
    r'be05b66b079aa65b5c28d6916b1b474848b5d8d6';

@ProviderFor(receivePurchaseUseCase)
const receivePurchaseUseCaseProvider = ReceivePurchaseUseCaseProvider._();

final class ReceivePurchaseUseCaseProvider
    extends
        $FunctionalProvider<
          ReceivePurchaseUseCase,
          ReceivePurchaseUseCase,
          ReceivePurchaseUseCase
        >
    with $Provider<ReceivePurchaseUseCase> {
  const ReceivePurchaseUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receivePurchaseUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receivePurchaseUseCaseHash();

  @$internal
  @override
  $ProviderElement<ReceivePurchaseUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReceivePurchaseUseCase create(Ref ref) {
    return receivePurchaseUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReceivePurchaseUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReceivePurchaseUseCase>(value),
    );
  }
}

String _$receivePurchaseUseCaseHash() =>
    r'a486676f272c5abf64f4b98b8a6daf60ac428a13';

@ProviderFor(cancelPurchaseUseCase)
const cancelPurchaseUseCaseProvider = CancelPurchaseUseCaseProvider._();

final class CancelPurchaseUseCaseProvider
    extends
        $FunctionalProvider<
          CancelPurchaseUseCase,
          CancelPurchaseUseCase,
          CancelPurchaseUseCase
        >
    with $Provider<CancelPurchaseUseCase> {
  const CancelPurchaseUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cancelPurchaseUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cancelPurchaseUseCaseHash();

  @$internal
  @override
  $ProviderElement<CancelPurchaseUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CancelPurchaseUseCase create(Ref ref) {
    return cancelPurchaseUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CancelPurchaseUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CancelPurchaseUseCase>(value),
    );
  }
}

String _$cancelPurchaseUseCaseHash() =>
    r'89775ae729bb82e1960ec589899b8bf4c75da364';

@ProviderFor(purchaseItemRepository)
const purchaseItemRepositoryProvider = PurchaseItemRepositoryProvider._();

final class PurchaseItemRepositoryProvider
    extends
        $FunctionalProvider<
          PurchaseItemRepository,
          PurchaseItemRepository,
          PurchaseItemRepository
        >
    with $Provider<PurchaseItemRepository> {
  const PurchaseItemRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseItemRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseItemRepositoryHash();

  @$internal
  @override
  $ProviderElement<PurchaseItemRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PurchaseItemRepository create(Ref ref) {
    return purchaseItemRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseItemRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseItemRepository>(value),
    );
  }
}

String _$purchaseItemRepositoryHash() =>
    r'a76c92277546b723eefd5a9f49171b997454db04';

@ProviderFor(getPurchaseItemsUseCase)
const getPurchaseItemsUseCaseProvider = GetPurchaseItemsUseCaseProvider._();

final class GetPurchaseItemsUseCaseProvider
    extends
        $FunctionalProvider<
          GetPurchaseItemsUseCase,
          GetPurchaseItemsUseCase,
          GetPurchaseItemsUseCase
        >
    with $Provider<GetPurchaseItemsUseCase> {
  const GetPurchaseItemsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPurchaseItemsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getPurchaseItemsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPurchaseItemsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPurchaseItemsUseCase create(Ref ref) {
    return getPurchaseItemsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPurchaseItemsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPurchaseItemsUseCase>(value),
    );
  }
}

String _$getPurchaseItemsUseCaseHash() =>
    r'b298fa45952884376542019a65e974ce283e388b';

@ProviderFor(getPurchaseItemsByPurchaseIdUseCase)
const getPurchaseItemsByPurchaseIdUseCaseProvider =
    GetPurchaseItemsByPurchaseIdUseCaseProvider._();

final class GetPurchaseItemsByPurchaseIdUseCaseProvider
    extends
        $FunctionalProvider<
          GetPurchaseItemsByPurchaseIdUseCase,
          GetPurchaseItemsByPurchaseIdUseCase,
          GetPurchaseItemsByPurchaseIdUseCase
        >
    with $Provider<GetPurchaseItemsByPurchaseIdUseCase> {
  const GetPurchaseItemsByPurchaseIdUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPurchaseItemsByPurchaseIdUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$getPurchaseItemsByPurchaseIdUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPurchaseItemsByPurchaseIdUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPurchaseItemsByPurchaseIdUseCase create(Ref ref) {
    return getPurchaseItemsByPurchaseIdUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPurchaseItemsByPurchaseIdUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPurchaseItemsByPurchaseIdUseCase>(
        value,
      ),
    );
  }
}

String _$getPurchaseItemsByPurchaseIdUseCaseHash() =>
    r'95d18283069c2299ca89f816051f2f2a1d970e53';

@ProviderFor(getPurchaseItemByIdUseCase)
const getPurchaseItemByIdUseCaseProvider =
    GetPurchaseItemByIdUseCaseProvider._();

final class GetPurchaseItemByIdUseCaseProvider
    extends
        $FunctionalProvider<
          GetPurchaseItemByIdUseCase,
          GetPurchaseItemByIdUseCase,
          GetPurchaseItemByIdUseCase
        >
    with $Provider<GetPurchaseItemByIdUseCase> {
  const GetPurchaseItemByIdUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPurchaseItemByIdUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getPurchaseItemByIdUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPurchaseItemByIdUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPurchaseItemByIdUseCase create(Ref ref) {
    return getPurchaseItemByIdUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPurchaseItemByIdUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPurchaseItemByIdUseCase>(value),
    );
  }
}

String _$getPurchaseItemByIdUseCaseHash() =>
    r'2a409f95cb3777515adf0de539d8e4927ed49996';

@ProviderFor(getPurchaseItemsByProductIdUseCase)
const getPurchaseItemsByProductIdUseCaseProvider =
    GetPurchaseItemsByProductIdUseCaseProvider._();

final class GetPurchaseItemsByProductIdUseCaseProvider
    extends
        $FunctionalProvider<
          GetPurchaseItemsByProductIdUseCase,
          GetPurchaseItemsByProductIdUseCase,
          GetPurchaseItemsByProductIdUseCase
        >
    with $Provider<GetPurchaseItemsByProductIdUseCase> {
  const GetPurchaseItemsByProductIdUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPurchaseItemsByProductIdUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$getPurchaseItemsByProductIdUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPurchaseItemsByProductIdUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPurchaseItemsByProductIdUseCase create(Ref ref) {
    return getPurchaseItemsByProductIdUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPurchaseItemsByProductIdUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPurchaseItemsByProductIdUseCase>(
        value,
      ),
    );
  }
}

String _$getPurchaseItemsByProductIdUseCaseHash() =>
    r'd5decd59de1be01496d6d88c495f227ea7ce2a4f';

@ProviderFor(createPurchaseItemUseCase)
const createPurchaseItemUseCaseProvider = CreatePurchaseItemUseCaseProvider._();

final class CreatePurchaseItemUseCaseProvider
    extends
        $FunctionalProvider<
          CreatePurchaseItemUseCase,
          CreatePurchaseItemUseCase,
          CreatePurchaseItemUseCase
        >
    with $Provider<CreatePurchaseItemUseCase> {
  const CreatePurchaseItemUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createPurchaseItemUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createPurchaseItemUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreatePurchaseItemUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreatePurchaseItemUseCase create(Ref ref) {
    return createPurchaseItemUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreatePurchaseItemUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreatePurchaseItemUseCase>(value),
    );
  }
}

String _$createPurchaseItemUseCaseHash() =>
    r'75d612162040cc1bad53789e78940397e1febb0b';

@ProviderFor(updatePurchaseItemUseCase)
const updatePurchaseItemUseCaseProvider = UpdatePurchaseItemUseCaseProvider._();

final class UpdatePurchaseItemUseCaseProvider
    extends
        $FunctionalProvider<
          UpdatePurchaseItemUseCase,
          UpdatePurchaseItemUseCase,
          UpdatePurchaseItemUseCase
        >
    with $Provider<UpdatePurchaseItemUseCase> {
  const UpdatePurchaseItemUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updatePurchaseItemUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updatePurchaseItemUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdatePurchaseItemUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdatePurchaseItemUseCase create(Ref ref) {
    return updatePurchaseItemUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdatePurchaseItemUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdatePurchaseItemUseCase>(value),
    );
  }
}

String _$updatePurchaseItemUseCaseHash() =>
    r'61a3183d1287e2bc0ef5690b4f4852087ab04367';

@ProviderFor(deletePurchaseItemUseCase)
const deletePurchaseItemUseCaseProvider = DeletePurchaseItemUseCaseProvider._();

final class DeletePurchaseItemUseCaseProvider
    extends
        $FunctionalProvider<
          DeletePurchaseItemUseCase,
          DeletePurchaseItemUseCase,
          DeletePurchaseItemUseCase
        >
    with $Provider<DeletePurchaseItemUseCase> {
  const DeletePurchaseItemUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deletePurchaseItemUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deletePurchaseItemUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeletePurchaseItemUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeletePurchaseItemUseCase create(Ref ref) {
    return deletePurchaseItemUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeletePurchaseItemUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeletePurchaseItemUseCase>(value),
    );
  }
}

String _$deletePurchaseItemUseCaseHash() =>
    r'2682581ea5c013d29ae7be3b3fa0fdb6f2137470';

@ProviderFor(getPurchaseItemsByDateRangeUseCase)
const getPurchaseItemsByDateRangeUseCaseProvider =
    GetPurchaseItemsByDateRangeUseCaseProvider._();

final class GetPurchaseItemsByDateRangeUseCaseProvider
    extends
        $FunctionalProvider<
          GetPurchaseItemsByDateRangeUseCase,
          GetPurchaseItemsByDateRangeUseCase,
          GetPurchaseItemsByDateRangeUseCase
        >
    with $Provider<GetPurchaseItemsByDateRangeUseCase> {
  const GetPurchaseItemsByDateRangeUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPurchaseItemsByDateRangeUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$getPurchaseItemsByDateRangeUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPurchaseItemsByDateRangeUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPurchaseItemsByDateRangeUseCase create(Ref ref) {
    return getPurchaseItemsByDateRangeUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPurchaseItemsByDateRangeUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPurchaseItemsByDateRangeUseCase>(
        value,
      ),
    );
  }
}

String _$getPurchaseItemsByDateRangeUseCaseHash() =>
    r'139c6e681c5af73c1bb3d8fa074c69902f710174';

@ProviderFor(getRecentPurchaseItemsUseCase)
const getRecentPurchaseItemsUseCaseProvider =
    GetRecentPurchaseItemsUseCaseProvider._();

final class GetRecentPurchaseItemsUseCaseProvider
    extends
        $FunctionalProvider<
          GetRecentPurchaseItemsUseCase,
          GetRecentPurchaseItemsUseCase,
          GetRecentPurchaseItemsUseCase
        >
    with $Provider<GetRecentPurchaseItemsUseCase> {
  const GetRecentPurchaseItemsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getRecentPurchaseItemsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getRecentPurchaseItemsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetRecentPurchaseItemsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetRecentPurchaseItemsUseCase create(Ref ref) {
    return getRecentPurchaseItemsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetRecentPurchaseItemsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetRecentPurchaseItemsUseCase>(
        value,
      ),
    );
  }
}

String _$getRecentPurchaseItemsUseCaseHash() =>
    r'b12abfd99f33e59a7a5eb0b8223f71ed0022a271';
