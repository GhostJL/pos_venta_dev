import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/entities/tax_rate.dart';

abstract class ProductRepository {
  Future<int> createProduct(Product product);
  Future<Product?> getProductById(int id);
  Future<List<Product>> getAllProducts();
  Stream<List<Product>> getAllProductsStream();
  Future<List<Product>> searchProducts(String query);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(int id);

  Future<void> addTaxToProduct(ProductTax productTax);
  Future<void> removeTaxFromProduct(int productId, int taxRateId);
  Future<List<ProductTax>> getTaxesForProduct(int productId);
  Future<List<TaxRate>> getTaxRatesForProduct(int productId);

  Future<bool> isCodeUnique(String code, {int? excludeId});
  Future<bool> isBarcodeUnique(
    String barcode, {
    int? excludeId,
    int? excludeVariantId,
  });
}
