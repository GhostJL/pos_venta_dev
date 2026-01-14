import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CashSessionFilterDialog extends StatefulWidget {
  final AsyncValue<List<dynamic>> cashiersAsync;
  final AsyncValue<List<dynamic>> warehousesAsync;
  final bool isCashier;
  final int? selectedUserId;
  final int? selectedWarehouseId;
  final DateTimeRange? selectedDateRange;
  final Function({int? userId, int? warehouseId, DateTimeRange? dateRange})
  onApply;

  const CashSessionFilterDialog({
    super.key,
    required this.cashiersAsync,
    required this.warehousesAsync,
    required this.isCashier,
    this.selectedUserId,
    this.selectedWarehouseId,
    this.selectedDateRange,
    required this.onApply,
  });

  @override
  State<CashSessionFilterDialog> createState() =>
      _CashSessionFilterDialogState();
}

class _CashSessionFilterDialogState extends State<CashSessionFilterDialog> {
  late int? _userId;
  late int? _warehouseId;
  late DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _userId = widget.selectedUserId;
    _warehouseId = widget.selectedWarehouseId;
    _dateRange = widget.selectedDateRange;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtrar Sesiones'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date Range Picker
            ListTile(
              title: Text(
                _dateRange == null
                    ? 'Seleccionar Fechas'
                    : '${DateFormat('dd/MM/yyyy').format(_dateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_dateRange!.end)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _dateRange,
                );
                if (picked != null) {
                  setState(() => _dateRange = picked);
                }
              },
            ),
            const SizedBox(height: 16),
            // Cashier Dropdown (Only for Admins)
            if (!widget.isCashier)
              widget.cashiersAsync.when(
                data: (cashiers) => DropdownButtonFormField<int>(
                  initialValue: _userId,
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
                  onChanged: (val) => setState(() => _userId = val),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error cargando cajeros'),
              ),
            const SizedBox(height: 16),
            // Warehouse Dropdown
            widget.warehousesAsync.when(
              data: (warehouses) => DropdownButtonFormField<int>(
                initialValue: _warehouseId,
                decoration: const InputDecoration(labelText: 'Sucursal'),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Todas'),
                  ),
                  ...warehouses.map(
                    (w) => DropdownMenuItem(value: w.id, child: Text(w.name)),
                  ),
                ],
                onChanged: (val) => setState(() => _warehouseId = val),
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
            widget.onApply(userId: null, warehouseId: null, dateRange: null);
            context.pop();
          },
          child: const Text('Limpiar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(
              userId: _userId,
              warehouseId: _warehouseId,
              dateRange: _dateRange,
            );
            context.pop();
          },
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}
