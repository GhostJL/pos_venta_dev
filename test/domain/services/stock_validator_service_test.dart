import 'package:flutter_test/flutter_test.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/inventory_lot.dart';
import 'package:posventa/domain/services/stock_validator_service.dart';
import 'package:posventa/domain/repositories/inventory_lot_repository.dart';

class FakeInventoryLotRepository extends Fake
    implements InventoryLotRepository {
  @override
  Future<List<InventoryLot>> getAvailableLots(
    int productId,
    int warehouseId, {
    int? variantId,
  }) async {
    // Return mock data if needed for specific tests
    return [];
  }
}

void main() {
  late StockValidatorService service;
  late Product testProduct;

  setUp(() {
    service = StockValidatorService(FakeInventoryLotRepository());
    testProduct = Product(
      id: 1,
      code: 'TEST001',
      name: 'Test Product',
      stock: 10,
    );
  });

  test('initial test', () {
    expect(service, isNotNull);
  });
}
