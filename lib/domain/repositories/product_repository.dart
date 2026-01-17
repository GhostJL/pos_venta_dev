import 'package:fpdart/fpdart.dart';
import 'package:posventa/core/error/failures.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/tax_rate.dart';

abstract class ProductRepository {
  Future<Either<Failure, int>> createProduct(
    Product product, {
    required int userId,
  });

  Future<Either<Failure, void>> batchCreateProducts(
    List<Product> products, {
    required int defaultWarehouseId,
    required int userId,
  });

  Future<Either<Failure, Product?>> getProductById(int id);

  Future<Either<Failure, List<Product>>> getProducts({
    String? query,
    int? departmentId,
    int? categoryId,
    int? brandId,
    int? supplierId,
    bool showInactive = false,
    bool onlyWithStock = false,
    List<int>? ids,
    String? sortOrder,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, int>> countProducts({
    String? query,
    int? departmentId,
    int? categoryId,
    int? brandId,
    int? supplierId,
    bool showInactive = false,
  });

  Future<Either<Failure, void>> updateProduct(
    Product product, {
    required int userId,
  });

  Future<Either<Failure, void>> deleteProduct(int id, {required int userId});

  Future<Either<Failure, void>> addTaxToProduct(
    ProductTax productTax, {
    required int userId,
  });
  Future<Either<Failure, void>> removeTaxFromProduct(
    int productId,
    int taxRateId, {
    required int userId,
  });
  Future<Either<Failure, List<ProductTax>>> getTaxesForProduct(int productId);
  Future<Either<Failure, List<TaxRate>>> getTaxRatesForProduct(int productId);

  Future<Either<Failure, bool>> isCodeUnique(String code, {int? excludeId});
  Future<Either<Failure, bool>> isNameUnique(String name, {int? excludeId});
  Future<Either<Failure, bool>> isBarcodeUnique(
    String barcode, {
    int? excludeId,
    int? excludeVariantId,
  });

  Future<Either<Failure, int>> saveVariant(
    ProductVariant variant, {
    required int userId,
  });
  Future<Either<Failure, void>> updateVariant(
    ProductVariant variant, {
    required int userId,
  });
}
