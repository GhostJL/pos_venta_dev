import 'package:posventa/domain/entities/inventory_lot.dart';
import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/entities/purchase_reception_item.dart';
import 'package:posventa/domain/entities/purchase_reception_transaction.dart';
import 'package:posventa/domain/repositories/product_repository.dart';
import 'package:posventa/domain/repositories/purchase_repository.dart';
import 'package:posventa/domain/entities/product_variant.dart';

/// Use case for receiving a purchase and updating inventory
/// This is the critical process that:
/// 1. Updates purchase status to 'completed'
/// 2. Sets received_date and received_by
/// 3. Updates inventory stock (quantity_on_hand)
/// 4. Creates inventory movements (Kardex)
/// 5. Updates product cost_price_cents (Last Cost policy)
class ReceivePurchaseUseCase {
  final PurchaseRepository _purchaseRepository;
  final ProductRepository _productRepository;

  ReceivePurchaseUseCase(this._purchaseRepository, this._productRepository);

  /// Receive a purchase by ID
  /// [purchaseId] - The ID of the purchase to receive
  /// [items] - List of items to receive with their details
  /// [receivedBy] - The user ID who is receiving the purchase
  Future<void> call(
    int purchaseId,
    List<PurchaseReceptionItem> itemsToReceive,
    int receivedBy,
  ) async {
    // 1. Get purchase details
    final purchase = await _purchaseRepository.getPurchaseById(purchaseId);
    if (purchase == null) {
      throw Exception('Purchase not found');
    }

    final warehouseId = purchase.warehouseId;
    final purchaseItemsMap = {for (var item in purchase.items) item.id!: item};

    final List<PurchaseItemUpdate> itemUpdates = [];
    final List<InventoryLot> newLots = [];
    final List<InventoryAdjustment> inventoryAdjustments = [];
    final List<InventoryMovement> movements = [];
    final List<ProductVariantUpdate> variantUpdates = [];

    bool allItemsCompleted = true;

    // Track received quantities to check completion status
    final Map<int, double> receivedQuantities = {};
    for (var item in purchase.items) {
      if (item.id != null) {
        receivedQuantities[item.id!] = item.quantityReceived;
      }
    }

    // 2. Process each item to receive
    for (final receptionItem in itemsToReceive) {
      final itemId = receptionItem.itemId;
      final quantityToReceive = receptionItem.quantity;
      final lotNumber = receptionItem.lotNumber;
      final expirationDate = receptionItem.expirationDate;

      if (!purchaseItemsMap.containsKey(itemId)) {
        continue;
      }

      final itemData = purchaseItemsMap[itemId]!;
      final productId = itemData.productId;
      final variantId = itemData.variantId;
      final quantityOrdered = itemData.quantity;
      final quantityReceivedSoFar = receivedQuantities[itemId] ?? 0.0;
      final unitCostCents = itemData.unitCostCents;

      // Validate quantity
      if (quantityReceivedSoFar + quantityToReceive > quantityOrdered) {
        throw Exception(
          'Cannot receive more than ordered. Item ID: $itemId, Ordered: $quantityOrdered, Received: $quantityReceivedSoFar, Trying to receive: $quantityToReceive',
        );
      }

      // Update local tracker
      receivedQuantities[itemId] = quantityReceivedSoFar + quantityToReceive;

      // --- LOGIC FOR LINKED VARIANTS ---
      int? targetVariantId = variantId;
      double adjustedQuantity = quantityToReceive;
      int adjustedUnitCostCents = unitCostCents;

      if (variantId != null) {
        final productResult = await _productRepository.getProductById(
          productId,
        );

        // Handle Either
        await productResult.fold(
          (failure) async => throw Exception(
            'Failed to fetch product for variant logic: ${failure.message}',
          ),
          (product) async {
            final variant = product?.variants
                ?.where((v) => v.id == variantId)
                .firstOrNull;

            if (variant != null) {
              // Apply linking logic
              if (variant.type == VariantType.purchase &&
                  variant.linkedVariantId != null) {
                targetVariantId = variant.linkedVariantId;
                // Conversion Factor: variant.conversionFactor (e.g., 12 for a box of 12)
                final conversionFactor = variant.conversionFactor;

                if (conversionFactor > 0) {
                  adjustedQuantity = quantityToReceive * conversionFactor;
                  // Cost per unit = Cost per pack / items per pack
                  adjustedUnitCostCents = (unitCostCents / conversionFactor)
                      .round();
                }
              }
            }
          },
        );
      }

      // 2a. Create Inventory Lot (Using Adjusted Values)
      final totalCostCents = (adjustedUnitCostCents * adjustedQuantity).toInt();

      final newLot = InventoryLot(
        id: 0,
        productId: productId,
        variantId: targetVariantId, // Use target variant (Sales)
        warehouseId: warehouseId,
        lotNumber: lotNumber,
        quantity: adjustedQuantity, // Use adjusted quantity
        unitCostCents: adjustedUnitCostCents, // Use adjusted cost
        totalCostCents: totalCostCents,
        expirationDate: expirationDate,
        receivedAt: DateTime.now(),
      );

      newLots.add(newLot);

      // 2b. Prepare Item Update (Tracks RAW purchase reception status)
      itemUpdates.add(
        PurchaseItemUpdate(
          itemId: itemId,
          quantityReceived: quantityReceivedSoFar + quantityToReceive,
          newLot: newLot,
        ),
      );

      // 2c. Prepare Inventory Adjustment (Using Adjusted Values)
      inventoryAdjustments.add(
        InventoryAdjustment(
          productId: productId,
          warehouseId: warehouseId,
          variantId: targetVariantId,
          quantityToAdd: adjustedQuantity, // Adjusted
        ),
      );

      // 2d. Prepare Inventory Movement (Using Adjusted Values)
      movements.add(
        InventoryMovement(
          productId: productId,
          variantId: targetVariantId,
          warehouseId: warehouseId,
          movementType: MovementType.purchase,
          quantity: adjustedQuantity, // Adjusted
          quantityBefore: 0,
          quantityAfter: 0,
          referenceType: 'purchase',
          referenceId: purchaseId,
          reason:
              'Purchase received - Lot: $lotNumber${targetVariantId != null ? " (Variant ID: $targetVariantId)" : ""}',
          performedBy: receivedBy,
          movementDate: DateTime.now(),
        ),
      );

      // 2e. Update Product Variant Cost
      if (targetVariantId != null) {
        variantUpdates.add(
          ProductVariantUpdate(
            variantId: targetVariantId!,
            newCostPriceCents: adjustedUnitCostCents,
          ),
        );
      }
    }

    // 3. Check completion status
    for (var item in purchase.items) {
      final received = receivedQuantities[item.id!] ?? 0.0;
      if (received < item.quantity) {
        allItemsCompleted = false;
        break;
      }
    }

    final newStatus = allItemsCompleted ? 'completed' : 'partial';

    // 4. Construct Transaction
    final transaction = PurchaseReceptionTransaction(
      purchaseId: purchaseId,
      newStatus: newStatus,
      receivedBy: receivedBy,
      receivedDate: DateTime.now(),
      itemUpdates: itemUpdates,
      newLots: newLots,
      inventoryAdjustments: inventoryAdjustments,
      movements: movements,
      variantUpdates: variantUpdates,
    );

    // 5. Execute
    await _purchaseRepository.executePurchaseReception(transaction);
  }
}
