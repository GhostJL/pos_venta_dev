import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:posventa/data/repositories/sale_return_repository_impl.dart';
import 'package:posventa/domain/repositories/sale_return_repository.dart';
import 'package:posventa/domain/use_cases/sale_return/create_sale_return_use_case.dart';
import 'package:posventa/domain/use_cases/sale_return/generate_next_return_number_use_case.dart';
import 'package:posventa/domain/use_cases/sale_return/get_sale_return_by_id_use_case.dart';
import 'package:posventa/domain/use_cases/sale_return/get_sale_returns_use_case.dart';
import 'package:posventa/domain/use_cases/sale_return/validate_return_eligibility_use_case.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/domain/entities/sale_return.dart';
import 'package:posventa/domain/entities/sale_return_item.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';

// ============================================================================
// Data Classes
// ============================================================================

class ReturnItemData {
  final SaleItem saleItem;
  final double returnQuantity;
  final double maxQuantity;
  final String? reason;

  ReturnItemData({
    required this.saleItem,
    required this.returnQuantity,
    required this.maxQuantity,
    this.reason,
  });

  ReturnItemData copyWith({
    SaleItem? saleItem,
    double? returnQuantity,
    double? maxQuantity,
    String? reason,
  }) {
    return ReturnItemData(
      saleItem: saleItem ?? this.saleItem,
      returnQuantity: returnQuantity ?? this.returnQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      reason: reason ?? this.reason,
    );
  }

  int get subtotalCents => (saleItem.unitPriceCents * returnQuantity).round();
  int get taxCents =>
      (saleItem.taxCents * (returnQuantity / saleItem.quantity)).round();
  int get totalCents => subtotalCents + taxCents;
}

class ReturnProcessingState {
  final Sale? selectedSale;
  final Map<int, ReturnItemData> selectedItems;
  final RefundMethod? refundMethod;
  final String? generalReason;
  final String? notes;
  final bool isProcessing;
  final String? error;
  final String? successMessage;

  const ReturnProcessingState({
    this.selectedSale,
    this.selectedItems = const {},
    this.refundMethod,
    this.generalReason,
    this.notes,
    this.isProcessing = false,
    this.error,
    this.successMessage,
  });

  ReturnProcessingState copyWith({
    Sale? selectedSale,
    Map<int, ReturnItemData>? selectedItems,
    RefundMethod? refundMethod,
    String? generalReason,
    String? notes,
    bool? isProcessing,
    String? error,
    String? successMessage,
    bool clearSale = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ReturnProcessingState(
      selectedSale: clearSale ? null : (selectedSale ?? this.selectedSale),
      selectedItems: selectedItems ?? this.selectedItems,
      refundMethod: refundMethod ?? this.refundMethod,
      generalReason: generalReason ?? this.generalReason,
      notes: notes ?? this.notes,
      isProcessing: isProcessing ?? this.isProcessing,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  int get totalSubtotalCents {
    return selectedItems.values.fold(
      0,
      (sum, item) => sum + item.subtotalCents,
    );
  }

  int get totalTaxCents {
    return selectedItems.values.fold(0, (sum, item) => sum + item.taxCents);
  }

  int get totalCents {
    return totalSubtotalCents + totalTaxCents;
  }

  bool get canProcess {
    return selectedSale != null &&
        selectedItems.isNotEmpty &&
        refundMethod != null &&
        generalReason != null &&
        generalReason!.trim().isNotEmpty &&
        !isProcessing;
  }
}

// ============================================================================
// State Notifier
// ============================================================================

class ReturnProcessingNotifier extends StateNotifier<ReturnProcessingState> {
  final Ref _ref;

  ReturnProcessingNotifier(this._ref) : super(const ReturnProcessingState());

  void selectSale(Sale sale) {
    state = state.copyWith(
      selectedSale: sale,
      selectedItems: {},
      clearError: true,
      clearSuccess: true,
    );
  }

  void toggleItem(SaleItem item, bool selected, double maxQuantity) {
    final newItems = Map<int, ReturnItemData>.from(state.selectedItems);

    if (selected) {
      newItems[item.id!] = ReturnItemData(
        saleItem: item,
        returnQuantity: item.quantity,
        maxQuantity: maxQuantity,
      );
    } else {
      newItems.remove(item.id!);
    }

    state = state.copyWith(selectedItems: newItems, clearError: true);
  }

  void updateItemQuantity(int itemId, double quantity) {
    final newItems = Map<int, ReturnItemData>.from(state.selectedItems);
    final item = newItems[itemId];

    if (item != null) {
      if (quantity > item.maxQuantity) {
        state = state.copyWith(
          error: 'La cantidad no puede exceder ${item.maxQuantity}',
        );
        return;
      }

      if (quantity <= 0) {
        state = state.copyWith(error: 'La cantidad debe ser mayor a 0');
        return;
      }

      newItems[itemId] = item.copyWith(returnQuantity: quantity);
      state = state.copyWith(selectedItems: newItems, clearError: true);
    }
  }

  void updateItemReason(int itemId, String reason) {
    final newItems = Map<int, ReturnItemData>.from(state.selectedItems);
    final item = newItems[itemId];

    if (item != null) {
      newItems[itemId] = item.copyWith(reason: reason);
      state = state.copyWith(selectedItems: newItems);
    }
  }

  void setRefundMethod(RefundMethod method) {
    state = state.copyWith(refundMethod: method, clearError: true);
  }

  void setGeneralReason(String reason) {
    state = state.copyWith(generalReason: reason, clearError: true);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  Future<bool> processReturn() async {
    if (!state.canProcess) {
      state = state.copyWith(
        error: 'Por favor complete todos los campos requeridos',
      );
      return false;
    }

    state = state.copyWith(isProcessing: true, clearError: true);

    try {
      final createUseCase = _ref.read(createSaleReturnUseCaseProvider);
      final generateNumberUseCase = _ref.read(
        generateNextReturnNumberUseCaseProvider,
      );
      final authState = _ref.read(authProvider);

      if (authState.user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Generate return number
      final returnNumber = await generateNumberUseCase();

      // Create return items
      final returnItems = state.selectedItems.values.map((itemData) {
        return SaleReturnItem(
          saleReturnId: 0, // Will be set by repository
          saleItemId: itemData.saleItem.id!,
          productId: itemData.saleItem.productId,
          quantity: itemData.returnQuantity,
          unitPriceCents: itemData.saleItem.unitPriceCents,
          subtotalCents: itemData.subtotalCents,
          taxCents: itemData.taxCents,
          totalCents: itemData.totalCents,
          reason: itemData.reason,
          createdAt: DateTime.now(),
        );
      }).toList();

      // Create sale return
      final saleReturn = SaleReturn(
        returnNumber: returnNumber,
        saleId: state.selectedSale!.id!,
        warehouseId: state.selectedSale!.warehouseId,
        customerId: state.selectedSale!.customerId,
        processedBy: authState.user!.id!,
        subtotalCents: state.totalSubtotalCents,
        taxCents: state.totalTaxCents,
        totalCents: state.totalCents,
        refundMethod: state.refundMethod!,
        reason: state.generalReason!,
        notes: state.notes,
        returnDate: DateTime.now(),
        createdAt: DateTime.now(),
        items: returnItems,
      );

      await createUseCase(saleReturn);

      state = state.copyWith(
        isProcessing: false,
        successMessage: 'Devolución procesada exitosamente: $returnNumber',
      );

      // Refresh returns list
      _ref.invalidate(saleReturnsProvider);
      _ref.invalidate(todayReturnsStatsProvider);

      return true;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Error al procesar devolución: ${e.toString()}',
      );
      return false;
    }
  }

  void reset() {
    state = const ReturnProcessingState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }
}

// ============================================================================
// Providers
// ============================================================================

// Repository Provider
final saleReturnRepositoryProvider = Provider<SaleReturnRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return SaleReturnRepositoryImpl(dbHelper);
});

// Use Case Providers
final createSaleReturnUseCaseProvider = Provider((ref) {
  final repository = ref.watch(saleReturnRepositoryProvider);
  return CreateSaleReturnUseCase(repository);
});

final getSaleReturnsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(saleReturnRepositoryProvider);
  return GetSaleReturnsUseCase(repository);
});

final getSaleReturnByIdUseCaseProvider = Provider((ref) {
  final repository = ref.watch(saleReturnRepositoryProvider);
  return GetSaleReturnByIdUseCase(repository);
});

final generateNextReturnNumberUseCaseProvider = Provider((ref) {
  final repository = ref.watch(saleReturnRepositoryProvider);
  return GenerateNextReturnNumberUseCase(repository);
});

final validateReturnEligibilityUseCaseProvider = Provider((ref) {
  final repository = ref.watch(saleReturnRepositoryProvider);
  return ValidateReturnEligibilityUseCase(repository);
});

// State Notifier Provider
final returnProcessingNotifierProvider =
    StateNotifierProvider.autoDispose<
      ReturnProcessingNotifier,
      ReturnProcessingState
    >((ref) => ReturnProcessingNotifier(ref));

// Returns List Provider
final saleReturnsProvider = FutureProvider.autoDispose<List<SaleReturn>>((
  ref,
) async {
  final useCase = ref.watch(getSaleReturnsUseCaseProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

  return await useCase(startDate: startOfDay, endDate: endOfDay);
});

// Today's Returns Stats Provider
final todayReturnsStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      final useCase = ref.watch(getSaleReturnsUseCaseProvider);
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final returns = await useCase(startDate: startOfDay, endDate: endOfDay);

      int totalReturns = returns.length;
      int totalAmountCents = returns.fold(
        0,
        (sum, ret) => sum + ret.totalCents,
      );

      return {
        'count': totalReturns,
        'totalCents': totalAmountCents,
        'total': totalAmountCents / 100.0,
      };
    });

// Returns for a specific sale Provider
final saleReturnsForSaleProvider = FutureProvider.family<List<SaleReturn>, int>(
  (ref, saleId) async {
    final repository = ref.watch(saleReturnRepositoryProvider);
    final allReturns = await repository.getSaleReturns();
    return allReturns.where((r) => r.saleId == saleId).toList();
  },
);
