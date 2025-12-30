import 'package:fpdart/fpdart.dart';
import 'package:posventa/core/error/failures.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/tax_rate.dart';

abstract class ProductRepository {
  Future<Either<Failure, int>> createProduct(Product product);

  Future<Either<Failure, void>> batchCreateProducts(List<Product> products);

  Future<Either<Failure, Product?>> getProductById(int id);

  Future<Either<Failure, int>> getProductsCount();

  /// Get all products with optional pagination
  Future<Either<Failure, List<Product>>> getAllProducts({
    int? limit,
    int? offset,
  });

  Stream<Either<Failure, List<Product>>> getAllProductsStream({
    int? limit,
    int? offset,
  });

  Future<Either<Failure, List<Product>>> searchProducts(String query);

  Future<Either<Failure, void>> updateProduct(Product product);

  Future<Either<Failure, void>> deleteProduct(int id);

  Future<Either<Failure, void>> addTaxToProduct(ProductTax productTax);
  Future<Either<Failure, void>> removeTaxFromProduct(
    int productId,
    int taxRateId,
  );
  Future<Either<Failure, List<ProductTax>>> getTaxesForProduct(int productId);
  Future<Either<Failure, List<TaxRate>>> getTaxRatesForProduct(int productId);

  Future<Either<Failure, bool>> isCodeUnique(String code, {int? excludeId});
  Future<Either<Failure, bool>> isNameUnique(String name, {int? excludeId});
  Future<Either<Failure, bool>> isBarcodeUnique(
    String barcode, {
    int? excludeId,
    int? excludeVariantId,
  });

  Future<Either<Failure, int>> saveVariant(ProductVariant variant);
  Future<Either<Failure, void>> updateVariant(ProductVariant variant);
}
