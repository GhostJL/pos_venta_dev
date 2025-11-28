import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/cash_session.dart';
import 'package:go_router/go_router.dart';
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
  void initState() {
    super.initState();
    // Auto-refresh sessions when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Invalidate with default filter (nulls) as that's what the page starts with
      ref.invalidate(cashSessionListProvider(CashSessionFilter()));
    });
  }

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
        title: const Text('Sesiones de Caja'),
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
              return SessionCard(session: session);
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
                    const SizedBox(height: 16),
                    // Warehouse Dropdown
                    warehousesAsync.when(
                      data: (warehouses) => DropdownButtonFormField<int>(
                        initialValue: _selectedWarehouseId,
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
                    context.pop();
                  },
                  child: const Text('Limpiar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {}); // Trigger rebuild of parent
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

class SessionCard extends StatelessWidget {
  final CashSession session;

  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final isOpen = session.status == 'open';
    final statusColor = isOpen ? Colors.green : Colors.grey;
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/cash-sessions/detail', extra: session),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header: Sesión + Estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sesión #${session.id}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.circle, color: statusColor, size: 10),
                      const SizedBox(width: 6),
                      Text(
                        isOpen ? 'Abierta' : 'Cerrada',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// Apertura y cierre
              Row(
                children: [
                  Icon(
                    Icons.login_rounded,
                    size: 16,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(session.openedAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              if (session.closedAt != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 16,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(session.closedAt!),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              /// Usuario
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    session.userName ?? 'ID: ${session.userId}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// Balances
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isOpen
                        ? 'Inicio: ${currencyFormat.format(session.openingBalanceCents / 100)}'
                        : 'Cierre: ${currencyFormat.format((session.closingBalanceCents ?? 0) / 100)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (!isOpen &&
                      session.differenceCents != null &&
                      session.differenceCents != 0)
                    Text(
                      'Dif: ${currencyFormat.format(session.differenceCents! / 100)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: session.differenceCents! < 0
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
