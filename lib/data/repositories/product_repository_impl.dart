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

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource dataSource;

  ProductRepositoryImpl(this.dataSource);

  @override
  Stream<Either<Failure, List<Product>>> getAllProductsStream({
    int? limit,
    int? offset,
  }) async* {
    final result = await getAllProducts(limit: limit, offset: offset);
    yield result;

    await for (final table in dataSource.tableUpdateStream) {
      if (table == 'products' ||
          table == 'inventory' ||
          table == 'product_variants') {
        yield await getAllProducts(limit: limit, offset: offset);
      }
    }
  }

  @override
  Future<Either<Failure, int>> createProduct(Product product) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      final id = await dataSource.createProduct(productModel);
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
  }) async {
    try {
      final productModels = products
          .map((p) => ProductModel.fromEntity(p))
          .toList();
      await dataSource.batchCreateProducts(
        productModels,
        defaultWarehouseId: defaultWarehouseId,
      );
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(int id) async {
    try {
      await dataSource.deleteProduct(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getAllProducts({
    int? limit,
    int? offset,
  }) async {
    try {
      final products = await dataSource.getAllProducts(
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
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    try {
      final products = await dataSource.searchProducts(query);
      return Right(products);
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
  Future<Either<Failure, void>> updateProduct(Product product) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      await dataSource.updateProduct(productModel);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTaxToProduct(ProductTax productTax) async {
    try {
      final model = ProductTaxModel.fromEntity(productTax);
      await dataSource.addTaxToProduct(model);
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
    int taxRateId,
  ) async {
    try {
      await dataSource.removeTaxFromProduct(productId, taxRateId);
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
  Future<Either<Failure, int>> saveVariant(ProductVariant variant) async {
    try {
      final model = ProductVariantModel.fromEntity(variant);
      final result = await dataSource.saveVariant(model);
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateVariant(ProductVariant variant) async {
    try {
      final model = ProductVariantModel.fromEntity(variant);
      await dataSource.updateVariant(model);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getProductsCount() async {
    try {
      final count = await dataSource.countProducts();
      return Right(count);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
