import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/domain/entities/sale_return.dart';
import 'package:posventa/domain/entities/sale_return_item.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/di/sale_di.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'return_processing_provider.g.dart';

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

  bool get isValid =>
      returnQuantity > 0 &&
      returnQuantity <= maxQuantity &&
      reason != null &&
      reason!.isNotEmpty;
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
        !selectedItems.values.any((item) => !item.isValid) &&
        !isProcessing;
  }
}

// ============================================================================
// Notifier
// ============================================================================

@riverpod
class ReturnProcessing extends _$ReturnProcessing {
  @override
  ReturnProcessingState build() => const ReturnProcessingState();

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
        returnQuantity: maxQuantity,
        maxQuantity: maxQuantity,
        reason:
            state.generalReason, // Pre-fill with general reason if available
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
      String? errorMessage;
      if (quantity > item.maxQuantity) {
        errorMessage = 'La cantidad no puede exceder ${item.maxQuantity}';
      } else if (quantity <= 0) {
        // Optional: errorMessage = 'La cantidad debe ser mayor a 0';
      }

      // Always update logic to ensure state matches UI input
      newItems[itemId] = item.copyWith(returnQuantity: quantity);

      state = state.copyWith(
        selectedItems: newItems,
        error: errorMessage,
        clearError: errorMessage == null,
      );
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
    // Also update all selected items that don't have a specific reason or have the same as previous general reason
    final newItems = Map<int, ReturnItemData>.from(state.selectedItems);
    bool changed = false;

    newItems.forEach((id, item) {
      // If item has no reason, or its reason matches the OLD general reason, update it
      if (item.reason == null || item.reason == state.generalReason) {
        newItems[id] = item.copyWith(reason: reason);
        changed = true;
      }
    });

    state = state.copyWith(
      generalReason: reason,
      selectedItems: changed ? newItems : null,
      clearError: true,
    );
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
      final createUseCase = ref.read(createSaleReturnUseCaseProvider);
      final generateNumberUseCase = ref.read(
        generateNextReturnNumberUseCaseProvider,
      );
      final authState = ref.read(authProvider);

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

      // Refresh returns list and sales list for real-time updates
      ref.invalidate(saleReturnsProvider);
      ref.invalidate(todayReturnsStatsProvider);

      // Invalidate sales streams to update sales history in real-time
      ref.invalidate(salesListStreamProvider);
      if (state.selectedSale?.id != null) {
        ref.invalidate(saleDetailStreamProvider(state.selectedSale!.id!));
      }

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

// Providers moved to sale_di.dart

// Returns List Provider - Now using StreamProvider for real-time updates
final saleReturnsProvider = StreamProvider.autoDispose<List<SaleReturn>>((ref) {
  final link = ref.keepAlive();

  final repository = ref.watch(saleReturnRepositoryProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

  return repository.getSaleReturnsStream(
    startDate: startOfDay,
    endDate: endOfDay,
  );
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

// Returns for a specific sale Provider - Now using StreamProvider for real-time updates
final saleReturnsForSaleProvider = Provider.family<List<SaleReturn>, int>((
  ref,
  saleId,
) {
  final asyncValue = ref.watch(allSaleReturnsProvider);

  final List<SaleReturn> allReturns =
      asyncValue.asData?.value ?? const <SaleReturn>[];

  return allReturns.where((r) => r.saleId == saleId).toList(growable: false);
});

// Returns Stats Provider
final returnsStatsProvider =
    FutureProvider.family<Map<String, dynamic>, DateTimeRange>((
      ref,
      dateRange,
    ) async {
      final useCase = ref.watch(getReturnsStatsUseCaseProvider);
      return await useCase(startDate: dateRange.start, endDate: dateRange.end);
    });
