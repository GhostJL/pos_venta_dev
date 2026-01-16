import 'package:flutter_test/flutter_test.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/services/stock_validator_service.dart';

void main() {
  late StockValidatorService service;
  late Product testProduct;

  setUp(() {
    service = StockValidatorService();
    // stock is int in Product entity, so we pass 10
    testProduct = Product(
      id: 1,
      code: 'TEST001',
      name: 'Test Product',
      stock: 10,
    );
  });

  // Re-writing the test file content entirely to be correct based on Product.dart reading
}
