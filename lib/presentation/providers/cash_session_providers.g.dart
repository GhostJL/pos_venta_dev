// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_session_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(warehouseList)
const warehouseListProvider = WarehouseListProvider._();

final class WarehouseListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Warehouse>>,
          List<Warehouse>,
          FutureOr<List<Warehouse>>
        >
    with $FutureModifier<List<Warehouse>>, $FutureProvider<List<Warehouse>> {
  const WarehouseListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'warehouseListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$warehouseListHash();

  @$internal
  @override
  $FutureProviderElement<List<Warehouse>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Warehouse>> create(Ref ref) {
    return warehouseList(ref);
  }
}

String _$warehouseListHash() => r'14f30f98d34d88cea3c7af24e66353df78c8e37e';

@ProviderFor(cashSessionList)
const cashSessionListProvider = CashSessionListFamily._();

final class CashSessionListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CashSession>>,
          List<CashSession>,
          FutureOr<List<CashSession>>
        >
    with
        $FutureModifier<List<CashSession>>,
        $FutureProvider<List<CashSession>> {
  const CashSessionListProvider._({
    required CashSessionListFamily super.from,
    required CashSessionFilter super.argument,
  }) : super(
         retry: null,
         name: r'cashSessionListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cashSessionListHash();

  @override
  String toString() {
    return r'cashSessionListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CashSession>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CashSession>> create(Ref ref) {
    final argument = this.argument as CashSessionFilter;
    return cashSessionList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CashSessionListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cashSessionListHash() => r'7f6bf4bca5ce5c3db12185210674735f46e19575';

final class CashSessionListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<CashSession>>,
          CashSessionFilter
        > {
  const CashSessionListFamily._()
    : super(
        retry: null,
        name: r'cashSessionListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CashSessionListProvider call(CashSessionFilter filter) =>
      CashSessionListProvider._(argument: filter, from: this);

  @override
  String toString() => r'cashSessionListProvider';
}

@ProviderFor(cashSessionMovements)
const cashSessionMovementsProvider = CashSessionMovementsFamily._();

final class CashSessionMovementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CashMovement>>,
          List<CashMovement>,
          FutureOr<List<CashMovement>>
        >
    with
        $FutureModifier<List<CashMovement>>,
        $FutureProvider<List<CashMovement>> {
  const CashSessionMovementsProvider._({
    required CashSessionMovementsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'cashSessionMovementsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cashSessionMovementsHash();

  @override
  String toString() {
    return r'cashSessionMovementsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CashMovement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CashMovement>> create(Ref ref) {
    final argument = this.argument as int;
    return cashSessionMovements(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CashSessionMovementsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cashSessionMovementsHash() =>
    r'0ad1ae54143ebb8db3ac7ca7471821bf3224d358';

final class CashSessionMovementsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CashMovement>>, int> {
  const CashSessionMovementsFamily._()
    : super(
        retry: null,
        name: r'cashSessionMovementsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CashSessionMovementsProvider call(int sessionId) =>
      CashSessionMovementsProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'cashSessionMovementsProvider';
}

@ProviderFor(cashSessionPayments)
const cashSessionPaymentsProvider = CashSessionPaymentsFamily._();

final class CashSessionPaymentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SalePayment>>,
          List<SalePayment>,
          FutureOr<List<SalePayment>>
        >
    with
        $FutureModifier<List<SalePayment>>,
        $FutureProvider<List<SalePayment>> {
  const CashSessionPaymentsProvider._({
    required CashSessionPaymentsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'cashSessionPaymentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cashSessionPaymentsHash();

  @override
  String toString() {
    return r'cashSessionPaymentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SalePayment>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SalePayment>> create(Ref ref) {
    final argument = this.argument as int;
    return cashSessionPayments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CashSessionPaymentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cashSessionPaymentsHash() =>
    r'bc9d1b61ca743ab976b6a848b4d1b6aed4361dbb';

final class CashSessionPaymentsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SalePayment>>, int> {
  const CashSessionPaymentsFamily._()
    : super(
        retry: null,
        name: r'cashSessionPaymentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CashSessionPaymentsProvider call(int sessionId) =>
      CashSessionPaymentsProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'cashSessionPaymentsProvider';
}

@ProviderFor(allCashMovements)
const allCashMovementsProvider = AllCashMovementsFamily._();

final class AllCashMovementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CashMovement>>,
          List<CashMovement>,
          FutureOr<List<CashMovement>>
        >
    with
        $FutureModifier<List<CashMovement>>,
        $FutureProvider<List<CashMovement>> {
  const AllCashMovementsProvider._({
    required AllCashMovementsFamily super.from,
    required CashMovementFilter super.argument,
  }) : super(
         retry: null,
         name: r'allCashMovementsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$allCashMovementsHash();

  @override
  String toString() {
    return r'allCashMovementsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CashMovement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CashMovement>> create(Ref ref) {
    final argument = this.argument as CashMovementFilter;
    return allCashMovements(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AllCashMovementsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$allCashMovementsHash() => r'c47f83dae6929ca132b194b835119aa7ff31f09d';

final class AllCashMovementsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<CashMovement>>,
          CashMovementFilter
        > {
  const AllCashMovementsFamily._()
    : super(
        retry: null,
        name: r'allCashMovementsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AllCashMovementsProvider call(CashMovementFilter filter) =>
      AllCashMovementsProvider._(argument: filter, from: this);

  @override
  String toString() => r'allCashMovementsProvider';
}

@ProviderFor(cashSessionDetail)
const cashSessionDetailProvider = CashSessionDetailFamily._();

final class CashSessionDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<CashSessionDetail>,
          CashSessionDetail,
          FutureOr<CashSessionDetail>
        >
    with
        $FutureModifier<CashSessionDetail>,
        $FutureProvider<CashSessionDetail> {
  const CashSessionDetailProvider._({
    required CashSessionDetailFamily super.from,
    required CashSession super.argument,
  }) : super(
         retry: null,
         name: r'cashSessionDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cashSessionDetailHash();

  @override
  String toString() {
    return r'cashSessionDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CashSessionDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CashSessionDetail> create(Ref ref) {
    final argument = this.argument as CashSession;
    return cashSessionDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CashSessionDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cashSessionDetailHash() => r'6ee486bffe5ba3792be7fee4a83a449ac4ec0e33';

final class CashSessionDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CashSessionDetail>, CashSession> {
  const CashSessionDetailFamily._()
    : super(
        retry: null,
        name: r'cashSessionDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CashSessionDetailProvider call(CashSession session) =>
      CashSessionDetailProvider._(argument: session, from: this);

  @override
  String toString() => r'cashSessionDetailProvider';
}
