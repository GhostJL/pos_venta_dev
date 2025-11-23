import 'package:posventa/domain/entities/product.dart';

class ProductFilterUtils {
  /// Filters and sorts a list of products based on the provided criteria
  static List<Product> filterAndSort({
    required List<Product> products,
    String searchQuery = '',
    int? departmentFilter,
    int? categoryFilter,
    int? brandFilter,
    int? supplierFilter,
    String sortOrder = 'name',
  }) {
    // Apply filters
    var filteredList = products.where((p) {
      final searchLower = searchQuery.toLowerCase();
      return (_matchesSearchQuery(p, searchLower)) &&
          (_matchesDepartment(p, departmentFilter)) &&
          (_matchesCategory(p, categoryFilter)) &&
          (_matchesBrand(p, brandFilter)) &&
          (_matchesSupplier(p, supplierFilter));
    }).toList();

    // Apply sorting
    filteredList.sort((a, b) => _compareProducts(a, b, sortOrder));

    return filteredList;
  }

  /// Checks if a product matches the search query
  static bool _matchesSearchQuery(Product product, String searchLower) {
    if (searchLower.isEmpty) return true;

    return product.name.toLowerCase().contains(searchLower) ||
        product.code.toLowerCase().contains(searchLower) ||
        (product.barcode?.toLowerCase().contains(searchLower) ?? false) ||
        (product.description?.toLowerCase().contains(searchLower) ?? false);
  }

  /// Checks if a product matches the department filter
  static bool _matchesDepartment(Product product, int? departmentFilter) {
    return departmentFilter == null || product.departmentId == departmentFilter;
  }

  /// Checks if a product matches the category filter
  static bool _matchesCategory(Product product, int? categoryFilter) {
    return categoryFilter == null || product.categoryId == categoryFilter;
  }

  /// Checks if a product matches the brand filter
  static bool _matchesBrand(Product product, int? brandFilter) {
    return brandFilter == null || product.brandId == brandFilter;
  }

  /// Checks if a product matches the supplier filter
  static bool _matchesSupplier(Product product, int? supplierFilter) {
    return supplierFilter == null || product.supplierId == supplierFilter;
  }

  /// Compares two products based on the sort order
  static int _compareProducts(Product a, Product b, String sortOrder) {
    switch (sortOrder) {
      case 'name':
        return a.name.compareTo(b.name);
      case 'price':
        return a.salePriceCents.compareTo(b.salePriceCents);
      case 'created_at':
        // Assuming Product entity has a createdAt field
        // return a.createdAt.compareTo(b.createdAt);
        return 0;
      default:
        return 0;
    }
  }

  /// Counts the number of active filters
  static int countActiveFilters({
    int? departmentFilter,
    int? categoryFilter,
    int? brandFilter,
    int? supplierFilter,
  }) {
    int count = 0;
    if (departmentFilter != null) count++;
    if (categoryFilter != null) count++;
    if (brandFilter != null) count++;
    if (supplierFilter != null) count++;
    return count;
  }
}
