import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/inventory_lot.dart';
import 'package:posventa/presentation/providers/inventory_lot_providers.dart';

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

  @override
  Widget build(BuildContext context) {
    final lotsAsync = _showOnlyAvailable
        ? ref.watch(availableLotsProvider(widget.productId, widget.warehouseId))
        : ref.watch(productLotsProvider(widget.productId, widget.warehouseId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productName ?? 'Lotes de Inventario'),
        elevation: 0,
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
      body: lotsAsync.when(
        data: (lots) {
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
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                          ? Colors.red
                          : isExpiringSoon
                          ? Colors.orange
                          : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Expira: ${dateFormat.format(lot.expirationDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isExpired
                            ? Colors.red
                            : isExpiringSoon
                            ? Colors.orange
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
