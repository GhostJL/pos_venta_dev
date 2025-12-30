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
    this.sortOrder = '',
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
AsyncValue<ProductPaginationState> filteredProducts(Ref ref) {
  final productsState = ref.watch(productListProvider);
  final filters = ref.watch(productFiltersProvider);
  final searchQuery = ref.watch(productSearchQueryProvider);

  // Helper to process list
  List<Product> processList(List<Product> rawList) {
    // 1. Filtrar por estado activo/inactivo
    final baseList = rawList.where((p) {
      if (filters.showInactive) return true;
      return p.isActive;
    }).toList();

    // 2. Aplicar el resto de filtros y búsqueda
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

  // Map the source state to the filtered state, preserving Loading/Error flags
  if (productsState.hasValue) {
    final originalState = productsState.value!;
    final filteredList = processList(originalState.products);

    // Create new state with filtered products but same metadata
    final newState = originalState.copyWith(products: filteredList);

    if (productsState.isLoading) {
      // Loading with data
      // ignore: invalid_use_of_internal_member
      return AsyncLoading<ProductPaginationState>().copyWithPrevious(
        AsyncData(newState),
      );
    }

    if (productsState.hasError) {
      // Error with data
      // ignore: invalid_use_of_internal_member
      return AsyncError<ProductPaginationState>(
        productsState.error!,
        productsState.stackTrace!,
        // ignore: invalid_use_of_internal_member
      ).copyWithPrevious(AsyncData(newState));
    }

    // Just data
    return AsyncData(newState);
  }

  // No data available yet
  if (productsState.isLoading) return const AsyncLoading();
  if (productsState.hasError) {
    return AsyncError(productsState.error!, productsState.stackTrace!);
  }

  return const AsyncLoading();
}
