import 'package:posventa/data/models/product_model.dart';
import 'package:posventa/data/models/product_tax_model.dart';
import 'package:posventa/data/models/product_variant_model.dart';
import 'package:posventa/data/models/tax_rate_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getProducts({
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

  Future<int> countProducts({
    String? query,
    int? departmentId,
    int? categoryId,
    int? brandId,
    int? supplierId,
    bool showInactive = false,
  });

  Future<ProductModel?> getProductById(int id);

  // Creates returns the ID
  Future<int> createProduct(ProductModel product);

  Future<void> batchCreateProducts(
    List<ProductModel> products, {
    required int defaultWarehouseId,
  });

  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(int id);

  Future<void> addTaxToProduct(ProductTaxModel productTax);
  Future<void> removeTaxFromProduct(int productId, int taxRateId);
  Future<List<ProductTaxModel>> getTaxesForProduct(int productId);
  Future<List<TaxRateModel>> getTaxRatesForProduct(int productId);

  Future<int> saveVariant(ProductVariantModel variant);
  Future<void> updateVariant(ProductVariantModel variant);

  Future<bool> isCodeUnique(String code, {int? excludeId});
  Future<bool> isNameUnique(String name, {int? excludeId});
  Future<bool> isBarcodeUnique(
    String barcode, {
    int? excludeId,
    int? excludeVariantId,
  });

  Stream<String> get tableUpdateStream;
}
