import 'package:fpdart/fpdart.dart';
import 'package:posventa/core/error/exceptions.dart';
import 'package:posventa/core/error/failures.dart';
import 'package:posventa/data/datasources/product_local_datasource.dart';
import 'package:posventa/data/models/product_model.dart';
import 'package:posventa/data/models/product_tax_model.dart';
import 'package:posventa/data/models/product_variant_model.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/domain/repositories/product_repository.dart';
import 'package:posventa/domain/services/audit_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource dataSource;
  final AuditService auditService;

  ProductRepositoryImpl(this.dataSource, this.auditService);

  @override
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
  }) async {
    try {
      final products = await dataSource.getProducts(
        query: query,
        departmentId: departmentId,
        categoryId: categoryId,
        brandId: brandId,
        supplierId: supplierId,
        showInactive: showInactive,
        onlyWithStock: onlyWithStock,
        ids: ids,
        sortOrder: sortOrder,
        limit: limit,
        offset: offset,
      );
      return Right(products);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> countProducts({
    String? query,
    int? departmentId,
    int? categoryId,
    int? brandId,
    int? supplierId,
    bool showInactive = false,
  }) async {
    try {
      final count = await dataSource.countProducts(
        query: query,
        departmentId: departmentId,
        categoryId: categoryId,
        brandId: brandId,
        supplierId: supplierId,
        showInactive: showInactive,
      );
      return Right(count);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> createProduct(
    Product product, {
    required int userId,
  }) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      final id = await dataSource.createProduct(productModel);

      await auditService.logAction(
        action: 'create_product',
        module: 'catalog',
        details: 'Created product: ${product.name} (ID: $id)',
        userId: userId,
      );

      return Right(id);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> batchCreateProducts(
    List<Product> products, {
    required int defaultWarehouseId,
    required int userId,
  }) async {
    try {
      final productModels = products
          .map((p) => ProductModel.fromEntity(p))
          .toList();
      await dataSource.batchCreateProducts(
        productModels,
        defaultWarehouseId: defaultWarehouseId,
      );

      await auditService.logAction(
        action: 'batch_create_products',
        module: 'catalog',
        details: 'Batch created ${products.length} products',
        userId: userId,
      );

      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(
    int id, {
    required int userId,
  }) async {
    try {
      // Fetch product name for log before deletion (optional but good)
      // For now, just logging ID to save a read if not needed strictly
      await dataSource.deleteProduct(id);

      await auditService.logAction(
        action: 'delete_product',
        module: 'catalog',
        details: 'Deleted product ID: $id',
        userId: userId,
      );

      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product?>> getProductById(int id) async {
    try {
      final product = await dataSource.getProductById(id);
      return Right(product);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(
    Product product, {
    required int userId,
  }) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      await dataSource.updateProduct(productModel);

      await auditService.logAction(
        action: 'update_product',
        module: 'catalog',
        details: 'Updated product: ${product.name} (ID: ${product.id})',
        userId: userId,
      );

      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTaxToProduct(
    ProductTax productTax, {
    required int userId,
  }) async {
    try {
      final model = ProductTaxModel.fromEntity(productTax);
      await dataSource.addTaxToProduct(model);

      await auditService.logAction(
        action: 'add_product_tax',
        module: 'catalog',
        details:
            'Added tax (Rate ID: ${productTax.taxRateId}) to product (ID: ${productTax.productId})',
        userId: userId,
      );

      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductTax>>> getTaxesForProduct(
    int productId,
  ) async {
    try {
      final taxes = await dataSource.getTaxesForProduct(productId);
      return Right(taxes);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeTaxFromProduct(
    int productId,
    int taxRateId, {
    required int userId,
  }) async {
    try {
      await dataSource.removeTaxFromProduct(productId, taxRateId);

      await auditService.logAction(
        action: 'remove_product_tax',
        module: 'catalog',
        details:
            'Removed tax (Rate ID: $taxRateId) from product (ID: $productId)',
        userId: userId,
      );

      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaxRate>>> getTaxRatesForProduct(
    int productId,
  ) async {
    try {
      final rates = await dataSource.getTaxRatesForProduct(productId);
      return Right(rates);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isCodeUnique(
    String code, {
    int? excludeId,
  }) async {
    try {
      final result = await dataSource.isCodeUnique(code, excludeId: excludeId);
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isNameUnique(
    String name, {
    int? excludeId,
  }) async {
    try {
      final result = await dataSource.isNameUnique(name, excludeId: excludeId);
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isBarcodeUnique(
    String barcode, {
    int? excludeId,
    int? excludeVariantId,
  }) async {
    try {
      final result = await dataSource.isBarcodeUnique(
        barcode,
        excludeId: excludeId,
        excludeVariantId: excludeVariantId,
      );
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> saveVariant(
    ProductVariant variant, {
    required int userId,
  }) async {
    try {
      final model = ProductVariantModel.fromEntity(variant);
      final result = await dataSource.saveVariant(model);

      await auditService.logAction(
        action: 'save_variant',
        module: 'catalog',
        details: 'Saved variant: ${variant.variantName} (ID: $result)',
        userId: userId,
      );

      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateVariant(
    ProductVariant variant, {
    required int userId,
  }) async {
    try {
      final model = ProductVariantModel.fromEntity(variant);
      await dataSource.updateVariant(model);

      await auditService.logAction(
        action: 'update_variant',
        module: 'catalog',
        details: 'Updated variant: ${variant.variantName} (ID: ${variant.id})',
        userId: userId,
      );

      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
