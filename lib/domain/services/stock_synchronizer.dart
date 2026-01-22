import 'package:posventa/domain/repositories/inventory_repository.dart';
import 'package:posventa/domain/repositories/product_repository.dart';

class StockSynchronizer {
  final InventoryRepository _inventoryRepository;
  final ProductRepository _productRepository;

  StockSynchronizer(this._inventoryRepository, this._productRepository);

  /// Scans all products and recalculates their inventory based on lots.
  /// Returns a report of processed items.
  Future<Map<String, dynamic>> synchronizeAllProducts({
    Function(int processed, int total)? onProgress,
    bool Function()? shouldCancel,
  }) async {
    int processedCount = 0;
    int errorCount = 0;

    try {
      // 1. Count products to know loop bounds
      final countResult = await _productRepository.countProducts(
        showInactive: true,
      );

      int totalProducts = 0;
      countResult.fold(
        (failure) => throw Exception('Failed to count products'),
        (count) => totalProducts = count,
      );

      // 2. Process in batches
      const int batchSize = 50;
      for (int offset = 0; offset < totalProducts; offset += batchSize) {
        if (shouldCancel?.call() == true) {
          return {
            'success': false,
            'message': 'Cancelled by user',
            'processed': processedCount,
          };
        }

        final productsResult = await _productRepository.getProducts(
          limit: batchSize,
          offset: offset,
          showInactive: true,
        );

        await productsResult.fold(
          (failure) async {
            errorCount += batchSize; // Rough estimate
          },
          (products) async {
            for (final product in products) {
              if (shouldCancel?.call() == true) break;
              await _inventoryRepository.recalculateInventory(product.id!);
              processedCount++;
              onProgress?.call(processedCount, totalProducts);
            }
          },
        );
      }

      return {
        'total': totalProducts,
        'processed': processedCount,
        'errors': errorCount,
        'success': true,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
        'processed': processedCount,
      };
    }
  }

  Future<void> synchronizeProduct(int productId) async {
    await _inventoryRepository.recalculateInventory(productId);
  }
}
