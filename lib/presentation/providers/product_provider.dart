import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:posventa/domain/entities/product.dart';

class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  ProductNotifier() : super(const AsyncValue.loading()) {
    _loadProducts();
  }

  final List<Product> _initialProducts = [
    const Product(
      id: 1,
      code: 'P001',
      name: 'Sample Product 1',
      departmentId: 1,
      categoryId: 1,
      unitOfMeasure: 'unit',
      costPriceCents: 1000,
      salePriceCents: 1500,
    ),
    const Product(
      id: 2,
      code: 'P002',
      name: 'Sample Product 2',
      departmentId: 1,
      categoryId: 2,
      unitOfMeasure: 'unit',
      costPriceCents: 1200,
      salePriceCents: 1800,
    ),
  ];

  Future<void> _loadProducts() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      state = AsyncValue.data(_initialProducts);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> createProduct(Product product) async {
    state.whenData((products) async {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final newProduct = product.copyWith(id: products.length + 1);
        state = AsyncValue.data([...products, newProduct]);
      } catch (e, s) {
        state = AsyncValue.error(e, s);
      }
    });
  }

  Future<void> updateProduct(Product product) async {
    state.whenData((products) async {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final updatedProducts = [
          for (final p in products)
            if (p.id == product.id) product else p,
        ];
        state = AsyncValue.data(updatedProducts);
      } catch (e, s) {
        state = AsyncValue.error(e, s);
      }
    });
  }
}

final productNotifierProvider =
    StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>((ref) {
      return ProductNotifier();
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
