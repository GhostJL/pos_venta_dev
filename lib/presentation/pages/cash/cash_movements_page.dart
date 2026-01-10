import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/presentation/pages/shared/main_layout.dart';
import 'package:posventa/presentation/providers/cash_session_providers.dart';
import 'package:posventa/presentation/providers/cashier_providers.dart';
import 'package:go_router/go_router.dart';

class CashMovementsPage extends ConsumerStatefulWidget {
  const CashMovementsPage({super.key});

  @override
  ConsumerState<CashMovementsPage> createState() => _CashMovementsPageState();
}

class _CashMovementsPageState extends ConsumerState<CashMovementsPage> {
  DateTimeRange? _selectedDateRange;
  int? _selectedUserId;

  @override
  Widget build(BuildContext context) {
    final filter = CashMovementFilter(
      startDate: _selectedDateRange?.start,
      endDate: _selectedDateRange?.end,
      userId: _selectedUserId,
    );

    final movementsAsync = ref.watch(allCashMovementsProvider(filter));
    final cashiersAsync = ref.watch(cashierListProvider);
    final isSmallScreen = MediaQuery.of(context).size.width < 800;
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos de Caja'),
        leading: isSmallScreen
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () =>
                    MainLayout.scaffoldKey.currentState?.openDrawer(),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, cashiersAsync),
          ),
        ],
      ),
      body: movementsAsync.when(
        data: (movements) {
          if (movements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontraron movimientos',
                    style: TextStyle(color: Theme.of(context).disabledColor),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: movements.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final movement = movements[index];
              final isEntry = movement.movementType == 'entry';
              final color = isEntry ? Colors.green : Colors.orange;
              final icon = isEntry
                  ? Icons.arrow_downward
                  : Icons.arrow_upward; // In to box, Out of box?
              // Standard: Entry = Add (Up/In), Withdrawal = Remove (Down/Out)
              // Let's use standard Icons
              final displayIcon = isEntry
                  ? Icons.add_circle_outline
                  : Icons.remove_circle_outline;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.1),
                    child: Icon(displayIcon, color: color),
                  ),
                  title: Text(
                    movement.reason,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateFormat.format(movement.movementDate)),
                      if (movement.description != null &&
                          movement.description!.isNotEmpty)
                        Text(
                          movement.description!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(movement.amountCents / 100),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Sesión #${movement.cashSessionId}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to session detail maybe?
                    // context.push('/cash-sessions/detail', extra: session... we don't have session object here easily without fetching)
                    // limit to just viewing details?
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showFilterDialog(
    BuildContext context,
    AsyncValue<List<dynamic>> cashiersAsync,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filtrar Movimientos'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(
                        _selectedDateRange == null
                            ? 'Seleccionar Fechas'
                            : '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDateRange: _selectedDateRange,
                        );
                        if (picked != null) {
                          setDialogState(() => _selectedDateRange = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    cashiersAsync.when(
                      data: (cashiers) => DropdownButtonFormField<int>(
                        initialValue: _selectedUserId,
                        decoration: const InputDecoration(labelText: 'Cajero'),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Todos'),
                          ),
                          ...cashiers.map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.username),
                            ),
                          ),
                        ],
                        onChanged: (val) =>
                            setDialogState(() => _selectedUserId = val),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Text('Error cargando cajeros'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDateRange = null;
                      _selectedUserId = null;
                    });
                    context.pop();
                  },
                  child: const Text('Limpiar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    context.pop();
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
