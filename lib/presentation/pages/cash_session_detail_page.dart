import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/presentation/providers/cash_session_providers.dart';

class CashSessionDetailPage extends ConsumerWidget {
  final CashSession session;

  const CashSessionDetailPage({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(cashSessionDetailProvider(session));
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(title: Text('Detalle de Sesión #${session.id}')),
      body: detailAsync.when(
        data: (detail) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(detail, currencyFormat),
                const SizedBox(height: 24),
                const Text(
                  'Movimientos Manuales',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildMovementsList(detail, currencyFormat),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSummaryCard(CashSessionDetail detail, NumberFormat format) {
    final session = detail.session;
    final difference = session.differenceCents ?? 0;
    final isNegative = difference < 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRow('Fondo Inicial', session.openingBalanceCents, format),
            const Divider(),
            _buildRow(
              'Ventas en Efectivo',
              detail.totalCashSales,
              format,
              isPositive: true,
            ),
            _buildRow(
              'Movimientos Manuales',
              detail.totalManualMovements,
              format,
            ),
            const Divider(),
            _buildRow(
              'Balance Esperado',
              session.expectedBalanceCents ?? 0,
              format,
              isBold: true,
            ),
            _buildRow(
              'Balance Contado',
              session.closingBalanceCents ?? 0,
              format,
              isBold: true,
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Diferencia',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  format.format(difference / 100),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: difference == 0
                        ? Colors.black
                        : (isNegative ? Colors.red : Colors.green),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    int amountCents,
    NumberFormat format, {
    bool isBold = false,
    bool? isPositive,
  }) {
    Color? color;
    if (isPositive != null) {
      color = isPositive ? Colors.green : Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
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
            format.format(amountCents / 100),
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementsList(CashSessionDetail detail, NumberFormat format) {
    if (detail.movements.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No hay movimientos manuales en esta sesión.'),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: detail.movements.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final movement = detail.movements[index];
        final isEntry = movement.movementType == 'entry';
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isEntry
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            child: Icon(
              isEntry ? Icons.arrow_downward : Icons.arrow_upward,
              color: isEntry ? Colors.green : Colors.red,
            ),
          ),
          title: Text(movement.reason),
          subtitle: Text(DateFormat('HH:mm').format(movement.movementDate)),
          trailing: Text(
            format.format(movement.amountCents / 100),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isEntry ? Colors.green : Colors.red,
            ),
          ),
        );
      },
    );
  }
}
