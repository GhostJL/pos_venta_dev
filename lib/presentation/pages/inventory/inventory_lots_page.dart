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
  final int? variantId;

  const InventoryLotsPage({
    super.key,
    required this.productId,
    required this.warehouseId,
    this.productName,
    this.variantId,
  });

  @override
  ConsumerState<InventoryLotsPage> createState() => _InventoryLotsPageState();
}

class _InventoryLotsPageState extends ConsumerState<InventoryLotsPage> {
  bool _showOnlyAvailable = true;

  @override
  Widget build(BuildContext context) {
    // We strictly assume we are here for a specific product context.
    // If variantId is provided, we filter by it.
    // We removed the 'Variant List' screen logic as requested.

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.productName ?? 'Lotes de Inventario'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        // Standard back button will pop to previous screen (InventoryPage)
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
      body: _buildLotsList(context),
    );
  }

  Widget _buildLotsList(BuildContext context) {
    final lotsAsync = _showOnlyAvailable
        ? ref.watch(availableLotsProvider(widget.productId, widget.warehouseId))
        : ref.watch(productLotsProvider(widget.productId, widget.warehouseId));
    final theme = Theme.of(context);

    return lotsAsync.when(
      data: (allLots) {
        final lots = widget.variantId != null
            ? allLots.where((l) => l.variantId == widget.variantId).toList()
            : allLots;

        if (lots.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_rounded,
                  size: 64,
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sin lotes registrados',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Use Cards for very small screens, Table for everything else
            if (constraints.maxWidth < 600) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: lots.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _LotCard(
                  lot: lots[index],
                  onTap: () => context.push('/inventory/lot/${lots[index].id}'),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  dataRowMinHeight: 52,
                  dataRowMaxHeight: 52,
                  showCheckboxColumn: false,
                  columnSpacing: 24,
                  horizontalMargin: 24,
                  columns: const [
                    DataColumn(label: Text('LOTE / ID')),
                    DataColumn(label: Text('RECEPCIÓN')),
                    DataColumn(label: Text('VENCIMIENTO')),
                    DataColumn(label: Text('COSTO U.')),
                    DataColumn(numeric: true, label: Text('CANTIDAD')),
                    DataColumn(label: Text('ESTADO')),
                  ],
                  rows: lots
                      .map(
                        (lot) => _buildDataRow(
                          context,
                          lot,
                          () => context.push('/inventory/lot/${lot.id}'),
                        ),
                      )
                      .toList(),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  DataRow _buildDataRow(
    BuildContext context,
    InventoryLot lot,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isExpired =
        lot.expirationDate != null &&
        lot.expirationDate!.isBefore(DateTime.now());

    // Status Logic
    bool isActive = lot.quantity > 0;

    return DataRow(
      onSelectChanged: (_) => onTap(),
      cells: [
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lot.lotNumber,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (!isActive)
                Text(
                  'Agotado',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.error,
                  ),
                ),
            ],
          ),
        ),
        DataCell(Text(dateFormat.format(lot.receivedAt))),
        DataCell(
          lot.expirationDate == null
              ? const Text('-')
              : Row(
                  children: [
                    Icon(
                      isExpired ? Icons.warning_amber_rounded : Icons.event,
                      size: 16,
                      color: isExpired ? theme.colorScheme.error : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(lot.expirationDate!),
                      style: TextStyle(
                        color: isExpired ? theme.colorScheme.error : null,
                        fontWeight: isExpired
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
        ),
        DataCell(Text('\$${(lot.unitCostCents / 100).toStringAsFixed(2)}')),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${lot.quantity.toStringAsFixed(2)} / ${lot.originalQuantity.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (lot.originalQuantity > 0)
                Text(
                  '${((lot.quantity / lot.originalQuantity) * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isActive ? 'Activo' : 'Inactivo',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LotCard extends StatelessWidget {
  final InventoryLot lot;
  final VoidCallback onTap;

  const _LotCard({required this.lot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isExpired =
        lot.expirationDate != null &&
        lot.expirationDate!.isBefore(DateTime.now());

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lot.lotNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: lot.quantity > 0
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${lot.quantity.toStringAsFixed(2)} / ${lot.originalQuantity.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: lot.quantity > 0
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (lot.originalQuantity > 0)
                      Text(
                        '${((lot.quantity / lot.originalQuantity) * 100).toStringAsFixed(0)}% disponible',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recibido: ${dateFormat.format(lot.receivedAt)}'),
                if (lot.expirationDate != null)
                  Text(
                    'Exp: ${dateFormat.format(lot.expirationDate!)}',
                    style: TextStyle(
                      color: isExpired ? theme.colorScheme.error : null,
                      fontWeight: isExpired
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
