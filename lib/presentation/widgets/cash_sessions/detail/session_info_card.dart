import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/core/theme/theme.dart';

class SessionInfoCard extends StatelessWidget {
  final CashSession session;
  final AsyncValue<List<Warehouse>> warehousesAsync;
  final DateFormat dateFormat;

  const SessionInfoCard({
    super.key,
    required this.session,
    required this.warehousesAsync,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Información de la Sesión',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        Icons.person_outline,
                        'Usuario',
                        session.userName ?? 'ID: ${session.userId}',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: warehousesAsync.when(
                        data: (warehouses) {
                          String warehouseName = 'ID: ${session.warehouseId}';
                          try {
                            final w = warehouses.firstWhere(
                              (w) => w.id == session.warehouseId,
                            );
                            warehouseName = w.name;
                          } catch (_) {}
                          return _buildInfoItem(
                            context,
                            Icons.store_outlined,
                            'Sucursal',
                            warehouseName,
                          );
                        },
                        loading: () => _buildInfoItem(
                          context,
                          Icons.store_outlined,
                          'Sucursal',
                          'Cargando...',
                        ),
                        error: (_, __) => _buildInfoItem(
                          context,
                          Icons.store_outlined,
                          'Sucursal',
                          'ID: ${session.warehouseId}',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        Icons.login_rounded,
                        'Apertura',
                        dateFormat.format(session.openedAt),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: session.closedAt != null
                          ? _buildInfoItem(
                              context,
                              Icons.logout_rounded,
                              'Cierre',
                              dateFormat.format(session.closedAt!),
                            )
                          : _buildInfoItem(
                              context,
                              Icons.access_time,
                              'Estado',
                              'En Curso',
                              color: AppTheme.transactionSuccess,
                            ),
                    ),
                  ],
                ),
                if (session.closedAt != null) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          Icons.timer_outlined,
                          'Duración',
                          _formatDuration(
                            session.closedAt!.difference(session.openedAt),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (session.notes != null && session.notes!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.note_outlined,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Notas',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.notes!,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color ?? theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
