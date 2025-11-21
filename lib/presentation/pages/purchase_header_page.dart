import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';
import 'package:posventa/presentation/providers/warehouse_providers.dart';

class PurchaseHeaderPage extends ConsumerStatefulWidget {
  const PurchaseHeaderPage({super.key});

  @override
  ConsumerState<PurchaseHeaderPage> createState() => _PurchaseHeaderPageState();
}

class _PurchaseHeaderPageState extends ConsumerState<PurchaseHeaderPage> {
  final _formKey = GlobalKey<FormState>();

  Supplier? _selectedSupplier;
  Warehouse? _selectedWarehouse;
  final _invoiceController = TextEditingController();
  DateTime _purchaseDate = DateTime.now();

  @override
  void dispose() {
    _invoiceController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSupplier == null || _selectedWarehouse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione proveedor y almacén'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate to product selection page with header data
    context.push(
      '/purchases/new/products',
      extra: {
        'supplier': _selectedSupplier!,
        'warehouse': _selectedWarehouse!,
        'invoiceNumber': _invoiceController.text.trim(),
        'purchaseDate': _purchaseDate,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(supplierListProvider);
    final warehousesAsync = ref.watch(warehouseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Compra - Paso 1')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Información General',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete los datos generales de la orden de compra',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Supplier Selection
              suppliersAsync.when(
                data: (suppliers) {
                  return DropdownButtonFormField<Supplier>(
                    value: _selectedSupplier,
                    decoration: const InputDecoration(
                      labelText: 'Proveedor *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                    items: suppliers
                        .map(
                          (s) =>
                              DropdownMenuItem(value: s, child: Text(s.name)),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedSupplier = value),
                    validator: (value) => value == null ? 'Requerido' : null,
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error al cargar proveedores'),
              ),
              const SizedBox(height: 16),

              // Warehouse Selection
              warehousesAsync.when(
                data: (warehouses) {
                  return DropdownButtonFormField<Warehouse>(
                    value: _selectedWarehouse,
                    decoration: const InputDecoration(
                      labelText: 'Almacén Destino *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.warehouse),
                    ),
                    items: warehouses
                        .map(
                          (w) =>
                              DropdownMenuItem(value: w, child: Text(w.name)),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedWarehouse = value),
                    validator: (value) => value == null ? 'Requerido' : null,
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error al cargar almacenes'),
              ),
              const SizedBox(height: 16),

              // Invoice Number
              TextFormField(
                controller: _invoiceController,
                decoration: const InputDecoration(
                  labelText: 'Factura Proveedor (Opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt),
                  hintText: 'Ej: FAC-12345',
                ),
              ),
              const SizedBox(height: 16),

              // Purchase Date
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _purchaseDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _purchaseDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Compra',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    "${_purchaseDate.day.toString().padLeft(2, '0')}/${_purchaseDate.month.toString().padLeft(2, '0')}/${_purchaseDate.year}",
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Continue Button
              ElevatedButton.icon(
                onPressed: _continue,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continuar a Productos'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
