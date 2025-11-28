import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/presentation/providers/cash_session_providers.dart';
import 'package:posventa/presentation/providers/warehouse_providers.dart';

class CashSessionDetailPage extends ConsumerWidget {
  final CashSession session;

  const CashSessionDetailPage({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(cashSessionDetailProvider(session));
    final warehousesAsync = ref.watch(warehouseProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('Sesión #${session.id}'),
        actions: [
          if (session.status == 'open')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: const Text('Abierta'),
                backgroundColor: Colors.green.withAlpha(50),
                labelStyle: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: const Text('Cerrada'),
                backgroundColor: Colors.grey.withAlpha(50),
                labelStyle: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: detailAsync.when(
        data: (detail) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session Info Card
                _buildSessionInfoCard(
                  context,
                  session,
                  warehousesAsync,
                  dateFormat,
                ),
                const SizedBox(height: 16),

                // Financial Summary Card
                _buildFinancialSummaryCard(context, detail, currencyFormat),
                const SizedBox(height: 16),

                // Sales Summary Card
                _buildSalesSummaryCard(context, detail, currencyFormat),
                const SizedBox(height: 16),

                // Manual Movements
                _buildManualMovementsCard(context, detail, currencyFormat),
                const SizedBox(height: 16),

                // Payment Methods Summary
                _buildPaymentMethodsCard(context, detail, currencyFormat),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionInfoCard(
    BuildContext context,
    CashSession session,
    AsyncValue warehousesAsync,
    DateFormat dateFormat,
  ) {
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

  Widget _buildFinancialSummaryCard(
    BuildContext context,
    CashSessionDetail detail,
    NumberFormat currencyFormat,
  ) {
    final session = detail.session;
    final difference = session.differenceCents ?? 0;
    final isNegative = difference < 0;

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
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resumen Financiero',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildFinancialRow(
              context,
              'Fondo Inicial',
              session.openingBalanceCents,
              currencyFormat,
            ),
            const SizedBox(height: 8),
            _buildFinancialRow(
              context,
              'Ventas en Efectivo',
              detail.totalCashSales,
              currencyFormat,
              color: Colors.green,
              prefix: '+',
            ),
            const SizedBox(height: 8),
            _buildFinancialRow(
              context,
              'Movimientos Manuales',
              detail.totalManualMovements,
              currencyFormat,
              color: detail.totalManualMovements >= 0
                  ? Colors.green
                  : Colors.red,
              prefix: detail.totalManualMovements >= 0 ? '+' : '',
            ),
            const Divider(height: 24),
            _buildFinancialRow(
              context,
              'Balance Esperado',
              session.expectedBalanceCents ?? 0,
              currencyFormat,
              isBold: true,
            ),
            if (session.closingBalanceCents != null) ...[
              const SizedBox(height: 8),
              _buildFinancialRow(
                context,
                'Balance Contado',
                session.closingBalanceCents!,
                currencyFormat,
                isBold: true,
              ),
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: difference == 0
                      ? Colors.blue.withAlpha(25)
                      : (isNegative
                            ? Colors.red.withAlpha(25)
                            : Colors.green.withAlpha(25)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          difference == 0
                              ? Icons.check_circle_outline
                              : (isNegative
                                    ? Icons.trending_down
                                    : Icons.trending_up),
                          color: difference == 0
                              ? Colors.blue
                              : (isNegative ? Colors.red : Colors.green),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Diferencia',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: difference == 0
                                ? Colors.blue
                                : (isNegative ? Colors.red : Colors.green),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      currencyFormat.format(difference / 100),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: difference == 0
                            ? Colors.blue
                            : (isNegative ? Colors.red : Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSalesSummaryCard(
    BuildContext context,
    CashSessionDetail detail,
    NumberFormat currencyFormat,
  ) {
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
                Icon(
                  Icons.point_of_sale,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resumen de Ventas',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            if (detail.payments.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('No hay ventas registradas.')),
              )
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total de transacciones:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    '${detail.payments.length}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monto total:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    currencyFormat.format(detail.totalSales / 100),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildManualMovementsCard(
    BuildContext context,
    CashSessionDetail detail,
    NumberFormat currencyFormat,
  ) {
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
                Icon(
                  Icons.swap_vert_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Movimientos Manuales',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            if (detail.movements.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text('No hay movimientos manuales en esta sesión.'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: detail.movements.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final movement = detail.movements[index];
                  final isEntry = movement.movementType == 'entry';
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: isEntry
                          ? Colors.green.withAlpha(25)
                          : Colors.red.withAlpha(25),
                      child: Icon(
                        isEntry ? Icons.add : Icons.remove,
                        color: isEntry ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      movement.reason,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (movement.description != null &&
                            movement.description!.isNotEmpty)
                          Text(movement.description!),
                        Text(
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(movement.movementDate),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: Text(
                      '${isEntry ? '+' : '-'}${currencyFormat.format(movement.amountCents.abs() / 100)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isEntry ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsCard(
    BuildContext context,
    CashSessionDetail detail,
    NumberFormat currencyFormat,
  ) {
    // Group payments by method
    final paymentsByMethod = <String, int>{};
    for (final payment in detail.payments) {
      paymentsByMethod[payment.paymentMethod] =
          (paymentsByMethod[payment.paymentMethod] ?? 0) + payment.amountCents;
    }

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
                Icon(
                  Icons.payment_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Métodos de Pago',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            if (paymentsByMethod.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('No hay pagos registrados.')),
              )
            else
              ...paymentsByMethod.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getPaymentIcon(entry.key),
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(entry.key, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      Text(
                        currencyFormat.format(entry.value / 100),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
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

  Widget _buildFinancialRow(
    BuildContext context,
    String label,
    int amountCents,
    NumberFormat format, {
    bool isBold = false,
    Color? color,
    String prefix = '',
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '$prefix${format.format(amountCents / 100)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
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

  IconData _getPaymentIcon(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'efectivo':
        return Icons.money;
      case 'tarjeta':
      case 'tarjeta de crédito':
      case 'tarjeta de débito':
        return Icons.credit_card;
      case 'transferencia':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }
}
