import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/use_cases/product/get_all_products.dart';
import 'package:posventa/domain/use_cases/product/create_product.dart';
import 'package:posventa/domain/use_cases/product/update_product.dart';
import 'package:posventa/domain/use_cases/product/delete_product.dart';
import 'package:posventa/domain/use_cases/product/search_products.dart';
import 'package:posventa/presentation/providers/providers.dart';

class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final GetAllProducts _getAllProducts;
  final CreateProduct _createProduct;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;
  final SearchProducts _searchProducts;

  ProductNotifier({
    required GetAllProducts getAllProducts,
    required CreateProduct createProduct,
    required UpdateProduct updateProduct,
    required DeleteProduct deleteProduct,
    required SearchProducts searchProducts,
  }) : _getAllProducts = getAllProducts,
       _createProduct = createProduct,
       _updateProduct = updateProduct,
       _deleteProduct = deleteProduct,
       _searchProducts = searchProducts,
       super(const AsyncValue.loading()) {
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getAllProducts());
  }

  Future<void> reload() async {
    await _loadProducts();
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      await _loadProducts();
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _searchProducts(query));
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

  Future<void> deleteProduct(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _deleteProduct(id);
      return _getAllProducts();
    });
  }

  Future<void> toggleProductActive(int productId) async {
    final currentState = state.asData?.value;
    if (currentState == null) return;

    try {
      final product = currentState.firstWhere((p) => p.id == productId);
      final updatedProduct = product.copyWith(isActive: !product.isActive);
      await updateProduct(updatedProduct);
    } catch (e) {
      // Handle error or rethrow
      rethrow;
    }
  }
}

final productNotifierProvider =
    StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>((ref) {
      final getAllProducts = ref.watch(getAllProductsProvider);
      final createProduct = ref.watch(createProductProvider);
      final updateProduct = ref.watch(updateProductProvider);
      final deleteProduct = ref.watch(deleteProductProvider);
      final searchProducts = ref.watch(searchProductsProvider);

      return ProductNotifier(
        getAllProducts: getAllProducts,
        createProduct: createProduct,
        updateProduct: updateProduct,
        deleteProduct: deleteProduct,
        searchProducts: searchProducts,
      );
    });

final productListProvider = productNotifierProvider;

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
