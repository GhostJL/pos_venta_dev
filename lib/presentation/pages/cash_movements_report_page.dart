import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/presentation/providers/cash_session_providers.dart';

class CashMovementsReportPage extends ConsumerStatefulWidget {
  const CashMovementsReportPage({super.key});

  @override
  ConsumerState<CashMovementsReportPage> createState() =>
      _CashMovementsReportPageState();
}

class _CashMovementsReportPageState
    extends ConsumerState<CashMovementsReportPage> {
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final filter = CashMovementFilter(
      startDate: _selectedDateRange?.start,
      endDate: _selectedDateRange?.end,
    );

    final movementsAsync = ref.watch(allCashMovementsProvider(filter));
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Movimientos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _selectedDateRange,
              );
              if (picked != null) {
                setState(() => _selectedDateRange = picked);
              }
            },
          ),
        ],
      ),
      body: movementsAsync.when(
        data: (movements) {
          if (movements.isEmpty) {
            return const Center(child: Text('No hay movimientos registrados.'));
          }

          // Calculate totals
          int totalEntries = 0;
          int totalExits = 0;
          for (var m in movements) {
            if (m.movementType == 'entry') {
              totalEntries += m.amountCents;
            } else {
              totalExits += m.amountCents;
            }
          }

          return Column(
            children: [
              // Summary Header
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.primary.withAlpha(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTotalColumn(
                      'Entradas',
                      totalEntries,
                      Colors.green,
                      currencyFormat,
                    ),
                    _buildTotalColumn(
                      'Salidas',
                      totalExits,
                      Colors.red,
                      currencyFormat,
                    ),
                    _buildTotalColumn(
                      'Neto',
                      totalEntries - totalExits,
                      Colors.blue,
                      currencyFormat,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: movements.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final movement = movements[index];
                    final isEntry = movement.movementType == 'entry';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isEntry
                            ? Colors.green.withAlpha(10)
                            : Colors.red.withAlpha(10),
                        child: Icon(
                          isEntry ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isEntry ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(movement.reason),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(movement.movementDate),
                          ),
                          if (movement.description != null &&
                              movement.description!.isNotEmpty)
                            Text(
                              movement.description!,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      trailing: Text(
                        formatAmount(
                          movement.amountCents,
                          isEntry,
                          currencyFormat,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isEntry ? Colors.green : Colors.red,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  String formatAmount(int cents, bool isEntry, NumberFormat format) {
    final amount = cents / 100;
    return isEntry ? '+${format.format(amount)}' : '-${format.format(amount)}';
  }

  Widget _buildTotalColumn(
    String label,
    int cents,
    Color color,
    NumberFormat format,
  ) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          format.format(cents / 100),
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
