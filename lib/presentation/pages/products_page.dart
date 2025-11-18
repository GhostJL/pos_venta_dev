
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/presentation/widgets/product_form_page.dart';
import 'package:posventa/presentation/providers/brand_providers.dart';
import 'package:posventa/presentation/providers/category_providers.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';

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

  int get _activeFilterCount {
    int count = 0;
    if (_departmentFilter != null) count++;
    if (_categoryFilter != null) count++;
    if (_brandFilter != null) count++;
    if (_supplierFilter != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productNotifierProvider);

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
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, código o descripción',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 10),
            _buildActiveFilters(),
            const SizedBox(height: 10),
            Expanded(
              child: products.when(
                data: (productList) {
                  var filteredList = _getFilteredAndSortedList(productList);

                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final product = filteredList[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Código: ${product.code}'),
                              if (product.barcode != null) Text('Código de barras: ${product.barcode!}'),
                              Text('Unidad: ${product.unitOfMeasure}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '€${(product.salePriceCents / 100).toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
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
            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ProductFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildActiveFilters() {
    final departments = ref.watch(departmentListProvider);
    final categories = ref.watch(categoryListProvider);
    final brands = ref.watch(brandListProvider);
    final suppliers = ref.watch(supplierListProvider);

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: [
        if (_departmentFilter != null)
          departments.when(
            data: (list) {
              final name = list.firstWhere((d) => d.id == _departmentFilter).name;
              return Chip(
                label: Text('Dpto: $name'),
                onDeleted: () => setState(() => _departmentFilter = null),
              );
            },
            loading: () => const Chip(label: Text('...')),
            error: (e, s) => const SizedBox(),
          ),
        if (_categoryFilter != null)
          categories.when(
            data: (list) {
              final name = list.firstWhere((c) => c.id == _categoryFilter).name;
              return Chip(
                label: Text('Cat: $name'),
                onDeleted: () => setState(() => _categoryFilter = null),
              );
            },
            loading: () => const Chip(label: Text('...')),
            error: (e, s) => const SizedBox(),
          ),
        if (_brandFilter != null)
          brands.when(
            data: (list) {
              final name = list.firstWhere((b) => b.id == _brandFilter).name;
              return Chip(
                label: Text('Marca: $name'),
                onDeleted: () => setState(() => _brandFilter = null),
              );
            },
            loading: () => const Chip(label: Text('...')),
            error: (e, s) => const SizedBox(),
          ),
        if (_supplierFilter != null)
          suppliers.when(
            data: (list) {
              final name = list.firstWhere((s) => s.id == _supplierFilter).name;
              return Chip(
                label: Text('Proveedor: $name'),
                onDeleted: () => setState(() => _supplierFilter = null),
              );
            },
            loading: () => const Chip(label: Text('...')),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            final departments = ref.watch(departmentListProvider);
            final categories = ref.watch(categoryListProvider);
            final brands = ref.watch(brandListProvider);
            final suppliers = ref.watch(supplierListProvider);

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Filtrar y Ordenar',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Dropdowns for filtering
                  departments.when(
                    data: (data) => _buildFilterDropdown(data, 'Departamento', _departmentFilter, (val) {
                      setSheetState(() => _departmentFilter = val);
                    }),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 16),
                  categories.when(
                    data: (data) => _buildFilterDropdown(data, 'Categoría', _categoryFilter, (val) {
                      setSheetState(() => _categoryFilter = val);
                    }),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 16),
                  brands.when(
                    data: (data) => _buildFilterDropdown(data, 'Marca', _brandFilter, (val) {
                      setSheetState(() => _brandFilter = val);
                    }),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 16),
                  suppliers.when(
                    data: (data) => _buildFilterDropdown(data, 'Proveedor', _supplierFilter, (val) {
                      setSheetState(() => _supplierFilter = val);
                    }),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 24),

                  // Sort Order
                  DropdownButtonFormField<String>(
                    value: _sortOrder,
                    decoration: const InputDecoration(
                      labelText: 'Ordenar por',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'name', child: Text('Nombre')),
                      DropdownMenuItem(value: 'price', child: Text('Precio')),
                      DropdownMenuItem(value: 'created_at', child: Text('Fecha')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setSheetState(() {
                          _sortOrder = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setSheetState(() {
                              _departmentFilter = null;
                              _categoryFilter = null;
                              _brandFilter = null;
                              _supplierFilter = null;
                            });
                          },
                          child: const Text('Limpiar todo'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {}); // This triggers the main page to rebuild with the new filters
                            Navigator.pop(context);
                          },
                          child: const Text('Aplicar Filtros'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterDropdown(
    List<dynamic> items,
    String hint,
    int? currentValue,
    void Function(int?) onChanged,
  ) {
    return DropdownButtonFormField<int>(
      value: currentValue,
      hint: Text(hint),
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e.id as int, child: Text(e.name as String)))
          .toList(),
      onChanged: onChanged,
    );
  }

  void _showActions(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductFormPage(product: product),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicar'),
              onTap: () {
                Navigator.pop(context);
                final newProduct = product.copyWith(id: null, name: '${product.name} (Copia)');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductFormPage(product: newProduct),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.power_settings_new),
              title: Text(product.isActive ? 'Desactivar' : 'Activar'),
              onTap: () {
                Navigator.pop(context);
                final updatedProduct = product.copyWith(isActive: !product.isActive);
                ref.read(productNotifierProvider.notifier).updateProduct(updatedProduct);
              },
            ),
          ],
        );
      },
    );
  }
}
