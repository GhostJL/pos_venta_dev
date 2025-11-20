import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/presentation/providers/purchase_item_providers.dart';

/// Page to display all purchase items across all purchases
/// Useful for POS inventory tracking and purchase history analysis
class PurchaseItemsPage extends ConsumerStatefulWidget {
  const PurchaseItemsPage({super.key});

  @override
  ConsumerState<PurchaseItemsPage> createState() => _PurchaseItemsPageState();
}

class _PurchaseItemsPageState extends ConsumerState<PurchaseItemsPage> {
  String _searchQuery = '';
  String _filterType = 'all'; // all, recent, by_date

  @override
  Widget build(BuildContext context) {
    final purchaseItemsAsync = ref.watch(purchaseItemProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artículos de Compra'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrar',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(purchaseItemProvider.notifier).refresh();
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por producto...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Items list
          Expanded(
            child: purchaseItemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay artículos de compra registrados',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter items based on search query
                final filteredItems = items.where((item) {
                  if (_searchQuery.isEmpty) return true;
                  return (item.productName ?? '').toLowerCase().contains(
                    _searchQuery,
                  );
                }).toList();

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron resultados',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return _PurchaseItemCard(item: item);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(purchaseItemProvider.notifier).refresh();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar Artículos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todos'),
              leading: Radio<String>(
                value: 'all',
                groupValue: _filterType,
                onChanged: (value) {
                  setState(() => _filterType = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Recientes (últimos 50)'),
              leading: Radio<String>(
                value: 'recent',
                groupValue: _filterType,
                onChanged: (value) {
                  setState(() => _filterType = value!);
                  Navigator.pop(context);
                  // TODO: Implement recent filter
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

/// Card widget to display a single purchase item
class _PurchaseItemCard extends StatelessWidget {
  final PurchaseItem item;

  const _PurchaseItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (item.id != null) {
            context.push('/purchase-items/${item.id}');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product name
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.productName ?? 'Producto Desconocido',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withAlpha(100),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ID: ${item.id ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quantity and unit
              Row(
                children: [
                  Icon(Icons.inventory, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '${item.quantity} ${item.unitOfMeasure}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(width: 24),
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${item.unitCost.toStringAsFixed(2)} c/u',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(item.createdAt),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),

              // Lot number if available
              if (item.lotNumber != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.qr_code, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Lote: ${item.lotNumber}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              // Totals
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      if (item.taxCents > 0)
                        Text(
                          'Impuestos: \$${item.tax.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    'TOTAL: \$${item.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
