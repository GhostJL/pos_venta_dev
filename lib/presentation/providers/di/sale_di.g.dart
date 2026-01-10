// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transactionRepository)
const transactionRepositoryProvider = TransactionRepositoryProvider._();

final class TransactionRepositoryProvider
    extends
        $FunctionalProvider<
          TransactionRepository,
          TransactionRepository,
          TransactionRepository
        >
    with $Provider<TransactionRepository> {
  const TransactionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransactionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionRepository create(Ref ref) {
    return transactionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionRepository>(value),
    );
  }
}

String _$transactionRepositoryHash() =>
    r'4a8b58c01058ceb12bdab25ca3acad8c8301ccb6';

@ProviderFor(saleRepository)
const saleRepositoryProvider = SaleRepositoryProvider._();

final class SaleRepositoryProvider
    extends $FunctionalProvider<SaleRepository, SaleRepository, SaleRepository>
    with $Provider<SaleRepository> {
  const SaleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleRepositoryHash();

  @$internal
  @override
  $ProviderElement<SaleRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SaleRepository create(Ref ref) {
    return saleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleRepository>(value),
    );
  }
}

String _$saleRepositoryHash() => r'90327e2841aa357b9f7fb89983d9d4e28a16cd42';

@ProviderFor(createSaleUseCase)
const createSaleUseCaseProvider = CreateSaleUseCaseProvider._();

final class CreateSaleUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<CreateSaleUseCase>,
          CreateSaleUseCase,
          FutureOr<CreateSaleUseCase>
        >
    with
        $FutureModifier<CreateSaleUseCase>,
        $FutureProvider<CreateSaleUseCase> {
  const CreateSaleUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createSaleUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createSaleUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<CreateSaleUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CreateSaleUseCase> create(Ref ref) {
    return createSaleUseCase(ref);
  }
}

String _$createSaleUseCaseHash() => r'febbf6f6aba3b756c5f2ed133e9a524c3571411d';

@ProviderFor(getSalesUseCase)
const getSalesUseCaseProvider = GetSalesUseCaseProvider._();

final class GetSalesUseCaseProvider
    extends
        $FunctionalProvider<GetSalesUseCase, GetSalesUseCase, GetSalesUseCase>
    with $Provider<GetSalesUseCase> {
  const GetSalesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSalesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSalesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetSalesUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetSalesUseCase create(Ref ref) {
    return getSalesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetSalesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetSalesUseCase>(value),
    );
  }
}

String _$getSalesUseCaseHash() => r'b8404b9c68a426df76866da8169c2d0562cc427a';

@ProviderFor(getSaleByIdUseCase)
const getSaleByIdUseCaseProvider = GetSaleByIdUseCaseProvider._();

final class GetSaleByIdUseCaseProvider
    extends
        $FunctionalProvider<
          GetSaleByIdUseCase,
          GetSaleByIdUseCase,
          GetSaleByIdUseCase
        >
    with $Provider<GetSaleByIdUseCase> {
  const GetSaleByIdUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSaleByIdUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSaleByIdUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetSaleByIdUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetSaleByIdUseCase create(Ref ref) {
    return getSaleByIdUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetSaleByIdUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetSaleByIdUseCase>(value),
    );
  }
}

String _$getSaleByIdUseCaseHash() =>
    r'6b492a9e9c8bb815c4434ba9911cc9a2435f02c1';

@ProviderFor(generateNextSaleNumberUseCase)
const generateNextSaleNumberUseCaseProvider =
    GenerateNextSaleNumberUseCaseProvider._();

final class GenerateNextSaleNumberUseCaseProvider
    extends
        $FunctionalProvider<
          GenerateNextSaleNumberUseCase,
          GenerateNextSaleNumberUseCase,
          GenerateNextSaleNumberUseCase
        >
    with $Provider<GenerateNextSaleNumberUseCase> {
  const GenerateNextSaleNumberUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generateNextSaleNumberUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generateNextSaleNumberUseCaseHash();

  @$internal
  @override
  $ProviderElement<GenerateNextSaleNumberUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GenerateNextSaleNumberUseCase create(Ref ref) {
    return generateNextSaleNumberUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GenerateNextSaleNumberUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GenerateNextSaleNumberUseCase>(
        value,
      ),
    );
  }
}

String _$generateNextSaleNumberUseCaseHash() =>
    r'961dbaf4e486457c812f9b381356b98b10dfece1';

@ProviderFor(cancelSaleUseCase)
const cancelSaleUseCaseProvider = CancelSaleUseCaseProvider._();

final class CancelSaleUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<CancelSaleUseCase>,
          CancelSaleUseCase,
          FutureOr<CancelSaleUseCase>
        >
    with
        $FutureModifier<CancelSaleUseCase>,
        $FutureProvider<CancelSaleUseCase> {
  const CancelSaleUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cancelSaleUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cancelSaleUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<CancelSaleUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CancelSaleUseCase> create(Ref ref) {
    return cancelSaleUseCase(ref);
  }
}

String _$cancelSaleUseCaseHash() => r'3a677759e55b972bc2f476cf27ec8e08641412f1';

@ProviderFor(todaysRevenue)
const todaysRevenueProvider = TodaysRevenueProvider._();

final class TodaysRevenueProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  const TodaysRevenueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todaysRevenueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todaysRevenueHash();

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    return todaysRevenue(ref);
  }
}

String _$todaysRevenueHash() => r'f6c06176b9dacb3e23e55d67a8b72243a4ea6ef0';

@ProviderFor(todaysTransactions)
const todaysTransactionsProvider = TodaysTransactionsProvider._();

final class TodaysTransactionsProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  const TodaysTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todaysTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todaysTransactionsHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return todaysTransactions(ref);
  }
}

String _$todaysTransactionsHash() =>
    r'bf05b523e555e0610321bcb94f472e6c7fc60153';

@ProviderFor(cashSessionRepository)
const cashSessionRepositoryProvider = CashSessionRepositoryProvider._();

final class CashSessionRepositoryProvider
    extends
        $FunctionalProvider<
          CashSessionRepository,
          CashSessionRepository,
          CashSessionRepository
        >
    with $Provider<CashSessionRepository> {
  const CashSessionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cashSessionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cashSessionRepositoryHash();

  @$internal
  @override
  $ProviderElement<CashSessionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CashSessionRepository create(Ref ref) {
    return cashSessionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CashSessionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CashSessionRepository>(value),
    );
  }
}

String _$cashSessionRepositoryHash() =>
    r'0b0afad28e28d66ae8b680f6fc6a6fb3826a5492';

@ProviderFor(getCurrentSession)
const getCurrentSessionProvider = GetCurrentSessionProvider._();

final class GetCurrentSessionProvider
    extends
        $FunctionalProvider<
          GetCurrentSession,
          GetCurrentSession,
          GetCurrentSession
        >
    with $Provider<GetCurrentSession> {
  const GetCurrentSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCurrentSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCurrentSessionHash();

  @$internal
  @override
  $ProviderElement<GetCurrentSession> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCurrentSession create(Ref ref) {
    return getCurrentSession(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCurrentSession value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCurrentSession>(value),
    );
  }
}

String _$getCurrentSessionHash() => r'32cb4df366931b14802aaa665b114d665ad3873d';

@ProviderFor(getCurrentCashSessionUseCase)
const getCurrentCashSessionUseCaseProvider =
    GetCurrentCashSessionUseCaseProvider._();

final class GetCurrentCashSessionUseCaseProvider
    extends
        $FunctionalProvider<
          GetCurrentCashSessionUseCase,
          GetCurrentCashSessionUseCase,
          GetCurrentCashSessionUseCase
        >
    with $Provider<GetCurrentCashSessionUseCase> {
  const GetCurrentCashSessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCurrentCashSessionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCurrentCashSessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCurrentCashSessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCurrentCashSessionUseCase create(Ref ref) {
    return getCurrentCashSessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCurrentCashSessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCurrentCashSessionUseCase>(value),
    );
  }
}

String _$getCurrentCashSessionUseCaseHash() =>
    r'98544a12457218c3a7087521b443cd7737d465bf';

@ProviderFor(openCashSessionUseCase)
const openCashSessionUseCaseProvider = OpenCashSessionUseCaseProvider._();

final class OpenCashSessionUseCaseProvider
    extends
        $FunctionalProvider<
          OpenCashSessionUseCase,
          OpenCashSessionUseCase,
          OpenCashSessionUseCase
        >
    with $Provider<OpenCashSessionUseCase> {
  const OpenCashSessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openCashSessionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openCashSessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<OpenCashSessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OpenCashSessionUseCase create(Ref ref) {
    return openCashSessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpenCashSessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpenCashSessionUseCase>(value),
    );
  }
}

String _$openCashSessionUseCaseHash() =>
    r'68b51296d4be6325f6e606e6009900ff914be8ee';

@ProviderFor(closeCashSessionUseCase)
const closeCashSessionUseCaseProvider = CloseCashSessionUseCaseProvider._();

final class CloseCashSessionUseCaseProvider
    extends
        $FunctionalProvider<
          CloseCashSessionUseCase,
          CloseCashSessionUseCase,
          CloseCashSessionUseCase
        >
    with $Provider<CloseCashSessionUseCase> {
  const CloseCashSessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'closeCashSessionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$closeCashSessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<CloseCashSessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CloseCashSessionUseCase create(Ref ref) {
    return closeCashSessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CloseCashSessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CloseCashSessionUseCase>(value),
    );
  }
}

String _$closeCashSessionUseCaseHash() =>
    r'e8034c2c4d3e82819d4b83c41a2faa31afd39824';

@ProviderFor(currentCashSession)
const currentCashSessionProvider = CurrentCashSessionProvider._();

final class CurrentCashSessionProvider
    extends
        $FunctionalProvider<
          AsyncValue<CashSession?>,
          CashSession?,
          FutureOr<CashSession?>
        >
    with $FutureModifier<CashSession?>, $FutureProvider<CashSession?> {
  const CurrentCashSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentCashSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentCashSessionHash();

  @$internal
  @override
  $FutureProviderElement<CashSession?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CashSession?> create(Ref ref) {
    return currentCashSession(ref);
  }
}

String _$currentCashSessionHash() =>
    r'5f3b829041469d67d2c6c80c2bde19f178e99a7d';

@ProviderFor(saleReturnRepository)
const saleReturnRepositoryProvider = SaleReturnRepositoryProvider._();

final class SaleReturnRepositoryProvider
    extends
        $FunctionalProvider<
          SaleReturnRepository,
          SaleReturnRepository,
          SaleReturnRepository
        >
    with $Provider<SaleReturnRepository> {
  const SaleReturnRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleReturnRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleReturnRepositoryHash();

  @$internal
  @override
  $ProviderElement<SaleReturnRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaleReturnRepository create(Ref ref) {
    return saleReturnRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleReturnRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleReturnRepository>(value),
    );
  }
}

String _$saleReturnRepositoryHash() =>
    r'8cbf15afde25a852236c4f741238feb142ea808a';

@ProviderFor(createSaleReturnUseCase)
const createSaleReturnUseCaseProvider = CreateSaleReturnUseCaseProvider._();

final class CreateSaleReturnUseCaseProvider
    extends
        $FunctionalProvider<
          CreateSaleReturnUseCase,
          CreateSaleReturnUseCase,
          CreateSaleReturnUseCase
        >
    with $Provider<CreateSaleReturnUseCase> {
  const CreateSaleReturnUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createSaleReturnUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createSaleReturnUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateSaleReturnUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateSaleReturnUseCase create(Ref ref) {
    return createSaleReturnUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateSaleReturnUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateSaleReturnUseCase>(value),
    );
  }
}

String _$createSaleReturnUseCaseHash() =>
    r'f8446d925084966ea445abe0b157653a1ba95cf3';

@ProviderFor(getSaleReturnsUseCase)
const getSaleReturnsUseCaseProvider = GetSaleReturnsUseCaseProvider._();

final class GetSaleReturnsUseCaseProvider
    extends
        $FunctionalProvider<
          GetSaleReturnsUseCase,
          GetSaleReturnsUseCase,
          GetSaleReturnsUseCase
        >
    with $Provider<GetSaleReturnsUseCase> {
  const GetSaleReturnsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSaleReturnsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSaleReturnsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetSaleReturnsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetSaleReturnsUseCase create(Ref ref) {
    return getSaleReturnsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetSaleReturnsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetSaleReturnsUseCase>(value),
    );
  }
}

String _$getSaleReturnsUseCaseHash() =>
    r'5b9ee3fa8e80c0ffd08badcc2c91675ba01a5bf5';

@ProviderFor(getSaleReturnByIdUseCase)
const getSaleReturnByIdUseCaseProvider = GetSaleReturnByIdUseCaseProvider._();

final class GetSaleReturnByIdUseCaseProvider
    extends
        $FunctionalProvider<
          GetSaleReturnByIdUseCase,
          GetSaleReturnByIdUseCase,
          GetSaleReturnByIdUseCase
        >
    with $Provider<GetSaleReturnByIdUseCase> {
  const GetSaleReturnByIdUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSaleReturnByIdUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSaleReturnByIdUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetSaleReturnByIdUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetSaleReturnByIdUseCase create(Ref ref) {
    return getSaleReturnByIdUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetSaleReturnByIdUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetSaleReturnByIdUseCase>(value),
    );
  }
}

String _$getSaleReturnByIdUseCaseHash() =>
    r'2abcbc665b28ef1b4ac016bd40dff63d1de36747';

@ProviderFor(generateNextReturnNumberUseCase)
const generateNextReturnNumberUseCaseProvider =
    GenerateNextReturnNumberUseCaseProvider._();

final class GenerateNextReturnNumberUseCaseProvider
    extends
        $FunctionalProvider<
          GenerateNextReturnNumberUseCase,
          GenerateNextReturnNumberUseCase,
          GenerateNextReturnNumberUseCase
        >
    with $Provider<GenerateNextReturnNumberUseCase> {
  const GenerateNextReturnNumberUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generateNextReturnNumberUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generateNextReturnNumberUseCaseHash();

  @$internal
  @override
  $ProviderElement<GenerateNextReturnNumberUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GenerateNextReturnNumberUseCase create(Ref ref) {
    return generateNextReturnNumberUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GenerateNextReturnNumberUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GenerateNextReturnNumberUseCase>(
        value,
      ),
    );
  }
}

String _$generateNextReturnNumberUseCaseHash() =>
    r'5413bac52f8b017225607fc170982d8659ee8c38';

@ProviderFor(validateReturnEligibilityUseCase)
const validateReturnEligibilityUseCaseProvider =
    ValidateReturnEligibilityUseCaseProvider._();

final class ValidateReturnEligibilityUseCaseProvider
    extends
        $FunctionalProvider<
          ValidateReturnEligibilityUseCase,
          ValidateReturnEligibilityUseCase,
          ValidateReturnEligibilityUseCase
        >
    with $Provider<ValidateReturnEligibilityUseCase> {
  const ValidateReturnEligibilityUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'validateReturnEligibilityUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$validateReturnEligibilityUseCaseHash();

  @$internal
  @override
  $ProviderElement<ValidateReturnEligibilityUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ValidateReturnEligibilityUseCase create(Ref ref) {
    return validateReturnEligibilityUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ValidateReturnEligibilityUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ValidateReturnEligibilityUseCase>(
        value,
      ),
    );
  }
}

String _$validateReturnEligibilityUseCaseHash() =>
    r'7f5d3b16dd9097a446b27b1cb0ebbc659c625538';

@ProviderFor(getReturnsStatsUseCase)
const getReturnsStatsUseCaseProvider = GetReturnsStatsUseCaseProvider._();

final class GetReturnsStatsUseCaseProvider
    extends
        $FunctionalProvider<
          GetReturnsStatsUseCase,
          GetReturnsStatsUseCase,
          GetReturnsStatsUseCase
        >
    with $Provider<GetReturnsStatsUseCase> {
  const GetReturnsStatsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getReturnsStatsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getReturnsStatsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetReturnsStatsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetReturnsStatsUseCase create(Ref ref) {
    return getReturnsStatsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetReturnsStatsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetReturnsStatsUseCase>(value),
    );
  }
}

String _$getReturnsStatsUseCaseHash() =>
    r'5227190d610f00eceda24709fcd4c03a122e34c8';

@ProviderFor(cashMovementRepository)
const cashMovementRepositoryProvider = CashMovementRepositoryProvider._();

final class CashMovementRepositoryProvider
    extends
        $FunctionalProvider<
          CashMovementRepository,
          CashMovementRepository,
          CashMovementRepository
        >
    with $Provider<CashMovementRepository> {
  const CashMovementRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cashMovementRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cashMovementRepositoryHash();

  @$internal
  @override
  $ProviderElement<CashMovementRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CashMovementRepository create(Ref ref) {
    return cashMovementRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CashMovementRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CashMovementRepository>(value),
    );
  }
}

String _$cashMovementRepositoryHash() =>
    r'e8f78aa21326d824ededc610f5f2be3924cecf14';

@ProviderFor(createCashMovementUseCase)
const createCashMovementUseCaseProvider = CreateCashMovementUseCaseProvider._();

final class CreateCashMovementUseCaseProvider
    extends
        $FunctionalProvider<
          CreateCashMovement,
          CreateCashMovement,
          CreateCashMovement
        >
    with $Provider<CreateCashMovement> {
  const CreateCashMovementUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createCashMovementUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createCashMovementUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateCashMovement> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateCashMovement create(Ref ref) {
    return createCashMovementUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateCashMovement value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateCashMovement>(value),
    );
  }
}

String _$createCashMovementUseCaseHash() =>
    r'11d7fff84da89960446d5bcbc08b9627e2672cba';
