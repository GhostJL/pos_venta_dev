import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/inventory_lot.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/inventory_lot_providers.dart';
import 'package:posventa/presentation/providers/product_provider.dart';

class InventoryLotsPage extends ConsumerStatefulWidget {
  final int productId;
  final int warehouseId;
  final String? productName;

  const InventoryLotsPage({
    super.key,
    required this.productId,
    required this.warehouseId,
    this.productName,
  });

  @override
  ConsumerState<InventoryLotsPage> createState() => _InventoryLotsPageState();
}

class _InventoryLotsPageState extends ConsumerState<InventoryLotsPage> {
  bool _showOnlyAvailable = true;
  int? _selectedVariantId;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productName ?? 'Lotes de Inventario'),
        elevation: 0,
        leading: _selectedVariantId != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedVariantId = null;
                  });
                },
              )
            : null, // Default back button
        actions: [
          IconButton(
            icon: Icon(
              _showOnlyAvailable ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _showOnlyAvailable = !_showOnlyAvailable;
              });
            },
            tooltip: _showOnlyAvailable ? 'Mostrar todos' : 'Solo disponibles',
          ),
        ],
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (product) {
          // Case 1: Product has variants and none selected -> Show Variants List
          if (product?.variants != null &&
              product!.variants!.isNotEmpty &&
              _selectedVariantId == null) {
            return _buildVariantList(context, product.variants!);
          }

          // Case 2: Product has no variants OR Variant Selected -> Show Lots List
          return _buildLotsList(context);
        },
      ),
    );
  }

  Widget _buildVariantList(
    BuildContext context,
    List<ProductVariant> variants,
  ) {
    // Filter only Sales variants usually relevant for inventory stock view
    // But we should show all that have stock?
    // Let's show all and maybe indicate type.
    final salesVariants = variants
        .where((v) => v.type == VariantType.sales)
        .toList();

    if (salesVariants.isEmpty) {
      return const Center(child: Text("No hay variantes de venta disponibles"));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: salesVariants.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final variant = salesVariants[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                variant.type == VariantType.sales
                    ? Icons.sell
                    : Icons.inventory_2,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(
              variant.variantName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              variant.type == VariantType.sales
                  ? 'Variante de Venta'
                  : 'Variante de Compra',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              setState(() {
                _selectedVariantId = variant.id;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildLotsList(BuildContext context) {
    final lotsAsync = _showOnlyAvailable
        ? ref.watch(availableLotsProvider(widget.productId, widget.warehouseId))
        : ref.watch(productLotsProvider(widget.productId, widget.warehouseId));

    return lotsAsync.when(
      data: (allLots) {
        // Filter by selected variant if applicable
        final lots = _selectedVariantId != null
            ? allLots.where((l) => l.variantId == _selectedVariantId).toList()
            : allLots;

        if (lots.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay lotes disponibles',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lots.length,
          itemBuilder: (context, index) {
            final lot = lots[index];
            return _LotCard(
              lot: lot,
              onTap: () {
                context.push('/inventory/lot/${lot.id}');
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('Error: $error'),
          ],
        ),
      ),
    );
  }
}

class _LotCard extends StatelessWidget {
  final InventoryLot lot;
  final VoidCallback onTap;

  const _LotCard({required this.lot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isExpired =
        lot.expirationDate != null &&
        lot.expirationDate!.isBefore(DateTime.now());
    final isExpiringSoon =
        lot.expirationDate != null &&
        lot.expirationDate!.isAfter(DateTime.now()) &&
        lot.expirationDate!.isBefore(
          DateTime.now().add(const Duration(days: 30)),
        );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lot.lotNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: lot.quantity > 0
                          ? Theme.of(context).colorScheme.tertiary
                          : Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      lot.quantity > 0 ? 'Disponible' : 'Agotado',
                      style: TextStyle(
                        color: lot.quantity > 0
                            ? Theme.of(context).colorScheme.onTertiary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.inventory,
                      label: 'Cantidad',
                      value: lot.quantity.toStringAsFixed(2),
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.attach_money,
                      label: 'Costo Unit.',
                      value:
                          '\$${(lot.unitCostCents / 100).toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.calendar_today,
                      label: 'Recibido',
                      value: dateFormat.format(lot.receivedAt),
                      small: true,
                    ),
                  ),
                ],
              ),
              if (lot.expirationDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: isExpired
                          ? AppTheme.transactionFailed
                          : isExpiringSoon
                          ? AppTheme.transactionPending
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Expira: ${dateFormat.format(lot.expirationDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isExpired
                            ? AppTheme.transactionFailed
                            : isExpiringSoon
                            ? AppTheme.transactionPending
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: isExpired || isExpiringSoon
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool small;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: small ? 14 : 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: small ? 10 : 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: small ? 11 : 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
