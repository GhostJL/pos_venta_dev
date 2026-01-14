import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/sale_transaction.dart';
import 'package:posventa/domain/repositories/inventory_lot_repository.dart';
import 'package:posventa/domain/repositories/sale_repository.dart';
import 'package:posventa/domain/repositories/settings_repository.dart';

class CreateSaleUseCase {
  final SaleRepository _saleRepository;
  final InventoryLotRepository _lotRepository;
  final SettingsRepository _settingsRepository;

  CreateSaleUseCase(
    this._saleRepository,
    this._lotRepository,
    this._settingsRepository,
  );

  Future<int> call(Sale sale, {CreditUpdate? creditUpdate}) async {
    // Prepare transaction data
    final List<SaleItemLotDeduction> lotDeductions = [];
    final List<InventoryAdjustment> inventoryAdjustments = [];
    final List<InventoryMovement> movements = [];

    // Check inventory settings
    final settings = await _settingsRepository.getSettings();
    final useInventory = settings.useInventory;

    // Process each sale item
    for (final item in sale.items) {
      if (useInventory) {
        // Calculate quantity to deduct (handle variants)
        // With independent variant stock, we deduct the exact quantity sold
        double quantityToDeduct = item.quantity;

        // FIFO: Get available lots ordered by received_at ASC (oldest first)
        final availableLots = await _lotRepository.getAvailableLots(
          item.productId,
          sale.warehouseId,
          variantId: item.variantId,
        );

        double remainingToDeduct = quantityToDeduct;
        final List<LotDeduction> itemLotDeductions = [];

        // Deduct from lots using FIFO
        for (final lot in availableLots) {
          if (remainingToDeduct <= 0) break;

          final deductFromLot = remainingToDeduct < lot.quantity
              ? remainingToDeduct
              : lot.quantity;

          itemLotDeductions.add(
            LotDeduction(lotId: lot.id, quantityToDeduct: deductFromLot),
          );

          remainingToDeduct -= deductFromLot;
        }

        // Check if we have enough stock in lots
        if (remainingToDeduct > 0) {
          throw Exception(
            'Insufficient stock in lots for product ${item.productId}. '
            'Needed: $quantityToDeduct, Available: ${quantityToDeduct - remainingToDeduct}',
          );
        }

        lotDeductions.add(
          SaleItemLotDeduction(saleItem: item, deductions: itemLotDeductions),
        );

        // Prepare inventory adjustment
        inventoryAdjustments.add(
          InventoryAdjustment(
            productId: item.productId,
            variantId: item.variantId,
            warehouseId: sale.warehouseId,
            quantityToDeduct: quantityToDeduct,
          ),
        );

        // Prepare inventory movement
        // Note: quantityBefore/After will be filled by Repository in transaction
        movements.add(
          InventoryMovement(
            productId: item.productId,
            variantId: item.variantId,
            warehouseId: sale.warehouseId,
            movementType: MovementType.sale,
            quantity: -quantityToDeduct, // Negative for sale
            quantityBefore: 0, // Repository will update
            quantityAfter: 0, // Repository will update
            referenceType: 'sale',
            referenceId: null, // Will be set after sale is created
            reason: 'Sale #${sale.saleNumber}',
            performedBy: sale.cashierId,
            movementDate: DateTime.now(),
          ),
        );
      }
    }

    // Create transaction
    final transaction = SaleTransaction(
      sale: sale,
      lotDeductions: lotDeductions,
      inventoryAdjustments: inventoryAdjustments,
      movements: movements,
      creditUpdate: creditUpdate,
    );

    // Execute
    return await _saleRepository.executeSaleTransaction(transaction);
  }
}
