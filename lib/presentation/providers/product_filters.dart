import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/core/utils/product_filter_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_filters.g.dart';

class ProductFilterState {
  final int? departmentId;
  final int? categoryId;
  final int? brandId;
  final int? supplierId;
  final String sortOrder;
  final bool showInactive;

  const ProductFilterState({
    this.departmentId,
    this.categoryId,
    this.brandId,
    this.supplierId,
    this.sortOrder = 'name',
    this.showInactive = false,
  });

  ProductFilterState copyWith({
    int? departmentId,
    int? categoryId,
    int? brandId,
    int? supplierId,
    String? sortOrder,
    bool? showInactive,
    bool clearDepartment = false,
    bool clearCategory = false,
    bool clearBrand = false,
    bool clearSupplier = false,
  }) {
    return ProductFilterState(
      departmentId: clearDepartment
          ? null
          : (departmentId ?? this.departmentId),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      brandId: clearBrand ? null : (brandId ?? this.brandId),
      supplierId: clearSupplier ? null : (supplierId ?? this.supplierId),
      sortOrder: sortOrder ?? this.sortOrder,
      showInactive: showInactive ?? this.showInactive,
    );
  }

  int get activeFilterCount {
    int count = 0;
    if (departmentId != null) count++;
    if (categoryId != null) count++;
    if (brandId != null) count++;
    if (supplierId != null) count++;
    return count;
  }
}

@riverpod
class ProductFilters extends _$ProductFilters {
  @override
  ProductFilterState build() {
    return const ProductFilterState();
  }

  void setDepartment(int? id) =>
      state = state.copyWith(departmentId: id, clearDepartment: id == null);
  void setCategory(int? id) =>
      state = state.copyWith(categoryId: id, clearCategory: id == null);
  void setBrand(int? id) =>
      state = state.copyWith(brandId: id, clearBrand: id == null);
  void setSupplier(int? id) =>
      state = state.copyWith(supplierId: id, clearSupplier: id == null);
  void setSortOrder(String order) => state = state.copyWith(sortOrder: order);
  void setShowInactive(bool show) => state = state.copyWith(showInactive: show);

  void clearAll() {
    state = const ProductFilterState(
      showInactive: false,
    ); // Reset keeping showInactive false or previous?
  }
}

@riverpod
Future<List<Product>> filteredProducts(Ref ref) async {
  final products = await ref.watch(productListProvider.future);
  final filters = ref.watch(productFiltersProvider);
  final searchQuery = ref.watch(productSearchQueryProvider);

  // 1. Filtrar por estado activo/inactivo
  final baseList = products.where((p) {
    if (filters.showInactive) return true;
    return p.isActive;
  }).toList();

  // 2. Aplicar el resto de filtros y búsqueda usando la utilidad
  return ProductFilterUtils.filterAndSort(
    products: baseList,
    searchQuery: searchQuery,
    departmentFilter: filters.departmentId,
    categoryFilter: filters.categoryId,
    brandFilter: filters.brandId,
    supplierFilter: filters.supplierId,
    sortOrder: filters.sortOrder,
  );
}
