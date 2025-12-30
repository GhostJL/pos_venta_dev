import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'product_provider.g.dart';

@riverpod
class ProductSearchQuery extends _$ProductSearchQuery {
  @override
  String build() {
    return '';
  }

  void setQuery(String query) {
    state = query;
  }
}

class ProductPaginationState {
  final List<Product> products;
  final bool hasMore;
  final bool isLoadingMore;
  final int totalCount;

  const ProductPaginationState({
    required this.products,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.totalCount = 0,
  });

  ProductPaginationState copyWith({
    List<Product>? products,
    bool? hasMore,
    bool? isLoadingMore,
    int? totalCount,
  }) {
    return ProductPaginationState(
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

@riverpod
class ProductList extends _$ProductList {
  static const int _pageSize = 20;

  @override
  FutureOr<ProductPaginationState> build() async {
    final query = ref.watch(productSearchQueryProvider);

    // Fetch count
    final countResult = await ref
        .read(productRepositoryProvider)
        .getProductsCount();
    final totalCount = countResult.fold((l) => 0, (r) => r);

    if (query.isEmpty) {
      final products = await _fetchProducts(offset: 0);
      return ProductPaginationState(
        products: products,
        hasMore: products.length >= _pageSize,
        totalCount: totalCount,
      );
    } else {
      final products = await _searchProducts(query);
      return ProductPaginationState(
        products: products,
        hasMore: false,
        totalCount: products
            .length, // For search, total is just what we found (assumed)
      );
    }
  }

  Future<List<Product>> _fetchProducts({required int offset}) async {
    final getAllProducts = ref.read(getAllProductsProvider);
    final result = await getAllProducts.call(limit: _pageSize, offset: offset);
    return result.fold(
      (failure) => throw failure.message,
      (products) => products,
    );
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null) return;

    // Check Guard
    if (state.isLoading || state.hasError || !currentState.hasMore) return;

    // Search Mode Guard
    if (ref.read(productSearchQueryProvider).isNotEmpty) return;

    // Set loading state without losing data
    // ignore: invalid_use_of_internal_member
    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    // Using copyWithPrevious wrapper for the outer AsyncValue doesn't help much if we modify internal boolean
    // But sticking to standard pattern:

    try {
      await Future.delayed(Duration.zero);

      final currentProducts = currentState.products;
      final newProducts = await _fetchProducts(offset: currentProducts.length);

      // Deduplicate
      final currentIds = currentProducts.map((p) => p.id).toSet();
      final uniqueNewProducts = newProducts
          .where((p) => !currentIds.contains(p.id))
          .toList();

      if (uniqueNewProducts.isEmpty) {
        state = AsyncData(
          currentState.copyWith(hasMore: false, isLoadingMore: false),
        );
        return;
      }

      state = AsyncData(
        ProductPaginationState(
          products: [...currentProducts, ...uniqueNewProducts],
          hasMore: newProducts.length >= _pageSize,
          isLoadingMore: false,
          totalCount: currentState.totalCount,
        ),
      );
    } catch (e, st) {
      // Revert loading flag on error, keep data
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
      // Or handle error explicitly? strict Riverpod would emit AsyncError but that clears data if not handled carefully.
      // For pagination, usually we want to keep list and show snackbar.
      // But to match previous behavior:
      state = AsyncError(e, st);
    }
  }

  Future<List<Product>> _searchProducts(String query) async {
    final searchProducts = ref.read(searchProductsProvider);
    final result = await searchProducts.call(query);
    return result.fold(
      (failure) => throw failure.message,
      (products) => products,
    );
  }

  void searchProducts(String query) {
    ref.read(productSearchQueryProvider.notifier).setQuery(query);
  }

  Future<void> addProduct(Product product) async {
    final result = await ref.read(createProductProvider).call(product);
    result.fold((failure) => throw failure.message, (success) {
      ref.invalidateSelf();
    });
  }

  Future<void> updateProduct(Product product) async {
    final result = await ref.read(updateProductProvider).call(product);
    result.fold((failure) => throw failure.message, (success) => null);
  }

  Future<void> deleteProduct(int id) async {
    final result = await ref.read(deleteProductProvider).call(id);
    result.fold((failure) => throw failure.message, (success) => null);
  }

  Future<void> toggleProductActive(int productId) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final product = currentState.products.firstWhere(
        (p) => p.id == productId,
      );
      final updatedProduct = product.copyWith(isActive: !product.isActive);
      await updateProduct(updatedProduct);
      // Optimistic update could go here but invalidation is safer for sync
    } catch (e) {
      rethrow;
    }
  }
}

// Alias for backward compatibility if needed, though usage should be updated to productListProvider
// Note: productListProvider is generated by riverpod_generator from ProductList class
final productNotifierProvider = productListProvider;

extension ProductCopyWith on Product {
  Product copyWith({
    int? id,
    String? code,
    String? name,
    String? description,
    int? departmentId,
    int? categoryId,
    int? brandId,
    int? supplierId,
    bool? isSoldByWeight,
    bool? isActive,
    List<ProductTax>? productTaxes,
    List<ProductVariant>? variants,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      departmentId: departmentId ?? this.departmentId,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      supplierId: supplierId ?? this.supplierId,
      isSoldByWeight: isSoldByWeight ?? this.isSoldByWeight,
      isActive: isActive ?? this.isActive,
      productTaxes: productTaxes ?? this.productTaxes,
      variants: variants ?? this.variants,
    );
  }
}

final productProvider = FutureProvider.family<Product?, int>((ref, id) async {
  final result = await ref.watch(productRepositoryProvider).getProductById(id);
  return result.fold((failure) => throw failure.message, (product) => product);
});
