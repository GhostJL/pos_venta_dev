import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/presentation/pages/cash_session_detail_page.dart';
import 'package:posventa/presentation/providers/cash_session_providers.dart';
import 'package:posventa/presentation/providers/cashier_providers.dart';

class CashSessionHistoryPage extends ConsumerStatefulWidget {
  const CashSessionHistoryPage({super.key});

  @override
  ConsumerState<CashSessionHistoryPage> createState() =>
      _CashSessionHistoryPageState();
}

class _CashSessionHistoryPageState
    extends ConsumerState<CashSessionHistoryPage> {
  int? _selectedUserId;
  int? _selectedWarehouseId;
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final filter = CashSessionFilter(
      userId: _selectedUserId,
      warehouseId: _selectedWarehouseId,
      startDate: _selectedDateRange?.start,
      endDate: _selectedDateRange?.end,
    );

    final sessionsAsync = ref.watch(cashSessionListProvider(filter));
    final cashiersAsync = ref.watch(cashierListProvider);
    final warehousesAsync = ref.watch(warehouseListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Sesiones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () =>
                _showFilterDialog(context, cashiersAsync, warehousesAsync),
          ),
        ],
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text('No se encontraron sesiones.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _SessionCard(session: session);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showFilterDialog(
    BuildContext context,
    AsyncValue<List<dynamic>> cashiersAsync,
    AsyncValue<List<dynamic>> warehousesAsync,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filtrar Sesiones'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Date Range Picker
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
                    // Cashier Dropdown
                    cashiersAsync.when(
                      data: (cashiers) => DropdownButtonFormField<int>(
                        value: _selectedUserId,
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
                    const SizedBox(height: 16),
                    // Warehouse Dropdown
                    warehousesAsync.when(
                      data: (warehouses) => DropdownButtonFormField<int>(
                        value: _selectedWarehouseId,
                        decoration: const InputDecoration(
                          labelText: 'Sucursal',
                        ),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Todas'),
                          ),
                          ...warehouses.map(
                            (w) => DropdownMenuItem(
                              value: w.id,
                              child: Text(w.name),
                            ),
                          ),
                        ],
                        onChanged: (val) =>
                            setDialogState(() => _selectedWarehouseId = val),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Text('Error cargando sucursales'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedUserId = null;
                      _selectedWarehouseId = null;
                      _selectedDateRange = null;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Limpiar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {}); // Trigger rebuild of parent
                    Navigator.pop(context);
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

class _SessionCard extends StatelessWidget {
  final CashSession session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final isOpen = session.status == 'open';
    final color = isOpen ? Colors.green : Colors.grey;
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.point_of_sale, color: color),
        ),
        title: Text(
          'Sesión #${session.id} - ${isOpen ? "Abierta" : "Cerrada"}',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apertura: ${DateFormat('dd/MM/yyyy HH:mm').format(session.openedAt)}',
            ),
            if (session.closedAt != null)
              Text(
                'Cierre: ${DateFormat('dd/MM/yyyy HH:mm').format(session.closedAt!)}',
              ),
            Text('Usuario ID: ${session.userId}'), // Ideally fetch username
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              isOpen
                  ? 'Inicio: ${currencyFormat.format(session.openingBalanceCents / 100)}'
                  : 'Cierre: ${currencyFormat.format((session.closingBalanceCents ?? 0) / 100)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (!isOpen &&
                session.differenceCents != null &&
                session.differenceCents != 0)
              Text(
                'Dif: ${currencyFormat.format(session.differenceCents! / 100)}',
                style: TextStyle(
                  color: session.differenceCents! < 0
                      ? Colors.red
                      : Colors.green,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CashSessionDetailPage(session: session),
            ),
          );
        },
      ),
    );
  }
}
