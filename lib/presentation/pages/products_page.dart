import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/brand_providers.dart';
import 'package:posventa/presentation/providers/category_providers.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/product_filter_sheet.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ProductsPageState createState() => ProductsPageState();
}

class ProductsPageState extends ConsumerState<ProductsPage> {
  String _searchQuery = '';
  int? _departmentFilter;
  int? _categoryFilter;
  int? _brandFilter;
  int? _supplierFilter;
  String _sortOrder = 'name';
  final TextEditingController _searchController = TextEditingController();

  int get _activeFilterCount {
    int count = 0;
    if (_departmentFilter != null) count++;
    if (_categoryFilter != null) count++;
    if (_brandFilter != null) count++;
    if (_supplierFilter != null) count++;
    return count;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openScanner() async {
    final result = await context.push<String>('/scanner');

    if (result != null && mounted) {
      setState(() {
        _searchController.text = result;
        _searchQuery = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productNotifierProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text('Filtros ($_activeFilterCount)'),
              selected: _activeFilterCount > 0,
              onSelected: (selected) {
                if (selected) {
                  _showFilterSheet();
                } else {
                  _clearFilters();
                }
              },
              backgroundColor: AppTheme.inputBackground,
              selectedColor: AppTheme.primary.withAlpha(50),
              checkmarkColor: AppTheme.primary,
              labelStyle: TextStyle(
                color: _activeFilterCount > 0
                    ? AppTheme.primary
                    : AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide.none,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nombre, código o código de barras',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                    ),
                    onPressed: _openScanner,
                    tooltip: 'Escanear código',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActiveFilters(),
            const SizedBox(height: 16),
            Expanded(
              child: products.when(
                data: (productList) {
                  var filteredList = _getFilteredAndSortedList(productList);

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: AppTheme.textSecondary.withAlpha(100),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No se encontraron productos',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = filteredList[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: AppTheme.borders.withAlpha(50),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.inventory_2_rounded,
                              color: AppTheme.primary,
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.background,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: AppTheme.borders,
                                      ),
                                    ),
                                    child: Text(
                                      product.code,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Monospace',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    product.unitOfMeasure,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${(product.salePriceCents / 100).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.more_vert_rounded),
                                onPressed: () => _showActions(context, product),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: hasManagePermission
          ? FloatingActionButton(
              onPressed: () {
                context.push('/products/form');
              },
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }

  Widget _buildActiveFilters() {
    final departments = ref.watch(departmentListProvider);
    final categories = ref.watch(categoryListProvider);
    final brands = ref.watch(brandListProvider);
    final suppliers = ref.watch(supplierListProvider);

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        if (_departmentFilter != null)
          departments.when(
            data: (list) {
              final name = list
                  .firstWhere((d) => d.id == _departmentFilter)
                  .name;
              return Chip(
                label: Text('Dpto: $name'),
                onDeleted: () => setState(() => _departmentFilter = null),
                backgroundColor: AppTheme.primary.withAlpha(20),
                labelStyle: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 12,
                ),
                deleteIconColor: AppTheme.primary,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (e, s) => const SizedBox(),
          ),
        if (_categoryFilter != null)
          categories.when(
            data: (list) {
              final name = list.firstWhere((c) => c.id == _categoryFilter).name;
              return Chip(
                label: Text('Cat: $name'),
                onDeleted: () => setState(() => _categoryFilter = null),
                backgroundColor: AppTheme.secondary.withAlpha(20),
                labelStyle: const TextStyle(
                  color: AppTheme.secondary,
                  fontSize: 12,
                ),
                deleteIconColor: AppTheme.secondary,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (e, s) => const SizedBox(),
          ),
        if (_brandFilter != null)
          brands.when(
            data: (list) {
              final name = list.firstWhere((b) => b.id == _brandFilter).name;
              return Chip(
                label: Text('Marca: $name'),
                onDeleted: () => setState(() => _brandFilter = null),
                backgroundColor: Colors.orange.withAlpha(20),
                labelStyle: const TextStyle(color: Colors.orange, fontSize: 12),
                deleteIconColor: Colors.orange,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (e, s) => const SizedBox(),
          ),
        if (_supplierFilter != null)
          suppliers.when(
            data: (list) {
              final name = list.firstWhere((s) => s.id == _supplierFilter).name;
              return Chip(
                label: Text('Prov: $name'),
                onDeleted: () => setState(() => _supplierFilter = null),
                backgroundColor: Colors.purple.withAlpha(20),
                labelStyle: const TextStyle(color: Colors.purple, fontSize: 12),
                deleteIconColor: Colors.purple,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (e, s) => const SizedBox(),
          ),
      ],
    );
  }

  List<Product> _getFilteredAndSortedList(List<Product> productList) {
    var filteredList = productList.where((p) {
      final searchLower = _searchQuery.toLowerCase();
      return (_searchQuery.isEmpty ||
              p.name.toLowerCase().contains(searchLower) ||
              p.code.toLowerCase().contains(searchLower) ||
              (p.barcode?.toLowerCase().contains(searchLower) ?? false) ||
              (p.description?.toLowerCase().contains(searchLower) ?? false)) &&
          (_departmentFilter == null || p.departmentId == _departmentFilter) &&
          (_categoryFilter == null || p.categoryId == _categoryFilter) &&
          (_brandFilter == null || p.brandId == _brandFilter) &&
          (_supplierFilter == null || p.supplierId == _supplierFilter);
    }).toList();

    filteredList.sort((a, b) {
      if (_sortOrder == 'name') {
        return a.name.compareTo(b.name);
      } else if (_sortOrder == 'price') {
        return a.salePriceCents.compareTo(b.salePriceCents);
      } else if (_sortOrder == 'created_at') {
        // Assuming Product entity has a createdAt field
        // return a.createdAt.compareTo(b.createdAt);
      }
      return 0;
    });

    return filteredList;
  }

  void _clearFilters() {
    setState(() {
      _departmentFilter = null;
      _categoryFilter = null;
      _brandFilter = null;
      _supplierFilter = null;
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ProductFilterSheet(
        departmentFilter: _departmentFilter,
        categoryFilter: _categoryFilter,
        brandFilter: _brandFilter,
        supplierFilter: _supplierFilter,
        sortOrder: _sortOrder,
        onDepartmentChanged: (val) => _departmentFilter = val,
        onCategoryChanged: (val) => _categoryFilter = val,
        onBrandChanged: (val) => _brandFilter = val,
        onSupplierChanged: (val) => _supplierFilter = val,
        onSortOrderChanged: (val) => _sortOrder = val,
        onClearFilters: _clearFilters,
        onApplyFilters: () => setState(() {}),
      ),
    );
  }

  void _showActions(BuildContext context, Product product) {
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              if (hasManagePermission)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                  title: const Text(
                    'Editar Producto',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    context.pop();
                    context.push('/products/form', extra: product);
                  },
                ),
              if (hasManagePermission) const SizedBox(height: 8),
              if (hasManagePermission)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.copy_rounded,
                      color: AppTheme.secondary,
                    ),
                  ),
                  title: const Text(
                    'Duplicar Producto',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    context.pop();
                    final newProduct = product.copyWith(
                      id: null,
                      name: '${product.name} (Copia)',
                    );
                    context.push('/products/form', extra: newProduct);
                  },
                ),
              if (hasManagePermission) const SizedBox(height: 8),
              if (hasManagePermission)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          (product.isActive ? AppTheme.error : AppTheme.success)
                              .withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.power_settings_new_rounded,
                      color: product.isActive
                          ? AppTheme.error
                          : AppTheme.success,
                    ),
                  ),
                  title: Text(
                    product.isActive
                        ? 'Desactivar Producto'
                        : 'Activar Producto',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () async {
                    context.pop();
                    try {
                      await ref
                          .read(productNotifierProvider.notifier)
                          .toggleProductActive(product.id!);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              !product.isActive
                                  ? 'Producto activado'
                                  : 'Producto desactivado',
                            ),
                            backgroundColor: !product.isActive
                                ? AppTheme.success
                                : AppTheme.textSecondary,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al cambiar estado: $e'),
                            backgroundColor: AppTheme.error,
                          ),
                        );
                      }
                    }
                  },
                ),
              if (hasManagePermission) const SizedBox(height: 8),
              if (hasManagePermission)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: AppTheme.error,
                    ),
                  ),
                  title: const Text(
                    'Eliminar Producto',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    context.pop();
                    _confirmDelete(context, product);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirmar Eliminación',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar el producto "${product.name}"?',
            style: const TextStyle(fontSize: 16),
          ),
          actionsPadding: const EdgeInsets.all(16),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Eliminar'),
              onPressed: () {
                ref
                    .read(productNotifierProvider.notifier)
                    .deleteProduct(product.id!);
                Navigator.of(dialogContext).pop();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto eliminado correctamente'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
