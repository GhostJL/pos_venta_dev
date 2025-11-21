import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/presentation/providers/purchase_providers.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';

class PurchasesPage extends ConsumerStatefulWidget {
  const PurchasesPage({super.key});

  @override
  ConsumerState<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends ConsumerState<PurchasesPage> {
  PurchaseStatus? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final purchasesAsync = ref.watch(purchaseProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Compras')),
      floatingActionButton: hasManagePermission
          ? FloatingActionButton.extended(
              onPressed: () {
                context.push('/purchases/new');
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Nueva Compra'),
              tooltip: 'Crear Nueva Compra',
            )
          : null,
      body: Column(
        children: [
          // Status Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todas', null),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pendiente', PurchaseStatus.pending),
                  const SizedBox(width: 8),
                  _buildFilterChip('Recibida', PurchaseStatus.completed),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cancelada', PurchaseStatus.cancelled),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Purchase List
          Expanded(
            child: purchasesAsync.when(
              data: (purchases) {
                // Apply filter
                final filteredPurchases = _selectedFilter == null
                    ? purchases
                    : purchases
                          .where((p) => p.status == _selectedFilter)
                          .toList();

                if (filteredPurchases.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == null
                              ? 'No hay compras registradas'
                              : 'No hay compras ${_getStatusText(_selectedFilter!).toLowerCase()}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(purchaseProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPurchases.length,
                    itemBuilder: (context, index) {
                      final purchase = filteredPurchases[index];
                      return _PurchaseCard(purchase: purchase);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, PurchaseStatus? status) {
    final isSelected = _selectedFilter == status;
    Color? chipColor;

    if (status != null) {
      switch (status) {
        case PurchaseStatus.pending:
          chipColor = Colors.orange;
          break;
        case PurchaseStatus.completed:
          chipColor = Colors.green;
          break;
        case PurchaseStatus.cancelled:
          chipColor = Colors.red;
          break;
      }
    }

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? status : null;
        });
      },
      selectedColor: chipColor?.withAlpha(100),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? chipColor : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  String _getStatusText(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.pending:
        return 'PENDIENTE';
      case PurchaseStatus.completed:
        return 'RECIBIDA';
      case PurchaseStatus.cancelled:
        return 'CANCELADA';
    }
  }
}

class _PurchaseCard extends StatelessWidget {
  final Purchase purchase;

  const _PurchaseCard({required this.purchase});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isPending = purchase.status == PurchaseStatus.pending;
    final isCancelled = purchase.status == PurchaseStatus.cancelled;

    Color statusColor;
    String statusText;
    if (isPending) {
      statusColor = Colors.orange;
      statusText = 'PENDIENTE';
    } else if (isCancelled) {
      statusColor = Colors.red;
      statusText = 'CANCELADA';
    } else {
      statusColor = Colors.green;
      statusText = 'COMPLETADA';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.push('/purchases/${purchase.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    purchase.purchaseNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(100),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                purchase.supplierName ?? 'Proveedor Desconocido',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

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
                    dateFormat.format(purchase.purchaseDate),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Items count and Warehouse
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.list, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          '${purchase.items.length} producto(s)',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.warehouse_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Almacén #${purchase.warehouseId}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Divider(),
              const SizedBox(height: 8),

              // Totals
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${(purchase.totalCents / 100).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
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
