import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';
import 'package:posventa/presentation/providers/warehouse_providers.dart';
import 'package:posventa/core/theme/theme.dart';

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
          backgroundColor: AppTheme.transactionPending,
        ),
      );
      return;
    }

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Compra'),
        backgroundColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Datos de la Orden',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Configure los detalles iniciales para su orden de compra.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Group 1: Entities
              _FormSection(
                title: 'Proveedor y Destino',
                children: [
                  suppliersAsync.when(
                    data: (suppliers) => DropdownButtonFormField<Supplier>(
                      initialValue: _selectedSupplier,
                      decoration: const InputDecoration(
                        labelText: 'Proveedor',
                        prefixIcon: Icon(Icons.business_outlined),
                      ),
                      items: suppliers
                          .map(
                            (s) =>
                                DropdownMenuItem(value: s, child: Text(s.name)),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedSupplier = value),
                      validator: (value) =>
                          value == null ? 'Seleccione un proveedor' : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error al cargar proveedores'),
                  ),
                  const SizedBox(height: 16),
                  warehousesAsync.when(
                    data: (warehouses) => DropdownButtonFormField<Warehouse>(
                      initialValue: _selectedWarehouse,
                      decoration: const InputDecoration(
                        labelText: 'Almacén de Recepción',
                        prefixIcon: Icon(Icons.warehouse_outlined),
                      ),
                      items: warehouses
                          .map(
                            (w) =>
                                DropdownMenuItem(value: w, child: Text(w.name)),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedWarehouse = value),
                      validator: (value) =>
                          value == null ? 'Seleccione un almacén' : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error al cargar almacenes'),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Group 2: Document Info
              _FormSection(
                title: 'Información del Documento',
                children: [
                  TextFormField(
                    controller: _invoiceController,
                    decoration: const InputDecoration(
                      labelText: 'Número de Factura (Opcional)',
                      prefixIcon: Icon(Icons.receipt_long_outlined),
                      hintText: 'Ej: FAC-001-1234',
                    ),
                  ),
                  const SizedBox(height: 16),
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
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha de Compra',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        DateFormat('dd / MM / yyyy').format(_purchaseDate),
                        style: textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              FilledButton.icon(
                onPressed: _continue,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continuar a Selección de Productos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FormSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}
