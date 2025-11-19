import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/use_cases/product/get_all_products.dart';
import 'package:posventa/domain/use_cases/product/create_product.dart';
import 'package:posventa/domain/use_cases/product/update_product.dart';
import 'package:posventa/presentation/providers/providers.dart';

class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final GetAllProducts _getAllProducts;
  final CreateProduct _createProduct;
  final UpdateProduct _updateProduct;

  ProductNotifier({
    required GetAllProducts getAllProducts,
    required CreateProduct createProduct,
    required UpdateProduct updateProduct,
  }) : _getAllProducts = getAllProducts,
       _createProduct = createProduct,
       _updateProduct = updateProduct,
       super(const AsyncValue.loading()) {
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getAllProducts());
  }

  Future<void> addProduct(Product product) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _createProduct(product);
      return _getAllProducts();
    });
  }

  Future<void> updateProduct(Product product) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _updateProduct(product);
      return _getAllProducts();
    });
  }
}

final productNotifierProvider =
    StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>((ref) {
      final getAllProducts = ref.watch(getAllProductsProvider);
      final createProduct = ref.watch(createProductProvider);
      final updateProduct = ref.watch(updateProductProvider);

      return ProductNotifier(
        getAllProducts: getAllProducts,
        createProduct: createProduct,
        updateProduct: updateProduct,
      );
    });

extension ProductCopyWith on Product {
  Product copyWith({
    int? id,
    String? code,
    String? barcode,
    String? name,
    String? description,
    int? departmentId,
    int? categoryId,
    int? brandId,
    int? supplierId,
    String? unitOfMeasure,
    bool? isSoldByWeight,
    int? costPriceCents,
    int? salePriceCents,
    int? wholesalePriceCents,
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      description: description ?? this.description,
      departmentId: departmentId ?? this.departmentId,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      supplierId: supplierId ?? this.supplierId,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      isSoldByWeight: isSoldByWeight ?? this.isSoldByWeight,
      costPriceCents: costPriceCents ?? this.costPriceCents,
      salePriceCents: salePriceCents ?? this.salePriceCents,
      wholesalePriceCents: wholesalePriceCents ?? this.wholesalePriceCents,
      isActive: isActive ?? this.isActive,
    );
  }
}
