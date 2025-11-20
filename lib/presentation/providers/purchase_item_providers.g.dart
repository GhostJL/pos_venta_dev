// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_item_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing purchase items state

@ProviderFor(PurchaseItemNotifier)
const purchaseItemProvider = PurchaseItemNotifierProvider._();

/// Notifier for managing purchase items state
final class PurchaseItemNotifierProvider
    extends $AsyncNotifierProvider<PurchaseItemNotifier, List<PurchaseItem>> {
  /// Notifier for managing purchase items state
  const PurchaseItemNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseItemProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseItemNotifierHash();

  @$internal
  @override
  PurchaseItemNotifier create() => PurchaseItemNotifier();
}

String _$purchaseItemNotifierHash() =>
    r'd4a88ccad1fa40ede8eb9ed62b795827dd4804f1';

/// Notifier for managing purchase items state

abstract class _$PurchaseItemNotifier
    extends $AsyncNotifier<List<PurchaseItem>> {
  FutureOr<List<PurchaseItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<PurchaseItem>>, List<PurchaseItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<PurchaseItem>>, List<PurchaseItem>>,
              AsyncValue<List<PurchaseItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider to get a single purchase item by ID

@ProviderFor(purchaseItemById)
const purchaseItemByIdProvider = PurchaseItemByIdFamily._();

/// Provider to get a single purchase item by ID

final class PurchaseItemByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<PurchaseItem?>,
          PurchaseItem?,
          FutureOr<PurchaseItem?>
        >
    with $FutureModifier<PurchaseItem?>, $FutureProvider<PurchaseItem?> {
  /// Provider to get a single purchase item by ID
  const PurchaseItemByIdProvider._({
    required PurchaseItemByIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'purchaseItemByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$purchaseItemByIdHash();

  @override
  String toString() {
    return r'purchaseItemByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PurchaseItem?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PurchaseItem?> create(Ref ref) {
    final argument = this.argument as int;
    return purchaseItemById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PurchaseItemByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$purchaseItemByIdHash() => r'2abcffedde384b6a6de7173580e1959f367e65ec';

/// Provider to get a single purchase item by ID

final class PurchaseItemByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PurchaseItem?>, int> {
  const PurchaseItemByIdFamily._()
    : super(
        retry: null,
        name: r'purchaseItemByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get a single purchase item by ID

  PurchaseItemByIdProvider call(int id) =>
      PurchaseItemByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'purchaseItemByIdProvider';
}

/// Provider to get purchase items by purchase ID

@ProviderFor(purchaseItemsByPurchaseId)
const purchaseItemsByPurchaseIdProvider = PurchaseItemsByPurchaseIdFamily._();

/// Provider to get purchase items by purchase ID

final class PurchaseItemsByPurchaseIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PurchaseItem>>,
          List<PurchaseItem>,
          FutureOr<List<PurchaseItem>>
        >
    with
        $FutureModifier<List<PurchaseItem>>,
        $FutureProvider<List<PurchaseItem>> {
  /// Provider to get purchase items by purchase ID
  const PurchaseItemsByPurchaseIdProvider._({
    required PurchaseItemsByPurchaseIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'purchaseItemsByPurchaseIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$purchaseItemsByPurchaseIdHash();

  @override
  String toString() {
    return r'purchaseItemsByPurchaseIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PurchaseItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PurchaseItem>> create(Ref ref) {
    final argument = this.argument as int;
    return purchaseItemsByPurchaseId(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PurchaseItemsByPurchaseIdProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$purchaseItemsByPurchaseIdHash() =>
    r'828eca6b49e0d2621571870be0b055e429dd2fef';

/// Provider to get purchase items by purchase ID

final class PurchaseItemsByPurchaseIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PurchaseItem>>, int> {
  const PurchaseItemsByPurchaseIdFamily._()
    : super(
        retry: null,
        name: r'purchaseItemsByPurchaseIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get purchase items by purchase ID

  PurchaseItemsByPurchaseIdProvider call(int purchaseId) =>
      PurchaseItemsByPurchaseIdProvider._(argument: purchaseId, from: this);

  @override
  String toString() => r'purchaseItemsByPurchaseIdProvider';
}

/// Provider to get purchase items by product ID

@ProviderFor(purchaseItemsByProductId)
const purchaseItemsByProductIdProvider = PurchaseItemsByProductIdFamily._();

/// Provider to get purchase items by product ID

final class PurchaseItemsByProductIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PurchaseItem>>,
          List<PurchaseItem>,
          FutureOr<List<PurchaseItem>>
        >
    with
        $FutureModifier<List<PurchaseItem>>,
        $FutureProvider<List<PurchaseItem>> {
  /// Provider to get purchase items by product ID
  const PurchaseItemsByProductIdProvider._({
    required PurchaseItemsByProductIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'purchaseItemsByProductIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$purchaseItemsByProductIdHash();

  @override
  String toString() {
    return r'purchaseItemsByProductIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PurchaseItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PurchaseItem>> create(Ref ref) {
    final argument = this.argument as int;
    return purchaseItemsByProductId(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PurchaseItemsByProductIdProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$purchaseItemsByProductIdHash() =>
    r'd5e92fc555d338dfbe855b0e00ca7cc484740cbe';

/// Provider to get purchase items by product ID

final class PurchaseItemsByProductIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PurchaseItem>>, int> {
  const PurchaseItemsByProductIdFamily._()
    : super(
        retry: null,
        name: r'purchaseItemsByProductIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get purchase items by product ID

  PurchaseItemsByProductIdProvider call(int productId) =>
      PurchaseItemsByProductIdProvider._(argument: productId, from: this);

  @override
  String toString() => r'purchaseItemsByProductIdProvider';
}

/// Provider to get purchase items by date range

@ProviderFor(purchaseItemsByDateRange)
const purchaseItemsByDateRangeProvider = PurchaseItemsByDateRangeFamily._();

/// Provider to get purchase items by date range

final class PurchaseItemsByDateRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PurchaseItem>>,
          List<PurchaseItem>,
          FutureOr<List<PurchaseItem>>
        >
    with
        $FutureModifier<List<PurchaseItem>>,
        $FutureProvider<List<PurchaseItem>> {
  /// Provider to get purchase items by date range
  const PurchaseItemsByDateRangeProvider._({
    required PurchaseItemsByDateRangeFamily super.from,
    required (DateTime, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'purchaseItemsByDateRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$purchaseItemsByDateRangeHash();

  @override
  String toString() {
    return r'purchaseItemsByDateRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<PurchaseItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PurchaseItem>> create(Ref ref) {
    final argument = this.argument as (DateTime, DateTime);
    return purchaseItemsByDateRange(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is PurchaseItemsByDateRangeProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$purchaseItemsByDateRangeHash() =>
    r'5fe06a9d497896bce8b457721b64dc033034f2d8';

/// Provider to get purchase items by date range

final class PurchaseItemsByDateRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PurchaseItem>>,
          (DateTime, DateTime)
        > {
  const PurchaseItemsByDateRangeFamily._()
    : super(
        retry: null,
        name: r'purchaseItemsByDateRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get purchase items by date range

  PurchaseItemsByDateRangeProvider call(DateTime startDate, DateTime endDate) =>
      PurchaseItemsByDateRangeProvider._(
        argument: (startDate, endDate),
        from: this,
      );

  @override
  String toString() => r'purchaseItemsByDateRangeProvider';
}

/// Provider to get recent purchase items

@ProviderFor(recentPurchaseItems)
const recentPurchaseItemsProvider = RecentPurchaseItemsFamily._();

/// Provider to get recent purchase items

final class RecentPurchaseItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PurchaseItem>>,
          List<PurchaseItem>,
          FutureOr<List<PurchaseItem>>
        >
    with
        $FutureModifier<List<PurchaseItem>>,
        $FutureProvider<List<PurchaseItem>> {
  /// Provider to get recent purchase items
  const RecentPurchaseItemsProvider._({
    required RecentPurchaseItemsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'recentPurchaseItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recentPurchaseItemsHash();

  @override
  String toString() {
    return r'recentPurchaseItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PurchaseItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PurchaseItem>> create(Ref ref) {
    final argument = this.argument as int;
    return recentPurchaseItems(ref, limit: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentPurchaseItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentPurchaseItemsHash() =>
    r'bc6af42447caa95ba0b6833ba5e962fb0eee882c';

/// Provider to get recent purchase items

final class RecentPurchaseItemsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PurchaseItem>>, int> {
  const RecentPurchaseItemsFamily._()
    : super(
        retry: null,
        name: r'recentPurchaseItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get recent purchase items

  RecentPurchaseItemsProvider call({int limit = 50}) =>
      RecentPurchaseItemsProvider._(argument: limit, from: this);

  @override
  String toString() => r'recentPurchaseItemsProvider';
}
