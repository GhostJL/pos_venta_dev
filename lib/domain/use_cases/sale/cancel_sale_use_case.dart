import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/entities/sale_transaction.dart';
import 'package:posventa/domain/repositories/sale_repository.dart';

class CancelSaleUseCase {
  final SaleRepository _repository;

  CancelSaleUseCase(this._repository);

  Future<void> call(int saleId, int userId, String reason) async {
    // Fetch the sale to get its details
    final sale = await _repository.getSaleById(saleId);
    if (sale == null) {
      throw Exception('Sale not found');
    }

    // Prepare transaction data
    final List<LotRestoration> lotRestorations = [];
    final List<InventoryAdjustment> inventoryAdjustments = [];
    final List<InventoryMovement> movements = [];

    // For each sale item, we need to restore the lots that were deducted
    // This information is stored in the sale_item_lots table
    // The Repository will need to query this table to get the lot deductions
    // For now, we'll prepare the structure and let the Repository handle the details

    // Note: The actual lot restoration details will be fetched by the Repository
    // from the sale_item_lots table during transaction execution.
    // We're just preparing the transaction metadata here.

    final transaction = SaleCancellationTransaction(
      saleId: saleId,
      userId: userId,
      reason: reason,
      cancelledAt: DateTime.now(),
      lotRestorations: lotRestorations, // Will be populated by Repository
      inventoryAdjustments:
          inventoryAdjustments, // Will be populated by Repository
      movements: movements, // Will be populated by Repository
    );

    await _repository.executeSaleCancellation(transaction);
  }
}
