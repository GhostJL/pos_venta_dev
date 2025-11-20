import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart';

abstract class ProductRepository {
  Future<void> createProduct(Product product);
  Future<Product?> getProductById(int id);
  Future<List<Product>> getAllProducts();
  Future<List<Product>> searchProducts(String query);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(int id);

  Future<void> addTaxToProduct(ProductTax productTax);
  Future<void> removeTaxFromProduct(int productId, int taxRateId);
  Future<List<ProductTax>> getTaxesForProduct(int productId);
}
