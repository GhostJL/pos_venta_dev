import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/domain/entities/warehouse.dart';

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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Información de la Sesión',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              Icons.person_outline,
              'Usuario',
              session.userName ?? 'ID: ${session.userId}',
            ),
            const SizedBox(height: 12),
            warehousesAsync.when(
              data: (warehouses) {
                String warehouseName = 'ID: ${session.warehouseId}';
                try {
                  final warehouse = warehouses.firstWhere(
                    (w) => w.id == session.warehouseId,
                  );
                  warehouseName = warehouse.name;
                } catch (e) {
                  // Warehouse not found, use default
                }
                return _buildInfoRow(
                  context,
                  Icons.store_outlined,
                  'Sucursal',
                  warehouseName,
                );
              },
              loading: () => _buildInfoRow(
                context,
                Icons.store_outlined,
                'Sucursal',
                'Cargando...',
              ),
              error: (_, __) => _buildInfoRow(
                context,
                Icons.store_outlined,
                'Sucursal',
                'ID: ${session.warehouseId}',
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              Icons.login_rounded,
              'Apertura',
              dateFormat.format(session.openedAt),
            ),
            if (session.closedAt != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                Icons.logout_rounded,
                'Cierre',
                dateFormat.format(session.closedAt!),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                Icons.timer_outlined,
                'Duración',
                _formatDuration(session.closedAt!.difference(session.openedAt)),
              ),
            ],
            if (session.notes != null && session.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                Icons.note_outlined,
                'Notas',
                session.notes!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).hintColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
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
