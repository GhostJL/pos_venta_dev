import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/presentation/widgets/common/right_click_menu_wrapper.dart';

class PurchaseHeader extends StatelessWidget {
  const PurchaseHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: _buildHeader(context, 'Proveedor')),
          Expanded(flex: 2, child: _buildHeader(context, 'Fecha')),
          Expanded(flex: 1, child: _buildHeader(context, 'Items')),
          Expanded(flex: 2, child: _buildHeader(context, 'Total')),
          Expanded(flex: 2, child: _buildHeader(context, 'Estado')),
          const SizedBox(width: 48), // Actions space
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class PurchaseTableRow extends StatelessWidget {
  final Purchase purchase;

  const PurchaseTableRow({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    final menuItems = [
      const PopupMenuItem(
        value: 'view',
        child: Row(
          children: [
            Icon(Icons.visibility_outlined, size: 20),
            SizedBox(width: 8),
            Text('Ver Detalles'),
          ],
        ),
      ),
    ];

    void onAction(String value) {
      if (value == 'view') {
        context.push('/purchases/${purchase.id}');
      }
    }

    return RightClickMenuWrapper(
      menuItems: menuItems,
      onSelected: onAction,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 8),
        color: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/purchases/${purchase.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Proveedor
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        purchase.supplierName ?? 'Proveedor General',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Fecha
                Expanded(
                  flex: 2,
                  child: Text(
                    dateFormat.format(purchase.purchaseDate),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),

                // Items
                Expanded(
                  flex: 1,
                  child: Text(
                    '${purchase.items.length} items',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),

                // Total
                Expanded(
                  flex: 2,
                  child: Text(
                    currencyFormat.format(purchase.total),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),

                // Estado
                Expanded(
                  flex: 2,
                  child: _buildStatusChip(context, purchase.status),
                ),

                // Actions
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onSelected: onAction,
                  itemBuilder: (context) => menuItems,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, PurchaseStatus status) {
    Color color;
    Color bgColor;
    String label;

    switch (status) {
      case PurchaseStatus.pending:
        color = Colors.orange;
        bgColor = Colors.orange.withValues(alpha: 0.1);
        label = 'PENDIENTE';
        break;
      case PurchaseStatus.partial:
        color = Colors.blue;
        bgColor = Colors.blue.withValues(alpha: 0.1);
        label = 'PARCIAL';
        break;
      case PurchaseStatus.completed:
        color = Colors.green;
        bgColor = Colors.green.withValues(alpha: 0.1);
        label = 'COMPLETADO';
        break;
      case PurchaseStatus.cancelled:
        color = Colors.red;
        bgColor = Colors.red.withValues(alpha: 0.1);
        label = 'CANCELADO';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
