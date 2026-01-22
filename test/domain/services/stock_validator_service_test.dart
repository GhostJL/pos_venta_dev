import 'package:flutter_test/flutter_test.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/repositories/inventory_repository.dart';
import 'package:posventa/domain/entities/inventory.dart';
import 'package:posventa/domain/services/stock_validator_service.dart';

class FakeInventoryRepository extends Fake implements InventoryRepository {
  @override
  Future<List<Inventory>> getInventoryByProduct(int productId) async {
    return [
      Inventory(
        id: 1,
        productId: productId,
        warehouseId: 1,
        quantityOnHand: 10.0,
        updatedAt: DateTime.now(),
      ),
    ];
  }
}

void main() {
  late StockValidatorService service;
  late Product testProduct;

  setUp(() {
    service = StockValidatorService(FakeInventoryRepository());
    testProduct = Product(
      id: 1,
      code: 'TEST001',
      name: 'Test Product',
      // stock: 10, // Removed
    );
  });

  test('initial test', () {
    expect(service, isNotNull);
  });
}
